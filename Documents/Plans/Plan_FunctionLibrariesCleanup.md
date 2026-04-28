# FunctionLibraries 清理与功能恢复计划

## 背景与目标

`Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/` 在 fork 阶段经历过一次"`UFUNCTION(ScriptCallable)` → `UFUNCTION(BlueprintCallable)` / `UFUNCTION()`"的批量改造，但只改了一半：

- 类级 `meta=(ScriptMixin="...")` 大量被注释成 `//UCLASS(...)` + 退化为 `UCLASS(Meta = ())`，仅 8 个 mixin 库实际仍在反射注入路径上。
- 函数级 `Meta = (ScriptTrivial / NotAngelscriptProperty / ScriptName 重载)` 等功能性 meta 在改造时**没有迁移到 active 行**，只留在 `//UFUNCTION(ScriptCallable, ...)` 死注释里作为隐含 TODO。
- `AngelscriptActorLibrary.h` 里 27 个函数变成了裸 `UFUNCTION()`，**既不在 `Bind_BlueprintType.cpp` 反射绑定路径上、也没在 `Binds/` 目录被手工 `Method` 注册**，整文件大概率已是 dead code。

截至 2026-04-28 工作树状态（**待提交**），15 个 `FunctionLibraries/*.h` 已把语法噪音清掉（删 270+ 行死注释、修空 `Meta = ()` 占位、修 `Meta = (BlueprintCallable)` 嵌套笔误），并保留 `//UCLASS(Meta = (ScriptMixin = "..."))` 锚点 + 7 个文件头一段统一的 parity note（其中 `AngelscriptWorldLibrary.h` 头部注释已被本计划立项时同步修正为准确的"Bind_UWorld.cpp 手工接管"描述），行为零变化（`ProductionScriptMixinSignatures` 1/1、`FunctionLibraries.*` 23/23 PASS）。详细文件清单与影响分析见下方"已完成基线变更详单"章节。但**真正的功能损失还在 active 行里没补回来**。

本计划的目标是：

1. 把"死注释里有、active 行没有"的功能性 meta 量化盘点出来（取代被删掉的 ScriptCallable 死注释作为 TODO 锚点）。
2. 决策 `AngelscriptActorLibrary.h` 的去留：要么把它的功能手工补到 `Bind_AActor.cpp`，要么直接删除整文件。
3. 把 `ScriptTrivial` / `NotAngelscriptProperty` / `ScriptName` 重载 三类功能性 meta 在 active 行批量恢复。
4. 评估能否重新启用 `meta=(ScriptMixin="...")` 类级注入，把当前依赖 `BlueprintCallableReflectiveFallback` 的 8 个文件切回 Hazelight 上游路径。

## 范围与边界

- **范围内**
  - `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/` 下的 16 个 `.h` / `.cpp`
  - 与之手工配合的 `Binds/Bind_AActor.cpp`、`Binds/Bind_FunctionLibraryMixins.cpp`、`Binds/BlueprintCallableReflectiveFallback.h`
  - 相关测试：`Angelscript.TestModule.Engine.BindConfig.ProductionScriptMixinSignatures`、`Angelscript.TestModule.FunctionLibraries.*`、`Angelscript.TestModule.Bindings.*`
- **范围外**
  - 新增 mixin 库（如 `BlueprintMixinLibrary`、GAS 扩展库）—— 由 `Plan_HazelightScriptFeatureParity.md` 承接
  - `Bind_*.cpp` 大面积重排或并行化 —— 由 `Plan_BindParallelization.md` 承接
  - `ScriptCallable` meta 在 fork 内的全面恢复 —— 跟 `Helper_FunctionSignature.h` 改造相关，超出本计划

## 当前事实状态快照

