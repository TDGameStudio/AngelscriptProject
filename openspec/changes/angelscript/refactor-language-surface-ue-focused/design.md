## Context

The source frontend already diagnoses virtual properties and the `property` decorator. It also constructs Lambda AST and definition objects, while runtime delegate/event signatures still use `asCFuncdefType`. Standalone add-on packages have explicit CMake, stdlib, runner and test consumers, despite the standalone fork source list already referring to obsolete paths. See the indexed surface inventory for current evidence rather than treating every removal as an implemented feature.

## Goals / Non-Goals

Make the accepted language boundary permanent in source, metadata and SDK APIs. Preserve ordinary named-call execution, UE host parameterized types, explicit callable metadata, external definitions and runtime safety. This is creation-only planning; implementing all language/library features that remain allowed is not required. In particular, host container permission does not claim a currently complete TArray runtime adapter.

No new module scheduler, delegate interop, container implementation, standalone port, VM verifier repair or host startup restoration is included. UE delegate payload work remains in its existing Change. Historical VM reports are retained; API-dependent fixtures are migrated without weakening their value/lifetime/compatibility assertions.

## Decisions

### 1. Reject syntax at its owning boundary

Use the maintained Parser/Sema and diagnostic engine. Add a small source-policy classification shared by declaration/body entry points: `asERemovedLanguageFeature` with ModuleSharing, FuncdefDeclaration, AnonymousFunction, ScriptException, ScriptCoroutine, UserTemplate and VirtualProperty. Add one reporting helper on Sema, `DiagnoseRemovedFeature(asERemovedLanguageFeature, asCSourceRange)`, carrying the feature name through existing structured diagnostics and returning recovery through the existing Parser/Sema mechanisms. Use a newly allocated nonconflicting diagnostic ID in the existing producer range; do not introduce a parallel diagnostic catalog. Existing virtual-property diagnostics may delegate to this helper.

Recognize prohibited constructs in grammar context: shared/external before class/interface/function declarations, funcdef declarations, `function(...)` anonymous expressions and capture-list anonymous forms, try/catch/throw statements, coroutine/yield statement forms, template declarations/specializations and virtual-property blocks/decorators. Do not reserve ordinary method names `get`, `set`, `GetValue`, `SetValue` or globally reject identifiers named shared/external. Return a precise error rather than silently dropping the construct. Existing recovery must reach subsequent valid declarations. Skipped conditional input is not parsed. No runtime option restores syntax.

The source-policy helper is a planned new interface, not a claim that current input has typed policy diagnostics. Current rejecting behavior is baseline GREEN; new diagnostics/recovery and accepted Lambda rejection are separate missing outcomes. Script library coroutine entry points are removed with their registrations; no global blacklist of user function names is introduced.

### 2. Remove Lambda products and preserve callable signatures

Delete anonymous-function parsing, Sema entry points, Lambda-only AST classes, visitors/projections/codecs, origin assignment and executable lowering. Remove `SetLambdaOrigin` and active Lambda identity construction. Named-function/member references and delegate/event declarations remain distinct retained concepts; any shared body analysis utility is kept without a Lambda-specific public facade.

The public and maintained internal target vocabulary is:

| Existing interface/concept | Target |
|---|---|
| `asCFuncdefType` / `CastToFuncdefType` | `asCCallableType` / `CastToCallableType` |
| `asCDataType::IsFuncdef()` | `IsCallableType()` |
| `asCMetadataImage::CreateFuncdefType` | `CreateCallableType`, same structured key/name/namespace/signature/output contract, output type `asCCallableType*&` |
| `GetFuncdefSignature` | `GetCallableSignature` |
| `GetChildFuncdefCount/GetChildFuncdef` | `GetChildCallableTypeCount/GetChildCallableType` |
| `AddChildFuncdef` | `AddChildCallableType` |
| `RegisterFuncdef(const char*)`, Engine funcdef enumeration | Remove; define through MetadataImage, query its structured types, and register through `RegisterMetadataImage` |
| `CreateCallableSignature` | Keep as the structural signature authority |

Rename dedicated funcdef fields, enum labels and source files to Callable/CallableSignature roles consistently, without old-name aliases. A nominal callable may describe a named host callback, delegate or event; it does not grant source funcdef or Lambda syntax. Preserve the distinction between nominal callable type identity and structural signature identity. Existing signatures, native ABI tests, indirect-call instructions, receiver leases and GC relations retain their behavior.

Retain semantic stable-key bytes for equivalent retained callable contracts. Do not renumber persisted enum positions through deletion: keep retired wire ordinals explicitly reserved and reject them. Removing Lambda AST/identity admission is incompatible, so advance each affected format's explicit version and reject its prior version rather than reinterpret removed nodes. A C++ spelling-only change to retained callable metadata does not require changing bytecode instruction ordinals or inventing another cache format. Rebuild C++ consumers; binary ABI compatibility is not promised.

### 3. Engine-owned module membership and host generics

Keep `asSSemanticSourceInput.LogicalSourceKey`, `asSBuilderOptions.Dependencies`, `AddExternalDefinitions`, MetadataImage dependencies, Engine registration and generation-owned executable links. They represent source membership, frozen provider definitions and runtime ownership without source shared/external declarations.

