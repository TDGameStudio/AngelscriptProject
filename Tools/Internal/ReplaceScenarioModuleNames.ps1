$root = "D:\Workspace\AngelscriptProject\Plugins\Angelscript\Source\AngelscriptTest"
$files = Get-ChildItem -Path $root -Recurse -Include "*.cpp","*.h"
$count = 0
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)

    # Replace ModuleName strings: TEXT("ScenarioXxx") -> TEXT("TestXxx")
    # Also FName(TEXT("ScenarioXxx")) and ScenarioXxx.as filenames
    $newContent = $content `
        -replace '(TEXT\(")Scenario([A-Za-z])', '$1Test$2' `
        -replace '"Scenario([A-Za-z])', '"Test$1'

    if ($newContent -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.Encoding]::UTF8)
        Write-Output "Updated: $($file.Name)"
        $count++
    }
}
Write-Output "Total files updated: $count"
