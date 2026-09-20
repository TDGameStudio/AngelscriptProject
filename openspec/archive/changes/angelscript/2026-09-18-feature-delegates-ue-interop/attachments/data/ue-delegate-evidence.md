# UE delegate inventory and integration evidence

## Provenance and limits

Inspected during the exploration and Change creation on 2026-09-06 in the selected AngelscriptProject workspace. Parent HEAD: `d8343d314f0b948a43a323fc443cf305ff2f5dc3`. Plugin HEAD: `1fd9301891914240f9c550448336843b150af3f6`. The workspace contains unrelated changes; these commits are context, not a claim that every inspected working file is an immutable clean snapshot.

The configured installed engine reports UE 5.8.0, changelist 55116800, branch `++UE5+Release-5.8`. Engine paths below are relative to the configured EngineRoot. No external repository update or engine build occurred. Re-read implementation anchors before applying because concurrent VM/frontend reconstruction may change them.

Knot's UE5-main knowledge base was queried for TDelegate/TMulticastDelegate binding, AddWeakLambda, handles and dynamic payloads. Retrieved application examples include UAudioPropertiesSheetAsset::BindPropertiesCopyToSheetChanges (weak-owner lambda), FOnlineEventDelegateHandle (native handle removal through a weak event reference), and native TDelegate-based API signatures. These are branch-specific examples, not proof of installed-engine behavior. Counts and version-sensitive conclusions below were checked against local 5.8 headers.

## Public declaration inventory

Count method: enumerate `#define DECLARE_...` delegate/event names in the three owning headers, extract complete names, and group by removing only the OneParam through NineParams suffix. Internal macros, binding helpers, module-specific wrappers and arbitrary engine headers are outside this inventory.

| Header | Public names | SHA-256 |
|---|---:|---|
| Engine/Source/Runtime/Core/Public/Delegates/DelegateCombinations.h | 80 | `46d74e82e9514e01465dcc9fd994c6874bcce8d22f8acc2dcb609d7ea350fa9d` |
| Engine/Source/Runtime/Core/Public/Delegates/Delegate.h | 1 | `ba904a3d3761eff0e3a82365db4561bf4d9dd94e80f5e2d4f5512080516877a8` |
| Engine/Source/Runtime/CoreUObject/Public/UObject/SparseDelegate.h | 10 | `97218e27b61e1075360c1a86a2f2ca42a48d7cac75efdce43ebce891501a6804` |

The first header has eight families with ten arities each: DECLARE_DELEGATE, DECLARE_DELEGATE_RetVal, DECLARE_MULTICAST_DELEGATE, DECLARE_TS_MULTICAST_DELEGATE, DECLARE_EVENT, DECLARE_DYNAMIC_DELEGATE, DECLARE_DYNAMIC_DELEGATE_RetVal and DECLARE_DYNAMIC_MULTICAST_DELEGATE. Delegate.h adds DECLARE_DERIVED_EVENT; SparseDelegate.h adds ten DECLARE_DYNAMIC_MULTICAST_SPARSE_DELEGATE forms. Total: 91 spellings. The selected six ordinary/dynamic families account for 60; deferred Event/TS/Sparse/Derived forms account for 31.

| Shape | Fixed prefix arguments | Per-parameter arguments |
|---|---|---|
| Ordinary void | Type name | Type |
| Ordinary return | Return type, type name | Type |
| Dynamic void | Type name | Type, parameter name |
| Dynamic return | Return type, type name | Type, parameter name |
| Event | Owner type, event type name | Type |
| Sparse dynamic multicast | Delegate type name, owner class, owner member name | Type, parameter name |
| Derived event | Owner type, base event type, new event type | Inherited signature |

The supported suffix sequence is no suffix, OneParam, TwoParams, ThreeParams, FourParams, FiveParams, SixParams, SevenParams, EightParams, NineParams. No multicast return-value family appears in this inventory. Use source definitions over stale prose about an eight-parameter maximum.

## Version-sensitive UE observations

- `Delegate.h:221` expands the Event form to a class deriving from TMulticastDelegate without owner-only publication enforcement. The comment and `DelegateCombinations.h:30` discourage this form for new delegates. `DECLARE_DERIVED_EVENT` has an actual base-type relationship; it cannot be modeled by discarding its base argument.
- Ordinary delegate declarations are native TDelegate aliases. The script frontend has nominal delegate identities, so adopting the spelling does not automatically adopt C++ alias identity semantics.
- `DelegateSignatureImpl.inl:853` and `:1020` expose AddWeakLambda/AddUObject returning native FDelegateHandle values. Dynamic binding checks member signatures but uses reflection function identity for invocation; `:1237` is a relevant typed helper anchor.
- `Core/Public/UObject/ScriptDelegates.h:25` defaults UE_USE_DYNAMIC_DELEGATE_PAYLOADS to zero unless externally defined. `DelegateSignatureImpl.inl:1205` contains a gated dynamic payload path. This proves conditional implementation and a header default, not the effective flags of every possible build. Do not state that dynamic payloads can never exist or assume they are enabled.

