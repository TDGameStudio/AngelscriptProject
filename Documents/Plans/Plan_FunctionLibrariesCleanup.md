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
| `Documents/Plans/Plan_FunctionLibrariesCleanup/MetaLossMatrix.md` | 新建（audit deliverable） | +约 200 | P1.1 产出。15 文件 × 7 类 meta 损失矩阵；核心结论：130 处真实损失集中在 4 个文件（Math 113 / Component 13 / Actor 11 / Script 3），其余 11 文件死注释纯属噪音 |
| `Documents/Plans/Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md` | 新建（audit deliverable） | +约 200 | P4.1 产出。16 处锚点四类分类（类 1=1 / 类 1.5=3 / 类 2=0 / 类 3=12）；P4.2 试点首选 HitResult；新发现"类 1.5"UHT 重载消歧 helper 模式不阻塞 ScriptMixin 重启 |
| `Documents/Plans/Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md` | 新建（audit deliverable） | +约 280 | P5.1 产出。20 文件 × 5 维度对照矩阵；核心结论：缺 19 函数 + 3 子类 + 0 可清理锚点（100% parity gap）；为 16 个缺漏函数提取完整 Hazelight 签名作 P5.2 实施模板 |

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
- **Hazelight 上游 helper 补全**（Phase 5 引入）：照 Hazelight 上游 `AngelscriptCode/Public/FunctionLibraries/*.h` 把 fork 缺失的整个 `UFUNCTION` 函数补回来（含完整 Meta，按 fork 惯例 `ScriptCallable → BlueprintCallable` 转换）
- **Hazelight 上游 mixin 子类补全**（Phase 5 引入）：补 fork 完全没写过的 `UCLASS(meta = (ScriptMixin = "..."))` 子类（如 MathLibrary 已知缺 3 个 active UCLASS）
- **锚点注释删除**（Phase 5 引入）：基于 Hazelight diff 矩阵确认非 parity gap 后，删除 fork 内保留的 `//UCLASS(Meta = (ScriptMixin = "..."))` 历史草稿、过时文件头 parity note、过时函数级注释

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

- [x] **P1.1** 生成"active 行 vs 死注释 meta 损失矩阵" ✅ 2026-04-28 完成
  - 工作树清理已删死注释，但功能差距没有可执行清单。需要从 git history 取出原文件内容，逐函数比对：每个函数原死注释里有哪些 meta、active 行有哪些、差额就是"丢失功能"
  - 立项时点的"清理前基线"在 `git stash` 或本计划提交前的 `HEAD`（即立项时刻 working tree 已 modified 状态的反向 diff）；同时配合更早的"`ScriptCallable` → `BlueprintCallable` 替换提交"（用 `git log --all -- Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptMathLibrary.h --diff-filter=M -p | head -200` 定位），做三方比对
  - 输出 `Documents/Plans/Plan_FunctionLibrariesCleanup/MetaLossMatrix.md`，按 16 个文件 × 4 类 meta（`ScriptTrivial` / `NotAngelscriptProperty` / `ScriptName` 重载 / `ScriptCallable`）列表，每行写文件名 + 函数名 + 当前 active meta + 应有 meta + 差额
  - 同步在 `Plan_OpportunityIndex.md` 三、缺陷重构章节添加本 Plan 索引
  - **实施记录**：[`Plan_FunctionLibrariesCleanup/MetaLossMatrix.md`](./Plan_FunctionLibrariesCleanup/MetaLossMatrix.md) 已完成，覆盖 15 个修改过的文件 × 7 类 meta。**核心结论**：①真实 meta 损失共 130 处，②仅集中在 4 个文件（Math 113 / Component 13 / Actor 11 / Script 3），③其余 11 个文件死注释纯属噪音、无 active 行损失。详细分布：`ScriptTrivial 94 + ScriptNoDiscard 35 + NotAngelscriptProperty 7 + ScriptName 重载 4`
- [x] **P1.1** 📦 Git 提交：合并到 P4.1 / P5.1 audit deliverable 单一提交（见 P5.1 提交说明）

