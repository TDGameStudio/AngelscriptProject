# Bind 步骤并行化可行性分析与方案

## 背景与目标

### 背景

AngelScript 引擎初始化时，`BindScriptTypes()` 将所有 C++ 类型、方法、全局函数注册到 `asIScriptEngine`。这是引擎启动链路中的关键阶段：

```
Initialize() → Initialize_AnyThread()
  → LoadBindModules()          // 加载生成的绑定分片 DLL
  → BindScriptTypes()          // ★ 本计划关注的阶段
    → CallBinds()              // 排序后逐个执行绑定函数
  → InitialCompile()           // 脚本编译
```

当前仓库中手写绑定（`Binds/` 目录）约 **120 个 `FBind` 注册点**，分布在约 120 个 `Bind_*.cpp` 文件中。加上运行时生成的绑定分片模块（`ASRuntimeBind_0` ~ `ASRuntimeBind_110`、`ASEditorBind_0` ~ `ASEditorBind_30`），总绑定数量可达 **数百个**。

`CallBinds()` 的执行模型非常简单：

```cpp
// AngelscriptBinds.cpp 第 121-145 行
void FAngelscriptBinds::CallBinds(const TSet<FName>& DisabledBindNames)
{
    for (const FBindFunction& Bind : GetSortedBindArray())
    {
        if (DisabledBindNames.Contains(Bind.BindName))
            continue;
        Bind.Function();  // 顺序执行每个绑定
    }
}
```

**纯单线程顺序执行**，没有任何并行化。UEAS2 参考实现也完全相同。

### 当前 Bind 系统架构详情

#### 排序与优先级

唯一的排序键是 `int32 BindOrder`，有三个预定义档位：

| 档位 | 值 | 典型用途 |
| --- | --- | --- |
| `EOrder::Early` | -100 | 类型声明（`RegisterObjectType`），如 `Bind_FString`、`Bind_FVector`、`Bind_Delegates`、`Bind_Primitives` |
| `EOrder::Normal` | 0 | 大部分独立类型的方法绑定 |
| `EOrder::Late` | 100 | 依赖其他类型已存在的绑定，如 `Bind_BlueprintType`（`Late+100`）、`Bind_AActor`（`Late+150`） |

实际使用中存在大量微调（`Early+1`、`Late-1`、`Late+105`、`Late+150` 等），本质是一个**线性优先级序列**，没有显式依赖图。

#### 绑定执行中改变的全局状态

每个 `Bind.Function()` lambda 内部通过 `FAngelscriptBinds` 的 API 操作以下全局状态：

| 状态 | 写入 API | 线程安全性 |
| --- | --- | --- |
| `asCScriptEngine` 内部数组（`registeredObjTypes`、`registeredGlobalFuncs`、`registeredGlobalProps`、`allRegisteredTypes`、`typeLookup`） | `RegisterObjectType`、`RegisterObjectMethod`、`RegisterGlobalFunction`、`RegisterEnum`、`RegisterEnumValue` 等 | ❌ **非线程安全**：Register 系列方法不加锁，直接 `PushLast` 到内部数组；`isPrepared = false` 是非原子赋值 |
| `asCScriptEngine::defaultNamespace` | `SetDefaultNamespace` / 通过 `FNamespace` RAII 临时切换 | ❌ **引擎级全局状态**：`FNamespace` 构造时设新值、析构时恢复旧值，并发会导致 namespace 错乱 |
| `FAngelscriptBinds::PreviouslyBoundFunction` | `OnBind()` 写入，后续 `SetPreviousBindIsPropertyAccessor` 等读取 | ❌ **静态变量**：绑定 A 注册一个方法后立即设置 trait，如果另一个线程同时绑定 B 则 `PreviouslyBoundFunction` 会被覆盖 |
| `FAngelscriptBinds::ClassFuncMaps`、`SkipBinds`、`SkipBindNames`、`SkipBindClasses` | 各绑定函数内部写入 | ❌ **静态 TMap/TSet**：无锁 |
| `FAngelscriptType` 数据库 | `FAngelscriptType::Register`、`RegisterTypeFinder` | ❌ **静态数据结构**：无锁 |

#### AngelScript 引擎的 `engineRWLock` 使用情况

`as_scriptengine.cpp` 中的 `ACQUIREEXCLUSIVE(engineRWLock)` / `ACQUIRESHARED(engineRWLock)` 共出现约 25 次，但**全部用于**：
- `SetUserData` / `GetUserData`（用户数据存取）
- `GetModuleCount` / `GetModuleByIndex`（模块枚举）
- `Set*CleanupCallback`（清理回调注册）

**所有 `Register*` 方法（`RegisterObjectType`、`RegisterObjectMethod`、`RegisterGlobalFunction` 等）内部不使用任何锁**。它们直接操作 `registeredObjTypes.PushLast`、创建 `asCScriptFunction`、设置 `isPrepared = false` 等。

### 隐式依赖分析

虽然没有显式依赖图，但 bind 之间存在以下**隐式依赖**：

