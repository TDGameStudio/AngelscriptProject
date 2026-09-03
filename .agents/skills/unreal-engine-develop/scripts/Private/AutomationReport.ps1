$script:UnrealAutomationSummarySchema = 'hardness-unreal-automation-summary'
$script:UnrealAutomationMaxReportBytes = 134217728
$script:UnrealAutomationMaxLogBytes = 262144
$script:UnrealAutomationMaxLogHints = 20
$script:UnrealAutomationMaxTextLength = 512
$script:UnrealAutomationMaxTestDetails = 200

function Limit-UnrealAutomationText {
    param(
        [AllowEmptyString()][string] $Value,
        [int] $MaximumLength = $script:UnrealAutomationMaxTextLength
    )
    if ($null -eq $Value) { return '' }
    $normalized = $Value.Replace("`0", '').Trim()
    if ($normalized.Length -le $MaximumLength) { return $normalized }
    return $normalized.Substring(0, $MaximumLength)
}

function Get-UnrealAutomationExactProperty {
    param(
        [Parameter(Mandatory = $true)] $Value,
        [Parameter(Mandatory = $true)][string] $Name,
        [switch] $Required
    )
    $property = @($Value.PSObject.Properties | Where-Object { $_.Name -ceq $Name } | Select-Object -First 1)
    if ($property.Count -eq 0) {
        if ($Required) { throw "Required lower-camel JSON property '$Name' is missing." }
        return $null
    }
    return $property[0].Value
}

function ConvertTo-UnrealAutomationCount {
    param(
        [AllowNull()] $Value,
        [Parameter(Mandatory = $true)][string] $Name,
        [switch] $Optional
    )
    if ($null -eq $Value -and $Optional) { return 0 }
    $parsed = 0
    if (-not [int]::TryParse([string] $Value, [ref] $parsed) -or $parsed -lt 0) {
        throw "Automation JSON property '$Name' must be a non-negative integer."
    }
    return $parsed
}

function Resolve-UnrealAutomationIndexPath {
    param([Parameter(Mandatory = $true)][string] $ReportPath)
    if ([string]::IsNullOrWhiteSpace($ReportPath)) { throw 'ReportPath cannot be empty.' }
    $fullPath = [System.IO.Path]::GetFullPath($ReportPath)
    if (Test-Path -LiteralPath $fullPath -PathType Container) {
        return Join-Path $fullPath 'index.json'
    }
    if ([System.IO.Path]::GetExtension($fullPath).Equals('.json', [System.StringComparison]::OrdinalIgnoreCase)) {
        return $fullPath
    }
    return Join-Path $fullPath 'index.json'
}

function Get-UnrealAutomationLogEvidence {
    param([AllowEmptyString()][string] $LogPath)
    $hints = [System.Collections.Generic.List[string]]::new()
    $bytesInspected = 0
    $truncated = $false
    if ([string]::IsNullOrWhiteSpace($LogPath) -or -not (Test-Path -LiteralPath $LogPath -PathType Leaf)) {
        return [pscustomobject]@{ Hints = @(); BytesInspected = 0; Truncated = $false }
    }

    $stream = [System.IO.File]::Open($LogPath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::ReadWrite)
    try {
        $bytesInspected = [int] [Math]::Min([int64] $script:UnrealAutomationMaxLogBytes, $stream.Length)
        $truncated = $stream.Length -gt $bytesInspected
        if ($truncated) { [void] $stream.Seek(-$bytesInspected, [System.IO.SeekOrigin]::End) }
        $buffer = [byte[]]::new($bytesInspected)
        $offset = 0
        while ($offset -lt $bytesInspected) {
            $read = $stream.Read($buffer, $offset, $bytesInspected - $offset)
            if ($read -le 0) { break }
            $offset += $read
        }
        $text = [System.Text.Encoding]::UTF8.GetString($buffer, 0, $offset)
    }
    finally {
        $stream.Dispose()
    }

    if ($truncated) {
        $firstNewLine = $text.IndexOf("`n", [System.StringComparison]::Ordinal)
        $text = if ($firstNewLine -ge 0) { $text.Substring($firstNewLine + 1) } else { '' }
    }
    $failurePattern = '(?i)(fatal error|assertion failed|ensure condition failed|unhandled exception|automation test failed|log[a-z0-9_]*:\s*error:|(?:^|\s)error:)'
    $matches = @($text -split '\r?\n' | Where-Object { $_ -match $failurePattern })
    foreach ($line in @($matches | Select-Object -Last $script:UnrealAutomationMaxLogHints)) {
        $hint = Limit-UnrealAutomationText -Value ([string] $line)
        if (-not [string]::IsNullOrWhiteSpace($hint)) { $hints.Add($hint) }
    }
    return [pscustomobject]@{ Hints = @($hints); BytesInspected = $bytesInspected; Truncated = $truncated }
}

