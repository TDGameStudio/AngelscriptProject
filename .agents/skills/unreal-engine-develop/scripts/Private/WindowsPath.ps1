$script:UnrealDriveAssignmentSchema = 'hardness-unreal-drive-assignments'
$script:UnrealDriveLetters = @([char[]](90..71) | ForEach-Object { "$_`:" })
$script:UnrealDriveAssignmentLimit = 256

function Initialize-UnrealDosDeviceInterop {
    if (-not [System.OperatingSystem]::IsWindows()) { return }
    if ($null -ne ('Hardness.Unreal.Interop.DosDeviceNative' -as [type])) { return }
    Add-Type -TypeDefinition @'
using System;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;
using Microsoft.Win32.SafeHandles;

namespace Hardness.Unreal.Interop
{
    [StructLayout(LayoutKind.Sequential)]
    public struct ByHandleFileInformation
    {
        public uint FileAttributes;
        public System.Runtime.InteropServices.ComTypes.FILETIME CreationTime;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastAccessTime;
        public System.Runtime.InteropServices.ComTypes.FILETIME LastWriteTime;
        public uint VolumeSerialNumber;
        public uint FileSizeHigh;
        public uint FileSizeLow;
        public uint NumberOfLinks;
        public uint FileIndexHigh;
        public uint FileIndexLow;
    }

    public static class DosDeviceNative
    {
        public const uint DDD_RAW_TARGET_PATH = 0x00000001;
        public const uint DDD_REMOVE_DEFINITION = 0x00000002;
        public const uint DDD_EXACT_MATCH_ON_REMOVE = 0x00000004;
        public const uint DDD_NO_BROADCAST_SYSTEM = 0x00000008;
        private const uint FILE_SHARE_READ = 0x00000001;
        private const uint FILE_SHARE_WRITE = 0x00000002;
        private const uint FILE_SHARE_DELETE = 0x00000004;
        private const uint OPEN_EXISTING = 3;
        private const uint FILE_ATTRIBUTE_NORMAL = 0x00000080;

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern uint QueryDosDevice(string deviceName, StringBuilder targetPath, int maximumLength);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool DefineDosDevice(uint flags, string deviceName, string targetPath);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern SafeFileHandle CreateFile(
            string fileName,
            uint desiredAccess,
            uint shareMode,
            IntPtr securityAttributes,
            uint creationDisposition,
            uint flagsAndAttributes,
            IntPtr templateFile);

        [DllImport("kernel32.dll", SetLastError = true)]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetFileInformationByHandle(
            SafeFileHandle file,
            out ByHandleFileInformation information);

        public static string Query(string deviceName)
        {
            StringBuilder buffer = new StringBuilder(32768);
            uint result = QueryDosDevice(deviceName, buffer, buffer.Capacity);
            if (result == 0)
            {
                int error = Marshal.GetLastWin32Error();
                if (error == 2) return null;
                throw new Win32Exception(error, "QueryDosDevice failed for " + deviceName);
            }
            string value = buffer.ToString();
            int separator = value.IndexOf('\0');
            return separator < 0 ? value : value.Substring(0, separator);
        }

        public static void Create(string deviceName, string rawTargetPath)
        {
            uint flags = DDD_RAW_TARGET_PATH | DDD_NO_BROADCAST_SYSTEM;
            if (!DefineDosDevice(flags, deviceName, rawTargetPath))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "DefineDosDevice create failed for " + deviceName);
        }

        public static void RemoveExact(string deviceName, string rawTargetPath)
        {
            uint flags = DDD_RAW_TARGET_PATH | DDD_REMOVE_DEFINITION |
                DDD_EXACT_MATCH_ON_REMOVE | DDD_NO_BROADCAST_SYSTEM;
            if (!DefineDosDevice(flags, deviceName, rawTargetPath))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "DefineDosDevice exact removal failed for " + deviceName);
        }

        public static string FileIdentity(string path)
        {
            using (SafeFileHandle handle = CreateFile(
                path,
                0,
                FILE_SHARE_READ | FILE_SHARE_WRITE | FILE_SHARE_DELETE,
                IntPtr.Zero,
                OPEN_EXISTING,
                FILE_ATTRIBUTE_NORMAL,
                IntPtr.Zero))
            {
                if (handle.IsInvalid)
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateFile failed for " + path);
                ByHandleFileInformation information;
                if (!GetFileInformationByHandle(handle, out information))
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "GetFileInformationByHandle failed for " + path);
                ulong index = ((ulong)information.FileIndexHigh << 32) | information.FileIndexLow;
                return information.VolumeSerialNumber.ToString("X8") + ":" + index.ToString("X16");
            }
        }
    }
}
'@
}