1. **类型必须先于方法注册**：`RegisterObjectMethod("FVector", ...)` 要求 `FVector` 已经通过 `RegisterObjectType` 注册。这是 AS 引擎的硬约束——内部会 `ParseDataType` 查找类型
2. **Early → Late 的二阶段模式**：许多类型采用 Early 注册类型声明 + Late 注册方法/转换的模式（如 `Bind_FVector` 的 `Early` 声明 + `Late` 转换）
3. **`FNamespace` RAII**：构造时 `SetDefaultNamespace(name)`，析构时恢复旧值。如果并发执行，namespace 状态会互相覆盖
4. **`PreviouslyBoundFunction` 链式调用**：`BindMethod` → `OnBind` → 设置 `PreviouslyBoundFunction` → 紧接着 `SetPreviousBindIsPropertyAccessor` 读取。这是一个**紧耦合的串行模式**

### UEAS2 对比

| 项 | UEAS2 | 当前仓库 |
| --- | --- | --- |
| `CallBinds` 实现 | 单线程顺序 for 循环 | 同 |
| 排序 | `BindOrder` 整数排序 | 同 |
| 并行化 | **无**（编译阶段有 `ParallelFor` 但绑定无） | 无 |
| 线程化初始化 | `Initialize_AnyThread` 可放到 `AsyncTask` | 同 |

---

## 可行性评估

### 结论：直接并行化 `CallBinds` **不可行**

原因如下：

1. **AngelScript 引擎 API 非线程安全**：`RegisterObjectType`、`RegisterObjectMethod` 等核心 Register 方法**不加锁**，内部直接操作 `registeredObjTypes`、`allRegisteredTypes`、`typeLookup` 等数组和 map。并发调用会导致数据竞争和崩溃

2. **`defaultNamespace` 是引擎级单例状态**：`FNamespace` RAII 通过 `SetDefaultNamespace` / `GetDefaultNamespace` 临时切换 namespace，并发修改会导致类型注册到错误的 namespace

3. **`PreviouslyBoundFunction` 是绑定间紧耦合的静态变量**：绑定代码普遍依赖"注册方法 → 立即设置 trait"的串行语义，并行化会破坏这个约定

4. **隐式顺序依赖广泛存在**：Early/Late 二阶段模式、跨绑定的类型引用，都依赖特定的执行顺序

### 可行的替代优化方向

虽然直接并行化绑定执行不可行，但仍有几个可以加速绑定阶段的方向：

#### 方向 A：预计算与缓存（低风险、中收益）

将绑定阶段的部分工作预先完成或缓存，减少运行时开销。

- **Bind DB 缓存已存在**：`AS_USE_BIND_DB` 路径会从 `Binds.Cache` 加载预计算的绑定数据库（非 Editor 场景），这已经是一种缓存优化
- **预排序绑定数组**：当前 `GetSortedBindArray()` 每次调用都对静态数组做一次 `Sort()`。可以在首次排序后缓存结果，避免重复排序

#### 方向 B：绑定注册的批量化（中风险、中收益）

AngelScript 的 `Register*` 方法每次调用都做字符串解析（`asCBuilder::ParseDataType`、签名解析等）。可以：

- 收集同一类型的所有方法注册，合并为批量调用减少重复的类型查找
- 预解析绑定签名字符串，缓存类型查找结果

#### 方向 C：分阶段绑定 + 阶段内并行准备（中风险、高收益）

将绑定分为严格的三个阶段：

1. **Phase 1（类型声明）**：所有 `RegisterObjectType` / `RegisterEnum` / `RegisterInterface`。这些操作相对独立（不依赖其他已注册类型），但仍需串行执行（AS 引擎 API 限制）
2. **Phase 2（并行准备）**：在工作线程上并行准备每个绑定的参数数据（签名字符串构造、函数指针收集、类型查找缓存），不调用 AS 引擎 API
3. **Phase 3（方法注册）**：将准备好的注册数据顺序提交给 AS 引擎

这种方式的核心思想是把"准备数据"和"提交给引擎"分离，前者可以并行。

#### 方向 D：解决 `PreviouslyBoundFunction` 瓶颈（低风险、低收益）

当前 `PreviouslyBoundFunction` 是一个静态变量，绑定代码依赖"注册 → 立即设置 trait"的模式。改为让 `BindMethod` / `BindGlobalFunction` 等直接返回 function ID 并由调用方持有，消除静态变量依赖。这不直接实现并行化，但移除了一个并行化的前置障碍。

---

## 推荐方案与执行计划

综合可行性和收益，推荐先实施**方向 A（预排序缓存）** + **方向 D（消除 PreviouslyBoundFunction 瓶颈）**，再视绑定耗时数据决定是否深入方向 C。

---

## Phase 1：测量当前绑定耗时基线

> 目标：在做任何优化之前，先获取精确的绑定耗时分解数据，为后续决策提供量化依据。