## Project source observations

All project paths below are relative to Plugins/Angelscript/Source unless prefixed with openspec.

| Evidence | Observation | Application boundary |
|---|---|---|
| AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:1167 | ProcessDelegates generates script structs with inner dynamic-delegate storage and Execute/Broadcast helpers. | Dormant legacy mechanism; do not restore it. |
| AngelscriptRuntime/Binds/Bind_Delegates.cpp:370, :524 | Reflection binding finds UFunctions and checks compatibility; multicast AddUFunction uses AddUnique. | Migration must distinguish Add from deduplication. |
| AngelscriptRuntime/Core/AngelscriptDelegateWithPayload.h:14 | A separate wrapper retains weak UObject, function name and boxed payload. | Evidence of payload demand, not the replacement closure representation. |
| AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_decl.h:464 | Callable nodes carry signature, parameters and nominal identity; Event identifies multicast. | Extend shared semantic flavor, not one AST node per macro name. |
| AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp:700 | ParseCallableDeclaration accepts optional parameter names and calls ActOnCallableType. | Reuse type parsing and Sema construction for built-in forms. |
| AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema_lambda.cpp:229 | Capturing lambda conversion into stored delegates fails with capturing-lambda-cannot-escape. | Owned escaping closures need implementation, not merely new syntax. |
| AngelscriptTest/NewVersion/NativeEngine/Bodies/BodyLambdaTests.cpp:28, :56 | Noncapturing contextual conversion is tested; stored capturing conversion is rejected. | These are semantic fixtures, not runtime execution proof. |
| AngelscriptTest/NewVersion/NativeEngine/Bodies/BodySemanticTests.cpp:884 | Delegate variable calls use canonical signatures without an Engine. | Existing direct-call frontend foundation. |
| AngelscriptTest/NewVersion/NativeEngine/Declarations/DeclarationSemanticTests.cpp:724 | Identity fixture resolves an event with int return. | Add void-only multicast validation and preserve the identity control using valid declarations. |
| AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_descriptor_consumer.cpp:223 | Callable AST projects into FAngelscriptDelegateDesc with semantic identities and signatures. | Use as the host handoff; it does not prove UE objects are materialized. |
| AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp:234 | Legacy host creates UDelegateFunction signature objects. | Reference for explicit new host materialization and replacement. |
| AngelscriptRuntime/Binds/Bind_Delegates_Type.cpp:107, :380, :715 | Legacy type adapters create single, inline multicast and sparse reflection properties. | Property construction alone does not establish layout, owner registration, lifecycle or callable execution. |

Current durable contracts reinforce these boundaries: `openspec/specs/angelscript/language/frontend/preprocessing/spec.md:122` leaves declarations to Parser/Sema; `lexing/spec.md:81` excludes implicit UDELEGATE support; `reflection-dependencies/spec.md:133` keeps host descriptions separate from reflection object materialization.

## External primary references

- [Epic delegates and lambda functions](https://dev.epicgames.com/documentation/en-us/unreal-engine/delegates-and-lambda-functions-in-unreal-engine): native binding families and payload usage; version-sensitive limits still require local source checks.
- [Epic dynamic delegates](https://dev.epicgames.com/documentation/en-us/unreal-engine/dynamic-delegates-in-unreal-engine): reflection/serialization purpose and BindDynamic/AddDynamic helpers.
- [Epic multicast delegates](https://dev.epicgames.com/documentation/en-us/unreal-engine/multicast-delegates-in-unreal-engine): void return, handle-oriented operations and unspecified listener ordering. This reference is not authority for a new script container's mutation semantics.
- [Epic FMulticastDelegateProperty](https://dev.epicgames.com/documentation/unreal-engine/API/Runtime/CoreUObject/FMulticastDelegateProperty?lang=en-US): property/signature association; corroborated by the local engine and plugin sources.

## Evidence disposition

This attachment preserves source findings for later design and tests. It is neither a second specification nor an execution ledger. No delegate Automation test, C++ adapter test, Blueprint fixture, cooking test, hot-reload test or benchmark was run during this exploration or record creation. Future verification must execute both native and dynamic paths and distinguish compiled source behavior from AST-only checks.
