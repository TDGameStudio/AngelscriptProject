# Tasks: Refactor Code Coverage as Extension

## 1. 准备和分析

- [ ] 1.1 审查现有代码覆盖率实现，确认所有调用点和依赖项
- [ ] 1.2 搜索所有访问 `Engine.CodeCoverage` 的代码位置
- [ ] 1.3 确认 `FAngelscriptCodeCoverage` 当前的析构逻辑（是否存在内存泄漏）
- [ ] 1.4 审查 `AddTestFrameworkHooks()` 的实现，确认对模块加载的依赖

## 2. 创建扩展类

- [ ] 2.1 在 `AngelscriptCodeCoverage.h` 中声明 `FAngelscriptCodeCoverageExtension` 类
- [ ] 2.2 实现 `IAngelscriptExtension` 接口（`OnEngineAttached` / `OnEngineDetached`）
- [ ] 2.3 添加 `TUniquePtr<FAngelscriptCodeCoverage> Coverage` 成员持有覆盖率对象
- [ ] 2.4 添加 `FAngelscriptEngine* AttachedEngine` 成员记录关联引擎
- [ ] 2.5 在 `OnEngineAttached` 中检查 `CoverageEnabled()`，创建覆盖率对象
- [ ] 2.6 在 `OnEngineAttached` 中调用 `Coverage->AddTestFrameworkHooks()`（WITH_EDITOR）
- [ ] 2.7 在 `OnEngineDetached` 中通过 `Coverage.Reset()` 清理覆盖率对象

## 3. 添加访问辅助函数

- [ ] 3.1 实现 `FAngelscriptCodeCoverageExtension::GetForEngine(FAngelscriptEngine&)` 静态函数
- [ ] 3.2 在 `GetForEngine` 中通过 `FAngelscriptEngineExtensionRegistry` 查找扩展实例
- [ ] 3.3 返回扩展实例中的 `Coverage.Get()` 指针（可能为 nullptr）
- [ ] 3.4 添加 `GetCoverage()` 公共访问器用于扩展实例内部访问

## 4. 移除引擎成员指针

- [ ] 4.1 从 `FAngelscriptEngine` 中删除 `FAngelscriptCodeCoverage* CodeCoverage = nullptr;` 成员声明
- [ ] 4.2 移除 `Initialize_AnyThread()` 中的覆盖率对象创建代码（1817-1821 行）
- [ ] 4.3 移除 `PostInitialize_GameThread()` 中的 `OnPostEngineInit` Lambda（2007-2015 行）
- [ ] 4.4 确认移除后没有遗留的 `CodeCoverage` 成员访问

## 5. 更新引擎内部调用点

- [ ] 5.1 查找 `AngelscriptEngine.cpp` 中所有 `CodeCoverage != nullptr` 检查
- [ ] 5.2 更新 `CompileModules` 中的 `MapExecutableLines` 调用（约 5081 行）
- [ ] 5.3 更新行回调中的 `HitLine` 调用（约 6117 行）
- [ ] 5.4 更新 `GetOnScreenMessages` 中的覆盖率状态显示（约 6210 行）
- [ ] 5.5 将所有调用改为 `FAngelscriptCodeCoverageExtension::GetForEngine(*this)`

## 6. 更新状态导出调用点

- [ ] 6.1 查找 `AngelscriptStateDump.cpp` 中对 `Engine.CodeCoverage` 的访问（约 1157 行）
- [ ] 6.2 改为通过 `FAngelscriptCodeCoverageExtension::GetForEngine(Engine)` 访问
- [ ] 6.3 确认状态导出逻辑正常工作

## 7. 注册扩展

- [ ] 7.1 在 `FAngelscriptRuntimeModule::StartupModule()` 中添加扩展注册代码
- [ ] 7.2 使用 `#if WITH_AS_COVERAGE` 条件编译包裹注册代码
- [ ] 7.3 使用 `FAngelscriptEngineExtensionRegistry::Get().RegisterExtension(MakeShared<FAngelscriptCodeCoverageExtension>())`
- [ ] 7.4 确认注册顺序（与崩溃快照扩展一致）

