# 编译流水线重构方案

> **目标**：重构当前 4 阶段编译流（parse → preprocess → compile → link），解决命名耦合顺序、职责边界不清晰、缺乏抽象和可扩展性的问题。
>
> **范围**：编译流水线架构全面重设计，行为等价即可。AS↔UE 类型映射作为后续独立项目。
>
> **约束**：周边子系统（Preprocessor、ClassGenerator、StaticJIT）的集成方式允许调整。

---

## 现状分析

### 当前架构

```
FAngelscriptPreprocessor::Process()
    ↓ TArray<TSharedRef<FAngelscriptModuleDesc>>
FAngelscriptEngine::CompileModules()
    ├── CompileModule_Types_Stage1()       // 解析 + 类型生成
    ├── CompileModule_Functions_Stage2()   // 函数签名生成
    ├── CompileModule_Code_Stage3()        // 字节码编译 + JIT
    └── CompileModule_Globals_Stage4()     // 全局变量初始化
```

### 核心问题

| 问题 | 表现 |
|------|------|
| 命名耦合顺序 | `Stage1/2/3/4` 编号让阶段间产生隐式顺序依赖，插入新阶段需要重编号 |
| 职责边界不清晰 | Stage1 同时做 import 解析、预编译数据加载、并行解析、类型生成 |
| 缺乏抽象 | 没有统一的 Phase/Pass 接口，无法以插件方式扩展编译流 |
| 巨型函数 | `CompileModules()` 约 800+ 行，混合了编排逻辑、错误处理、热重载交互 |
| 巨型类 | `FAngelscriptEngine` 约 184KB，编译流只是其职责之一 |

---

## 方案对比

### 方案 A：Pass-based Pipeline（LLVM 风格）

每个编译阶段是独立 Pass 对象，声明输入/输出/依赖，由 Pipeline Manager 自动排序和调度。

```cpp
class ICompilationPass
{
public:
    virtual FName GetPassName() const = 0;
    virtual void GetDependencies(TArray<FName>& OutDeps) const = 0;
    virtual EPassResult Execute(FCompilationContext& Context, FAngelscriptModuleDesc& Module) = 0;
};

class FCompilationPipeline
{
    TArray<TUniquePtr<ICompilationPass>> Passes;
public:
    void AddPass(TUniquePtr<ICompilationPass> Pass);
    ECompileResult Execute(FCompilationContext& Context, TArray<TSharedRef<FAngelscriptModuleDesc>>& Modules);
};
```

**优点**：
- 最大可扩展性，新增 pass 只需注册
- 依赖关系显式声明，Pipeline 可自动拓扑排序
- 每个 Pass 完全独立，可单独测试

**缺点**：
- 对 4-5 个阶段来说抽象偏重
- 依赖解析和调度逻辑本身需要维护
- 阶段间交错逻辑（如 Stage1/2 之间的 ClassGenerator 交互）拆分复杂

**适用场景**：阶段数量多（10+）、需要动态组合 pass、需要第三方扩展编译流。

---

### 方案 B：Phase 对象 + CompilationContext（推荐）

每个阶段是独立类，通过共享 `FCompilationContext` 传递中间状态，由简单顺序驱动器编排。

```cpp
class ICompilationPhase
{
public:
    virtual FName GetPhaseName() const = 0;
    virtual EPhaseResult Execute(FCompilationContext& Context) = 0;
};

struct FCompilationContext
{
    ECompileType CompileType;
    TArray<TSharedRef<FAngelscriptModuleDesc>> Modules;
    FCompilationDiagnostics Diagnostics;

    // 各阶段产出的中间数据通过 typed slots 存取
    template<typename T> T& GetOrCreate();
    template<typename T> const T* Find() const;
};

// 具体阶段实现
class FScriptParsingPhase : public ICompilationPhase { ... };
class FTypeGenerationPhase : public ICompilationPhase { ... };
class FFunctionGenerationPhase : public ICompilationPhase { ... };
class FCodeCompilationPhase : public ICompilationPhase { ... };
class FGlobalInitializationPhase : public ICompilationPhase { ... };
```

**优点**：
- 职责边界清晰，每个 Phase 类单一职责
- 命名语义化，不依赖编号
- Context 统一管理状态流转，避免参数爆炸
- 可扩展但不过度设计
- `FAngelscriptEngine` 得到瘦身

**缺点**：
- Context 需谨慎设计避免退化为 god object
- 比方案 C 多引入几个类文件
- 阶段间的隐式数据依赖需要通过 Context 的 typed slots 显式化

**适用场景**：阶段数量适中（4-8）、需要清晰的职责划分和可测试性、希望保持架构简洁。

---

### 方案 C：轻量重构——语义化命名 + 职责提取

保持函数式组织，去掉编号用语义命名，将过大函数拆分为更小职责单元。

```cpp
// Before
void CompileModule_Types_Stage1(...);
void CompileModule_Functions_Stage2(...);
void CompileModule_Code_Stage3(...);
void CompileModule_Globals_Stage4(...);

// After
void ParseAndGenerateTypes(ECompileType, TSharedRef<FAngelscriptModuleDesc>, ...);
void GenerateFunctionSignatures(ECompileType, TSharedRef<FAngelscriptModuleDesc>);
void CompileBytecodeAndJIT(ECompileType, TSharedRef<FAngelscriptModuleDesc>);
void InitializeGlobalVariables(ECompileType, TSharedRef<FAngelscriptModuleDesc>);
```

**优点**：
- 改动最小，风险最低
- 命名立即改善可读性
- 可渐进式进行

**缺点**：
- 不解决可扩展性问题
- 职责仍绑定在 `FAngelscriptEngine` 巨型类上
- `CompileModules()` 800+ 行编排逻辑仍是大函数

