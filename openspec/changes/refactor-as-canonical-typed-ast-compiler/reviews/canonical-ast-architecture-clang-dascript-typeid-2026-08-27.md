# Canonical Typed AST 架构重梳理：Clang、daScript 与动态 TypeId（2026-08-27）

> **2026-08-28 状态校正：** 本文第 8 节 `:387-390` 与第 10 节
> `:419-425` 是 2026-08-27 当时的实现快照，不能再作为当前状态依据。当前 HIR 已
> 物理删除，产品默认已明确保持 LEGACY，原生 `asCScriptNode` Parser AST / Builder /
> `asCCompiler` 继续保留。关于 Clang lifetime/cleanup 的精确分层、当前实现 findings
> 与 CTA-S53 候选方案，以
> `reviews/canonical-ast-vs-clang-lifetime-review-2026-08-28.md` 为准。本文关于动态
> TypeId 分层与 stable identity 的结论仍有效。

## 1. 结论先行

`refactor-as-canonical-typed-ast-compiler` 的总体方向正确，不建议推倒重来。
当前工程真正引入的是 **Clang-style frontend ownership and phase boundary**，不是
Clang AST 库：

```text
source/provenance
    -> Parser（语法）
    -> Sema（唯一语义裁决者）
    -> ASTContext（唯一 canonical graph owner）
    -> Seal + Verify（只读边界）
    -> Bytecode / TypedASTJIT / Public AST / diagnostics
```

对比 daScript 后，AngelScript 动态 `typeId` 本身不是需要消灭的设计错误。
daScript 也把编译期 `TypeDecl` 降为运行期 `TypeInfo*`，并让执行节点使用直接指针；
它的 hash 用于 lookup/fingerprint，碰撞时仍验证完整类型。真正的坑是把 AS 的同一个
Engine-local numeric `typeId` 同时误用为：

- canonical semantic identity；
- detached/persisted relocation identity；
- active VM operand；
- embedding-facing public projection。

正确改造不是“让 TypeId 确定化”，而是把这四种职责拆开：

```text
snapshot-local asASTTypeRef
          -> durable StableTypeKey
          -> target/profile TypeABIKey
          -> generation-local RuntimeTypeBinding
          -> public numeric typeId（仅在确有 ABI/语言需要时晚投影）
```

当前实现已经完成 stable identity、detached install、六类 relocation failure matrix
与 generation aggregate ownership。Canonical CodeGen 的 TypeId 分配已经推迟到
candidate transaction；成功 artifact 的 immutable `runtimeTypeBindings` 转移给
module-owned generation，公开 AST snapshot 和 execution lease 共同保活同代
executable/type/binding resources。Task 14.3/14.4 已由完整回归闭合。

当前最大的架构缺口已经前移到 **Sema semantic authority、TypedASTJIT consumer cutover
与 Standalone/default selection coherence**。也就是说，dynamic TypeId 这个具体坑已经
有可工作的长期边界，剩余风险是 canonical graph 还没有覆盖全语言并成为所有 backend
唯一语义输入。

## 2. 本轮静态证据范围

本轮只读取本地源码，没有依赖网络材料：

- Clang 22.1.8：`D:\LLVM\llvm-project-22.1.8.src\clang`；
- daScript：`D:\Workspace\AngelscriptProject\Reference\daScript`；
- 当前实现：`D:\as-cta\Plugins\Angelscript`；
- OpenSpec：`D:\as-cta\openspec\changes\refactor-as-canonical-typed-ast-compiler`。

Clang 对照的关键证据：

- `clang/include/clang/AST/ASTContext.h:220`：`ASTContext` 持有 long-lived AST
  nodes，并对类型使用 FoldingSet/uniquing；
- `clang/include/clang/AST/TypeBase.h:937`：`QualType` 是 unqualified type 与
  qualifier bits 的组合；
- `clang/include/clang/AST/Expr.h:112`：`Expr` 直接带 `QualType`、value kind 与
  object kind；
