# Canonical Typed AST Compiler Implementation Re-review — 2026-08-26（第十三轮，静态架构审查）

## Review decision

当前实现结论仍是 **Request changes**。

这轮审查不否定 Canonical Typed AST 的总体方向。当前代码已经形成了有价值的迁移基础：Canonical Parser/Sema/CodeGen、sealed AST、public snapshot lease、稳定 identity、contained generation Engine、TypedASTJIT、Cache V2 原型和受控生成文件发布都已有实质实现。

但现在的实现仍是一个**边界未闭合的过渡架构**，还不能作为 production cutover 或 OpenSpec 完成归档的依据。最关键的问题不再只是语言覆盖率，而是三类 authority 没有被一个事务统一起来：

```text
source/semantic authority    canonical AST / stable identities
executable authority         module functions/types/globals/Bytecode
generation authority         StaticJIT snapshot/catalog/provider/cache
```

当前这三层可以分别成功、失败或保持旧 generation，导致“操作返回成功，但没有 Provider”“新 executable 搭配旧 AST snapshot”“部分 module 失败但整次 Generate 成功”等不可接受状态。

本轮是**纯静态 review**：没有运行 UE build、Automation、Standalone 或其他执行验证，也不把历史日志中的通过数当作当前工作树的重新验证结果。

## Review scope and working-tree state

- worktree：`D:\Workspace\AngelscriptProject\.worktrees\refactor-as-canonical-typed-ast-compiler`
- junction：`D:\as-cta`
- branch：`refactor-as-canonical-typed-ast-compiler`
- parent HEAD：`fd16e5b592111dbc1433c9f9038d5d34caa4325f`
- plugin HEAD：`ed22fbdf0fc1a3793b006bb703aeb62a7500b25a`
- review 时父仓库有 `24` 个 status entry；`Plugins/Angelscript` 子模块有 `216` 个 status entry
- OpenSpec artifact 状态：proposal/design/specs/tasks `4/4` complete
- implementation checklist：`78 checked / 41 open / 119 total`

审查覆盖：

- `proposal.md`、`design.md`、`tasks.md` 和本 change 的全部 capability specs；
- Canonical AST sidecar、module/snapshot publication、Cache restore/capture；
- matching/contained StaticJIT generation、source authority、generation snapshot、native-form catalog；
- 对应测试代码及历史 review 中声称已经关闭的架构边界。

没有修改实现代码，也没有修改 `tasks.md` 勾选状态。

## Findings summary

| ID | Severity | Summary | OpenSpec impact |
| --- | --- | --- | --- |
| F1 | P1 | matching-profile Generate 返回成功但没有生成 Provider；还可能退休已有 owned Provider 文件 | 8.4 false-complete |
| F2 | P1 | sidecar `ReadBytes` 的无符号加法可溢出，恶意长度可越界读取/触发超大分配 | 6.1/6.2 hardening 未闭合 |
| F3 | P1 | `LoadByteCode`、`RemoveFunction`、`Discard` 等 module mutation 不退休当前 AST snapshot | 13.8/13.11 未闭合 |
| F4 | P1 | canonical executable 与 AST snapshot 分两阶段发布，失败时可形成新 executable + 旧 current snapshot | 13.8 核心事务未闭合 |
| F5 | P1 | matching Generate 跳过 compile-error/null module，允许不完整 graph 部分成功 | 8.4 false-complete |
| F6 | P2 | stable native-form catalog 只被计数，不被 generator 消费；普通 primary 默认也不填充 | 8.2/8.4 false-complete |
| F7 | P2 | Cache failure diagnostic 直接遍历未持 lease 的 raw AST context | 13.8/13.9 记录与代码不一致 |
| F8 | P2 | full sidecar decode 把空 expected profile 当 wildcard | 6.1 exact-profile contract 未闭合 |

## F1 — P1：matching-profile Generate 成功但没有生成 Provider

### Evidence

`as-primary-engine-typed-ast-generate/spec.md:3-9` 要求 matching-profile TypedASTJIT Generate 读取当前 primary graph/snapshot 并完成 emit；`tasks.md:536` 的 8.4 也明确要求 generator orchestration 和 owned-output-only writes。

