# AngelScript 调试和日志全覆盖矩阵

> 本文覆盖 AngelScript 中 **调试、日志和断言**的所有用法。
> 包括 Print、Log、Ensure、Check、断点等开发辅助工具。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| 日志系统 | `AngelscriptTest/Coverage/AngelscriptCoverageLoggingTests.cpp` | ✅ 完成 |
| 断言系统 | `AngelscriptTest/Coverage/AngelscriptCoverageAssertTests.cpp` | ⬜ 计划 |
| 调试工具 | `AngelscriptTest/Coverage/AngelscriptCoverageDebugTests.cpp` | ⬜ 计划 |

---

## 子矩阵 1：日志输出

### 1.1 Print 系列

| 函数 | 写法 | 状态 | 输出位置 |
|------|------|------|---------|
| Print | `Print("Message")` | ✅ | 屏幕 + 日志 |
| PrintString | `PrintString("Message", Duration, Color)` | ✅ | 屏幕（带颜色） |
| PrintWarning | `PrintWarning("Warning")` | ✅ | 屏幕（黄色） |
| PrintError | `PrintError("Error")` | ✅ | 屏幕（红色） |

### 1.2 UE_LOG 宏

| 写法 | 状态 | 说明 |
|------|------|------|
| `UE_LOG(LogTemp, Log, TEXT("..."))` | ✅ | 普通日志 |
| `UE_LOG(LogTemp, Warning, TEXT("..."))` | ✅ | 警告 |
| `UE_LOG(LogTemp, Error, TEXT("..."))` | ✅ | 错误 |
| `UE_LOG(LogTemp, Display, TEXT("..."))` | ✅ | 显示 |
| `UE_LOG(LogTemp, Verbose, TEXT("..."))` | ✅ | 详细 |

### 1.3 日志分类

| 日志类别 | 状态 | 用途 |
|---------|------|------|
| LogTemp | ✅ | 临时日志 |
| LogScript | ✅ | 脚本日志 |
| LogNet | ✅ | 网络日志 |
| LogActor | ✅ | Actor 日志 |
| 自定义分类 | ✅ | DEFINE_LOG_CATEGORY |

### 1.4 日志级别

| 级别 | 枚举值 | 状态 | 说明 |
|------|-------|------|------|
| Fatal | `ELogVerbosity::Fatal` | ⬜ | 致命错误（崩溃） |
| Error | `ELogVerbosity::Error` | ⬜ | 错误 |
| Warning | `ELogVerbosity::Warning` | ⬜ | 警告 |
| Display | `ELogVerbosity::Display` | ⬜ | 显示 |
| Log | `ELogVerbosity::Log` | ⬜ | 普通日志 |
| Verbose | `ELogVerbosity::Verbose` | ⬜ | 详细日志 |
| VeryVerbose | `ELogVerbosity::VeryVerbose` | ⬜ | 非常详细 |

---

## 子矩阵 2：断言系统

### 2.1 check 系列（开发版崩溃）

| 宏 | 写法 | 状态 | 说明 |
|------|------|------|------|
| check | `check(Condition)` | ⬜ | 不满足则崩溃 |
| checkf | `checkf(Condition, TEXT("Message"))` | ⬜ | 带格式化消息 |
| checkSlow | `checkSlow(Condition)` | ⬜ | Debug 版本检查 |
| checkCode | `checkCode(Code)` | ⬜ | 执行代码 |
| checkNoEntry | `checkNoEntry()` | ⬜ | 不应到达 |
| checkNoReentry | `checkNoReentry()` | ⬜ | 不应重入 |

### 2.2 verify 系列（总是执行）

| 宏 | 写法 | 状态 | 说明 |
|------|------|------|------|
| verify | `verify(Condition)` | ⬜ | Release 也执行 |
| verifyf | `verifyf(Condition, TEXT("Message"))` | ⬜ | 带消息 |

### 2.3 ensure 系列（非致命断言）

| 宏 | 写法 | 状态 | 说明 |
|------|------|------|------|
| ensure | `ensure(Condition)` | ⬜ | 失败时报告但继续 |
| ensureAlways | `ensureAlways(Condition)` | ⬜ | 每次都报告 |
| ensureMsgf | `ensureMsgf(Condition, TEXT("..."))` | ⬜ | 带格式化消息 |
| ensureAlwaysMsgf | `ensureAlwaysMsgf(Condition, TEXT("..."))` | ⬜ | 总是报告+消息 |

### 2.4 断言对比

| 特性 | check | verify | ensure |
|------|-------|--------|--------|
| Release 执行 | ❌ | ✅ | ✅ |
| 失败后崩溃 | ✅ | ✅ | ❌ |
| 性能开销 | 无（Release） | 有 | 有 |
| 推荐场景 | 开发验证 | 关键检查 | 非致命错误 |

