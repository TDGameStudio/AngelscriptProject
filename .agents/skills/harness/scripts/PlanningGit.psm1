#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'

function Complete-HarnessReplanGit {
    param($Context,$Applied)
    Import-Module (Join-Path $Context.HarnessRoot '.agents/skills/git-operations/scripts/GitOperations.psd1')
    $root=if ($Context.PSObject.Properties['OpenSpecRoot']) { $Context.OpenSpecRoot } else { $Context.WorkspaceRoot }
    $uid=$Applied.git_plan.ChangeUid
    $key=[Convert]::ToHexString([Security.Cryptography.SHA256]::HashData([Text.Encoding]::UTF8.GetBytes($uid))).ToLowerInvariant()
    $path=Join-Path $root ('Saved/Harness/PlanningCommits/'+$key+'-'+$Applied.replan_id+'.json')
    $mutex=[Threading.Mutex]::new($false,('HarnessPlanningGit-'+$key))
    $held=$false
    try {
        try { $held=$mutex.WaitOne(0) } catch [Threading.AbandonedMutexException] { $held=$true }
        if (-not $held) { throw 'Planning Git operation is busy.' }
        if (-not (Test-Path -LiteralPath $path)) { throw 'Planning Git recovery record is missing; inspect committed provenance before recovery.' }
        $state=Get-Content -LiteralPath $path -Raw | ConvertFrom-Json -AsHashtable
        if ($state.schema -ne 1 -or $state.uid -cne $uid -or $state.requestHash -cne $Applied.request_sha256 -or
            [IO.Path]::GetFullPath($state.recordRoot) -ne [IO.Path]::GetFullPath($root) -or
            [IO.Path]::GetFullPath($state.workspaceRoot) -ne [IO.Path]::GetFullPath($Context.WorkspaceRoot)) { throw 'Planning Git operation identity differs.' }
        function Save-PlanningState {
            $temp=$path+'.'+[guid]::NewGuid().ToString('N')+'.tmp'
            try { [IO.File]::WriteAllText($temp,($state | ConvertTo-Json -Depth 30),[Text.UTF8Encoding]::new($false)); [IO.File]::Move($temp,$path,$true) }
            finally { if ([IO.File]::Exists($temp)) { [IO.File]::Delete($temp) } }
        }
        function Read-PlanningGit([string[]]$Arguments) {
            $result=@(& git -C $root @Arguments 2>&1)
            if ($LASTEXITCODE) { throw ($result -join "`n") }
            return ($result -join "`n").Trim()
        }
        if ($state.stage -eq 'complete') { return $state.commit }
        if ((Read-PlanningGit @('symbolic-ref','--short','HEAD')) -cne $state.branch) { throw 'Planning Git branch changed.' }
        $head=Read-PlanningGit @('rev-parse','HEAD')
        if ($head -cne $state.baseline) {
            if ($state.ContainsKey('attempt') -and (Read-PlanningGit @('rev-parse','HEAD^')) -ceq $state.attempt.Head -and
                (Read-PlanningGit @('rev-parse','HEAD^{tree}')) -ceq $state.attempt.Tree) {
                $state.stage='complete'; $state.commit=$head; Save-PlanningState; return $head
            }
            throw 'Planning Git baseline changed outside the recorded attempt.'
        }
        $prefix='openspec/changes/'+$state.change+'/'
        $selected=@(foreach ($name in $state.outputs.Keys) {
            $file=[IO.Path]::GetFullPath((Join-Path $root ($prefix+$name)))
            $changeRoot=[IO.Path]::GetFullPath((Join-Path $root $prefix)).TrimEnd('\','/')+[IO.Path]::DirectorySeparatorChar
            if (-not $file.StartsWith($changeRoot,[StringComparison]::OrdinalIgnoreCase)) { throw 'Planning path escaped its Change.' }
            $cursor=$file
            while ($cursor -and $cursor.Length -ge $changeRoot.TrimEnd('\','/').Length) {
                $item=Get-Item -LiteralPath $cursor -Force -ErrorAction SilentlyContinue
                if ($item -and ($item.Attributes -band [IO.FileAttributes]::ReparsePoint)) { throw 'Planning path contains a reparse point.' }
                $cursor=Split-Path $cursor
            }
            if (-not (Test-Path -LiteralPath $file -PathType Leaf) -or (Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash -ine $state.outputs[$name]) { throw "Planning Git conflicts with an external edit: $name" }
            $prefix+$name
        })
        $args=@{WorkspaceRoot=$root;RepositoryScopes=@{'.'=$selected};CommitMessage=$state.message;PreserveOutsideStaged=$true}
        $shown=Complete-HarnessGitCommit @args -WhatIf
        if (@($shown.IncludedChanges).Count -ne 1) { throw 'Planning Git candidate disappeared.' }
        $state.stage='commit-pending'; $state.attempt=@{Head=$head;Tree=$shown.IncludedChanges[0].CandidateTree;Revision=$shown.PlanRevision}; Save-PlanningState
        $result=Complete-HarnessGitCommit @args -ExpectedPlanRevision $shown.PlanRevision
        if (@($result.Commits).Count -ne 1 -or -not $result.ScopedGitStateComplete) { throw 'Planning Git did not finish its accepted scope.' }
        $state.stage='complete'; $state.commit=$result.Commits[0].Commit; Save-PlanningState
        return $state.commit
    } finally { if ($held) { $mutex.ReleaseMutex() }; $mutex.Dispose() }
}
Export-ModuleMember -Function Complete-HarnessReplanGit