当前 matching 实现只做了：

1. `AngelscriptJITProjectGeneration.cpp:515-532` 检查 source authority；
2. `:534-572` Acquire 每个 module 的 AST snapshot lease；
3. `:587-589` 调用 `CountCatalogRecipes()`；
4. `:597-613` 把结果设为 `Succeeded`，然后调用 `WriteOwnedLease()`。

`WriteOwnedLease()` 在 `:377-446` 只构造：

- `CanonicalASTLease.generated.json`；
- `OwnedFiles.generated.json`。

该路径没有构造 `FAngelscriptStaticJITGenerationSnapshot`，没有调用 `GenerateStaticJITProviderArtifacts()`，也没有检查 `bHasProviderOutput`。

对照之下，contained path 在 `AngelscriptJITProjectGeneration.cpp:794-820` 会创建真正的 generator request，调用 `GenerateStaticJITProviderArtifacts()`，并在没有 Provider output 时失败。

batch helper 还有第二个断点：`GenerateProfilesSequential()` 在 `:694-700` 计算了 matching profile 的 `ProfileOutput`，但 `:701-706` 调用的是不带 output directory 的三参数 `GenerateMatchingProfile()`；该 overload 在 `:473-484` 构造 request 时没有填写 `OutputDirectory`。因此 batch matching 项即使报告成功，也可以完全不写传入的 output root。

测试锁定的是占位行为而不是产品行为：

- `AngelscriptPrimaryEngineCanonicalASTGenerateTests.cpp:470-503` 只要求 owned inventory 存在，并明确断言 `Provider.generated.cpp` 不存在；
- `:540-569` 的 sequential test 只检查 matching result 成功和 contained Engine 数量，没有验证 matching profile 目录中的 Provider/module sources。

还有一个更危险的发布后果。`WriteOwnedLease()` 调用 `FAngelscriptJITGeneratedFileStore::Publish()`；后者在 `AngelscriptJITGeneratedFileStore.cpp:755-774` 会删除旧 inventory 中被判定为 `UnexpectedOwnedFile` 的文件。如果 output directory 原先有属于同一 owner 的 Provider/module source，而本次 expected output 只剩 lease/inventory，那么 matching Generate 存在将真实 Provider 当 stale owned output 退休的路径。

### Impact

- Editor/commandlet 可以得到 `Succeeded`，但磁盘上没有可编译、可链接、可加载的 Provider；
- multi-profile Generate 的 matching profile 输出目录可能被静默忽略；
- 在已有 owned output 上重复 matching Generate，存在删掉先前 Provider 的风险；
- 8.4 当前不能保持“实现完成”的含义。

### Required correction

matching 与 contained 只能有不同的**输入提供者**，不能有不同的 backend/publish pipeline。matching path 应从 primary leases 构造完整 generation input/snapshot，然后进入与 contained path 相同的：

```text
validate complete graph
    -> resolve native recipes
    -> GenerateStaticJITProviderArtifacts
    -> require bHasProviderOutput
    -> PrepareProjectProfileOutput
    -> owned publication
```

三参数 matching overload 或 sequential helper 必须把 `ProfileOutput` 显式传下去。没有 eligible Provider 时必须是失败，而不是成功写一份 lease telemetry。

### Rereview gate

- matching Generate 真实生成 Provider manifest、provider implementation 和每个非空 AS module 的 `<StableModuleKey>.<Profile>.jit.cpp`；
- matching 与 contained 共用同一 generator/publisher；
- batch matching profile 写入指定 output root；
- 重复 Generate 不会因占位 inventory 删除已有合法 Provider；
- 测试不再把“Provider 不存在”当 Generate 成功条件。AST dump 的“不生成 Provider”测试应继续保留，但必须与 Generate 测试分开。

## F2 — P1：sidecar 长度字段可通过 `asUINT` 溢出绕过边界检查

### Evidence

`as_ast_sidecar.cpp:60-76`：