- `clang/include/clang/AST/DeclBase.h:1462`：`DeclContext` 建模声明作用域；
- `clang/include/clang/Sema/Sema.h:855`：Sema 负责语义分析与 AST building；
- `clang/lib/Parse/ParseAST.cpp:114` 与 Parser 的 `Sema &Actions`：Parser 驱动 Sema
  actions；
- `clang/lib/CodeGen/CGStmt.cpp:61`：CodeGen 从 `const Stmt*` 读取已完成语义的树。

daScript 对照的关键证据：

- `include/daScript/ast/ast_typedecl.h:42`：`TypeDecl` 是 rich、mutable、pointer-rich
  的编译期 semantic type tree；
- `include/daScript/simulate/debug_info.h:391`：运行期 `TypeInfo` 持有
  `StructInfo*`、`EnumInfo*`、子 `TypeInfo*`、flags、size 与 hash；
- `src/ast/ast_debug_info_helper.cpp:251`：`makeTypeInfo` 明确完成
  `TypeDecl -> TypeInfo` lowering，并按 mangled name 复用运行期描述；
- `src/ast/ast_debug_info_helper.cpp:257`：`tDistinct` 在这个边界被擦除到 underlying
  type，说明编译期语义类型和运行期表示并不相同；
- `src/ast/ast_simulate.cpp:3687`：`Program::simulate` 生成 global/function
  runtime tables 和 `SimNode` graph；
- `src/simulate/debug_info.cpp:450`：`isSameType(TypeInfo*, TypeInfo*)` 仍做结构递归
  比较，而非只比较一个数值 ID；
- `src/builtin/module_builtin_ast_annotations.cpp:250`：hash 命中后仍调用
  `TypeDecl::isSameType` 检测 collision。

## 3. 当前 canonical frontend 的真实结构

### 3.1 已建立的正确边界

当前 maintained fork 已经形成以下核心对象：

| 层 | 当前对象 | 责任 |
| --- | --- | --- |
| Source | `asCSourceManager` | logical source、origin、offset、line table |
| Syntax/Sema | `asCParser`、`asCSema*` | 语法识别与语义事实构造 |
| Ownership | `asCASTContext` | arena、Decl/Stmt/Expr/Type 表、interner、Seal |
| Type | `asCType`、`asCQualType` | snapshot-local ref、kind、stable key、qualifiers |
| Read-only API | `asCASTSnapshot` | V1 opaque owner-tagged IDs、immutable traversal |
| Bytecode | `asCBytecodeCodeGen` | 从 sealed graph 生成 detached candidate artifact |
| Runtime install | `asSTypeRelocation`、`asCRuntimeTypeBindingTable` | stable relocation、ABI validation、generation-local resolve |

这个层次与 Clang 的精神一致，但没有复制 Clang 的 class hierarchy、C++ template
系统、PCH、Clang Modules 或 LLVM IR。`asCASTContext` 使用表 ID 而非内部 public raw
pointer，使同一套编号可服务 Public V1、verifier 和可选 DTO；这是针对 Hot Reload
和跨 Engine 场景做出的合理本地化选择。

### 3.2 Type 模型目前偏薄，但方向正确

当前 `asCType` 仅直接保存：

```text
asASTTypeRef id
asEASTTypeKind kind
primitive token
stableKey
```

`asCQualType` 组合 type ref 和 packed qualifiers。优点是 AST 不含 `asCTypeInfo*` 或
numeric `typeId`。不足是完整类型结构大量编码在 `stableKey` 与周边 Decl/ABI facts
中，而不像 Clang `Type` 或 daScript `TypeDecl` 那样直接拥有结构化 template/function
type edges。

这不要求现在改成 daScript 式 raw-pointer tree，但后续应遵守一个约束：

> `stableKey` 可以是 deterministic serialization，却不能只按 display spelling 或
> hash 判等；type kind、owner、template/function structure 与 qualifiers 必须参与完整
> 相等验证。

Task 14.1 已用 foreign same-index、wrong-kind、template-owner 与 deliberate collision
测试锁住这一点。

### 3.3 Sema 仍未完全成为唯一语义权威