1. **死注释已被批量清掉，行为零变化**：2026-04-28 工作树清理（待提交）已通过 lint 0 错误、UHT 0 警告、`ProductionScriptMixinSignatures` 1/1 PASS、`FunctionLibraries.*` 23/23 PASS 验证。`git show HEAD:...AngelscriptMathLibrary.h | rg ScriptTrivial -c` 在原文件计 98 处，其中 active 行 10 处、死注释 88 处；清理后 active 行仍是 10 处。
2. **17 处 `//UCLASS(Meta = (ScriptMixin = "..."))` 锚点已保留**，分布在 8 个文件中：MathLibrary（FVector / FVector3f / FRotator / FRotator3f / FQuat / FQuat4f / FTransform / FTransform3f）、Input（UInputComponent / APlayerController / UPlayerInput）、GameplayTagContainer / GameplayTag、World、AssetManager、HitResult。这些是 ScriptMixin 待恢复的精确目标。
3. **8 个文件 ScriptMixin 当前是启用状态**（`UCLASS(meta = (ScriptMixin = "..."))`）：`AngelscriptComponentLibrary`（USceneComponent）、`AngelscriptActorLibrary`（AActor）、`GameplayTagQueryMixinLibrary`（FGameplayTagQuery）、`RuntimeFloatCurveMixinLibrary`（FRuntimeFloatCurve UCurveFloat）、`RuntimeCurveLinearColorMixinLibrary`（FRuntimeCurveLinearColor）、`AngelscriptFrameTimeMixinLibrary`（FQualifiedFrameTime）、`WidgetBlueprintStatics::UAngelscriptWidgetMixinLibrary`（UWidget）、`UAngelscriptLevelStreamingMixinLibrary`（ULevelStreaming）。
4. **`AngelscriptActorLibrary.h` 是高度疑似 dead code**：
   - 类级 `meta=(ScriptMixin="AActor")` 启用 ✓
   - 但所有 27 个函数都是 `UFUNCTION()` 裸壳，没有 `BlueprintCallable / ScriptCallable` —— 不进入 `Bind_BlueprintType.cpp:1428-1437` 任何分支
   - `UAngelscriptActorLibrary` 类只在自己的 `.h` 出现，整个 `Binds/` 目录无任何引用
   - AS 脚本里 `Actor.SetActorRelativeLocation(...)` 能用，是因为 UE 引擎 `AActor` 自己有 BlueprintCallable 同名版本
5. **`Bind_BlueprintType.cpp:1428-1437` 是反射绑定的唯一总入口**：必须满足 `BlueprintEvent | NetFunc | BlueprintCallable | BlueprintPure | ScriptCallable` 之一才能被注册到脚本，没有这些就直接 silently dropped。
6. **`Helper_FunctionSignature.h:316-317` 显示 `bNotAngelscriptProperty` 与 `bTrivial` 是功能性 meta**：前者通过 `ModifyScriptFunction:530` 调 `ScriptFunction->SetProperty(false)` 抑制 angelscript property 自动识别；后者参与 trivial inline 优化（在 `WriteToDB` 落到 `FAngelscriptMethodBind::bTrivial`）。这两个 meta 在 active 行的缺失是**真实功能损失**，不是装饰差异。

## 已完成基线变更详单（2026-04-28，工作树待提交）

本节记录本计划立项时点为止已经在工作树落地、但**尚未 git commit** 的全部修改，作为后续 Plan 推进的精确起点。所有变更均无行为副作用，已通过 `Angelscript.TestModule.Engine.BindConfig.ProductionScriptMixinSignatures`（1/1 PASS）与 `Angelscript.TestModule.FunctionLibraries.*`（23/23 PASS）测试组验证。

### 修改文件清单（`git diff --numstat HEAD`）

`Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/`（15 个 `.h`，+181 / -368，净 -187 行）：