```cpp
asUINT n = 0;
if( !ReadU32(bytes, length, offset, n) || offset + n > length )
    return false;
text.Assign(reinterpret_cast<const char*>(bytes + offset), n);
offset += n;
```

`offset + n` 在 `asUINT` 上执行。以第一个 header string 为例，读取 magic/version/length 后 `offset == 12`；若编码的 `n == UINT_MAX`，`offset + n` 会回绕为 `11`，`11 > length` 可以为 false，随后 `Assign(bytes + 12, UINT_MAX)` 对短 buffer 做越界读取或尝试超大分配。

同一 helper 同时被 `asCASTReadSidecarHeader()` 和完整 `asCASTDecodeSidecar()` 使用，影响 header inspection 及完整 DTO restore。外层 `length <= kMaxBytes` 不能限制攻击者编码在 payload 内部的 `n`。

### Impact

这是 Cache/持久化输入边界上的内存安全问题，而不是普通的错误码不精确。损坏或恶意 sidecar 可以在 verifier、stable identity 和 graph admission 之前触发越界访问。

### Required correction

至少改成减法式边界检查：

```cpp
if( offset > length || n > length - offset )
    return false;
```

更合适的架构修复是引入一个唯一的 bounded cursor/reader，集中实现：

- `Remaining()`；
- `ReadU32/ReadU64`；
- `ReadBytes(maxFieldBytes)`；
- `ReadCount(maxCount)`；
- 完整消费检查。

所有 DTO field decoder 必须通过这个 reader，避免每个 helper 重复写易溢出的算术。

### Rereview gate

增加 `UINT_MAX`、`UINT_MAX-1`、边界刚好相等、截断 length、嵌套 string array/count 等 adversarial fixtures，并证明 header inspection 和 full decode 都只返回稳定错误码，不分配超预算内存、不修改 target context。

## F3 — P1：module mutation 后旧 AST snapshot 仍被报告为 current

### Evidence

snapshot acquire 本身已经使用同一把锁完成 retain，这部分方向正确：`as_module.cpp:2236-2250` 在 `astSnapshotLock` 内读取并 `AddRef()`。

问题在于 snapshot retirement 没有被纳入 module mutation protocol：

- `InternalReset()` 从 `as_module.cpp:878` 开始清空 functions/types/globals/imports，但函数体内不调用 `ReleaseCanonicalASTSnapshot()`；
- `as_restore.cpp:834` 在读取 Bytecode 前调用 `module->InternalReset()`，`:868` 在失败时再次 reset；restore 完成也不发布对应 canonical snapshot；
- `as_module.cpp:2201-2211` 的 `RemoveFunction()` 删除 module function 后直接成功返回，不退休 snapshot；
- `as_module.cpp:187-212` 的 `Discard()` 把 module 从 Engine map 移除，但 held/fresh snapshot 仍可保持 `IsCurrentGeneration()==true`；
- 对照之下，`CompileFunction(asCOMP_ADD_TO_MODULE)` 已在 `as_module.cpp:2177-2181` 正确认识到“module executable 增加函数后旧 snapshot 不再完整”，并显式退休 snapshot。

### Impact

调用者可以在 module 已被 restore、删函数或 discard 后继续 Acquire 到旧 graph，而且该 graph 仍声称是 current generation。TypedASTJIT、diagnostics、future LLVM、Cache capture 或 Editor inspection 都可能把已经不对应 executable/module inventory 的 AST 当权威输入。

### Required correction

不要简单地在所有 `InternalReset()` 开头无条件 release，因为 canonical staged rebuild 失败必须保留 last-good generation。应拆开两个概念：

```text
ResetExecutableStorage()       // candidate/private destructive work
RetirePublishedGeneration()    // public mutation commit boundary
```

所有公开 module mutation 必须声明其 snapshot policy：

- replace with a complete new generation；
- retire current snapshot；
- preserve current generation because the mutation failed before commit。

`LoadByteCode`、`RemoveFunction`、`Discard`、attached `CompileFunction` 和 canonical Build/Hot Reload 都应通过一个明确的 generation transaction，而不是分别记得调用或忘记调用 release。

