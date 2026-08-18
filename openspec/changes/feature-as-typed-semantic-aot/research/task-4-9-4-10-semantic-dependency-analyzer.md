# Tasks 4.9/4.10: Typed semantic dependency and Provider invalidation gap

Date: 2026-08-17

Status: classification implemented (tasks 4.9/4.10 GREEN). The per-entry
Provider semantic-dependency table, ABI bump, matcher reverse index, and
fixture regeneration remain pending as tasks 4.9a-4.10c. The analyzer
no longer treats every direct script call as a compiler `FunctionContent`
requirement; self-recursion relies on the current function `ExecutionHash`,
and directly embedded helper/SCC members synthesize one `FunctionContent`
row.

Related tasks: 4.9, 4.10; later verification/documentation tasks 5.7, 5.9 and
8.2.

## Summary

The first production integration of the TypedASTJIT semantic-use analyzer
correctly found missing compiler dependencies, but it currently classifies
every direct script call as requiring a `FunctionContent` dependency. That rule
is too strict: the maintained compiler records ordinary script calls as
`Signature` dependencies and records `FunctionContent` only in a hard-value
compilation context. A valid self-recursive Typed function is consequently
rejected with `SemanticDependencyMismatch`.

Simply changing the analyzer to accept `Signature` for every script call is not
safe either. TypedASTJIT directly emits the bodies of reachable non-root helper
functions and SCC members into the root's generated `.jit.cpp`. If a helper
body changes while the root body and signature remain unchanged, a Provider
that validates only the root `ExecutionHash` can continue publishing stale
native code. The missing contract is therefore not merely analyzer
eligibility; it is a Provider-visible semantic dependency and invalidation
contract for every value or body embedded in generated code.

## Reproduction and current RED evidence

The production valid-generation regression is:

- test report:
  `Saved/Tests/semantic-aot-task49-valid-generation/20260817_082524_596_85ea63f7/`;
- result: `0/1 PASS`;
- failing assertion: `TypedASTJIT self-recursion AOT fixture did not use
  production TypedAST backend`;
- typed diagnostic: `SemanticDependencyMismatch`, with a script-call content
  use requiring dependency kind `FunctionContent` while the authoritative
  compiler dependency set contains only `Signature`.

This RED follows three earlier, expected milestones:

- dependency analyzer first GREEN: build
  `Saved/Build/semantic-aot-task49-dependency-first-green-build/20260817_081149_264_8914de14/`
  and focused tests
  `Saved/Tests/semantic-aot-task49-dependency-first-green/20260817_081230_717_48b5d853/`
  (`2/2 PASS`);
- real missing-signature production RED: build
  `Saved/Build/semantic-aot-task49-backend-red-build/20260817_082041_860_96e1e4fa/`
  and expected failing test
  `Saved/Tests/semantic-aot-task49-backend-red/20260817_082100_715_ed36375b/`
  (`0/1 PASS` because production incorrectly selected Typed);
- first production integration GREEN: build
  `Saved/Build/semantic-aot-task49-backend-first-green-build/20260817_082317_404_a7bfdde2/`,
  exact backend test
  `Saved/Tests/semantic-aot-task49-backend-first-green/20260817_082336_190_e2516297/`
  (`1/1 PASS`), and complete Dependencies prefix
  `Saved/Tests/semantic-aot-task49-dependencies-post-integration/20260817_082424_019_79767511/`
  (`3/3 PASS`).

The last regression is intentionally retained as evidence. No test has been
weakened and tasks 4.9/4.10 remain unchecked.

## Maintained-compiler evidence and root cause

The authoritative behavior is in
`ThirdParty/angelscript/source/as_builder.cpp`, in
`asCBuilder::MarkDependency(asCScriptFunction*, ...)`:

1. Every referenced function receives a `Signature` artifact dependency.
2. A second `FunctionContent` artifact dependency is recorded only while
   `bValueDependenciesAreHard` is true (apart from the maintained generated
   `StaticClass` exclusion).
3. Ordinary script calls do not run in that hard-value context.

