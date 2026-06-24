param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..\..')).Path,
    [switch]$FailOnRequired
)

$ErrorActionPreference = 'Stop'

$pluginRoot = Join-Path $ProjectRoot 'Plugins\Angelscript'
$testRoot = Join-Path $pluginRoot 'Source\AngelscriptTest'

$results = New-Object System.Collections.Generic.List[object]

Get-ChildItem -Path $testRoot -Recurse -Filter '*.cpp' | ForEach-Object {
    $file = $_.FullName
    $lines = Get-Content -LiteralPath $file
    $braceDepth = 0

    for ($index = 0; $index -lt $lines.Count; ++$index) {
        $line = $lines[$index]

        if ($line -match '^\s*using namespace\s+([A-Za-z0-9_:]+);') {
            $namespace = $matches[1]
            $category = $null

            $isFileLevel = $braceDepth -eq 0
            $isSdkSupport = $isFileLevel -and $file -like '*\AngelScriptSDK\*' -and $namespace -match '^Angelscript(Builder|Native|SDK)'
            $isPrivateSupport =
                $isFileLevel -and (
                $namespace -match '(TestHelpers)$' -or
                $namespace -match '^CompilerPipeline.*Test$' -or
                $namespace -eq 'PreprocessorTestHelpers' -or
                $namespace -eq 'SubsystemGetterMetadataTest' -or
                $namespace -eq 'CurveTestHelpers' -or
                $namespace -eq 'WorldCollisionTraceTestHelpers')
            $isPrivateUsingDirective = $namespace -match '_Private$'
            $isDeferredSharedUtility = $isFileLevel -and $namespace -in @('AngelscriptFunctionalTestUtils', 'AngelscriptActorTestUtils', 'AngelscriptBlueprintTestUtils')

            if ($isSdkSupport) {
                $category = 'RequiredSdk'
            }
            elseif ($isPrivateUsingDirective) {
                $category = 'RequiredPrivateUsingDirective'
            }
            elseif ($isPrivateSupport) {
                $category = 'RequiredPrivate'
            }
            elseif ($isDeferredSharedUtility) {
                $category = 'DeferredSharedUtility'
            }

            if ($null -ne $category) {
                $results.Add([PSCustomObject]@{
                    Category = $category
                    File = $file.Replace($pluginRoot + '\', '').Replace('\', '/')
                    Line = $index + 1
                    Namespace = $namespace
                }) | Out-Null
            }
        }

        if ($braceDepth -eq 0 -and $line -match '^\s*namespace\s+([A-Za-z0-9_]+_Private)\s*$') {
            $results.Add([PSCustomObject]@{
                Category = 'RequiredPrivateNamespaceDefinition'
                File = $file.Replace($pluginRoot + '\', '').Replace('\', '/')
                Line = $index + 1
                Namespace = $matches[1]
            }) | Out-Null
        }

        $withoutStrings = $line -replace '"(?:\\.|[^"])*"', '""'
        $braceDepth += ([regex]::Matches($withoutStrings, '\{')).Count - ([regex]::Matches($withoutStrings, '\}')).Count
        if ($braceDepth -lt 0) {
            $braceDepth = 0
        }
    }
}

$required = @($results | Where-Object { $_.Category -like 'Required*' } | Sort-Object File, Line)
$deferred = @($results | Where-Object { $_.Category -eq 'DeferredSharedUtility' } | Sort-Object File, Line)

foreach ($group in $results | Group-Object Category | Sort-Object Name) {
    $files = @($group.Group | Select-Object -ExpandProperty File -Unique)
    Write-Output ("{0}: imports={1}, files={2}" -f $group.Name, $group.Count, $files.Count)
}

if ($required.Count -gt 0) {
    Write-Output ''
    Write-Output 'Required namespace imports/directives/definitions:'
    $required | ForEach-Object {
        if ($_.Category -eq 'RequiredPrivateNamespaceDefinition') {
            Write-Output ("{0}:{1} namespace {2}" -f $_.File, $_.Line, $_.Namespace)
        }
        else {
            Write-Output ("{0}:{1} using namespace {2};" -f $_.File, $_.Line, $_.Namespace)
        }
    }
}

if ($deferred.Count -gt 0) {
    Write-Output ''
    Write-Output 'Deferred shared utility imports:'
    $deferred | ForEach-Object {
        Write-Output ("{0}:{1} using namespace {2};" -f $_.File, $_.Line, $_.Namespace)
    }
}

if ($FailOnRequired -and $required.Count -gt 0) {
    throw ("Found {0} required namespace import/directive violation(s)." -f $required.Count)
}