### Rereview gate

针对每个 mutation 证明：成功改变 executable/module inventory 后旧 lease 可继续只读，但 `IsCurrentGeneration()==false`，fresh Acquire 不能返回不完整旧 generation；失败且没有 commit 时 last-good snapshot 与 executable 都保持 current。

## F4 — P1：canonical executable 与 snapshot 不是同一个原子发布事务

### Evidence

canonical Build 已经引入 candidate module，这是非常有价值的进展。但 commit 顺序仍然分裂：

```text
as_module.cpp:515  InternalReset() live module
:516               PromoteCanonicalBuildCandidate()
:518               AdoptPendingCanonicalAST()
:519-520           JITCompile / PrepareEngine
:521               BuildCompleted()
:523               PublishCanonicalASTSnapshot()
```

`PublishCanonicalASTSnapshot()` 在 `as_module.cpp:2356-2424`：

- seal/verify context；
- 分配 `asCASTSnapshot`；
- 最后才在 `astSnapshotLock` 下替换 snapshot。

该函数返回 `void`。若 seal/verify 或 `asNEW(asCASTSnapshot)` 失败，`:2366-2369`、`:2382-2385`、`:2389-2406` 直接 return；此时 candidate executable 已经晋升，旧 snapshot 却仍可保持 current。即使成功，`BuildCompleted()` 也发生在 snapshot publish 之前，留下可被外部观察到的 generation split window。

`PromoteCanonicalBuildCandidate()` 上方 `as_module.cpp:2605` 的注释还说 `InternalReset()` 已经 release prior generation，但当前 `InternalReset()` 实际没有做这件事，说明实现内部对事务边界本身也存在不一致认知。

### Impact

这是架构级 correctness 问题：一个 module generation 的 executable、stable identity、AST snapshot 和 generation key 不具备同生共死关系。内存不足、verifier failure 或 callback/interleaving 都能形成“新代码 + 旧 semantic graph”的状态。

### Required correction

构造一个完整的 detached generation candidate：

```text
FModuleGenerationCandidate
  - executable functions/types/globals/imports
  - sealed and verified AST context
  - already-allocated AST snapshot
  - bytecode publisher/digest/stable identities
  - generation key/provenance
  - activation/rollback plan
```

所有可能失败的分配、seal、verify、identity 和 backend validation 都在 commit 之前完成。最终 commit 在一个 module generation gate 内一次性交换 executable + snapshot + metadata；旧 snapshot 只在交换完成后标记 non-current。`PublishCanonicalASTSnapshot()` 应返回显式 status，不能静默吞掉 publication failure。

### Rereview gate

failure injection 必须覆盖 snapshot allocation、seal/verifier、JIT/Prepare、global init 和 publication 前后的边界，并证明不存在任何新 executable/旧 current snapshot 或旧 executable/new current snapshot 组合。

## F5 — P1：matching Generate 对不完整 module graph 部分成功

### Evidence

`AngelscriptJITProjectGeneration.cpp:547-551` 遍历 active modules 时，对 `bCompileError` 或 `ScriptModule == nullptr` 直接 `continue`。只要其余 module 取得至少一个 lease，`:573-613` 就可以返回 success。

其前置 freshness check 不能补足这个缺口。`AngelscriptJITSourceAuthority.cpp:292-305` 从每个 descriptor 的 `Module->Code` 构造 compiled inventory，没有先拒绝 `bCompileError`/null runtime module，因此 source inventory 可以与 descriptor code 对上，却没有证明所有 active modules 都成功编译并拥有本 generation 的 executable/snapshot。

contained path 的 generation snapshot builder 有更严格的正确行为：`AngelscriptStaticJITGenerationSnapshot.cpp:1474-1481` 遇到 null/compile-error module 会使整个 request 失败。

### Impact

多 module 项目中，一个模块 compile failure 可以被 matching Generate 静默排除，最终发布的是不完整 Provider，且 result 仍为 `Succeeded`。这破坏“complete Provider source graph”的 spec 约束，也使 output freshness 无法代表项目当前状态。

