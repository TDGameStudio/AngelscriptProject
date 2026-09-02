# Canonical type relocation failure matrix（2026-08-27）

## 1. 结论

Task 14.3 的 relocation transaction acceptance 已闭合。

Canonical CodeGen 现在满足以下边界：

1. detached artifact 在安装前只持有稳定、无 Engine 指针的 type/member/function identity、完整 expected ABI、use kind、owning function ordinal 与 operand offset；
2. 所有 relocation 先完成 Runtime resolution 和 binding-table freeze，再开始 patch detached bytecode；
3. public numeric TypeId 只在目标 Engine/generation 安装阶段投影，不进入 Canonical AST、stable key 或 detached durable identity；
4. 六类 relocation 均有真实 source fixture 和 test-only 定点失败注入；
5. 每类失败都发生在 `Commit()` 之前，并证明 generation A 的 executable、AST、publisher/digest、Runtime bindings、Engine/module inventory、ID allocator/free list 均不变；
6. wildcard `?&` ABI 的 `TYPEID` 不是仅由 failure matrix 人工制造：生产执行测试验证 generic callback 的 `GetArgTypeId(0)` 看到了当前 Engine 的 `FPayload` TypeId。

这关闭的是 canonical/detached/generation install correctness，不是把 legacy VM、SaveByteCode 或 `FAngelscriptPrecompiledData` 的所有 numeric TypeId operand 一次性移除。后者仍按 Task 14.5 的 scope inventory 留给未来独立 change。

## 2. Relocation 分类与真实 fixture

`asERuntimeTypeRelocationUse` 以 `asTYPE_RELOC_USE_COUNT` 作为完整枚举边界。当前矩阵逐项签收：

| Use | 语义分类 | Candidate source / lowering surface | 安装结果 |
| --- | --- | --- | --- |
| `asTYPE_RELOC_METADATA_ONLY` | metadata-only | `FTxnRelocationPod Copy` 的 POD value-copy/COPY 元数据 | 目标 ABI 的 size/shape；不是 durable numeric TypeId identity |
| `asTYPE_RELOC_RUNTIME_TYPE_TARGET` | Runtime type target | value/list construction 等需要 Runtime type target 的 opcode | 当前 generation resolved Runtime type target/current operand |
| `asTYPE_RELOC_PUBLIC_TYPE_ID` | public numeric-ID projection | `TxnObserveWildcard(Copy)` 的 wildcard hidden TypeId ABI operand | 当前 Engine/generation 的 public `int typeId` |
| `asTYPE_RELOC_PROPERTY` | member dependency | `return Box.Marker` | exact owner ABI 校验后的 property offset/target |
| `asTYPE_RELOC_FUNCTION` | callable dependency | `TxnObserveWildcard(Copy)` 及 list-factory/call target | exact function ordinal/signature 对应的 Runtime target |
| `asTYPE_RELOC_LIST_PATTERN_TARGET` | anonymous Runtime helper target | `FTxnListPatternBox Box = {2}` | exact owner ABI + list-factory identity 对应的 candidate helper |

统一 candidate fixture：

```angelscript
int ExerciseTxnRelocations(FTxnRelocationPod Copy)
{
    FTxnListPatternBox Box = {2};
    TxnObserveWildcard(Copy);
    return Box.Marker;
}
```

generation A 使用另一个已发布模块 source：

```angelscript
int BaselineRead(FTxnRelocationPod Value)
{
    return Value.Value;
}
```

Candidate AST 在独立 scratch module `TxnRelocationClassMatrixCandidate` 中 parse/seal；真正的 `asCBytecodeCodeGen::Generate()` 以 generation A 所在的 `TxnRelocationClassMatrix` 作为安装目标。这样 matrix 检查的是“已发布 A + detached B candidate”的实际替换边界，而不是空模块上的局部 rollback。

## 3. 失败注入位置与事务语义

新增 unit-test-only API：

- `asCBytecodeCodeGen::SetTestFailureAtTypeRelocationUse()`；
- `asCBytecodeCodeGen::WasTestTypeRelocationFailureInjected()`；
- `asSBytecodeCodeGenArtifact::ResolveAndPatchTypeRelocations()` 的 optional test failure 参数。

注入点位于完整 `asCRuntimeTypeBindingTable::Build()` 成功之后、任一 detached operand patch 之前。这个位置很重要：

- 若在 Build 之前失败，只能证明 resolver 早退，不能证明 frozen complete table 已经建立后仍可无副作用退出；
- 若边解析边 patch，后面一个 relocation 的失败可能留下半 patched artifact 或提前修改 Engine allocator；
- 当前实现先 validate/resolve/freeze 全表，再按 relocation patch 仅属于 candidate 的 bytecode；最后 `Commit()` 才发布 Engine/module 状态。

