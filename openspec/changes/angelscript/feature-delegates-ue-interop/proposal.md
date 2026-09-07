## Why

The replacement compiler needs delegate usage comparable to Unreal C++: typed member/free-function binding, callbacks that retain explicit bind-time payloads after the creating function returns, multicast subscription handles, and explicit interoperability with native C++ and Blueprint delegates. Recognizing `delegate` and `event` alone does not provide those execution and lifetime contracts.

The preserved legacy implementation rewrites declarations into wrapper structs around UE dynamic delegates, reconstructs signatures from generated Execute/Broadcast methods, and binds UObject/function-name pairs. It is reference material, not a supported runtime to reactivate. The replacement frontend already owns callable declarations, canonical signatures, nominal identities, delegate invocation semantics and host descriptor projection. The separately owned language-surface reduction removes every Lambda form and migrates old funcdef SDK consumers to structured callable metadata. This feature consumes that resulting interface and does not restore anonymous functions.

The user requested creation of a Change to record the explored feature. This delivery creates the record, proposal, required task record, and indexed source evidence only. It does not authorize implementation, UE execution, engine modification, specification synchronization, archive, commits, or publication. The task graph begins with explicit design/specification completion; product nodes cannot become Ready until that planning outcome is complete. This feature record is not a claim that implementation-ready planning has finished.

## What Changes

### UE declaration forms over one callable model

Support the following six public UE macro families, each with zero through nine parameters, for 60 supported declaration spellings:

| Family | Signature arguments | Resulting semantics |
|---|---|---|
| `DECLARE_DELEGATE` | Name, parameter types | Ordinary single-cast, void return |
| `DECLARE_DELEGATE_RetVal` | Return type, name, parameter types | Ordinary single-cast with return |
| `DECLARE_MULTICAST_DELEGATE` | Name, parameter types | Ordinary multicast, void return |
| `DECLARE_DYNAMIC_DELEGATE` | Name, type/name parameter pairs | Reflected single-cast, void return |
| `DECLARE_DYNAMIC_DELEGATE_RetVal` | Return type, name, type/name parameter pairs | Reflected single-cast with return |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE` | Name, type/name parameter pairs | Reflected multicast, void return |

Use a finite declaration-form table and the existing type parser. Treat these spellings as built-in declarations recognized in declaration contexts after conditional preprocessing. Preserve original tokens and source ranges; do not expand UE C++ headers, synthesize wrapper source, or introduce a second semantic parser in the preprocessor. Raw `delegate` and `event` remain supported and converge on the same callable construction and validation paths. These 60 spellings are aliases of language declarations, not a claim of full C++ preprocessing or type-system compatibility.

Preserve unnamed parameters for ordinary forms and authored parameter names for dynamic forms. Validate suffix arity, required names, invalid combinations, declaration scope, and recovery to subsequent declarations. Type arguments use supported AngelScript type syntax. Parsing nested generic types directly, including their internal commas, is a deliberate built-in-syntax convenience rather than C++ textual macro compatibility. Arbitrary C++ pointer/declarator syntax is not added implicitly.

Keep single/multicast classification separate from reflection eligibility and authored declaration form. Preserve the existing distinction between nominal delegate identity and canonical signature identity. Equivalent declaration entrances for the same language declaration have the same identity; separately named delegates do not become interchangeable merely because UE native macros happen to create C++ typedefs. Additional semantic flags must participate in applicable compatibility witnesses and versioned metadata/AST representations.

The inspected UE core headers also contain Event, Derived Event, TS multicast and Sparse multicast forms: 31 further spellings. Recognize these known deferred families sufficiently to emit a specific unsupported-feature diagnostic and recover; do not silently erase their owner, inheritance, thread-policy or sparse-storage meaning. Implementing those semantics is outside this Change.

### Typed named callables and explicit payloads

Provide typed references to named free functions and members, including C++-style `&Type::Method` syntax, and Bind/Create entry points for static functions and object receivers. Resolve overloads, access, receiver compatibility, constness, passing modes and returns at compilation. A script member reference denotes a script callable identity and dispatch contract, not the C++ member-pointer ABI. Preserve virtual dispatch. Native C++ functions are callable only through registered bindings.

Ordinary callbacks do not require UFUNCTION reflection. Keep direct invocation and explicit Execute operations consistent. Empty Execute fails deterministically; void callbacks provide ExecuteIfBound. Non-void callbacks require an explicit bound check rather than silently inventing a return value. Multicast signatures require void returns; migrate the existing event-int identity fixture to a valid identity control plus a rejection case.

All Lambda forms, anonymous function conversion and lexical capture environments are excluded. There are no BindLambda/CreateLambda/AddLambda or weak-owner Lambda variants. Ordinary managed script receivers use their managed lifetime; UObject method bindings are weak and do not implicitly protect unrelated payload values.

Trailing bind-time payloads are explicit stored typed values appended after invocation-time arguments to a named function or member. Preserve bind-time value semantics, construction, copy, destruction and managed-reference ownership; reject stored references to local stack variables. A managed handle payload retains that handle's reference relation rather than deep-copying its object. Payload storage uses the callable's explicit binding state, not an anonymous-function AST or a revived boxed-payload wrapper. Storage optimization is deferred until measured.

### Multicast subscriptions and lifetime

Add/AddStatic/AddUObject-style operations return an opaque subscription handle. Remove(handle) removes that subscription; RemoveAll(receiver) acts only on bindings explicitly associated with that receiver; Clear removes all subscriptions. Keep Add and explicit deduplicating operations distinct because legacy AddUFunction used AddUnique. Deduplicate only through explicit supported target/receiver identity; do not infer binding equality by comparing payload memory.

Event instances own subscription identity domains. Copying an owning event creates an independent domain, and a handle from the source cannot remove a subscription in the copy. A borrowed native-event view refers to the original UE event rather than copying its listener list. The bridge retains the native handle and origin needed for removal.

Ordinary script multicast does not promise listener order. New listeners are deferred until a subsequent broadcast; removed listeners not yet invoked are skipped; nested broadcast takes its own current membership snapshot. Script callback failure stops that script broadcast and unwinds invocation resources. Native-event views retain their host's documented iteration behavior rather than claiming to impose script-container semantics on UE internals.

Callbacks must retain valid execution ownership and code-generation information. Stable identity alone does not establish executable compatibility. After code retirement, reject stale entry; compatible rebinding requires signature and payload-layout checks. Automatic migration of changed bound payload layouts is excluded. Handle removal and destruction remain safe after receiver invalidation or runtime teardown.

### Two Unreal integration paths

| Path | Host responsibility | Boundary |
|---|---|---|
| Script-only ordinary delegate/event | Replacement callable and subscription runtime | No UDelegateFunction required |
| Ordinary C++ delegate boundary | Registered/generated adapters for exposed TDelegate/TMulticastDelegate signatures | Construct real compiled C++ delegate values; never reinterpret script storage |
| Dynamic reflected delegate/event | Materialize UDelegateFunction, parameter properties, FDelegateProperty or FMulticastInlineDelegateProperty, and receiver UFunctions | UE-compatible storage, flags, parameter layout, reflection and Blueprint behavior |

For native single-cast inputs, create a native callable that owns a script callback reference and enters the replacement executor through typed parameter/return adaptation. For native multicast members, subscribe to the real event and keep its FDelegateHandle. Native templates and adapters must exist at C++ build time; runtime script declarations do not create new types visible to already compiled C++ or automatically expose unregistered native APIs.

For dynamic declarations, extend the existing AST-to-host descriptor projection and materialize reflection objects explicitly after signature resolution. Do not reconstruct signatures from wrapper methods or materialize UObject pointers during parsing/Sema. Complete signature/property layout and class registration before public visibility. Script handlers eligible for dynamic binding receive a UFunction invocation bridge into the new executor; script Broadcast uses the real dynamic delegate storage. Typed BindDynamic/AddDynamic expressions validate UFUNCTION eligibility and produce the required reflection target identity.

BlueprintAssignable members require a dynamic multicast declaration. Ordinary callbacks with explicit payloads are not implicitly serializable Blueprint delegates. The dynamic DECLARE forms provide the explicit reflection selection in this Change; adding UDELEGATE annotation syntax can be a later extension and is not a prerequisite.

Load script reflection definitions before dependent Blueprint assets need them in editor and cooked startup. Reflection replacement must update affected Blueprint/type references using valid host lifecycle operations. Delegate work consumes the replacement class/function host lifecycle; it does not authorize wholesale restoration of the dormant integration. If that host lifecycle is unavailable when implementation is planned, represent its required bounded prerequisite explicitly rather than disguising it as a parser task.

### Intended usage

The following is target syntax, not a claim of current executable support:

```cpp
DECLARE_DELEGATE_OneParam(FOnCompleted, int);

FOnCompleted Callback = FOnCompleted::CreateUObject(
    Owner, &ARequestOwner::HandleCompleted, RequestId
);
// Handler signature: void HandleCompleted(int Result, int RequestId)
Callback.Execute(200);