### Required correction

matching/contained 应共用一个 complete-graph validator。任何 active authoritative module 的 compile error、null runtime module、缺 snapshot、wrong generation/profile、ambiguous identity 都必须使整次 request fail closed；不能用 `continue` 形成部分成功。

## F6 — P2：native-form catalog 尚未成为 generation authority

### Evidence

OpenSpec `as-static-jit-native-call-linkage/spec.md:15-20` 要求 matching generation 按稳定 declaration/profile 从 catalog 解析 reviewed recipe，且不要求 `bCollectStaticJITCompatibilityBinds=true`。

当前实际路径是：

- `AngelscriptJITProjectGeneration.cpp:316-375` 的 `CountCatalogRecipes()` 只增加 hit/miss telemetry；
- matching path 在 `:587-613` 计数后直接写 lease manifest，完全没有把 recipe 传给 TypedASTJIT/generator；
- 真正的 generation snapshot 在 `AngelscriptStaticJITGenerationSnapshot.cpp:710-744` 仍通过 `FScriptFunctionNativeForm::GetNativeForm(Function)` 和 pointer-keyed registry 获取 native metadata；
- `StaticJITBinds.cpp:44-49` 在 `bCollectStaticJITCompatibilityBinds==false` 时会直接删除 `NativeForm`；catalog publication 位于该 guard 之后的 `:65-66`；
- `AngelscriptEngine.h:214-217` 把此 flag 明确描述为 isolated-test switch，默认 false；
- matching catalog 测试在 `AngelscriptPrimaryEngineCanonicalASTGenerateTests.cpp:449-450` 特意用 `CreatePrimaryEngine(..., true)` 打开该 flag，不代表普通 primary Engine 的生产配置；
- `AngelscriptNativeFormCatalog.cpp:237-242` 在 mutex 内从 `TMap` 取出 raw pointer 后立即释放锁。当前计数调用只判断 null，问题有限；一旦 generator 真正读取 recipe，其他插入导致 rehash 时该 pointer contract 不安全。

### Impact

stable catalog 目前是测试/telemetry side channel，不是 artifact generation 的 authority。8.2 的“real registration populates catalog”和 8.4 的“stable catalog lookup drives generation”都没有真正闭环。

### Required correction

- 把“保存 pointer-keyed BytecodeJIT compatibility form”和“发布 pointer-free reviewed catalog recipe”拆成两个独立动作；普通 real registration 应按 spec 发布稳定 recipe，不依赖 test-only compatibility flag；
- generator 输入应持有 catalog 的 immutable/value snapshot，而不是在 generation 中返回受 mutex 保护容器内部的 pointer；
- `Find` 改为 value copy、shared immutable recipe，或 catalog copy-on-write snapshot；
- exact ABI/route/profile miss 只走已审查 bridge/fallback，不能用 display spelling 推导 DLL linkage。

## F7 — P2：Cache diagnostic 遍历 raw AST context，没有 lease

### Evidence

`AngelscriptCacheCleanCapture.cpp:873-945` 的 `DescribeCanonicalSourceAuthority()`：

1. 从 `Function.module` 取 module；
2. `:877-878` 调用 `RuntimeModule->GetCanonicalASTContext()` 得到 raw pointer；
3. `:890-930` 遍历 declarations、parents 和 SourceManager。

`as_module.cpp:2335-2341` 的 raw getter 不加 `astSnapshotLock`、不 `AddRef()`、不返回 lease。snapshot publisher 可以在 diagnostic 遍历期间替换并 release 旧 context。

这还直接反驳了 `tasks.md:1029` 的进度记录：“full Runtime/Editor production search leaves raw `GetCanonicalASTContext()` calls only in CanonicalAST white-box tests”。当前调用位于 Runtime Cache production source，不是 test。

### Impact

失败诊断路径也必须满足生产内存安全。Hot Reload/snapshot replacement 并发时，这段只为拼接错误信息的代码可能读已释放 context；而且历史 checklist 会让后续 reviewer 误以为 raw access 已清零。