This is consistent with Cache V2 incremental semantics: an ordinary call is
coupled to the callee declaration/call ABI, not to the callee implementation.
The callee can normally be recompiled or rerouted independently. Body/value
dependencies are reserved for cases where the consumer embeds content or a
folded value.

TypedASTJIT adds a new code-generation fact that the compiler cannot infer from
ordinary source semantics: when it emits a helper/SCC body directly into the
root artifact, that root Provider now embeds the helper implementation. The
analyzer must preserve the compiler's ordinary `Signature` edge and separately
describe this Typed code-generation-specific content edge.

Self-recursion is a special but simple case. The generated entry already
carries and validates its own root `ExecutionHash`; requiring a second
`FunctionContent` dependency from the root to itself duplicates the same
authority and causes the current false rejection.

## Why a local relaxation is unsafe

Changing `bRequiresFunctionContent` to false for every direct script call would
make self-recursion pass, but would create the following stale-publication
sequence:

1. Root `A` directly embeds helper `B` in `A`'s `.jit.cpp`.
2. The Provider entry validates `A`'s function key, root `ExecutionHash`, entry
   ABI, artifact profile, native environment and reference slots.
3. `B`'s body changes without changing `B`'s signature or `A`'s body.
4. Cache V2 correctly does not treat the ordinary call as a hard body
   dependency.
5. The old Provider still matches `A`, even though its machine code contains
   the old body of `B`.

The same issue applies to a changed member of a mutually recursive SCC. A
folded primitive/enum global has the equivalent value problem: the generated
body embeds the folded bits, and the existing
`FAngelscriptArtifactSemanticDependency::ExpectedContentOrValue` must survive
into Provider validation rather than ending at generation analysis.

## 通俗解释：问题不取决于 `UFUNCTION`，而取决于调用链接方式

`Provider` 可以理解为随 JIT DLL 一起生成的“代码保鲜标签”。它记录
根 AS 函数的稳定身份、生成时内容 Hash、Entry ABI、目标 Profile 和
C++ 入口地址。Engine 初始化时只有在标签仍与当前 AS 函数完全一致时，
才安装 DLL 里的原生入口；否则拒绝旧入口并回退到 BytecodeJIT/VM。

普通 AS/VM 调用只需要依赖被调函数的 `Signature`。例如：

```angelscript
int AddOne(int Value)
{
    return Value + 1;
}

UFUNCTION()
int Calculate(int Value)
{
    return AddOne(Value);
}
```

在 VM 中，`Calculate` 运行时会进入当前的 `AddOne`。只要声明
`int AddOne(int)` 没变，`AddOne` 从 `+1` 改成 `+100` 不要求重编译
`Calculate`；更新 `AddOne` 自己的 Bytecode/route 即可。因此 maintained
compiler 正确地记录 `Calculate -> AddOne.Signature`，而不是普通调用就
无条件记录 `FunctionContent`。

TypedASTJIT 的 direct closure 改变了这个前提。它可能生成：

```cpp
static int ASJIT_AddOne(int Value)
{
    return Value + 1;
}

static int ASJIT_Calculate(int Value)
{
    return ASJIT_AddOne(Value);
}
```

这里 `Calculate` 的原生产物已经固定链接到同一 `.jit.cpp`/DLL 中的
`ASJIT_AddOne`。如果 AS 中 `AddOne` 改成 `+100`，而旧 Provider 只验证
没有改动的 `Calculate.ExecutionHash` 和没有改动的 `AddOne.Signature`，
它就可能继续安装仍执行 `+1` 的旧 C++。因此所有被直接嵌入的非根
helper/SCC 成员都必须有额外的 `FunctionContent` 失效边。

自递归不同：

```angelscript
UFUNCTION()
int Factorial(int Value)
{
    return Value <= 1 ? 1 : Value * Factorial(Value - 1);
}
```

`Factorial` 的根 Provider 已经验证它自己的 `ExecutionHash`。函数体一改，
这个根 Hash 就会变化；再要求一条
`Factorial -> Factorial.FunctionContent` 是重复验证。当前 blanket
`bRequiresFunctionContent=true` 没区分“根调用自己”和“根直接嵌入另一个
helper”，所以合法自递归被错误拒绝。