function New-UnrealAutomationSummaryResult {
    param(
        [Parameter(Mandatory = $true)][string] $ReportPath,
        [Parameter(Mandatory = $true)][int] $ProcessExitCode,
        [Parameter(Mandatory = $true)] $LogEvidence
    )
    return [pscustomobject][ordered]@{
        SchemaVersion          = $script:UnrealAutomationSummarySchema
        SummarySource         = 'None'
        Outcome               = 'Missing'
        Passed                = $false
        Complete              = $false
        ReportFound           = $false
        ReportValid           = $false
        ReportPath            = $ReportPath
        ReportBytes           = 0
        ReportCreatedOn       = ''
        ProcessExitCode       = $ProcessExitCode
        Total                 = 0
        Succeeded             = 0
        SucceededWithWarnings = 0
        Failed                = 0
        Skipped               = 0
        NotRun                = 0
        InProcess             = 0
        Warnings              = 0
        Errors                = 0
        FailedTests           = @()
        FailedTestsTotal      = 0
        FailedTestsTruncated  = $false
        SkippedTests          = @()
        SkippedTestsTotal     = 0
        SkippedTestsTruncated = $false
        IncompleteTests       = @()
        IncompleteTestsTotal  = 0
        IncompleteTestsTruncated = $false
        LogFailureHints       = @($LogEvidence.Hints)
        LogBytesInspected     = [int] $LogEvidence.BytesInspected
        LogTruncated          = [bool] $LogEvidence.Truncated
        Reasons               = @()
    }
}

