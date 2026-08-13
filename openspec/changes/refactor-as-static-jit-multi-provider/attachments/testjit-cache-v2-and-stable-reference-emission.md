# TestJIT Cache V2 and stable-reference emission — 2026-08-12

## Scope and current boundary

This attachment records the incremental evidence for OpenSpec task 6.2 and the
completed command-isolation/emission portion of 6.3. Task 6.3 remains open
because the legacy `AngelscriptTest/StaticJIT/AOT/Generated` fixture and its
local `.Cache` have not yet been removed. Cache V2 restoration and real
Provider consumption remain tasks 6.4–6.5.

## Fixture and command isolation

The fixed test workflow is owned by `AngelscriptTest` and is invoked as:

```text
-run=AngelscriptTestJIT -Mode=Generate|Verify
```

It creates a temporary Script root from committed test fixture strings and
publishes only into
`AngelscriptTestJIT/Private/Generated/Profiles/EditorDevelopment`. It does not
call the project Scaffold/Generate service, discover the host `Script/` tree,
consume `.uproject` project identity, or write project provider output.

The fixture currently contains two non-empty AngelScript modules and produces
exactly two module compilation units:

- `ASStaticJITAotImportProvider` ->
  `Modules/363ba981d7c3e864c636826dc571c5d7e306f994e52ec1db353151967b367751.jit.cpp`
  with one generated function;
- `ASStaticJITAotFixture` ->
  `Modules/c8f2291154afd48cf9d8c267f8bfcf5bff307741bbaa61ea978863ed08f780ed.jit.cpp`
  with 29 generated functions.

The carrier has `bUseUnity = false`, so UBT compiles the two generated module
sources independently. The generated inventory has no slice, bucket, local
cache, or generated `.jit.hpp` path.

## Cross-process drift discovered during Verify

The first independent Verify correctly failed because the generated Provider
preamble still persisted current-process values through legacy constructs:

- `FJitRef_GlobalVar` initialized with a pointer literal;
- `FJitRef_SystemFunctionPointer` initialized with a process address;
- `FJitRef_Type` initialized with a current type pointer;
- `FJitVerifyPropertyOffset` and related layout verifier definitions.

The module bodies were stable, but `Provider.generated.cpp` changed whenever a
new Unreal process assigned different addresses. Weakening Verify or ignoring
the preamble would have hidden a real packaged-provider defect, so the emitter
was changed instead.

## Stable Engine-local emission

Provider-mode generation now builds a final sorted reference-descriptor set
before assigning slot indexes. Generated bodies obtain values through the
current `FScriptExecution` and immutable Binding reference table:

- `GetScriptFunction`;
- `GetSystemFunctionPointer`;
- `GetTypeInfo` / `GetObjectType`;
- `GetGlobalStorage`;
- `GetPropertyOffset`.

Opaque VM-owned `FString` literals referenced by `PGA`/`PshGPtr` bytecodes are
pre-scanned and added as content-addressed `StringLiteral` descriptors. This is
necessary because their storage is process-local while the existing Cache V2
dependency set does not otherwise list them. Their content, not their address,
participates in generated identity.

The regenerated manifest contains the following ordered descriptor counts:

```text
EnvironmentSymbol  8
ScriptFunction    11
ScriptProperty     5
ScriptType        29
StringLiteral      3
```

Search of all three generated `.cpp` files finds no legacy `FJitRef_*`, no
`FJitVerify*`, and no address-shaped pointer literal. The resulting generation
is:

```text
93680e6b30984e4428ed5e594dfb16279834b3857d9126ea19f4feed60c5a3a3
```

## TDD and verification evidence

- Initial RED generated-output regression: five pass, the new stable-slot
  invariant fails as expected:
  `Saved/Tests/staticjit-stable-reference-slots-red-tests/20260812_215119_636_0a8cb532/Report`.
- Runtime/Test compile after implementing the emitter:
  `Saved/Build/staticjit-stable-reference-slots-compile2/20260812_215820_173_4f6b373b`.
- Product Generate commandlet, capturing both fixture modules:
  `Saved/Commandlet/staticjit-stable-reference-slots-generate1/20260812_215855_937_e70b915a/Commandlet.log`.
- Non-unity compilation and link of both regenerated module sources plus
  `Provider.generated.cpp` into `UnrealEditor-AngelscriptTestJIT.dll`:
  `Saved/Build/staticjit-stable-reference-slots-generated-build/20260812_220103_374_e0683f26`.
- Generated ownership/reference invariant tests, 6/6 pass:
  `Saved/Tests/staticjit-stable-reference-slots-green-tests/20260812_220117_660_6782c8ee/Report`.
- Independent new-process, read-only Verify with the same ProviderGeneration:
  `Saved/Commandlet/staticjit-stable-reference-slots-verify1/20260812_220155_659_3b5957d1/Commandlet.log`.

## Remaining implementation risks

The stable emitter proves relocatable bytes; it does not yet prove that a
production Engine builds every current slot value and executes this real
Provider. The next slice must construct the Engine-local resolver for script
functions/types/properties/globals, environment functions/types, and string
literals, then cover source and fresh Cache V2 engines.

Two details require explicit coverage rather than assumptions:

- class/static-type helper globals need a use-specific stable storage identity
  instead of accidentally reusing a type descriptor;
- referenced script modules with no generated eligible function still need a
  complete module-key index, rather than relying only on the generated-function
  list.

The ignored host `Script/PrecompiledScript.Cache` also remains intentionally in
place until task 6.4/10.4 owns the legacy-cache removal and package proof.

## Current source-Engine reference resolution — 2026-08-12

The first resolver test deliberately used the existing memory-compile helper
and failed with `MissingCurrentPublication`. That helper compiles valid VM
modules but does not construct the authoritative source inventory or pass a
capture context into `CompileModules`; accepting its live objects would have
made the Provider, rather than the current Cache V2 publication, the ABI
authority.

The TestJIT generation Engine path was therefore extracted into an RAII fixture
session and is now shared by generation and runtime proofs. It materializes the
two committed fixtures below an isolated project `Script/` root, uses normal
`InitialCompile`, owns a unique Cache V2 root, and retires the Engine before
deleting that root. The next run proved one current publication transaction:

```text
Candidates=2 Captured=2 Skipped=0
Disposition=Current Modules=2
SourceSnapshot=c906ca3e9ace506cfd2d0acb391e3f171af69cf5ecc20c0909df1d9f51e5aa9e
```

That run advanced to real reference resolution and reported 18/22 unique
references. The four misses were three `ScriptType` keys and one
`ScriptProperty` key. Root cause: the initial resolver enumerated only
`asCScriptEngine::allRegisteredTypes`, while script-declared object/enum/
typedef/funcdef types are owned by each current `asCModule::allLocalTypes`.
The resolver now indexes all active modules, which is also the ownership shape
rebuilt by fresh Cache V2 restoration. The property index is derived from those
current owner types, so no fixture-specific key or numeric type id is used.

