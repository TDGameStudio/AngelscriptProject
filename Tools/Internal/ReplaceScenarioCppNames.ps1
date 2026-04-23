$root = "D:\Workspace\AngelscriptProject\Plugins\Angelscript\Source\AngelscriptTest"
$files = Get-ChildItem -Path $root -Recurse -Include "*.cpp","*.h"
$count = 0
foreach ($file in $files) {
    $content = [System.IO.File]::ReadAllText($file.FullName, [System.Text.Encoding]::UTF8)

    $newContent = $content `
        -replace 'FAngelscriptScenario([A-Za-z])', 'FAngelscriptTest$1' `
        -replace 'class AScenario([A-Za-z])', 'class ATest$1' `
        -replace 'class UScenario([A-Za-z])', 'class UTest$1' `
        -replace '"AScenario([A-Za-z])', '"ATest$1' `
        -replace '"UScenario([A-Za-z])', '"UTest$1' `
        -replace 'TEXT\("AScenario([A-Za-z])', 'TEXT("ATest$1' `
        -replace 'TEXT\("UScenario([A-Za-z])', 'TEXT("UTest$1'

    if ($newContent -ne $content) {
        [System.IO.File]::WriteAllText($file.FullName, $newContent, [System.Text.Encoding]::UTF8)
        Write-Output "Updated: $($file.Name)"
        $count++
    }
}
Write-Output "Total files updated: $count"