### `UFUNCTION` 不是充分条件，也不是必要条件

当前实现的具体行为证明，函数是否有 `UFUNCTION` 不是安全边界：

- closure 的选定根必须是 exact `UFUNCTION` root；
- 一个可直接生成、同时也是 `UFUNCTION` root 的被调函数，分类为
  `DirectScript`；
- 一个可直接生成、但不是 `UFUNCTION` root 的普通 helper，分类为
  `InternalSemanticHelper`；
- `DirectScript` 和 `InternalSemanticHelper` 随后都属于 direct closure；
- backend 对两者都把调用表达式绑定到固定的 `Callee->WrapperSymbol`，
  当前也都统一设置 `bRequiresFunctionContent=true`。

因此给示例中的 `AddOne` 加上 `UFUNCTION()`，当前生成方式可能只会把它
从 `InternalSemanticHelper` 改称 `DirectScript`；`Calculate` 仍然直接调用
DLL 内固定的 `ASJIT_AddOne` wrapper。即使 `AddOne` 自己另有一个 Provider
entry，并且该 entry 因 `AddOne.ExecutionHash` 改变而被拒绝，也不能自动
阻止已经安装的 `Calculate` 绕过该 entry、直接进入旧 wrapper。

四种情况的区别如下：

| `AddOne` 形态 | `Calculate` 的生成调用 | `Calculate` 是否需要验证 `AddOne` 内容 |
|---|---|---|
| 非 `UFUNCTION` helper | 直接固定 wrapper | 需要 |
| `UFUNCTION` helper/root | 直接固定 wrapper | 仍然需要 |
| `UFUNCTION` helper/root | 经当前 Provider/Engine slot 间接路由 | 通常只需 Signature、ABI 和 route；`AddOne` 自己验证内容 |
| 非 `UFUNCTION` helper | 经当前 VM/binding slot 间接路由 | 同样可只依赖 Signature、ABI 和 route |

所以真正的判据是：

```text
直接嵌入或固定链接 callee C++ body
    => caller Provider 必须验证 callee FunctionContent

通过当前 Engine 的可更新 slot/VM/Provider 入口间接调用
    => caller 验证 Signature + ABI + route，callee 自己验证内容

根函数调用自己
    => 根 ExecutionHash 已验证自身内容
```

### “把所有 AS 函数都变成 `UFUNCTION`”为什么不能自动解决

即使把所有 AS 函数都标成 `UFUNCTION`，只要 TypedASTJIT 仍为性能而生成
直接的 C++ wrapper 调用，旧调用者仍可能固定链接到旧 callee body，问题
不会消失。独立 Provider entry 被拒绝不等于所有直接调用它的旧 C++ 都会
自动失效。

只有进一步改变调用架构，让每个跨函数调用都经过当前 Engine 的
Provider/VM indirection slot，这一类 caller-to-callee 内容依赖才可以消失。
但那是另一种性能和生命周期权衡，而且并不要求所有函数成为
`UFUNCTION`：普通 helper 同样可以通过稳定函数 key + ABI + 当前 slot
间接路由。

强制所有 AS helper 都成为 `UFUNCTION` 还会无必要地扩大 Unreal 反射、
descriptor、Parms ABI、ClassGenerator/hot-reload 和 Provider root 表面，
并把本来只是脚本内部实现细节的函数提升为 UE 可反射入口。这个成本不应
被用来掩盖 direct-call invalidation contract 的缺失。

结论是：保留“只有需要 UE 入口的函数才是 `UFUNCTION`”的现有边界；由
TypedASTJIT 根据每条调用的实际 lowering 决定依赖。直接 helper/SCC 调用
记录 `FunctionContent`，间接 route 记录 Signature/ABI/slot，自递归由根
`ExecutionHash` 覆盖。

## Current Provider gap

The current Provider ABI is revision 7. It carries root identity and content,
entry ABI, profile/environment identity, stable references, flags and an
artifact-set digest, but it does not carry a per-entry semantic dependency
table containing dependency kind, stable target and expected content/value.

