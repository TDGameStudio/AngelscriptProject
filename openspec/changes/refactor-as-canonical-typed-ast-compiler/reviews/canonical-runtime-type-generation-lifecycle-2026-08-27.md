# Canonical Runtime Type Generation 生命周期收口（2026-08-27）

## 1. 结论

Task 14.4 已完成实现与聚焦验证。Canonical compiler 的成功发布现在不再只是“替换 bytecode，随后另行发布 AST snapshot”，而是把以下状态收进同一代 Runtime generation 的所有权与发布协议：

```text
Generation
  = executable inventories
  + sealed canonical AST snapshot lease
  + stable type/member/function identities
  + immutable Runtime type-binding table
  + publisher/digest/provenance/generation metadata
  + generation-local public TypeId projection dependencies
```

同一 module 的 generation B 在候选状态完成解析、binding freeze、CodeGen commit 与 snapshot 准备之后，才在 `astSnapshotLock` 下完成一次 current-generation 交换。generation A 的 executable/type objects/public TypeId map 不会在仍有 snapshot 或执行引用时被回收；失败的 B 不会改变 current A。

这关闭了本 change 内动态 `TypeId` 最危险的生命周期缺口，但不表示整个 `refactor-as-canonical-typed-ast-compiler` 已完成：14.2 的 Standalone gate、14.3 的逐 relocation-class failure matrix、14.6 的边界扫描与最终大门仍保持 open。

## 2. 最终所有权模型

```text
current asCModule
  └─ owner ref ──> asCRuntimeTypeGeneration
                    ├─ immutable asCRuntimeTypeBindingTable
                    ├─ generation-local TypeInfo/public-TypeId dependencies
                    └─ preallocated retired asCModule carrier

current/retired asCASTSnapshot
  └─ lease ──────> same asCRuntimeTypeGeneration

externally referenced asCScriptFunction
  ├─ external refcount 0 -> 1: acquire generation execution lease
  └─ external refcount 1 -> 0: release generation execution lease
```

generation 不通过内部 function ownership 反向持有自己。`asCModule`/retired carrier 仍按既有规则内部拥有 function；function 只在存在外部引用时租赁 generation。这样 `asIScriptContext::Prepare()` 对 function 的外部引用可以延长旧代执行依赖的寿命，同时避免 `generation -> function -> generation` 的永久引用环。

`asCASTSnapshot` 同样 AddRef/Release generation。snapshot 的 ASTContext 与对应代 Runtime binding/executable/type map 因而具有相同的退役边界，而不是两个互不相关的生命周期。

## 3. 发布、失败与退役协议

### 3.1 candidate 阶段

1. 为 candidate module 预分配 `asCRuntimeTypeGeneration`、retired carrier 和待发布 snapshot；内存分配/快照准备失败发生在 current 状态改变之前。
2. 用 durable stable identity 和完整 `asSTypeABIKey` 解析全部 `asSTypeRelocation`。
3. `asCRuntimeTypeBindingTable::Build()` 使用 validate-all/commit-none，成功后 freeze；numeric public TypeId 只作为 candidate/current Engine 的 late projection。
4. detached bytecode、function/global/type inventories 与 frozen bindings 在 candidate 内完成 `Commit()`；局部 artifact 通过 `SwapWith()` 把 immutable table 转移给 candidate generation。

### 3.2 单点 current 交换

`asCModule::Build()` 在 `astSnapshotLock`（即 `AcquireASTSnapshot()` 使用的同一把锁）下完成：

1. 将 current generation A 标记并转移到预分配 retired carrier；
2. 把 candidate generation B 及 executable inventories 提升为 current；
3. 交换 `astSnapshot`；
4. 更新 `astGeneration` 和 current/non-current 标记。

旧 snapshot 在离开临界区后才 Release。读取者因此不能再观察到“A snapshot 仍被稳定标记为 current，但 A Runtime generation 已经 retired/B executable 已经 current”的混合状态。

### 3.3 失败不发布

Runtime type resolution、snapshot preparation 或候选构建失败时，不执行上面的 current 交换：

- A 的 module inventories、publisher/digest、snapshot、generation key 与 binding view 保持不变；
- A 的 TypeInfo/public TypeId map 不被候选 B 重定向；
- B 的 pending TypeId、helper、functions/types/globals 由 candidate rollback/销毁路径清理。

### 3.4 退役与最终释放

同 module replacement 会把 A 的 executable/type/global/import 状态整体转移到 retired carrier。只要仍有以下任一 lease，A 就继续存活：