- [ ] **P1.1** 在 `CallBinds` 中增加 per-bind 计时，按 BindOrder 分档统计耗时
  - 当前只有 `FAngelscriptBindExecutionObservation` 记录整体 `CallBinds` 耗时（`BeginObservationPass` / `EndObservationPass`），没有 per-bind 粒度
  - 在 `CallBinds` 循环内，用 `FPlatformTime::Seconds()` 包裹每个 `Bind.Function()` 调用，收集 `{BindName, BindOrder, DurationMs}` 三元组
  - 输出到日志或存入 `FAngelscriptBindExecutionObservation` 的新数据结构中，按 BindOrder 分档（Early / Normal / Late / Late+100~150）汇总
  - 条件编译在 `AS_PRINT_STATS` 或 `WITH_DEV_AUTOMATION_TESTS` 下
- [ ] **P1.1** 📦 Git 提交：`[AngelscriptRuntime] Feat: add per-bind timing instrumentation to CallBinds`

- [ ] **P1.2** 运行一次完整的编辑器启动 + 非编辑器启动，收集绑定耗时数据
  - 记录总绑定耗时、各档位（Early/Normal/Late）的累计耗时、top-10 最慢的单个绑定
  - 数据记录在本计划文档的 Phase 1 完成注释中
  - 如果总绑定耗时 < 500ms，并行化优化的优先级应下调；如果 > 2s，方向 C 的投入回报才显著
- [ ] **P1.2** 📦 Git 提交：`[AngelscriptRuntime] Doc: bind timing baseline measurement`

---

## Phase 2：消除 `PreviouslyBoundFunction` 全局耦合

> 目标：移除绑定代码对静态变量 `PreviouslyBoundFunction` 的依赖，为后续可能的分离"准备"与"提交"阶段扫清障碍。

- [ ] **P2.1** 审计所有使用 `PreviouslyBoundFunction` / `GetPreviousBind` 的调用点
  - `PreviouslyBoundFunction` 在 `OnBind()` 中被设置（`AngelscriptBinds.cpp` 第 360 行），然后被 `MarkAsImplicitConstructor`、`DeprecatePreviousBind`、`SetPreviousBindIsPropertyAccessor`、`SetPreviousBindIsEditorOnly`、`SetPreviousBindIsCallable`、`SetPreviousBindNoDiscard`、`CompileOutPreviousBind` 等方法读取
  - 逐一检查 `Binds/` 目录下所有使用这些方法的位置，确认每个调用点是否都紧跟在 `BindMethod` / `BindExternMethod` / `BindGlobalFunction` 之后
  - 评估能否改为让 `BindMethod` 等返回一个包装对象（如 `FBoundFunction`），调用方在包装对象上链式设置 trait
- [ ] **P2.1** 📦 Git 提交：`[AngelscriptRuntime] Doc: audit PreviouslyBoundFunction usage across all binds`

- [ ] **P2.2** 引入 `FBoundFunction` 返回值模式，逐步替代 `PreviouslyBoundFunction`
  - 设计 `FBoundFunction` 结构体，持有 `int32 FunctionId`，提供 `MarkAsImplicitConstructor()`、`Deprecate()`、`SetPropertyAccessor()` 等方法
  - 让 `BindMethod`、`BindExternMethod`、`BindGlobalFunction` 等返回 `FBoundFunction`（已有部分方法返回 `int FunctionId`，可以直接包装）
  - 在不破坏现有 API 的前提下，对新写的绑定代码推荐使用新模式；现有代码可逐步迁移
  - `PreviouslyBoundFunction` 短期保留为向后兼容路径，长期标记 deprecated
- [ ] **P2.2** 📦 Git 提交：`[AngelscriptRuntime] Refactor: introduce FBoundFunction to replace PreviouslyBoundFunction pattern`

---

## Phase 3：预排序缓存与注册去重

> 目标：减少 `CallBinds` 路径上的冗余计算开销。

- [ ] **P3.1** 缓存排序后的绑定数组，避免每次 `CallBinds` 重新排序
  - 当前 `GetSortedBindArray()` 每次调用都拷贝 + 排序整个静态数组。由于绑定注册只在静态构造期发生，排序结果在运行时不会变化
  - 增加一个 `static bool bSorted` 标志（或懒初始化模式），首次调用时排序并缓存，后续调用直接返回已排序数组的引用
  - `ResetBindState()` 中清除缓存标志
- [ ] **P3.1** 📦 Git 提交：`[AngelscriptRuntime] Opt: cache sorted bind array to avoid redundant sorting`

- [ ] **P3.2** 检查 `RegisterObjectType` 的 `asALREADY_REGISTERED` 回退路径的频率
  - 一些绑定文件中，同一个类型可能被多个绑定点尝试注册（返回 `asALREADY_REGISTERED` 后 fallback 到 `GetTypeInfoByName`）。这不影响正确性，但每次都做字符串解析和查找
  - 通过 P1.1 的计时数据识别是否有高频重复注册的热点
  - 如果有，考虑在 `FAngelscriptBinds` 层增加一个 `TMap<FBindString, asITypeInfo*>` 缓存，减少对 AS 引擎的重复调用
