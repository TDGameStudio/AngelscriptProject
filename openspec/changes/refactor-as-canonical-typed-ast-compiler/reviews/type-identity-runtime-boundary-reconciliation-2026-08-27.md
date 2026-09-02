# Canonical AST 类型身份与 Runtime 安装边界梳理（2026-08-27）

## 状态与用途

- Change：`refactor-as-canonical-typed-ast-compiler`
- 工作区：`D:\as-cta`
- 评审类型：静态架构梳理、OpenSpec scope reconciliation、implementation inventory
- 设计结论：已由用户确认，按本记录写入 proposal/design/specs/tasks
- 实现状态：类型身份 Units A–D 已闭合；14.2 的 immutable binding + Standalone gate、14.3 的六类 relocation failure matrix、14.4 的 aggregate generation ownership、14.5 的 legacy site inventory 与 14.6 的最终边界矩阵均已签收。当前 focused 证据包括 Frontend Type 20/20、SemaAuthority 301/301、ProductionCodeGen 111/111、transaction 20/20、generation lifecycle 6/6、HotReload 12/12、Module Snapshot 9/9、TypedASTJIT 70/70 与 Standalone 21/21
- Review 结论：Canonical AST 方向保留；类型身份与 Runtime 安装边界必须在默认 cutover 前闭合；完整 VM/PrecompiledData relocation 改造拆到后续 change

本文回答三个问题：

1. 当前引入的 Clang-style Canonical Typed AST 实际借鉴了什么；
2. 它与 daScript 的 AST/运行时类型体系有什么本质差异；
3. AngelScript 动态 `typeId` 应如何改造，才能不污染 AST、Cache、StaticJIT、Hot Reload 和 VM 热路径。

## Executive conclusion

当前实现不是引入 Clang AST 库，而是 AngelScript-native 的 Clang-style
前端分层：

```text
SourceManager
    -> Parser 调用 Sema actions
    -> ASTContext 统一拥有 Decl/Type/QualType/Stmt/Expr
    -> Seal + Verify
    -> Bytecode / TypedASTJIT / Public AST / optional DTO consumers
```

这个方向正确，且比直接照搬 daScript 的 mutable pointer-rich AST 更适合：

- UE Hot Reload 新旧 generation 共存；
- Public AST 的 opaque ID/versioned view；
- Cache/StaticJIT 的 pointer-free identity；
- contained generation Engine；
- module generation 的 last-good rollback。

真正的问题不是 `typeId` 动态本身，而是 legacy 路径把同一个 Engine-local
整数混用为：

- public embedding handle；
- active bytecode operand；
- property/type relocation key；
- persisted/precompiled remap identity；
- 有时甚至被误认为 canonical type identity。

批准的目标模型是：

```text
asASTTypeRef                 snapshot-local traversal identity
      |
      v
StableTypeKey               durable source-semantic identity
      |
      v
TypeABIKey                  target/profile/layout/lifetime compatibility
      |
      v
RuntimeTypeBinding          immutable generation-local resolved view
      |
      v
public int typeId           current Engine/generation projection only
```

动态解析集中在 detached candidate 的 install/publication 阶段。VM 执行时继续
使用已经解析好的 pointer、offset、compact slot 或当前代 numeric ID，不按 stable
key 每条指令查名字/hash。

## 1. 当前 Clang-style AST 体系

### 1.1 借鉴的是阶段和所有权，不是 Clang 类型

设计依据是 `design.md` 的以下边界：

- `SourceManager` 区分 logical source identity 与 snapshot-local FileID；
- Parser 只识别语法并调用 Sema actions；
- Sema 决定 lookup、overload、conversion、receiver、argument plan、lifetime、cleanup 和 control target；
- ASTContext arena/表统一拥有节点；
- Seal 后 backends 只读；
- implicit conversion、temporary、cleanup、generated call 等成为显式 AST facts；
- 不链接 `clangAST`/`clangSema`，不复制 Clang class hierarchy、PCH/module/template breadth。

当前主要文件：