GREEN evidence:

- Editor build after the shared source-session and module-local type fix:
  `Saved/Build/staticjit-current-engine-module-local-types-compile/20260812_222814_459_feeafc6a`.
- Focused real-provider reference test, 1/1 pass:
  `Saved/Tests/staticjit-current-engine-reference-resolver-green4/20260812_222834_530_a4e0792a/Report`.
- Runtime diagnostic from that test:
  `Current Engine reference index built: requested=22 resolved=22 unresolved=[]`.
- Every copied TestJIT catalog entry subsequently built an exact immutable
  reference table from those current-Engine values.

This closes the source-Engine resolver construction slice, not task 6.4 or
6.5. No Provider entry is selected/published by production orchestration yet,
and a second fresh Engine has not yet restored the persisted Cache V2
generation and executed the committed DLL.

## Production source-Engine route cutover investigation — 2026-08-12

The next TDD slice added a production-shaped source-Engine test that requires
`InitialCompile()` itself to discover the committed TestJIT Provider, publish
the complete VM/Raw/UserData binding for
`int IndependentModuleEntryForAOT()`, and execute the Provider entry with the
fixture result `87`. The test does not manually invoke the Provider router.

Implementation in this slice now includes:

- one shared current-native environment-fingerprint builder used by project
  generation, TestJIT generation, and Runtime matching;
- one shared Parms-entry eligibility predicate used by generation and Runtime
  matching;
- a Runtime `FAngelscriptJITProviderRouter` that snapshots registered
  Providers and the current Engine route generation, resolves required stable
  references, performs typed matching, publishes exact selections, clears
  stale selections on miss, and refreshes the Engine-local route snapshot;
- automatic router invocation after a successful authoritative
  `FAngelscriptEngine::InitialCompile()`.

The implementation compiles through all 123 Editor actions:

```text
Saved/Build/staticjit-source-engine-provider-router-compile1/20260812_224603_766_da341d72
Result: Succeeded
```

The focused test remains RED, 0/1:

```text
Saved/Tests/staticjit-source-engine-provider-route-green1/20260812_224830_355_a3abb79c/Report
StaticJIT Provider routing: code=3 profile=EditorDevelopment ...
Expected pointer to be not Null (AngelscriptStaticJITAotTests.cpp:586)
```

`code=3` is `MissingStaticJITCompiler`. The failure is before Provider
enumeration or matching, so the logged zero Provider count is not evidence of
a registration, ProviderId, ABI, environment, or reference mismatch.

Root-cause tracing found that a normal owned `FAngelscriptEngine` currently
leaves `StaticJIT` null and does not install an `asIJITCompiler`. The only
non-ThirdParty allocation and `SetJITCompiler` call is the legacy
precompiled-data diagnostics compatibility loader in
`StaticJITDiagnostics.cpp`. Destruction already uninstalls and deletes an
owned compiler, but the symmetric production initialization path is absent.
No Runtime initialization currently sets `asEP_INCLUDE_JIT_INSTRUCTIONS`
either.

This is an initialization/lifecycle cutover gap, not a reason to weaken the
source-Engine test or restore the legacy `.Cache` prerequisite. Before making
the minimal production change, the next investigation step is to select the
single shared owned-Engine initialization point and confirm the required
`asEP_INCLUDE_JIT_INSTRUCTIONS` timing/target guards against the complete
existing initialization and compatibility paths. Tasks 6.4 and 6.5 remain
open until the source Engine and a second fresh Cache V2 Engine both execute
the committed Provider and the mismatch/lifecycle matrix is covered.

## Production compiler ownership and source-Engine GREEN — 2026-08-12

Normal owned Engine initialization now installs one Engine-owned
`FAngelscriptStaticJIT` during `PreInitialize_GameThread`, sets its
`PrecompiledData`, enables `asEP_INCLUDE_JIT_INSTRUCTIONS`, and registers it
with the underlying `asIScriptEngine`. Existing shutdown remains the symmetric
owner: it first uninstalls the compiler and then deletes the Engine-owned
instance. The compatibility diagnostics path continues to use the same owned
slot instead of creating a competing process-global compiler.

The first provider regeneration with JIT instructions exposed a maintained-VM
gap rather than a Provider mismatch: the C++ emitter reached `asBC_JitEntry`
and asserted because that bytecode had no emission handler. Inspection of the
maintained interpreter showed that `asBC_JitEntry` is an intentional no-op
resume marker; per-function native dispatch is made through the function's
`VMEntry`, and the interpreter switch also treats the marker as a no-op. The
StaticJIT bytecode emitter therefore gained the matching no-op handler. It
does not emit a call, pointer, or new control-flow edge.

Fresh evidence after that fix:

- Runtime/Test incremental build:
  `Saved/Build/staticjit-jitentry-bytecode-green1/20260812_230620_624_e0c57ba2`;
- successful product Generate for two module units and 30 functions:
  `Saved/Commandlet/staticjit-source-engine-regenerate-jitentry-green1/20260812_230636_222_3e2574ee/Commandlet.log`;
- non-unity compilation/link of the two regenerated module sources:
  `Saved/Build/staticjit-regenerated-provider-jitentry-green1/20260812_230751_999_c14d3d57`;
- independent new-process Verify, reporting `verified=30`, `native=30`,
  `vm=0`, `references=22/22`, and `matchResults=[0:30]`:
  `Saved/Commandlet/staticjit-regenerated-provider-cross-process-verify-green1/20260812_230805_784_4839faad/Commandlet.log`;
- production-shaped source Engine auto-publication and execution, 1/1 pass:
  `Saved/Tests/staticjit-source-engine-provider-route-green3/20260812_231001_146_57f9abbf/Report`.

The regenerated Provider generation is now:

```text
f54ad740009149a773a19f3d93dead20975da8c7150a1dd961d5e281c28da8bb
```

The source proof obtains the binding only after normal `InitialCompile`; it
does not call the router from the test. The selected function has non-null
VM/Raw/UserData state, resolves to a Native route, and executes
`IndependentModuleEntryForAOT()` from the committed TestJIT DLL with result
`87`.

## Fresh Cache V2 Engine: typed hybrid restoration — 2026-08-12

The initial fresh-Engine test intentionally required a strict producer A /
destroy A / allocate B lifecycle. Producer A compiled both committed source
modules and flushed generation
`7a5aa990fad4303a6cddd0571bb8e050e6cb48387a47600435174d4846133b24`
to its isolated Cache V2 root. Engine B found that generation, but the first
test failed because it incorrectly required whole-module exact restoration,
two `bLoadedIncrementalCache` modules, and zero frontend events:

```text
Saved/Tests/staticjit-cache-v2-decision-trace-red2/20260812_231712_861_7658f132/Report
```

Verbose rerun established the real reason rather than a Cache enablement or
commandlet gate:

```text
[CacheV2][ExactStartup] Candidate miss ... Reason=10
Detail=A persisted module is outside the executable exact-start restore vertical
```

The TestJIT primary fixture deliberately contains reflected UCLASS types,
properties, inheritance, and 29 functions. Cache V2's current executable
exact-start vertical accepts only the already-tested narrow enum/global
module shape. Existing production class-cache tests normatively exercise a
typed hybrid fallback for broader class graphs: Cache V2 selects the persisted
generation, the current Engine rebuilds module/class authority through the
frontend, and the compiler restores cacheable function bodies into that fresh
Engine's own function objects. Expanding exact whole-module class restoration
inside this StaticJIT change would cross the Cache V2 capability boundary and
would contradict that established fallback contract.

The TestJIT proof now validates the production hybrid path without weakening
the artifact requirement:

- Engine A is destroyed before Engine B is allocated;
- B selects the exact generation written by A;
- the selected generation contains exactly two candidate modules;
- all 30 generated-provider functions are restored from Cache V2;
- three explicitly non-cacheable synthesized helpers compile normally;
- B resolves its own 22/22 reference slots and publishes 30 Native / 0 VM
  routes;
- B executes the committed Provider function and returns `87`.

Fresh build and GREEN evidence:

- `Saved/Build/staticjit-cache-v2-hybrid-proof-compile1/20260812_232522_711_e84e7c9c`;
- `Saved/Tests/staticjit-cache-v2-hybrid-proof-green1/20260812_232758_887_673f1d70/Report` (1/1 pass).

The test diagnostic is:

```text
Generation=7a5aa990fad4303a6cddd0571bb8e050e6cb48387a47600435174d4846133b24
Modules=2 RestoredFunctions=30 CompiledMisses=3 NotCacheable=3 FrontendEvents=6
StaticJIT: verified=30 exact=30 native=30 vm=0 references=22/22
```

This closes the fresh Cache V2 consumer slice of task 6.4. Task 6.4 remains
unchecked until the legacy local AOT fixture/cache prerequisite is removed;
task 6.5 remains open for the complete mismatch, multi-Engine,
Provider-refresh, UASFunction, coexistence, unregister, and lifetime matrix.

## Mixed class graph plus global functions: Cache V2 gap and fix — 2026-08-12

While migrating the remaining legacy AOT fixture coverage, adding ordinary
global functions back beside the three reflected script classes caused clean
capture to reject the whole module:

```text
Class-graph function int AddForAOT(const int) has no complete stable type
owner/invocation/source authority
```

This was not an AngelScript or StaticJIT restriction. The class-graph capture
vertical treated the presence of two or more classes as proof that every
function in the module must have a type owner. A normal module-level global
function instead has a stable Module owner and the GlobalFunction invocation
kind. Moving the globals into a class would have hidden the Cache limitation
and changed the fixture's real source shape, so that workaround was rejected
after user review.

A TDD regression added `int AddGlobal(int Value)` beside a two-UCLASS class
graph and requires capture, cold-generation validation, fresh-Engine restore,
signature preservation, and execution with `35 -> 42`. The expected RED was:

```text
Saved/Tests/cache-classgraph-mixed-global-red1/
  20260812_235059_735_9cba0e63/Report
Totals: total=1 passed=0 failed=1
```

Cache V2 now:

- classifies both Module-owned globals and Type-owned methods while building
  the same module interface;
- keeps global functions out of class method/VFT/reflection member tables;
- restores class method skeletons per type, then restores module-owned global
  functions through the opaque function artifact codec;
- validates global parameter counts against the cached declaration instead of
  assuming the old no-parameter global-only vertical.

The focused GREEN proof restored two types and six functions into a fresh
Engine and executed the restored parameterized global function:

```text
Saved/Tests/cache-classgraph-mixed-global-green1/
  20260812_235324_072_7603e788/Report
Capture: 2 classes, 6 stable functions, 18 graph-validated records
Restore: 2 types, 6 current-engine function routes
Execution: AddGlobal(35) == 42
Totals: total=1 passed=1 failed=0
```

The TestJIT fixture is being returned to the mixed module shape so this Cache
capability is exercised by the real one-AS-module/one-`.jit.cpp` workflow.
Imports and reflected global/static-class declarations remain separate shapes;
they are not silently claimed as covered by this fix.

## Application-registered property references: Cache V2 gap and fix — 2026-08-13

After the mixed class/global fix, the real TestJIT fixture reached the next
independent capture failure in `ObjectLastNativeForAOT()`:

```text
Function int ObjectLastNativeForAOT() class-graph dependency capture failed:
Error=64 Class=6
```

The script expression `Value.Value` depends on both the application-registered
`FAotObjectLastProbe` type and its application-registered `int Value`
property. Cache V2 already assigned stable EnvironmentSymbol identities to
registered types and system functions, but its property branch only accepted
module-local ScriptProperty identities. The raw compiler pointer was therefore
not portable to a fresh Engine and capture correctly failed closed with
`CurrentSymbolMissing`.

The production environment identity now has an explicit registered-property
reference:

- its stable key contains the registered owner type's stable key, property
  name, and canonical AngelScript type;
- its ABI contains the owner ABI plus byte/composite offsets, access mask,
  exposed-access bits, composite-indirect, private/protected/inherited, and
  application-bind markers;
- clean capture records the dependency as EnvironmentAbi/EnvironmentSymbol;
- the opaque function-artifact validator applies the same classification to
  restored bytecode property relocations;
- the current Engine resolver enumerates effective registered properties and
  rejects ambiguous or ABI-mismatched matches.

The TDD test was first RED with the new property identity deliberately
returning no reference:

```text
Saved/Tests/cache-environment-property-red2/
  20260813_000311_846_79e8b396/Report
Totals: total=3 passed=2 failed=1
```

Two intermediate reruns exposed test-fixture facts rather than production
failures: a fully initialized project Engine is not the correct late native
registration fixture, and `RegisterObjectProperty()` stores application
properties in `asCObjectType::properties`, not script-only `localProperties`.
The focused test now uses three raw AngelScript Engines, matching the existing
SDK/exporter test convention.

Final focused evidence:

```text
Saved/Build/cache-environment-property-green-build4/
  20260813_001343_104_2e56242b
Saved/Tests/cache-environment-property-green4/
  20260813_001359_623_f7059bca/Report
Totals: total=3 passed=3 failed=0
```

