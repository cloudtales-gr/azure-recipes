<#
.SYNOPSIS
  NET-01: tests the NSG rules from inside the VNet. Runs a small probe on vm-web and vm-app with Run Command
  (no SSH, no public IP) and prints one line per connection: expected, actual, OK or NO.
#>
[CmdletBinding()]
param()
$ErrorActionPreference = 'Stop'
$rg = 'rg-recipe-net-01'
if (-not (Get-AzContext)) { Connect-AzAccount | Out-Null }

# Same probe as test.sh: open a TCP connection with a 3-second timeout.
$probe = @'
probe() {  # from to ip port expected
  if timeout 3 bash -c "</dev/tcp/$3/$4" 2>/dev/null; then got=allowed; else got=blocked; fi
  if [ "$got" = "$5" ]; then ok=OK; else ok=NO; fi
  printf '%-3s %-4s -> %-4s %-15s expected %-7s got %s\n' "$ok" "$1" "$2" "$3:$4" "$5" "$got"
}
'@
$tests = @{
    'vm-web' = @(
        'probe web app  10.10.2.4 8080 allowed'
        'probe web app  10.10.2.4 22   blocked'
        'probe web data 10.10.3.4 5432 blocked')
    'vm-app' = @(
        'probe app data 10.10.3.4 5432 allowed'
        'probe app web  10.10.1.4 22   blocked')
}
foreach ($vm in 'vm-web', 'vm-app') {
    $script = $probe + "`n" + ($tests[$vm] -join "`n")
    $r = Invoke-AzVMRunCommand -ResourceGroupName $rg -VMName $vm -CommandId 'RunShellScript' -ScriptString $script
    # Run Command returns "[stdout] ... [stderr] ..."; keep the stdout part
    ($r.Value[0].Message -split '\[stderr\]')[0] -replace '(?s).*\[stdout\]\s*', '' -split "`n" |
        Where-Object { $_.Trim() } | ForEach-Object { $_.TrimEnd() }
}