---

## 子矩阵 3：调试绘制

### 3.1 DrawDebug 系列

| 函数 | 状态 | 说明 |
|------|------|------|
| DrawDebugLine | ⬜ | 绘制线段 |
| DrawDebugSphere | ⬜ | 绘制球体 |
| DrawDebugBox | ⬜ | 绘制盒体 |
| DrawDebugCapsule | ⬜ | 绘制胶囊 |
| DrawDebugArrow | ⬜ | 绘制箭头 |
| DrawDebugCoordinateSystem | ⬜ | 绘制坐标系 |
| DrawDebugString | ⬜ | 绘制 3D 文本 |
| DrawDebugPoint | ⬜ | 绘制点 |

### 3.2 DrawDebug 参数

| 参数 | 类型 | 状态 | 说明 |
|------|------|------|------|
| World | UWorld | ⬜ | 世界上下文 |
| Location / Start / End | FVector | ⬜ | 位置 |
| Radius / Size | float / FVector | ⬜ | 大小 |
| Color | FColor | ⬜ | 颜色 |
| bPersistentLines | bool | ⬜ | 是否持久 |
| LifeTime | float | ⬜ | 持续时间（秒） |
| DepthPriority | uint8 | ⬜ | 深度优先级 |
| Thickness | float | ⬜ | 线条粗细 |

---

## 子矩阵 4：性能分析

### 4.1 Stat 命令

| 命令 | 状态 | 说明 |
|------|------|------|
| `stat fps` | ⬜ | 显示 FPS |
| `stat unit` | ⬜ | 显示帧时间 |
| `stat game` | ⬜ | 游戏线程统计 |
| `stat gpu` | ⬜ | GPU 统计 |
| `stat memory` | ⬜ | 内存统计 |
| `stat slow` | ⬜ | 慢速统计 |

### 4.2 Profiling

| 工具 | 状态 | 说明 |
|------|------|------|
| SCOPE_CYCLE_COUNTER | ⬜ | 性能计数器 |
| Unreal Insights | ⬜ | 外部分析工具 |

---

## 子矩阵 5：调试可视化

### 5.1 显示调试信息

| 命令/标志 | 状态 | 说明 |
|----------|------|------|
| `show Collision` | ⬜ | 显示碰撞 |
| `show Bones` | ⬜ | 显示骨骼 |
| `show Navmesh` | ⬜ | 显示导航网格 |
| `show Paths` | ⬜ | 显示路径 |

### 5.2 控制台变量（CVar）

| 操作 | 写法 | 状态 |
|------|------|------|
| 获取 CVar | `IConsoleManager::Get().FindConsoleVariable(...)` | ⬜ |
| 设置 CVar | `CVar->Set(Value)` | ⬜ |
| 注册 CVar | `RegisterConsoleVariable(...)` | ⬜ |

---

## 子矩阵 6：错误处理

### 6.1 异常处理替代

| 方法 | 状态 | 说明 |
|------|------|------|
| 返回 bool | ⬜ | 成功/失败 |
| 输出参数 | ⬜ | ErrorCode |
| ensure + 早返回 | ⬜ | 推荐模式 |

### 6.2 错误恢复

| 场景 | 状态 | 方法 |
|------|------|------|
| null 检查 | ⬜ | `if (!ensure(Obj)) return;` |
| 索引检查 | ⬜ | `if (!ensure(Index < Num())) return;` |
| 状态 ✅ | `if (!ensure(IsValid())) return;` |

---

## 子矩阵 7：断点和调试器

### 7.1 断点

| 操作 | 状态 | 说明 |
|------|------|------|
| 设置断点 | ⬜ | IDE 断点 |
| 条件断点 | ⬜ | 满足条件时中断 |
| 日志断点 | ⬜ | 不中断，仅输出 |

### 7.2 调试器功能

| 功能 | 状态 | 说明 |
|------|------|------|
| 单步执行 | ⬜ | Step Over/Into/Out |
| 查看变量 | ⬜ | Watch 窗口 |
| 调用堆栈 | ⬜ | Call Stack |
| 即时窗口 | ⬜ | 执行表达式 |

---

## 子矩阵 8：调试辅助工具

### 8.1 对象查看

| 工具 | 状态 | 说明 |
|------|------|------|
| GetName() | ⬜ | 对象名称 |
| GetClass()->GetName() | ⬜ | 类名 |
| GetFullName() | ⬜ | 完整路径 |
| GetOuter() | ⬜ | 外部对象 |

### 8.2 引用查看

| 工具 | 命令 | 状态 |
|------|------|------|
| 引用查看器 | 编辑器工具 | ⬜ |
| 查找引用 | `obj refs` | ⬜ |

---