delegate int FTransform(int Value);
int AddOffset(int Value, int Offset)
{
    return Value + Offset;
}
FTransform MakeTransform(int Offset)
{
    return FTransform::CreateStatic(AddOffset, Offset);
}
// MakeTransform(10).Execute(5) invokes named AddOffset(5, 10).

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(
    FOnHealthChanged, float, OldValue, float, NewValue
);
// A reflected class may expose FOnHealthChanged through a
// UPROPERTY(BlueprintAssignable) member after host materialization.
```

### Compatibility and non-goals

- Raw delegate/event declarations use the ordinary callable model in the proposed replacement language. Legacy declarations intended for reflection migrate to explicit dynamic forms; do not infer reflection from use sites or silently project an ordinary payload-bearing callback into a dynamic delegate. This is an intentional legacy compatibility change, not a legacy-runtime restoration switch.
- Keep ordinary and dynamic binding rules explicit. String-based reflection lookup is not the primary typed binding mechanism and does not gain compile-time guarantees by renaming its API.
- Exclude general C/C++ macro expansion, C++ header ingestion, arbitrary new C++ types at runtime, UDELEGATE syntax, TDelegate function-signature template syntax in scripts, operator-based subscription sugar, all Lambda/anonymous-function forms, lexical captures, stored stack-reference payloads, move-only callable families, network/RPC behavior, result aggregation and automatic payload-state serialization.
- Exclude functional support for DECLARE_EVENT, DECLARE_DERIVED_EVENT, TS multicast and Sparse multicast beyond their explicit diagnostics. In particular do not claim owner-only publication from UE's DECLARE_EVENT spelling.
- Implement within Plugins/Angelscript first. No engine-source patch, host-project behavior, unrelated Skill change, external editor extension change or JIT backend is included by default. A demonstrated missing host/engine extension point requires a bounded follow-up or evidence-gated plan update.

## Capabilities

### New Capabilities

- `angelscript/runtime/delegates`: Executable typed callable values, receiver/payload ownership, multicast subscriptions, invalidation and teardown behavior.
- `angelscript/bindings/delegates`: Registered native C++ delegate adapters and dynamic UE/Blueprint materialization, invocation and loading contracts.

### Modified Capabilities

- `angelscript/language/frontend/declarations`: Built-in UE declaration forms, callable flavor, arity/name validation and void multicast constraints.
- `angelscript/language/frontend/bodies`: Typed function/member references, callable operations and explicit named-target bind-time payloads.
- `angelscript/language/frontend/reflection-dependencies`: Flavor-aware resolved delegate descriptions and dependencies, while preserving the explicit host-materialization boundary.

The preprocessing contract remains intact. Later deltas should amend lexing, AST codec or definition/identity capabilities only where the actual authored behavior or shared contract requires it, rather than listing every touched implementation file as a capability.

## Impact

### Ownership and related work

- Current delivery: parent repository OpenSpec record and attachments only, written in English.
- Future implementation: Plugins/Angelscript submodule, principally ThirdParty/angelscript/source/frontend, replacement execution/metadata owners, Binds, ClassGenerator and the required editor integration; new tests remain under Source/AngelscriptTest/NewVersion with public Angelscript.UnitTest identities.
- Keep Source/AngelscriptProject minimal and all unrelated dirty work intact. Legacy source is evidence, not an enabled test or implementation target.
- Consume execution, metadata compatibility and generation-lifetime services owned by `angelscript/refactor-vm-symbolic-execution`. That Change already covers base delegate/VM ownership and indirect execution; this Change owns the added declaration forms, explicit named-target payload runtime behavior, multicast API and UE adapters. Do not fork a second VM, cache format or stable-key authority. Its planned services are not assumed implemented. Consume `angelscript/refactor-language-surface-ue-focused` task 2.1 structured callable metadata; the public interface is `asCCallableType`, `CreateCallableType` and retained `CreateCallableSignature`, not funcdef registration. Task 1.1 must confirm that interface and its proof before any delegate product task becomes executable.
- Coordinate frontend interface/diagnostic changes with `angelscript/feature-frontend-diagnostics-tooling`; preserve source ranges and precise failures without making the entire diagnostics or unified-testing-framework Change an unconditional prerequisite. Existing replacement CQTest remains usable.

### Planned proof boundaries

The following acceptance groups are mapped to the required tasks.md. Task 1.1 must finalize their design/specification and prerequisite contracts before any product node enters Ready execution. This list is acceptance intent, not a second Task DAG:

1. Declaration semantics: cover all 60 supported spellings; zero/one/nine-parameter boundaries; typed/raw declaration equivalence; dynamic names; nested types; forward references; namespace/class placement; invalid arity and unsupported families; inactive branches; recovery and source-accurate diagnostics.
2. Callable execution: execute free/member/virtual calls and a returned named-target callback with explicit payload after its creator exits; prove payload argument ordering, payload destruction, weak receiver invalidation, empty invocation and stale-generation rejection with independent values and lifetime counters.
3. Multicast execution: prove precise handle removal, duplicate versus unique behavior, copy domains, weak listeners, mutation/nesting, failure cleanup and teardown-safe removal. AST acceptance alone is insufficient.
4. Native C++ integration: pass a retained named-target script callback with explicit payload to a real registered C++ delegate API, obtain the expected return/output values, and subscribe/remove on the original native multicast instance. Prove type mismatch rejection before callback entry.
5. Dynamic/Blueprint integration: materialize a script dynamic event, bind a real Blueprint listener and verify its received values; invoke a script UFUNCTION handler through a real UE dynamic delegate; verify reflected storage lifetime, asset-loading order and replacement/invalidation. These cases require actual host execution rather than fabricated descriptors.

Use grouped observed RED/GREEN when implementation is authorized. Start with the smallest owner suite, build changed C++ before its execution proof, and expand only for demonstrated shared-contract or host integration impact. Do not enable dormant startup merely to satisfy a test. No UE build, Automation execution, benchmark or implementation verification occurred during this record creation.

Source evidence and the exact UE macro inventory are indexed in `attachments/INDEX.md`. The next planning artifact should be design, followed by durable behavior deltas and an executable task plan before implementation.