- 旧 `asCASTSnapshot`；
- 被外部持有或已由 context `Prepare()` 的旧 `asCScriptFunction`。

最后一个 lease 释放后，generation 删除 retired carrier；carrier 的既有 reset/destructor 路径才移除旧代 TypeId map 和其余 Runtime 资源。

legacy `Build()`、canonical empty rebuild 和 `as_restore.cpp` 的 `LoadByteCode` replacement reset 均统一走 `ResetExecutableGenerationForReplacement()`，不再绕过 generation retirement。

## 4. 动态 TypeId 的改造边界

最终身份链为：

```text
asASTTypeRef (snapshot-local)
  -> StableTypeKey (durable nominal/structural identity)
  -> asSTypeABIKey (complete compatibility contract)
  -> generation-local RuntimeTypeBinding
  -> current numeric public TypeId projection
```

关键点：

- `asASTTypeRef` 只在一个 AST snapshot 内有效，跨 snapshot 数值相同也不代表同一类型；
- `StableTypeKey` 与完整 ABI key 才能进入 relocation、cache/provider identity、diagnostic DTO 等持久边界；hash 只用于索引，完整相等仍是最终 authority；
- numeric `TypeId` 继续兼容 AngelScript embedding API，但被明确限制为 Engine/generation-local projection；
- VM/installed bytecode 不需要每条指令按 stable name 动态查类型。安装时完成 stable lookup，执行时可以使用该 generation 内已经解析的 pointer、offset、slot 或 current numeric ID；
- 热更新不会重写旧代 operand 去指向新代 TypeId。旧代 executable 与旧代 TypeId map 一起退役。

一个测试层面的易错点是 handle-qualified 类型：binding row 的 `dataType` 可能是 `FType@`，因此 numeric ID 应通过 `ScriptEngine->GetTypeIdFromDataType(Binding->dataType)` 比较，不能直接拿裸 `TypeInfo` 的 ID 代替。这不是 Runtime identity 缺陷，而是“裸 object type ID”和“完整 qualified data type ID”混淆。

## 5. 本轮发现的问题与处理

| 问题 | RED/现象 | 根因 | 处理与边界 |
| --- | --- | --- | --- |
| handle-qualified TypeId 断言不一致 | binding 的 public ID 与测试取得的裸 TypeInfo ID 不同 | 测试丢失了 handle qualifier | 使用完整 `asCDataType` 做 public-ID 投影比较 |
| retired generation 仍占 authoritative nominal lookup | B 构建出现 `-10`/重复类型 | 先转移全部类型，但未先撤销 A 的 current authority | retirement 在转移前移除 current lookup authority，同时保留 A TypeId map 供旧执行使用 |
| empty canonical rebuild 未退役 A | 空 B 后旧 executable generation 仍 current | 空发布路径绕过 replacement reset | 统一走 generation-aware reset |
| legacy Build/LoadByteCode 绕过 generation | 非 canonical replacement 可直接 `InternalReset()` | reset 入口分散 | 引入并复用 `ResetExecutableGenerationForReplacement()` |
| prepared execution 未保活旧代 | 释放最后一个 snapshot 后，已 `Prepare(A function)` 的 A TypeId map 已消失 | function 外部引用只保活 function，没有保活其 generation | external function ref 0→1/1→0 获取/释放 execution lease；GREEN 后 context 可继续执行 A |
| executable 与 snapshot 非原子发布 | 并发 reader 观察到 snapshot current-before/current-after，但其 generation 已 retired | executable promotion 与 snapshot exchange 分两段 | 在 `astSnapshotLock` 内完成 retire/promote/snapshot/current marker 单点交换 |

## 6. 验证证据

### 6.1 RED → GREEN

| 场景 | RED | GREEN |
| --- | --- | --- |
| prepared execution lease | `Saved/Tests/canonical-runtime-type-execution-lease-red/20260827_034255_512_63c2abcd/Report/index.json`（0/1） | `Saved/Tests/canonical-runtime-type-execution-lease-green/20260827_034714_815_e4d97f8d/Report/index.json`（1/1） |
| snapshot/executable atomic publication | `Saved/Tests/canonical-runtime-generation-atomic-publication-red/20260827_035248_839_6c8d92a2/Report/index.json`（0/1） | `Saved/Tests/canonical-runtime-generation-atomic-publication-green/20260827_035357_894_7b02e5e8/Report/index.json`（1/1） |