| 文件 | 增 | 删 | 净 | 主要变更 |
|---|---:|---:|---:|---|
| `AngelscriptMathLibrary.h` | 89 | 164 | -75 | 删 88 处 `//UFUNCTION(ScriptCallable, Meta = (ScriptTrivial, ...))` 死注释；修 1 处 `Meta = (BlueprintCallable)` 嵌套笔误（`MakeBox / MakeBoxFromCenterAndExtents` 等）；保留 8 处 `//UCLASS(Meta = (ScriptMixin = "FVector/FRotator/FQuat/FTransform/..."))` 类级锚点；加文件头 parity note |
| `AngelscriptComponentLibrary.h` | 27 | 62 | -35 | 删 35 处 `//UFUNCTION(ScriptCallable, ...)` 死注释；保留 active 行所有 `Meta = (ScriptTrivial / ScriptName / ...)`；ScriptMixin 类级 meta 已启用，无文件头 note |
| `AngelscriptActorLibrary.h` | 2 | 29 | -27 | 删 27 处 `//UFUNCTION(ScriptCallable, ...)` 死注释；ScriptMixin 类级 meta 已启用但所有函数仍是裸 `UFUNCTION()`（高度疑似 dead code，本计划 P2 决策） |
| `RuntimeFloatCurveMixinLibrary.h` | 0 | 27 | -27 | 删 27 处死注释；ScriptMixin 类级 meta 已启用 |
| `InputComponentScriptMixinLibrary.h` | 11 | 25 | -14 | 删 25 处死注释；保留 3 处 `//UCLASS(Meta = (ScriptMixin = "UInputComponent / APlayerController / UPlayerInput"))` 类级锚点；加文件头 parity note |
| `GameplayTagContainerMixinLibrary.h` | 9 | 21 | -12 | 删 21 处死注释；保留 `//UCLASS(Meta = (ScriptMixin = "FGameplayTagContainer"))` 类级锚点；加文件头 parity note |
| `GameplayTagMixinLibrary.h` | 9 | 10 | -1 | 删 10 处死注释；保留 `//UCLASS(Meta = (ScriptMixin = "FGameplayTag"))` 类级锚点；加文件头 parity note |
| `UAssetManagerMixinLibrary.h` | 9 | 10 | -1 | 删 10 处死注释；保留 `//UCLASS(Meta = (ScriptMixin = "UAssetManager"))` 类级锚点；加文件头 parity note |
| `AngelscriptHitResultLibrary.h` | 9 | 1 | +8 | 删 1 处空 `Meta = ()` 占位；保留 `//UCLASS(Meta = (ScriptMixin = "FHitResult"))` 类级锚点；加文件头 parity note |
| `SubsystemLibrary.h` | 0 | 6 | -6 | 删 6 处死注释；无 ScriptMixin |
| `AngelscriptScriptLibrary.h` | 0 | 3 | -3 | 删 3 处死注释；无 ScriptMixin |
| `GameplayTagQueryMixinLibrary.h` | 0 | 3 | -3 | 删 3 处死注释；ScriptMixin 类级 meta 已启用 |
| `GameplayLibrary.h` | 0 | 2 | -2 | 删 2 处死注释；无 ScriptMixin |
| `WidgetBlueprintStatics.h` | 0 | 2 | -2 | 删 2 处死注释；其中 `UAngelscriptWidgetMixinLibrary` 子类的 ScriptMixin 类级 meta 已启用 |
| `AngelscriptWorldLibrary.h` | 16 | 3 | +13 | 删 1 处空 `Meta = ()` 占位；保留 `//UCLASS(Meta = (ScriptMixin = "UWorld"))` 类级锚点；加文件头 parity note，并在本计划立项时同步**修正**了首版错误的"BlueprintCallableReflectiveFallback 兜底"描述，改为准确的"`Bind_UWorld.cpp:79-82` 手工 lambda 接管 + `IsScriptDeclarationAlreadyBound` 拦截机理"说明 |

`Documents/`（新增 2 份、修改 1 份）：

| 文件 | 状态 | 行数变更 | 主要内容 |
|---|---|---|---|
| `Documents/Knowledges/ZH/Syntax_Mixin.md` | 新建 | +343 | Mixin 知识基线总文档：AS 语言级 `mixin` 与 C++ `ScriptMixin` meta 的双轨实现、4 种触发方式、`*MixinLibrary` 文件清单（启用 8 / 关闭 8）、单元测试矩阵、§6 现状反思（含 §6.5 已落地清理 / §6.6 ScriptMixin 关闭文件三类分类）、与 Hazelight / vanilla AS 的差异 |
| `Documents/Plans/Plan_FunctionLibrariesCleanup.md` | 新建 | +160（含本章节扩展后达 +200+） | 本计划：4 个 Phase 覆盖 meta 损失矩阵盘点、ActorLibrary dead code 决策、active 行功能 meta 批量恢复、按文件三类分类的 ScriptMixin 重启评估（P4.1 审计 → P4.2 类 3 试点 → P4.3 类 3 批量 → P4.4 类 1 单独决策） |
| `Documents/Plans/Plan_OpportunityIndex.md` | 修改 | +3 / -2 | §3.1 表格新增"K. FunctionLibraries 清理与功能恢复"行；开篇执行 Plan 总数 57 → 58 |

### 影响分析