### Required correction

该函数应先 `AcquireASTSnapshot(asAST_API_VERSION_1)`，在完整 diagnostic traversal 期间持有 lease，最后 release；更长期应将 `GetCanonicalASTContext()` 限制为 pending-build/internal white-box API，production consumer 只能使用 public lease/view 或显式 internal leased snapshot handle。

## F8 — P2：full sidecar decode 将空 expected profile 当 wildcard

### Evidence

`as_ast_sidecar.cpp:581-588`：

```cpp
if( !functionKey.Equals(expected.functionKey) )
    return asAST_SIDECAR_FUNCTION_KEY_MISMATCH;
if( expected.profile.GetLength() && !profile.Equals(expected.profile) )
    return asAST_SIDECAR_PROFILE_MISMATCH;
```

因此 `expected.profile == ""` 时，任何 payload profile 都能进入完整 graph decode。`as_ast_sidecar.h:46-48` 说明 production Cache admission 会先读 header，以避免空 expected profile 充当 wildcard；当前 ExactStartup 调用也传入非空 exact profile，所以现有 production exposure 低于 F2。

但 full decode API 本身仍是公开的 Runtime helper，参数名和用途是 expected identity，而不是 inspection。现有 `AngelscriptCacheASTBodySidecarTests.cpp:18-64` 只覆盖 non-empty wrong profile；`:439-463` 验证的是 header inspection。没有“encoded profile 非空 + expected profile 为空”的 full-decode negative。

### Impact

API 的 fail-closed contract 依赖所有调用者先做一层额外约定，未来新 consumer 很容易绕过 exact-profile guard。Cache/profile identity 属于 artifact correctness 边界，不应存在隐式 wildcard。

### Required correction

full decode 应要求 exact non-empty profile 并无条件比较；仅 `asCASTReadSidecarHeader()` 提供无 expected identity 的 inspection。若确实需要 wildcard，应另建名称明确、不能用于 restore 的 diagnostic API。

## Architecture review

### 总体判断

架构方向是对的，不建议推倒重来；当前需要的是**收束边界和统一事务**。Canonical AST 本身已证明有能力成为 Bytecode、TypedASTJIT、Cache inspection 和未来 LLVM 的共同语义载体。真正阻碍 production cutover 的，是几个关键 seam 仍各自拥有一套局部成功条件。

可以把当前状态概括为：

```text
正确的核心模型
  + 很多已验证的局部组件
  + 两套分叉的 generation orchestration
  + 不完整的 module generation transaction
  + 尚未成为 authority 的 stable catalog
= 可继续投资的 prototype / migration platform
!= production-safe canonical compiler architecture
```

### 做得好的部分

1. **Canonical AST 作为共享语义层的方向正确。** SourceManager、typed nodes、stable IDs、verifier、structured traversal/dump、sealed publication 都在减少 backend 重新猜语义的空间。
2. **public snapshot acquire 已有正确的 retain 临界区。** `AcquireASTSnapshot()` 在锁内 `AddRef()`，`currentGeneration` 也已经改为原子读写；这是应保留的基础。
3. **canonical candidate module 是正确的迁移方向。** 先在 candidate 上构造，再 swap containers，比直接污染 live module 明显更接近 last-good transaction。
4. **contained generation path 层次较完整。** source graph compile、complete generation snapshot、TypedASTJIT generator、Provider output 和 owned file publication 已经有清晰链路。
5. **profile/ownership/containment 被当成一等约束。** Hot Reload freeze、one contained Engine at a time、owned output、profile-specific identity 都是正确的产品级边界。
6. **Cache V2 默认关闭和 fail-closed 的范围控制是合理的。** 在跨 Engine/import/incremental closure 未完成前，不让原型冒充默认 production path，这个决策应保留。

### 当前最主要的架构问题

#### 1. Matching 与 contained 是两套 pipeline，而不是同一 pipeline 的两个 input adapter

当前：