OpenSpec 中 4.x、5.x、13.2 仍未闭合，说明当前 Canonical AST 已经可 seal、可遍历、
可生成相当多 Bytecode，但部分 declaration/expression/lifetime/control facts 仍从
transient `asCScriptNode` 或 legacy builder/compiler 状态转换而来。风险不是“用了
parser node”这件事本身，而是 backend 是否还需要重新推断：

- overload/callee/receiver；
- conversion 和 argument order/provenance；
- temporary materialization/cleanup；
- control transfer target/phase；
- generated declaration/list factory/import/global lifecycle。

最终 cutover 标准应是：parser node 可以作为解析/错误恢复输入，但 sealed AST 已包含
backend 所需的全部语义事实。只要 CodeGen 或 TypedASTJIT 还要重新做上述裁决，就不能
把 4.x/5.x/13.2 视为完成。

## 4. Clang、当前实现、daScript 的逐项对比

| 维度 | Clang | 当前 Canonical AST | daScript |
| --- | --- | --- | --- |
| AST owner | `ASTContext` | `asCASTContext` | GC-managed AST nodes / Program |
| Type reference | interned `Type*` + `QualType` bits | opaque `asASTTypeRef` + `asCQualType` | mutable `TypeDeclPtr` graph |
| Parser/Sema | Parser calls Sema actions | 目标相同，仍在迁移 residual legacy walks | 多 inference/visitor passes 修改 AST |
| Expr semantics | Expr 带 QualType/value/object kind | Expr 带 QualType/value category/callee/control facts | Expression 持 TypeDeclPtr，passes 归一化 |
| Read-only boundary | Sema 完成后由 CodeGen 读 const AST | `Seal()` + verifier 明确冻结 | 没有完全相同的 snapshot seal API |
| Runtime type | CodeGen/target lowering 自己映射 | `asCRuntimeTypeBindingTable` 映射到 AS Runtime | `makeTypeInfo` 映射到 `TypeInfo*` |
| Execution form | LLVM IR / object | AS Bytecode / TypedASTJIT | SimNode interpreter / AOT / JIT |
| Hash 角色 | uniquing/folding/index | accelerator/checksum，完整 key 权威 | lookup/semantic/mangled hash，多处仍结构校验 |
| Public snapshot | tooling 通常直接用 Clang AST/lifetime | versioned POD views + owner-tagged opaque IDs | AST/RTTI API 更 pointer-rich |
| Hot Reload fit | 非核心设计目标 | generation lease 是一等需求 | 需要宿主另加 generation/remap ownership |

从这个对比看，当前实现不应该继续向“复制 Clang”扩张，也不应该退回“所有地方保存
Runtime pointer”的 daScript 风格。适合本项目的是混合取长：

- 采用 Clang 的 source/Parser/Sema/ASTContext/read-only CodeGen 边界；
- 采用 daScript 的 explicit compile-type -> runtime-type lowering 和 execution direct
  binding；
- 保留本项目独有的 pointer-free stable identity、Public V1 opaque IDs、contained
  Engine 和 Hot Reload generation lease。

## 5. 动态 TypeId：问题在哪里

### 5.1 当前分配语义

`asCScriptEngine::GetTypeIdFromDataType` 的行为很明确：

- primitive 使用固定 ID；
- object/enum/funcdef/typeinfo 的 `typeId` 初始为 `-1`；
- 第一次请求时消费当前 Engine 的 `typeIdSeqNbr++`；
- ID 合并 script object/template/app object/handle/const-handle flags；
- 写入该 Engine 的 `mapTypeIdToTypeInfo`；
- TypeInfo 生命周期结束后从 map 移除。

因此 numeric TypeId 是：

- Engine-local；
- lazy and access-order dependent；
- generation/lifetime scoped；
- public embedding ABI 可观察；
- 不适合跨 Engine、跨 generation、Cache、Provider 或 detached artifact identity。

### 5.2 真正危险的混用

同一个整数当前出现在三类语义里：