1. **行为零变化**：删除的全部是 `//UFUNCTION(ScriptCallable, ...)` 死注释和空 `Meta = ()` 占位，active 行 `UFUNCTION` / `Meta` / 函数体一行未触动；测试基线无回归。
2. **TODO 锚点替换**：被删除的 270+ 行死注释原本承担"已丢失功能 meta（`ScriptTrivial / NotAngelscriptProperty / ScriptName 重载`）"的隐性 TODO 角色。该角色由本计划 Phase 1 的 meta 损失矩阵显式接管。
3. **类级 ScriptMixin 锚点保留**：17 处 `//UCLASS(Meta = (ScriptMixin = "..."))` 一并保留作为 Phase 4 重启候选锚点；本计划 P4.1 审计将把它们分类到三类（手工 lambda 接管 / 反射 fallback / 仅静态命名空间）。
4. **首版错误已修正**：`AngelscriptWorldLibrary.h` 头部最初标注的"BlueprintCallableReflectiveFallback 兜底"描述基于错误推断；本计划立项时通过对 `Bind_UWorld.cpp:79-82` 与 `Bind_BlueprintCallable.cpp:62-70` 的代码审计，修正为"手工 lambda 接管 + `IsScriptDeclarationAlreadyBound` 拦截"的准确描述。
5. **`AngelscriptActorLibrary.h` 依然为 dead code 嫌疑**：清理仅去掉了死注释，27 个裸 `UFUNCTION()` 函数依然不进入 `Bind_BlueprintType.cpp:1428-1437` 任何绑定分支；本计划 P2 承接处置决策。
6. **未涉及任何 `Bind_*.cpp` 改动**：尽管定位 dead code 与手工接管路径时审阅了 `Bind_AActor.cpp` / `Bind_UWorld.cpp` / `Bind_FunctionLibraryMixins.cpp` / `Bind_BlueprintType.cpp` / `Bind_BlueprintCallable.cpp` / `BlueprintCallableReflectiveFallback.cpp` / `Helper_FunctionSignature.h`，但**未对任何绑定层文件做修改**。

### 建议提交拆分

为保证可审查性与可回滚性，已完成基线建议拆为以下提交（顺序无依赖，可重排）：

| 提交 | 范围 | 建议 message |
|---|---|---|
| C1 | 15 个 `FunctionLibraries/*.h` | `[FunctionLibraries] Refactor: drop legacy ScriptCallable dead comments and empty Meta placeholders` |
| C2 | `Documents/Knowledges/ZH/Syntax_Mixin.md` 新建 | `[Docs] Docs: add Syntax_Mixin knowledge baseline` |
| C3 | `Documents/Plans/Plan_FunctionLibrariesCleanup.md` 新建 + `Plan_OpportunityIndex.md` 索引联动 | `[Docs] Plans: add FunctionLibraries cleanup plan with meta-loss / dead-code / ScriptMixin re-enable scope` |

C1 提交后建议立即跑 `RunBuild.ps1 -Label fnlib-cleanup` + `RunTestSuite.ps1 -Suite Smoke` + `RunTests.ps1 -TestPrefix "Angelscript.TestModule.FunctionLibraries."` 三组烟雾验证，记录到 commit body。

## 影响范围

### 操作类型定义

本计划涉及以下操作（按需组合）：

- **active 行 meta 补齐**：把 `Meta = (ScriptName = "...", NotAngelscriptProperty)` 等从 fork 改造时丢失的 meta 加回 `UFUNCTION(BlueprintCallable, Meta = (...))`
- **ScriptMixin 重启**：取消 `//UCLASS(Meta = (ScriptMixin = "..."))` 行的注释，恢复 fork 改造时关闭的反射注入路径
- **ScriptTrivial 恢复**：把 fork 改造时遗弃的 `ScriptTrivial` 标志加回 active Meta
- **裸 `UFUNCTION()` 决策**：`UFUNCTION()` → `UFUNCTION(BlueprintCallable)` 让其进入反射路径；或迁移到 `Bind_AActor.cpp` 手工 Method；或整段删除
- **手工绑定迁移**：把 ActorLibrary 的特化 ScriptName 重载（如 `SetActorLocation` 的 `bSweep + FHitResult` 重载）迁移到 `Bind_AActor.cpp` 用 lambda 注册
- **dead code 删除**：确认无依赖后整文件删除

### 按文件分组的清单