```text
matching
Primary Engine
  -> source authority
  -> AST leases
  -> catalog hit/miss count
  -> lease manifest
  -> success

contained
frozen source snapshot
  -> contained generation Engine
  -> complete generation snapshot
  -> TypedASTJIT generator
  -> Provider/module output
  -> publication
```

中间的断线正是 F1/F5/F6 的共同根因。`FAngelscriptStaticJITGenerationSnapshot` 的 builder 还在 `AngelscriptStaticJITGenerationSnapshot.cpp:1435-1441` 强制要求 Engine purpose 为 `StaticJITGeneration`，使 primary Runtime Engine 无法复用同一 snapshot builder，进一步诱导 matching path 走一条“只证明 lease 存在”的旁路。

目标应是：

```text
PrimaryEngineLeaseProvider -----\
                                -> FCanonicalGenerationBundle
ContainedCompileProvider -------/       |
                                        v
                            CompleteGraphValidator
                                        |
                                        v
                              TypedASTJIT Generator
                                        |
                                        v
                              Project Output Publisher
```

`FCanonicalGenerationBundle` 至少应包含：

- exact target/artifact profile；
- immutable source inventory/content identity；
- complete compiled module graph；
- 每个 module 的 owned AST snapshot lease；
- immutable native-form recipe snapshot；
- stable module/function keys 和 publisher/digest；
- generation request/capability/ABI requirements。

downstream 不需要知道输入来自 primary 还是 contained Engine。

#### 2. Module generation 不是 aggregate transaction

当前 candidate 只覆盖 executable containers；AST snapshot 在 promote、`BuildCompleted()` 之后另行 seal/allocate/publish。其他 mutation 又各自决定是否退休 snapshot。这会不断产生遗漏。

应把 module generation 定义为不可分割 aggregate：

```text
Generation = Executable + AST + identities + publisher + digest + provenance
```

只有整个 aggregate 验证完成才能 commit。所有 mutation API 必须通过同一个 state machine 改变 generation，而不是直接改 containers 后补偿 snapshot。

#### 3. Stable identity 已出现，但 stable metadata 的所有权仍不稳定

native-form catalog 的 key/value 方向正确，但目前 publication 依赖 test flag，lookup 返回锁内容器 pointer，generator 仍读取 Engine-local pointer-keyed form。它尚不是“stable metadata service”，只是进程全局辅助表。

建议 catalog 使用 immutable snapshot/copy-on-write 或 value-copy API；registration 始终发布 reviewed pointer-free recipe，per-Engine compatibility objects 再由各 Engine 自己决定是否保留。

#### 4. Raw context escape hatch 破坏了 lease architecture

public lease/view 已经建立，但 production code 仍能调用 `GetCanonicalASTContext()`。只要 raw getter 可被普通 Runtime/Editor consumer 访问，后续很容易再次绕过 lifetime protocol。

建议将 raw getter 收缩为 module 内部 pending-build access，或返回带所有权的 internal lease。diagnostic、Cache、StaticJIT、Editor inspection 一律走 lease。

#### 5. 持久化 decoder 缺少一个统一的安全 primitive

sidecar schema 已经从占位走向完整 graph，但 decoder 仍以大量手写 `offset + size`、count loop 和 string read 组成。随着 schema 扩展，单点 hardening 很难长期可靠。

bounded reader 应成为 Cache DTO 的唯一入口，并与 verifier/publication firewall 组合：

```text
bounded decode -> detached context -> exact identity remap -> seal -> verify -> atomic activation
```

#### 6. 一部分测试验证了 scaffold，而不是产品产物

matching Generate 测试明确断言不产生 Provider，是典型例子。测试数量和 prefix green 不能替代 contract oracle。每个架构 gate 应首先验证用户可观察产物和 authority 一致性，再验证内部计数。

## OpenSpec checklist consistency

本轮不直接编辑 `tasks.md`，但下一次实现 checkpoint 至少应处理下列记录：

