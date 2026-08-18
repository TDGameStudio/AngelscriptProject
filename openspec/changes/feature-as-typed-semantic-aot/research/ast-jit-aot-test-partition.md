# AST JIT / AOT test partition map

## Why this attachment exists

The maintained `AngelscriptStaticJITAotTests.cpp` source is still close to
seven thousand physical lines after the first extraction pass. It mixes
several independently evolving contracts and is therefore no longer the
preferred destination for new coverage. This attachment records the
incremental extraction boundary requested during implementation; it is not a
second test plan and does not replace `tasks.md`.

## Landed bounded surfaces

- `StaticJIT/TypedASTJIT/`
  - eligibility and execution-profile selection;
  - transitive call-closure planning;
  - generated C++ output contracts;
  - native/VM bridge routing;
  - scalar-operation runtime helpers.
  - These six capability files were moved out of the `StaticJIT/` root
    without changing their automation prefixes or method names. New Typed
    AST JIT coverage must select one of these capability owners or introduce
    a new narrowly named file beneath this directory.
- `StaticJIT/AOT/RuntimeRoutes/`
  - debugger routing;
  - coverage and loop-timeout routing;
  - frame and recursion routing;
  - narrowly shared route-test support.
- `StaticJIT/AOT/Generation/`
  - whole-generation determinism, profile identity, stale output and expected
    fallback verification;
  - complete generation-snapshot facts, including the proof that the isolated
    source Engine captures verified facts without consuming Cache V2 records;
  - installed TestJIT Provider ABI and same-module mixed
    TypedASTJIT/BytecodeJIT publication, in a lightweight Provider-snapshot
    test that does not construct another Engine.
- `StaticJIT/AOT/UASFunctionDispatch/`
  - VM, Raw and Parms dispatch through generated `UASFunction` entries using a
    narrow bridge to the existing shared fixture.
- `StaticJIT/AOT/Diagnostics/`
  - `AngelscriptStaticJITAotGenerationDiagnosticsTests.cpp` owns request,
    fallback, semantic-function and capability facts;
  - `AngelscriptStaticJITAotCallDiagnosticsTests.cpp` owns per-call lowering,
    source and native-linkage vocabulary;
  - `AngelscriptStaticJITAotGeneratedProviderDiagnosticsTests.cpp` owns
    packaging, emitted Provider source and Shipping omission;
  - `AngelscriptStaticJITAotInstalledDiagnosticsTests.cpp` owns Provider ABI
    validation, Registry deep copy and diagnostic-only replacement;
  - `AngelscriptStaticJITAotCommandDiagnosticsTests.cpp` owns stable JSON and
    the real `as.StaticJIT.DumpDiagnostics` file-output contract.

## Required next surfaces