`AngelscriptActorLibrary.h`（27 个函数，全裸 `UFUNCTION()`）：
- 27 个函数 — 裸 `UFUNCTION()` 决策（删 / 改 BlueprintCallable / 迁 Bind_AActor）
- `SetActorLocationAdvanced`、3 处 `*Quat` 重载、3 处 `*WorldRotation` 重载 — ScriptName 别名 + NotAngelscriptProperty 恢复（如选择保留文件）

`AngelscriptMathLibrary.h`（10 个子类，88 处死注释 ScriptTrivial 已删）：
- 7 个 mixin 子类 — ScriptMixin 重启（FVector / FVector3f / FRotator / FRotator3f / FQuat / FQuat4f / FTransform / FTransform3f）
- 大量 active 行 — ScriptTrivial 恢复

`AngelscriptComponentLibrary.h`（35 处死注释已删）：
- 全部 active 行 — ScriptTrivial 恢复
- 6 处 `*Quat` 重载 — ScriptName 别名 + NotAngelscriptProperty 恢复

`InputComponentScriptMixinLibrary.h`（25 处死注释已删，3 个子类 ScriptMixin 关闭）：
- 3 个子类 — ScriptMixin 重启（UInputComponent / APlayerController / UPlayerInput）

`GameplayTagContainerMixinLibrary.h` / `GameplayTagMixinLibrary.h`（21 + 10 处死注释已删）：
- 2 个子类 — ScriptMixin 重启（FGameplayTagContainer / FGameplayTag）

`AngelscriptHitResultLibrary.h`（11 处 ScriptTrivial active 已保留）：
- 1 个子类 — ScriptMixin 重启（FHitResult）
- ScriptTrivial 已 OK，无需补

`AngelscriptWorldLibrary.h` / `UAssetManagerMixinLibrary.h`（小文件，死注释已删）：
- 2 个子类 — ScriptMixin 重启（UWorld / UAssetManager）

`RuntimeFloatCurveMixinLibrary.h`（27 处死注释已删，ScriptMixin 启用）：
- 全部 active 行 — 无需补 meta（原 active 行也没有 ScriptTrivial）

`SubsystemLibrary.h` / `GameplayLibrary.h` / `AngelscriptScriptLibrary.h` / `WidgetBlueprintStatics.h`（普通库或单 mixin 类，死注释已删）：
- 无 active 行 meta 损失，本计划无操作

## 分阶段执行计划

### Phase 1：盘点与量化

- [ ] **P1.1** 生成"active 行 vs 死注释 meta 损失矩阵"
  - 工作树清理已删死注释，但功能差距没有可执行清单。需要从 git history 取出原文件内容，逐函数比对：每个函数原死注释里有哪些 meta、active 行有哪些、差额就是"丢失功能"
  - 立项时点的"清理前基线"在 `git stash` 或本计划提交前的 `HEAD`（即立项时刻 working tree 已 modified 状态的反向 diff）；同时配合更早的"`ScriptCallable` → `BlueprintCallable` 替换提交"（用 `git log --all -- Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptMathLibrary.h --diff-filter=M -p | head -200` 定位），做三方比对
  - 输出 `Documents/Plans/Plan_FunctionLibrariesCleanup/MetaLossMatrix.md`，按 16 个文件 × 4 类 meta（`ScriptTrivial` / `NotAngelscriptProperty` / `ScriptName` 重载 / `ScriptCallable`）列表，每行写文件名 + 函数名 + 当前 active meta + 应有 meta + 差额
  - 同步在 `Plan_OpportunityIndex.md` 三、缺陷重构章节添加本 Plan 索引
- [ ] **P1.1** 📦 Git 提交：`[Docs] Docs: add FunctionLibraries cleanup plan with meta-loss matrix`

### Phase 2：ActorLibrary dead code 决策

- [ ] **P2.1** 验证 `AngelscriptActorLibrary` 是否真的是 dead code
  - 用 `Tools\RunBuild.ps1 -SerializeByEngine` + 在 `UAngelscriptActorLibrary::SetActorRelativeLocation` 的实现里塞一行 `UE_LOG(LogTemp, Fatal, ...)`，跑 `Angelscript.TestModule.Actor.*`，确认这条 log 永远不触发即为 dead code
  - 备选验证路径：用 `as.DumpEngineState` 生成 `BindDatabase.csv`，搜 `UAngelscriptActorLibrary` 是否出现在 `ClassName` 列；不出现就是 dead code
  - 验证完成后回滚验证用的 Fatal log 修改