| 责任 | 路径 |
| --- | --- |
| Snapshot-local type model | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_ast_type.h/.cpp` |
| Context/interner | `.../as_ast_context.h/.cpp` |
| Decl/Stmt/Expr | `.../as_decl.*`, `.../as_stmt.*`, `.../as_expr.*` |
| Sema | `.../as_sema*.h/.cpp` |
| Runtime bridge | `.../as_runtime_type_bridge.h/.cpp` |
| Bytecode backend/artifact | `.../as_bytecode_codegen.h/.cpp`, `.../as_bytecode_codegen_artifact.h` |
| Public snapshot | `.../as_ast_public_view.*`, `.../as_module.*`, public `Core/angelscript.h` |

### 1.2 Type/QualType 当前形态

当前 `asCType` 是：

```text
snapshot-local asASTTypeRef
asEASTTypeKind
primitive token
stableKey spelling
```

当前 `asCQualType` 是：

```text
asASTTypeRef
packed const/handle/auto-handle/reference/in/out/inout qualifiers
```

这符合 Clang 的 `Type` 与 `QualType` 分离原则，但比 Clang/daScript 的完整类型
结构薄。当前 `stableKey` 已避免保存 `asCTypeInfo*`/numeric `typeId`，并覆盖
namespace/template spelling；它仍需要与 type kind、template structure、qualifier、
owner 和 ABI/layout compatibility 一起验证，不能把一段 display string 或其 hash
单独当作完整身份。

### 1.3 Runtime bridge 与 binding table 已分层，但 artifact/publication 尚未接入

`asCRuntimeTypeBridge` 已统一调用 `asCRuntimeTypeBindingTable::ResolveCanonicalType`，
通过 stable key 在 candidate transient types、`GetTypeInfoByDecl`、
`GetTypeInfoByName`、object types、funcdefs 和 modules 中收集候选，去重后拒绝
歧义，并验证 canonical type kind，不再直接返回第一个同名 `asCTypeInfo`。

新增的 `asCRuntimeTypeBindingTable` 可以 capture/比较 complete `asSTypeABIKey`，
一次性解析 `asCDataType`、`asCTypeInfo*`、layout/behaviour signatures、property/
function target、offset 和 current public type ID，成功后冻结，失败时不提交任何
slot。`asSTypeRelocation` 本身仍保持 pointer/typeId/TypeRef-free。

优点：

- AST/public/cache identity 不含 Engine pointer/typeId；
- candidate types 可以 shadow previous generation；
- typedef 保留 source identity，而 VM storage 可 lower 到 alias；
- current Engine resolution 与 snapshot lifetime 已有明确概念边界。

不足：

- candidate discovery 仍以 name/Format scan 为主，尚未由 module-owned stable index 直接供给；
- detached CodeGen artifact 尚未生成/消费 `asSTypeRelocation`；
- property/function/type relocation 仍分散在 CodeGen、module remap、PrecompiledData；
- module executable、snapshot、resolved type view 尚未完全成为一个 aggregate transaction。

### 1.4 当前 AST 架构成熟度判断

不建议推倒 AST node/context/snapshot 架构。应保留：

- SourceManager；
- compact node/type IDs；
- Seal/verifier firewall；
- read-only traversal/query/dump；
- public snapshot lease；
- candidate module；
- stable declaration/type identity；
- contained generation ownership。

默认 cutover 的主要阻塞仍是：

- Sema 尚未完全退出 residual parser-node semantic walk；
- Canonical Bytecode/TypedASTJIT consumer coverage 未闭合；
- executable/snapshot/identity/Runtime binding 未完全原子发布；
- legacy HIR/asCScriptNode production authority 尚未退休；
- final focused/All gates 未完成。

类型身份 reconciliation 是这些 seam 的一部分，不是另起一套 AST。

## 2. 与 daScript AST/类型体系对比

本地参考：`Reference/daScript`。

### 2.1 daScript 的 TypeDecl 是 rich mutable semantic type tree

`include/daScript/ast/ast_typedecl.h` 中的 `TypeDecl` 直接包含：

- base type；
- `Structure*` / `Enumeration*` / `TypeAnnotation*`；
- first/second/argument types；
- tuple/variant argument names；
- fixed dimensions 和 type-macro expressions；
- ref/const/temp/smart pointer 等 flags；
- size/alignment/stride；
- copy/move/delete/POD/GC traits；
- exact/parameterized equality；
- mangled/semantic/lookup hashes。

每个 daScript `Expression` 直接持有 `TypeDeclPtr type`。Inference、sanitize、
visitor passes 在编译期修改/替换这些节点。它比当前 `asCType` 表达力强，但 AST、
semantic inference、layout 和运行时内存语义耦合更紧。

### 2.2 daScript 的 hash 不是统一稳定 type ID

daScript 至少区分：

| Hash | 实际语义 |
| --- | --- |
| `getLookupHash` | 同一编译环境内 lookup；会混入 `Structure*`/`Enum*`/Annotation pointer，不能持久化 |
| `getSemanticHash` | 递归内容/语义 fingerprint |
| `getMangledNameHash` | mangled spelling 的 64-bit hash |

因此不能把 daScript 解释为“用 stable hash 代替 AS typeId”。其中
`getLookupHash` 明确包含进程内指针；semantic/mangled hash 也仍需碰撞和完整内容
校验。

### 2.3 daScript 执行阶段仍然生成 Runtime TypeInfo 指针

`src/ast/ast_debug_info_helper.cpp` 的 `makeTypeInfo` 把 `TypeDecl` 转成运行时
`TypeInfo`，记录结构/枚举、子类型、flags、size 和 hash。`SimNode_TypeInfo` 直接
持有并返回 `TypeInfo*`；call/GC/debug/string 等 SimNode 也携带 `TypeInfo**`。

所以 daScript 的实际分层也是：

```text
TypeDecl + semantic/mangled identity
            |
            v
runtime-owned TypeInfo*
            |
            v