**适用场景**：时间紧迫、只想快速改善可读性、作为更大重构的第一步。

---

## 方案总结

| 维度 | 方案 A (Pass Pipeline) | 方案 B (Phase + Context) | 方案 C (轻量重构) |
|------|----------------------|------------------------|------------------|
| 可扩展性 | 极高 | 高 | 低 |
| 实现复杂度 | 高 | 中 | 低 |
| 职责清晰度 | 高 | 高 | 中 |
| 对现有代码影响 | 大 | 中-大 | 小 |
| 测试友好度 | 高 | 高 | 低 |
| 过度设计风险 | 高 | 低 | 无 |

**推荐方案 B**：Phase + Context 模式在编译器工程中成熟且实用，平衡了清晰度、可扩展性和实现成本。

---

## 落地注意事项

### 1. CompileModules() 编排逻辑的拆解

当前 `CompileModules()` 不是简单的"依次调用 4 个函数"。它包含：

- **模块间依赖解析**：Stage1 循环中先解析 imports 再编译，模块顺序有依赖
- **阶段间交错操作**：Stage1 和 Stage2 之间有 ClassGenerator 的类注册、热重载的版本链处理
- **错误传播与回滚**：某个模块编译失败后需要跳过后续阶段，但其他模块可能继续
- **并行化逻辑**：Stage1 内部的 `BuildParallelParseScripts()` 跨模块并行

落地时需要决定：这些交错逻辑是放在 Phase 内部，还是放在 Phase 之间的 "hook" 中，还是由 Context 的状态驱动。

**建议**：将交错操作建模为独立的轻量 Phase（如 `FClassRegistrationPhase`），而非塞进相邻 Phase 的前后。

### 2. FCompilationContext 的设计边界

Context 容易退化为 god object。需要明确：

- **Context 只持有跨阶段共享的状态**：Modules 列表、诊断信息、编译类型、全局配置
- **阶段内部的临时状态不进 Context**：如 Stage1 内部的 builder 对象
- **Typed slots 的生命周期**：某些中间数据只在相邻两个 Phase 间有效，用完应清理

```cpp
// Good: 跨阶段共享
Context.GetOrCreate<FTypeRegistry>();

// Bad: 只在一个 Phase 内部使用的临时数据
Context.GetOrCreate<FParserTemporaryState>();  // 不应该进 Context
```

### 3. PrecompiledData 的适配

当前 PrecompiledData 有 `ApplyToModule_Stage1/2/3()` 方法，与编号强耦合。重构后需要：

- 将 PrecompiledData 的接口改为按 Phase 名称索引，而非编号
- 每个 Phase 的 `Execute()` 内部自行检查是否有可用的预编译缓存
- 缓存 key 应基于内容 hash 而非阶段编号

### 4. 热重载路径的特殊处理

`ECompileType::SoftReloadOnly` 路径不走完整的 4 阶段流程。重构后需要：

- Phase 接口支持"跳过"语义（返回 `EPhaseResult::Skipped`）
- 或者为热重载定义一个不同的 Phase 序列
- Context 中携带足够信息让每个 Phase 自行判断是否需要执行

**建议**：让每个 Phase 内部根据 `CompileType` 决定行为，而非在外部用 if/else 跳过整个 Phase。

### 5. 错误处理策略

当前的错误处理散布在各 Stage 函数中，模式不统一。重构时统一为：

- Phase 返回 `EPhaseResult`（Success / Error / Skipped / PartialSuccess）
- 错误详情写入 `Context.Diagnostics`
- 驱动器根据返回值决定是否继续执行后续 Phase
- 单个模块的失败不应阻断其他模块的编译（当前行为需保留）

### 6. 文件组织

建议的目录结构：

```
Core/
├── AngelscriptEngine.h/cpp          // 瘦身后，只保留引擎生命周期管理
├── Compilation/
│   ├── CompilationContext.h         // FCompilationContext
│   ├── CompilationPhase.h           // ICompilationPhase 接口
│   ├── CompilationPipeline.h/cpp    // 驱动器/编排器
│   ├── Phases/
│   │   ├── ScriptParsingPhase.cpp
│   │   ├── TypeGenerationPhase.cpp
│   │   ├── FunctionGenerationPhase.cpp
│   │   ├── CodeCompilationPhase.cpp
│   │   └── GlobalInitializationPhase.cpp
│   └── CompilationDiagnostics.h
└── ...
```

### 7. 渐进式迁移策略

不建议一次性重写。推荐分步：

1. **Step 1**：引入 `ICompilationPhase` 接口和 `FCompilationContext`，创建空壳 Phase 类
2. **Step 2**：将 `CompileModule_Types_Stage1` 的逻辑搬入 `FScriptParsingPhase` + `FTypeGenerationPhase`
3. **Step 3**：逐个迁移 Stage2/3/4
4. **Step 4**：重构 `CompileModules()` 为使用 Pipeline 驱动器
5. **Step 5**：删除旧的 `CompileModule_*_Stage*` 函数

每一步完成后运行全量测试（417+ automation tests），确保行为等价。

### 8. 与 StaticJIT 的交互

当前 Stage3 内部直接调用 `ScriptModule->JITCompile()`。重构后有两个选择：

- JIT 作为 `FCodeCompilationPhase` 的内部步骤（简单，保持当前语义）
- JIT 作为独立的 `FJITCompilationPhase`（更清晰，但需要确保 bytecode 已就绪）

**建议**：初期保持在 CodeCompilation 内部，后续如果 JIT 逻辑复杂化再提取。

### 9. 测试策略

- 每个新 Phase 类应有独立的单元测试
- 保留现有 417+ 集成测试作为行为等价的验证基线
- 迁移过程中新旧路径可并行存在，通过 feature flag 切换，确认无回归后删除旧路径