It proves cross-Engine stable-key/ABI equality for identical registrations and
also proves that moving the same logical property to another byte offset keeps
the stable key but changes the ABI. The real TestJIT Generate/Verify cycle is
the next integration proof for capture, restored relocation validation, and
one-module/one-file emission.

## Current-Engine property materialization: StaticJIT routing gap and fix — 2026-08-13

The regenerated TestJIT Provider compiled successfully and contained all 43
fixture functions, but the first independent Verify exposed a second, narrower
gap after Cache V2 capture had already succeeded:

```text
StaticJIT Provider routing: code=0 profile=EditorDevelopment publication=1
providers=1 verified=43 exact=41 native=41 vm=2 references=28/29
sourceRoute=1 publishedRoute=2 matchResults=[0:41,8:2]
```

`EAngelscriptArtifactMatchResult` value `8` is `MissingReference`. The focused
provider-reference test identified the one missing unique reference and proved
that the two VM fallbacks shared it:

```text
Saved/Tests/staticjit-environment-property-reference-red2/
  20260813_002248_914_b44efffb/Report
Current Engine reference index built: requested=29 resolved=28
unresolved=[7:fb782abdc7bc2165cb75160cf047111ba3a29079ef1a57627bb5c54710f303b8:1]
Totals: total=1 passed=0 failed=1
```

The reference is the registered `FAotObjectLastProbe::Value` property. Cache
V2 could now build and validate its EnvironmentSymbol identity, but the
StaticJIT current-Engine index only materialized EnvironmentSymbol types and
system functions. It did not turn a property identity back into the current
Engine's `asCObjectProperty*`. Moving the fixture or accepting VM fallback
would have hidden an incomplete stable-reference implementation, so the
resolver was completed instead.

The Cache environment resolver now materializes an exact registered property
and its owning current-Engine type. It enumerates effective registered
properties, requires stable-key and ABI equality, and fails closed on
ambiguity. The StaticJIT resolver stores the current property pointer in the
immutable slot and retains the owner type for the slot lifetime. A changed
property layout therefore remains a typed ABI mismatch rather than silently
using a stale offset.

Focused build and materialization evidence:

```text
Saved/Build/staticjit-environment-property-reference-green-build1/
  20260813_002540_509_0d6a39cd
Saved/Tests/staticjit-environment-property-materialize-green1/
  20260813_002619_944_3aff15bd/Report
Totals: total=1 passed=1 failed=0 skipped=0
```

The property test proves an identical second Engine resolves to its own
property and owner type, while the same stable property with a shifted byte
offset is rejected.

The exact Provider-reference proof then reached the required all-Native state:

```text
Saved/Tests/staticjit-environment-property-reference-green1/
  20260813_002657_390_daef14dd/Report
Current Engine reference index built: requested=29 resolved=29 unresolved=[]
StaticJIT Provider routing: verified=43 exact=43 native=43 vm=0
references=29/29 matchResults=[0:43]
Totals: total=1 passed=1 failed=0 skipped=0
```

Finally, the independent fixed-root commandlet Verify repeated the same result
outside the focused automation method:

```text
Saved/Commandlet/staticjit-testjit-environment-property-verify-green1/
  20260813_002827_632_5cbe75fb/Commandlet.log
StaticJIT Provider routing: code=0 profile=EditorDevelopment publication=1
providers=1 verified=43 exact=43 native=43 vm=0 references=29/29
sourceRoute=1 publishedRoute=2 matchResults=[0:43]
Commandlet result: 0
```

This closes the mixed class/global/application-property integration defect. It
does not broaden the separate import or reflected global/static-class Cache V2
shapes, which remain explicit migration/test-matrix work rather than implicit
claims of this fix.

## Primitive global parameters and order-independent restore — 2026-08-13

Restoring the full committed TestJIT fixture first exposed two independent
clean-capture rejections. The provider module was rejected because its
exported function has an `int` parameter, while the class-graph consumer was
rejected separately because it contains an import. This section records only
the provider/global-function closure; import graph support remains the next
explicit step.

The focused RED extended the global-only round trip with
`int AddFixtureValue(int Value)` and a no-argument entry that calls it. Capture
failed at the old hard-coded signature restriction:

```text
Saved/Tests/cache-global-parameter-red2/
  20260813_004533_299_164420c0/Report
IC-434 global-only capture: Error=2 Records=0 GraphRecords=0
Detail=Every current authority function must be a global int function with no parameters
Totals: total=1 passed=0 failed=1 skipped=0
```

The current-module authority now records primitive return and parameter types,
ordered parameter names, and passing modes instead of synthesizing every
declaration as `int Function()`. During the first GREEN attempt, this correctly
captured the module but revealed two restore-side restrictions in sequence:

```text
Saved/Tests/cache-global-parameter-green1/
  20260813_004819_406_a34140e3/Report
Detail=A FunctionBody is not supported by the selected type materializer:
Declaration=int AddFixtureValue(const int)

Saved/Tests/cache-global-parameter-green2/
  20260813_005026_469_ede74199/Report
Detail=The private VM adapter rejected function int ParameterFixtureEntry()
```

The second failure was order-sensitive: a caller could be restored before its
same-module callee because persistent graph order is identity order, not an
execution dependency topological order. The restore path now materializes all
global function signature skeletons before restoring any body, exactly as the
class path already does for methods. Relocations therefore resolve against the
complete current module function table, independent of record ordering.

Build and final cross-Engine execution evidence:

```text
Saved/Build/cache-global-skeleton-green-build2/
  20260813_005419_879_2ef7c5d1
Saved/Tests/cache-global-parameter-green4/
  20260813_005456_447_0e39b53f/Report
IC-434 global-only capture: Error=0 Records=12 GraphRecords=12
Detail=Captured and graph-validated module ASCacheV2GlobalFunctionOnlyRestore
with 4 functions
IC-434 global-only restore: Error=0 Stage=7 Types=0 Functions=4
Detail=Atomically restored 1 modules, 0 types and 4 current-engine function routes
Totals: total=1 passed=1 failed=0 skipped=0
```

The producer Engine is destroyed before validation/restoration. The consumer
finds the restored entry by declaration and executes it to `42`, proving that
both the parameterized callee and the order-independent intra-module call
relocation are live rather than merely serialized.

## Reflection-only StaticsClass in a mixed class/global graph — 2026-08-13

The earlier full-fixture diagnosis above used the public generic rejection
text and initially described the consumer failure as an import-shape issue.
Verbose shape evidence corrected that interpretation: the preprocessor had
already resolved/removed the source import table, while the module owned four
class descriptors but only three VM object types:

```text
Saved/Commandlet/staticjit-testjit-full-fixture-diagnostic2/
  20260813_004044_653_af267078/Commandlet.log
Classes=4 ObjectTypes=3 ImportedModules=0 ImportedFunctions=0
```

The fourth descriptor is the intentional `Module_<ModuleName>Statics`
container created for module-level `UFUNCTION` declarations. It has a native
`UObject` code root and reflected function descriptors, but no AngelScript VM
object type. Consequently, forcing `Module.Classes.Num()` to equal
`GetObjectTypeCount()` was a Cache V2 modeling defect, not a language rule that
forbids global functions beside a class graph.

A focused regression changed the existing mixed class/global round trip to
contain two ordinary `UCLASS` types plus a reflected, parameterized module
global:

```angelscript
UFUNCTION()
int AddGlobal(int Value)
{
    return Value + 7;
}
```

The RED reproduced the exact stale assumption before any restore work:

```text
Saved/Tests/cache-statics-class-red/
  20260813_010637_274_2290a2d5/Report
Detail=The class-graph capture vertical requires two or more classes and no
enum, delegate, import, typedef or post-init declaration
Totals: total=1 passed=0 failed=1 skipped=0
```

Cache capture now classifies ordinary VM classes and the optional
reflection-only StaticsClass separately. The StaticsClass receives its own
stable type declaration and TypeSchema with:

- `Generated | ReferenceType` semantics and zero-size/one-alignment layout;
- one `CodeSuper` environment relation to the native `UObject` root;
- ordered reflected members targeting module-owned global function
  declarations;
- no VM properties, method table, VFT, behavior slots, shadow type, or
  generated `StaticClass` global.

The first GREEN attempt then exposed an independent graph-closure defect. The
local TypeSchema was valid, but module graph validation treated every reflected
member as a type-owned `Method`:

```text
Saved/Tests/cache-statics-class-green1/
  20260813_011305_262_5c5a9148/Report
Detail=Captured module graph failed: Error=35 Class=5 Kind=7 Stage=5 Offset=455
Error=35: MissingOwner
```

Graph closure now selects ownership from the schema form: ordinary UClass
members remain type-owned `Method` declarations, while StaticsClass members
must be module-owned `GlobalFunction` declarations. Module identity, stable
function key, declaration ABI, target kind, reflection order, and script name
are still checked exactly.

Restore resolves the StaticsClass code root without materializing a VM type,
creates all global function skeletons before descriptor reconstruction, and
then lets ClassGenerator build the UClass/UFunction surface from the restored
descriptor. Ordinary class materialization is unchanged.

Build and final fresh-Engine proof:

```text
Saved/Build/cache-statics-class-green-build2/
  20260813_011536_622_fec5fcd7
Saved/Tests/cache-statics-class-green2/
  20260813_011555_420_956922e3/Report
Capture: Error=0 Records=19 Graph=19
Detail=Captured 2 base-before-derived VM classes, 1 reflection-only
StaticsClass descriptor and 6 stable functions
Restore: Error=0 Stage=7 Types=3 Functions=6
Detail=Atomically restored 1 modules, 3 types and 6 current-engine function routes
Totals: total=1 passed=1 failed=0 skipped=0
```

The consumer proves all relevant outcomes rather than only record acceptance:
both ordinary reflected classes bind to consumer-engine VM types, the restored
StaticsClass has no `ScriptType` but owns a generated UClass containing
`AddGlobal`, and calling the restored parameterized VM global with `35`
returns `42`.

## StaticsClass global with an environment object parameter — 2026-08-13

After StaticsClass itself became graph-carried, the full committed TestJIT
fixture still captured only its provider module. Verbose compile-capture
diagnostics identified a distinct Cache V2 signature defect rather than an
import/cross-module failure:

```text
Saved/Commandlet/staticjit-testjit-cross-module-diagnostic/
  20260813_011854_135_e89e0e79/Commandlet.log
Module=ASStaticJITAotFixture
Detail=Function int StaticWorldContextCheck(UObject, const int) parameter 0
is outside the class-graph stable type table
```

The focused RED added a reflected module global whose `UObject` argument is
executed after a fresh-Engine restore:

```angelscript
UFUNCTION()
int AcceptEnvironmentObject(UObject Value)
{
    return Value == nullptr ? 42 : 7;
}
```

It failed at exactly the same capture boundary:

```text
Saved/Build/cache-statics-environment-red-build/
  20260813_012321_084_2e844acd
Saved/Tests/cache-statics-environment-red/
  20260813_012344_618_17472900/Report
Detail=Function int AcceptEnvironmentObject(UObject) parameter 0 is outside
the class-graph stable type table
Totals: total=1 passed=0 failed=1 skipped=0
```

The first implementation attempt intentionally tested the wider hypothesis
that every application-registered environment value/reference could use the
same path. That hypothesis was false. It admitted the project's existing
`FVector&inout` class graph into the function-artifact writer, whose current
property-offset table cannot represent that body shape and dereferenced a
missing object-property match:

```text
Saved/Build/cache-statics-environment-green-build/
  20260813_012621_019_f2322fa4
Saved/Tests/cache-statics-environment-green/
  20260813_012639_118_e9502a20/Automation.log
EXCEPTION_ACCESS_VIOLATION in asCWriter::FindObjectPropIndex
as_restore.cpp:7262, entered from CaptureClassGraphPrimitiveVertical
```

The supported contract was therefore kept narrow and fail-closed. Callable
signatures in a class graph may now encode an application-registered external
**object handle** as `EnvironmentType`, preserving reference/const/handle
qualifiers and a stable environment key plus exact ABI. Environment inline
values and non-handle references remain outside this capture shape and are
rejected before entering the artifact writer; they are not claimed as part of
this closure. Clean capture and current-module authority use the same rule.

The existing restore materializer already resolves an `EnvironmentType`
against the consumer Engine's registered type table by stable key and expected
ABI, so no producer type pointer or numeric TypeId is persisted.

Final build and fresh-Engine execution evidence:

```text
Saved/Build/cache-statics-environment-handle-green-build/
  20260813_012816_853_82954f17
Saved/Tests/cache-statics-environment-handle-green/
  20260813_012911_535_42bb0652/Report
Capture: Error=0 Records=21 Graph=21
Detail=Captured 2 base-before-derived VM classes, 1 reflection-only
StaticsClass descriptor and 7 stable functions
Restore: Error=0 Stage=7 Types=3 Functions=7
Detail=Atomically restored 1 modules, 3 types and 7 current-engine function routes
Totals: total=1 passed=1 failed=0 skipped=0
```

The consumer verifies the restored StaticsClass UFunction surface and executes
`AcceptEnvironmentObject(nullptr)` through the restored VM body to return
`42`. This closes the exact `UObject WorldContextObject` signature shape used
by the TestJIT fixture without silently broadening unsupported environment
value layouts.