SimNode hot-path direct pointer access
```

### 2.4 借鉴与不照搬

值得借鉴：

- rich structural type description；
- mangled identity 与 semantic fingerprint 分开；
- AST type 降到 runtime type object 的明确边界；
- execution path 使用预解析 `TypeInfo*`；
- hash 用于索引/验证，不承担唯一 lifetime identity。

不直接照搬：

- AST/nominal types 跨 generation 使用 raw pointers；
- Seal/publish 后仍允许 type tree mutation；
- 把 target layout、GC/copy/delete 全塞进 durable semantic identity；
- 把 pointer-derived lookup hash 当 Cache/Provider identity；
- 让 old generation 重新解析 mutable current module state。

### 2.5 对比结论

| 维度 | 当前 Canonical AST | daScript |
| --- | --- | --- |
| Ownership | module ASTContext + snapshot lease | GC-managed AST nodes |
| Type reference | snapshot-local opaque ID + stable key | TypeDeclPtr tree |
| Post-build mutation | Seal 后禁止 | inference/sanitize 中广泛 mutation |
| Runtime lowering | bridge 到 asCTypeInfo/typeId/layout | makeTypeInfo 到 TypeInfo* |
| Durable identity | pointer-free stable keys/DTO intent | semantic/mangled hashes，部分 lookup hash pointer-local |
| Hot Reload fit | generation lease/stable cross refs | 需额外 ownership/remap 才满足本项目契约 |
| VM hot path | 可 patch pointer/offset/ID 或 binding slot | direct TypeInfo*/SimNode pointers |

## 3. AngelScript 动态 typeId 的真实语义

### 3.1 分配规则

`asCScriptEngine::GetTypeIdFromDataType` 当前行为：

- primitive 使用固定 ID；
- named/object type 的 `asCTypeInfo::typeId` 初始为 `-1`；
- 第一次请求时使用 `typeIdSeqNbr++`；
- 再 OR script object/template/app object/handle/const-handle flags；
- 写入当前 Engine 的 `mapTypeIdToTypeInfo`；
- 类型销毁时从该 map 移除。

因此 object `typeId` 是：

- Engine-local；
- lazy；
- registration/access-order dependent；
- 只在当前 `asCTypeInfo` 生命周期有效；
- 不跨 Engine/Cache/contained generation；
- Hot Reload old/new revision 需要不同 Runtime identity；
- public AngelScript embedding ABI 已可观察。

### 3.2 VM opcode 必须按用途分类

| 类别 | 典型 opcode/路径 | VM 实际需要 | 当前改造结论 |
| --- | --- | --- | --- |
| Metadata-only | `COPY` | byte size；interpreter 不读附带 typeId | durable relocation 不应以 numeric ID 表示；active VM 可只留 size |
| Metadata-only property owner | `ADDSi`, `LoadThisR` | resolved property offset；interpreter 不读附带 typeId | artifact 用 owner type + property stable key；install 后只留 offset/optional debug metadata |
| Runtime type target | `Cast` | current generation 的 target object type | install 为 `asCTypeInfo*`/binding slot/current ID；不每次 stable-key lookup |
| Public-ID projection | `TYPEID` | 对脚本/API可观察的 current numeric ID | install/slot 投影当前代 ID；不能持久化旧 Engine ID |
| Public/list ABI projection | `SetListType` | list buffer 中的 current numeric ID | install patch 或 Runtime binding 取值 |
| Embedding API | `GetTypeIdByDecl`, `GetTypeInfoById`, property/global reflection | current Engine mapping | 保持兼容；明确 ephemeral contract |

关键事实：VM 并不天然需要“每条指令动态按名字找类型”。动态的是 generation
install；执行可以是静态于该 generation 的 resolved operand。

### 3.3 PrecompiledData 已经是 proto-linker

`StaticJIT/PrecompiledData.cpp` 当前已有：

- `StoreTypeId` / `LoadTypeId`；
- `ReferenceProperty(offset, typeId)`；
- old type/offset 到 new type/offset 的 remap；
- `COPY`/`TYPEID`/`Cast`/`SetListType`/`ADDSi` 等 operand 处理。

它证明“保存时符号化、加载时重新链接”已有雏形。问题是符号表仍从 old numeric
typeId 出发。后续 dedicated change 应将其升级为：

```text
StableOwnerTypeKey
+ StablePropertyDeclKey
+ ExpectedTypeABIKey
        -> exact target Engine remap
        -> current pointer/offset/public ID
```

本 compiler change 只要求新的 canonical detached/durable boundary 不复制这个历史
错误；不在这里完成所有 legacy PrecompiledData schema/opcode 迁移。

## 4. 被拒绝的方案

### 4.1 确定性 eager typeId 分配

按 stable name 排序后顺序分配，只能让一个封闭 registration set 更可重复。
第三方 bind、template instance、不同 host/profile 和 Hot Reload old/new coexistence
都会改变集合或要求两个 live revision。它可以是测试诊断工具，不是 canonical
identity。

### 4.2 Hash-derived public typeId

不采用，原因：

- 现有 32-bit ID 高位包含 object/template/handle flags；
- 有效 sequence 空间有限，碰撞不可避免；
- 同一 nominal name 可同时存在多个 ABI/layout revision；
- public API 兼容风险大；
- 即使换 64-bit，也必须保留完整 descriptor collision verification；
- hash 是索引/fingerprint，不是 lifetime object identity。

### 4.3 所有地方直接持 asCTypeInfo*（纯 daScript-style）

在 installed active VM/JIT hot path 中可以使用 direct pointer；不能作为：

- Public AST identity；
- Cache/SaveByteCode identity；
- Provider key；
- cross-Engine artifact；
- old/new generation shared mutable binding。

因此 direct pointer 是 `RuntimeTypeBinding` 的一种 resolved representation，不是
完整架构。

## 5. 批准的分层身份模型

### 5.1 asASTTypeRef：snapshot-local

用途：

- AST compact reference/interner；
- public opaque traversal；
- one-snapshot equality。

禁止：

- 跨 snapshot 比较；
- 跨 Engine identity；
- Cache/Provider global key；
- 仅因整数相同而认为相同类型。

### 5.2 StableTypeKey：durable semantic identity

至少包含/验证：

- type kind；
- nominal declaration/owner/namespace/module identity；
- template/container arguments；
- function type result/parameters when applicable；
- source/canonical alias distinction where semantic consumers need it；
- qualifiers 由 `asCQualType` 单独组合。

Public V1 可以暴露 deterministic spelling；internal hash 只加速 lookup。完整
kind/key/structure equality 是 acceptance authority。

### 5.3 TypeABIKey：target/runtime compatibility

至少覆盖消费方需要的：

- target profile；
- native environment；
- size/alignment；
- base type revision；
- property stable identity/type/offset；
- GC/reference/copy/destructor behavior；
- calling ABI flags；
- binding/native-form relevant ABI/linkage metadata。

`StableTypeKey` 相同、`TypeABIKey` 不同表示同一 nominal type 的两个不兼容
Runtime revisions。

### 5.4 RuntimeTypeBinding：generation-local resolved view

包含：

- `asCDataType` / `asCTypeInfo*`；
- current public numeric typeId；
- layout/behaviours；
- resolved property/function/native binding targets；
- owning generation lifetime。

约束：

- build/resolve all before publication；
- publication 后 immutable；
- generation B 不 retarget generation A slot；
- old execution/snapshot lease 使 A binding/type map dependency 继续有效；
- last lease 释放全部 A resources。

### 5.5 public numeric typeId：compatibility projection

保留现有 external API 和 language-visible behavior，但明确：

- only current live Engine/generation；
- not durable/canonical；
- not hash-derived；
- not compared across Engines；
- only materialized where VM/public ABI requires it。

## 6. Canonical CodeGen/install 数据流

```text
sealed AST
   |
   v
detached asSBytecodeCodeGenArtifact
   - candidate-owned functions/types/globals/imports
   - stable type/property/function relocations
   - expected TypeABIKey/use kind/operand location
   |
   v
