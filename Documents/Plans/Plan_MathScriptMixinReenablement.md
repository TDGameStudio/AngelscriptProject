# Math 子类 ScriptMixin 重启专项

## 背景与目标

`AngelscriptMathLibrary.h` 中 8 个 `UCLASS(Meta = (ScriptName = "..."))` 子类（`FVector` / `FVector3f` / `FRotator` / `FRotator3f` / `FQuat` / `FQuat4f` / `FTransform` / `FTransform3f`）当前以 fork-only 形态保留——上方 `//UCLASS(Meta = (ScriptMixin = "..."))` 死注释作为 Hazelight-parity 锚点，但 ScriptMixin meta 全部禁用，所有 helper 函数仅以 namespace 静态调用形式（`FRotator::GetForwardVector(rot)` / `AngelscriptFVectorMixin::Size2D(vec, normal)`）暴露给 AS。

`Plan_FunctionLibrariesCleanup.md` 的 Phase 4 P4.3 试启实测：直接取消注释这 8 处 ScriptMixin meta 后，`Helper_FunctionSignature.h:339` 类级注入路径会**剥除第一参数并改写为目标类型的成员方法形式**，原 namespace 静态调用形式被覆盖，导致 fork 测试 + 用户脚本编译失败：

```
No matching signatures to 'FRotator::GetForwardVector(FRotator)'
Namespace 'AngelscriptFVectorMixin' doesn't exist.
```

P4.3 因此回退所有 8 处启用，并将该工作从"内部 cleanup"重新分类为"用户可见 API 重命名 + 测试/脚本批量迁移"，移交本专项独立推进。

**目标**：完成 fork 内 namespace 静态调用形式 → 实例方法形式的批量迁移，启用 8 处 ScriptMixin meta，让 fork 与 Hazelight 上游在 AS 端调用形式上 100% 对齐。

**为什么不是简单 cleanup**：

- 这是用户脚本可见的 **API 调用形式变更**，不是内部 C++ 重构
- 仓内最少 ~80 个调用点（含部分误命中），仓外用户工程未知数
- 启用 ScriptMixin 是不可逆的原子切换，无法部分迁移
- 需要面向 fork 使用者的 migration guide + breaking change 公告

## 范围与边界

### In Scope

- 仓内所有 fork-only `<Lib>::<Func>(target, ...)` namespace 静态调用形式的精确盘点与改写
- `AngelscriptMathLibrary.h` 8 个 mixin 子类 ScriptMixin meta 启用 + Static 子类不变更
- `ProductionScriptMixinSignatures` baseline 重新生成 + diff 解释
- 向 fork 使用者提供 `Migration_*.md` 迁移指南
- `Syntax_Mixin.md` 与 `ScriptMixinSwitchAudit.md` / `HazelightDiffMatrix.md` 同步更新

### Out of Scope

- 其他 FunctionLibraries 文件（HitResult / Tag / TagContainer / AssetMgr / Input / World）的 ScriptMixin 状态变更——这些已在 P4.2/P4.3/P4.4 完成，本 Plan 不再涉及
- AS 引擎层 mixin 注入机制重写（`Helper_FunctionSignature.h` 行为不动）
- P5.3 已落地的 3 个 Static 子类（`UAngelscriptFQuatStaticLibrary` / `UAngelscriptFRotatorStaticLibrary` / `UAngelscriptFTransformStaticLibrary`）—— 这些承载的 transform 工具函数本就只暴露 namespace 静态形式，与本 Plan 的 mixin 重启不冲突，不在迁移清单内
- `WrapUInt(uint32)` 等 UHT 不支持的 deferred 函数（`Plan_FunctionLibrariesCleanup.md` P5.2 已记录）

### 与既有 Plan 的分工

| Plan | 职责 |
|---|---|
| `Plan_FunctionLibrariesCleanup.md` | C++ header 端文件结构对齐、cleanup note 修整。**已收口** |
| **本 Plan** | AS 端调用形式迁移 + ScriptMixin 启用 + 用户契约公告 |
| `Plan_HazelightScriptFeatureParity.md` | 上层 Hazelight parity 总览，本 Plan 是其 Math 子项的最终闭环 |

## 当前事实状态快照（截至 2026-04-28）

### 8 处禁用 ScriptMixin 锚点

`Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptMathLibrary.h`：

| 行号（约） | 类名 | 当前 UCLASS |
|---:|---|---|
| 299 | `UAngelscriptFVectorMixinLibrary` | `UCLASS()` |
| 385 | `UAngelscriptFVector3fMixinLibrary` | `UCLASS()` |
| 459 | `UAngelscriptFRotatorLibrary` | `UCLASS(Meta = (ScriptName = "FRotator"))` |
| 509 | `UAngelscriptFRotator3fLibrary` | `UCLASS(Meta = (ScriptName = "FRotator3f"))` |
| 559 | `UAngelscriptFQuatLibrary` | `UCLASS(Meta = (ScriptName = "FQuat"))` |
| 629 | `UAngelscriptFQuat4fLibrary` | `UCLASS(Meta = (ScriptName = "FQuat4f"))` |
| 698 | `UAngelscriptFTransformLibrary` | `UCLASS(Meta = (ScriptName = "FTransform"))` |
| 774 | `UAngelscriptFTransform3fLibrary` | `UCLASS(Meta = (ScriptName = "FTransform3f"))` |

每个上方都有 `//UCLASS(Meta = (ScriptMixin = "..."))` 死注释作为 Hazelight-parity 锚点。

### 调用点初步盘点（grep 粗估，需 P1 精筛）

| 文件 | 粗命中数 | 备注 |
|---|---:|---|
| `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptMathFunctionLibraryTests.cpp` | 40 | 含 UE 真静态常量误命中（`FVector::ZeroVector` 等） |
| `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptMathOrientationFunctionLibraryTests.cpp` | 34 | 同上 |
| `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptMathAndPlatformBindingsTests.cpp` | 11 | 同上 |
| `Script/Examples/Core/Example_MovingObject.as` | 1 | 用户脚本示例 |

**粗命中合计 ~86**，预估真实迁移点 60-80（剔除 UE 真静态常量 / 类型构造 `FRotator()` 等）。P1 精筛是否需要迁移每条都要逐条判断。

### P4.3 已知失败用例

P4.3 试启时下列 3 个测试 PASS → FAIL：

```
Angelscript.TestModule.FunctionLibraries.MathOrientationFactoriesAndTransformMutators
Angelscript.TestModule.FunctionLibraries.MathPlanarProjectionAndColorFormatting
Angelscript.TestModule.FunctionLibraries.MathShortestPathAndTransformSemantics
```

完整证据见 `Documents/Plans/Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md` "类 3 — namespace-regression"子节 + `Plan_FunctionLibrariesCleanup.md` P4.3 实施记录。

## 影响范围

### 操作类型定义

本次迁移涉及以下操作（按需组合）：

- **namespace 调用改写（A）**：`<Lib>::<Func>(target, ...args)` → `target.<Func>(...args)`
  - 例 1：`AngelscriptFVectorMixin::Size2D(vec, normal)` → `vec.Size2D(normal)`
  - 例 2：`FRotator::GetForwardVector(rot)` → `rot.GetForwardVector()`
- **真静态调用排除（A')**：`FRotator::Compose(A, B)` 这类 fork 在 Static 子类承载的工具函数 P5.3 后已经分流，**不需要改写**——保留 namespace 形式
- **mixin meta 启用（B）**：`//UCLASS(Meta = (ScriptMixin = "..."))` → 取消注释 + 移除占位 `UCLASS()` 行
- **baseline 重生（C）**：`ProductionScriptMixinSignatures` 重新捕获、独立 commit、附 diff 解释
- **文档同步（D）**：用户面 Migration guide + 内部 audit/Plan 状态同步

### 按目录分组的文件清单（P1 完成后填实）

P1 输出 `Plan_MathScriptMixinReenablement/MigrationMatrix.md` 后回填本节。预计：

`Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/`（1 个）：

- `AngelscriptMathLibrary.h` — 操作 B（8 处）+ 文件头 cleanup note 重写为"已启用，迁移完成"

`Plugins/Angelscript/Source/AngelscriptTest/Bindings/`（3 个，P1 精筛后定数）：

- `AngelscriptMathFunctionLibraryTests.cpp` — 操作 A（~30+ 处）
- `AngelscriptMathOrientationFunctionLibraryTests.cpp` — 操作 A（~25+ 处）
- `AngelscriptMathAndPlatformBindingsTests.cpp` — 操作 A（~10 处）