- `AngelScriptSDK/Compiler/TypedSemanticIR/`
  - expression identity and propagation (`Clear`/`Copy`/`Merge`, void/discard,
    conversion, assignment, call and short-circuit);
  - scalar operator/type capture (literal, enum, unary, arithmetic,
    comparison, bitwise, logical and power conversion);
  - compiler publication/failure transactions and source provenance;
  - receiver/call-rewrite metadata and unsupported-category capture.
  - New compiler-HIR coverage goes here instead of growing the existing
    `Compiler/AngelscriptNativeTypedSemanticIRTests.cpp`. Each `.cpp` owns one
    observable capability family and may use a narrow shared support header
    for Engine/module/snapshot mechanics.
  - Current bounded owners are:
    - `AngelscriptNativeTypedSemanticIRExpressionContextTests.cpp` for
      expression-context copy/merge/clear identity;
    - `AngelscriptNativeTypedSemanticIRExpressionConversionTests.cpp` for
      compiler-selected conversion and final compiler types;
    - `AngelscriptNativeTypedSemanticIRResolvedCallTests.cpp` for
      resolved-call identity in discard and local-initializer positions;
    - `AngelscriptNativeTypedSemanticIRPublicationTransactionTests.cpp` for
      successful-bytecode/verifier-invalid-HIR discard, stable verifier
      diagnostics, bytecode equality and executable VM fallback;
    - `AngelscriptNativeTypedSemanticIROperatorTests.cpp` for exact scalar
      leaves and primitive operator families;
    - `AngelscriptNativeTypedSemanticIRUnsupportedContainerTests.cpp` for
      independent reference/container fallback identity;
    - `AngelscriptNativeTypedSemanticIRUnsupportedPropertyTests.cpp` for
      receiver-owned property fallback identity and unchanged VM behavior;
    - `AngelscriptNativeTypedSemanticIRUnsupportedLifetimeTests.cpp` for
      construction and managed-cleanup fallback state;
    - `AngelscriptNativeTypedSemanticIRUnsupportedLanguageBoundaryTests.cpp`
      for capture-on/off rejection of exception-region syntax (`try`, `catch`
      and `rethrow`) that is outside the maintained language surface;
    - `AngelscriptNativeTypedSemanticIRUnsupportedImplicitMemberTests.cpp`
      for explicit-`this` and unqualified member receiver/property fallback
      identity. It deliberately remains separate from direct-property coverage
      because its compiler entry path and regression cause are different.
    - `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedFunctionTests.cpp`
      for the reachable `__generated` compiler/preprocessor trait and its
      deterministic `CompilerSynthesizedFunction` fallback disposition.
    - `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedDefaultsTests.cpp`
      for generated `__InitDefaults` bytecode, capture disposition and real
      default-statement execution.
    - `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedLifecycleTests.cpp`
      for automatically generated default constructor, default destructor and
      factory bytecode paths. These record stable no-HIR dispositions while
      preserving runtime construction/destruction behavior.
    - `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedAccessorTests.cpp`
      for the removed virtual-property/accessor source syntax. It proves the
      parser rejects the source identically with capture off/on and publishes
      neither a partial type nor HIR.
    - `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedLambdaTests.cpp`
      for the currently unreachable future-lambda source syntax. It owns the
      deterministic compile-rejection boundary instead of mixing lambda into
      the general language-boundary file.
    - `AngelscriptNativeTypedSemanticIRUnsupportedSynthesizedListFactoryTests.cpp`
      for registered native/system list-factory identity, per-function list
      pattern ownership, capture-invariant normalized bytecode and real list
      construction. It remains separate from script-generated lifecycle
      functions because it never enters a script compiler HIR transaction.

- `StaticJIT/AOT/References/`
  - committed reference-slot resolution;
  - bind/rebind/unbind behavior;
  - direct-exported, private bridge and ordinary binding distinctions.
- `StaticJIT/AOT/Parity/`
  - scalar, structured-control-flow, numeric-boundary and power-boundary
    differential execution.
- `StaticJIT/AOT/ProviderLifecycle/`
  - current/fresh Engine publication, sequential loads, committed Provider
    rejection and CacheV2-independent installation.
- `StaticJIT/AOT/ExceptionsAndLifetime/`
  - nested exception payload, cleanup/lifetime, virtual dispatch and recursion
    parity that is not already owned by `RuntimeRoutes/`.

## Migration rules

1. New coverage goes directly to its bounded capability directory; it does not
   extend the general AOT translation unit.
2. Existing scenarios move as complete families when they are next changed.
   Test names and maintained parent prefixes remain discoverable.
3. A split must not create one isolated Engine per test file. Shared fixture
   and Engine-session access uses a narrow support or bridge interface.
4. Scenario bodies stay in their owning `.cpp`. Shared support contains only
   genuinely reused lookup, invocation and assertion mechanics and must not
   become a replacement monolith.
5. Build-system discovery remains recursive, but every extraction is verified
   with the affected focused prefix before the next family is moved.
6. Prefer one capability family per `.cpp`; when a single family becomes
   large, split it again by observable scenario. Do not use a generic
   catch-all file as the destination for unrelated AST JIT/AOT tests.
