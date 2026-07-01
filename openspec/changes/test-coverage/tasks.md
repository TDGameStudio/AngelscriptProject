# Tasks — test-coverage

> 本 change "承前启后"：§1–§3 是**已完成的记录（承前）**；§4–§6 是**安排给之后补充的工作（启后）**，未勾选即为待办，可在后续会话继续执行。
> 验证命令统一只用：`Tools\RunTests.ps1`（按 Automation 前缀过滤）。

## 1. 扫描与梳理（已完成）

- [x] 1.1 扫描 `AngelscriptTest/Coverage/*.cpp`，提取每个文件的 Automation 前缀与 `TEST_METHOD` 数量
- [x] 1.2 对照 `Documents/Coverage/` 历史文档，识别过时/伪缺口声明

## 2. 撰写统一矩阵（已完成）

- [x] 2.1 撰写 `coverage-matrix.md`：按分类列出已实现覆盖（统一列结构与图例）
- [x] 2.2 撰写 `coverage-gaps.md`：待覆盖/待增强 + fork 不支持边界 + 历史误标纠偏
- [x] 2.3 撰写 `specs/as-test-coverage/spec.md`：确立 OpenSpec 为覆盖记录 SoT
- [x] 2.4 按 AS 类型/功能将矩阵拆分为 `matrices/` 下 18 个领域矩阵（UStruct/容器/类型/对象引用各独立，物理/输入/Widget/网络/定时器等功能系统各自成文）；`coverage-matrix.md` 收敛为主索引（图例/列说明/领域索引/全局汇总）。
- [x] 2.5 将 18 个领域矩阵全部展开为**场景级设计规格**：每行一个可验证场景，标注状态 + 断言该场景的 `TEST_METHOD`，使矩阵可指导测试实现；过程中按代码审计校准真实计数（当前 89 文件 / 1010 方法），并关闭原 G3/G4 伪缺口。

## 3. 校验记录（已完成）

- [x] 3.1 校验矩阵汇总数字（89 文件 / 90 主题 / ~980 方法）与扫描结果一致
- [x] 3.2 审计推翻伪缺口（GC 循环引用、动态材质参数实际已覆盖），同步修正矩阵状态

---

## 4. 文档退役 cutover（已完成，先改指后删除）

> 目标：`Documents/Coverage/` 退役，引用统一改指向本 OpenSpec 记录，无悬空引用。

- [x] 4.1 将 38 个 Coverage 测试 `.cpp` 头注释中的 `Documents/Coverage/Coverage_*.md` 引用，统一改指 `OpenSpec: test-coverage/coverage-matrix.md`
- [x] 4.2 更新 `.agents/skills/_angelscript-test-guide/SKILL.md` 与 `SKILL_ZH.md` 中对 `Documents/Coverage/` 的引用
- [x] 4.3 确认无其它文档引用后，删除 `Documents/Coverage/` 整目录（80 个文件）
- [x] 4.4 `git grep "Documents/Coverage"` 无残留（仅 openspec 记录内说明性提及）

## 5. 覆盖缺口补充（待办，低/中优先级，TDD）

> 详见 `coverage-gaps.md §1`。均非阻塞项；按需逐个执行，新增测试遵循 `_angelscript-test-guide`。

- [x] 5.1 (G1) 扩充 `AngelscriptCoverageAnimInstanceTests.cpp`：新增 `AnimInstanceQueryFunctionsExecute`，通过 transient `USkeletalMeshComponent` outer 实例化 AS `UAnimInstance`，反射执行 owner / montage / curve 查询并断言 asset-free 运行期状态。验证：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.Animation.AnimInstance"` → `3/3`
- [x] 5.2 (G2) 扩充 `AngelscriptCoverageSaveGameTests.cpp`：嵌套 struct / 数组字段 save→load 往返断言。验证：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.SaveGame"` → `4/4`
- [x] 5.3 (G3) 审计 `TArray<TWeakObjectPtr<T>>` 元素往返/失效 → **已覆盖**（`WeakObjectPtrArrayContainer` / `HandlesTests::WeakObjectPtrArrayContainerAndReassignment`），关闭
- [x] 5.4 (G4) 审计 `TObjectPtr<T>` 显式属性声明/读写 → **已覆盖**（`HandleTests::TObjectPtrRouting` / `HandlesTests::UObjectNewObjectTObjectPtrAndSubclassReferences`），关闭
- [x] 5.5 (G5) 实测 `AngelscriptCoverageTArrayAdvancedTests.cpp` 中 TArray 越界 `[]` 访问运行期语义；新增 `TArrayOutOfBoundsIndexAccess`，读/写越界均断言 `Array index out of bounds.` 脚本异常。验证：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.TArrayAdvanced"` → `23/23`
- [x] 5.6 (G6) 扩充 `AngelscriptCoverageTMapAdvancedTests.cpp`：`TMap<K, 用户USTRUCT>` 作值的存取往返断言（现 `TMapValueTypes` 仅 FString/FVector/int）。验证：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.TMapAdvanced"` → `11/11`
- [ ] 5.7 (G7) 实测 `AngelscriptCoverageWidgetTests.cpp` 中动画播放 / 焦点输入模式能否在 headless 下补运行期断言（动画推进/焦点转移）；可行则把 `WidgetAnimationPlaybackReflectionSurfaces` / `WidgetFocusAndInputModeReflectionSurfaces` 从 🟡 升 ✅，不可行则记为反射上限。验证：`Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.Widget"`