validate-all RuntimeTypeBindingTable build
   - candidate Engine transient types shadow old generation
   - complete key equality
   - target/profile/native environment/layout/ABI checks
   - no live module mutation
   |
   +-- failure --> Abandon candidate; last-good generation unchanged
   |
   v
patch active operands / freeze immutable binding table
   |
   v
single generation publication
   executable + snapshot + stable identities + publisher/digest/provenance
   + Runtime bindings
```

允许的 active execution representation：

- `asCTypeInfo*`/`asCObjectType*`；
- property offset；
- generation-local slot；
- current numeric typeId；
- direct native/function pointer under its existing code-image/module lease。

不允许作为 durable identity：

- publishing Engine pointer；
- publishing Engine numeric typeId；
- snapshot-local `asASTTypeRef`；
- old property offset；
- hash without complete key；
- display spelling without owner/signature/ABI proof。

## 7. Hot Reload 和 generation transaction

目标 aggregate：

```text
Generation =
    executable functions/types/globals/imports
  + sealed verified AST snapshot
  + stable declaration/type identity
  + target/profile ABI expectations
  + Runtime type/property/function binding view
  + publisher/digest/provenance/generation key
```

所有可能失败的 allocation、type resolution、layout/ABI validation、Seal、Verify、
JIT/Prepare、identity binding 和 snapshot construction 在 commit 之前完成。最终
publication 一次交换 aggregate。失败不允许出现：

- new executable + old current snapshot；
- old executable + new current snapshot；
- new snapshot + old Runtime type bindings；
- B bytecode + A property offsets/public IDs；
- slot in-place retarget 使正在执行的 A 读到 B layout。

## 8. 当前 change 与后续 change 的 scope split

### 8.1 当前 `refactor-as-canonical-typed-ast-compiler` 必须完成

- `asASTTypeRef` 明确 snapshot-local；
- stable type identity 不含 Engine pointer/numeric ID；
- complete key/hash-collision fail-closed；
- target/profile ABI/layout expectation 独立于 semantic key；
- detached canonical artifact 的 type/property/function relocation 不以 numeric ID 为 durable key；
- install validate-all before publication；
- active operands 只在 owning generation lease 下有效；
- executable/snapshot/identity/Runtime bindings aggregate publication；
- Hot Reload old/new same nominal type different revision coexistence；
- Public AST/diagnostic/optional DTO/Provider identity source scans；
- Cache V2 default-off boundary不回归。

### 8.2 后续 `refactor-as-runtime-type-identity-relocation` 才完成

- 清除所有 legacy bytecode metadata-only typeId operands；
- `Cast` 等 opcode 统一选择 pointer/slot/current-ID active form；
- `TYPEID`/`SetListType` 的系统化 projection helpers；
- `FAngelscriptPrecompiledData` 从 old typeId/offset key 迁到 stable key/ABI relocation；
- persisted schema/bytecode version transition；
- deterministic compact slot layout（如果证据证明需要）；
- public embedding type-ID API 的任何扩展/弃用；
- performance benchmark 与 memory impact；
- 与 SaveByteCode/LoadByteCode/legacy readers 的独立兼容计划。

本轮不创建该 follow-up change；需要用户明确要求后再使用 OpenSpec CLI 创建。

## 9. OpenSpec 记录改动

本轮修改：

| Artifact | 调整 |
| --- | --- |
| `proposal.md` | 增加 type identity/install scope reconciliation 和 follow-up non-goal |
| `design.md` | 扩展 Decision 5；增加五种 identity role、install flow、opcode classification、Hot Reload lease 和 scope split |
| `specs/as-canonical-typed-ast/spec.md` | 增加 cross-snapshot、cross-Engine、Hot Reload revision、public ID projection、hash alias fail-closed scenarios |
| `specs/as-canonical-compiler-pipeline/spec.md` | detached symbolic relocation、resolve-before-publish、active operand/generation lease requirements |
| `specs/as-incremental-script-cache/spec.md` | explicit prototype no-pointer/no-numeric-ID durability and different-ID target Engine remap scenario |
| `specs/as-static-jit-backend/spec.md` | contained Engine Runtime resolution ownership and ID-independent Provider output |
| `specs/as-typed-ast-jit-backend/spec.md` | snapshot + Runtime view request lease；Provider 不持久化 Engine type identity |
| `tasks.md` | 新增 remaining dependency graph 和 section 14；强化 9.1/9.6/13.6/13.8/13.11/13.12 |

已有完成 checkbox 保留历史状态。新增边界没有借旧的 2.6 green 直接标完成；section
14 全部保持 unchecked，必须按 AST-first/failure-injection/transaction gates 实现。

## 10. 实现文件图与依赖顺序

### Unit A：AST stable identity

**Files**

- Modify `.../as_ast_type.h/.cpp`
- Modify `.../as_ast_context.h/.cpp`
- Modify `.../as_runtime_type_bridge.h/.cpp`
- Add `.../Frontend/CanonicalAST/AngelscriptNativeCanonicalASTTypeIdentityTests.cpp`

**Produces**

- snapshot-local ref rejection；
- complete stable type equality；
- hash-as-index-only contract；
- cross-Engine numeric-ID independence。

**Implemented evidence (2026-08-27)**

- 新增 `AngelscriptNativeCanonicalASTTypeIdentityTests.cpp`；
- `asCASTContext::GetType` 拒绝带非零 public owner token 的 ref，避免相同数值 index 被错误解释为 internal local identity；
- Public snapshot A/B 的 type ref 具有相同 numeric value、不同 owner，B 对 A 的 ref 返回 `asINVALID_ARG`；
- type kind、complete owner spelling、template argument、qualifier 与 deliberate hash-collision matrix 已覆盖；
- 两个 Engine 通过不同 lazy allocation 顺序取得不同 public numeric type ID，但 bridge 产生相同 kind/stable key；
- focused `...Frontend.CanonicalAST.Type`：19/19 PASS；完整证据与基线失败见 `reviews/implementation-progress-2026-08-27.md`。

### Unit B：Runtime compatibility and immutable binding table

**Files**

- Add `.../source/as_runtime_type_binding.h/.cpp`
- Modify `Plugins/Angelscript/Standalone/CMakeLists.txt`
- Add `.../Compiler/CanonicalAST/AngelscriptNativeCanonicalRuntimeTypeBindingTests.cpp`

**Produces**

- `asSTypeABIKey` role；
- `asSTypeRelocation` role；
- `asCRuntimeTypeBindingTable::Build(...)` validate-all result；
- immutable generation ownership；
- stable mismatch categories。

已实现的 internal interface 固定为以下职责和名字；它们不是 public embedding ABI：

```cpp
enum asERuntimeTypeRelocationUse
{
    asTYPE_RELOC_METADATA_ONLY = 0,
    asTYPE_RELOC_RUNTIME_TYPE_TARGET = 1,
    asTYPE_RELOC_PUBLIC_TYPE_ID = 2,
    asTYPE_RELOC_PROPERTY = 3,
    asTYPE_RELOC_FUNCTION = 4,
    asTYPE_RELOC_LIST_PATTERN_TARGET = 5,
};

