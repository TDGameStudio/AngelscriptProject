# AngelScript Coverage 待覆盖 / 边界矩阵（统一记录）

> 配合 `coverage-matrix.md`（主索引）及 `matrices/` 下各领域矩阵使用。本文记录两类内容：
>
> 1. **待覆盖 / 待增强**（⬜ / 🟡）：尚未覆盖或可继续加强的真实子项。
> 2. **fork 不支持 / 不适用**（🚫）：当前 AngelScript fork 明确不支持的能力，已作为边界测试或不纳入计划，**避免后续重复尝试**。
>
> 重要原则：历史文档（`Documents/Coverage/`）长期高估缺口（把已实现项标为 ⬜）。本文已剔除"伪缺口"，凡标注 `需审计` 者表示需对照实际测试文件确认后再动手。

## 图例

| 标记 | 含义 |
|------|------|
| ⬜ | 待覆盖（建议新增测试） |
| 🟡 | 部分覆盖（建议增强既有测试） |
| 🚫 | fork 不支持 / 不适用（仅记录，不计划补测） |

---

## 1. 待覆盖 / 待增强（候选工作项）

> 注：经对照实际测试代码审计后，已剔除"伪缺口"。例如 GC 循环引用（`GCStrongCycleReclaim`/`GCRootReachability`/`GCUPropertyReachabilityChain`）与动态材质参数（`DynamicMaterialParametersAndAssignment`/`...Readback`）实际已覆盖，不再列为缺口。

| # | 优先级 | 子项 | 关联测试文件 | 状态 | 说明 |
|---|-------|------|------------|------|------|
| G1 | 🟡 中 | AnimInstance 行为覆盖 | AngelscriptCoverageAnimInstanceTests.cpp | 🟡 | 现仅 2 方法（子类/变量 + 查询函数"可编译"），缺运行期行为断言（状态机/曲线值/通知） |
| G2 | 🟢 低 | SaveGame 复杂结构序列化 | AngelscriptCoverageSaveGameTests.cpp | 🟡 | 已覆盖标量属性往返/缺槽 null；嵌套 struct / 数组字段往返待补 |
| G3 | 🟢 低 | 弱引用/指针容器元素 | AngelscriptCoverageWeakReferenceTests.cpp | 🟡 | `TArray<TWeakObjectPtr<T>>` 元素往返尚无专项断言（`需审计`确认） |
| G4 | 🟢 低 | TObjectPtr 显式属性往返 | AngelscriptCoverageHandlesTests.cpp | 🟡 | `TObjectPtr<T>` 已在多文件出现；作为显式 UPROPERTY 的声明/读写专项断言`需审计`确认 |

> 上述均为**可选增强**，非阻塞项。当前 Coverage 覆盖整体成熟（89 文件 / 980 方法），无"极高优先级"硬缺口。新增测试须遵循 `AGENTS.md` 测试分层与 `_angelscript-test-guide` 约定。

## 2. fork 不支持 / 不适用边界（仅记录，不计划补测）

### 2.1 容器 API 未绑定

| 容器 | 未绑定 API | 现状 |
|------|-----------|------|
| TArray | `RemoveAll(Pred)` / `Find` / `FindLast` / `StableSort` / `Reverse` / `FilterByPredicate` / `FindByKey` / `FindByPredicate` / `Heapify`/`HeapPop`/`HeapPush` / `LowerBound`/`UpperBound` | 🚫 当前绑定未暴露；用 `FindIndex`/`Contains`/`Sort` 替代 |
| TMap | 指针式 `Find(Key)` / `GenerateKeyArray` / `GenerateValueArray` / `FindRef` / `FindChecked` / `Reserve`/`Shrink` / `Append` / `FilterByPredicate` / `for (auto& Pair)` 语法 | 🚫 用 `Find(Key,Out)` / `GetKeys` / `GetValues` / 显式迭代器替代 |
| TSet | `Find(Value)` / `Array()` / `Union` / `Intersect` / `Difference` / `Includes` / `FilterByPredicate` | 🚫 用 `Contains` / `Append`(并集) / 手动 for-each 替代 |

### 2.2 容器嵌套

| 组合 | 现状 |
|------|------|
| `TArray<TArray<T>>` / `TArray<TMap<>>` / `TMap<K,TArray<>>` / `TArray<TSet<>>` / `TMap<K,TMap<>>` | 🚫 编译器诊断 `Containers cannot be nested in other containers`（已作边界测试） |
| struct 内含数组再作为数组元素 | ✅ 允许（已覆盖，列此对照） |

### 2.3 接口引用

| 能力 | 现状 |
|------|------|
| 脚本级 `interface` / `TScriptInterface<I>` 声明、赋值、多态调用、作容器元素 | 🚫 当前 fork 不支持脚本级 interface；`UInterfaceTests` 覆盖的是 C++ UINTERFACE 实现路径 |

### 2.4 其他边界

| 能力 | 现状 |
|------|------|
| 委托 `BindStatic`（绑定全局/静态函数） | 🚫 AS 无静态函数概念，用 `BindUFunction`/`BindLambda` |
| 多播委托返回值 | 🚫 语义上不支持（多监听器返回值无意义） |
| 输入模式切换 `SetInputMode` 完整路径 | 🚫 headless 下作为 `InputModeSwitchingUnsupportedBoundary` 边界记录 |
| `GetWidgetFromName` 运行时取控件 | 🚫 作为 `GetWidgetFromNameUnsupportedBoundary` 边界记录 |

---

## 3. 已被历史文档误标为"未覆盖"的项（已实现，纠偏对照）

> `Documents/Coverage/` 多处把下列**已实现**主题标为 ⬜/计划，本表纠偏，删除旧文档时无需迁移其"待办"。

| 历史文档声称 | 实际状态 | 实际测试位置 |
|------------|---------|------------|
| 物理/碰撞/Trace/约束 = 0% 计划 | ✅ 已覆盖 | PhysicsTests.cpp（25 方法，含 Trace/Constraint/CharacterMovement） |
| 增强输入(UE5)/触摸 = ⬜ 计划 | ✅ 已覆盖 | InputTests.cpp（IMC/修饰器/触发器/触摸边界） |
| UI/UMG 控件/动画/绑定 = ⬜ 计划 | ✅ 已覆盖 | WidgetTests.cpp（控件/布局/动画/焦点/事件） |
| 委托/事件/动态委托 = ⬜ | ✅ 已覆盖 | Delegate/Multicast/Dynamic/Event Tests |
| 句柄/弱引用/软引用/GC = 部分 ⬜ | ✅ 已覆盖 | Handle/Handles/Weak/Soft/GC Tests |
| MasterIndex 整体完成度 ≈ 12% | ❌ 严重低估 | 实际 89 文件 / 980 方法，绝大多数主题成熟 |

---

## 4. 文档退役 / 迁移（cutover · 已完成）

`Documents/Coverage/` 已退役，由本 OpenSpec 记录接管。cutover 执行情况：

- ✅ **38 个** Coverage 测试 `.cpp` 的头注释里 `Documents/Coverage/Coverage_*.md` 引用，已统一改指 `OpenSpec: test-coverage-matrix-consolidation/coverage-matrix.md`。
- ✅ `.agents/skills/_angelscript-test-guide/SKILL.md` 与 `SKILL_ZH.md` 已同步改指本记录。
- ✅ 改指完成后删除 `Documents/Coverage/` 整目录（80 个文件）；`git grep "Documents/Coverage"` 无残留。

> 严格遵循"先改指、后删除"，无悬空引用窗口。改动仅限注释字符串。