### Phase 2：ActorLibrary dead code 决策

- [x] **P2.1** 验证 `AngelscriptActorLibrary` 是否真的是 dead code ✅ 2026-04-28 完成
  - 用 `Tools\RunBuild.ps1 -SerializeByEngine` + 在 `UAngelscriptActorLibrary::SetActorRelativeLocation` 的实现里塞一行 `UE_LOG(LogTemp, Fatal, ...)`，跑 `Angelscript.TestModule.Actor.*`，确认这条 log 永远不触发即为 dead code
  - 备选验证路径：用 `as.DumpEngineState` 生成 `BindDatabase.csv`，搜 `UAngelscriptActorLibrary` 是否出现在 `ClassName` 列；不出现就是 dead code
  - 验证完成后回滚验证用的 Fatal log 修改
  - **实施记录**：采用静态证据链验证（无需运行时 Fatal log），4 条证据全部命中：①全仓库零 .cpp 调用（仅 .h + 2 处文档）；②`Bind_BlueprintType.cpp:1428-1437` 反射五分支对裸 `UFUNCTION()` 全部 miss；③`AngelscriptTest/` 模块零引用；④`Script/` 与测试 AS 代码对 `SetActorRotation/SetActorRelativeRotation/AddActor*Rotation/SetActorQuat` 全部零调用。**结论**：30 个函数中实际有效函数为 0（27 个真冗余 + 3 个 fork 独有 BlueprintCallable 但与 UE native 同名 → 被 `IsScriptDeclarationAlreadyBound` 拦截）；**但其中 6 个 FQuat 重载 + 1 个 SetActorLocationAdvanced + 2 个 EDITOR utility 是 fork 独有签名**（UE native AActor BlueprintCallable surface 不覆盖），属真实 fork 价值
- [x] **P2.1** 📦 Git 提交：无（仅本地验证，不提交）

- [x] **P2.2** 决策 `AngelscriptActorLibrary.h` 处置方案 ✅ 2026-04-28 完成
  - 若 P2.1 确认 dead code，三选一：
    - **选项 A（推荐）**：整文件删除，加注释到 `Bind_AActor.cpp` 头部说明历史
    - **选项 B**：把 `UFUNCTION()` 改成 `UFUNCTION(BlueprintCallable)` 让反射路径接住，并恢复死注释里的 `ScriptName / NotAngelscriptProperty` meta
    - **选项 C**：把这 27 个函数迁移到 `Bind_AActor.cpp` 用手工 `AActor_.Method("...", lambda)` 注册（与 `Bind_FunctionLibraryMixins.cpp` 的 `RuntimeFloatCurve` 模式一致）
  - 在 Plan 内补一条决策 + 理由
  - **决策**：选项 B'（混合方案）—— 仅保留 9 个 fork 独有签名（6 FQuat + `SetActorLocationAdvanced` + 2 EDITOR utility）并升级为 `UFUNCTION(BlueprintCallable, Meta = (ScriptName=..., NotAngelscriptProperty))` 形态；删除 21 个 UE native AActor 已覆盖的真冗余函数。**理由**：选项 A 整删会丢失 6 个 FQuat 重载未来兼容性（Hazelight 上游也保留这些）；选项 B 全保留会让 21 个真冗余被 `IsScriptDeclarationAlreadyBound` 静默拦截，制造无意义 fallback noise；选项 C 手工迁移成本远高于价值。选项 B' 在"恢复 fork 独有功能"和"清理 dead code"之间取得最佳平衡
  - **实施细节**：文件从 169 行缩到 81 行；6 个 FQuat 重载每个都带 `ScriptName="SetActor*Rotation"` 别名 + `NotAngelscriptProperty`，与 UE native FRotator 重载形成 AS 重载；`SetActorQuat` 按 Hazelight 上游设计独立 ScriptName + `ScriptTrivial`；`SetActorLocationAdvanced` 带 sweep+hit+teleport 完整签名；2 EDITOR utility 保持 `WITH_EDITOR` 守护
  - **验证**：构建 0 错误（180s）；`ProductionScriptMixinSignatures` 1/1 PASS（mixin 签名无 regression）；`FunctionLibraries.*` 23/23 PASS；`Actor.*` 24/24 PASS。零回归