7. Directory ownership and translation-unit ownership are separate choices.
   Moving a capability file into its directory is safe immediately; splitting
   a CQTest class is done only with a shared support seam that preserves the
   existing automation prefix and does not duplicate Engine setup.
8. File count is not the optimization target. A new `.cpp` is justified by a
   distinct capability owner or independently runnable prefix; trivial cases
   that share one fixture and one contract stay together. Conversely, a file
   that mixes compiler capture, emitter golden output and runtime dispatch is
   split even if its raw line count is still modest.
9. Expensive setup is owned at the narrowest reusable layer. Tests may share a
   fixture/session or immutable captured input, but each method resets mutable
   state and must remain order-independent. No partition may depend on unity
   build leakage or another translation unit's static initialization.
10. Use size only as a review trigger, not as the ownership rule. Review a
    translation unit for another capability split when it grows beyond roughly
    500 physical lines or five `TEST_METHOD` cases. Keep it together only when
    the excess is narrow shared setup for one observable contract; otherwise
    split by scenario and move only genuinely reused mechanics into a small
    support header/source pair.
11. Unsupported-language coverage is not a catch-all category. Receiver,
    property, container, lifetime, suspend/exception-region, lambda, and
    compiler-synthesized dispositions each receive their own capability owner
    when they become reachable and testable.
12. Add a nested directory only when it communicates a durable capability
    domain, not merely to reduce the number of entries in one folder. As the
    compiler-HIR surface grows, use bounded owners such as `Expressions/`,
    `ControlFlow/`, `Unsupported/`, and `Publication/`; keep a small family in
    the current `TypedSemanticIR/` directory until a second related owner makes
    the domain useful. New suspend/exception-region coverage belongs to its
    own unsupported-boundary owner and must not enlarge a generic language or
    unsupported catch-all file.

## Large-file follow-up

`TypedASTJIT/AngelscriptTypedASTJITGeneratedOutputTests.cpp` remains a large
single-family file because its first half is shared builder/assertion support
for one CQTest class. It must not receive unrelated tests. Before adding a new
generated-output scenario, extract its shared mechanics to a narrow support
interface and divide the scenarios into scalar/control output, call/linkage
output, and entry/frame output translation units. This is intentionally not a
copy-and-paste split: duplicate HIR builders or different golden-normalization
rules would make the tests disagree while appearing smaller.

`AngelScriptSDK/Compiler/AngelscriptNativeTypedSemanticIRTests.cpp` is also an
existing large mixed-capability translation unit. It remains the owner of its
already-landed foundation/structured-control cases until those families are
next changed. Tasks 2.1 and 2.2 start in
`AngelScriptSDK/Compiler/TypedSemanticIR/` instead of adding more methods to
that file. If an old family is extracted later, first move its reusable native
Engine/module/snapshot mechanics behind a small support interface, then move
the complete scenario family while preserving the maintained automation
prefix and method names.

The compiler-HIR partition is not exempt from the same follow-up rule. The
former 581-line
`AngelscriptNativeTypedSemanticIRExpressionPropagationTests.cpp` crossed the
review trigger and has now been split into context, conversion, and resolved
call owners. The original Automation prefix and method names are preserved.
Each raw-SDK case keeps its case-owned Engine/module isolation; only narrow
query mechanics remain class-private, so the split does not introduce process
or global Engine state.
Container and property coverage were already split from the former generic
`UnsupportedTests.cpp`; unrelated unsupported categories must receive their
own narrowly named file instead of recreating that catch-all.

The latest compiler-HIR partition contains twenty capability-owned `.cpp`
files and twenty-one `TEST_METHOD` cases. Each file has one or two cases; the
largest is the one-method capture-parity owner at 446 physical lines, below the
current 500-line review trigger. Capture/archive isolation, publication
transaction, internal exception-region metadata, and the disabled-cooperative-
suspend boundary each have a dedicated owner instead of growing the original
foundation or language-boundary files.
The current partition is verified by:

- `Saved/Build/typed-semantic-synthesized-boundary-partition/
  20260816_205540_756_aec01d17/` — UBT PASS;
- `Saved/Tests/typed-semantic-synthesized-accessor-exact/
  20260816_205552_057_b2f5c5fa/` — exact accessor boundary `1/1 PASS`;
- `Saved/Tests/typed-semantic-synthesized-lambda-exact/
  20260816_205629_730_fc055492/` — exact lambda boundary `1/1 PASS`;
- `Saved/Tests/typed-semantic-synthesized-boundary-partition-group/
  20260816_205706_789_ef45e33a/` — complete TypedSemanticIR prefix `35/35
  PASS`, zero failed/skipped;
- `Saved/Build/typed-semantic-list-factory-engine-local-normalization/
  20260816_212532_082_2172bed4/` — affected build PASS;
- `Saved/Tests/typed-semantic-list-factory-engine-local-normalization-exact/
  20260816_212549_262_5825c26c/` — list-factory boundary `1/1 PASS`;
- `Saved/Tests/typed-semantic-list-factory-engine-local-normalization-group/
  20260816_212625_822_f4f1b01b/` — complete TypedSemanticIR prefix `36/36
  PASS`, zero failed/skipped;
- `Saved/Build/typed-semantic-publication-transaction-green/
  20260816_214029_939_ecf873ff/` — affected UBT build PASS;
- `Saved/Tests/typed-semantic-publication-transaction-green-exact/
  20260816_214050_382_8b6c3ab9/` — exact publication boundary `1/1 PASS`;
- `Saved/Tests/typed-semantic-publication-transaction-green-group/
  20260816_214127_680_9d2e33e3/` — complete TypedSemanticIR prefix `37/37
  PASS`, zero failed/skipped.
- `Saved/Tests/typed-semantic-exception-region-green-exact/
  20260816_215914_883_bc49e4d8/` — exact internal exception-region boundary
  `1/1 PASS`;
- `Saved/Tests/typed-semantic-suspend-boundary-exact/
  20260816_220120_546_74616436/` — exact maintained suspend/safe-point boundary
  `1/1 PASS`;
- `Saved/Tests/typed-semantic-task25-green-group/
  20260816_220157_931_7fbf7256/` — complete TypedSemanticIR prefix `39/39
  PASS`, zero failed/skipped.
- `Saved/Build/typed-semantic-task27-parity-boundary-build/
  20260816_222337_094_6c9c0e7a/` — capture-parity affected build PASS;
- `Saved/Tests/typed-semantic-task27-capture-parity-green-02/
  20260816_222356_473_8e3eddba/` — capture parity `1/1 PASS`;
- `Saved/Tests/typed-semantic-task27-archive-isolation-equivalent-identity/
  20260816_222558_636_8163e349/` — archive isolation `1/1 PASS`;
- `Saved/Tests/typed-semantic-task27-full-green/
  20260816_222836_812_8b7864c0/` — complete TypedSemanticIR prefix `41/41
  PASS`, zero failed/skipped.

The new source discovery initially exposed six old TypeSystem files that used
language-case helpers only through Adaptive Unity leakage. They now include
`AngelscriptNativeLanguageCaseTestSupport.h` directly. Test partitioning must
remain safe under non-unity/repartitioned compilation; another translation
unit's include order is never a valid support seam.

## Immediate task-7 application

Task 7.1 diagnostics tests are created beneath `StaticJIT/AOT/Diagnostics/`
from the start. Generation/artifact diagnostics, installed Provider/route
diagnostics, and serialization/console output use separate translation units.
The existing root-level diagnostics file may be migrated incrementally when
its scenario is touched; new assertions must not make that file grow further.

The per-call lowering/linkage contract is also isolated in
`AngelscriptStaticJITAotCallDiagnosticsTests.cpp`. It is a pointer-free,
synthetic serialization surface and does not create another test Engine.
Production-feed proof remains in the existing bounded generation-verification
session, so splitting a scenario family does not multiply Engine startup cost.