- [ ] **P3.2** 📦 Git 提交：`[AngelscriptRuntime] Opt: reduce redundant RegisterObjectType calls via type cache`

---

## Phase 4：分阶段绑定架构评估（视 Phase 1 数据决定）

> 目标：如果 Phase 1 的测量数据显示绑定耗时显著（> 2s），评估将绑定拆分为"类型声明阶段"和"方法注册阶段"，并在方法注册前并行准备注册数据。

- [ ] **P4.1** 设计分阶段绑定原型：类型声明 vs 方法注册分离
  - 当前许多绑定文件已经自然分为 `Early`（类型声明）和 `Late`（方法注册）两个 `FBind`
  - 评估是否可以强制所有绑定按此模式拆分，使 Early 阶段完成后所有类型已知，Late 阶段的方法注册可以并行准备参数数据
  - "并行准备"指在工作线程上构造签名字符串、收集函数指针等不涉及 AS 引擎状态修改的工作；最终 `RegisterObjectMethod` 仍在单线程上串行调用
  - 这需要解决 `FNamespace` RAII 的线程安全问题——准备阶段需要预计算 namespace 而非运行时切换
- [ ] **P4.1** 📦 Git 提交：`[AngelscriptRuntime] Doc: staged binding architecture prototype evaluation`

- [ ] **P4.2** 如果 P4.1 原型可行，实现最小化的分阶段 `CallBinds`
  - 将 `GetSortedBindArray()` 的结果按 `BindOrder` 阈值分为两批：`<= 0`（Early+Normal）和 `> 0`（Late）
  - 第一批串行执行（类型声明）
  - 第二批：先并行调用一个"准备"回调收集注册参数，再串行提交给 AS 引擎
  - 这需要对 `FBind` 的注册 API 做拆分：`FBind` 可以注册一个 `PrepareFunction` 和一个 `CommitFunction`，而非单一的 `Function`
  - 验证绑定结果与纯串行路径完全一致（通过比对 `asIScriptEngine` 的类型/函数数量和 ID 分配）
- [ ] **P4.2** 📦 Git 提交：`[AngelscriptRuntime] Feat: implement staged CallBinds with parallel preparation`

---

## 验收标准

- [ ] Phase 1 完成后，有精确的 per-bind 耗时数据，记录在本计划文档中
- [ ] Phase 2 完成后，新绑定代码不再依赖 `PreviouslyBoundFunction` 静态变量
- [ ] Phase 3 完成后，`CallBinds` 不再每次重新排序绑定数组
- [ ] 所有改动不影响现有绑定的注册结果（类型数量、函数 ID 等与改动前一致）
- [ ] 所有现有测试继续通过
- [ ] `AngelscriptProjectEditor Win64 Development` 构建通过

## 风险与注意事项

- **AngelScript 引擎 API 不可并发**：`RegisterObjectType`、`RegisterObjectMethod` 等**不加锁**，并发调用会导致数据竞争。任何并行化方案都必须保证最终的 AS 引擎 API 调用仍是串行的
- **`defaultNamespace` 全局状态**：`FNamespace` RAII 修改引擎级 namespace。并行准备阶段如果需要 namespace 信息，必须预计算而非运行时切换
- **`PreviouslyBoundFunction` 紧耦合**：绑定代码普遍依赖"注册 → 立即设置 trait"的串行语义。Phase 2 的 `FBoundFunction` 模式在迁移过程中需要与旧模式共存
- **绑定分片模块的加载顺序**：`ASRuntimeBind_*` 模块在 `LoadModule` 时注册绑定到静态数组，排序在 `CallBinds` 中完成。如果分阶段绑定需要不同的注册模式（Prepare + Commit），生成的绑定代码也需要同步修改
- **收益依赖实际耗时数据**：如果 Phase 1 测量显示总绑定耗时 < 500ms，Phase 4 的分阶段并行化投入产出比较低，应将精力转向其他优化（如脚本编译并行化——UEAS2 已有 `BuildParallelParseScripts` 先例）
- **生成绑定代码的兼容性**：`AngelscriptEditorModule.cpp` 中 `GenerateNativeBinds` 生成的分片模块代码使用 `FAngelscriptBinds::RegisterBinds(EOrder::Late, ...)` 模式。如果 Phase 4 引入新的 Prepare + Commit 拆分，需要同步更新代码生成器

---

## 附录 A：原子计数与数据提前确定可行性专题

> 本附录回答一类常见提问：「每个 `Bind` 写入 AS 引擎的数据都可以提前确定，是否可以用原子计数（如递增 `nextScriptFunctionId`）替代锁，从而把 `CallBinds` 阶段并行化？」结论先行：思路在概念上对了一半，但落到当前 fork 的 AngelScript 引擎实现时，**仅靠原子计数远远不够**；要把它变成可用方案，仍要走方向 C 的「分阶段并行准备 + 串行提交」路径，并且收益必须先经过 Phase 1 的实测耗时数据验证。