`FAngelscriptJITProviderMatcher` can validate
`ImmutableDirectCallSet` against `ArtifactSetDigest`, but that mode is not a
replacement for the required reloadable contract:

- the current Editor/reloadable router does not publish the current closure
  digest as an immutable validation authority;
- immutable-set validation is intended for a complete immutable cooked set;
- one monolithic set digest does not preserve typed failure detail for a
  changed helper body or folded hard value;
- the authoritative compiler dependency already contains
  `ExpectedContentOrValue`, but Provider rows do not transport or validate it.

Therefore the current root-only matcher cannot prove that every body/value
embedded in a Typed entry is still current.

## Considered alternatives

### A. Provider semantic dependency table — approved

Bump the Provider ABI and add a deterministic, POD-like per-entry dependency
view containing at least:

- semantic dependency kind (`Signature`, `FunctionContent`, `HardValue`, and
  the already-supported layout/storage kinds as applicable);
- stable target reference kind, stable key and expected ABI/shape identity;
- optional `ExpectedContentOrValue`;
- deterministic ordering/count bounds suitable for generated static data.

Generation would:

- preserve all authoritative compiler dependencies and their kinds;
- require only `Signature` for an ordinary script call;
- rely on the root entry's own `ExecutionHash` for self-recursion;
- synthesize a Typed code-generation `FunctionContent` dependency for each
  directly embedded non-root helper or SCC member;
- retain hard-value fingerprints for folded globals;
- include the canonical dependency rows in artifact/provider generation
  digests.

Runtime matching would resolve each row against the current Engine authority.
For a function-content row it would compare the expected content hash with the
current `FunctionRoute.Identity.Content.Execution`; for a hard-value/layout row
it would use the corresponding validated current semantic publication. Any
missing, ambiguous, wrong-kind, wrong-ABI or changed-content result would fail
closed with a typed `SemanticDependencyMismatch` and would not publish that
Provider entry.

This option preserves Cache V2's ordinary call semantics while adding the
extra invalidation edge exactly where Typed code generation embeds content.

### Approved forward-table and reverse-index model

The persistent/generated truth is a **forward table owned by each installable
entry**, not a list of all source call sites owned by the callee. For example,
if RootA calls Helper twice and RootB calls Helper once, RootA owns one
deduplicated Helper-content row and RootB owns one row. Helper does not persist
an inverse list naming RootA and RootB. Call-site source positions remain
diagnostic metadata and do not participate in invalidation identity.

The forward slice is transitive over the code actually embedded by the entry.
For a fixed direct chain `RootA -> HelperB -> HelperC`, RootA records B and C.
For self-recursion it records neither a duplicate self row nor a synthetic
callee body because RootA's own `ExecutionHash` already covers that body. For
a current Engine/Provider/VM call, the entry records signature/ABI/route but no
callee content. A folded constant records its hard-value fingerprint.

At successful adoption, each Engine derives its own ephemeral **reverse
index** from those forward slices:

```text
Helper stable key + FunctionContent
    -> RootA Provider entry
    -> RootB Provider entry
```

When Helper changes, the Engine looks up that reverse key, revalidates only the
listed entries and withdraws mismatches before a new invocation can acquire
them. This index is rebuilt from adopted Provider data, is not serialized as
callee-owned truth, is not shared across Engines, and is removed with the
Engine/Provider state.

Withdrawal does not destroy code underneath an already-running invocation.
The existing publication/lease lifetime lets that invocation finish; later
calls use a current replacement or BytecodeJIT/VM. Regeneration is a separate
recovery step: emit the updated `<Module>.jit.cpp`, build/load its DLL, then
adopt a newly matching Provider. Dependency validation therefore runs at
adoption/refresh rather than on every generated direct call.

### B. Replace the root execution hash with a closure hash — not recommended

A closure hash could include all embedded helper bodies, but the runtime would
still need the same closure metadata and authoritative current identities to
recompute it. It also folds hard-value/layout diagnostics into an opaque root
mismatch and duplicates the semantic dependency mechanism.

### C. Make all compiler script-call dependencies `FunctionContent` — rejected