The installed-Provider contract is isolated in
`AngelscriptStaticJITAotInstalledDiagnosticsTests.cpp`. Its synthetic Provider
validates the cross-DLL flat diagnostic ABI, Runtime-owned deep copy, immutable
old snapshots, and diagnostic-only replacement without changing artifact or
Provider-generation identity. It contains no generation Engine fixture.

The generated-Provider contract is isolated in
`AngelscriptStaticJITAotGeneratedProviderDiagnosticsTests.cpp`. It proves the
Editor catalog is rendered without changing execution identity and that the
Shipping package omits the optional catalog. The installed-Provider file also
owns the distinction between script callees, which require a
`CalleeFunctionKey`, and UE/C++ system calls, whose durable diagnostic identity
is the stable native target key plus expected ABI.

Two regressions found only while running the formal generation path remain in
their natural non-AOT owners rather than being added to this directory:
`StaticJIT/Scaffold/AngelscriptJITScaffoldLineEndingTests.cpp` protects managed
marker recognition across CRLF checkouts, while
`Cache/AngelscriptCacheFunctionArtifactPropertyValidationTests.cpp` protects
the maintained-fork function-artifact writer's fail-closed property lookup.

The first adaptive non-unity build after this extraction also found that
`RuntimeRoutes/AngelscriptStaticJITAotFrameRecursionRouteTests.cpp` had relied
on a unity sibling for `FAngelscriptScriptTestCallbackScope`. The split now
owns the direct `Testing/AngelscriptScriptTestRunner.h` include. This is the
expected benefit of compiling the bounded translation units independently:
their real dependencies become explicit instead of being hidden by unity
composition.

The independent `GenerationFacts` class was subsequently moved out of the
root translation unit into
`Generation/AngelscriptStaticJITAotGenerationSnapshotTests.cpp`. This is a
pure ownership move: the automation prefix and test method name remain the
same, and the test continues to create only its original single interpreter
fixture Engine.

Task 7.4's real BytecodeJIT-versus-TypedASTJIT identity proof stays in the
existing `Generation/AngelscriptStaticJITAotGenerationVerificationTests.cpp`
session. Adding another Engine-owning test class merely to reduce line count
would increase test time and exercise a different generation snapshot; the
new identity assertions therefore reuse that bounded two-run generation
oracle. The exact automation passed at
`Saved/Tests/typed-aot-provider-identity-green-03/20260816_174750_272_ac8d5a1c/`.

Task 7.5's publication-shape proof is isolated in
`Generation/AngelscriptStaticJITAotMixedBackendPublicationTests.cpp`. It reads
the already installed `AngelscriptTestJIT` Provider catalog and proves that
diagnostic FunctionKeys map one-to-one to backend-neutral entries, a single
ModuleKey contains both actual backends, TypedASTJIT publishes VM/Raw/Parms,
and the BytecodeJIT function retains a VM entry. Actual dispatch remains in
the existing shared-fixture `UASFunctionDispatch/` family, including the
generated-WorldContext case where a single function falls back to Bytecode
and deliberately has no Parms entry. This keeps catalog publication and
runtime dispatch as separate responsibilities without multiplying fixture
startup.

## Task 2.10 external implicit receiver partition

Real-source `external_implicit_this` coverage is scenario-owned beneath
`AngelScriptSDK/Compiler/TypedSemanticIR/ExternalImplicitThis/` instead of
growing the root TypedSemanticIR translation unit. The valid body, malformed
receiver and null-handle contracts each have one CQTest method in separate
`.cpp` files; a narrow header shares only exact lookup/execution and bytecode
normalization helpers.

The body owner covers parameter/local precedence, explicit and implicit fields,
the maintained mode-2 `GetX` accessor path and an ordinary method. The null
owner uses the real implicit-handle-by-value declaration and proves that capture
does not replace the VM `Null pointer access` path. The malformed owner preserves
the current frontend policy while proving missing/primitive receiver shapes
publish no HIR and retain the stable `InvalidEffectiveReceiver` reason.