### 附录 A.1 — 思路重述

把每个 `Bind.Function()` lambda 内部要写入 `asIScriptEngine` 的字段（签名字符串、函数指针、UserData 等）预先在工作线程上备好，最关键的「函数 ID」改用 `std::atomic<int>` 自增分配，整个 `CallBinds` 因此可以 `ParallelFor`。该思路天然有吸引力，因为它把"瓶颈"简化为单一资源争用。

### 附录 A.2 —「数据是否真的能提前确定」分类

直接对照 [Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine.cpp) 中 `RegisterObjectMethod`（第 2691 行）与 `RegisterMethodToObjectType`（第 2717 行）实际写入的字段：

可提前确定（lambda 局部、纯本地数据）：

- 签名字符串字面量（`"void SetWorldLocation(const FVector &in)"`）
- 函数指针 `asSFuncPtr` / 调用约定 `asECallConvTypes` / `ASAutoCaller::FunctionCaller`
- UserData 指针、`accessorType`、父类型名 `obj`
- `FNamespace` 名字面量

不可提前确定（必须运行期生成、且依赖前序 bind 已完成的全局状态）：

- `func->id`：由 `asCScriptEngine::GetNextScriptFunctionId()`（第 5503 行）从 `freeScriptFunctionIds` 栈顶或 `scriptFunctions.GetLength()` 获取
- `ParseDataType("AActor", &dt, defaultNamespace, ...)` 的解析结果：内部读 `engine->allRegisteredTypesByName` / `typeLookup`，依赖该类型已被前面的 bind 注册过
- `ParseFunctionDeclaration` 的解析结果：对每个参数类型做同样查找
- `objectType->FindMethod(name, ...)` 的重载冲突检查结果：依赖该类型当前的 `methodTable`
- `func->CalculateParameterOffsets()`：依赖参数 `asCDataType` 已确定

也就是说，「数据可提前确定」对**字面量级的输入**成立，对**引擎查询出的中间结果**不成立。

### 附录 A.3 — 「原子计数」能解决什么、不能解决什么

可单点原子化（理论可行，工程量小）：

- `nextScriptFunctionId` 自增：把 `GetNextScriptFunctionId()` 改成 `std::atomic<int>::fetch_add(1)`，即可让多线程并发抢 ID
- `PreviouslyBoundFunction`（[Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp) 第 73 行 `GetPreviouslyBoundFunctionRef`）：可改为 `thread_local`，但这只是把「跨线程冲突」转成「线程内顺序」，不解除语义耦合

不可单点原子化（必须串行，或换一整套 lock-free 容器）：

- `scriptFunctions.PushLast(func)`：`asCArray::PushLast` 内部会扩容 realloc + memcpy，扩容期间任何并发读会拿到悬空指针
- `objectType->methods.PushLast(id)` 与 `objectType->methodTable.Add(func)`：同上
- `engine->allRegisteredTypesByName`、`typeLookup`、`registeredObjTypes` 等表的写入：哈希表 rehash 不是原子操作
- `defaultNamespace` 是 `asCScriptEngine` 全局变量，[Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp) 第 760~771 行 `FNamespace` RAII 通过 `SetDefaultNamespace` 切换；并行执行时不同线程会互相覆盖，导致方法注册到错误 namespace

引申结论：**若要让 `RegisterObjectMethod` 整体无锁可并发，等同于把 `asCArray` / `asCMap` 换成 lock-free 容器，并改写 `defaultNamespace` 的语义**。这是对 fork 出去的 AS 引擎做结构性重构，违反 [AGENTS.md](AGENTS.md) 写明的「`AngelScript` 选择性吸收、不大改 fork」策略，也会让后续合并上游 2.38+ 的代价急剧上升。

### 附录 A.4 — 场景区分：手写 Binds vs 生成 Bind 分片

按可并行性把 bind 来源分成两类讨论。

#### A.4.1 生成绑定分片（`ASRuntimeBind_*` / `ASEditorBind_*`）

- 来源：[Plugins/Angelscript/Source/AngelscriptEditor/CodeGen/AngelscriptEditorCodeGen.cpp](Plugins/Angelscript/Source/AngelscriptEditor/CodeGen/AngelscriptEditorCodeGen.cpp) 第 270 行 `FAngelscriptEditorModule::GenerateNativeBinds`，每 10 个 UClass 一个分片，分片缓存写入 `BindModules.Cache`（同文件第 348 行）
- 模式高度规整：每个分片只做「对一组 UClass 的 BlueprintCallable 函数调 `BindMethod` / `BindMethodDirect`」，**不做类型声明、不做 namespace 切换、不做跨分片依赖**，统一注册在 `EOrder::Late`
- 可并行性评估：
  - **Prepare（并行可）**：在工作线程上完成 `UClass::GenerateFunctionList` 收集、签名字符串构造、`FFuncEntry` 整理、调用约定推导，**不接触 `asIScriptEngine`**
  - **Parse（分阶段并行可）**：前提是所有 `Bind_*` 早期类型声明（`Early`/`Normal`）已串行完成、类型表已冻结，工作线程上的 `ParseDataType` / `ParseFunctionDeclaration` 才是「只读引擎」操作
  - **Commit（必须串行）**：`AddScriptFunction` + `methods.PushLast` + `methodTable.Add` 这一段写入容器，与原子计数无关