## Cross-AS-module global-function dependencies — 2026-08-13

After the StaticsClass and environment-handle closures, the full TestJIT
fixture reached a separate Cache V2 boundary. The primary module contains a
module-global `ImportEntryForAOT()` whose source import has already been
resolved by preprocessing to the provider module's real script function. The
VM import table is therefore empty, but the compiled function body still owns
a foreign script-function relocation:

```text
Saved/Commandlet/staticjit-testjit-full-after-environment-handle/
  20260813_013052_274_2b02bc27/Commandlet.log
Function int ImportEntryForAOT() class-graph dependency capture failed:
Error=64 Class=6 Kind=0 Stage=0 Offset=0
CurrentSymbolMissing=64 Ineligible=6
```

`Error=64` is `CurrentSymbolMissing`. The previous clean-capture authority and
function-artifact codec could identify only functions owned by the selected
module or application-registered environment functions. A script function
owned by another AS module was therefore still pointer-shaped at the VM seam
and could not be admitted into the stable graph.

A focused provider/consumer production-publication test reproduced the issue
before the implementation:

```text
Saved/Tests/cache-cross-module-red-prefix/
  20260813_014309_035_53624d33/Report
Expected current publication Modules=2, actual Modules=1
Totals: total=3 passed=2 failed=1 skipped=0
```

The closure uses one stable identity throughout:

- a successful compile transaction pre-scans foreign script-function
  dependencies across its complete candidate module set;
- each target is resolved through its owner module's current declaration
  authority and becomes `ScriptFunction StableKey + declaration ABI +
  execution-content hash`;
- live pointers exist only inside that in-memory compile transaction and are
  never copied into a record, manifest, generated provider, or later Engine;
- the function-artifact VM stream was bumped from revision 4 to 5 and gained
  the function-artifact-only `x` owner marker, which carries the semantic
  `baseModuleName` plus the existing canonical signature; full-module bytecode
  remains unchanged;
- the outer Cache V2 function execution codec was bumped from 5 to 6 so old
  payloads cannot be mistaken for the new relocation contract;
- ambiguous hot-reload module names, targets outside the successful compile
  transaction, missing stable declaration authority, and unresolved foreign
  targets all fail closed to normal compilation/no publication.

Two small MSVC declaration iterations occurred while wiring the exported
prepass API: the first `friend` declaration and later `ANGELSCRIPTRUNTIME_API`
declaration had different linkage attributes. The final implementation keeps
the exported declaration unique and uses a narrow friend access struct rather
than giving the public function a second declaration. The passing Runtime/Test
build is:

```text
Saved/Build/cache-cross-module-implementation-build3/
  20260813_015505_902_c3da3f9e
Result: Succeeded
```

The stable publication test then became GREEN:

```text
Saved/Tests/cache-cross-module-publication-green/
  20260813_015601_369_244d9b8d/Report
Cache V2 cross-module publication: Modules=2
Totals: total=3 passed=3 failed=0 skipped=0
```

That result proves pointer-free publication but not fresh-process execution,
so a second TDD step destroys the producer Engine, validates the cold
Generation, batch-restores provider plus consumer into an isolated full
consumer Engine, and executes the consumer entry. Its RED landed at the exact
restore-side counterpart of the capture failure:

```text
Saved/Build/cache-cross-module-fresh-red-build/
  20260813_015944_070_0bc9a90a
Saved/Tests/cache-cross-module-fresh-red/
  20260813_020005_917_686c4e20/Report
Cache V2 current symbol missing: ReferenceKind=3 DependencyKind=3
Restore: Error=3 Stage=2
Detail=Consumer graph validation failed: Error=64 Kind=7 Stage=6 Offset=587
Totals: total=1 passed=0 failed=1 skipped=0
```

Fresh restore now derives a deterministic provider-before-consumer order from
persisted `ScriptFunction` dependencies. Each prepared provider contributes a
transaction-local current-symbol/external-function authority to later module
validation and VM relocation. All modules remain staging-only until the sole
batch commit, so a later consumer failure still discards the provider and
publishes nothing. Cross-module restore cycles and unselected required
providers fail closed; they are not partially activated.

Final build and cross-Engine execution evidence:

```text
Saved/Build/cache-cross-module-fresh-implementation-build2/
  20260813_020332_000_ad7215a9
Saved/Tests/cache-cross-module-fresh-green-attempt/
  20260813_020350_762_bf6c3a87/Report
Restore: Error=0 Stage=7 Modules=2 Functions=2
Detail=Atomically restored 2 modules, 2 types and 2 current-engine function routes
Executed consumer result=42
Totals: total=1 passed=1 failed=0 skipped=0
```

This closes the Cache path for a module-global function calling a global
function in another AS module without retaining producer pointers or numeric
FunctionIds. It also keeps the earlier interpretation explicit: global
functions are valid members of a class graph through the reflection-only
`StaticsClass`; the cross-module relocation was an independent Cache defect,
not a restriction on class graphs.

## TestJIT strict per-module generation and Compile Reuse closure — 2026-08-13

The complete TestJIT fixture now generates strictly one C++ translation unit
for each non-empty AS module. The two-module fixture produces only:

```text
ASStaticJITAotImportProvider -> one <StableModuleKey>.jit.cpp (2 functions)
ASStaticJITAotFixture        -> one <StableModuleKey>.jit.cpp (44 functions)
Total                        -> 2 generated .jit.cpp files, 46 functions
```

There is no per-function source, slice, fixed bucket, or aggregate module
source. A function body edit retains its module source path; another module's
owned bytes and timestamp remain independent. The generated TestJIT module
build and read-only Verify both passed, with provider routing reporting:

```text
verified=46 exact=46 native=46 vm=0 references=37/37
```

The full AOT group initially reached `17/18 PASS`. The sole failure was not a
StaticJIT generation or provider-DLL problem. It was the production Cache V2
Compile Reuse path used by the fresh-Engine AOT test:

```text
FreshCacheV2EnginePublishesAndExecutesCommittedProviderRoute
Modules=1 RestoredFunctions=2/46
CurrentSymbolMissing for the provider function used by ImportEntryForAOT()
```

### Compile Reuse transaction authority and ordering

Exact-source modules now prepare a transaction-local table containing their
current live script function, persisted stable FunctionKey, declaration ABI,
and execution-content hash. Changed-source modules never publish an old
function as authority. Duplicate, zero, invalid, or ambiguous entries reject
the Cache candidate and fall back to compilation.

The first implementation exposed a real ordering problem: the consumer module
was prepared before its provider, so its graph could not see the provider's
staged authority. Runtime `bindInformations`, imports, and dependency arrays
are not a reliable ordering oracle at this point in compilation. The final
ordering is derived from the already validated persisted Generation:

- scan FunctionBody ownership and cross-module `ScriptFunction` dependencies;
- build provider-to-consumer edges using stable module/function identities;
- topologically prepare providers first;
- reject missing providers, duplicate ownership, cycles, or invalid module
  keys rather than partially activating a transaction.

This advanced the focused regression from `2/46` to `45/46` restored
functions. The three remaining normal compile misses were the expected
generated `UClass StaticClass()` helpers, which are deliberately reconstructed
from current ClassGenerator authority and have no persisted FunctionBody.

### The final 45/46 failure and the actual root cause

The remaining function was the consumer's module-global `ImportEntryForAOT()`.
Its restored VM artifact refers to the provider's
`ImportedValueForAOT(int)`. Diagnostics were expanded to retain the complete
two-module lookup trace and to print the unresolved function's declaration,
FunctionId, funcType, semantic module name, invocation kind, object owner, and
traits. The decisive RED was:

```text
Saved/Tests/staticjit-cache-semantic-module-signature-authority-focused/
  20260813_031705_593_7eaf4a72/Report
RestoredFunctions=45/46 CompiledMisses=4 NotCacheable=3
function=int ImportedValueForAOT(const int)
id=80334 funcType=1
baseModule=ASStaticJITAotImportProvider invocation=1
```

Several deliberately fail-closed hypotheses were tested and rejected:

1. Matching only the provider `scriptFunctions` pointer failed because the
   artifact resolved to another current module generation.
2. Following the import table's `boundFunctionId` failed because this object
   was a real previous-generation script function, not the import signature
   object.
3. Rebuilding a stable key from the alias failed for this payload because the
   full-module bytecode reader retained top-level `const` on the by-value
   primitive parameter while the replacement source declaration did not.
4. Adding structural matching alone still failed. A diagnostic placed inside
   the prepared authority was never reached, proving that the artifact
   materialization path was not using that resolver at all.

The fourth result identified the principal wiring defect. Compile Reuse used
the composite prepared-function authority while computing and validating the
current function-input digest, but `TryRestoreFunctionArtifact()` constructed
a fresh `FAngelscriptFunctionArtifactCodec` without the external function
resolver. Thus dependency validation and VM relocation used different
identity authorities.

The final closure is intentionally narrow:

- `FAngelscriptCacheFunctionInputAuthorities` carries both the current-symbol
  resolver and the function-artifact external-function resolver;
- `TryRestoreFunctionFromValidatedGraph()` passes the same transaction-local
  authority through `TryRestoreFunctionArtifact()` into the actual restore
  codec;
- exact pointer identity remains the first choice;
- an import signature may follow its exact current `boundFunctionId`;
- a previous/replacement module generation first matches by semantic AS module
  name plus the candidate module's exact stable FunctionKey;
- only when full-bytecode normalization prevents that exact key does a narrow
  structural fallback ignore top-level `const` on a non-reference,
  non-handle, by-value parameter;
- return type, reference/handle constness, in/out flags, namespace, invocation
  family, method owner, semantic module name, and all other signature
  coordinates remain exact;
- two different prepared references matching the same alias are rejected,
  never selected by enumeration or module load order.

No pointer or numeric FunctionId is persisted. They are used only to inspect
the current Engine during one Compile Reuse transaction; the materialized
artifact still carries the stable FunctionKey, ABI, and execution-content
identity.

### Final evidence

The Runtime/Test build containing the complete resolver plumbing passed:

```text
Saved/Build/staticjit-cache-restore-codec-external-authority-build/
  20260813_032923_379_c99de30a
Result: Succeeded
```

The exact fresh-Engine regression then became GREEN and executed the imported
provider route:

```text
Saved/Tests/staticjit-cache-restore-codec-external-authority-focused/
  20260813_033008_301_ada044d2/Report
Modules=2 RestoredFunctions=46 CompiledMisses=3 NotCacheable=3
Totals: total=1 passed=1 failed=0 skipped=0
```

After removing the temporary large candidate-list warning, the clean Runtime
build passed:

```text
Saved/Build/staticjit-cache-final-cleanup-build/
  20260813_033301_964_f8d00e89
Result: Succeeded
```

The complete StaticJIT AOT group advanced from `17/18` to `18/18 PASS`:

```text
Saved/Tests/staticjit-testjit-two-module-aot-final-green/
  20260813_033321_537_ccf27a00/Report
StaticJIT Provider routing:
  verified=46 exact=46 native=46 vm=0 references=37/37
Fresh Cache V2:
  Modules=2 RestoredFunctions=46 CompiledMisses=3 NotCacheable=3
Totals: total=18 passed=18 failed=0 skipped=0
```

The directly affected Cache multi-module production group also remained
GREEN:

```text
Saved/Tests/staticjit-cache-multi-module-final-green/
  20260813_033847_868_62d4f6ed/Report
CrossModuleFunctionDependencyPublishesStableProviderReference: PASS
CrossModuleFunctionDependencyRestoresAndExecutesInFreshEngine: PASS
ProductionPublicationBuildsOneDeduplicatedCompleteGeneration: PASS
UnsupportedModuleDoesNotDiscardEligibleModulePublication: PASS
Totals: total=4 passed=4 failed=0 skipped=0
```

The Cache work therefore does not change the class-graph answer: module-global
functions are valid and are represented through the reflection-only
`StaticsClass`. The repaired concern is the separate cross-module identity and
VM relocation chain needed when one such global function calls another AS
module and a later Engine consumes the persisted artifact.

After the group runs, the cross-generation alias matcher was tightened once
more so unchanged declarations use the candidate module's exact stable
FunctionKey before the narrow by-value-const structural fallback. Because this
was a post-group source change, it was rebuilt and the exact two-Engine
regression was rerun rather than borrowing the earlier green result:

```text
Saved/Build/staticjit-cache-stable-key-first-alias-final-build/
  20260813_034147_019_7e8eb67d
Result: Succeeded

Saved/Tests/staticjit-cache-stable-key-first-alias-final-focused/
  20260813_034205_825_5fa0c349/Report
Modules=2 RestoredFunctions=46 CompiledMisses=3 NotCacheable=3
Totals: total=1 passed=1 failed=0 skipped=0
```

## Legacy paired-cache removal and persistence semantics — 2026-08-13

The final TestJIT migration removed the test-only paired archive workflow
rather than layering a second compatibility path over Cache V2. The obsolete
fixture output below is gone:

```text
AngelscriptTest/StaticJIT/AOT/Generated/ASStaticJITAotFixture.as.jit.hpp
AngelscriptTest/StaticJIT/AOT/Generated/AngelscriptJitCode_0.jit.cpp
AngelscriptTest/StaticJIT/AOT/Generated/AngelscriptJitInfo.jit.cpp
AngelscriptTest/StaticJIT/AOT/Generated/StaticJITAotFixture.Cache
```

