## Why

The reconstructed AngelScript frontend and maintained SDK still expose a mixture of UE-facing language features, upstream compatibility APIs, and retained standalone-library consumers. Some unwanted syntax already rejects, while Lambda and funcdef-backed runtime types still have active consumers. A parser-only deny list would leave public SDK entry points and ownership assumptions behind; indiscriminate deletion would break delegate signatures, native calls, GC and host container types.

The accepted direction is a smaller UE-owned script language. The engine selects source/module membership, supplies external definitions and publishes executable generations. Scripts use ordinary classes/functions, host-registered parameterized types and explicit UE declarations. They do not define module sharing policy, anonymous functions, exception handlers, coroutines or user templates.

The user authorized implementation on 2026-09-08 after the initial planning delivery and delegate-plan alignment. This Change implements the bounded language/SDK/library reduction, verifies the current plugin, synchronizes its durable specifications and closes through the project lifecycle. Task cards and implementation evidence record actual completion. Git publication and the separate delegate implementation are outside this delivery.

## What Changes

| Surface | Outcome |
|---|---|
| Source shared/external module modifiers | Reject; remove their SDK sharing/owner-transfer policy |
| Source funcdef and old funcdef SDK surface | Reject source syntax; replace retained callable/signature consumers with canonical structured interfaces |
| Lambda | Remove all forms, including noncapturing immediate invocation, captures and escaping anonymous functions |
| Script exceptions/coroutines | Reject try/catch/throw and coroutine/yield facilities; retain runtime fault cleanup and host Context control |
| User class/function templates | Reject declarations, specialization and metaprogramming |
| Host parameterized types and intrinsics | Preserve registered TArray<T>/TMap<K,V>-style types, nesting and established Cast<T>-style operations |
| Virtual properties/accessors | Remove property blocks, property decorators and implicit accessor binding; ordinary GetX()/SetX() remain ordinary functions |
| UE accessor metadata authored in AS | Reject BlueprintGetter/BlueprintSetter on properties/functions, including nested metadata; retain general UPROPERTY/UFUNCTION behavior |
| Unused upstream add-ons | Remove scriptarray, scriptdictionary, scriptmath and scriptstdstring packages and their exclusive consumption chain; retain the Standalone directory |

This is an intentional source and C++ SDK compatibility break. No enable flag, forwarding alias or second legacy parser restores the removed features. Explicit diagnostics retain authored locations and recovery; inactive conditional input continues to be skipped. Ordinary identifiers and unrelated same-spelling host concepts are not globally banned.

Retain native generic-call interfaces (asIScriptGeneric), host parameterized-type metadata, callable signatures needed by named-function/member delegates, indirect dispatch, runtime faults/unwind, GC, host suspend/resume/abort and debug callbacks. Do not remove these merely because a name contains Generic, Shared, External or Exception.

## Capabilities

### New Capabilities

- `angelscript/language/surface`: Permanent UE-oriented source and host-library boundary, with explicit removal diagnostics and preserved host capabilities.

### Modified Capabilities

- `angelscript/language/frontend/declarations`: Reject removed declaration/accessor forms while preserving host type applications and engine-selected multi-file declarations.
- `angelscript/language/frontend/bodies`: Remove anonymous functions and script exception/coroutine forms while preserving ordinary calls and runtime cleanup facts.
- `angelscript/language/ast/core`: Exclude Lambda-only semantic products and reject incompatible persisted forms.
- `angelscript/language/types/definitions`: Structured callable metadata and engine-owned definition membership without obsolete funcdef/shared/accessor SDK interfaces.
- `angelscript/language/frontend/reflection-dependencies`: Reject AS-authored BlueprintGetter/BlueprintSetter while preserving ordinary reflected fields/functions and delegate descriptions.

## Impact

Planning lives in the parent repository. Implementation belongs in Plugins/Angelscript: the maintained SDK/frontend, current test corpus, affected runtime reflection/binding consumers and bounded Standalone add-on consumers. Keep Source/AngelscriptProject minimal and preserve unrelated work. Dormant Legacy implementation and historical test oracles remain reference material; only active build-boundary consumers are migrated when necessary to compile the changed public SDK.

The adjacent `angelscript/feature-delegates-ue-interop` remains the owner of UE delegate/event execution, explicit bind-time payloads and native/dynamic adapters. Its Lambda/closure proposal is superseded by this decision. Align its pending task 2.2 and dependent acceptance cases without implementing that feature or completing its existing design prerequisite. This Change supplies the callable metadata interface; the delegate Change consumes it before product work. Cross-change prerequisites are stated explicitly, not encoded as foreign task IDs in a local DAG.

The completed task history and raw reports of `angelscript/refactor-vm-symbolic-execution` are preserved. This Change supersedes Lambda/funcdef public-surface assumptions only; VM execution, ABI, lifetime, verification and cache oracles remain valid requirements and must be migrated rather than deleted when their fixture API changes.

Non-goals: full UE/ClassGenerator startup integration, automatic module scheduling, new container implementations, new delegate features, VM fault/GC removal, JIT, restoring Standalone buildability, deleting the Standalone project, engine-source changes or wholesale cleanup of dormant historical trees. Existing Standalone CMake references obsolete SDK paths; package removal must not be presented as a successful standalone build migration.