| 类别 | 例子 | 应有处理 |
| --- | --- | --- |
| metadata-only | `COPY`、property-owner metadata (`ADDSi`/`LoadThisR`) | durable artifact 保存 size 或 stable owner/property key；安装后可只留 size/offset |
| Runtime type target | `Cast`、需要当前 TypeInfo 的执行行为 | 安装时解析为 current ID、pointer 或 compact binding slot |
| public-ID projection | `TYPEID`、`SetListType`、embedding reflection | 只在 candidate install/公开 API 调用时投影当前代 numeric ID |

VM 不需要在每条指令执行时按 stable key 搜索。正确成本模型是：

```text
build/install: stable lookup + complete ABI validation（较慢但一次性）
execution:     pointer / offset / slot / current ID（保持热路径直接）
```

### 5.3 不采用的方案

#### 确定性 eager TypeId

按名称排序分配只能让一个封闭注册集合可重复。第三方 bindings、template instances、
不同 host profile 和 Hot Reload 同名双 revision 都会破坏这个前提。它可用于测试，但
不能成为 canonical identity。

#### hash-derived TypeId

32-bit public ID 已编码对象/handle flags；剩余空间无法免碰撞。同一 nominal key 的 A/B
ABI revisions 又必须并存。换成 64-bit 也只降低碰撞概率，不解决 lifetime identity，
仍需要完整 descriptor equality。

#### 全部改成 `asCTypeInfo*`

active VM/JIT 下 direct pointer 很合适，但不能进入 Public AST、Cache、Provider key、
detached artifact 或跨 Engine transport。pointer 是 Runtime binding 的结果，不是
canonical identity。

## 6. 当前已实现的 TypeId 改造

### 6.1 Stable identity 与 Runtime compatibility 已拆分

`asSTypeABIKey` 当前覆盖：

- stable type key；
- target profile / native environment；
- canonical kind / qualifiers；
- object flags；
- byte size / alignment；
- full layout/member signature；
- full behaviour/call signature；
- non-authoritative `layoutHash`。

`Equals()` 比较完整 fields，不使用 hash 作为 equality authority。Runtime resolver 会
拒绝 missing、ambiguous、wrong-kind、wrong-profile、wrong-native-environment 和完整
ABI mismatch。

### 6.2 Detached relocations 已不携带 TypeId/pointer/TypeRef

`asSTypeRelocation` 使用：

- complete expected ABI；
- stable member/function identity；
- relocation use kind；
- owning function ordinal；
- bytecode dword operand location；
- candidate-local exact target function ordinal。

这满足 detached boundary 不依赖 snapshot-local TypeRef、Engine pointer 或 numeric
TypeId 的要求。

### 6.3 TypeId 已推迟到 candidate transaction

Canonical CodeGen artifact 当前有 `PreparePendingTypeIds`、
`CommitPendingTypeIds`、`ResolveAndPatchTypeRelocations` 和 `Abandon`：

- emission 不立即调用 `GetTypeIdFromDataType` 污染 Engine sequence/map；
- resolve-all 后给 candidate 规划 local numeric projections；
- 只有 commit 才把完整 projection 发布到 Engine map；
- failure/abandon 回滚 slots、maps、candidate objects；
- property/function/list-pattern 资源都使用显式 relocation。

匿名 list-pattern helper 是一个重要边界例子：它不是 public semantic type，不应伪造
StableTypeKey/TypeId。当前使用 `asTYPE_RELOC_LIST_PATTERN_TARGET`，以 owning object ABI
和 exact list factory function 表达 durable identity，并只回滚本 candidate 新建的
anonymous helper。

## 7. 已闭合的 generation aggregate

### 7.1 代码现状

当前 `asCModule::Build()` canonical path 在 candidate 内先完成：

```text
build candidate module
    -> seal + verify pending AST
    -> detached asCBytecodeCodeGen::Generate(candidate)
    -> resolve complete stable relocation set
    -> freeze immutable Runtime binding table
    -> prepare snapshot + generation carrier
    -> under astSnapshotLock retire A / promote B / exchange snapshot
       / update digest, key and current marker
```