struct asSTypeABIKey
{
    asCString stableTypeKey;
    asCString targetProfileKey;
    asCString nativeEnvironmentKey;
    asEASTTypeKind typeKind = asAST_TYPE_INVALID;
    asDWORD qualifiers = 0;
    asQWORD objectFlags = 0;
    int byteSize = -1;
    int byteAlignment = -1;
    asCString layoutSignature;
    asCString behaviourSignature;
    asQWORD layoutHash = 0;

    bool Equals(const asSTypeABIKey& other) const;
};

struct asSTypeRelocation
{
    asSTypeABIKey expectedType;
    asCString stableMemberKey;
    asERuntimeTypeRelocationUse use = asTYPE_RELOC_METADATA_ONLY;
    asUINT functionArtifactIndex = 0;
    asUINT bytecodeDwordOffset = 0;
    asUINT targetFunctionArtifactIndex = asUINT(-1);
};

struct asSResolvedRuntimeTypeBinding
{
    asSTypeABIKey key;
    asCDataType dataType;
    asCTypeInfo* typeInfo = 0;
    asCObjectProperty* property = 0;
    asCScriptFunction* function = 0;
    int publicTypeId = -1;
    int propertyOffset = 0;
};

class asCRuntimeTypeBindingTable
{
public:
    int Build(
        asCScriptEngine* engine,
        const asCASTContext& context,
        const asCArray<asSTypeRelocation>& relocations,
        const asSRuntimeTypeBindingEnvironment& environment,
        const asCArray<asCTypeInfo*>* transientTypes,
        asCString* detail,
        const asCArray<asCScriptFunction*>* transientFunctions);
    const asSResolvedRuntimeTypeBinding* GetBinding(asUINT relocationIndex) const;
    bool IsFrozen() const;
};
```

`layoutHash` 在 target type 上重新计算，但只用于索引/诊断；`Equals` 比较完整
layout/member/behaviour values，不用 hash 决定相等或不等。`Build` 成功即 frozen；
失败时 table 为空且不得修改 Engine/module。具体 AddRef/Release 使用 maintained fork
已有内部引用协议，但 ownership 结果必须是 generation lease 最后释放 binding 所依赖
的类型/函数。

**Implemented evidence (2026-08-27)**

- 首个 wrong-kind RED 为 0/1，通过把 bridge 统一到 exact resolver 后转绿；
- complete Runtime binding matrix 为 10/10 PASS；
- 覆盖 exact/missing/ambiguous/wrong-kind/wrong-profile/wrong-native-environment/
  complete ABI mismatch、late-failure commit-none、property/function target 和
  hash-non-authority；
- 初次 Standalone 8/21 被定位为 premature product-wide CANONICAL default 造成的
  migration baseline 路由错误；恢复 LEGACY transitional default 后 Standalone
  **21/21 PASS**，explicit Canonical Cutover **12/12 PASS**；
- RuntimeTypeBinding **10/10 PASS**，Task 14.2 已关闭；命令、报告路径与失败分类见
  `reviews/implementation-progress-2026-08-27.md` 和
  `attachments/final-completion-issue-log-2026-08-27.md`。

### Unit C：Detached CodeGen relocations

**Files**

- Modify `.../as_bytecode_codegen_artifact.h`
- Modify `.../as_bytecode_codegen.h/.cpp`
- Modify `.../as_runtime_type_binding.h/.cpp`
- Add or extend Canonical ProductionCodeGen transaction tests

**Produces**

- every post-emission dependency has stable relocation；
- metadata/runtime-target/public-ID use classification；
- resolve before `Commit()`；
- per-relocation failure injection；
- no partial Engine/module mutation。

`asSBytecodeCodeGenArtifact` 当前持有：

```cpp
asCArray<asSTypeRelocation> typeRelocations;
asCRuntimeTypeBindingTable runtimeTypeBindings;
asCArray<asCTypeInfo*> pendingTypeIdTypes;
int pendingTypeIdSequenceStart;
asUINT pendingTypeIdCount;
asCArray<asCObjectType*> createdListPatternTypes;
```

Emission 只追加 relocation；installation 调用
`runtimeTypeBindings.Build(...)`，成功后按 `use` patch detached active operands。
`PreparePendingTypeIds` 在不修改 Engine sequence/map 的前提下规划 candidate-local
numeric projection；`CommitPendingTypeIds` 只在 transaction commit 内发布完整规划；
`Abandon()` 回滚 candidate slots、TypeId map、function/global/type resources 和本次创建
的 anonymous list-pattern helper。

**Implemented evidence (2026-08-27)**

- 类型、property、function、public-ID 和 anonymous list-pattern target 已进入 explicit
  relocation；
- exact target function ordinal 避免同一 candidate batch 中 same-arity/same-signature
  function 被 name search 错选；
- POD by-value source form 不再被 Runtime-normalized `const T&inout` 覆盖；
- enum/typeDef candidate discovery、null handle、array/template、automatic import、type-only
  target 与 late public TypeId projection 均已有 focused coverage；
- complete ProductionCodeGen 为 **111/111 PASS**；
- complete transaction group 为 **20/20 PASS**；
- anonymous list helper rollback 为 **1/1 PASS**；
- 六类 relocation failure injection 与完整 generation-state comparison 已签收，
  Task 14.3 已关闭；详细 report 路径见
  `reviews/canonical-type-relocation-failure-matrix-2026-08-27.md`。

14.3 的关闭建立在每个 relocation class 的命名 failure injection 和包括
module-owned Runtime binding view 在内的完整 generation-state comparison 上，不是由
broad green 推断。

### Unit D：generation aggregate publication

**Files**

- Modify `.../as_module.h/.cpp`
- Modify Runtime Hot Reload publication owner only where aggregate exchange is coordinated
- Add `Plugins/Angelscript/Source/AngelscriptTest/HotReload/AngelscriptCanonicalRuntimeTypeGenerationTests.cpp`
- Extend Module CanonicalAST Snapshot and CodeGen transaction tests

**Produces**

- aggregate publication；
- same nominal/different ABI revision coexistence；
- old lease retains old Runtime view；
- failed B keeps all of A；
- last lease releases type-ID map dependencies。

**Implemented and verified (2026-08-27)**

- `asSBytecodeCodeGenArtifact::Commit()` 通过 `SwapWith()` 把 frozen
  `runtimeTypeBindings` 转移到 candidate module 的
  `asCRuntimeTypeGeneration`；
- generation 预分配 retired-module carrier，same-module replacement 将旧代
  executable/type/global/import state 整体移入 carrier；
- `asCASTSnapshot` AddRef/Release 同代 generation，旧 snapshot 因而保活旧代
  binding view、type objects 与 public-TypeId map；
- `asCScriptFunction` 仅在 external refcount 0→1 时获取 generation execution
  lease，在 1→0 时释放，既支持 `Context::Prepare()` 后的旧代执行，又避免
  `generation -> function -> generation` 内部引用环；
- canonical `Build()` 在 `AcquireASTSnapshot()` 使用的同一
  `astSnapshotLock` 下完成 retire A、promote B、snapshot exchange、generation
  increment 与 current marker 交换；
- legacy Build、empty canonical rebuild 与 LoadByteCode replacement 均统一走
  `ResetExecutableGenerationForReplacement()`；
- generation lifecycle **6/6 PASS**、HotReload CanonicalAST **12/12 PASS**、
  Module CanonicalAST Snapshot **9/9 PASS**；原子发布改动后的
  ProductionCodeGen **111/111 PASS**、transaction **20/20 PASS**。

Unit D 的 ownership、RED→GREEN、TypeId 投影和 discard/JIT/global 边界详见
`reviews/canonical-runtime-type-generation-lifecycle-2026-08-27.md`。Unit B–D 的
type-identity scope 已关闭；仍开放的 `3.4`/`13.8` 是完整 production entry-point、
multi-publisher 与 CompileFunction completeness 的 aggregate audit，不应倒推成
Runtime type binding 或 relocation 未完成。

### Unit E：boundary inventory and final gates

**Files**

- Update this review with actual implementation evidence
- Update `tasks.md` checkboxes only after exact gate completion
- No automatic creation of follow-up OpenSpec

**Produces**

- opcode/use inventory；
- source scans；
- focused result matrix；
- explicit deferred legacy VM/PrecompiledData scope。

Dependency：A -> B -> C -> D -> E。TypedASTJIT consumer closure may start after B but
cannot close its production lease/Provider tasks before D.

## 11. `GetTypeIdFromDataType` 与旧 relocation inventory（2026-08-27）

### 11.1 Canonical CodeGen / Runtime binding

| Source | 当前 site | 分类 | 结论 |
| --- | --- | --- | --- |
| `as_bytecode_codegen.cpp:8821` | 仅有“不 eager 调用”的说明；canonical emitter 无 direct call | boundary | numeric projection 已移到 candidate plan/commit |
| `as_runtime_type_binding.cpp:203` | `ExistingPublicTypeIdProjection` | public-ID projection | 只读取/请求当前 generation 的公开 projection，不参与 stable equality |

Canonical detached relocation 中没有 direct eager `GetTypeIdFromDataType` 调用。这是本
change 应保持的边界。

### 11.2 LEGACY compiler direct sites

以下 line inventory 来自
`Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp`。
同一 opcode 的多个 source-form emit sites 合并列出，但每个当前 direct-call line 都在表
中出现：

| Lines | 形式 | 分类 | 后续处理 |
| --- | --- | --- | --- |
| 2857, 2862, 2883, 2888, 2893, 2916, 2918, 2935 | semantic observation payload 的 actual/parameter/source/target/string TypeId | public-ID projection / diagnostic observation | legacy shadow observer；不得成为 canonical identity |
| 4475, 4591, 4613, 6741, 6782, 6797, 7138, 7179, 7194, 7261, 7319, 7558, 7581, 7592, 14824, 18947, 18953 | `asBC_ADDSi` property owner TypeId | metadata-only | Runtime 只需要 resolved offset；后续 legacy relocation change 可去掉/slot 化 |
| 4482, 10528, 10560 | `asBC_COPY` TypeId | metadata-only | active interpreter 主要需要 size/handle shape；持久化仍用 old ID remap |
| 5202 | `asBC_TYPEID` | public-ID projection | 必须保留当前 Engine/generation observable numeric value |
| 7475 | init-list recursive element/list-pattern TypeId argument | public-ID projection / anonymous Runtime resource boundary | canonical path 已使用 explicit list-pattern relocation；legacy path 留给后续 change |
| 7777 | `asBC_SetListType` | public-ID projection | list buffer ABI 写入 current ID；不能持久化 producer Engine ID |
| 10990 | `asBC_Cast` | Runtime type target | install/restore 后必须指向 target generation 的 type；可用 pointer/slot/current ID |

### 11.3 SaveByteCode/LoadByteCode reader

| Source | Site | 分类 | 结论 |
| --- | --- | --- | --- |
| `as_restore.cpp:3861` | `ReadUsedTypeIds` 将 serialized datatype 投影为 target Engine TypeId | public-ID projection / linker remap | 是 load-time target projection，不是 durable equality |
| `as_restore.cpp:4037-4044`, `6629-6634` | `TYPEID`, `Cast` remap | public-ID projection / Runtime target | 两种语义共用旧 numeric operand，需要后续 schema 拆分 |
| `as_restore.cpp:4045-4078`, `6635-6662` | `ADDSi`, `LoadThisR`, `LoadRObjR`, `LoadVObjR` type/offset remap | metadata-only property-owner relocation | durable identity 应是 owner + property stable key + ABI |
| `as_restore.cpp:4079-4107`, `6663-...` | `COPY` remap并重算 size | metadata-only | target platform size 是真正需要的结果 |
| `as_restore.cpp:4334-4346`, `6802-...` | `SetListType` remap | public-ID projection | target Engine current ID |

### 11.4 `FAngelscriptPrecompiledData` proto-linker

| Source | Current opcodes/sites | 分类 | 结论 |
| --- | --- | --- | --- |
| `StaticJIT/PrecompiledData.cpp:168-179` | `StoreTypeId` / `LoadTypeId` | generic old numeric relocation | 证明 save-symbolize/load-rebind 的 linker 形态已存在，但 key 仍是 old ID |
| `:215-216`, `:302-304` | `COPY` | metadata-only | load 后还需 target size；后续可改 stable type/size contract |
| `:230-232`, `:318-320` | `TYPEID`, `Cast` | public projection + Runtime target | 必须拆分用途，不能用一个 durable old-ID contract 概括 |
| `:234-252`, `:325+` | `ADDSi`, `LoadThisR`, `LoadRObjR`, `LoadVObjR`; `ReferenceProperty(offset,typeId)` | metadata-only property owner | load 已把运行时不用的 owner TypeId 置 `-1`，直接证明 numeric operand 不是 VM 必需 identity |
| `:255-256`, `:322-323` | `SetListType` | public-ID projection | load 时投影 target current ID |
| `PrecompiledData.cpp:2312` / `.h:628` | `ReferenceProperty(int Offset, int TypeId, ...)` | metadata-only durable key debt | 后续改为 StableOwnerTypeKey + StablePropertyKey + expected ABI |

### 11.5 Embedding/public reflection projections

这些 direct calls 都属于 current Engine public-ID projection，不应因 canonical identity
改造而删除：

| File:lines | API surface |
| --- | --- |
| `as_context.cpp:5927` | context variable/type reflection |
| `as_generic.cpp:81,279` | generic return/argument type IDs |
| `as_module.cpp:1402,1476` | global property and type declaration lookup |
| `as_objecttype.cpp:256,446` | template subtype/property reflection |
| `as_scriptengine.cpp:2738,3247,3286,5127,5811` | property/default-array/string/GetTypeIdByDecl/funcdef projections |
| `as_scriptfunction.cpp:596,1053,1541,1557` | local/return/parameter reflection |
| `as_scriptobject.cpp:607,622` | script-object/property reflection |
| `as_typeinfo.cpp:249,451` | TypeInfo initialization/typedef projection |

`as_scriptengine.cpp:831-842` 是 primitive fixed-ID assertions；
`as_scriptengine.cpp:4994` 是 allocator/mapper 本体，不是额外 consumer site。

### 11.6 Scope conclusion

本 change 关闭 canonical/detached/generation durable identity 和 late install correctness。
它不删除上表全部 legacy operands，也不改变 public `int typeId` ABI。上表的 legacy
VM/SaveByteCode/PrecompiledData debt 是未来
`refactor-as-runtime-type-identity-relocation` 的必需范围；未经用户明确请求，本轮不创建
也不实施该 follow-up。

### 11.7 Canonical wildcard public-ID projection closure

Task 14.3 的六类 relocation failure matrix 发现 canonical call emitter 对 `?&`
wildcard 只传递了 live value address，没有发出 generic VM ABI 要求的 hidden
`TYPEID`。这不是 durable identity 缺陷，而是 public-ID projection 成功路径缺失。

当前实现保留 actual argument 的 canonical/runtime datatype，发出
`asBC_TYPEID, 0` placeholder，并记录 `asTYPE_RELOC_PUBLIC_TYPE_ID`。完整 binding
table 在 target Engine/generation 中 resolve/freeze 后，安装器把 placeholder patch 为
current public ID；AST、StableTypeKey、TypeABIKey 和 detached relocation 都不保存该
numeric value。

生产测试同时断言 published bytecode 含 `TYPEID`，以及 generic callback 的
`GetArgTypeId(0)` 等于当前 Engine 的 `GetTypeIdByDecl("FPayload")`。这把本文件对
`TYPEID` 的“public projection”分类从设计 inventory 闭合到 canonical producer 和真实
Runtime observation。完整 RED/GREEN 与矩阵见
`reviews/canonical-type-relocation-failure-matrix-2026-08-27.md`。

### 11.8 Default-array nominal alias 的 generation-local 晚绑定

Task 14.6 的跨 Engine 测试暴露了一个不能用 numeric TypeId 修补的别名问题：
Canonical source/stable identity 使用 `TArray<int>`，而 target Engine 的
default-array 注册表面可以显示为 `int[]`。若 resolver 只比较 Runtime shorthand，
同一个语义类型会被误报 missing；若把 target Engine 的 TypeId 或 `asCTypeInfo*`
写回 stable key，则会重新引入本 review 要消除的跨 generation 污染。

当前修复只发生在 target generation 的候选解析阶段：

1. 从 candidate Engine 的 `asCDataType` 重建 registered template nominal spelling；
2. 用完整 `TArray<int>` key 做 candidate equality；
3. 在 ABI/layout/profile/native-environment 全部匹配后冻结该 Engine 自己的 TypeInfo、
   layout、behaviour、target 和 current public TypeId；
4. 不把 `int[]`、TypeInfo pointer 或 numeric ID 写入 AST、DTO、Provider identity 或
   detached relocation。

永久回归让 Engine B 先注册 `FDummy` 扰动分配顺序，证明 A/B 的 public TypeId
不同，同一个 `TArray<int>` stable key 仍分别绑定到各自的 TypeInfo，且没有跨
Engine sharing。这与 daScript 的 resolved runtime pointer 思路一致，但 lifetime 由
本项目的 immutable generation binding/lease 明确承担。

需要区分的是，局部 `TArray<int>` 默认构造仍会在 Canonical CodeGen 暴露
`DANGLING_ID construct-decl`。那是 Sema lifetime/container lowering 的开放缺口，
不是本 alias late-binding 的未完成部分，也没有被 TypedASTJIT fallback 绿灯掩盖。
完整 RED/GREEN 与非声明见
`attachments/type-identity-boundary-gate-2026-08-27.md`。

## 12. Minimum acceptance gates

### AST/type identity

- same snapshot equivalent type interns once；
- foreign same-index `asASTTypeRef` rejected；
- namespace/template/kind/qualifier alias rejected；
- hash collision/incomplete display name rejected；
- public/cache dump contains no Engine pointer/typeId identity。

### Cross-Engine

- Engine A/B registration order yields different numeric IDs；
- StableTypeKey/TypeABIKey exact match succeeds；
- Runtime binding uses target Engine B objects/ID；
- persisted/detached identity bytes independent from A/B numeric IDs。

### Hot Reload

- generation A/B same stable nominal key, different layout/ABI key；
- held A execution/snapshot uses A；
- fresh acquire uses B；
- no published slot retarget；
- final A release cleans old resources safely。

### Failure transaction

- missing type；
- ambiguous type；
- wrong kind/template args；
- wrong profile/native environment；
- layout/ABI mismatch；
- property/function stable target mismatch；
- snapshot allocation/Seal/Verify failure；
- failure before/after every install phase；
- all failures preserve last-good executable + snapshot + identities + bindings。

### Backend/persistence

- active VM operands may be pointer/offset/slot/current ID only under generation lease；
- VM hot path does no stable-key lookup per instruction；
- optional Cache prototype ignores publishing numeric IDs；
- StaticJIT Provider identity uses stable generation/content/profile/ABI metadata；
- no diagnostic dump becomes compiler/Cache/Provider input。

## 13. 验证命令边界

只使用项目入口：

```powershell
Tools\RunBuild.ps1
Tools\RunTests.ps1
Tools\RunTestSuite.ps1
```

建议 section 14 focused 顺序：

1. Frontend CanonicalAST Type/TypeIdentity；
2. Compiler CanonicalAST RuntimeTypeBinding；
3. Compiler CanonicalAST ProductionCodeGen + transaction；
4. Module CanonicalAST Snapshot；
5. HotReload CanonicalAST；
6. StaticJIT TypedASTJIT/generation identity；
7. Cache V2 default-disabled boundary；
8. Standalone Debug；
9. Runtime/Editor build；
10. `openspec validate`、`git diff --check`、durable identity source scans。

Section 14 green 不替代 section 12 的完整 focused、Standalone Release 和 All。

## 14. Task 14.6 final evidence

2026-08-27 的最终边界门禁已完成：

- Runtime/Game 与 Editor build 通过；
- Frontend Type **20/20**；
- SemaAuthority **301/301**；
- ProductionCodeGen **111/111**；
- CodeGen transaction **20/20**；
- Module Snapshot **9/9**；
- HotReload CanonicalAST **12/12**；
- StaticJIT CanonicalASTIdentity **12/12**、ProjectGeneration.Engine
  **32/32**、TypedASTJIT **70/70**；
- Cache SettingsAndShutdown/default-disabled **7/7**；
- Standalone Debug **21/21**；
- generated output、address-free dump、structured dump、AST diagnostics 与
  ASTBodySidecar determinism groups 全绿；
- AST storage、diagnostic output、optional DTO/sidecar、Provider identity 与
  detached relocation 的 durable-identity scan 均为 **0 forbidden matches**。

`as_ast_sidecar.cpp` 的本地 `asASTTypeRef(i)` 被逐项复核为 DTO type-table index 到
新 snapshot 的重建，不是可持久化或跨 snapshot identity；generation snapshot 中的
resolved pointer/current ID 也被复核为 lease 保护的 immutable active state，而不是
durable key。

完整命令结果、精确报告路径、三项 gate 内修复、一个未掩盖的 `TArray<int>` 默认
构造缺口及 scope non-claims 见
`attachments/type-identity-boundary-gate-2026-08-27.md`。据此 Task 14.6 可勾选；
这不代表 Task 10.2 默认切换或 section 12 最终 All gate 已完成。

## Final assessment

Canonical AST/Clang-style layering 应继续沿用。daScript 最有价值的参考不是某个
hash，而是它同样把 AST `TypeDecl` 降为 runtime `TypeInfo*` 后再让执行节点使用
resolved pointer。AngelScript 动态 `typeId` 也无需被消灭；它应退回到 current
Engine/generation 的 public compatibility projection。

本次真正需要新增的架构 seam 是：

```text
stable semantic identity
  -> explicit ABI compatibility
  -> validate-all generation install
  -> immutable Runtime binding lifetime
  -> active VM operands/public typeId projection
```

只要这个 seam 与 module aggregate transaction 一起闭合，动态 typeId 不会迫使 VM
在热路径做动态 name/hash lookup，也不会继续污染 AST、Cache、StaticJIT 或 Hot
Reload identity。完整 legacy VM/PrecompiledData cleanup 有独立价值，但不应再次把
当前 Canonical compiler cutover 扩张成无限范围。