- 收益预估假设：生成绑定方法数量远超手写 binds（每分片 10 个 UClass、所有 BlueprintCallable 方法叠加），如果 Phase 1 数据显示 Parse + 字符串处理是热点，分阶段并行的相对收益最大

#### A.4.2 手写 Binds（`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_*.cpp`）

- 模式不规整：
  - `FNamespace` RAII 普遍存在：[Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2D.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector2D.cpp) 第 185 行、[Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_InputEvents.cpp) 第 217 行等
  - `PreviouslyBoundFunction` 紧跟 `BindMethod` 的副作用调用普遍存在：`Bind_FString.cpp` / `Bind_FVector.cpp` / `Bind_AActor.cpp` / `Bind_BlueprintEvent.cpp` / `Bind_BlueprintType.cpp` / `Bind_UStruct.cpp` 等数十个文件
  - 部分类型采用 `Early` 类型声明 + `Late` 方法注册的二阶段模式（`Bind_FVector` 等数学类型）
- 可并行性评估：
  - 不能直接套用「Prepare → Commit」模型，需先按 Phase 2 完成 `FBoundFunction` 改造、消除 `PreviouslyBoundFunction` 紧耦合
  - `FNamespace` RAII 在并行准备阶段必须用「预计算 namespace 字段」替代「运行时 SetDefaultNamespace」
- 现实路径：**手写 Binds 暂时维持串行**，把生成绑定作为并行试点的第一阶段；待生成绑定的 Prepare/Commit 拆分稳定后，再决定是否扩展到手写 Binds

### 附录 A.5 — 与现有 Phase 1~4 的对应关系

- 用户思路「数据提前确定」≡ 方向 C / Phase 4.1 中描述的「在工作线程上构造签名字符串、收集函数指针等不涉及 AS 引擎状态修改的工作」
- 用户思路「原子计数 ID」≡ Phase 4.1 的工作线程间 ID 同步原语，作用范围仅限「ID 分配」一步
- 用户思路「并行 register」≡ 方向 C 已写明「最终 `RegisterObjectMethod` 仍在单线程上串行调用」，即提交阶段不能并行
- 收益判断 ≡ Phase 1.1 / 1.2 的 per-bind 计时基线必须先落地，否则任何并行原型都缺乏决策依据

### 附录 A.6 — 落地前置条件清单

要进入「并行 bind 原型」阶段，必须先满足以下前置条件：

1. Phase 1.1 per-bind 计时落地，并跑出编辑器 / 非编辑器两组数据
2. Phase 2 完成 `FBoundFunction` 改造，消除 `PreviouslyBoundFunction` 静态变量耦合
3. 生成绑定代码模板（`AngelscriptEditorCodeGen.cpp` 的 `GenerateNativeBinds`）支持 Prepare / Commit 拆分，否则现有 `ASRuntimeBind_*` 分片仍走旧路径
4. 决策点：若 Phase 1 数据显示总绑定耗时 < 500ms，放弃并行原型，将精力转向脚本编译并行化（参照 UEAS2 `BuildParallelParseScripts` 先例）

### 附录 A.7 — 不做事项（明确缩小范围）

- 不做：把 `asCArray` / `asCMap` 替换为 lock-free 容器
- 不做：在 `RegisterObjectMethod` 入口加全局锁；锁开销 > 收益，且无法解决 namespace / `PreviouslyBoundFunction` 的语义耦合
- 不做：把整个 `CallBinds` 直接 `ParallelFor`；本计划「## 可行性评估」一节已论证不可行
- 不做：在本附录中扩展 Phase 1~4 的 todo 项与 Git 提交脚本；本附录是分析性专题，不引入新交付物

---

## 附录 B：Bind Database 并行化分析

> 本附录回答「`bind database` 这一类预计算数据是否可以并行生成」的问题。结论先行：要把 database 拆成两类来谈，**Editor 离线代码生成阶段的 database 几乎完全可并行（且作者在源码里已留下 TODO 注释）**，**运行期从 `Binds.Cache` 还原后的 register 调用仍然不能并行（受附录 A.3 约束）**。理解这一区别，可以让"并行化"投资集中在 ROI 最高的环节。

### 附录 B.1 — 两种 database 的辨别

工程里"bind database"实际指两个不同对象，并行可行性差别很大。

#### B.1.1 Database 1：`FAngelscriptBindDatabase`（持久化到 `Script/Binds.Cache`）