若请求的 relocation use 没有由 candidate 实际发出，生成会失败且 `WasTestTypeRelocationFailureInjected()` 保持 false。测试因此不能用“没有走到目标路径”的普通失败冒充该 relocation class 的签收。

矩阵对每种 use 都要求返回指定的 `asCONTEXT_NOT_FINISHED`，同时要求 injected flag 为 true。之后逐项比较 generation A，并在六次循环结束后再与最初 generation A 做一次完整比较。

## 4. Generation A 不变量

`FCodeGenTableSnapshot` 和 `AssertCodeGenTablesEqual()` 比较以下状态：

### 4.1 Module inventory

- public/module function count；
- `scriptFunctions` 与 `globalFunctionList`；
- public/module global count 与 `scriptGlobalsList`；
- imported functions、funcdefs；
- class types、enum types、typedefs。

### 4.2 Engine inventory 与 allocator/free list

- `scriptFunctions` 总槽位与 occupied 数；
- free script function IDs；
- imported-function slots、occupied 数与 free IDs；
- funcdefs/registered funcdefs；
- global-property slots、occupied 数与 free IDs；
- variable address map；
- all-script global function/global variable/declared-type symbol inventories；
- anonymous list-pattern helper inventory；
- `typeIdSeqNbr`；
- `mapTypeIdToTypeInfo`。

### 4.3 Published executable/AST generation

- last bytecode publisher；
- canonical digest presence/value；
- retained AST snapshot presence；
- snapshot current marker；
- AST generation key。

### 4.4 Runtime binding view

- immutable Runtime binding count；
- complete binding fingerprint；
- registered function-behaviour internal references。

因此本测试不只断言“Build 返回失败”或“旧函数还能调用”。它直接覆盖 Task 14.3 要求的 Engine slots/free lists、module inventories、publisher/digest、AST snapshot/generation key 与 Runtime bindings。

## 5. RED → GREEN 过程

### 5.1 RED：不存在 relocation-class injection API

测试先引用尚不存在的 class-targeted injection API，构建按预期失败；这建立了 test-first baseline：

`Saved/Build/canonical-relocation-class-matrix-red-build/20260827_040855_625_ceffacd1/`

加入 test-only API 后构建成功：

`Saved/Build/canonical-relocation-class-matrix-injection-build/20260827_040956_321_a9a21f48/`

### 5.2 Fixture 探索暴露的 Sema/publication 问题

为让一个 authored fixture 真实发出全部 relocation，尝试过程暴露了三项独立的 canonical Sema/publication 问题：

1. Raw canonical parser 仍显式拒绝 source `@` token；现有 ParserDeclarations 测试也把 `FNode@ Node;` 锁定为 rejection。矩阵没有通过手工 AST 绕过这个事实。
2. 使用 registered implicit-handle type 的某些局部形式会留下 unreachable speculative `DeclRef`，Seal/publication verifier 随后拒绝它。
3. Native POD local copy/member assignment 的部分形式同样会残留 unreachable speculative `DeclRef`。

把 candidate 移到独立 scratch module 后问题仍在，因此不是“generation A module 被重复 parse”导致。最终 fixture 使用 by-value parameter，并避免 POD member access，保证 relocation matrix 聚焦 install transaction。

这些现象没有在 Task 14.3 中伪装为已修复。它们属于仍然开放的 Sema/Parser action、transient graph reachability 与 production cutover surface，需要在对应 AST-first gate 下处理。

### 5.3 RED：public numeric-ID projection class 根本未生成

在前五类逐步可达后，矩阵对 `asTYPE_RELOC_PUBLIC_TYPE_ID` 明确失败：candidate 发出了 6 条 relocation，但不存在 use=2：

`Saved/Tests/canonical-relocation-class-matrix-list-target-fixture/20260827_042920_574_8ad7924f/Report/index.json`

根因不是 injection，也不是 Runtime resolver。Canonical call emitter 已会把 wildcard value argument 作为 live address 传入，却没有实现 legacy/generic ABI 需要的 hidden `TYPEID` operand。因此 generic callback 可以收到地址，却无法从 `GetArgTypeId()` 观察真实静态类型。

### 5.4 GREEN：wildcard hidden TypeId late projection

修复在 call lowering 中维护与 source argument 对齐的 `argPublicTypeIdTypes`：

1. formal token 为 `ttQuestion` 时，保存 actual argument 的 canonical/runtime datatype；
2. 普通参数按既有 reverse formal order 压栈；
3. 在 wildcard address/value 前发出 `asBC_TYPEID, 0` placeholder；
4. 为该 operand 记录 `asTYPE_RELOC_PUBLIC_TYPE_ID`；
5. `ResolveAndPatchTypeRelocations()` 在目标 Engine/generation 中将 placeholder patch 为 current public ID；
6. capture/user argument index 映射使用 `actualArgumentIndex`，不把 closure capture 当成 authored wildcard argument。