| Task | Current | Static review conclusion |
| --- | --- | --- |
| 6.1 | checked | `ReadBytes` overflow 与 empty-expected-profile negative 缺失，adversarial bounded decode 尚未闭合 |
| 6.2 | checked | DTO 已实现，但 decoder primitive 仍有内存安全缺口；需补 hardening note/gate |
| 8.2 | checked | catalog publication 依赖 `bCollectStaticJITCompatibilityBinds`，普通 primary 不满足 spec，应重开或明确 partial |
| 8.3 | checked | lease/no-sibling 部分成立；相关 test 不能替 8.4 证明 Provider emission |
| 8.4 | checked | matching path 没有 generator/provider，且 partial-module success，应重开 |
| 13.8 | open | 保持 open；加入 Build aggregate transaction、LoadByteCode/RemoveFunction/Discard retirement 的具体矩阵 |
| 13.9 | checked | scope containment 可保留，但 `tasks.md:1029` 的“production raw getter 已清零”陈述必须更正 |
| 13.11 | open | 加入 malicious sidecar lengths、matching real artifacts、compile-error module 和 publication failure injection |

OpenSpec artifact `4/4 complete` 只表示 proposal/design/specs/tasks 文件存在并满足 schema，不表示 implementation 已完成。

## Recommended repair order

1. **先修 F2 sidecar overflow。** 这是最独立、风险最高且修复边界最小的内存安全问题。
2. **统一 matching/contained generation input。** 让 matching 真实进入 generation snapshot、TypedASTJIT、Provider 和 publication；同时修 F1/F5。
3. **把 catalog 变成实际 generator input。** 解耦 test flag，改成 immutable/value lookup，关闭 F6。
4. **实现完整 module generation transaction。** 先分配/verify AST snapshot，再原子提交 executable + snapshot + metadata，关闭 F4。
5. **审计全部 module mutation。** LoadByteCode、RemoveFunction、Discard、CompileFunction、Hot Reload、Cache restore 都必须明确 replace/retire/preserve policy，关闭 F3。
6. **删除 production raw context consumer。** Cache diagnostic 改持 lease，并把 raw getter 收窄，关闭 F7。
7. **收紧 exact profile API。** full decode 禁止 implicit wildcard，关闭 F8。
8. **再更新 tasks 和验证矩阵。** 不应先通过修改 checkbox 追平实现。

## Minimum rereview gates

下一轮静态/动态复审前，建议至少具备以下永久测试：

- malicious sidecar length：`UINT_MAX`、wrapped offset、truncated field、nested count；
- encoded non-empty profile + empty expected profile 必须 fail closed；
- matching Generate 真实生成 Provider/module files，且重跑不删除合法 owned output；
- batch matching profile 使用请求的 output root；
- 任一 active module compile error/null/missing snapshot 时整次 Generate 失败且不写 output；
- 普通 Runtime primary 配置下 real bind registration 可产生 catalog recipe；
- matching generator 从 catalog recipe 选择 reviewed native form，missing/conflict 走安全 fallback；
- snapshot allocation/verifier failure 后 old executable + old snapshot 同时保持 current；
- successful Build/Hot Reload 对 executable/snapshot/generation key 做一次 atomic switch；
- LoadByteCode、RemoveFunction、Discard、attached CompileFunction 后旧 lease non-current；
- Cache diagnostic traversal 在 snapshot replacement 并发下持 lease。

## Final assessment

目前实现架构**值得继续沿用，但不适合切默认或宣称完成**。

最值得保留的是 Canonical AST、sealed snapshot、candidate module、contained generation 和 stable identity 这些核心构件。最需要重构的不是 AST node 本身，而是它们之间的 orchestration：

1. matching/contained 必须汇合为同一条 generation pipeline；
2. executable/AST/identity 必须成为同一个 module generation transaction；
3. catalog/Cache/diagnostic 必须只消费有明确 lifetime 和 exact profile 的 immutable input。

当这三条闭合后，当前实现会从“功能很多但 authority 分裂的迁移平台”变成真正可支撑 Bytecode、TypedASTJIT、Cache 和 future LLVM 的 canonical compiler architecture。在此之前，应保持 default/cutover gate 关闭，并把 8.2、8.4 的完成声明恢复为 partial/open。
