# Test-SdkHandoff.ps1
# Usage: & Test-SdkHandoff.ps1 -WorkspaceRoot <root> -ExpectedChangeUid change_6f58d4ea-1ff3-48f6-8680-df1b32635270 [-RequireComplete]
# Depends on: PowerShell 7, producer change.yaml, attachments/data/sdk-handoff.json, SHA-256 of listed SDK headers.
#Requires -Version 7
param(
	[Parameter(Mandatory = $true)][string]$WorkspaceRoot,
	[Parameter(Mandatory = $true)][string]$ExpectedChangeUid,
	[switch]$RequireComplete
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-ProducerRoot {
	param([string]$Root, [string]$Uid)
	$active = Join-Path $Root 'openspec/changes/angelscript/feature-types-explicit-ownership'
	$candidates = @()
	if (Test-Path -LiteralPath (Join-Path $active 'change.yaml')) { $candidates += $active }
	$archive = Join-Path $Root 'openspec/archive/changes/angelscript'
	if (Test-Path -LiteralPath $archive) {
		$candidates += @(Get-ChildItem -LiteralPath $archive -Directory | Where-Object {
			$_.Name -like '*-feature-types-explicit-ownership'
		} | ForEach-Object { $_.FullName })
	}
	foreach ($candidate in $candidates) {
		$manifest = Join-Path $candidate 'change.yaml'
		if (-not (Test-Path -LiteralPath $manifest)) { continue }
		$text = Get-Content -LiteralPath $manifest -Raw
		if ($text -match [regex]::Escape($Uid)) { return $candidate }
	}
	throw "Producer Change $Uid was not found under active or archived locations."
}

$producer = Resolve-ProducerRoot -Root $WorkspaceRoot -Uid $ExpectedChangeUid
$handoffPath = Join-Path $producer 'attachments/data/sdk-handoff.json'
if (-not (Test-Path -LiteralPath $handoffPath -PathType Leaf)) {
	throw "Missing sdk-handoff.json at $handoffPath"
}
$handoff = Get-Content -LiteralPath $handoffPath -Raw | ConvertFrom-Json
if ($handoff.schema -ne 'external-types-handoff-v1') {
	throw "Unexpected handoff schema: $($handoff.schema)"
}
if ($handoff.producer_uid -ne $ExpectedChangeUid) {
	throw "Handoff UID $($handoff.producer_uid) does not match $ExpectedChangeUid"
}
if ($handoff.preparation -ne 'shared-const-v1') {
	throw "Handoff preparation must be shared-const-v1"
}
if ($RequireComplete) {
	if ($handoff.status -ne 'complete') { throw 'Handoff status is not complete' }
	$tasks = Join-Path $producer 'tasks.md'
	$pending = @(Select-String -LiteralPath $tasks -Pattern '^- \[ \]' )
	if ($pending.Count -gt 0) {
		throw "Producer still has $($pending.Count) unchecked task(s)"
	}
}
foreach ($entry in $handoff.sources.PSObject.Properties) {
	$relative = $entry.Name
	$expected = [string]$entry.Value
	$path = Join-Path $WorkspaceRoot $relative
	if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
		throw "Missing source $relative"
	}
	$actual = (Get-FileHash -Algorithm SHA256 -LiteralPath $path).Hash.ToLowerInvariant()
	if ($actual -ne $expected.ToLowerInvariant()) {
		throw "Stale hash for ${relative}: expected $expected actual $actual"
	}
}
Write-Output "SDK handoff verified for $ExpectedChangeUid from $producer"
exit 0