Cross-Engine bytecode comparison normalizes only the same documented
pointer-bearing operands used by the existing capture-parity oracle. A temporary
opcode/word renderer remains in the support header as a bounded debugging aid;
it exposed that the only apparent bytecode mismatch was the Engine-local type
pointer in `FREE`, not an instruction or stack-layout change.

Evidence: affected build PASS at
`Saved/Build/typed-semantic-task210-external-receiver-green2/
20260816_230502_198_442c1f34/`, focused `3/3 PASS` at
`Saved/Tests/typed-semantic-task210-external-receiver-green2/
20260816_230522_312_bf7768c0/`, and complete TypedSemanticIR `44/44 PASS` at
`Saved/Tests/typed-semantic-task210-regression/
20260816_230607_621_fb80272f/`.

## Task 2.11 mixin call partition

Real-source mixin coverage is scenario-owned beneath
`AngelScriptSDK/Compiler/TypedSemanticIR/Mixin/`. The valid method-syntax
contract and the maintained free-call rejection have separate `.cpp` owners;
a narrow support header shares only exact lookup, resolved-call/formal queries,
literal recognition and execution observation.

The call owner proves a side-effecting source receiver executes once, aliases
effective formal zero, remains distinct from `external_implicit_this`, and
retains the compiler's final named/default/formal mapping plus reverse-formal
evaluation ranks. The free-call owner proves capture off/on both preserve the
existing `No matching signatures` rejection and publish no partial Entry/HIR.

The first build exposed one old Adaptive Unity include leak in
`AngelscriptNativeFunctionDirectionDefaultTests.cpp`; the file now directly
includes the language-case helper it consumes. Evidence: affected build PASS
at `Saved/Build/typed-semantic-task211-mixin-green-build/
20260816_233005_894_65dd7140/`, focused `2/2 PASS` at
`Saved/Tests/typed-semantic-task211-mixin-green/
20260816_233019_313_eb823903/`, and complete TypedSemanticIR `46/46 PASS` at
`Saved/Tests/typed-semantic-task211-regression/
20260816_233103_970_a4b191c8/`.

## Task 2.12 call rewrite and metadata partition

Task 2.12 的真实 source/compiler coverage 没有继续堆进 TypedSemanticIR 根目录，
而是按能力拆到两个子目录：

- `AngelScriptSDK/Compiler/TypedSemanticIR/CallRewrites/`：
  `CompileOutTests.cpp` 独立拥有 `CompileOutEntirely`、
  `ReplaceWithFirstParam`、`CompileOutAsMethodChain` 的最终值/receiver/无可执行
  call 合同；`CallRewriteTestSupport.h` 只共享 typed lookup；
- `AngelScriptSDK/Compiler/TypedSemanticIR/CallMetadata/`：
  `HiddenArgumentTests.cpp` 独立拥有 host-hidden origin，
  `NativeAbiTests.cpp` 独立拥有 first-param/determines-output/generic/user-data
  等 pointer-free native ABI 事实。

这三个 `.cpp` 各只有一个 CQTest method，支持继续按 call shape 扩展而不会重新
形成单一巨型测试文件。受影响的 synthetic consumer tests 仍留在原来的
`StaticJIT/TypedASTJIT/` eligibility、call-closure、generated-output owner 中，
因为它们验证的是 consumer 合同，不是 compiler capture ownership。

证据：focused call partition `3/3 PASS` at
`Saved/Tests/typed-semantic-task212-call-green/
20260817_000630_588_5f596b29/`，complete TypedSemanticIR `49/49 PASS` at
`Saved/Tests/typed-semantic-task212-full-green/
20260817_000711_876_48b83539/`；consumer regressions 分别为 `30/30 PASS` 和
`25/25 PASS`，详见 `research/task-2-12-call-rewrites-and-native-abi.md`。