`Script/Examples/`（1 个或更多，P1 全量盘点后定数）：

- `Script/Examples/Core/Example_MovingObject.as` — 操作 A（数处）

`Documents/`（多份）：

- `Documents/Knowledges/ZH/Migration_AsCallSiteForMathMixin.md` — 新建用户面迁移指南
- `Documents/Knowledges/ZH/Syntax_Mixin.md` — 操作 D（§6.6 四类分类更新）
- `Documents/Plans/Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md` — 操作 D（"类 3 — namespace-regression"标注 ✅ 已闭环）
- `Documents/Plans/Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md` — 操作 D（8 处锚点状态从 "deferred" → "enabled"）

`Plugins/Angelscript/Source/AngelscriptTest/Engine/BindConfig/`（1 个，操作 C）：

- `ProductionScriptMixinSignatures` baseline JSON

## 分阶段执行计划

### Phase 1 — 调用点完整盘点

精确分类每一处 grep 命中，输出迁移矩阵，让 P3 阶段无歧义。

- [ ] **P1.1** 仓内全文盘点 namespace 静态调用形式
  - 用 `rg "(AngelscriptF\w+Mixin|F(?:Vector3?f?|Rotator3?f?|Quat4?f?|Transform3?f?))::\w+\("` 在 `Plugins/Angelscript/` 与 `Script/` 范围全文搜索；不要预先排除 Test 目录或 Examples，所有命中都需盘点
  - 输出原始命中清单（文件 + 行号 + 调用片段）到 `Plan_MathScriptMixinReenablement/RawHits.md`，作为后续精筛的 source of truth
  - 同步盘点 `.md` 文档代码块（用 ` ```angelscript ` 或 ` ```as ` 围栏的）—— 文档示例若过期会向用户传播错误用法
- [ ] **P1.1** 📦 Git 提交：`[Plan/MathScriptMixinReenablement] Docs: enumerate raw namespace-static call hits`

- [ ] **P1.2** 精筛分类：迁移点 vs 非迁移点
  - 每条 RawHits 命中按下表分类：①真 mixin 调用（需改写）/ ②真 UE 静态调用（如 `FQuat::Identity`、`FVector::ZeroVector`，不动）/ ③ Static 子类承载的工具调用（P5.3 后保留 namespace 形式，不动）/ ④构造调用（`FRotator(...)`，不动）
  - 每一条都要给出判定依据（指向具体函数所在 UCLASS 是 mixin 子类还是 Static 子类）
  - 输出 `Plan_MathScriptMixinReenablement/MigrationMatrix.md`，包含每个迁移点的 before/after 文本对（即可直接用于 P3 改写）
  - 该矩阵的总数即 P3 改写工作量基线，必须 review 通过后再启动 P3
- [ ] **P1.2** 📦 Git 提交：`[Plan/MathScriptMixinReenablement] Docs: classify hits and produce migration matrix`

- [ ] **P1.3** 反向查找：是否有 fork 用户脚本调用了 mixin 子类的函数 namespace 静态形式
  - 在仓内 `Script/` 全文 grep `Mixin::` 与 `F(Vector|Rotator|Quat|Transform)(3f|4f)?::\w`
  - 任何用户示例脚本中的命中要单列 `UserScriptHits.md`，因为这些直接影响 release notes 措辞（"用户脚本必须改"还是"仅 fork 内部测试受影响"）
  - 同步检查 `Documents/Knowledges/ZH/` 下的 `.md` 文档代码块是否使用 namespace 静态形式
- [ ] **P1.3** 📦 Git 提交：`[Plan/MathScriptMixinReenablement] Docs: enumerate user-facing call sites`

### Phase 2 — 切换策略决策

在动手大规模改写前先决定迁移策略，避免 P3 改写一半发现策略不可行。