### 2026-06-30 第二轮深审新增（G8–G29，5 个未深审域并行 subagent 产出）

> 详见 `coverage-gaps.md §1` 表格 G8–G29 与"### 2026-06-30 能力面缺失行审查 · 第二轮"段。G8/G10 已于 2026-07-01 补测关闭，其余 20 项均为可选增强、非阻塞。新增测试须遵循 `_angelscript-test-guide`（CQTest + theme-first Automation 前缀）。

#### 05-uclass 域（3 项）

- [x] 5.8 (G8) 在 `AngelscriptCoverageUClassTests.cpp` 新增 `UClassDefaultObjectAndInstanceStateIndependence`：断言运行时修改 CDO 后后续 `NewObject` 继承新默认、既有实例不被 retroactive 修改、实例突变不污染 CDO 或后续实例。验证：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.UClass"` → `60/60`
- [ ] 5.9 (G9) 在 `AngelscriptCoverageClassLifecycleTests.cpp` 的 `ActorLifecycle`/`MultiLevelInheritanceLifecycle` 补 Actor 自身 Tick/EndPlay/Destroyed 运行期分发断言（参考 Component 侧 `DispatchComponentTick` + `DestroyComponent` 实现）。验证：`Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.ClassLifecycle"`
- [x] 5.10 (G10) 在 `AngelscriptCoverageClassLifecycleTests.cpp` 新增 `NativeOnlyVirtualOverrideBoundaries`，补 `PostLoad / PreSave / PostInitProperties / BeginDestroy / FinishDestroy / Reset` 等 native-only 虚方法的 BlueprintOverride 拒绝边界（compile-failure）。验证：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.ClassLifecycle"` → `9/9`

#### 06-ustruct 域（8 项）

- [ ] 5.11 (G11) 扩展 `AngelscriptCoverageUStructTests.cpp`：`FInstancedStruct` 作 USTRUCT 成员 / UPROPERTY 反射 + `InitializeAs<FFoo>` / `Get<FFoo>()` 往返 + 容器/参数形态。fork 已绑定（`Bind_FInstancedStruct.cpp`）。验证：`Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.UStruct"`
- [ ] 5.12 (G12) 扩展 `UStructValueSemantics`：含 TArray/TMap/TSet 成员的深拷贝独立性断言（修改副本容器不影响源容器）。验证：同上
- [ ] 5.13 (G13) 扩展 `UStructOperators`：补 `opSub` / `opMul` / `opDiv` / `opNeg` 与复合赋值 `opAddAssign` / `opSubAssign` / `opMulAssign` / `opDivAssign` 的运行期断言。验证：同上
- [ ] 5.14 (G14) 在 USTRUCT 边界域加 1 行 compile-failure：`FInstancedPropertyBag Foo;` / `FPropertyBag Foo;` 实证；预期 🚫，确认后归边界矩阵。验证：同上
- [ ] 5.15 (G15) 加 1 行 compile-failure：USTRUCT 用 `HasNativeMake` / `HasNativeBreak` 说明符；预期 🚫。验证：同上
- [ ] 5.16 (G16) 加 1 行 compile-failure：USTRUCT 内 `void Serialize(FArchive& Ar)` 声明；预期 🚫。验证：同上
- [ ] 5.17 (G17) 加 1 行 compile-failure：USTRUCT 内 `bool NetSerialize(FArchive&, UPackageMap*, bool&)` 声明；预期 🚫。验证：同上
- [ ] 5.18 (G18) 加 1 行 compile-failure：USTRUCT 内 `static int Foo;`；预期 🚫（与 §2.4 `BindStatic` 同源）。验证：同上

