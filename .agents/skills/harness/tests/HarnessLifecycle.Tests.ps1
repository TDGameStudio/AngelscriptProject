#requires -Version 7.0
$ErrorActionPreference='Stop'
# One integrated selection: full planning Create and Replan, actual fixture
# arrangements, real plugin/replica closure and incomplete multi-repo recovery.
& (Join-Path $PSScriptRoot 'HarnessClosure.Tests.ps1') -IncludeReplan
& (Join-Path $PSScriptRoot 'HarnessIncompleteClosure.Tests.ps1') -WithPlugin
& python -X utf8 -m unittest discover -s $PSScriptRoot -p test_closure_withdrawal.py
if ($LASTEXITCODE) { throw 'Withdrawal proof failed' }
'HarnessLifecycle.Tests.ps1: PASS'
