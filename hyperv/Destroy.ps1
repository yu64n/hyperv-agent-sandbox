#Requires -RunAsAdministrator
[CmdletBinding(SupportsShouldProcess)] param([string]$Config = "config/sandbox.env")
if (!(Test-Path $Config)) { $Config = "config/sandbox.env.example" }
$s=@{}; Get-Content $Config | ? { $_ -match '^[^#=]+=' } | % { $k,$v=$_ -split '=',2; $s[$k]=$v }
foreach ($name in @($s.SANDBOX_VM,$s.ROUTER_VM)) { if (Get-VM $name -ErrorAction SilentlyContinue) { Stop-VM $name -TurnOff -Force -ErrorAction SilentlyContinue; Remove-VM $name -Force } }
if (Get-VMSwitch $s.INTERNAL_SWITCH -ErrorAction SilentlyContinue) { Remove-VMSwitch $s.INTERNAL_SWITCH -Force }

