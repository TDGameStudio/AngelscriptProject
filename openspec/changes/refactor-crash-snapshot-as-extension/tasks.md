# Tasks: Refactor Crash Snapshot as Extension

## 1. 准备和分析

- [ ] 1.1 审查现有崩溃快照实现，确认所有全局状态和依赖项
- [ ] 1.2 审查 `FClassReloadHelper::FClassReloadHelperExtension` 作为参考实现
- [ ] 1.3 确认 `FAngelscriptEngineExtensionRegistry` 的线程安全性和多引擎支持

## 2. 创建扩展类

- [ ] 2.1 在 `AngelscriptCrashSnapshot.h` 中声明 `FAngelscriptCrashSnapshotExtension` 类
- [ ] 2.2 实现 `IAngelscriptExtension` 接口（`OnEngineAttached` / `OnEngineDetached`）
- [ ] 2.3 添加静态引用计数器 `ActiveEngineCount`，使用 `std::atomic<int32>` 确保线程安全
- [ ] 2.4 在 `OnEngineAttached` 中检查引用计数，首次附加时调用 `Startup()`
- [ ] 2.5 在 `OnEngineDetached` 中检查引用计数，最后一次分离时调用 `Shutdown()`

## 3. 重构崩溃快照接口

- [ ] 3.1 保持 `Startup()/Shutdown()` 为公开静态方法（供扩展类调用）
- [ ] 3.2 添加注释说明这些方法现在由扩展系统管理，不应直接调用
- [ ] 3.3 确认 `WriteSnapshotForTesting` 和 `ConfigureForTesting` 接口不受影响

## 4. 修改模块初始化

- [ ] 4.1 在 `FAngelscriptRuntimeModule::StartupModule()` 中注册扩展
- [ ] 4.2 使用 `FAngelscriptEngineExtensionRegistry::Get().RegisterExtension(MakeShared<FAngelscriptCrashSnapshotExtension>())`
- [ ] 4.3 移除 `StartupModule()` 中对 `FAngelscriptCrashSnapshot::Startup()` 的直接调用
- [ ] 4.4 移除 `ShutdownModule()` 中对 `FAngelscriptCrashSnapshot::Shutdown()` 的直接调用
- [ ] 4.5 可选：存储扩展注册句柄，在模块卸载时取消注册

## 5. 构建和基础验证

- [ ] 5.1 运行 `Tools\RunBuild.ps1` 确保编译通过
- [ ] 5.2 验证编辑器启动无错误日志
- [ ] 5.3 验证崩溃快照相关日志正确输出（引擎附加/分离时的日志）

## 6. 测试现有功能 <!-- Non-TDD -->

- [ ] 6.1 运行崩溃快照相关的自动化测试（如果存在）
- [ ] 6.2 使用 `as.Test.ConfigureCrashSnapshot` 命令验证测试接口
- [ ] 6.3 使用 `WriteSnapshotForTesting` 验证快照生成功能
- [ ] 6.4 验证崩溃快照 JSON 格式未改变

## 7. 多引擎实例测试 <!-- TDD -->

- [ ] 7.1 创建测试：验证多次创建/销毁引擎实例时引用计数正确
- [ ] 7.2 创建测试：验证第一个引擎附加时崩溃处理器注册
- [ ] 7.3 创建测试：验证最后一个引擎分离时崩溃处理器取消注册
- [ ] 7.4 创建测试：验证中间引擎销毁不影响崩溃处理器状态
- [ ] 7.5 运行 `Tools\RunTests.ps1 -Filter "CrashSnapshot"` 验证所有测试通过

## 8. 集成测试 <!-- Non-TDD -->

- [ ] 8.1 在编辑器中启动 PIE，验证崩溃快照系统正常工作
- [ ] 8.2 测试编辑器内多次进入/退出 PIE，验证无内存泄漏
- [ ] 8.3 验证独立游戏构建（如果支持崩溃快照）

## 9. 文档更新

- [ ] 9.1 更新 `AngelscriptCrashSnapshot.h` 中的注释，说明新的生命周期管理方式
- [ ] 9.2 在设计文档中记录最终实现细节（如有偏差）
- [ ] 9.3 更新 `AGENTS.md` 或相关文档，记录崩溃快照系统作为扩展的事实

## 10. 清理和验证

- [ ] 10.1 检查是否有遗留的直接 `Startup()/Shutdown()` 调用
- [ ] 10.2 运行完整测试套件 `Tools\RunTestSuite.ps1` 确保无回归
- [ ] 10.3 验证崩溃快照系统在所有支持的平台上工作（Windows/Mac/Linux）
- [ ] 10.4 检视代码，确保线程安全（`std::atomic` 用于引用计数）
- [ ] 10.5 最终构建验证 `Tools\RunBuild.ps1`