function Get-UnrealAutomationSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)][string] $ReportPath,
        [string] $LogPath = '',
        [int] $ProcessExitCode = 0
    )

    $indexPath = Resolve-UnrealAutomationIndexPath -ReportPath $ReportPath
    $logEvidence = Get-UnrealAutomationLogEvidence -LogPath $LogPath
    $summary = New-UnrealAutomationSummaryResult -ReportPath $indexPath -ProcessExitCode $ProcessExitCode -LogEvidence $logEvidence
    $reasons = [System.Collections.Generic.List[string]]::new()
    if (-not (Test-Path -LiteralPath $indexPath -PathType Leaf)) {
        $reasons.Add('UE Automation index.json is missing.')
        if ($ProcessExitCode -ne 0) { $reasons.Add("Native process exited with code $ProcessExitCode.") }
        $summary.Reasons = @($reasons)
        return $summary
    }
    $summary.ReportFound = $true
    $summary.ReportBytes = [long](Get-Item -LiteralPath $indexPath).Length
    if ($summary.ReportBytes -gt $script:UnrealAutomationMaxReportBytes) {
        $summary.Outcome = 'Malformed'
        $reasons.Add("UE Automation index.json size $($summary.ReportBytes) exceeds the maximum $script:UnrealAutomationMaxReportBytes bytes.")
        $summary.Reasons = @($reasons)
        return $summary
    }

    try {
        $document = Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8 | ConvertFrom-Json -Depth 100 -ErrorAction Stop
        if ($null -eq $document -or $document -isnot [pscustomobject]) {
            throw 'The report root must be a JSON object.'
        }

        $succeeded = ConvertTo-UnrealAutomationCount -Name 'succeeded' -Value (Get-UnrealAutomationExactProperty -Value $document -Name 'succeeded' -Required)
        $succeededWithWarnings = ConvertTo-UnrealAutomationCount -Name 'succeededWithWarnings' -Value (Get-UnrealAutomationExactProperty -Value $document -Name 'succeededWithWarnings' -Required)
        $failed = ConvertTo-UnrealAutomationCount -Name 'failed' -Value (Get-UnrealAutomationExactProperty -Value $document -Name 'failed' -Required)
        $notRun = ConvertTo-UnrealAutomationCount -Name 'notRun' -Value (Get-UnrealAutomationExactProperty -Value $document -Name 'notRun' -Required)
        $inProcess = ConvertTo-UnrealAutomationCount -Name 'inProcess' -Value (Get-UnrealAutomationExactProperty -Value $document -Name 'inProcess' -Required)
        $testsValue = Get-UnrealAutomationExactProperty -Value $document -Name 'tests' -Required
        if ($null -eq $testsValue) { $tests = @() }
        elseif ($testsValue -is [System.Array] -or $testsValue -is [pscustomobject]) { $tests = @($testsValue) }
        else { throw "Automation JSON property 'tests' must be an array." }

        $failedTests = [System.Collections.Generic.List[object]]::new()
        $skippedTests = [System.Collections.Generic.List[object]]::new()
        $incompleteTests = [System.Collections.Generic.List[object]]::new()
        $derived = @{ Success = 0; SuccessWithWarnings = 0; Fail = 0; NotRun = 0; InProcess = 0; Skipped = 0 }
        $warningTotal = 0
        $errorTotal = 0
        foreach ($test in $tests) {
            if ($null -eq $test -or $test -isnot [pscustomobject]) { throw 'Every tests entry must be a JSON object.' }
            $fullTestPath = [string](Get-UnrealAutomationExactProperty -Value $test -Name 'fullTestPath' -Required)
            $displayNameValue = Get-UnrealAutomationExactProperty -Value $test -Name 'testDisplayName'
            $displayName = if ($null -eq $displayNameValue) { $fullTestPath } else { [string] $displayNameValue }
            $state = [string](Get-UnrealAutomationExactProperty -Value $test -Name 'state' -Required)
            if ([string]::IsNullOrWhiteSpace($fullTestPath)) { throw "Automation test 'fullTestPath' cannot be empty." }
            $warnings = ConvertTo-UnrealAutomationCount -Name "$fullTestPath.warnings" -Value (Get-UnrealAutomationExactProperty -Value $test -Name 'warnings') -Optional
            $errors = ConvertTo-UnrealAutomationCount -Name "$fullTestPath.errors" -Value (Get-UnrealAutomationExactProperty -Value $test -Name 'errors') -Optional
            $warningTotal += $warnings
            $errorTotal += $errors
            if ($state -ceq 'Success' -and $errors -gt 0) {
                throw "Automation test '$fullTestPath' has state Success but reports $errors error(s)."
            }
            $record = [pscustomobject][ordered]@{
                FullTestPath = $fullTestPath
                DisplayName  = $displayName
                State        = $state
                Warnings     = $warnings
                Errors       = $errors
            }
            switch -CaseSensitive ($state) {
                'Success' {
                    if ($warnings -gt 0) { $derived.SuccessWithWarnings++ }
                    else { $derived.Success++ }
                }
                'Fail' {
                    $derived.Fail++
                    if ($failedTests.Count -lt $script:UnrealAutomationMaxTestDetails) { $failedTests.Add($record) }
                }
                'Skipped' {
                    $derived.Skipped++
                    if ($skippedTests.Count -lt $script:UnrealAutomationMaxTestDetails) { $skippedTests.Add($record) }
                }
                'NotRun' {
                    $derived.NotRun++
                    if ($incompleteTests.Count -lt $script:UnrealAutomationMaxTestDetails) { $incompleteTests.Add($record) }
                }
                'InProcess' {
                    $derived.InProcess++
                    if ($incompleteTests.Count -lt $script:UnrealAutomationMaxTestDetails) { $incompleteTests.Add($record) }
                }
                default { throw "Automation test '$fullTestPath' has unsupported state '$state'." }
            }
        }

        foreach ($countCheck in @(
            [pscustomobject]@{ Name = 'succeeded'; Expected = $succeeded; Actual = $derived.Success }
            [pscustomobject]@{ Name = 'succeededWithWarnings'; Expected = $succeededWithWarnings; Actual = $derived.SuccessWithWarnings }
            [pscustomobject]@{ Name = 'failed'; Expected = $failed; Actual = $derived.Fail }
            [pscustomobject]@{ Name = 'notRun'; Expected = $notRun; Actual = $derived.NotRun }
            [pscustomobject]@{ Name = 'inProcess'; Expected = $inProcess; Actual = $derived.InProcess }
        )) {
            if ([int] $countCheck.Expected -ne [int] $countCheck.Actual) {
                throw "Automation JSON count '$($countCheck.Name)' is $($countCheck.Expected), but tests contain $($countCheck.Actual)."
            }
        }

        $createdValue = Get-UnrealAutomationExactProperty -Value $document -Name 'reportCreatedOn'
        $summary.SummarySource = 'UEAutomationJson'
        $summary.ReportValid = $true
        $summary.ReportCreatedOn = if ($null -eq $createdValue) { '' } else { [string] $createdValue }
        $summary.Total = $tests.Count
        $summary.Succeeded = $succeeded
        $summary.SucceededWithWarnings = $succeededWithWarnings
        $summary.Failed = $failed
        $summary.Skipped = $derived.Skipped
        $summary.NotRun = $notRun
        $summary.InProcess = $inProcess
        $summary.Warnings = $warningTotal
        $summary.Errors = $errorTotal
        $summary.FailedTests = @($failedTests)
        $summary.FailedTestsTotal = $derived.Fail
        $summary.FailedTestsTruncated = $derived.Fail -gt $failedTests.Count
        $summary.SkippedTests = @($skippedTests)
        $summary.SkippedTestsTotal = $derived.Skipped
        $summary.SkippedTestsTruncated = $derived.Skipped -gt $skippedTests.Count
        $summary.IncompleteTests = @($incompleteTests)
        $summary.IncompleteTestsTotal = $derived.NotRun + $derived.InProcess
        $summary.IncompleteTestsTruncated = $summary.IncompleteTestsTotal -gt $incompleteTests.Count
        $summary.Complete = $tests.Count -gt 0 -and $notRun -eq 0 -and $inProcess -eq 0

        if ($tests.Count -eq 0) {
            $summary.Outcome = 'Incomplete'
            $reasons.Add('UE Automation report contains no tests.')
        }
        elseif ($notRun -gt 0 -or $inProcess -gt 0) {
            $summary.Outcome = 'Incomplete'
            $reasons.Add("UE Automation report is incomplete: notRun=$notRun, inProcess=$inProcess.")
        }
        elseif ($failed -gt 0 -or $ProcessExitCode -ne 0) {
            $summary.Outcome = 'Failed'
            if ($failed -gt 0) { $reasons.Add("UE Automation reported $failed failed test(s).") }
            if ($ProcessExitCode -ne 0) { $reasons.Add("Native process exited with code $ProcessExitCode.") }
        }
        elseif ($succeededWithWarnings -gt 0 -or $warningTotal -gt 0 -or $derived.Skipped -gt 0) {
            $summary.Outcome = 'PassedWithWarnings'
            if ($derived.Skipped -gt 0) { $reasons.Add("UE Automation skipped $($derived.Skipped) test(s).") }
        }
        else {
            $summary.Outcome = 'Passed'
        }
        $summary.Passed = $summary.Outcome -in @('Passed', 'PassedWithWarnings')
    }
    catch {
        $summary.SummarySource = 'None'
        $summary.Outcome = 'Malformed'
        $summary.Passed = $false
        $summary.Complete = $false
        $summary.ReportValid = $false
        $reasons.Clear()
        $reasons.Add((Limit-UnrealAutomationText -Value "UE Automation JSON is invalid: $($_.Exception.Message)"))
        if ($ProcessExitCode -ne 0) { $reasons.Add("Native process exited with code $ProcessExitCode.") }
    }
    $summary.Reasons = @($reasons | Select-Object -First $script:UnrealAutomationMaxLogHints)
    return $summary
}