## Task 2.13 evaluation-order partition

Task 2.13 按 observable capability 新建
`AngelScriptSDK/Compiler/TypedSemanticIR/EvaluationOrder/`，没有把 2/3/8 operand
矩阵塞回根级 `AngelscriptNativeTypedSemanticIRTests.cpp`：

- `Calls/AngelscriptNativeTypedSemanticIROrdinaryCallOrderTests.cpp`：ordinary call；
- `Calls/AngelscriptNativeTypedSemanticIRConstructorIndexOrderTests.cpp`：constructor/index；
- `Chains/AngelscriptNativeTypedSemanticIRChainOrderTests.cpp`：call/member/index chain；
- `Expressions/AngelscriptNativeTypedSemanticIRExpressionOrderTests.cpp`：binary、
  assignment、compound assignment、nested cast；
- `AngelscriptNativeTypedSemanticIREvaluationOrderTestSupport.h`：只共享 HIR graph
  lookup/formal/marker traversal。

四个 `.cpp` 各一个 CQTest method，行数为 201、184、164、237；support header 为
246 行。完整矩阵复用 maintained eager-expression suite 的 2/3/8 operand oracle：
call/constructor/index/chains 反向 final-formal，binary/RHS/casts 左到右，独立
receiver 显式位于 argument steps 之后。focused `4/4 PASS`，complete
TypedSemanticIR `53/53 PASS`；完整证据和 adaptive-unity 自包含修复记录在
`research/task-2-13-evaluation-order.md`。

## Task 2.14 argument-origin partition

参数来源测试按 compiler observable capability 放在
`AngelScriptSDK/Compiler/TypedSemanticIR/ArgumentOrigins/`：

- `ExplicitArgumentOriginTests.cpp` 独立验证 positional/named source
  ordinal/name/span 与 formal/evaluation 的正交关系；
- `DefaultArgumentOriginTests.cpp` 独立验证 callee declaration、parameter、
  canonical default、caller processed span 和 Signature dependency；
- `ArgumentOriginTestSupport.h` 只共享 resolved-call/formal/span/dependency 查询。

既有 host-hidden 行为继续留在 `CallMetadata/HiddenArgumentTests.cpp`，因为它的
注册型 hidden ABI fixture 已经是该能力的单一 owner。consumer synthetic HIR
仍由 `StaticJIT/TypedASTJIT/` 下的 Eligibility、CallClosure、GeneratedOutput
各自拥有。本轮没有把测试重新堆进根级 TypedSemanticIR 文件。focused `2/2`、
hidden `1/1`、完整 TypedSemanticIR `55/55`、consumer `30/30 + 25/25` 全部通过；
完整证据见 `research/task-2-14-argument-provenance.md`。

## Task 2.16 call-target and body-ownership partition

调用目标身份按 compiler observable capability 放在
`AngelScriptSDK/Compiler/TypedSemanticIR/CallTargets/`：

- `ImportedCallTargetTests.cpp` 独立拥有 import bind/rebind/unbind、稳定 slot、
  source/signature 和禁止冻结 `boundFunctionId` 的合同；
- `BodyOwnershipTests.cpp` 独立拥有 local/system/shared/external ownership 和
  malformed verifier matrix；
- `CallTargetTestSupport.h` 只共享 raw SDK Engine/module/HIR 查询和精确执行辅助。

shared/external 的公开 parser token 在 maintained fork 中仍禁用，因此测试通过
`CompileFunction(..., asCOMP_ADD_TO_MODULE)` 构造真实 module authority，不把未来语法
混入当前合同。consumer synthetic tuples 继续由 `StaticJIT/TypedASTJIT/` 下的
Eligibility、CallClosure、GeneratedOutput owner 负责。focused `2/2`、完整 HIR
`57/57`、consumer `30/30 + 25/25`、Standalone `20/20` 均通过；完整记录见
`research/task-2-16-call-target-and-body-ownership.md`。