对应 build：

- execution-lease RED build：`Saved/Build/canonical-runtime-type-execution-lease-red-build/20260827_034237_810_54083573/`；
- execution-lease GREEN build：`Saved/Build/canonical-runtime-type-execution-lease-green-build/20260827_034450_813_cd2c7213/`；
- atomic-publication RED build：`Saved/Build/canonical-runtime-generation-atomic-publication-red-build/20260827_035231_229_3dc22edf/`；
- atomic-publication GREEN build：`Saved/Build/canonical-runtime-generation-atomic-publication-green-build/20260827_035343_478_63e08b0c/`。

### 6.2 最终聚焦与回归

| Gate | Result | Report |
| --- | ---: | --- |
| generation lifecycle matrix | 6/6 PASS | `Saved/Tests/canonical-runtime-type-generation-final/20260827_035434_179_56b4c087/Report/index.json` |
| HotReload CanonicalAST | 12/12 PASS | `Saved/Tests/canonical-hotreload-generation-final/20260827_035508_306_a5cdee87/Report/index.json` |
| Module CanonicalAST Snapshot | 9/9 PASS | `Saved/Tests/canonical-module-snapshot-generation-final/20260827_035546_484_f87c6f65/Report/index.json` |
| ProductionCodeGen | 111/111 PASS | `Saved/Tests/canonical-production-generation-final/20260827_035737_704_25f5d064/Report/index.json` |
| CodeGen.Transaction | 19/19 PASS | `Saved/Tests/canonical-type-relocation-transaction-generation-final/20260827_035811_787_99281096/Report/index.json` |

统一 reset 的 build 也已成功：`Saved/Build/canonical-runtime-type-generation-unified-reset-build/20260827_033559_201_86b1c038/`。

## 7. 已知边界与不能过度声称的部分

- same-module replacement 是本实现对“完整旧代 executable + types + globals/import state + binding view + TypeId map”最强的保证路径。
- 实际 `DiscardModule` 仍按既有语义调用 `CallExit`、处理 JIT binding 和 module 生命周期。discard/recreate 测试证明无 global 的旧 VM function 与类型映射能在 snapshot lease 后继续存在，但不能据此声称“任意 mutable global 或 JIT code 在显式 discard 后仍具备透明继续执行语义”。
- 当前 same-module transfer 会移动 global/import 状态和 `isGlobalVarInitialized`；后续如扩展到跨 Engine、持久 restore 或 JIT code-image retirement，仍应由各自 lifecycle/lease contract 明确处理。
- 完整 VM/`PrecompiledData` relocation 清理不在本 change 范围；本 change 保留 public `int TypeId` 兼容面，只关闭 canonical durable identity 与 generation-install correctness。

## 8. 架构评估

Canonical AST 的 Clang-like 方向是合适的：source location、arena/context ownership、typed declarations/expressions、Sema authority 和 immutable snapshot 形成稳定的编译器前端事实源。此前欠缺的是 daScript 一类多后端系统常见的“已解析 Runtime/AOT view”：不能让 AST 类型引用或动态 numeric ID 直接承担跨 generation 身份。

本轮引入 generation-owned immutable Runtime binding view 后，两层职责更清楚：

- Clang-like AST 负责语义、结构、诊断与 durable stable identity；
- generation binding/relocation 层负责把 durable identity 链接到当前 Engine 的 Runtime 对象和 ABI；
- VM、TypedASTJIT、StaticJIT 只消费已安装的 generation-local resolved operands，不在 hot path 重做 stable lookup；
- numeric TypeId 退回到兼容投影位置，不再作为 cache、snapshot、provider 或跨热更新身份。

因此当前架构已经具备正确的扩展方向：以后增加新后端，应复用 `StableTypeKey + ABIKey + relocation/install`，而不是为每个后端重新持久化 Engine pointer 或 numeric TypeId。

## 9. 后续顺序

1. Task 14.3：给 type/property/function/public-ID/list-pattern 等每个 relocation class 增加明确的 failure injection，并比较包含 module-owned Runtime binding view 在内的完整 A 状态。
2. Task 14.2：修复当前 Standalone default-cutover 回归，从 8/21 恢复到 21/21，再签收同源 binding table。
3. Task 14.6：运行完整 type-identity boundary gate 与 durable-identity scans。
4. 继续剩余 Sema、TypedASTJIT、Standalone 与默认 CANONICAL cutover；最后再执行 section 12 的全量门禁。