- 定义：[Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindDatabase.h](Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindDatabase.h)，由 `FAngelscriptStructBind` / `FAngelscriptClassBind` / `FAngelscriptMethodBind` / `FAngelscriptPropertyBind` 组成
- 用途：cooked game 在没有 editor metadata 的情况下重放 bind 调用所需的"快照"
- 填充入口（Editor 期间）：
  - [Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp) 第 1325 行 `Bind_Defaults`（`Late+100`，`#elif !AS_USE_BIND_DB` 分支，第 888~1714 行）：5-Phase 串行扫描所有 UClass，第 1550 行 `FAngelscriptBindDatabase::Get().Classes.Add(BindOrder.DBBind)`
  - [Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp) 第 1420 行 `FAngelscriptBindDatabase::Get().Structs.Add(DBBind)`
- 读取入口（cooked / `AS_USE_BIND_DB` 分支）：
  - [Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp) 第 706~753 行 `#if AS_USE_BIND_DB` 块：第 715 行 `for (auto& DBBind : FAngelscriptBindDatabase::Get().Classes) { ... BindUClass(...) }`、第 733/759 行调 `BindBlueprintEvent` / `BindBlueprintCallable`
  - [Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_UStruct.cpp) 第 865 行 `Bind_StructDeclarations`（`Early+1`）、第 885 行 `Bind_StructDetails`（`Late`）
- 序列化：[Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindDatabase.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindDatabase.cpp) 第 42 行 `Save` / 第 103 行 `Load`，单一 `FArchive` 顺序读写

#### B.1.2 Database 2：`RuntimeClassDB` / `EditorClassDB`（Editor 离线代码生成）

- 定义：`TMap<FString, TArray<TObjectPtr<UClass>>>`，按 package 名分组所有 BlueprintCallable 类
- 用途：仅给 `GenerateNativeBinds` 决定 `ASRuntimeBind_*` / `ASEditorBind_*` 分片的成员归属，**不写入 AS 引擎、不进入 cooked 流程**
- 填充入口：[Plugins/Angelscript/Source/AngelscriptEditor/CodeGen/AngelscriptEditorCodeGen.cpp](Plugins/Angelscript/Source/AngelscriptEditor/CodeGen/AngelscriptEditorCodeGen.cpp) 第 352 行 `GenerateBindDatabases()`，串行 `for (UClass* Class : TObjectRange<UClass>())`（第 359 行）
- 消费入口：同文件第 270 行 `GenerateNativeBinds`，把每 10 个 UClass 打成一个分片 `.cpp` 文件

### 附录 B.2 — 阶段化可行性评估

把 database 的生命周期拆成四个阶段单独评估：

#### B.2.1 阶段 A：`GenerateBindDatabases`（Editor 离线代码生成阶段，填充 Database 2）

- 当前实现：单线程 `TObjectRange<UClass>` 串行扫描，对每个 UClass 调 `FSourceCodeNavigation::FindClassHeaderPath`、`Class->GenerateFunctionList`、检查 `FUNC_BlueprintCallable`，最后 `RuntimeClassDB.Add(...)` / `EditorClassDB.Add(...)`
- 可并行性：**最高**
  - 每个 UClass 的处理是相互独立的纯只读操作（除了最后的 TMap 写入）
  - `FSourceCodeNavigation::FindClassHeaderPath` 是 Editor 同步 IO，几乎肯定是这一阶段的真实热点
  - **完全不接触 AS 引擎**，不受附录 A 任何前置条件约束
- 改造模板（不引入此 Plan 的 todo）：
  - `ParallelFor` 处理 UClass，每线程产出 thread-local `TArray<TPair<FString, UClass*>>`
  - 串行收尾批量 reduce 到 `RuntimeClassDB` / `EditorClassDB`
- 源码端已存在的 TODO 注释（[Bind_BlueprintType.cpp 第 1042 行](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp)）：
  - `for (UClass* Class : TObjectRange<UClass>()) //Could this be parallel for? Have to create all maps first`
  - 作者已经识别到同样的并行机会，但落到的是 `Bind_BlueprintType_Declarations`（`Early`）阶段；阶段 A 与之共享同一个机制

#### B.2.2 阶段 B：`Bind_Defaults` 5-Phase（Editor 期间，填充 Database 1 + 调 AS register）

- 当前实现：[Bind_BlueprintType.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp) 第 1325~1712 行
  - Phase 1（第 1341~1378 行）：拓扑排序 `ClassesToBind`
  - Phase 2（第 1380~1447 行）：`TFieldIterator<UFunction>` + `BindBlueprintEvent` / `BindBlueprintCallable`，**同时**写 `BindOrder.DBBind.Methods` 与调 `Binds.Method(...)`
  - Phase 3（第 1449~1521 行）：GetterSetter
  - Phase 4（第 1523~1551 行）：Inherit + `BindProperties` + 第 1550 行 `FAngelscriptBindDatabase::Get().Classes.Add(BindOrder.DBBind)`
  - Phase 5（第 1555 行起）：UInterface 方法 register