- [ ] **P2.1** 评估"双形式过渡期"可行性
  - 调研：能否让 mixin 子类启用 ScriptMixin 的同时，再补一个 Static 半子类承载相同函数的 namespace 静态形式（与 P5.3 的 transform 工具子类同模式）？
  - 评估代价：会让 fork 比 Hazelight 多出 ~8 个 Static 半子类、~80 个重复 UFUNCTION，对 BindDatabase / ProductionScriptMixinSignatures 数量翻倍影响
  - 评估收益：用户脚本不需要立即迁移，可在 1-2 个 release 后再删除兼容层
  - 输出 `Plan_MathScriptMixinReenablement/MigrationStrategyADR.md`，记录评估过程
- [ ] **P2.1** 📦 Git 提交：`[Plan/MathScriptMixinReenablement] Docs: ADR on dual-form transition feasibility`

- [ ] **P2.2** 决策：破坏性切换 vs 兼容期方案
  - 基于 P1.3 用户脚本命中数 + P2.1 ADR 做决策；推荐默认：**破坏性切换（一次性）**——理由：①该 plugin 当前用户范围有限；②兼容期方案让 fork 长期偏离 Hazelight；③用户改写工作量随迁移指南可控
  - 决策结果写入 `MigrationStrategyADR.md`，并在本 Plan 后续 Phase 的描述中明确执行路径（如选兼容期方案，P3/P4 拆分要重新设计）
  - 决策需 user 明确确认；不可由执行者单方面决定（影响外部用户契约的决策必须有 owner sign-off）
- [ ] **P2.2** 📦 Git 提交：`[Plan/MathScriptMixinReenablement] Docs: finalize migration strategy decision`

### Phase 3 — 调用点批量改写（在 ScriptMixin 仍 disabled 状态下）

按 P1.2 矩阵逐文件改写，每文件单独 commit 便于回滚 + bisect。**关键约束：P3 全部完成时，所有改写后的代码在 ScriptMixin 仍 disabled 状态下也必须 PASS** —— 这要求每条迁移调用点在 `target.Func(...)` 形式下也能解析通过。

需提前在 fork-side AS 引擎检查"实例方法形式"是否在 ScriptMixin disabled 状态也可用。如果 disabled 时 `vec.Size2D(normal)` 不解析（因为 Helper_FunctionSignature.h 不会注入），则 P3 阶段必须串行：①先改 P3.1（一个文件）②先启用对应 ScriptMixin meta（短暂解锁）③测试 PASS ④进 P3.2 —— 这种串行模式风险更高，应在 P2.1 ADR 中明确（可能需要先启 ScriptMixin 再迁移调用点，与本节默认顺序相反）。

- [ ] **P3.0** 解析顺序验证
  - 写一段最小重现：保留所有 ScriptMixin disabled 状态下，写 `FVector V; V.Size2D(N);` 看是否能编译。如不能，则改写顺序必须从"先启 ScriptMixin → 再迁移所有调用点"改为"逐文件启 ScriptMixin → 逐文件改"
  - 这个验证决定 P3 全部子任务的执行顺序
  - 输出结论到 `MigrationStrategyADR.md` 的"执行顺序"补充节
- [ ] **P3.0** 📦 Git 提交：与 P3.1 合并提交（仅一行 ADR 补充，不单独立 commit）

- [ ] **P3.1** 改写 `AngelscriptMathOrientationFunctionLibraryTests.cpp`
  - 按 P1.2 矩阵逐条把 `FRotator::GetForwardVector(rot)` 等改成 `rot.GetForwardVector()`；每个 TEXT(R"(...)" ) 块内的脚本保持缩进与标点风格一致
  - 改写完单文件构建 + 跑该文件涉及的测试集（依 P3.0 决定的顺序，可能需要先启 ScriptMixin 才能验证 PASS）
  - 验证：原 P4.3 失败的 `MathOrientationFactoriesAndTransformMutators` 等用例改后通过
- [ ] **P3.1** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate Math orientation tests to instance-method call form`

- [ ] **P3.2** 改写 `AngelscriptMathFunctionLibraryTests.cpp`
  - 同 P3.1 模式逐条改写；该文件命中点最多（P1.2 后估 30+）
  - 注意区分 fork mixin 子类承载的函数 vs P5.3 Static 子类承载的函数 vs UE 真静态：仅前者需改
  - 验证：`MathPlanarProjectionAndColorFormatting` 等改后通过
- [ ] **P3.2** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate Math function library tests to instance-method call form`

- [ ] **P3.3** 改写 `AngelscriptMathAndPlatformBindingsTests.cpp`
  - 同上模式
