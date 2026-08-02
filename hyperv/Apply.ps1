#Requires -RunAsAdministrator
[CmdletBinding()] param([string]$Config = "config/sandbox.env")
$ErrorActionPreference = "Stop"
if (!(Test-Path $Config)) { $Config = "config/sandbox.env.example" }
$settings = @{}
Get-Content $Config | Where-Object { $_ -match '^[^#=]+=' } | ForEach-Object { $k,$v = $_ -split '=',2; $settings[$k]=$v }
function Ensure-Switch($Name,$Type) { if (!(Get-VMSwitch -Name $Name -ErrorAction SilentlyContinue)) { New-VMSwitch -Name $Name -SwitchType $Type | Out-Null } }
Ensure-Switch $settings.INTERNAL_SWITCH Internal
if (!(Get-VMSwitch -Name $settings.EXTERNAL_SWITCH -ErrorAction SilentlyContinue)) { throw "Create external switch '$($settings.EXTERNAL_SWITCH)' on the intended WAN adapter first" }
New-Item -ItemType Directory -Force $settings.VM_ROOT | Out-Null
function Ensure-VM($Name,$Memory,$Switch,$DiskSize) {
  $disk = Join-Path $settings.VM_ROOT "$Name.vhdx"
  if (!(Test-Path $disk)) { New-VHD -Path $disk -Dynamic -SizeBytes $DiskSize | Out-Null }
  if (!(Get-VM -Name $Name -ErrorAction SilentlyContinue)) { New-VM -Name $Name -Generation 2 -MemoryStartupBytes $Memory -VHDPath $disk -SwitchName $Switch | Out-Null }
  Set-VM -Name $Name -AutomaticCheckpointsEnabled $false -AutomaticStartAction Nothing -AutomaticStopAction ShutDown
}
Ensure-VM $settings.ROUTER_VM 1GB $settings.EXTERNAL_SWITCH 16GB
if ((Get-VMNetworkAdapter -VMName $settings.ROUTER_VM).SwitchName -notcontains $settings.INTERNAL_SWITCH) { Add-VMNetworkAdapter -VMName $settings.ROUTER_VM -SwitchName $settings.INTERNAL_SWITCH -Name LAN }
Ensure-VM $settings.SANDBOX_VM 4GB $settings.INTERNAL_SWITCH 64GB
Write-Host "VM resources are ready. Attach installer media for first boot, then use make apply."