- 可并行性：**部分可并行，但需要先解耦**
  - "DB 写入"（`DBBind.Methods.Add` / `DBBind.Properties.Add`）是纯本地数据，可并行
  - "AS register"（`BindBlueprintEvent` / `BindBlueprintCallable` 内部 `Binds.Method(...)`）触发 `RegisterObjectMethod`，受附录 A.3 约束必须串行
  - 当前两件事**写在同一个循环里**，必须先按附录 A.6 完成 `FBoundFunction` 改造、消除 `PreviouslyBoundFunction` 紧耦合
- 改造方向（与附录 A.4.1 的 Prepare → Commit 模型同构）：
  - Pass 1（可 `ParallelFor`）：每线程遍历各自的 BindOrder 子集，只填 `DBBind.Methods/Properties` 和准备好"待 register entry"
  - Pass 2（必须串行）：把所有线程收集到的 entry 顺序提交给 AS 引擎

#### B.2.3 阶段 C：`Save(Binds.Cache)` / `Load(Binds.Cache)`（序列化）

- 当前实现：[AngelscriptBindDatabase.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBindDatabase.cpp) 第 42 行 `Save` / 第 103 行 `Load`，单一 `FArchive` 顺序读写
- 可并行性：**基本不需要并行**
  - 二进制 archive 本身的顺序性使得拆并行收益很低
  - 唯一可并行的子环节：`Save` 内 `FAngelscriptClassHeader` 收集（第 60~99 行，对每个 Class/Struct/Enum/Delegate 调 `FSourceCodeNavigation::FindClassHeaderPath`），如果实测显示 IO 是热点，可以 `ParallelFor` 收集；否则不值得改

#### B.2.4 阶段 D：cooked 启动时从 `Binds.Cache` 还原后调 AS register

- 当前实现：[Bind_BlueprintType.cpp](Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp) 第 706~753 行的 `#if AS_USE_BIND_DB` 分支，遍历 `FAngelscriptBindDatabase::Get().Classes` 调 `BindUClass` / `BindBlueprintCallable` / `BindBlueprintEvent`
- 可并行性：**不能并行**
  - 与 `CallBinds` 阶段的串行约束完全等价
  - 只是输入从"hardcoded lambda"换成"序列化数据"，AS 引擎 API 的非线程安全性没有改变
  - 直接受附录 A.3 约束（`asCArray::PushLast` 扩容、`allRegisteredTypesByName` rehash、`defaultNamespace` 全局变量）

### 附录 B.3 — 与附录 A 的对应映射

可以把"bind database 是否可并行生成"理解为附录 A 的具象化：

- 附录 A 中的 **Prepare 阶段** ≡ B.2.1 阶段 A 与 B.2.2 阶段 B 的 Pass 1，本质上就是"生成/填充 database"
- 附录 A 中的 **Commit 阶段** ≡ B.2.2 阶段 B 的 Pass 2 与 B.2.4 阶段 D，本质上就是"读 database 调 AS 引擎"
- 因此：**database 的生成本质上是 Prepare 阶段，可并行；register 是 Commit 阶段，必须串行**。容易踩的坑是把它们写在同一个循环里（如当前 `Bind_Defaults` 的 5-Phase），从而误判整体不可并行
- 落到既有 Phase 1~4 上：
  - 阶段 A 不依赖任何前置条件，可独立成单独 Plan 驱动
  - 阶段 B 必须先具备附录 A.6 的前置条件（per-bind 计时数据 + `FBoundFunction` 改造）才能动
  - 阶段 C / 阶段 D 维持现状

### 附录 B.4 — 按 ROI 排序的潜在改造方向

按"实施成本 / 预估收益 / 是否依赖附录 A 前置"三维度排序，从高到低：

1. **最高 ROI**：阶段 A（`GenerateBindDatabases` 改 `ParallelFor`）
   - 离线、无 AS 依赖、`FSourceCodeNavigation::FindClassHeaderPath` 几乎肯定是热点
   - 改动局限于 [AngelscriptEditorCodeGen.cpp](Plugins/Angelscript/Source/AngelscriptEditor/CodeGen/AngelscriptEditorCodeGen.cpp) 一个文件
   - 不依赖附录 A 的任何前置条件
2. **中 ROI**：阶段 B（`Bind_Defaults` 5-Phase 解耦为 Prepare / Commit）
   - 需要先按附录 A.6 完成 `FBoundFunction` 改造
   - 收益规模取决于 Phase 1.1 计时数据
3. **低 ROI**：阶段 C 中 `Save` 的 `FAngelscriptClassHeader` 收集 `ParallelFor`
   - 仅在实测显示该子环节占大头时才值得做
4. **不做**：阶段 D 直接并行
   - 与"把 `CallBinds` 直接 `ParallelFor`"等价，附录 A 已论证不可行

> 本附录与附录 A 一致，仅做分析性记录，不引入 todo 项与 Git 提交脚本。是否把阶段 A 推进为独立 Plan、是否把阶段 B 纳入 Phase 4 的执行计划，由后续基于 Phase 1 实测数据决定。