- [x] **P2.2** 📦 Git 提交：`[FunctionLibraries] Refactor: trim AngelscriptActorLibrary to 9 fork-distinctive surfaces (6 FQuat + sweep + 2 editor)`

### Phase 3：active 行功能 meta 批量恢复

- [x] **P3.1** 恢复 `ScriptName` 重载 + `NotAngelscriptProperty`（Component / Script，Actor 已在 P2.2 合并处理）✅ 2026-04-28 完成
  - 影响文件：`AngelscriptComponentLibrary.h`（6 处 `*Quat` 重载）、`AngelscriptActorLibrary.h`（如 P2.2 选 B/C）
  - 例：`UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetRelativeRotation"))` → `UFUNCTION(BlueprintCallable, Meta = (ScriptName = "SetRelativeRotation", NotAngelscriptProperty))`
  - 验证：`SetRelativeRotation` 在 AS 脚本里既能 Quat 又能 Rotator 调用，且不被识别成 angelscript property（`as.DumpEngineState` 的 `BindFunctions.csv` 应有两条 Bind，且 `bIsProperty=false`）
  - **实施记录**：依 [`MetaLossMatrix.md`](./Plan_FunctionLibrariesCleanup/MetaLossMatrix.md) §1 实际数据修正：ComponentLibrary 实际只有 2 处 NotAngelscriptProperty 损失（原计划"6 处 *Quat 重载"是估算偏差，实际 6 处中 2 处缺 NotAngelscriptProperty、其余已携带），ActorLibrary 4+2 已在 P2.2 选项 B' 合并完成。本任务实际处理 5 处：
    - `AngelscriptComponentLibrary.h` 2 处：`SetRelativeRotationQuat` / `SetWorldRotationQuat` 在 `Meta = (ScriptName = ...)` 上追加 `NotAngelscriptProperty`
    - `AngelscriptScriptLibrary.h` 3 处：`GetNameOfGlobalVariableBeingInitialized` / `GetNamespaceOfGlobalVariableBeingInitialized` / `GetModuleNameOfGlobalVariableBeingInitialized` 由裸 `UFUNCTION(BlueprintCallable)` 升级为 `UFUNCTION(BlueprintCallable, Meta = (NotAngelscriptProperty))`
  - **验证**：构建 0 错误（53s）；`ProductionScriptMixinSignatures` 1/1 PASS；`FunctionLibraries.*` 23/23 PASS。零回归
- [x] **P3.1** 📦 Git 提交：`[FunctionLibraries] Fix: restore NotAngelscriptProperty on Component Quat overloads and Script global init helpers`

- [ ] **P3.2** 恢复 `ScriptTrivial`（MathLibrary 子类 + Component）
  - 影响文件：`AngelscriptMathLibrary.h`（FVector / FVector3f / FRotator / FQuat 等子类大量函数）、`AngelscriptComponentLibrary.h`（多数 Get/Set）
  - 用 P1.1 矩阵驱动批量恢复：active 行原本 `Meta = (ScriptName = "SinCos")` → `Meta = (ScriptTrivial, ScriptName = "SinCos")`
  - 验证：`Helper_FunctionSignature.h:317` 的 `bTrivial = HasFuncMeta(NAME_Signature_ScriptTrivial)` 应为 true，落到 `FAngelscriptMethodBind::bTrivial` 字段为 true
- [ ] **P3.2** 📦 Git 提交：`[FunctionLibraries] Fix: restore ScriptTrivial on Math/Component active UFUNCTION lines`

### Phase 4：ScriptMixin 类级 meta 重启可行性评估