- [ ] **P2.1** 📦 Git 提交：无（仅本地验证，不提交）

- [ ] **P2.2** 决策 `AngelscriptActorLibrary.h` 处置方案
  - 若 P2.1 确认 dead code，三选一：
    - **选项 A（推荐）**：整文件删除，加注释到 `Bind_AActor.cpp` 头部说明历史
    - **选项 B**：把 `UFUNCTION()` 改成 `UFUNCTION(BlueprintCallable)` 让反射路径接住，并恢复死注释里的 `ScriptName / NotAngelscriptProperty` meta
    - **选项 C**：把这 27 个函数迁移到 `Bind_AActor.cpp` 用手工 `AActor_.Method("...", lambda)` 注册（与 `Bind_FunctionLibraryMixins.cpp` 的 `RuntimeFloatCurve` 模式一致）
  - 在 Plan 内补一条决策 + 理由
- [ ] **P2.2** 📦 Git 提交：`[Angelscript] Refactor: <decided action> for AngelscriptActorLibrary dead code`

### Phase 3：active 行功能 meta 批量恢复

- [ ] **P3.1** 恢复 `ScriptName` 重载 + `NotAngelscriptProperty`（Component / Actor）
  - 影响文件：`AngelscriptComponentLibrary.h`（6 处 `*Quat` 重载）、`AngelscriptActorLibrary.h`（如 P2.2 选 B/C）
  - 例：`UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetRelativeRotation"))` → `UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetRelativeRotation", NotAngelscriptProperty))`
  - 验证：`SetRelativeRotation` 在 AS 脚本里既能 Quat 又能 Rotator 调用，且不被识别成 angelscript property（`as.DumpEngineState` 的 `BindFunctions.csv` 应有两条 Bind，且 `bIsProperty=false`）
- [ ] **P3.1** 📦 Git 提交：`[FunctionLibraries] Fix: restore NotAngelscriptProperty on Component/Actor Quat overloads`

- [ ] **P3.2** 恢复 `ScriptTrivial`（MathLibrary 子类 + Component）
  - 影响文件：`AngelscriptMathLibrary.h`（FVector / FVector3f / FRotator / FQuat 等子类大量函数）、`AngelscriptComponentLibrary.h`（多数 Get/Set）
  - 用 P1.1 矩阵驱动批量恢复：active 行原本 `Meta = (ScriptName = "SinCos")` → `Meta = (ScriptTrivial, ScriptName = "SinCos")`
  - 验证：`Helper_FunctionSignature.h:317` 的 `bTrivial = HasFuncMeta(NAME_Signature_ScriptTrivial)` 应为 true，落到 `FAngelscriptMethodBind::bTrivial` 字段为 true
- [ ] **P3.2** 📦 Git 提交：`[FunctionLibraries] Fix: restore ScriptTrivial on Math/Component active UFUNCTION lines`

### Phase 4：ScriptMixin 类级 meta 重启可行性评估

- [ ] **P4.1** 审计现有 helper 的"AS 注入路径"，区分三类
  - 当前 8 个 ScriptMixin 关闭的文件**并非**统一走同一条兜底路径。需要先在 `Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md` 里把每个文件分类到三类中之一：
    - **类 1 — 已被 `Bind_*.cpp` 手工 lambda 接管**：例如 `AngelscriptWorldLibrary.h` 已被 `Bind_UWorld.cpp:79-82` 手工注册 `World.GetStreamingLevels() const`，转发到 `UAngelscriptWorldLibrary::GetStreamingLevels(World)`。这类文件**不能**直接重启 ScriptMixin，否则要么被 `Bind_BlueprintCallable.cpp:62-70` 的 `IsScriptDeclarationAlreadyBound` 静默跳过（无价值）、要么因签名细微差异（如 `TArray<ULevelStreaming@>` vs `TArray<ULevelStreaming>`、`const` 推导）注册成重复 overload 引发歧义
    - **类 2 — 走 `BlueprintCallableReflectiveFallback` 反射兜底**：函数没有 native pointer entry，由 `Bind_BlueprintCallable.cpp:74-91` 的 `BindBlueprintCallableReflectiveFallback` 兜底执行。这类文件可以考虑试点 ScriptMixin，但要确认 fallback 路径下生成的 AS 签名跟 mixin 路径的目标签名是否兼容
    - **类 3 — 仅静态命名空间形式可见**：函数没被任何路径绑定为成员方法，AS 脚本里只能写 `Lib::Func(target, ...)`。这类文件重启 ScriptMixin 是**净增益**（对齐 Hazelight）
  - 用 grep 扫描 `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/` 下是否 include 了对应 `FunctionLibraries/*.h`，是分类的关键启发式（命中=类 1 嫌疑大）
  - 用 `as.DumpEngineState` 导出 `BindFunctions.csv` 验证：搜目标类型（如 FVector）下是否已有同名函数；如有，进一步对比签名
  - 输出审计矩阵：`Library | Class | Has Bind_*.cpp manual wrap | Current binding path | Re-enable verdict`