构建：

`Saved/Build/canonical-wildcard-public-typeid-build/20260827_043117_777_211f3dbe/`

六类矩阵首次全部通过：

`Saved/Tests/canonical-relocation-class-matrix-after-public-typeid/20260827_043132_283_9bc664b3/Report/index.json`

## 6. 生产行为验证

Failure matrix 证明 failure atomicity，但它不能单独证明成功路径的 public-ID ABI 正确。因此 `FCanonicalASTProductionWildcardValueArgTests.PreparedValueObjectToConstWildcardRefPassesLValueAddress` 增加了三层断言：

1. published function bytecode 包含 `asBC_TYPEID`；
2. canonical function 正常执行，generic callback 收到 live `FPayload` lvalue，值为 41；
3. callback 的 `GetArgTypeId(0)` 等于 `ScriptEngine->GetTypeIdByDecl("FPayload")`。

这项测试直接证明 numeric TypeId 是当前 Engine 的 late public projection，而不是 producer AST/artifact 保存的旧数字。

构建：

`Saved/Build/canonical-wildcard-typeid-observation-build/20260827_043231_113_0af8a5b2/`

focused GREEN：

`Saved/Tests/canonical-wildcard-typeid-observation/20260827_043249_518_460b65e0/Report/index.json`

## 7. 最终回归证据

| Gate | Result | Report |
| --- | ---: | --- |
| CodeGen transaction complete group | 20/20 PASS | `Saved/Tests/canonical-relocation-matrix-full-transaction/20260827_043434_164_c9fad9ce/Report/index.json` |
| ProductionCodeGen complete group | 111/111 PASS | `Saved/Tests/canonical-relocation-matrix-production-regression/20260827_043507_255_e1b56025/Report/index.json` |
| Module CanonicalAST Snapshot | 9/9 PASS | `Saved/Tests/canonical-relocation-matrix-module-snapshot-regression/20260827_043544_787_a2f5b695/Report/index.json` |
| HotReload CanonicalAST | 12/12 PASS | `Saved/Tests/canonical-relocation-matrix-hotreload-regression/20260827_043616_544_f5382824/Report/index.json` |

前两项是 Task 14.3 的直接 acceptance；后两项确认新的 late projection 和 failure injection 没有破坏 Task 14.4 的 snapshot/generation ownership 与 Hot Reload retirement。

## 8. 架构判断

### 8.1 现在正确的 identity 链

```text
Canonical AST asASTTypeRef
  -> complete StableTypeKey
  -> expected TypeABIKey
  -> detached asSTypeRelocation
  -> target-generation RuntimeTypeBinding
  -> pointer / offset / slot / current public TypeId
```

`asASTTypeRef` 只在 owning AST snapshot 内有效；StableTypeKey/TypeABIKey 才能跨 Engine、跨 generation、跨 artifact；Runtime pointer、offset 和 numeric TypeId 都只是最后安装结果。

### 8.2 dynamic TypeId 不再污染 compiler authority

AngelScript public `typeId` 动态分配本身不需要删除。真正的坑是把它当成 AST equality、artifact identity、cache key 或 provider identity。当前 canonical path 已把它限制为：

- public reflection/generic ABI 的当前 Engine observable value；
- install-time projection；
- generation-local binding-table data；
- replacement/retirement 生命周期内由 owning generation 保活。

这与 Clang 风格 AST 的 owner-scoped type handle、linker relocation、target-specific lowering 分层一致，也避免 daScript 式多 backend consumer 直接依赖某个 VM 注册顺序产生的整数。

### 8.3 尚未关闭的边界

- Task 14.2 的 Standalone 当前仍为 8/21，根因是 incomplete canonical default cutover，不是 relocation source/link failure；
- Task 14.6 尚未运行完整 TypeIdentity + StaticJIT + Cache boundary + Standalone + determinism/source scan gate；
- section 4–10 的 Sema authority、TypedASTJIT 完整 consumer cutover、production default 与 legacy authority removal 仍开放；
- explicit handle parser 与 unreachable speculative `DeclRef` 问题必须进入对应 AST-first card，不能由本 matrix 的绿色结果外推为完整语言覆盖。

## 9. Task 状态

Task 14.3 可以标记完成。这个完成声明只代表其明确的 relocation inventory、late projection、六类 failure injection、complete generation-state comparison 和要求的 focused regressions已经满足；不代表 section 10 默认切换、14.6 boundary gate 或整个 OpenSpec change 已完成。
