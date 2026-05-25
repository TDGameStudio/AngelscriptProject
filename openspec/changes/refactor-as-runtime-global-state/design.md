# Design: refactor-as-runtime-global-state

## Context

当前失败点是 `FString::Format`，但真正目标是 runtime 去全局化。项目已经移除了 `GAngelscriptEngine`，引擎发现也改成 ContextStack / subsystem owner，但 bind 与类型系统里仍有一些 legacy/static storage 能保存 engine-owned AngelScript 对象。

去全局化的判断标准：

- 可以全局：纯注册描述、UE reflection 对象、名字、配置、可重放 bind callback。
- 必须去全局化：`asITypeInfo*`、`asIScriptFunction*`、`asIScriptObject*`、`asCContext*` 等由某个 `asIScriptEngine` 创建和销毁的对象。
- 需要审计：legacy fallback storage，因为它们通常服务“无 current engine”的旧路径，容易变成隐藏的跨 engine 状态。

`TGetStaticTypeInfo<T>::TypeInfo` 是第一处已复现的问题：`FString` / `FText` bind 时把当前 engine 的 `asITypeInfo*` 写入 process-wide static，后续格式化参数转换又把当前 engine 的类型对象拿去和这个历史指针比较。

## Narrow Failure Chain

1. Engine A binds `FString`, storing Engine A's `asITypeInfo*` in `TGetStaticTypeInfo<FString>::TypeInfo`.
2. Engine B becomes current and executes `FString::Format("{0}", "Hello")`.
3. The format string itself is read directly as `FString`; the checked argument is the second parameter (`{0}`).
4. Engine B resolves the argument type id to Engine B's `FString` type object.
5. Pointer comparison against Engine A's cached `TypeInfo` fails even though both types are named `FString`.
6. The formatter throws the invalid-argument branch.

Historical note: commit `679704f` had an explicit `FString TypeInfo is per script engine` fallback that also accepted `TypeInfo->GetName() == "FString"`. Commit `4140354` removed that fallback and exposed the stale global cache again. The fallback proves the observed failure mode, but the durable fix is engine-scoped caching rather than name-only acceptance.

## Goals / Non-Goals

**Goals:**

1. 以去全局化为主线，建立 runtime 状态分层规则和处理顺序。
2. 把确认保存 engine-owned AS 对象的 process-wide 状态迁到 engine-owned / engine-keyed / lifecycle-cleared 结构。
3. 先处理 `TGetStaticTypeInfo<T>`，因为它已经通过 `FString::Format` 暴露出稳定失败链路。
4. 覆盖 `FString::Format` 和 `FText::Format`，因为二者共享同一个静态 TypeInfo 模式。
5. 对类似状态形成“立即处理 / 审计后处理 / 可保留”分层，避免盲目删除所有全局注册表。

**Non-Goals:**

- 不重写完整 bind 系统。
- 不移除保存纯元数据的全局注册表。
- 不把名字比较作为最终架构；名字 fallback 只能作为短期止血。
- 不替换标准构建/测试入口。

## Technical Approach

### A1. State ownership classification first

每个 runtime 状态先按保存内容分类，再决定迁移方式：

| Class | 内容 | 处理方式 |
|---|---|---|
| Engine-owned AS objects | `asITypeInfo*`、`asIScriptFunction*`、`asIScriptObject*`、`asCContext*` | 必须迁入 `FAngelscriptEngine`、按 engine key 分区，或由 engine teardown 清理 |
| Engine-derived mutable state | 依赖当前 engine bind 顺序、type database、script enum lookup 的状态 | 优先迁入 `FAngelscriptEngine`；保留 fallback 时必须证明不会跨 engine 读写 |
| Replayable metadata | bind 描述、函数指针、UE reflection 对象、名字、配置 | 可以全局保留，但不得缓存 AS runtime object |
| Scoped acceleration cache | TLS / RAII 短生命周期加速缓存 | 可以保留，前提是作用域结束即失效，且不跨 engine 暴露对象 |

### A2. First migration: `TGetStaticTypeInfo<T>`

`TGetStaticTypeInfo<T>` 从“每个 C++ 类型一个全局 AS 指针”改为“每个 engine 一个 AS 指针”。

目标行为：

- Bind phase 记录 `asITypeInfo*` 和创建它的 engine。
- Read phase 只返回当前 engine 对应的 `asITypeInfo*`。
- Engine shutdown 在 AS engine release 前清理该 engine 的条目。
- `FString::Format` / `FText::Format` 继续使用快速指针比较，但比较对象来自当前 engine。

可接受形态：