- [ ] **P4.1** 📦 Git 提交：`[Docs] Docs: add ScriptMixin re-enable audit matrix for FunctionLibraries`

- [ ] **P4.2** 试点：单文件重启 ScriptMixin（按 P4.1 审计结果选取类 3 文件）
  - 优先选审计结论为"类 3 — 净增益"的最小文件作为试点，**禁止**选类 1 文件（World/任何被 Bind_*.cpp 手工接管的）
  - 候选评估顺序：HitResultLibrary（11 函数）→ GameplayTagMixinLibrary（10 函数）→ AssetManagerMixinLibrary
  - 取消 `//UCLASS(Meta = (ScriptMixin = "..."))` 注释，删除文件头 `// FunctionLibraries cleanup note ...` 段
  - 跑 `ProductionScriptMixinSignatures` + `FunctionLibraries.*` + 对应 `Bindings.*` 三组测试确认行为
  - 跑 `as.DumpEngineState` 重启前后比对 `BindFunctions.csv` diff，差异必须能逐条解释
- [ ] **P4.2** 📦 Git 提交：`[FunctionLibraries] Refactor: re-enable ScriptMixin on <PilotLibrary>`

- [ ] **P4.3** 批量重启剩余类 3 文件 ScriptMixin
  - 影响文件：按 P4.1 矩阵决定，可能包括 MathLibrary（7 mixin 子类）、Input（3 子类）、GameplayTagContainer 等
  - **明确排除**：`AngelscriptWorldLibrary.h`（类 1）以及任何审计为类 1 的文件
  - 每个文件单独提交，便于回滚
  - 每次重启后跑 `ProductionScriptMixinSignatures` + 对应库的功能测试
- [ ] **P4.3** 📦 Git 提交：每个文件一条，格式 `[FunctionLibraries] Refactor: re-enable ScriptMixin on <Library> library`

- [ ] **P4.4** 类 1 文件的处置：保留手工接管 or 切回 ScriptMixin
  - 对类 1 文件（如 `AngelscriptWorldLibrary.h`）单独评估：手工 lambda 提供的精确签名控制（去指针 `@`、显式 `const`、自定义返回类型映射）是否真的有价值，还是历史包袱
  - 若评估为有价值：在文件头永久标注"由 Bind_*.cpp 接管，不要重启 ScriptMixin"，本计划对此文件的工作收口
  - 若评估为历史包袱：把 `Bind_*.cpp` 的手工 lambda 删除 + 重启 ScriptMixin meta + 修整 helper 函数签名（去掉冗余 `*`/调整 `const`）让反射路径产物等价于原手工签名
- [ ] **P4.4** 📦 Git 提交：每个类 1 文件一条，格式 `[FunctionLibraries] Refactor: <decision> for <Library> manual lambda`

## 验收标准

1. `Plan_FunctionLibrariesCleanup/MetaLossMatrix.md` 完整覆盖 16 个文件 × 4 类 meta，每条都能从 git history 反查证据。
2. `AngelscriptActorLibrary.h` 处置完成（删除 / 全部走反射 / 全部走手工绑定，三选一），`as.DumpEngineState` 的 `BindFunctions.csv` 应消除"声明但不可调用"的歧义。
3. `Helper_FunctionSignature.h` 的 `bTrivial / bNotAngelscriptProperty` 在重要函数上恢复 true（用 `BindDatabase.csv` 抽样验证至少 30 处）。
4. `ProductionScriptMixinSignatures` 测试持续 1/1 PASS（注：可能需要更新该测试的 baseline，因为 ScriptMixin 重启会改变签名注入数量；如需更新 baseline，必须有独立提交并附 diff 说明）。
5. `Angelscript.TestModule.FunctionLibraries.*` 持续 23/23 PASS，且 `Angelscript.TestModule.Bindings.*` 在涉及 Math/Vector/Rotator/Transform/HitResult/Component/Actor 的子项无回归。
6. 全文件 `//UFUNCTION(ScriptCallable...)` 死注释保持为 0（清理成果不能因为本计划倒退）。

