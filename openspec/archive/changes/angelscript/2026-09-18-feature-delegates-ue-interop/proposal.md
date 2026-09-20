## Why

The replacement compiler needs delegate usage comparable to Unreal C++: the six `DECLARE_*` families, typed member/free-function binding, callbacks that retain explicit bind-time payloads after the creating function returns, multicast subscription handles, and explicit interoperability with native C++ and Blueprint delegates. The former AngelScript keywords `delegate` and `event` are removed; they are not aliases of the UE macros.

The preserved legacy implementation rewrites `delegate`/`event` into wrapper structs around UE dynamic delegates, reconstructs signatures from generated Execute/Broadcast methods, and binds UObject/function-name pairs. It is reference material, not a supported runtime to reactivate. Preprocessor `ProcessDelegates` must not keep doing that rewrite. The replacement frontend already owns callable declarations, canonical signatures, nominal identities and host descriptor projection. The 2026-09-18 ClassGen UCLASS/UFUNCTION `CompileModules` + ProcessEvent path is the host this Change consumes. The separately owned language-surface reduction removes every Lambda form. This feature does not restore anonymous functions.

The 2026-09-18 replan authorizes implementation of this Change. Task 1.1 still finishes remaining interface names and planning-validation before product nodes become Ready. Creation-only authorization is revoked.

## What Changes

### UE declaration forms over one callable model

Support the following six public UE macro families, each with zero through nine parameters, for 60 supported declaration spellings. This Change owns the full table, not a 0–1-parameter subset.

| Family | Signature arguments | Resulting semantics |
|---|---|---|
| `DECLARE_DELEGATE` | Name, parameter types | Ordinary single-cast, void return |
| `DECLARE_DELEGATE_RetVal` | Return type, name, parameter types | Ordinary single-cast with return |
| `DECLARE_MULTICAST_DELEGATE` | Name, parameter types | Ordinary multicast, void return |
| `DECLARE_DYNAMIC_DELEGATE` | Name, type/name parameter pairs | Reflected single-cast, void return |
| `DECLARE_DYNAMIC_DELEGATE_RetVal` | Return type, name, type/name parameter pairs | Reflected single-cast with return |
| `DECLARE_DYNAMIC_MULTICAST_DELEGATE` | Name, type/name parameter pairs | Reflected multicast, void return |

Use a finite declaration-form table and the existing type parser. Treat these spellings as built-in declarations recognized in declaration contexts after conditional preprocessing. Preserve original tokens and source ranges; do not expand UE C++ headers, synthesize wrapper source, or introduce a second semantic parser in the preprocessor. These 60 spellings are the language declaration surface, not a claim of full C++ preprocessing or type-system compatibility.

`delegate` and `event` used as callable introducers receive a removed-syntax diagnostic and do not publish a callable type. Lexer keeps dedicated tokens only for that transitional diagnostic. Deleting `KwDelegate` / `KwEvent` is a later Change.

Preserve unnamed parameters for ordinary forms and authored parameter names for dynamic forms. Validate suffix arity, required names, invalid combinations, declaration scope, and recovery to subsequent declarations. Type arguments use supported AngelScript type syntax. Parsing nested generic types directly, including their internal commas, is a deliberate built-in-syntax convenience rather than C++ textual macro compatibility. Arbitrary C++ pointer/declarator syntax is not added implicitly.

Keep single/multicast classification separate from reflection eligibility and authored declaration form. Preserve the existing distinction between nominal delegate identity and canonical signature identity. Equivalent declaration entrances for the same language declaration have the same identity; separately named delegates do not become interchangeable merely because UE native macros happen to create C++ typedefs.

The inspected UE core headers also contain Event, Derived Event, TS multicast and Sparse multicast forms: 31 further spellings. Recognize these known deferred families sufficiently to emit a specific unsupported-feature diagnostic and recover; do not silently erase their owner, inheritance, thread-policy or sparse-storage meaning. Implementing those semantics is outside this Change.

### Typed named callables and explicit payloads

Provide typed references to named free functions and members, including C++-style `&Type::Method` syntax, and Bind/Create entry points for static functions and object receivers. Resolve overloads, access, receiver compatibility, constness, passing modes and returns at compilation. A script member reference denotes a script callable identity and dispatch contract, not the C++ member-pointer ABI. Preserve virtual dispatch. Native C++ functions are callable only through registered bindings.

Ordinary callbacks do not require UFUNCTION reflection. Keep direct invocation and explicit Execute operations consistent. Empty Execute fails deterministically; void callbacks provide ExecuteIfBound. Non-void callbacks require an explicit bound check rather than silently inventing a return value. Multicast signatures require void returns.

All Lambda forms, anonymous function conversion and lexical capture environments are excluded. There are no BindLambda/CreateLambda/AddLambda or weak-owner Lambda variants. Ordinary managed script receivers use their managed lifetime; UObject method bindings are weak and do not implicitly protect unrelated payload values.

Trailing bind-time payloads are explicit stored typed values appended after invocation-time arguments to a named function or member. Preserve bind-time value semantics, construction, copy, destruction and managed-reference ownership; reject stored references to local stack variables. Payload work stays on task 2.2.

### Multicast subscriptions and lifetime

Add/AddStatic/AddUObject-style operations return an opaque subscription handle. Remove(handle) removes that subscription; RemoveAll(receiver) acts only on bindings explicitly associated with that receiver; Clear removes all subscriptions. Keep Add and explicit deduplicating operations distinct because legacy AddUFunction used AddUnique.