同时：

- `asSBytecodeCodeGenArtifact::runtimeTypeBindings` 在 relocation resolve 后冻结并转移给
  candidate `asCRuntimeTypeGeneration`；
- same-module replacement 通过 retired module carrier 保留 A 的 executable、type、global、
  import inventories；
- `asCASTSnapshot` 持有 generation snapshot lease；外部 function ref / Context::Prepare
  持有 execution lease；
- function 内部不强引用 generation，避免
  `generation -> function -> generation` ownership cycle；
- executable promotion、snapshot exchange、generation key/current marker 在同一个
  `astSnapshotLock` publication critical section 内完成。

因此 Hot Reload A/B 的 generation lifetime coherence 已由 14.4 闭合：新 reader 只见
B，old snapshot/prepared execution 继续使用 A，失败的 B 不改变 A，最后一个 A lease
释放后才销毁 retired resources。

### 7.2 已采用的目标对象

实现采用 fork-internal `asCRuntimeTypeGeneration` 与 current/retired module carrier
共同组成 generation aggregate。类本身持有 frozen bindings、retired carrier 与 lease
state；module 侧同一 publication protocol 持有 snapshot/key/publisher/digest：

```text
asCRuntimeTypeGeneration
    immutable asCRuntimeTypeBindingTable
    retired asCModule carrier
    retirement/ref-count state

current asCModule publication state
    generation key / provenance / publisher / digest
    current executable function/type/global/import inventories
    sealed asCASTSnapshot / owned ASTContext
    generation snapshot/execution leases
```

`asCModule` 持有 current generation handle 和 build orchestration state。Hot Reload B
在 publication 前完成：

1. parse/Sema/seal/verify；
2. detached CodeGen；
3. resolve all stable relocations；
4. assign candidate-local public IDs；
5. construct immutable Runtime binding view；
6. construct public snapshot；
7. run all failure-injection points；
8. single current-generation exchange。

交换后：

- 新 acquire/lookup 只见 B；
- A 的 lookup visibility 被撤销，但 A objects/ID map/bindings 不被就地 retarget；
- 已持有 A snapshot 或正在执行 A function 的 reader 保持 A lease；
- A 最后一个 lease 释放后统一移除旧 TypeId map dependencies 并销毁 old resources。

### 7.3 Ownership cycle 处理

实现没有让“generation owns functions，同时每个 function 强引用 generation”，从而
避免 cycle：

- function 保存 non-owning generation token；
- external function reference / execution context 获取 generation execution lease；
- public snapshot 保存同一 generation snapshot lease，而不是只保存 ASTContext；
- module current handle 与外部 leases 共同决定 generation retirement；
- generation 销毁时按现有 Runtime ownership 顺序释放 functions/globals/types/bindings。

这不是仅把 binding table copy 到 `asCModule`：prepared execution、concurrent
Acquire/publish、failed B、same-name/different-layout A/B、discard/recreate 与 empty rebuild
均有独立测试。详见
`reviews/canonical-runtime-type-generation-lifecycle-2026-08-27.md`。

## 8. 整体进展重评

OpenSpec artifact 状态为 complete，表示 proposal/design/specs/tasks 已齐全，不表示
实现完成。`tasks.md` 当前是 **125 项中 82 项 checked、43 项 unchecked**。43 项不是
43 个互相独立的新功能，其中 9.x/10.x/13.x/14.x 大量是同一 cutover 的分层验收；
不能据此直接换算线性完成百分比。

按架构阶段更准确的进展如下：