## 风险与注意事项

### 风险

1. **重启 ScriptMixin 可能改变方法签名 / 命名空间**
   - 当前 `BlueprintCallableReflectiveFallback` 走的是"无 ScriptMixin meta，但第一参数是目标类型"的回退路径，最终签名应当和 ScriptMixin 等价；但 `ScriptName / ScriptNamespace` 衍生规则在两条路径有微妙差异（参考 `Helper_FunctionSignature.h:152-204` 的 `GetScriptNamespaceForClass`）
   - **缓解**：P4.1 强制要求重启前后导出 `BindFunctions.csv` diff 比对，差异必须能逐条解释才允许进入 P4.2
2. **ActorLibrary 选项 C（手工绑定迁移）会让 `Bind_AActor.cpp` 膨胀显著**
   - `Bind_AActor.cpp` 当前 446+ 行，再加 27 个 lambda 注册可能突破 600 行
   - **缓解**：可拆出 `Bind_AActor_RelativeTransform.cpp` 单独承载，沿用 `Bind_FunctionLibraryMixins.cpp` 拆分模式
3. **`ScriptTrivial` 恢复后影响 trivial inline 优化路径**
   - `Helper_FunctionSignature.h:317` 设的 `bTrivial` 最终落到 `FAngelscriptMethodBind::bTrivial`，参与 StaticJIT 与 BindDatabase 的 inline 决策
   - **缓解**：P3.2 完成后跑一次 `Angelscript.TestModule.StaticJIT.*` 全集，确认无 inline 行为回归

### 已知行为变化

1. **ScriptMixin 重启后，Blueprint 节点面板会减少这些 helper**：当前 `BlueprintCallableReflectiveFallback` 路径让 BP 也能调用 `Vector.Size2D` 等 helper，重启 ScriptMixin 后这些静态函数将仅在 AS 可见
   - **影响文件**：8 个重启 ScriptMixin 的文件（约 60+ 个静态函数）
   - **应对**：在 `Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md` 里逐条标注"是否被任何 BP / Blueprint 资产调用"。如确有 BP 依赖，需要在重启前先把那个函数额外补一条 `BlueprintCallable` 的 wrapper（不挂 ScriptMixin 的独立函数）。
2. **`SetRelativeRotation` 等 Quat 重载的 ScriptName 别名恢复后，AS 脚本旧调用形式可能改变**
   - 旧：`Component.SetRelativeRotationQuat(quat)` 可能可用（如果走反射回退）
   - 新：只能 `Component.SetRelativeRotation(quat)`（与 Rotator 版本重载）
   - **影响文件**：`AngelscriptComponentLibrary.h` 6 处 + `AngelscriptActorLibrary.h`（如选项 B/C）
   - **应对**：P3.1 提交前 `rg "SetRelativeRotationQuat|SetActorRelativeRotationQuat" Script/ Plugins/Angelscript/Source/AngelscriptTest/` 确认无引用即可放行；如有引用一并改名

## 关联文档

- `Documents/Knowledges/ZH/Syntax_Mixin.md` —— 本计划的知识基线，§6"现状反思"对应本计划要解决的问题
- `Documents/Plans/Plan_HazelightScriptFeatureParity.md` —— 上层 parity 计划（新 mixin 库的扩展由它承接）
- `Documents/Plans/Plan_OpportunityIndex.md` —— 完成 P1.1 时同步加入索引
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h` —— `InitFromFunction` 与 `ModifyScriptFunction` 是 meta 落地的最终路径
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_BlueprintType.cpp:1428-1437` —— 反射绑定唯一总入口
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AActor.cpp` —— ActorLibrary 选项 C 的迁移目标
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FunctionLibraryMixins.cpp` —— `RuntimeFloatCurve` 手工绑定模式参考
- 本计划立项时点（2026-04-28）的工作树清理变更 —— 详见下方"已完成基线变更详单"章节，提交后将合并到 git history 作为 `Plan_FunctionLibrariesCleanup` 的执行起点