- [x] **P4.1** 审计现有 helper 的"AS 注入路径"，区分三类 ✅ 2026-04-28 完成
  - 当前 8 个 ScriptMixin 关闭的文件**并非**统一走同一条兜底路径。需要先在 `Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md` 里把每个文件分类到三类中之一：
    - **类 1 — 已被 `Bind_*.cpp` 手工 lambda 接管**：例如 `AngelscriptWorldLibrary.h` 已被 `Bind_UWorld.cpp:79-82` 手工注册 `World.GetStreamingLevels() const`，转发到 `UAngelscriptWorldLibrary::GetStreamingLevels(World)`。这类文件**不能**直接重启 ScriptMixin，否则要么被 `Bind_BlueprintCallable.cpp:62-70` 的 `IsScriptDeclarationAlreadyBound` 静默跳过（无价值）、要么因签名细微差异（如 `TArray<ULevelStreaming@>` vs `TArray<ULevelStreaming>`、`const` 推导）注册成重复 overload 引发歧义
    - **类 2 — 走 `BlueprintCallableReflectiveFallback` 反射兜底**：函数没有 native pointer entry，由 `Bind_BlueprintCallable.cpp:74-91` 的 `BindBlueprintCallableReflectiveFallback` 兜底执行。这类文件可以考虑试点 ScriptMixin，但要确认 fallback 路径下生成的 AS 签名跟 mixin 路径的目标签名是否兼容
    - **类 3 — 仅静态命名空间形式可见**：函数没被任何路径绑定为成员方法，AS 脚本里只能写 `Lib::Func(target, ...)`。这类文件重启 ScriptMixin 是**净增益**（对齐 Hazelight）
  - 用 grep 扫描 `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/` 下是否 include 了对应 `FunctionLibraries/*.h`，是分类的关键启发式（命中=类 1 嫌疑大）
  - 用 `as.DumpEngineState` 导出 `BindFunctions.csv` 验证：搜目标类型（如 FVector）下是否已有同名函数；如有，进一步对比签名
  - 输出审计矩阵：`Library | Class | Has Bind_*.cpp manual wrap | Current binding path | Re-enable verdict`
  - **实施记录**：[`Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md`](./Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md) 已完成。**核心结论**：①16 处锚点最终分入"四类"——类 1（手工接管，1 处：World）、**类 1.5**（UHT 重载消歧 helper、可与 ScriptMixin 共存，3 处：Input 三子类）、**类 2 实例为 0**（5 个候选文件函数全是 inline 实现、无 sidecar `.cpp`）、类 3（净增益，12 处：Math 8 + Hit 1 + TagContainer 1 + Tag 1 + AssetMgr 1）；②可重启锚点 15 处、禁止重启 1 处；③P4.2 试点首选 `AngelscriptHitResultLibrary.h`（单 mixin 子类 + active 行 ScriptTrivial 已齐全 + Hazelight 上游一致）。新发现"类 1.5"是 fork 独有的 UHT 重载消歧 helper 模式，不阻塞 ScriptMixin 重启
- [x] **P4.1** 📦 Git 提交：合并到 P1.1 / P5.1 audit deliverable 单一提交（见 P5.1 提交说明）

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

### Phase 5：Hazelight 上游对比与 helper 漏改修复 + 锚点注释清理

> **P5.1 完成后已修正**：以下立项 sanity check 段落保留作历史叙事，但实际数据已被 [`Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md`](./Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md) 全面取代。**正确数据**：MathLibrary `UFUNCTION` fork=87 而非 90、缺 16 函数（不是 13）；其他 19 个文件中**仅 3 个有 gap**（HitResult 缺 1 / TagContainer 缺 1 / AssetMgr 缺 1）；其余 16 个文件函数数完全 parity。后续 P5.2 / P5.3 / P5.4 一律以 audit matrix 为准。