function Get-UnrealDriveAssignmentStorePath {
    if ($env:HARDNESS_UNREAL_TEST_MODE -ceq '1' -and -not [string]::IsNullOrWhiteSpace($env:HARDNESS_UNREAL_TEST_STATE_ROOT)) {
        $testRoot = ConvertTo-UnrealCanonicalPath -Path $env:HARDNESS_UNREAL_TEST_STATE_ROOT -AllowMissing
        return Join-Path $testRoot 'DriveAssignments.json'
    }
    $base = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)
    if ([string]::IsNullOrWhiteSpace($base)) { throw 'LOCALAPPDATA is unavailable for the Hardness drive-assignment registry.' }
    return Join-Path $base 'TDGameStudio/Hardness/Unreal/DriveAssignments.json'
}

function New-UnrealDriveAssignmentStore {
    return [pscustomobject][ordered]@{
        schemaVersion = $script:UnrealDriveAssignmentSchema
        assignments   = @()
    }
}

function Read-UnrealDriveAssignmentStore {
    $path = Get-UnrealDriveAssignmentStorePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { return New-UnrealDriveAssignmentStore }
    if ((Get-Item -LiteralPath $path).Length -gt (1024 * 1024)) { throw "Drive-assignment registry exceeds 1 MiB: $path" }
    $store = Read-UnrealJsonFile -Path $path
    if ([string] $store.schemaVersion -cne $script:UnrealDriveAssignmentSchema) {
        throw "Unsupported drive-assignment registry schema: $($store.schemaVersion)"
    }
    $assignments = @($store.assignments)
    if ($assignments.Count -gt $script:UnrealDriveAssignmentLimit) {
        throw "Drive-assignment registry exceeds $script:UnrealDriveAssignmentLimit entries."
    }
    $seenKeys = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    $seenDrives = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($assignment in $assignments) {
        foreach ($name in @('key', 'workspaceRoot', 'projectFile', 'gitCommonDir', 'driveLetter', 'rawTarget', 'ownerRunId', 'ownerPid', 'mappingOwned', 'updatedAtUtc')) {
            if ($null -eq $assignment.PSObject.Properties[$name]) { throw "Drive-assignment registry entry is missing '$name'." }
        }
        if ([string] $assignment.key -notmatch '^[a-f0-9]{64}$' -or
            [string] $assignment.driveLetter -notmatch '^[G-Z]:$' -or
            -not $seenKeys.Add([string] $assignment.key) -or
            -not $seenDrives.Add([string] $assignment.driveLetter)) {
            throw 'Drive-assignment registry contains an invalid or duplicate assignment.'
        }
        $workspace = ConvertTo-UnrealCanonicalPath -Path ([string] $assignment.workspaceRoot) -AllowMissing
        $project = ConvertTo-UnrealCanonicalPath -Path ([string] $assignment.projectFile) -AllowMissing
        $common = ConvertTo-UnrealCanonicalPath -Path ([string] $assignment.gitCommonDir) -AllowMissing
        $expectedKey = Get-UnrealSha256Text -Value ("{0}|{1}" -f $common, $workspace)
        $ownerRunId = [string] $assignment.ownerRunId
        $ownerPid = 0
        $validOwnerPid = if ([string]::IsNullOrWhiteSpace($ownerRunId)) {
            $null -eq $assignment.ownerPid
        }
        else {
            [int]::TryParse([string] $assignment.ownerPid, [ref] $ownerPid) -and $ownerPid -gt 0
        }
        $updatedAt = [DateTimeOffset]::MinValue
        $validUpdatedAt = [DateTimeOffset]::TryParse([string] $assignment.updatedAtUtc, [ref] $updatedAt)
        if (-not (Test-UnrealPathEqual -Left $workspace -Right ([string] $assignment.workspaceRoot)) -or
            -not (Test-UnrealPathEqual -Left $project -Right ([string] $assignment.projectFile)) -or
            -not (Test-UnrealPathEqual -Left $common -Right ([string] $assignment.gitCommonDir)) -or
            [string] $assignment.key -cne $expectedKey -or
            [string] $assignment.rawTarget -cne (ConvertTo-UnrealRawDosTarget -WorkspaceRoot $workspace) -or
            ($ownerRunId -ne '' -and $ownerRunId -notmatch '^[a-f0-9]{32}$') -or
            -not $validOwnerPid -or -not $validUpdatedAt -or $assignment.mappingOwned -isnot [bool]) {
            throw 'Drive-assignment registry contains invalid identity or ownership data.'
        }
    }
    return $store
}

