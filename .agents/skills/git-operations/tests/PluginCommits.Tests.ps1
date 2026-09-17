param()
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../scripts/GitOperations.psd1') -Force
$fixture = Join-Path ([IO.Path]::GetTempPath()) ('plugin-commits-' + [guid]::NewGuid().ToString('N'))
function G([string]$Root, [string[]]$ArgsList) {
    $text = @(& git -C $Root @ArgsList 2>&1)
    if ($LASTEXITCODE) { throw ($text -join "`n") }
    return ($text -join "`n")
}
try {
    foreach ($name in @('source','parent')) {
        $repo = Join-Path $fixture $name
        [void][IO.Directory]::CreateDirectory($repo)
        G $repo @('init','-b','main') | Out-Null
        G $repo @('config','user.name','Fixture') | Out-Null
        G $repo @('config','user.email','fixture@example.invalid') | Out-Null
        [IO.File]::WriteAllText((Join-Path $repo 'owned.txt'), 'base')
        G $repo @('add','.') | Out-Null
        G $repo @('commit','-m','base') | Out-Null
    }
    $parent = Join-Path $fixture 'parent'
    G $parent @('-c','protocol.file.allow=always','submodule','add',(Join-Path $fixture 'source'),'Plugins/Foo') | Out-Null
    G $parent @('commit','-am','plugin') | Out-Null
    $plugin = Join-Path $parent 'Plugins/Foo'
    G $plugin @('config','user.name','Fixture') | Out-Null
    G $plugin @('config','user.email','fixture@example.invalid') | Out-Null
    $before = G $parent @('rev-parse','HEAD')
    [IO.File]::WriteAllText((Join-Path $plugin 'owned.txt'), 'requested')
    [IO.File]::WriteAllText((Join-Path $plugin 'unrelated.txt'), 'preserve staged')
    G $plugin @('add','unrelated.txt') | Out-Null
    $result = Complete-HarnessGitCommit -WorkspaceRoot $parent -PluginsOnly -PreserveOutsideStaged -RepositoryScopes @{'Plugins/Foo'=@('owned.txt')} -CommitMessage 'plugin result'
    if ($before -ne (G $parent @('rev-parse','HEAD'))) { throw 'PluginsOnly unexpectedly committed parent gitlinks.' }
    if (@($result.Commits).Count -ne 1 -or $result.Commits[0].Repository -ne 'Plugins/Foo') { throw 'Expected one exact plugin commit.' }
    if ((G $plugin @('diff','--cached','--name-only')) -ne 'unrelated.txt') { throw 'Unrelated staging was changed.' }
    Write-Output 'PluginCommits.Tests.ps1: PASS'
} finally {
    $target = [IO.Path]::GetFullPath($fixture)
    if ($target.StartsWith([IO.Path]::GetFullPath([IO.Path]::GetTempPath())) -and [IO.Path]::GetFileName($target).StartsWith('plugin-commits-')) { Remove-Item -LiteralPath $target -Recurse -Force }
}