立项时已快速 sanity check（路径 `K:\UnrealEngine\UEAS\Engine\Plugins\Angelscript\Source\AngelscriptCode\Public\FunctionLibraries\`，来自 `AgentConfig.ini` 的 `References.HazelightAngelscriptEngineRoot`）：

- **文件清单**：fork 与 Hazelight 都是 **20 个 `.h`，文件层面 100% 一致**，无新增/缺失文件。Hazelight 用 `AngelscriptCode` 模块、fork 用 `AngelscriptRuntime` 模块，仅模块名差异不算 parity gap。
- **`AngelscriptMathLibrary.h`**：Hazelight 103 个 `UFUNCTION` + 12 个 active `UCLASS` mixin 子类；fork **90 + 9**。**缺 13 个 helper 函数 + 3 个 mixin 子类**，是本 Phase 最大的补漏目标。（P5.1 修正：实际 fork=87、缺 16 函数）
- **`AngelscriptActorLibrary.h`**：函数数量一致（30 vs 30），但 Hazelight 用 `UFUNCTION(ScriptCallable, ...)`、fork 是裸 `UFUNCTION()`。这正是 Phase 2 dead code 嫌疑的直接来源——Hazelight 上游可作为 P2.2 选项 B/C 的改造模板。
- **其他 18 个文件**：尚未抽样，由 P5.1 完成全量对照。（P5.1 完成：18 文件中仅 3 文件各缺 1 函数，其余 15 文件 100% parity）

注意：`AngelscriptCode/Private/FunctionLibraries/` 也存在对应实现 `.cpp`，三方对照时需一并取。

具体任务：

- [x] **P5.1** 生成 Hazelight 上游 vs fork 完整对照矩阵 ✅ 2026-04-28 完成
  - 当前已知 MathLibrary 缺 13 函数 + 3 mixin 子类、ActorLibrary 30/30 函数但全部裸 `UFUNCTION()`，但其他 18 个文件的 parity gap 没有数据。需要扫描全部 20 文件，沉淀成可执行的"补漏 + 清理"清单
  - 按 20 文件 × 5 维度建表：①文件存在性（已确认 100% 一致，仅作 baseline）；②active `UCLASS` 列表（含 ScriptMixin meta）；③active `UFUNCTION` 列表（含函数名 + 完整 Meta）；④函数体差异（参数 / 返回值 / 实现行数变化）；⑤Hazelight 上游有但 fork 注释掉/已删除的内容（dead removal 候选）
  - 工具建议：先用 `Compare-Object` 比对两端文件名 → `Get-ChildItem ... | Select-String "^UFUNCTION|^UCLASS"` 抽签名 → 不一致条目再用 `git diff --no-index <haze>/X.h <ours>/X.h` 看上下文
  - 输出 `Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md`，矩阵结尾必须给出三个汇总数：①缺函数总数、②缺 mixin 子类总数、③可清理锚点注释数
  - **实施记录**：[`Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md`](./Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md) 已完成。**核心结论**：①缺函数 19 处（Math 16 + Hit 1 + TagContainer 1 + AssetMgr 1）——比立项时估算的 13 多 6 处，实际 active UFUNCTION 数 fork=87 而非 90、Haze=103；②缺 mixin 子类 3 处（Math 的 `UAngelscriptFQuatStaticLibrary` / `UAngelscriptFRotatorStaticLibrary` / `UAngelscriptFTransformStaticLibrary`）；③**可清理锚点为 0**——fork 16 处 `//UCLASS(Meta = (ScriptMixin = "..."))` 锚点 100% 在 Hazelight 上游为 active，全部是真 parity gap，P5.4 工作转化为"修整 6 处 cleanup parity note 描述准确性"。已为 16 个缺漏函数提取完整 Hazelight 签名作 P5.2 实施模板
- [x] **P5.1** 📦 Git 提交：单次提交合并 P1.1 / P4.1 / P5.1 三份 audit deliverable，commit message `[Docs] Plans: add FunctionLibraries cleanup audit matrices (meta loss / Hazelight diff / ScriptMixin switch)`