- 保留 `TGetStaticTypeInfo<T>` 作为入口，减少 bind callsite 扩散。
- 增加类似 `SetForCurrentEngine(TypeInfo)` / `GetForCurrentEngine()` / `ClearForEngine(...)` 的操作。
- key 可以是 `FAngelscriptEngine*` 或 `asIScriptEngine*`，但必须有明确 cleanup 点，避免地址复用导致误判。

### A3. Second migration candidates

这批不是立刻全部重构，而是按“能否保存 AS runtime object 并跨 engine 被读取”逐个确认：

- `GScriptEnumTypeLookupByName`：全局 `FName -> asITypeInfo*`，需要迁入 engine 或按 engine 分区。
- `LegacyToStringList`：`FToStringType` 内含 `asITypeInfo*`；legacy fallback 应只保存元数据，或者证明不会在 bind 后被跨 engine 读取。
- `LegacyDatabase` / `LegacyBindState` / `LegacyBindDatabase`：多数是描述型数据，但需要确认 type finder / previous-bound-index 等是否依赖当前 engine。
- `GAngelscriptContextPool`：TLS context pool 已按 `DesiredScriptEngine` 取还 context；需要确认 engine teardown 覆盖所有池内 context。

### A4. Regression chain

回归测试不只证明单 engine 成功，而要证明“前一个 engine 留下的状态不会污染后一个 engine”。

验收链路：

1. Engine A 完成 bind，写入旧问题涉及的状态。
2. Engine A teardown 或切换到 Engine B。
3. Engine B 执行 `FString::Format("{0}", "Hello")`，结果为 `Hello`。
4. Engine B 执行等价 `FText` 格式化路径或共享 TypeInfo cache 验证。
5. 若 enum / ToString fallback 被迁移，同样补一条跨 engine 顺序用例或 teardown 用例。

## Similar Global State Inventory

### P0: 立即去全局化

- `Binds/Helper_GetTypeInfo.h`: `TGetStaticTypeInfo<T>::TypeInfo` 是 process-wide `asITypeInfo*`，当前根因。
- `Binds/Bind_FString.cpp` / `Binds/Bind_FText.cpp`: format path 依赖上述静态 TypeInfo，作为第一条验收链路。

### P1: 高风险，随本变更审计并尽量收口

- `Binds/Bind_UEnum.cpp`: `GScriptEnumTypeLookupByName` 是 process-wide `FName -> asITypeInfo*`。
- `Binds/Bind_FString.cpp`: `LegacyToStringList` 是 legacy fallback，元素类型 `FToStringType` 可携带 `asITypeInfo*`。

### P2: 中风险，确认是否真的保存 engine-owned 对象

- `Core/AngelscriptType.cpp`: `LegacyDatabase` 是 fallback `FAngelscriptTypeDatabase`。
- `Core/AngelscriptBinds.cpp`: `LegacyBindState` 是 fallback bind-state registry。
- `Core/AngelscriptBindDatabase.cpp`: `LegacyBindDatabase` 是 fallback bind metadata。
- `Core/AngelscriptEngine.cpp`: `thread_local FAngelscriptContextPool GAngelscriptContextPool` 保存 `asCContext*`，但已有按 script engine 匹配 / release 的 containment 逻辑。

### P3: 可保留但不得升级为 AS 指针缓存

- 静态 `FName`、配置开关、console variable。
- 保存可重放注册逻辑的 bind extension registry。
- 仅保存 UE reflection 对象、名字、函数指针、声明文本的 cache。
- `FScopedBindCaches` 这类 RAII/TLS 临时缓存，前提是作用域结束即失效。

## Decision

以“runtime AS 对象去全局化”为主线推进。`FString::Format` 不是单独热修；它是第一条可复现验收链。

推荐执行顺序：

1. 先落状态分层和清单，明确哪些全局状态必须处理。
2. 迁移 `TGetStaticTypeInfo<T>` 到 engine-scoped storage。
3. 用 `FString` / `FText` format 证明当前 engine 类型身份稳定。
4. 继续处理 `GScriptEnumTypeLookupByName` 和 `LegacyToStringList`。
5. 审计 legacy database / bind state / context pool，保留纯元数据，清掉 AS runtime object 跨 engine 泄漏面。

## Risks / Trade-offs

- **迁移面扩大**：主线从格式化回归扩大为去全局化，涉及更多状态点。处理方式是分 P0/P1/P2，不把所有 legacy fallback 一次性重写。
- **cleanup 顺序**：engine-owned AS 指针必须在 AS engine release 前移除，否则后续地址复用可能制造新误判。
- **fallback 兼容**：名字比较可以短期止血，但不能作为最终结构，否则会继续掩盖跨 engine 状态泄漏。
- **legacy fallback 不确定性**：部分 fallback 可能只服务静态初始化路径。先证明是否会保存 AS runtime object，再决定迁移或保留。