The old `GetPrecompiledCacheFilename`, `IsGeneratedOutputAvailable`, local
`.Cache` loader, and runner fallback were removed. The ownership regression
requires that directory to contain no files and that the runner invoke only
`AngelscriptTestJIT -Mode=Generate|Verify`.

TDD evidence:

```text
Saved/Build/staticjit-testjit-legacy-workflow-red-build/
  20260813_040711_198_8b6114ec
Saved/Tests/staticjit-testjit-legacy-workflow-red/
  20260813_040731_963_4aead36a/Report
RED: four legacy generated/cache files were still present

Saved/Tests/staticjit-testjit-legacy-workflow-green-2/
  20260813_041547_197_e9d6cc0a/Report
Totals: total=7 passed=7 failed=0 skipped=0
```

While making ordinary AOT tests source-driven, a separate test-engine wrapper
bug was found. `FAngelscriptTestEngine::Create` unconditionally derived
`bDisableCacheV2Persistence` from whether a root override existed, thereby
overwriting an explicit caller request to disable persistence. It now combines
the caller request with the missing-root safety rule:

```cpp
LocalConfig.bDisableCacheV2Persistence =
    LocalConfig.bDisableCacheV2Persistence
    || LocalConfig.CacheV2RootOverride.IsEmpty();
```

The first attempted interpretation was deliberately broader: skip current
Cache V2 capture as well as disk persistence. A focused test passed under that
interpretation, but the full AOT matrix failed 14/18 because all TestJIT
provider entries correctly failed closed to VM. That result proved the current
in-memory artifact snapshot is provider matching authority, not merely pending
Store data:

```text
Saved/Build/cachev2-disable-capture-red-build/
  20260813_042329_933_74f89656
Saved/Tests/cachev2-disable-capture-red/
  20260813_042356_722_f4f3364a/Report

Saved/Tests/staticjit-testjit-cachev2-aot-green/
  20260813_042709_734_9d63bc2e/Report
Totals: total=18 passed=4 failed=14 skipped=0
Failure shape: generated Native route expected; fail-closed VM route selected
```

The final semantics are narrower and production-shaped:

- persistence disabled means no Store restore, flush, or shutdown files;
- source compile still prepares and publishes the in-memory `Current` artifact
  snapshot and therefore can match a loaded provider;
- only the dedicated fresh-Engine test enables Store persistence;
- Engine A flushes and is destroyed before Engine B is allocated;
- Engine B consumes the persisted candidate through normal startup and owns
  all restored function objects and resolved reference slots.

The focused final regression requires a valid in-memory `Current`, no function
reuse summary, and zero files below the isolated Cache root after shutdown:

```text
Saved/Build/staticjit-testjit-shared-fixture-build/
  20260813_044026_906_e363343c
Saved/Tests/cachev2-disable-persistence-final-green/
  20260813_044050_697_d9811734/Report
Totals: total=1 passed=1 failed=0 skipped=0
```

## Test-section fixture lifetime and bounded AOT cost

Capturing the complete two-module, 46-function current artifact snapshot costs
about 50 seconds on this workstation. Reconstructing it in every test method
caused the first migrated full prefix to hit its five-minute timeout even
though completed scenarios had no logic failures:

```text
Saved/Tests/staticjit-testjit-cachev2-aot-migration/
  20260813_041638_960_26975744
Result: timeout while entering the double-conversion test
```

Ordinary immutable behavior proofs now create one source fixture in CQTest
`BEFORE_ALL`, reuse it read-only within that test section, and destroy it in
`AFTER_ALL`. Probe state and UObjects remain method-local. Tests whose purpose
is Engine identity or Store lifetime do not share it: Fresh Cache still owns
producer plus consumer, and MultiEngine still constructs two sequential
isolated sessions. Diagnostics and UASFunction sections each own a separate
bounded fixture lifetime.

The final full prefix ran without timeout or cross-test contamination:

```text
Saved/Tests/staticjit-testjit-cachev2-aot-shared-green/
  20260813_044142_900_ae4f496d/Report
Totals: total=18 passed=18 failed=0 skipped=0
Duration: 455.32 seconds
```

## Reproducible Generate/rebuild/Verify workflow

`Tools/RunStaticJITTests.ps1` now supports `All`, `Generate`, and `Verify`.
The canonical `All` order is baseline Editor build, TestJIT Generate, normal
Editor rebuild, TestJIT Verify, then focused tests. It never invokes project
Scaffold or host-project source discovery.

Generate was byte-stable and reported both module files unchanged:

```text
Saved/Build/staticjit-testjit-workflow_01_baseline_build/
  20260813_044927_037_b26786e8
Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit-workflow_02_generate/
  20260813_044928_793_96ca6dea/Commandlet.log

ASStaticJITAotImportProvider -> one module .jit.cpp, 2 functions
ASStaticJITAotFixture        -> one module .jit.cpp, 44 functions
```

The intervening build found the already-generated sources current, and Verify
recomputed byte-identical output before running the full AOT matrix:

```text
Saved/Build/staticjit-testjit-workflow_03_generated_rebuild/
  20260813_045114_515_7a0e0cc6
Result: Succeeded; target up to date because Generate rewrote zero files

Saved/StaticJIT/TestJIT/Commandlet/staticjit-testjit-workflow_01_verify/
  20260813_045122_966_eb92a943/Commandlet.log
Verify: Success - 0 errors

Saved/Tests/staticjit-testjit-workflow_02_tests/
  20260813_045247_211_6786e74d/Report
Provider routing: verified=46 exact=46 native=46 vm=0 references=37/37
Totals: total=18 passed=18 failed=0 skipped=0
```

Adjacent final regressions:

```text
Saved/Tests/staticjit-testjit-uasfunction-final/
  20260813_050109_647_efd9fdee/Report
Totals: total=3 passed=3 failed=0 skipped=0

Saved/Tests/staticjit-testjit-cache-isolation-final/
  20260813_050203_101_ea3be95c/Report
Totals: total=3 passed=3 failed=0 skipped=0

Saved/Tests/staticjit-testjit-ownership-final-green/
  20260813_050355_457_800cff90/Report
Totals: total=7 passed=7 failed=0 skipped=0
```

One orchestration observation is intentionally not counted as test evidence:
parallel calls to the repository runner are rejected by its worktree lock, but
that early rejection currently returns process exit code zero after printing
an error. The affected prefixes were rerun sequentially and passed above. This
is an existing runner-boundary issue outside the StaticJIT change, so it was
recorded rather than expanded into an unrelated fix.