- [ ] **P3.3** 📦 Git 提交：`[AngelscriptTest] Refactor: migrate Math platform binding tests to instance-method call form`

- [ ] **P3.4** 改写 `Script/Examples/` 与 `Documents/` 文档代码块
  - P1.3 输出的所有 `Script/Examples/*.as` 命中点逐条改写
  - 同步改 `Documents/Knowledges/ZH/` 下 `Syntax_Mixin.md` 等文档中可能存在的过期代码块
  - 文档代码块改写要保留示例上下文与说明，避免破坏教学叙事
- [ ] **P3.4** 📦 Git 提交：`[Script/Docs] Refactor: migrate Math mixin call sites in examples and knowledge docs`

### Phase 4 — ScriptMixin 启用 + Baseline 重生

P3 调用点全部迁移完成后，启用 8 处 mixin meta 是一次性原子动作。

- [ ] **P4.1** 启用 8 处 ScriptMixin meta + 重写文件头 cleanup note
  - 把 `AngelscriptMathLibrary.h` 8 处 `//UCLASS(Meta = (ScriptMixin = "<Type>"))` 取消注释
  - 删除每个对应的占位 `UCLASS()` 或 `UCLASS(Meta = (ScriptName = "..."))` 行
  - 重写文件头 cleanup parity note：从"deferred 因 namespace-regression"改为"已启用，对齐 Hazelight"
  - 构建必须 0 错误
- [ ] **P4.1** 📦 Git 提交：`[FunctionLibraries] Feat: re-enable ScriptMixin on 8 Math sub-libraries (FVector/FRotator/FQuat/FTransform families)`

- [ ] **P4.2** 重新生成 `ProductionScriptMixinSignatures` baseline
  - 跑 `Angelscript.TestModule.Engine.BindConfig.ProductionScriptMixinSignatures` 看预期 fail（签名数量大幅增加），按测试输出生成新 baseline
  - 新 baseline 与旧 baseline 做 diff，逐类型解释新增了哪些方法（应当全是从 8 个 mixin 子类注入到 FVector/FRotator/FQuat/FTransform 的方法）
  - 把 diff 解释写入 `Plan_MathScriptMixinReenablement/BaselineDiff.md`
  - 独立 commit baseline 更新，commit message 引用 P4.1 commit hash
- [ ] **P4.2** 📦 Git 提交：`[AngelscriptTest] Test: refresh ProductionScriptMixinSignatures baseline for re-enabled Math mixins`

- [ ] **P4.3** 全量回归验证
  - 构建 0 错误
  - `ProductionScriptMixinSignatures` 1/1 PASS（用新 baseline）
  - `Angelscript.TestModule.FunctionLibraries.*` 全集 PASS（特别关注原 P4.3 失败的 3 个用例）
  - `Angelscript.TestModule.Bindings.Math.*` + `Bindings.Vector.*` + `Bindings.Rotator.*` + `Bindings.Transform.*` 全集 PASS
  - 跑 full suite（依 `.cursor/skills/full-test-suite/SKILL.md` 流程），允许有已知 flaky，但 Math 相关无新增 fail
  - 验证结果写入 `Plan_MathScriptMixinReenablement/Phase4Verification.md`
- [ ] **P4.3** 📦 Git 提交：`[Plan/MathScriptMixinReenablement] Docs: record Phase 4 verification evidence`

### Phase 5 — 用户契约公告与文档收口

- [ ] **P5.1** 撰写用户面迁移指南 `Migration_AsCallSiteForMathMixin.md`
  - 落点 `Documents/Knowledges/ZH/Migration_AsCallSiteForMathMixin.md`
  - 内容：①what changed（namespace 形式不再可用，强制改成实例方法形式）/ ②原理（ScriptMixin meta 启用后引擎层的剥参逻辑）/ ③before/after 对照表（按 8 个类型分组，每类列 5-10 个常见调用形式）/ ④快速迁移命令（提供 `rg` + `sed` 风格的批量替换脚本，让用户一键改）/ ⑤fallback：如何在用户工程暂时保留兼容期（指向 P2.1 ADR 中评估的双形式方案）
  - 引导用户从 release tag 或 commit hash 锚定迁移版本