#### 09-control-flow-language 域（1 项）

- [ ] 5.19 (G19) 扩展 `AngelscriptCoverageLoopTests.cpp::ForEach`：补 Add/Remove 容器在 for-each 迭代中修改时的运行期语义断言（迭代器失效或合法的语义）。验证：`Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.Loop"`

#### 12-input 域（10 项）

- [ ] 5.20 (G20) 扩展 `EnhancedInputComponentBindingEventsAndRemoval` / `EnhancedInputBindingHandlesAndRemoval`：补 Ongoing/Completed/Canceled 三个 ETriggerEvent 的 `GetTriggerEvent()` 反射保留断言。验证：`Tools\RunTests.ps1 -Filter "Angelscript.TestModule.Coverage.Input"`
- [ ] 5.21 (G21) 扩展 `EnhancedInputModifiersAndTriggers`：补 `ModifyRaw` / `UpdateState` 反射或行为断言。验证：同上
- [ ] 5.22 (G22) 加 Swizzle / FOVScaling Modifier 的反射上限或 compile-failure 边界（Swizzle 已在 Bindings 域暴露但 Coverage 缺；FOVScaling grep 零引用）。验证：同上
- [ ] 5.23 (G23) 加 ChordedAction Trigger 反射或 compile-failure 边界（区别于已覆盖的 Combo）。验证：同上
- [ ] 5.24 (G24) 加 EnhancedInputUserSettings / PlayerMappableKeyProfile compile-failure 边界。验证：同上
- [ ] 5.25 (G25) 扩展传统 InputComponent 测试：补 `bConsumeInput` / `bExecuteWhenPaused` / `Priority` (Block/Override/DontBlock) 设置后链路反射或运行期断言。验证：同上
- [ ] 5.26 (G26) 加独立 compile-failure 边界：`GetMousePosition` / `GetInputMotionState` / `GetInputAnalogKeyState` / `GetInputKeyTimeDown`（fork grep 零绑定）。验证：同上
- [ ] 5.27 (G27) 加多 Player 输入路由测试（CreatePlayer / GetPlayerControllerFromID / 第二手柄 InputComponent 隔离反射）。验证：同上
- [ ] 5.28 (G28) 加光标类型 / 点击 / 悬停事件 compile-failure 边界（`SetMouseCursor` / `bEnableClickEvents` / `bEnableMouseOverEvents`）。验证：同上
- [ ] 5.29 (G29) 加 Force Feedback / Haptic API compile-failure 边界（`ClientPlayForceFeedback` / `SetHapticsByValue` 等）。验证：同上

## 5b. 断言层深审（2026-06-30，已完成首轮）

> 起因：用户质疑 ✅ 是否全部核到断言层。按 mixed 标准（能力类须运行期行为断言；纯声明/反射/语法类允许反射/编译级）逐文件读断言。详见 `coverage-gaps.md` "2026-06-30 断言层深审记录"。

- [x] 5b.1 深审 flagged 域（AnimInstance/SaveGame/Material/AssetLoading/LiteralAsset/Preprocessor/Comment/Const/OperatorOverload）断言层；确认绝大多数为真行为断言，G1 为仅有的能力类 compile-only
- [x] 5b.2 给容器矩阵补"缺失行"：新增 G5（越界访问语义）、G6（USTRUCT 作 Map 值）两条 ⬜
- [x] 5b.4 能力面缺失行审查（按 UE/AS 能力面找"该测却没测"的行）：跨 01/02/03/08/10/11/13/14/15 域 grounded 抽查；结论见 `coverage-gaps.md`"2026-06-30 能力面缺失行审查"。新增 G7（Widget 动画/焦点软候选）；其余域饱和或为 headless 合法天花板
- [ ] 5b.3 （可选扩大范围）后续对 `05-uclass`/`06-ustruct`/`07`/`09`/`12` 等未逐行对照的大文件域，按能力面 + mixed 标准深挖；预期产出有限

## 6. 维护约定（持续）

- [ ] 6.1 后续新增/删除 Coverage 测试文件时，先更新所属 `matrices/<领域>.md` 对应行，再回填 `coverage-matrix.md` 主索引的领域文件数/方法数与全局汇总
- [ ] 6.2 若 fork 后续绑定了当前不支持的 API（见 `coverage-gaps.md §2`），将对应行从 🚫 迁移为 ⬜ 并排期补测
- [ ] 6.3 单个领域矩阵若膨胀过大（如 `06-ustruct.md` 对应的 16k 行测试文件），可进一步拆分子文件并在主索引补行
