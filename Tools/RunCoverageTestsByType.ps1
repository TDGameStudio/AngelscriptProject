# AngelScript Coverage 分类测试运行脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AngelScript Coverage Tests (By Type)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"
$TimeoutMs = 1200000  # 20 minutes per type

$TestTypes = @(
    @{Name="int"; Prefix="Angelscript.TestModule.Coverage.Int"; Methods=28; Assertions=363}
    @{Name="float"; Prefix="Angelscript.TestModule.Coverage.Float"; Methods=20; Assertions=150}
    @{Name="bool"; Prefix="Angelscript.TestModule.Coverage.Bool"; Methods=18; Assertions=90}
    @{Name="FString"; Prefix="Angelscript.TestModule.Coverage.FString"; Methods=28; Assertions=190}
)

$TotalMethods = 0
$TotalAssertions = 0
$PassedTypes = 0
$FailedTypes = @()

foreach ($TestType in $TestTypes) {
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host "运行 $($TestType.Name) Coverage 测试..." -ForegroundColor Yellow
    Write-Host "预期方法数: $($TestType.Methods)" -ForegroundColor Gray
    Write-Host "预期断言数: $($TestType.Assertions)" -ForegroundColor Gray
    Write-Host "----------------------------------------" -ForegroundColor Yellow
    Write-Host ""

    try {
        & Tools\RunTests.ps1 -TestPrefix $TestType.Prefix -Label "coverage-$($TestType.Name.ToLower())" -TimeoutMs $TimeoutMs

        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ $($TestType.Name) 测试通过" -ForegroundColor Green
            $PassedTypes++
            $TotalMethods += $TestType.Methods
            $TotalAssertions += $TestType.Assertions
        } else {
            Write-Host "❌ $($TestType.Name) 测试失败 (退出码: $LASTEXITCODE)" -ForegroundColor Red
            $FailedTypes += $TestType.Name
        }
    } catch {
        Write-Host "❌ $($TestType.Name) 测试执行出错: $_" -ForegroundColor Red
        $FailedTypes += $TestType.Name
    }

    Write-Host ""
}

# 总结
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "测试总结" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "通过类型: $PassedTypes / $($TestTypes.Count)" -ForegroundColor $(if ($PassedTypes -eq $TestTypes.Count) { "Green" } else { "Yellow" })
Write-Host "测试方法: $TotalMethods" -ForegroundColor Gray
Write-Host "断言数量: $TotalAssertions" -ForegroundColor Gray

if ($FailedTypes.Count -gt 0) {
    Write-Host ""
    Write-Host "失败类型:" -ForegroundColor Red
    foreach ($FailedType in $FailedTypes) {
        Write-Host "  - $FailedType" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host ""
    Write-Host "🎉 所有类型测试通过！" -ForegroundColor Green
    exit 0
}