- [ ] **P5.1** 📦 Git 提交：`[Docs] Add migration guide for Math mixin call site changes`

- [ ] **P5.2** 同步内部 audit 文档
  - `Documents/Knowledges/ZH/Syntax_Mixin.md` §6.6 四类分类：把 "类 3 — namespace-regression" 标记为 "✅ 2026-XX-XX 已闭环（迁移完成）" 并指向本 Plan
  - `Documents/Plans/Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md` 把 8 处 Math 锚点状态从 "保留禁用" 改为 "✅ 已启用"
  - `Documents/Plans/Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md` 同步更新 anchors #2-9 状态
  - `AngelscriptMathLibrary.h` 文件头 cleanup parity note：在 P4.1 已重写基础上添加 P5 收口时点 + 引用本 Plan
- [ ] **P5.2** 📦 Git 提交：`[Docs] Sync internal audits to mark Math mixin re-enablement closed`

- [ ] **P5.3** Release notes / ChangeLog 标记 breaking change
  - 在仓内常用的 Release / ChangeLog 落点（`Documents/Guides/TechnicalDebtInventory.md` 或专门 release notes 文件）添加 breaking change 段落
  - 段落明确："Math mixin call site form changed from `Lib::Func(target, ...)` to `target.Func(...)`. See `Migration_AsCallSiteForMathMixin.md`."
  - 在 `Plan_OpportunityIndex.md` 把本 Plan 标记为已完成（或归档）
- [ ] **P5.3** 📦 Git 提交：`[Docs] Mark Math mixin re-enablement breaking change in release notes`

- [ ] **P5.4** Plan 归档（条件：Phase 1-5 全部 ✅ 收口）
  - 按 `Plan.md` 归档规则在文档头补齐归档状态、归档日期、完成判断、结果摘要
  - 把本 Plan 文件从 `Documents/Plans/` 移到 `Documents/Plans/Archives/`
  - 同步更新 `Documents/Plans/Archives/README.md` + `Plan_OpportunityIndex.md`
- [ ] **P5.4** 📦 Git 提交：`[Plan/MathScriptMixinReenablement] Chore: archive completed plan`

## 验收标准

1. `AngelscriptMathLibrary.h` 8 处 `UCLASS(Meta = (ScriptMixin = "..."))` 全部 active；不留 `//UCLASS(...)` 死注释；与 Hazelight 上游 100% 文件结构对齐
2. `ProductionScriptMixinSignatures` 用新 baseline 1/1 PASS；新增签名数量与 P4.2 BaselineDiff.md 一致
3. `Angelscript.TestModule.FunctionLibraries.*` 23/23（或本 Plan 完成时实际数）PASS；P4.3 时 fail 的 3 个用例（`MathOrientationFactoriesAndTransformMutators` / `MathPlanarProjectionAndColorFormatting` / `MathShortestPathAndTransformSemantics`）PASS
4. `Angelscript.TestModule.Bindings.Math.*` 与 Vector/Rotator/Transform/Quat 子集 0 fail
5. `Migration_AsCallSiteForMathMixin.md` 完整覆盖 8 个类型 × at least 5 个调用形式示例；含 sed/rg 批量替换脚本
6. 仓内全文 `rg "(AngelscriptF\w+Mixin|F(?:Vector|Rotator|Quat|Transform)(3f|4f)?)::"` 命中数从 P1.1 基线下降到接近 0（仅保留真 UE 静态常量 + Static 子类工具调用）
7. `Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md` 中 "类 3 — namespace-regression" 子类全部标记 ✅ 闭环；fork 与 Hazelight 在 mixin 子类配置上 100% 等价

## 风险与注意事项

### 风险

1. **P3.0 解析顺序未明确前不能并行改写**
   - 如果 fork AS 引擎在 ScriptMixin disabled 状态下不接受 `vec.Size2D(normal)` 实例方法形式，则 P3.1-P3.4 必须串行执行（先启 ScriptMixin → 再改调用点 → 再下一文件），且改一半时 build/test 处于 broken 状态
   - **缓解**：P3.0 必须最先做，结论决定 P3 子任务执行模型；如串行模式必要则 P3 全部子任务用一次大 commit 而非每文件单独 commit