## 子矩阵 9：日志使用场景

### 9.1 开发调试

| 场景 | 状态 | 方法 |
|------|------|------|
| 函数进入/退出 | ⬜ | `UE_LOG(LogTemp, Log, TEXT("Enter %s"), *FString(__FUNCTION__))` |
| 变量值 | ⬜ | `Print(f"Value: {X}")` |
| 条件分支 | ⬜ | 关键 if 分支打印 |

### 9.2 性能调试

| 场景 | 状态 | 方法 |
|------|------|------|
| 函数耗时 | ⬜ | SCOPE_CYCLE_COUNTER |
| 调用频率 | ⬜ | 计数器 |
| 内存分配 | ⬜ | stat memory |

### 9.3 网络调试

| 场景 | 状态 | 方法 |
|------|------|------|
| RPC 调用 | ⬜ | 打印 RPC 参数 |
| 复制事件 | ⬜ | OnRep 日志 |
| 角色检查 | ⬜ | 打印 HasAuthority() |

---

## 子矩阵 10：调试最佳实践

### 10.1 日志规范

| 规范 | 状态 | 说明 |
|------|------|------|
| 使用合适的级别 | ⬜ | Error/Warning/Log |
| 包含上下文 | ⬜ | 对象名、函数名 |
| 格式化输出 | ⬜ | 清晰的消息 |
| 避免垃圾日志 | ⬜ | 不在 Tick 打印 |

### 10.2 断言规范

| 规范 | 状态 | 说明 |
|------|------|------|
| check 用于不可能 | ⬜ | 逻辑错误 |
| ensure 用于应避免 | ⬜ | 异常情况 |
| 带有清晰消息 | ⬜ | 便于定位 |
| 不在热路径 | ⬜ | 性能考虑 |

### 10.3 调试效率

| 技巧 | 状态 | 说明 |
|------|------|------|
| 二分查找问题 | ⬜ | 快速定位 |
| 使用条件断点 | ⬜ | 减少中断次数 |
| 重现步骤记录 | ⬜ | 便于修复 |
| Git bisect | ⬜ | 定位引入问题的提交 |

---

## 计划测试方法清单

### AngelscriptCoverageLoggingTests.cpp

| 方法 | 覆盖内容 | 状态 |
|------|---------|------|
| `PrintFunctions` | Print/PrintString/PrintWarning/PrintError | ✅ |
| `UELogMacros` | UE_LOG 各种级别 | ✅ |
| `LogCategories` | 不同日志分类 | ✅ |
| `LogFormatting` | 格式化输出 | ✅ |
| `ConditionalLogging` | 条件日志输出 | ✅ |
| `FunctionEntryExitLogging` | 函数进入/退出日志 | ✅ |
| `PerformanceConsciousLogging` | 性能友好的日志模式 | ✅ |
| `ContextRichLogging` | 上下文丰富的日志 | ✅ |

### AngelscriptCoverageAssertTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `CheckMacros` | check/checkf（需验证编译） |
| `VerifyMacros` | verify（总是执行） |
| `EnsureMacros` | ensure/ensureAlways |
| `AssertComparison` | check vs verify vs ensure |

### AngelscriptCoverageDebugTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `DrawDebugShapes` | DrawDebugLine/Sphere/Box |
| `DrawDebugParams` | 颜色/持续时间/粗细 |
| `DebugVisualization` | show 命令 |
| `ObjectInspection` | GetName/GetClass |

---

## 待补充清单

### 🔴 高优先级

1. **日志输出**（Print / UE_LOG）
2. **断言基础**（check / ensure）
3. **调试绘制**（DrawDebug*）

### 🟡 中优先级

4. **日志级别和分类**
5. **断言对比**（check vs ensure）
6. **对象查看工具**

### 🟢 低优先级

7. **性能分析**（stat 命令）
8. **控制台变量**
9. **调试最佳实践**

---

## 测试注意事项

### 断言测试的特殊性

1. **check 测试**
   - check 失败会崩溃
   - 不能直接测试失败情况
   - 只能验证 API 可用性

2. **ensure 测试**
   - ensure 失败不崩溃
   - 可以测试失败情况
   - 验证返回值和继续执行

3. **日志测试**
   - 验证日志输出
   - 检查日志文件
   - 验证格式正确

---

## 总结

调试和日志是 **开发效率的关键**：
- 日志 → 问题诊断
- 断言 → 早期发现错误
- 调试绘制 → 可视化调试
- 性能分析 → 优化指导

**估计工作量**：3 个测试文件，约 15-20 个测试方法
**优先级**：🔴🔴 高（开发辅助工具）

**特殊说明**：
- 断言测试需要特殊处理（不能真崩溃）
- 日志测试需要验证输出
- 调试绘制需要可视化验证（可选）







