# Offline fallback for the live demo.
# Runs the same deterministic gate as CI and prints Fail/Pass counts.
# Expected on the flawed templates: Fail=32, Pass=68.
#
# IMPORTANT: run with -NoProfile (this machine's pwsh profile hangs otherwise):
#   pwsh -NoProfile -File ./scripts/psrule-check.ps1

$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')
$r = Invoke-PSRule -InputPath ./infra/ -Module PSRule.Rules.Azure -Option ./ps-rule.yaml -Format File -Baseline Azure.Default
Write-Output "TOTAL=$($r.Count)"
$r | Group-Object Outcome | ForEach-Object { Write-Output "$($_.Name)=$($_.Count)" }
