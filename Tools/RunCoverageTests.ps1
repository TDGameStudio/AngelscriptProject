# AngelScript Coverage 测试运行脚本

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AngelScript Coverage Tests Runner" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorActionPreference = "Continue"

# 测试配置
$TestPrefix = "Angelscript.TestModule.Coverage"
$TimeoutMs = 1800000  # 30 minutes

Write-Host "运行所有 Coverage 测试..." -ForegroundColor Yellow
Write-Host "测试前缀: $TestPrefix" -ForegroundColor Gray
Write-Host "超时时间: $($TimeoutMs/1000) 秒" -ForegroundColor Gray
Write-Host ""

# 运行测试
Write-Host "执行命令: Tools\RunTests.ps1 -TestPrefix `"$TestPrefix`" -Label coverage-all -TimeoutMs $TimeoutMs" -ForegroundColor Gray
Write-Host ""

try {
    & Tools\RunTests.ps1 -TestPrefix $TestPrefix -Label coverage-all -TimeoutMs $TimeoutMs

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "✅ 所有测试通过！" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "❌ 测试失败 (退出码: $LASTEXITCODE)" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
    }
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "❌ 测试执行出错: $_" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "预期结果:" -ForegroundColor Cyan
Write-Host "- 测试方法: 94 个" -ForegroundColor Gray
Write-Host "- 断言数量: ~793 个" -ForegroundColor Gray
Write-Host "- 覆盖类型: int, float, bool, FString" -ForegroundColor Gray
Write-Host ""