function Write-UnrealDriveAssignmentStore {
    param([Parameter(Mandatory = $true)] $Store)
    $assignments = @($Store.assignments)
    if ($assignments.Count -gt $script:UnrealDriveAssignmentLimit) {
        throw "Drive-assignment registry exceeds $script:UnrealDriveAssignmentLimit entries."
    }
    Write-UnrealJsonFileAtomic -Path (Get-UnrealDriveAssignmentStorePath) -Value ([pscustomobject][ordered]@{
        schemaVersion = $script:UnrealDriveAssignmentSchema
        assignments   = $assignments
    })
}

function Get-UnrealWorkspaceAssignmentKey {
    param(
        [Parameter(Mandatory = $true)][string] $GitCommonDir,
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot
    )
    $common = ConvertTo-UnrealCanonicalPath -Path $GitCommonDir
    $workspace = ConvertTo-UnrealCanonicalPath -Path $WorkspaceRoot
    return Get-UnrealSha256Text -Value ("{0}|{1}" -f $common, $workspace)
}

function ConvertTo-UnrealRawDosTarget {
    param([Parameter(Mandatory = $true)][string] $WorkspaceRoot)
    $workspace = ConvertTo-UnrealCanonicalPath -Path $WorkspaceRoot -AllowMissing
    if ($workspace.StartsWith('\\', [System.StringComparison]::Ordinal)) {
        return '\??\UNC\' + $workspace.TrimStart('\')
    }
    return '\??\' + $workspace
}

