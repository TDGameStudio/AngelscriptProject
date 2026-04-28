# Learning Trace Tests 阅读指南

本文档说明如何阅读和理解 Learning Trace Tests 的输出，帮助开发者快速了解 Angelscript 插件的关键机制。

## 输出结构

每个 Learning 测试遵循统一的输出结构：

```
[序号] Phase.StepId | 动作描述 | 观测结果
Key: Value
```

### Phase 标签

| Phase | 说明 |
|-------|------|
| `EngineBootstrap` | 原生引擎创建与初始化 |
| `Binding` | 函数/属性绑定 |
| `Compile` | 模块编译与诊断 |
| `Bytecode` | 字节码生成与函数体分析 |
| `ClassGeneration` | UClass/UFunction 生成 |
| `Execution` | 脚本执行生命周期 |
| `UEBridge` | UE 对象桥接 |
| `Debug` | 调试器上下文 |
| `GC` | 垃圾回收 |
| `Editor` | 编辑器功能 |

### 关键观测项

每个测试会输出特定的 Key-Value 对，帮助理解机制：

**编译阶段**
- `ModuleName`: 模块名
- `CompileResult`: 编译结果（Success/Error）
- `Diagnostics`: 错误/警告信息

**类生成阶段**
- `ScriptClassName`: 生成的脚本类名
- `GeneratedUClass`: 生成的 UClass
- `PropertyCount`: 属性数量
- `SuperClass`: 父类

**执行阶段**
- `FunctionDeclaration`: 函数声明
- `ExecuteResult`: 执行结果码
- `ReturnValue`: 返回值

**UE 桥接阶段**
- `ActorClass`: Actor 类名
- `PropertyName`: 属性名
- `FunctionName`: 函数名

## 按主题阅读

### Native 引擎基础

1. **Native Bootstrap** (`Learning/AngelScriptSDK/AngelscriptLearningNativeBootstrapTests.cpp`)
   - 学习：`asCreateScriptEngine`、引擎属性设置、模块创建
   - 输出：引擎实例指针、模块名、函数声明列表

2. **Native Binding** (`Learning/AngelScriptSDK/AngelscriptLearningNativeBindingTraceTests.cpp`)
   - 学习：`RegisterGlobalFunction`、`RegisterGlobalProperty`、`RegisterObjectType`
   - 输出：绑定类型名、注册结果、执行验证

3. **Bytecode & Execution** (`Learning/AngelScriptSDK/AngelscriptLearningBytecodeTraceTests.cpp`)
   - 学习：函数声明解析、字节码长度、`Prepare`/`Execute` 流程
   - 输出：字节码长度、参数计数、返回值

### Runtime 集成

1. **Compiler Pipeline** (`Learning/Runtime/AngelscriptLearningCompilerTraceTests.cpp`)
   - 学习：`BuildModule()` vs `CompileModuleFromMemory()` 的差异
   - 输出：`ECompileResult`、诊断信息

2. **Hot Reload Decision** (`Learning/Runtime/AngelscriptLearningHotReloadDecisionTraceTests.cpp`)
   - 学习：软重载、完整重载判定的触发条件
   - 输出：`ReloadRequirement`、触发解释

3. **Class Generation** (`Learning/Runtime/AngelscriptLearningClassGenerationTraceTests.cpp`)
   - 学习：`UCLASS()` 脚本如何变成 `UClass`
   - 输出：生成类名、属性列表、父类信息

4. **Script-Class to Blueprint** (`Learning/Runtime/AngelscriptLearningScriptClassToBlueprintTraceTests.cpp`)
   - 学习：脚本类如何作为 Blueprint 父类
   - 输出：Blueprint 名、继承关系、BeginPlay 验证

5. **UE Bridge** (`Learning/Runtime/AngelscriptLearningUEBridgeTraceTests.cpp`)
   - 学习：脚本函数如何成为 UE 可调用的 UFunction
   - 输出：属性名、函数名、ProcessEvent 结果

## 日志级别建议

运行 Learning 测试时推荐设置：

```
-LogCmds="Angelscript Display,LogAutomationTest Verbose"
```

如需更详细输出：

```
-LogCmds="Angelscript Verbose"
```

## 常见问题

### Q: 为什么有些测试的值断言很宽松？

A: Learning 测试侧重教学输出，不应对实现细节过度断言。某些值（如内存地址、完整 opcode 序列）可能因平台差异变化，教学型测试锁住结构与边界即可。

### Q: 如何判断某个机制是否稳定？

A: 查看测试的 Observation 输出。如果提到"边界观察"或"教学边界"，说明该路径在当前分支可能有边界条件，不宜在生产代码中依赖。

### Q: 可以直接复制这些测试代码吗？

A: 可以参考模式，但建议：
- 功能回归测试应放在 `Examples/` 或对应主题目录
- 内部正确性验证应放在 `AngelScriptSDK/`
- Learning 测试专注于解释机制

## 导出格式

如果测试支持 JSON 导出，输出目录为：

```
<ProjectRoot>/Saved/AutomationReports/LearningTests/
```

包含：
- `index.json`: 测试结果摘要
- 每个测试的详细事件列表