This would make the analyzer's current blanket rule pass, but it changes
Cache V2 compilation/reload semantics for every ordinary script call and
causes unnecessary transitive recompilation. A Typed backend-specific
invalidation need must not redefine the source compiler's general dependency
model.

### D. Route every helper through VM/current binding — rejected for this scope

This would avoid embedding helper bodies but removes the planned direct
Typed helper/SCC capability and its performance/value proposition. It can
remain a valid fallback for ineligible calls, not the completion definition for
tasks 4.9/4.10.

## Required TDD matrix before implementation is considered complete

The next implementation must begin from focused RED cases, kept under the
capability-owned `StaticJIT/TypedASTJIT/Dependencies/` test directory:

1. self-recursion accepts the compiler's signature-only edge and relies on the
   root `ExecutionHash`;
2. changing a directly embedded helper body invalidates an otherwise unchanged
   root Provider;
3. changing one member of a mutually recursive SCC invalidates every entry that
   embeds it, with deterministic row ordering independent of discovery order;
4. changing an embedded folded hard value invalidates the entry while an
   unchanged value matches;
5. malformed Provider dependency rows fail closed: unknown kind, zero key,
   absent required expected hash, duplicate/conflicting rows, wrong reference
   kind/ABI, out-of-range count and digest mismatch;
6. missing/wrong-kind/unmappable HIR uses retain
   `SemanticDependencyMismatch`;
7. a bytecode-reference-scan test double that deliberately disagrees still
   proves the Typed analyzer and matcher never consult BytecodeJIT scanning;
8. generation and Provider serialization are deterministic across repeated
   runs.

The existing valid-generation self-recursion test remains the production GREEN
gate after these narrower REDs are satisfied.

## Tentative implementation surface

This file map is a design boundary, not an assertion that the change has been
implemented:

- `StaticJIT/AngelscriptJITProvider.h`: versioned POD dependency row/view and
  entry ownership/count fields;
- `StaticJIT/AngelscriptJITGeneration.cpp`: canonical row emission,
  validation, digest participation and generated metadata;
- `StaticJIT/AngelscriptJITProviderMatcher.cpp`: current semantic authority
  resolution and typed mismatch reporting;
- `StaticJIT/AngelscriptJITProviderRouter.cpp`: supply the current Engine
  resolver/publication context without treating reloadable Editor output as an
  immutable cooked set;
- `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITDependencies.*`: distinguish
  source-semantic call requirements from codegen-embedded helper content;
- `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITBackend.cpp`: construct the
  exact helper/SCC dependency rows and remove the current blanket
  `bRequiresFunctionContent=true` rule;
- `Core/Artifacts/AngelscriptArtifactReference.h` and the existing route/
  semantic publication APIs: reuse current stable identity and
  `ExpectedContentOrValue`, extending only if a required current-value resolver
  is genuinely absent;
- `AngelscriptTest/StaticJIT/TypedASTJIT/Dependencies/`: split analyzer,
  generation and Provider-match cases by capability rather than growing one
  monolithic test file.

Any Provider layout change must bump `FAngelscriptJITProviderAbi::Revision` and
update generated carriers, manifests and compatibility tests together.

## Decision checkpoint

Decision: option A, the explicit per-entry Provider semantic dependency table,
was approved by the user on 2026-08-17. The approved scope includes the
versioned flat Provider table, exact lowering-based dependency classification,
initial current-Engine matching, an Engine-local reverse dependency index,
hot-reload withdrawal under the existing entry-lease lifetime, and separate
regeneration/restoration. The maintained compiler's ordinary signature-edge
semantics remain unchanged.

Approval is not completion evidence. No Provider ABI or production behavior
was changed in this record-update step. The current analyzer/backend
integration remains knowingly too strict, the self-recursion valid-generation
case remains RED, and tasks 4.9 through 4.10c remain open until the TDD,
implementation, fixture regeneration and fresh official verification are all
complete.

## 2026-08-17 — 4.9 implementation notes and open questions

These notes were recorded while writing the 4.9 RED tests. They are not
approvals and they do not change `tasks.md`.

### Confirmed next step