- [ ] **P5.2** 按 P5.1 矩阵补 helper 函数（共 19 个，分布在 4 个文件）
  - **修正后的**优先级顺序（依 [`HazelightDiffMatrix.md`](./Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md) §2）：MathLibrary（16 缺漏，最大）→ HitResultLibrary（缺 `SetPhysMaterial`）→ GameplayTagContainerMixinLibrary（缺 `AppendTags`）→ UAssetManagerMixinLibrary（缺 `ScanPathForPrimaryAssets`）
  - **MathLibrary 16 个缺漏函数**已在矩阵中提取完整签名作模板：4 组 transform 工具三重载（`ApplyDelta` / `ApplyRelative` / `GetDelta` / `GetRelative` × FQuat / FRotator / FTransform = 12 函数）+ 4 个单函数（`GetSafeNormal2D` / `MakeAngularVelocityFromDeltaRotation` / `MakeDeltaRotationFromAngularVelocity` / `WrapUInt`）
  - 每个补回来的函数必须保持 Hazelight 上游签名一致（参数顺序 / 返回类型 / Meta 完整携带）；Meta 涉及 `ScriptCallable` 时按 fork 当前惯例转换为 `BlueprintCallable` + 保留其他 Meta（参考 §6.5 已落地变更）；保留 `ScriptTrivial / NotAngelscriptProperty / ScriptName 重载` 等关键功能性 Meta（即同步完成 Phase 3 的 active 行恢复目标，避免重复 churn）
  - 跑 `Bindings.Math.*` + `Bindings.Vector.*` + `Bindings.Rotator.*` + `Bindings.Transform.*` + `ProductionScriptMixinSignatures` 做行为验证；若新函数引入新签名，`ProductionScriptMixinSignatures` baseline 可能需要按独立提交更新
- [ ] **P5.2** 📦 Git 提交：每个文件一条（共 4 个），格式 `[FunctionLibraries] Feat: restore missing helpers from Hazelight upstream <Library>`

- [ ] **P5.3** 补缺失的 mixin 子类（MathLibrary 缺 3 个 active UCLASS，已在 P5.1 矩阵确认）
  - **缺漏的 3 个子类**（依 [`HazelightDiffMatrix.md`](./Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md) §2.1.1）：`UAngelscriptFQuatStaticLibrary`（`ScriptName = "FQuat"`）/ `UAngelscriptFRotatorStaticLibrary`（`ScriptName = "FRotator"`）/ `UAngelscriptFTransformStaticLibrary`（`ScriptName = "FTransform"`）—— 全部是 fork 完全没写过的"主子类承载 mixin 方法 + Static 子类承载静态构造/常量/工具"双子类模式中的 Static 半部
  - 补回的 `UCLASS(Meta = (ScriptName = "..."))` 子类直接以 **enabled 状态**合入（不走"先注释 → 后重启"的两步流程，跟 Phase 4 的"重启已存在锚点"是不同操作）
  - 跑 `Angelscript.TestModule.Engine.BindConfig.ProductionScriptMixinSignatures` 必须重新生成 baseline 并独立提交，附带 diff 解释
- [ ] **P5.3** 📦 Git 提交：`[FunctionLibraries] Feat: restore missing ScriptMixin subclasses from Hazelight upstream` + 必要时另起 baseline 更新提交

- [ ] **P5.4** 锚点注释清理 → **修整 cleanup parity note 描述准确性**
  - **P5.1 矩阵关键修正**：fork 16 处 `//UCLASS(Meta = (ScriptMixin = "..."))` 锚点 **100% 在 Hazelight 上游为 active ScriptMixin**（详见 [`HazelightDiffMatrix.md`](./Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md) §3 全景表）—— 全部是真 parity gap、**不可清理**。原计划中的"规则 A 删锚点"实例数为 0
  - 工作转化为：**修整 6 处 cleanup parity note 描述**——当前 fork 在 6 个文件头的 cleanup parity note 笼统说"`BlueprintCallableReflectiveFallback` 兜底"，但 P4.1 已确认 fork 5 个候选文件 native pointer 都有效、不会走 ReflectiveFallback。`AngelscriptWorldLibrary.h` 的 note 已在 `cc764db` 修正为"`Bind_UWorld.cpp` 手工接管"，无需再动；剩余 6 处需修正为"仅静态命名空间形式可见 + 待 P4.x 重启"或类似准确描述
  - **执行前置条件**：必须等 P4.x 全部完成（试点 + 批量重启 + 类 1 决策），note 描述应反映最终的 ScriptMixin 状态而非中间态；避免"刚改完 note 又因为重启再变"
  - 涉及文件：`AngelscriptHitResultLibrary.h` / `GameplayTagMixinLibrary.h` / `GameplayTagContainerMixinLibrary.h` / `InputComponentScriptMixinLibrary.h` / `UAssetManagerMixinLibrary.h` / `AngelscriptMathLibrary.h`（如 P4.x 后 Math 文件头新增 note）
  - 每条改写都要引用 P4.1 / P5.1 矩阵中对应行号作为依据