| 阶段 | 判断 | 说明 |
| --- | --- | --- |
| AST foundation / Public V1 | 基本成形 | SourceManager、Context、opaque owner IDs、Seal、public views 已有较强覆盖 |
| Stable type identity | focused 完成 | 14.1 checked，Type/TypeIdentity/TypeSema 19/19 |
| Runtime binding compatibility | 实现完成、总 gate 未完成 | focused 10/10；Standalone 仍 8/21，14.2 不应勾选 |
| Detached relocation transaction | focused 完成 | 六类 relocation 逐项 failure injection；transaction 20/20、ProductionCodeGen 111/111；14.3 checked |
| Generation aggregate / Hot Reload | focused 完成 | module-owned binding view、snapshot/execution lease、atomic retire/promote；14.4 checked |
| Sema semantic authority | 部分完成 | residual parser/legacy semantic reads 仍在，4.x/5.x/13.2 未闭合 |
| TypedASTJIT canonical consumer | 部分完成 | canonical snapshot capture 已接入，但 HIR reads/eligibility/dependency/cleanup migration 未清零 |
| Default cutover | 提前打开但尚不健康 | Engine 默认 CANONICAL，Standalone 与 broad gates 证明切换早于完整 closure |
| HIR 物理删除 / LEGACY 原生链隔离保留 | 未完成 | TypedSemantic HIR 的 production/test consumers 尚未清零；AngelScript 原生 `asCScriptNode`、Parser、Builder、Compiler 和显式 LEGACY 选择不属于删除范围，CANONICAL 也不得把它们作为语义输入或静默 fallback |
| Final verification | 未开始完整闭环 | 14.6、10.9、12.2、12.4 仍需 StaticJIT/Cache/Standalone/focused/All 和 durable scans |

## 9. 当前验证证据

本轮之前已完成并复核的关键结果：

| Gate | 结果 | Report |
| --- | ---: | --- |
| Canonical type identity matrix | 19/19 PASS | `Saved/Tests/canonical-type-identity-matrix/20260827_004555_981_95d615aa/Report/index.json` |
| Runtime type binding focused | 10/10 PASS | `Saved/Tests/canonical-runtime-type-binding-final-focused/20260827_010535_347_bb86d11f/Report/index.json` |
| Type regression | 19/19 PASS | `Saved/Tests/canonical-runtime-type-binding-type-regression/20260827_010859_957_57ab0264/Report/index.json` |
| Authored-source TypeId transaction | 17/17 PASS | `Saved/Tests/canonical-typeid-authored-source-fixture/20260827_013839_880_adb60885/Report/index.json` |
| ProductionCodeGen closure | 111/111 PASS | `Saved/Tests/canonical-production-relocation-closure/20260827_024626_196_6dadaceb/Report/index.json` |
| Anonymous list helper rollback | 1/1 PASS | `Saved/Tests/canonical-listpattern-rollback-green/20260827_025055_067_d32f3648/Report/index.json` |
| Complete CodeGen transaction | 19/19 PASS | `Saved/Tests/canonical-type-relocation-transaction-final/20260827_025133_270_4e1c7484/Report/index.json` |
| Six-class relocation transaction | 20/20 PASS | `Saved/Tests/canonical-relocation-matrix-full-transaction/20260827_043434_164_c9fad9ce/Report/index.json` |
| ProductionCodeGen final relocation regression | 111/111 PASS | `Saved/Tests/canonical-relocation-matrix-production-regression/20260827_043507_255_e1b56025/Report/index.json` |
| Module CanonicalAST Snapshot | 9/9 PASS | `Saved/Tests/canonical-relocation-matrix-module-snapshot-regression/20260827_043544_787_a2f5b695/Report/index.json` |
| HotReload CanonicalAST | 12/12 PASS | `Saved/Tests/canonical-relocation-matrix-hotreload-regression/20260827_043616_544_f5382824/Report/index.json` |
| Standalone Debug | 8/21 PASS | `Saved/Tests` 下 `canonical-runtime-type-binding` 对应报告；失败属于不完整 default cutover，仍是正式 gate failure |

最后一项仍是正式红灯；前四项新增结果已证明 14.3/14.4 的 failure atomicity、A/B
lifetime、aggregate publication 与 wildcard public TypeId 成功投影。

## 10. 建议的剩余实施顺序

### P0：修复 Standalone/default selection coherence

当前 Engine constructor 默认 CANONICAL，而 Standalone 测试仍要求 LEGACY，且进入
canonical 后 array/dictionary/member/HIR/cleanup 路径失败。需要做一个明确选择：