The approved next implementation slice is the per-entry Semantic Dependency
Table. Task 4.9 only extends the two existing Dependencies test files and
must stay RED for the missing classification contract. Task 4.10 implements
the analyzer/backend classification. Tasks 4.9a/4.10a own the Provider ABI
row/table. Do not mix those scopes.

### Analyzer/backend facts the tests now lock

- `AnalyzeAngelscriptTypedASTJITDependencies()` still honors
  `FAngelscriptTypedASTJITScriptCallEmissionPlan::bRequiresFunctionContent`
  only. It does not compare `Plan.TargetReference.StableKey` with the root
  `FunctionView.FunctionKey.Hash`, and it does not synthesize a
  `FunctionContent` row.
- Production `AngelscriptTypedASTJITBackend.cpp` still sets
  `bRequiresFunctionContent = true` for every `DirectScript` and
  `InternalSemanticHelper` edge, including root self-recursion.
- Self-recursion identity used by production
  `FindDirectScriptReference()` is
  `Dependency.Reference.Kind == ScriptFunction &&
  Dependency.Reference.StableKey == Call.CalleeFunctionKey.Hash`.
  Semantic tests therefore set `Plan.TargetReference.StableKey` equal to
  `FunctionView.FunctionKey.Hash` for the self-recursion case.
- Ordinary compiler rows for script calls remain `Signature`. The existing
  GREEN helper test keeps both compiler `Signature` and `FunctionContent`
  rows plus `bRequiresFunctionContent=true`.

### How the new REDs fail for the right reason

- Self-recursion: production-like `bRequiresFunctionContent=true` + compiler
  `Signature` only. Current result is `SemanticDependencyMismatch` with
  `RequiredKind=FunctionContent`. Desired result is VALID,
  `ScriptCallSignature` only, no self `ScriptCallContent`.
- Non-root helper / SCC / shared-or-external borrowed body: compiler
  `Signature` only and `bRequiresFunctionContent=false` so the flag cannot
  hide the missing classifier. Current result is VALID with no content use.
  Desired result is VALID plus one synthesized `FunctionContent` row/use per
  embedded member.
- Production-like helper (`bRequiresFunctionContent=true`, compiler
  `Signature` only) is a second helper RED: current code fail-closes instead
  of synthesizing the missing content row.

### Open questions / coverage limits

1. Receiver / hidden-arg `TypeInfo` uses cannot be constructed in the
   engine-less semantic file. `AddTypeUse()` no-ops on primitives and needs a
   live `asCTypeInfo` plus `Graph.Types` or cache-environment identity.
   4.9 therefore only proves that a primitive `HostHidden` argument does not
   replace script-call classification. Live `ReceiverType` /
   `HiddenArgumentType` mismatch remains an engine-backed 4.10/backend case.
2. There is still no script-call emission plan for a current
   Engine/Provider/VM script route. Dynamic/current-route coverage in 4.9 is
   native `Route=CurrentNativeBinding` / `Bridge`. A later script current-route
   plan, if introduced, must not start requiring callee `FunctionContent`.
3. There is no injectable BytecodeJIT reference-scan test double. Isolation is
   proven with `FAngelscriptStaticJITBytecodeAccessAudit` DuringTypedAST
   counters, including the existing compiler-graph disagreement fixture whose
   live bytecode still contains the helper call. Do not add a production hook
   only to invent a scan double.
4. Provider ABI is still Revision 7. 4.9 cannot assert a serialized per-entry
   dependency table; that belongs to 4.9a/4.10a.
5. Shared/external `bodyOwnership` labels must not drive classification.
   Tests encode `SharedBorrowed` / `ExternalBorrowed` with the same direct
   script lowering as a helper.
6. `UFUNCTION` remains a root/disposition selector, not the dependency
   discriminator. Do not add tests that treat reflection as the contract.

### Verification command

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.StaticJIT.TypedASTJIT.Dependencies" -Label semantic-aot-task49 -TimeoutMs 600000
```

Run it from the isolated worktree / `V:\` subst. Do not check 4.9 until the
new classification cases fail for the reasons above and the older GREEN
cases remain GREEN.