- [ ] **P5.4** 📦 Git 提交：`[FunctionLibraries] Chore: rewrite cleanup parity notes per P4.1/P5.1 audit findings`

## 验收标准

1. `Plan_FunctionLibrariesCleanup/MetaLossMatrix.md` 完整覆盖 20 个文件 × 4 类 meta，每条都能从 git history 反查证据。
2. `AngelscriptActorLibrary.h` 处置完成（删除 / 全部走反射 / 全部走手工绑定，三选一），`as.DumpEngineState` 的 `BindFunctions.csv` 应消除"声明但不可调用"的歧义。
3. `Helper_FunctionSignature.h` 的 `bTrivial / bNotAngelscriptProperty` 在重要函数上恢复 true（用 `BindDatabase.csv` 抽样验证至少 30 处）。
4. `ProductionScriptMixinSignatures` 测试持续 1/1 PASS（注：Phase 4 ScriptMixin 重启与 Phase 5 mixin 子类补全都会改变签名注入数量；如需更新 baseline，必须有独立提交并附 diff 说明）。
5. `Angelscript.TestModule.FunctionLibraries.*` 持续 23/23 PASS，且 `Angelscript.TestModule.Bindings.*` 在涉及 Math/Vector/Rotator/Transform/HitResult/Component/Actor 的子项无回归。
6. 全文件 `//UFUNCTION(ScriptCallable...)` 死注释保持为 0（清理成果不能因为本计划倒退）。
7. `Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md` 完整覆盖 20 个文件 × 5 维度，结尾有缺函数总数 / 缺 mixin 子类总数 / 可清理锚点注释数三个明确汇总。
8. Phase 5 收口后，`AngelscriptMathLibrary.h` 已知缺漏（13 函数 + 3 mixin 子类）必须 100% 补全，或在 `HazelightDiffMatrix.md` 中明确标注"不补回的理由"（如 Hazelight 引擎侧依赖、UE 5.7 已不需要等）；其他文件按 P5.1 矩阵给出的缺漏数闭环或显式 deferred。
9. Phase 5 注释清理（P5.4）后，文件头 cleanup parity note 数量应从当前 7 处降低；保留的每一处都必须能在 `HazelightDiffMatrix.md` 找到"Hazelight 也是 ScriptMixin / fork 之所以不开是因为 Bind_*.cpp 手工接管"的具体证据。

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
4. **Hazelight 上游补漏可能引入引擎侧依赖**
   - Hazelight 部分 helper 实现可能依赖引擎补丁（例如对 `UWorld / UCurveFloat` 的私有访问、UE 5.7 之前的 API 形态等），照搬到 fork 时可能编译失败
   - **缓解**：P5.2 / P5.3 每补一个函数后立即 `RunBuild.ps1`；编译失败时**不要**绕过引擎依赖（如改用 reflection / 加 friend），先回退该函数并在 `HazelightDiffMatrix.md` 标注"deferred — needs engine patch X"
5. **Hazelight 路径不可访问会阻塞 Phase 5 全部任务**
   - `K:\UnrealEngine\UEAS` 是本地配置路径，CI / 其他 worktree 可能没有
   - **缓解**：P5.1 矩阵一旦合入主干，后续 P5.2-P5.4 无需再访问 Hazelight 源码（矩阵自身就是 source of truth）；Phase 5 的预备工作必须在配置了 `HazelightAngelscriptEngineRoot` 的环境完成

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