- 在 cutover gates 全绿前恢复默认 LEGACY、以配置显式启用 CANONICAL；或
- 保持默认 CANONICAL，但必须立即完成 Standalone 所暴露的 Sema/CodeGen coverage。

OpenSpec 10.2 原本要求 Tasks 1–9 通过后再改默认，因此从 contract 一致性看，默认切换
应由 10.x gate 驱动，不能让一个提前设置掩盖未完成项。

### P0：按 semantic families 关闭 Sema 与 CodeGen

建议顺序：

1. declaration/type/template/list/import/global facts；
2. calls、receiver、argument plan、conversion；
3. structured control target/phase；
4. materialization/cleanup/exception/suspend；
5. generated lifecycle/accessors/defaults；
6. debug/coverage/timeout/source maps。

每一族先断言 sealed public AST facts，再做 CodeGen/VM parity，遵守 Gate 0。

### P1：TypedASTJIT 去 HIR 化

只有 canonical visitors 已覆盖 eligibility、dependencies、calls、cleanup、exception、
recursion/global/import/provider contracts 后，才能移除 `GetTypedSemanticFunction()` 和
HIR capture。不能引入 AST -> HIR compatibility lowering 来延长双语义体系。

### P2：执行 14.6 boundary gate

在 Sema/Standalone/TypedASTJIT consumer gaps 收敛后，运行 14.6 要求的 Runtime/Editor
build、Frontend Type、SemaAuthority、ProductionCodeGen/transaction、Module、HotReload、
StaticJIT、Cache default-disabled、Standalone 和 durable-identity/determinism scans。
14.6 只关闭 type-identity boundary，不代替 section 12。

### P3：最终 cutover 和 legacy cleanup

依次运行 14.6、10.9、12.2、Standalone Debug/Release、12.4 All；source scans 确认
Public AST、diagnostics、optional DTO、Provider identity、detached relocation 不含 durable
Engine pointer/numeric TypeId/snapshot-local TypeRef。最后才删除 legacy production/HIR
surface。

## 11. 后续独立 change 的边界

本 change 只需要保证 canonical/detached/generation boundary 正确，不应该顺手重写所有
legacy VM 和 persistence。后续用户明确要求时，可创建
`refactor-as-runtime-type-identity-relocation`，范围包括：

- 清除 metadata-only opcode 中多余 TypeId；
- 给 Runtime type targets 统一 pointer/slot/current-ID active form；
- 统一 `TYPEID`/`SetListType` projection helpers；
- 将 `FAngelscriptPrecompiledData` 的 old TypeId/property offset relocation 升级为 stable
  owner/member key + expected ABI；
- 处理 SaveByteCode/LoadByteCode schema/version compatibility；
- 基准 compact slot、pointer 与 current-ID 的性能/内存取舍；
- 如确有必要，再设计 public embedding TypeId API 的扩展，而不是改变现有 int ABI。

本轮不创建该 OpenSpec。

## 12. 最终架构评价

当前实现已经从“在 legacy compiler 旁边再挂一份 HIR”走到了真正的 canonical frontend
雏形：Context ownership、typed nodes、Seal/verifier、public snapshot、read-only CodeGen、
detached candidate 和 stable Runtime relocation 都是正确的长期资产。

架构目前的问题集中在 semantic/consumer cutover，而不在基础模型或 dynamic TypeId：

- Sema authority 尚未覆盖全语言；
- Standalone/default selection 与完整 canonical coverage 不一致；
- default cutover 早于 Standalone/consumer closure；
- TypedASTJIT 与 legacy HIR 尚未完全解耦。

因此建议继续沿当前方向演进。generation transaction 已使 dynamic TypeId 从架构坑
降级为受控兼容投影；下一阶段的成功标准应从“又多支持几个 opcode”调整为“sealed
canonical graph 已包含该 semantic family 的全部裁决，而且 Bytecode 与 TypedASTJIT
只消费这些事实”。最后再恢复/确认默认切换并删除 legacy/HIR authority。