2. **P2.2 决策若选"兼容期方案"，P3/P4 设计要重做**
   - 双形式过渡需新增 Static 半子类，文件结构会偏离 Hazelight，本 Plan 验收标准 §1 需要修订
   - **缓解**：P2.2 决策必须有 user 明确 sign-off，决策后立即更新本 Plan
3. **用户工程未知数**
   - 仓内迁移完成后，仓外用户工程可能在升级时大面积破坏；release notes 措辞强度直接影响用户体验
   - **缓解**：P5.1 迁移指南必须给出 `rg` + `sed` 一键替换脚本，降低用户改写门槛；P5.3 release notes 用强标记（如 `[BREAKING]` 前缀）
4. **`ProductionScriptMixinSignatures` baseline 大幅扩张**
   - 启用 8 处 mixin meta 会让 4 个核心 UE 类型注入大量新方法（粗估 80+），baseline 文件可能膨胀 30%+
   - **缓解**：P4.2 BaselineDiff.md 必须逐类型解释新增方法的合理性，让 reviewer 能 sanity check 不是误注入
5. **Hot reload 链路潜在副作用**
   - mixin 子类启用 ScriptMixin 后，类生成器的注入路径会变化，可能影响热重载时方法注册的版本链
   - **缓解**：P4.3 全量回归特别跑 `Angelscript.TestModule.HotReload.*` 子集，0 fail 才允许进 P5

### 已知行为变化

1. **AS 端 Math 调用形式从 namespace 静态变为实例方法**（影响所有 fork 用户脚本）
   - 影响范围：8 个 UE 类型（FVector / FVector3f / FRotator / FRotator3f / FQuat / FQuat4f / FTransform / FTransform3f）的所有 mixin helper 调用
   - 例：`AngelscriptFVectorMixin::Size2D(vec, normal)` → `vec.Size2D(normal)`
   - 应对：P5.1 Migration guide
2. **Blueprint 节点面板减少 Math helpers**（如有 BP 调用方）
   - 当前 Math helpers 走 `BlueprintCallable` + 反射兜底，BP 也能调；启用 ScriptMixin 后这些方法仅 AS 可见
   - 影响文件：8 个 mixin 子类的所有 `UFUNCTION(BlueprintCallable, ...)` 静态方法（粗估 80+）
   - 应对：P1.2 矩阵中标注哪些函数有 BP 资产引用（grep BP UAsset 引用），如有需在 P4.1 前补独立 BP wrapper
3. **`ProductionScriptMixinSignatures` baseline 更新（强制）**
   - 影响文件：`ProductionScriptMixinSignatures` baseline JSON
   - 应对：P4.2 独立 commit + diff 解释
4. **fork 测试代码中所有 Math namespace 静态调用形式必须迁移**
   - 影响文件：P1.2 矩阵列出的所有测试 `.cpp`（粗估 3-4 个文件、~70 处迁移点）
   - 应对：P3.1-P3.3

## 关联文档

- `Documents/Plans/Plan_FunctionLibrariesCleanup.md` —— 上游 Plan，P4.3 deferred 的来源
- `Documents/Plans/Plan_FunctionLibrariesCleanup/ScriptMixinSwitchAudit.md` —— "类 3 — namespace-regression" 子类记录
- `Documents/Plans/Plan_FunctionLibrariesCleanup/HazelightDiffMatrix.md` —— 8 处锚点 anchors #2-9 当前状态
- `Documents/Knowledges/ZH/Syntax_Mixin.md` —— §6.6 四类分类，本 Plan 收口后更新
- `Documents/Plans/Plan_HazelightScriptFeatureParity.md` —— 上层 parity 计划
- `Documents/Plans/Plan_OpportunityIndex.md` —— Plan 索引
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Helper_FunctionSignature.h:339` —— 类级注入路径，namespace 形式被覆盖的代码原点
- `Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptMathLibrary.h` —— 8 处锚点所在文件
- `.cursor/skills/full-test-suite/SKILL.md` —— P4.3 全量验证使用的 full suite 流程

## 完成判断

本 Plan 在 P5.4 归档时记录最终状态。完成的判断标准：

- 验收标准 §1-7 全部 ✅
- `Migration_AsCallSiteForMathMixin.md` 已发布且至少 1 周（让用户有反馈窗口）
- 用户反馈（如有）在归档摘要中列出处置结论