Event instances own subscription identity domains. Copying an owning event creates an independent domain. A borrowed native-event view refers to the original UE event rather than copying its listener list.

Ordinary script multicast does not promise listener order. Task 2.1 proves Broadcast reaches added listeners. Task 2.3 owns the mutation/handle matrix.

### Two Unreal integration paths

| Path | Host responsibility | Boundary |
|---|---|---|
| Script-only ordinary DECLARE | Replacement callable and subscription runtime | No UDelegateFunction required |
| Ordinary C++ delegate boundary | Registered/generated adapters for exposed TDelegate/TMulticastDelegate signatures | Construct real compiled C++ delegate values; never reinterpret script storage |
| Dynamic reflected DECLARE | Materialize UDelegateFunction, parameter properties, FDelegateProperty or FMulticastInlineDelegateProperty, and receiver UFunctions | UE-compatible storage, flags, parameter layout, reflection and Blueprint behavior |

The replacement ClassGen host (`CompileModules` + descriptor consumer + ClassGen UserData) is available. Task 2.1 may execute dynamic flavors as script callables before 3.2 materializes `UDelegateFunction`. Tasks 3.2–4.1 remain in this Change.

### Intended usage

```cpp
DECLARE_DELEGATE_OneParam(FOnCompleted, int);
DECLARE_DELEGATE_RetVal_OneParam(int, FAddOne, int);
DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(
    FOnHealthChanged, float, OldValue, float, NewValue
);
```

`delegate int FTransform(int Value);` is rejected.

### Compatibility and non-goals

- Removed `delegate`/`event` introducers are not compatibility aliases. Legacy reflection intent uses explicit dynamic `DECLARE_*` forms.
- Keep ordinary and dynamic binding rules explicit.
- Exclude general C/C++ macro expansion, C++ header ingestion, arbitrary new C++ types at runtime, UDELEGATE syntax, TDelegate function-signature template syntax in scripts, operator-based subscription sugar, all Lambda/anonymous-function forms, lexical captures, stored stack-reference payloads, move-only callable families, network/RPC behavior, result aggregation and automatic payload-state serialization.
- Exclude functional support for DECLARE_EVENT, DECLARE_DERIVED_EVENT, TS multicast and Sparse multicast beyond their explicit diagnostics.
- Implement within Plugins/Angelscript. No engine-source patch. Tests live under `AngelscriptTest/NativeEngine/` with identities `Angelscript.UnitTest.NativeEngine.<Layer>.<Class>`. `NewVersion/` is not a source root.

## Capabilities

### New Capabilities

- `angelscript/runtime/delegates`: Executable typed callable values, receiver/payload ownership, multicast subscriptions, invalidation and teardown behavior.
- `angelscript/bindings/delegates`: Registered native C++ delegate adapters and dynamic UE/Blueprint materialization, invocation and loading contracts.

### Modified Capabilities

- `angelscript/language/frontend/lexing`: `delegate`/`event` tokens exist only to diagnose removal; `DECLARE_*` stay identifiers.
- `angelscript/language/frontend/declarations`: Built-in UE declaration forms, callable flavor, arity/name validation, void multicast constraints, and removed-keyword rejection.
- `angelscript/language/frontend/preprocessing`: No `ProcessDelegates` wrapper synthesis for leftover keywords or `DECLARE_*`.
- `angelscript/language/frontend/bodies`: Typed function/member references, callable operations and explicit named-target bind-time payloads.
- `angelscript/language/frontend/reflection-dependencies`: Flavor-aware resolved delegate descriptions and dependencies, while preserving the explicit host-materialization boundary.
- `angelscript/testing/language-fixtures`: Delegate/Event chapters admit `DECLARE_*` positives; keyword programs are CompileFail.

## Impact

### Ownership and related work

- Implementation: Plugins/Angelscript, principally frontend Parser/Sema/Lexer, preprocessor DetectClasses/ProcessDelegates, descriptor consumer, replacement execution, ClassGenerator, and required editor integration.
- New tests: `Plugins/Angelscript/Source/AngelscriptTest/NativeEngine/{Sema,Compile}/` with prefixes recorded in `design.md`.
- Keep Source/AngelscriptProject minimal. Legacy source is evidence, not an enabled test target.
- Consume `asCCallableType` / `CreateCallableType` / `CreateCallableSignature` from the archived language-surface Change. Consume `FAngelscriptEngine::CompileModules` from the archived UCLASS reload join. Do not fork a second VM.
- Language corpus execute is not this Change's proving command.

### Planned proof boundaries

1. Declaration-form table: all 60 supported spellings through one parser table and the 60-row matrix (1.2).
2. Diagnostics: removed `delegate`/`event`, unsupported families, multicast RetVal rejection (1.5).
3. Preprocess: no wrapper synthesis for `DECLARE_*` or leftover keywords (1.6).
4. Register: definition-graph callable type plus Flavor-aware `FAngelscriptDelegateDesc` (1.7).
5. Callable execution: Bind/Execute/Broadcast for ordinary and dynamic flavors through `CompileModules`; empty invocation; no keyword admission.
6. Explicit payloads (2.2) and multicast mutation (2.3).
7. Native C++ adapters (3.1).
8. `UDelegateFunction` materialization (3.2), Blueprint/script dynamic invocation (3.3), editor/cooked lifecycle (4.1).

Use grouped observed RED/GREEN. Start with NativeEngine Sema/Compile selections. No unconditional full suite.
