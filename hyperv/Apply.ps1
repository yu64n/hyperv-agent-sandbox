#Requires -RunAsAdministrator
[CmdletBinding()] param([string]$Config = "config/sandbox.env")
$ErrorActionPreference = "Stop"
if (!(Test-Path $Config)) { $Config = "config/sandbox.env.example" }
$settings = @{}
Get-Content $Config | Where-Object { $_ -match '^[^#=]+=' } | ForEach-Object { $k,$v = $_ -split '=',2; $settings[$k]=$v }
function Ensure-Switch($Name,$Type) {
  $switch = Get-VMSwitch -Name $Name -ErrorAction SilentlyContinue
  if (!$switch) { New-VMSwitch -Name $Name -SwitchType $Type | Out-Null; return }
  if ($switch.SwitchType -ne $Type) { throw "Switch '$Name' must be a $Type switch (found $($switch.SwitchType))" }
}
Ensure-Switch $settings.INTERNAL_SWITCH Private
if (!(Get-VMSwitch -Name $settings.EXTERNAL_SWITCH -ErrorAction SilentlyContinue)) { throw "Create external switch '$($settings.EXTERNAL_SWITCH)' on the intended WAN adapter first" }
New-Item -ItemType Directory -Force $settings.VM_ROOT | Out-Null
function Ensure-VM($Name,$Memory,$Switch,$DiskSize) {
  $disk = Join-Path $settings.VM_ROOT "$Name.vhdx"
  if (!(Test-Path $disk)) { New-VHD -Path $disk -Dynamic -SizeBytes $DiskSize | Out-Null }
  if (!(Get-VM -Name $Name -ErrorAction SilentlyContinue)) { New-VM -Name $Name -Generation 2 -MemoryStartupBytes $Memory -VHDPath $disk -SwitchName $Switch | Out-Null }
  Set-VM -Name $Name -AutomaticCheckpointsEnabled $false -AutomaticStartAction Nothing -AutomaticStopAction ShutDown
}
function Resolve-Media($Path,$Description) {
  if (!$Path -or !(Test-Path -LiteralPath $Path -PathType Leaf)) { throw "$Description not found: '$Path'" }
  return (Resolve-Path -LiteralPath $Path).Path
}
function Ensure-Dvd($VMName,$Path) {
  if (!(Get-VMDvdDrive -VMName $VMName | Where-Object { $_.Path -eq $Path })) {
    Add-VMDvdDrive -VMName $VMName -Path $Path | Out-Null
  }
}
$routerInstaller = Resolve-Media $settings.ROUTER_INSTALLER_ISO "Router installer ISO"
$sandboxInstaller = Resolve-Media $settings.SANDBOX_INSTALLER_ISO "Sandbox installer ISO"
$routerSeed = Resolve-Media (Join-Path $settings.SEED_ROOT "router.iso") "Router cloud-init seed ISO"
$sandboxSeed = Resolve-Media (Join-Path $settings.SEED_ROOT "sandbox.iso") "Sandbox cloud-init seed ISO"
Ensure-VM $settings.ROUTER_VM 1GB $settings.EXTERNAL_SWITCH 16GB
if ((Get-VMNetworkAdapter -VMName $settings.ROUTER_VM).SwitchName -notcontains $settings.INTERNAL_SWITCH) { Add-VMNetworkAdapter -VMName $settings.ROUTER_VM -SwitchName $settings.INTERNAL_SWITCH -Name LAN }
Ensure-VM $settings.SANDBOX_VM 4GB $settings.INTERNAL_SWITCH 64GB
Ensure-Dvd $settings.ROUTER_VM $routerInstaller
Ensure-Dvd $settings.ROUTER_VM $routerSeed
Ensure-Dvd $settings.SANDBOX_VM $sandboxInstaller
Ensure-Dvd $settings.SANDBOX_VM $sandboxSeed
Set-VMFirmware -VMName $settings.ROUTER_VM -FirstBootDevice (Get-VMDvdDrive -VMName $settings.ROUTER_VM | Where-Object Path -eq $routerInstaller)
Set-VMFirmware -VMName $settings.SANDBOX_VM -FirstBootDevice (Get-VMDvdDrive -VMName $settings.SANDBOX_VM | Where-Object Path -eq $sandboxInstaller)
Write-Host "VM resources and installer/cloud-init media are ready. Install both guests, then use make apply."