## 8. 构建和基础验证

- [ ] 8.1 运行 `Tools\RunBuild.ps1` 确保编译通过
- [ ] 8.2 验证编辑器启动无错误日志
- [ ] 8.3 验证代码覆盖率相关日志正确输出（如果启用）
- [ ] 8.4 确认 `CoverageEnabled()` 逻辑仍然有效

## 9. 测试覆盖率功能 <!-- Non-TDD -->

- [ ] 9.1 启用代码覆盖率功能（设置相关环境变量或配置）
- [ ] 9.2 运行自动化测试套件
- [ ] 9.3 验证测试框架钩子正确触发（StartRecording / StopRecordingAndWriteReport）
- [ ] 9.4 检查生成的覆盖率报告 HTML 文件
- [ ] 9.5 验证覆盖率报告内容格式未改变
- [ ] 9.6 验证 `MapExecutableLines` 正确收集可执行行
- [ ] 9.7 验证 `HitLine` 正确记录行执行

## 10. 多引擎实例测试 <!-- TDD -->

- [ ] 10.1 创建测试：验证多个引擎实例可以独立追踪覆盖率
- [ ] 10.2 创建测试：验证引擎实例销毁时覆盖率对象正确析构
- [ ] 10.3 创建测试：验证 `GetForEngine` 返回正确的覆盖率对象
- [ ] 10.4 创建测试：验证未启用覆盖率时 `GetForEngine` 返回 nullptr
- [ ] 10.5 运行 `Tools\RunTests.ps1 -Filter "CodeCoverage"` 验证所有测试通过

## 11. 内存泄漏检查 <!-- Non-TDD -->

- [ ] 11.1 使用内存分析工具检查引擎创建/销毁循环
- [ ] 11.2 验证 `TUniquePtr` 正确析构 `FAngelscriptCodeCoverage` 对象
- [ ] 11.3 验证测试框架钩子的委托句柄正确移除
- [ ] 11.4 在编辑器中多次进入/退出 PIE，检查内存增长

## 12. 集成测试 <!-- Non-TDD -->

- [ ] 12.1 在编辑器中运行完整的自动化测试套件
- [ ] 12.2 验证覆盖率报告在测试结束后正确生成
- [ ] 12.3 测试覆盖率数据在多次测试运行之间正确重置
- [ ] 12.4 验证 `ResetHits()` 功能正常工作

## 13. AddTestFrameworkHooks 鲁棒性 <!-- Non-TDD -->

- [ ] 13.1 检查 `AddTestFrameworkHooks()` 中对 `IAutomationControllerModule` 的加载检查
- [ ] 13.2 如果模块未加载，添加日志记录而非崩溃
- [ ] 13.3 验证在非编辑器环境下扩展正常工作（不调用 `AddTestFrameworkHooks`）

## 14. 文档更新

- [ ] 14.1 更新 `AngelscriptCodeCoverage.h` 中的注释，说明新的生命周期管理方式
- [ ] 14.2 在设计文档中记录最终实现细节（如有偏差）
- [ ] 14.3 更新 `AGENTS.md` 或相关文档，记录代码覆盖率系统作为扩展的事实
- [ ] 14.4 记录 `GetForEngine()` 的使用方式和最佳实践

## 15. 清理和验证

- [ ] 15.1 搜索并确认所有 `Engine.CodeCoverage` 引用已更新
- [ ] 15.2 检查是否有遗留的 `OnPostEngineInit` Lambda 闭包
- [ ] 15.3 运行完整测试套件 `Tools\RunTestSuite.ps1` 确保无回归
- [ ] 15.4 验证代码覆盖率系统在所有支持的平台上工作（Windows/Mac/Linux）
- [ ] 15.5 最终构建验证 `Tools\RunBuild.ps1`
- [ ] 15.6 验证 `WITH_AS_COVERAGE` 编译条件正确应用