Remove shared declaration flags and their getters/setters, shared-owner reassignment/duplicate-sharing policy, string-driven funcdef registration and accessor-mode configuration. Strip obsolete declaration import/module compilation management from the public SDK where it exists; retained metadata provenance queries must not expose a mutable legacy module object. Use stable source/module identities and definition ownership already present instead. Do not delete `asCModule` merely because it is named Module if still needed by dormant compile boundaries; leave such compatibility types behind the existing source-isolation boundary rather than on the replacement public surface.

Host parameterized type declarations and explicit host type arguments remain structured. Validate registered provider, arity and argument kinds; reject user type/function template definitions. Preserve nesting, type identities, generic arguments in fingerprints and established Cast<T> intrinsic semantics. Preserve `asIScriptGeneric`, native calling conventions, host registration callbacks, C++ templates, shared locks and `external_implicit_this`. No generic runtime or binding implementation is added merely to demonstrate a retained permission; current registered-type fixtures provide the control.

### 4. Runtime faults and host control remain independent

Reject source exception handling and coroutine syntax/library services. Preserve runtime error status, native failure translation, source/call information, unwind, destructor/handle cleanup, stack limits, Context suspend/resume/abort, line callbacks and shutdown. Host callbacks may still suspend or fail execution. Tests explicitly exercise these through the current SDK without introducing script try/catch/yield. Do not change C++ exception compilation switches based on this source policy.

### 5. Accessor metadata is rejected, not ignored

Remove source virtual-property and implicit get_/set_ accessor interpretation plus accessor-mode SDK configuration. A function whose name is `get_Value` is still callable as a normal function but does not synthesize `Value` property syntax.

At attribute semantic validation, reject AS-authored BlueprintGetter/BlueprintSetter on UPROPERTY/UFUNCTION, including nested UMETA/meta entries and qualified source locations. No resolved descriptor may carry these special authoring requests. Remove their dedicated descriptor flags, old preprocessor production, ClassGenerator interpretation and validation callbacks from maintained/compiled consumers. Ordinary metadata, UPROPERTY BlueprintReadWrite/BlueprintReadOnly, ordinary getter/setter methods and reflected named functions remain available. The UE engine's own native reflection features and existing native declarations are not altered.

### 6. Add-on removal is a bounded dependency-chain cleanup

Delete `Standalone/ThirdParty/AngelScriptAddons/{scriptarray,scriptdictionary,scriptmath,scriptstdstring}` and the add-on target/include/link list. Delete exclusive Addons tests; remove add-on-dependent subcases from mixed test files, registrations from StdLib, direct CScriptArray/stdstring use in runner paths and the hard-coded add-on cache identity. Remove obsolete documentation/fixtures that assert these packages ship. Mixed host/runner functions whose entire purpose requires a removed package are removed with callers or return an explicit unsupported-library result at their existing CLI boundary; never substitute unrelated UE containers or create replacement stdlibs.

Retain Standalone itself and unrelated CLI/adapter content. Its obsolete maintained-fork CMake source list is documented preexisting debt, not repaired by this Change. A scoped static dependency audit proves no remaining nonhistorical include/link/register/package references to the removed add-ons; it does not claim standalone execution success. Treat the active UE build as the product build gate.

### 7. Cross-change ownership and implementation order

The local DAG serializes frontend/shared SDK edits. The delegate Change's task 1.1 consumes this design and must confirm task 2.1's callable metadata proof before allowing its product tasks to execute; local Task DAGs do not accept foreign IDs. This dependency does not require this Change to implement the delegate feature. Existing delegate task 2.2 retains its ID but now owns explicit bound receiver/payload state, with named function `AddOffset(Value, Offset)` and stored Offset as the replacement for MakeTransform Lambda examples.

Keep delegate native/dynamic forms, subscription handles and weak UObject member bindings. Remove BindLambda/CreateLambda/AddLambda and weak-owner Lambda plans. Payloads are explicit values passed to named functions/members, not lexical captures. The existing delegate design/spec prerequisite remains pending; this alignment does not pretend to complete unrelated Blueprint/cooked-host design.

## Compatibility and failure handling

This is a source/SDK break during reconstruction: no migration shim, opt-in switch or silent metadata omission. For authored unsupported input, report a source diagnostic and withhold publishable output. For incompatible persisted semantic input, reject version/retired kind before constructing a valid graph. For signature/registration migration, preserve current transactional failure and reference ownership. A failed candidate must not replace installed executable code.

Do not erase dormant historical evidence to make token scans pass. The source audit uses explicit path/role exclusions and asserts deleted identifiers in the maintained public/compiled surface, rather than searching for the English words globally. Findings that require new unrelated behavior trigger a bounded plan update rather than broad deletion.

## Verification

Prepare related negative, positive and boundary cases together; preserve already-passing rejection controls as baseline GREEN. Use the exact public prefixes in tasks.md through Harness and current replacement CQTest. Absent renamed API seams may be minimally compile-enabled for behavioral RED; compile errors are not proof. Static API absence and add-on-reference checks complement behavioral proof, not replace it.

The final NativeEngine regression is justified by shared AST, identity, metadata, ABI, GC, Context and cache consumers; separate Baseline checks prove startup dormancy. No JIT, full UE suite, standalone execution or performance claim follows. Record exact source/binary identity and actual discovered cases, without comparing aggregate counts to the old Lambda-enabled corpus as if every retired case were a regression.