function ConvertFrom-UnrealRawDosTarget {
    param([AllowEmptyString()][string] $RawTarget)
    if ([string]::IsNullOrWhiteSpace($RawTarget)) { return '' }
    if ($RawTarget.StartsWith('\??\UNC\', [System.StringComparison]::OrdinalIgnoreCase)) { return '\\' + $RawTarget.Substring(8).TrimEnd('\', '/') }
    if ($RawTarget.StartsWith('\??\', [System.StringComparison]::Ordinal)) { return $RawTarget.Substring(4).TrimEnd('\', '/') }
    if ($RawTarget.StartsWith('\DosDevices\', [System.StringComparison]::OrdinalIgnoreCase)) { return $RawTarget.Substring(12).TrimEnd('\', '/') }
    return $RawTarget.TrimEnd('\', '/')
}

function Get-UnrealDosDeviceTarget {
    param([Parameter(Mandatory = $true)][ValidatePattern('^[G-Z]:$')][string] $DriveLetter)
    if (-not [System.OperatingSystem]::IsWindows()) { return '' }
    Initialize-UnrealDosDeviceInterop
    $raw = [Hardness.Unreal.Interop.DosDeviceNative]::Query($DriveLetter.ToUpperInvariant())
    $value = if ($null -eq $raw) { '' } else { [string] $raw }
    return $value
}

function Test-UnrealDosDeviceTargetsWorkspace {
    param(
        [AllowEmptyString()][string] $RawTarget,
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot
    )
    if ([string]::IsNullOrWhiteSpace($RawTarget)) { return $false }
    $target = ConvertFrom-UnrealRawDosTarget -RawTarget $RawTarget
    return Test-UnrealPathEqual -Left $target -Right $WorkspaceRoot
}

function ConvertTo-UnrealExecutionPath {
    param(
        [Parameter(Mandatory = $true)][string] $PhysicalPath,
        [Parameter(Mandatory = $true)] $Execution
    )
    $physicalRoot = ConvertTo-UnrealCanonicalPath -Path ([string] $Execution.physicalWorkspaceRoot) -AllowMissing
    $physical = Assert-UnrealPathContained -Root $physicalRoot -Path $PhysicalPath -Purpose 'workspace execution path'
    if ([string] $Execution.strategy -ceq 'Direct') { return $physical }
    $relative = [System.IO.Path]::GetRelativePath($physicalRoot, $physical)
    $executionRoot = ([string] $Execution.workspaceRoot).TrimEnd('\', '/')
    if ($relative -eq '.') { return $executionRoot + '\' }
    return $executionRoot + '\' + $relative.Replace('/', '\')
}

function Get-UnrealExecutionPaths {
    param(
        [Parameter(Mandatory = $true)] $PhysicalPaths,
        [Parameter(Mandatory = $true)] $Execution
    )
    $values = [ordered]@{}
    foreach ($property in @($PhysicalPaths.PSObject.Properties)) {
        $values[$property.Name] = ConvertTo-UnrealExecutionPath -PhysicalPath ([string] $property.Value) -Execution $Execution
    }
    return [pscustomobject] $values
}

function Get-UnrealDriveAssignmentOwnerState {
    param([Parameter(Mandatory = $true)] $Assignment)
    $runId = [string] $Assignment.ownerRunId
    if ($runId -notmatch '^[a-f0-9]{32}$') { return 'None' }
    try {
        $paths = Get-UnrealRunPaths -WorkspaceRoot ([string] $Assignment.workspaceRoot) -RunId $runId
        if (-not (Test-Path -LiteralPath $paths.MetadataPath -PathType Leaf)) { return 'Stale' }
        $metadata = Read-UnrealJsonFile -Path $paths.MetadataPath
        if ([string] $metadata.state -in $script:UnrealTerminalStates) { return 'Stale' }
        if (Test-UnrealProcessAlive -ProcessId $metadata.workerPid) { return 'Live' }
    }
    catch { }
    return 'Stale'
}

function Test-UnrealDriveAssignmentIdentity {
    param([Parameter(Mandatory = $true)] $Assignment)
    $workspace = [string] $Assignment.workspaceRoot
    $project = [string] $Assignment.projectFile
    $common = [string] $Assignment.gitCommonDir
    if (-not (Test-Path -LiteralPath $workspace -PathType Container) -or
        -not (Test-Path -LiteralPath $project -PathType Leaf) -or
        -not (Test-Path -LiteralPath $common)) { return $false }
    try {
        [void](Assert-UnrealPathContained -Root $workspace -Path $project -Purpose 'registered assignment project file')
        $previousPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        try {
            $observed = @(& git -C $workspace rev-parse --path-format=absolute --git-common-dir 2>$null)
            $exitCode = $LASTEXITCODE
        }
        finally { $ErrorActionPreference = $previousPreference }
        if ($exitCode -ne 0 -or $observed.Count -ne 1) { return $false }
        $observedCommon = ConvertTo-UnrealCanonicalPath -Path ([string] $observed[0])
        if (-not (Test-UnrealPathEqual -Left $observedCommon -Right $common)) { return $false }
        $expectedKey = Get-UnrealWorkspaceAssignmentKey -GitCommonDir $common -WorkspaceRoot $workspace
        return [string] $Assignment.key -ceq $expectedKey
    }
    catch { return $false }
}

function Remove-UnrealStaleDriveAssignments {
    param([Parameter(Mandatory = $true)] $Store)
    $retained = [System.Collections.Generic.List[object]]::new()
    foreach ($assignment in @($Store.assignments)) {
        $workspace = [string] $assignment.workspaceRoot
        $common = [string] $assignment.gitCommonDir
        $ownerState = Get-UnrealDriveAssignmentOwnerState -Assignment $assignment
        $identityExists = Test-UnrealDriveAssignmentIdentity -Assignment $assignment
        $target = Get-UnrealDosDeviceTarget -DriveLetter ([string] $assignment.driveLetter)
        if (-not [string]::IsNullOrWhiteSpace($target) -and [bool] $assignment.mappingOwned -and
            (Test-UnrealDosDeviceTargetsWorkspace -RawTarget $target -WorkspaceRoot $workspace) -and $ownerState -eq 'Stale') {
            try { [Hardness.Unreal.Interop.DosDeviceNative]::RemoveExact([string] $assignment.driveLetter, [string] $assignment.rawTarget) }
            catch { }
        }
        if ($identityExists) {
            if ($ownerState -eq 'Stale') {
                $assignment.ownerRunId = ''
                $assignment.ownerPid = $null
                $assignment.mappingOwned = $false
                $assignment.updatedAtUtc = [DateTimeOffset]::UtcNow.ToString('o')
            }
            $retained.Add($assignment)
        }
    }
    $Store.assignments = @($retained)
    return $Store
}

function Select-UnrealExecutionDrive {
    param(
        [Parameter(Mandatory = $true)] $Store,
        [Parameter(Mandatory = $true)][string] $AssignmentKey,
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot
    )
    $existing = @($Store.assignments | Where-Object { [string] $_.key -ceq $AssignmentKey } | Select-Object -First 1)
    if ($existing.Count -eq 1) {
        $drive = [string] $existing[0].driveLetter
        $target = Get-UnrealDosDeviceTarget -DriveLetter $drive
        if ([string]::IsNullOrWhiteSpace($target) -or (Test-UnrealDosDeviceTargetsWorkspace -RawTarget $target -WorkspaceRoot $WorkspaceRoot)) {
            return $drive
        }
    }
    $registered = [System.Collections.Generic.HashSet[string]]::new([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($assignment in @($Store.assignments | Where-Object { [string] $_.key -cne $AssignmentKey })) {
        [void] $registered.Add([string] $assignment.driveLetter)
    }
    foreach ($drive in $script:UnrealDriveLetters) {
        if ($registered.Contains($drive)) { continue }
        $target = Get-UnrealDosDeviceTarget -DriveLetter $drive
        if (Test-UnrealDosDeviceTargetsWorkspace -RawTarget $target -WorkspaceRoot $WorkspaceRoot) { return $drive }
    }
    foreach ($drive in $script:UnrealDriveLetters) {
        if ($registered.Contains($drive)) { continue }
        if ([string]::IsNullOrWhiteSpace((Get-UnrealDosDeviceTarget -DriveLetter $drive))) { return $drive }
    }
    throw 'No transient DOS drive letter is available in the G: through Z: allocation range.'
}

function New-UnrealExecutionDescription {
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $ProjectFile,
        [Parameter(Mandatory = $true)][string] $AssignmentKey,
        [Parameter(Mandatory = $true)][string] $DriveLetter,
        [Parameter(Mandatory = $true)][ValidateSet('Proposed', 'Assigned', 'Conflict', 'Unsupported')][string] $AssignmentState,
        [Parameter(Mandatory = $true)][ValidateSet('Absent', 'Ready', 'Owned', 'Foreign', 'StaleOwned')][string] $MappingState
    )
    $physicalRoot = ConvertTo-UnrealCanonicalPath -Path $WorkspaceRoot
    $physicalProject = ConvertTo-UnrealCanonicalPath -Path $ProjectFile
    if (-not [System.OperatingSystem]::IsWindows()) {
        return [pscustomobject][ordered]@{
            strategy              = 'Direct'
            assignmentKey         = $AssignmentKey
            driveLetter           = ''
            workspaceRoot         = $physicalRoot
            projectFile           = $physicalProject
            physicalWorkspaceRoot = $physicalRoot
            physicalProjectFile   = $physicalProject
            rawTarget             = ''
            assignmentState       = 'Unsupported'
            mappingState          = 'Ready'
        }
    }
    $root = $DriveLetter.ToUpperInvariant() + '\'
    $relativeProject = [System.IO.Path]::GetRelativePath($physicalRoot, $physicalProject).Replace('/', '\')
    return [pscustomobject][ordered]@{
        strategy              = 'DosDevice'
        assignmentKey         = $AssignmentKey
        driveLetter           = $DriveLetter.ToUpperInvariant()
        workspaceRoot         = $root
        projectFile           = $root + $relativeProject
        physicalWorkspaceRoot = $physicalRoot
        physicalProjectFile   = $physicalProject
        rawTarget             = ConvertTo-UnrealRawDosTarget -WorkspaceRoot $physicalRoot
        assignmentState       = $AssignmentState
        mappingState          = $MappingState
    }
}

function Get-UnrealExecutionPath {
    param(
        [Parameter(Mandatory = $true)][string] $WorkspaceRoot,
        [Parameter(Mandatory = $true)][string] $ProjectFile,
        [Parameter(Mandatory = $true)][string] $GitCommonDir,
        [Parameter(Mandatory = $true)][string] $RunId,
        [switch] $Assign
    )
    $workspace = ConvertTo-UnrealCanonicalPath -Path $WorkspaceRoot
    $project = ConvertTo-UnrealCanonicalPath -Path $ProjectFile
    [void](Assert-UnrealPathContained -Root $workspace -Path $project -Purpose 'execution project file')
    $key = Get-UnrealWorkspaceAssignmentKey -GitCommonDir $GitCommonDir -WorkspaceRoot $workspace
    if (-not [System.OperatingSystem]::IsWindows()) {
        return New-UnrealExecutionDescription -WorkspaceRoot $workspace -ProjectFile $project -AssignmentKey $key -DriveLetter 'G:' -AssignmentState Unsupported -MappingState Ready
    }

    $lease = $null
    try {
        if ($Assign) {
            $lease = Enter-UnrealLease -Scope 'drive-registry' -Key (Get-UnrealDriveAssignmentStorePath) -Policy Wait -TimeoutMs 10000
            if ($null -eq $lease) { throw 'Timed out acquiring the drive-assignment registry lease.' }
        }
        $store = Read-UnrealDriveAssignmentStore
        if ($Assign) { $store = Remove-UnrealStaleDriveAssignments -Store $store }
        $existingForKey = @($store.assignments | Where-Object { [string] $_.key -ceq $key } | Select-Object -First 1)
        $drive = Select-UnrealExecutionDrive -Store $store -AssignmentKey $key -WorkspaceRoot $workspace
        $raw = Get-UnrealDosDeviceTarget -DriveLetter $drive
        $mappingState = if ([string]::IsNullOrWhiteSpace($raw)) { 'Absent' } elseif (Test-UnrealDosDeviceTargetsWorkspace -RawTarget $raw -WorkspaceRoot $workspace) { 'Foreign' } else { 'Absent' }
        if ($existingForKey.Count -eq 1 -and [bool] $existingForKey[0].mappingOwned -and $mappingState -eq 'Foreign') {
            $mappingState = if ((Get-UnrealDriveAssignmentOwnerState -Assignment $existingForKey[0]) -eq 'Live') { 'Owned' } else { 'StaleOwned' }
        }

        if ($Assign) {
            $records = [System.Collections.Generic.List[object]]::new()
            foreach ($record in @($store.assignments | Where-Object { [string] $_.key -cne $key -and [string] $_.driveLetter -cne $drive })) { $records.Add($record) }
            $existing = @($store.assignments | Where-Object { [string] $_.key -ceq $key } | Select-Object -First 1)
            $mappingOwned = $false
            $ownerRunId = ''
            $ownerPid = $null
            if ($existing.Count -eq 1 -and [string] $existing[0].driveLetter -ceq $drive -and [bool] $existing[0].mappingOwned -and $mappingState -eq 'Foreign') {
                $mappingOwned = $true
                $mappingState = 'StaleOwned'
            }
            if ($existing.Count -eq 1 -and (Get-UnrealDriveAssignmentOwnerState -Assignment $existing[0]) -eq 'Live') {
                $ownerRunId = [string] $existing[0].ownerRunId
                $ownerPid = $existing[0].ownerPid
                $mappingOwned = [bool] $existing[0].mappingOwned
            }
            $records.Add([pscustomobject][ordered]@{
                key           = $key
                workspaceRoot = $workspace
                projectFile   = $project
                gitCommonDir  = ConvertTo-UnrealCanonicalPath -Path $GitCommonDir
                driveLetter   = $drive
                rawTarget     = ConvertTo-UnrealRawDosTarget -WorkspaceRoot $workspace
                ownerRunId    = $ownerRunId
                ownerPid      = $ownerPid
                mappingOwned  = $mappingOwned
                updatedAtUtc  = [DateTimeOffset]::UtcNow.ToString('o')
            })
            $store.assignments = @($records | Sort-Object key)
            Write-UnrealDriveAssignmentStore -Store $store
        }
        $keptExistingAssignment = $existingForKey.Count -eq 1 -and [string] $existingForKey[0].driveLetter -ceq $drive
        $assignmentState = if ($Assign -or $keptExistingAssignment) { 'Assigned' } else { 'Proposed' }
        return New-UnrealExecutionDescription -WorkspaceRoot $workspace -ProjectFile $project -AssignmentKey $key -DriveLetter $drive -AssignmentState $assignmentState -MappingState $mappingState
    }
    finally { Exit-UnrealLease -Lease $lease }
}

function Assert-UnrealSameFileIdentity {
    param(
        [Parameter(Mandatory = $true)][string] $PhysicalPath,
        [Parameter(Mandatory = $true)][string] $ExecutionPath
    )
    Initialize-UnrealDosDeviceInterop
    $physicalIdentity = [Hardness.Unreal.Interop.DosDeviceNative]::FileIdentity($PhysicalPath)
    $executionIdentity = [Hardness.Unreal.Interop.DosDeviceNative]::FileIdentity($ExecutionPath)
    if ($physicalIdentity -cne $executionIdentity) {
        throw "Execution project file does not resolve to the configured project file: $ExecutionPath"
    }
}

function Set-UnrealDriveMappingIntent {
    param(
        [Parameter(Mandatory = $true)] $Execution,
        [Parameter(Mandatory = $true)][string] $RunId
    )
    $lease = Enter-UnrealLease -Scope 'drive-registry' -Key (Get-UnrealDriveAssignmentStorePath) -Policy Wait -TimeoutMs 10000
    if ($null -eq $lease) { throw 'Timed out acquiring the drive-assignment registry lease before mapping.' }
    try {
        $store = Read-UnrealDriveAssignmentStore
        $record = @($store.assignments | Where-Object { [string] $_.key -ceq [string] $Execution.assignmentKey } | Select-Object -First 1)
        if ($record.Count -ne 1 -or [string] $record[0].driveLetter -cne [string] $Execution.driveLetter) {
            throw 'Drive-assignment ownership changed before mapping.'
        }
        $ownerState = Get-UnrealDriveAssignmentOwnerState -Assignment $record[0]
        if ($ownerState -eq 'Live' -and [string] $record[0].ownerRunId -cne $RunId) {
            throw "Execution drive $($Execution.driveLetter) still belongs to another live run."
        }
        $record[0].ownerRunId = $RunId
        $record[0].ownerPid = $PID
        $record[0].mappingOwned = $true
        $record[0].updatedAtUtc = [DateTimeOffset]::UtcNow.ToString('o')
        Write-UnrealDriveAssignmentStore -Store $store
    }
    finally { Exit-UnrealLease -Lease $lease }
}

function Enter-UnrealExecutionDriveMapping {
    param([Parameter(Mandatory = $true)] $Execution, [Parameter(Mandatory = $true)][string] $RunId)
    if ([string] $Execution.strategy -ceq 'Direct') {
        return [pscustomobject]@{ Execution = $Execution; Created = $false }
    }
    $drive = [string] $Execution.driveLetter
    $raw = Get-UnrealDosDeviceTarget -DriveLetter $drive
    $created = $false
    $mappingState = 'Foreign'
    if ([string]::IsNullOrWhiteSpace($raw)) {
        Set-UnrealDriveMappingIntent -Execution $Execution -RunId $RunId
        Initialize-UnrealDosDeviceInterop
        [Hardness.Unreal.Interop.DosDeviceNative]::Create($drive, [string] $Execution.rawTarget)
        $created = $true
        $mappingState = 'Owned'
    }
    elseif (-not (Test-UnrealDosDeviceTargetsWorkspace -RawTarget $raw -WorkspaceRoot ([string] $Execution.physicalWorkspaceRoot))) {
        throw "Execution drive $drive was claimed by another target before launch."
    }
    elseif ([string] $Execution.mappingState -ceq 'StaleOwned') {
        $mappingState = 'StaleOwned'
    }
    try {
        Assert-UnrealSameFileIdentity -PhysicalPath ([string] $Execution.physicalProjectFile) -ExecutionPath ([string] $Execution.projectFile)
        $ready = $Execution | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $ready.mappingState = $mappingState
        $ready.assignmentState = 'Assigned'

        $lease = Enter-UnrealLease -Scope 'drive-registry' -Key (Get-UnrealDriveAssignmentStorePath) -Policy Wait -TimeoutMs 10000
        if ($null -eq $lease) { throw 'Timed out acquiring the drive-assignment registry lease after mapping.' }
        try {
            $store = Read-UnrealDriveAssignmentStore
            $record = @($store.assignments | Where-Object { [string] $_.key -ceq [string] $Execution.assignmentKey } | Select-Object -First 1)
            if ($record.Count -ne 1 -or [string] $record[0].driveLetter -cne $drive) {
                throw 'Drive-assignment ownership changed before launch.'
            }
            $ownerState = Get-UnrealDriveAssignmentOwnerState -Assignment $record[0]
            if ($ownerState -eq 'Live' -and [string] $record[0].ownerRunId -cne $RunId) {
                throw "Execution drive $drive still belongs to another live run."
            }
            $record[0].ownerRunId = $RunId
            $record[0].mappingOwned = [bool]($created -or $mappingState -eq 'StaleOwned')
            $record[0].ownerPid = $PID
            $record[0].updatedAtUtc = [DateTimeOffset]::UtcNow.ToString('o')
            Write-UnrealDriveAssignmentStore -Store $store
        }
        finally { Exit-UnrealLease -Lease $lease }
        return [pscustomobject]@{ Execution = $ready; Created = $created }
    }
    catch {
        if ($created) {
            try {
                $current = Get-UnrealDosDeviceTarget -DriveLetter $drive
                if (Test-UnrealDosDeviceTargetsWorkspace -RawTarget $current -WorkspaceRoot ([string] $Execution.physicalWorkspaceRoot)) {
                    [Hardness.Unreal.Interop.DosDeviceNative]::RemoveExact($drive, [string] $Execution.rawTarget)
                }
            }
            catch { }
        }
        throw
    }
}

function Exit-UnrealExecutionDriveMapping {
    param(
        [AllowNull()] $Mapping,
        [Parameter(Mandatory = $true)][string] $RunId
    )
    if ($null -eq $Mapping -or [string] $Mapping.Execution.strategy -ceq 'Direct') { return }
    $execution = $Mapping.Execution
    $lease = Enter-UnrealLease -Scope 'drive-registry' -Key (Get-UnrealDriveAssignmentStorePath) -Policy Wait -TimeoutMs 10000
    if ($null -eq $lease) { throw 'Timed out acquiring the drive-assignment registry lease during cleanup.' }
    try {
        $store = Read-UnrealDriveAssignmentStore
        $record = @($store.assignments | Where-Object { [string] $_.key -ceq [string] $execution.assignmentKey } | Select-Object -First 1)
        if ($record.Count -ne 1 -or [string] $record[0].ownerRunId -cne $RunId) { return }
        $target = Get-UnrealDosDeviceTarget -DriveLetter ([string] $execution.driveLetter)
        if ([bool] $record[0].mappingOwned -and (Test-UnrealDosDeviceTargetsWorkspace -RawTarget $target -WorkspaceRoot ([string] $execution.physicalWorkspaceRoot))) {
            Initialize-UnrealDosDeviceInterop
            [Hardness.Unreal.Interop.DosDeviceNative]::RemoveExact([string] $execution.driveLetter, [string] $execution.rawTarget)
        }
        $record[0].ownerRunId = ''
        $record[0].ownerPid = $null
        $record[0].mappingOwned = $false
        $record[0].updatedAtUtc = [DateTimeOffset]::UtcNow.ToString('o')
        Write-UnrealDriveAssignmentStore -Store $store
    }
    finally { Exit-UnrealLease -Lease $lease }
}

function Exit-UnrealExecutionDriveMappingAfterWorker {
    param(
        [AllowNull()] $Mapping,
        [Parameter(Mandatory = $true)][string] $RunId,
        [ValidateRange(1, 30000)][int] $TimeoutMs = 10000
    )
    if ($null -eq $Mapping -or [string] $Mapping.Execution.strategy -ceq 'Direct') {
        Exit-UnrealExecutionDriveMapping -Mapping $Mapping -RunId $RunId
        return
    }
    $lease = Enter-UnrealLease -Scope 'drive' -Key ([string] $Mapping.Execution.driveLetter) -Policy Wait -TimeoutMs $TimeoutMs
    if ($null -eq $lease) { throw "Timed out acquiring execution-drive cleanup lease for $($Mapping.Execution.driveLetter)." }
    try { Exit-UnrealExecutionDriveMapping -Mapping $Mapping -RunId $RunId }
    finally { Exit-UnrealLease -Lease $lease }
}

function Resolve-UnrealPhysicalWorkspaceFromExecutionProject {
    param([Parameter(Mandatory = $true)][string] $ProjectFile)
    if ($ProjectFile -notmatch '^(?<drive>[G-Zg-z]:)[\\/](?<relative>.+)$') { return $null }
    try {
        $store = Read-UnrealDriveAssignmentStore
        $drive = $matches.drive.ToUpperInvariant()
        $relative = $matches.relative.Replace('/', '\')
        foreach ($assignment in @($store.assignments | Where-Object { [string] $_.driveLetter -ceq $drive })) {
            $physicalProject = Join-Path ([string] $assignment.workspaceRoot) $relative
            if (Test-UnrealPathEqual -Left $physicalProject -Right ([string] $assignment.projectFile)) {
                $target = Get-UnrealDosDeviceTarget -DriveLetter $drive
                if (-not (Test-UnrealDosDeviceTargetsWorkspace -RawTarget $target -WorkspaceRoot ([string] $assignment.workspaceRoot))) { continue }
                Assert-UnrealSameFileIdentity -PhysicalPath ([string] $assignment.projectFile) -ExecutionPath $ProjectFile
                return [pscustomobject]@{ WorkspaceRoot = [string] $assignment.workspaceRoot; ProjectFile = [string] $assignment.projectFile; DriveLetter = $drive }
            }
        }
    }
    catch { }
    return $null
}
