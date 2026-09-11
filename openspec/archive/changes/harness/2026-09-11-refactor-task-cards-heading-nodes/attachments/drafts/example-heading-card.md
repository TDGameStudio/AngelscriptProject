# Worked example: delegates plan header + task 2.2 in the settled heading-node format

Illustrative migration of `angelscript/feature-delegates-ue-interop/tasks.md` (header + one card). Names marked `proposed` are not settled; they exist only to show where the naming round's output lands. Real symbols verified 2026-09-11: `asCCallableType` (forward-declared in `as_typeinfo.h:60`, `as_module.h:140`), `asCCallableTypeDecl` (`frontend/as_ast_fwd.h:149`), `asCMetadataImage::CreateCallableType` / `CreateCallableSignature` (`as_metadata_image.h:145,151`), `frontend/as_frontend_sema_postfix.cpp`. `as_callable*` files and `AngelscriptTest/NewVersion/Delegates/` do not exist yet.

````markdown
---
task_graph:
  version: 1
  depends_on:
    "1.2": []
    "1.3": ["1.2"]
    "2.1": ["1.3"]
    "2.2": ["2.1"]
    "2.3": ["2.2"]
    "3.1": ["2.3"]
    "3.2": ["1.2"]
    "3.3": ["2.2", "3.2"]
    "4.1": ["3.1", "3.3"]
---

# UE-style delegates, native callables and Unreal interoperability

## Goal

Script code declares, binds, stores and broadcasts UE-style delegates whose callbacks run on the replacement runtime and interoperate with native `TDelegate`, dynamic delegates and Blueprint listeners.

## Architecture

Declarations are parsed into flavor-aware `asCCallableTypeDecl` nodes and resolved to `asCCallableType` through `asCMetadataImage::CreateCallableType`; the runtime stores one callable representation with explicit receiver/payload state and a generation lease; Unreal interop adapts that representation to `TDelegate`, reflected `UDelegateFunction` / `FDelegateProperty` and Blueprint. See `design.md` §2–§5.

## Global constraints

- Language policy (`angelscript/refactor-language-surface-ue-focused`): no Lambda forms, source funcdefs, script exceptions/coroutines, BlueprintGetter/BlueprintSetter; no `BindLambda` / `CreateLambda` / `AddLambda`; no lexical capture storage.
- Runtime work consumes `angelscript/refactor-vm-symbolic-execution` execution/identity owners; do not duplicate its VM, emitter, fingerprints or generation lifetime.
- Prerequisite: `angelscript/refactor-language-surface-ue-focused` task 2.1 (structured callable API) must be complete before any product node here is applied.
- Tests: CQTest under `WITH_ANGELSCRIPT_TESTS`, area `Angelscript.UnitTest.Delegates`, build before each proving phase via `ue.build`. Execution conventions: `.agents/skills/harness/references/execution-conventions.md`.

## File map

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/
   frontend/
     as_decl*.{h,cpp}                         # declaration forms, flavor            · 1.2
     as_frontend_sema_postfix.cpp             # bind/create expression semantics      · 1.3 2.2
     as_expr*.{h,cpp}                         # callable reference nodes              · 1.3 2.2
     as_ast_codec.*, as_ast_projection.*      # flavor in AST format                  · 1.2
+  as_callable.h                              # callable representation + lease       · 2.1 2.2 2.3
+  as_callable.cpp                            #                                       · 2.1 2.2 2.3
+  as_multicast.h/.cpp                        # subscription domain, broadcast        · 2.3
   as_bytecode*.{h,cpp}                       # lowering of bind/execute              · 2.1 2.2
   as_context*.{h,cpp}                        # invocation entry                      · 2.1
 Plugins/Angelscript/Source/AngelscriptRuntime/
   Binds/Bind_Delegates*.cpp                  # native TDelegate adapters             · 3.1 3.3
+  Binds/DelegateAdapters/**                  # typed adapter fixtures                · 3.1
+  ClassGenerator/DelegateReflection/**       # UDelegateFunction / FDelegateProperty · 3.2 3.3 4.1
 Plugins/Angelscript/Source/AngelscriptTest/NewVersion/
+  Delegates/DeclarationTests.cpp             # 1.2
+  Delegates/BindingSemanticTests.cpp         # 1.3
+  Delegates/ExecutionTests.cpp               # 2.1
+  Delegates/PayloadTests.cpp                 # 2.2
+  Delegates/MulticastTests.cpp               # 2.3
+  Delegates/NativeInteropTests.cpp           # 3.1
+  Delegates/ReflectionTests.cpp              # 3.2
+  Delegates/DynamicInteropTests.cpp          # 3.3
+  Delegates/LifecycleTests.cpp               # 4.1
```

## Requirement coverage

| Requirement (specs delta) | Tasks |
|---|---|
| Declaration forms, flavor, codec | 1.2 |
| Typed references, overloads, receiver/const/access | 1.3 |
| Executable callable and generation lifetime | 2.1 |
| Explicit payload and receiver lifetime | 2.2 |
| Multicast subscription and mutation | 2.3 |
| Native adapters and weak UObject policy | 3.1 |
| Reflected descriptors and properties | 3.2 |
| Blueprint / native / script dynamic invocation | 3.3 |
| Host loading, cooked execution, invalidation | 4.1 |

Self-review 2026-09-11: coverage complete; no placeholder phrases; symbol names consistent with `design.md` §4 "Vocabulary and Naming". Record: `attachments/data/planning-validation.md`.

## 2. Executable callable model

## [ ] 2.2 Store explicit named-target payloads and receiver state with managed lifetime

Bind-time payload values and the receiver are stored inside the callable object, copied and destroyed with it, and appended as trailing arguments when a named free function or member is invoked. No Lambda node, capture environment or anonymous-function conversion is added.

**Outcome**

`Bind(AddOffset, Offset)` on a delegate type stores `Offset` by value at bind time; `Execute(x)` calls `AddOffset(x, Offset)`. Managed handle payloads are retained until the last callback owner releases; escaping stack references are rejected at bind analysis. Excluded: multicast (2.3), native `TDelegate` adaptation (3.1), any Lambda-style capture.

**Interfaces**

Consumes (existing, inspected):

```cpp
class asCCallableType;                                   // as_typeinfo.h:60 — resolved delegate type from 1.2
asEMetadataResult asCMetadataImage::CreateCallableType(const asSStableKey& Key, ...);   // as_metadata_image.h:145
asEMetadataResult asCMetadataImage::CreateCallableSignature(const asSStableKey& SignatureKey, asCScriptFunction*& Out); // :151
```

Consumes (from 2.1, this Change):

```cpp
struct asSCallableObject;                                // proposed · glossary — one bound callable: target, receiver, generation lease
asEExecResult asCContext::ExecuteCallable(asSCallableObject&, asSArgSpan Args);   // proposed · glossary
```

Produces (new in this task):

```cpp
struct asSCallablePayload {                              // proposed · glossary — bind-time values appended to the call
    asCScriptFunction*  Target;                          // the named function/member; never a lambda node
    asSTypedValueArray  Values;                          // owned copies; destroyed with the callable
    asSReceiverRef      Receiver;                        // strong for script objects, weak for UObject
};
asEBindResult asCCallableBinder::BindNamed(asCCallableType&, asCScriptFunction& Target, asSArgSpan PayloadArgs, asSCallableObject& Out);  // proposed · glossary
```

Naming source: the delegates naming round's glossary, copied into that Change as `attachments/drafts/glossary.md` (not yet produced; the Change predates the naming gate).

**Cases**

1. **Payload stored by value** — new RED
   Given `int AddOffset(int v, int off)` and `d.Bind(AddOffset, 10)`
   When `d.Execute(5)`
   Then it returns `15`
2. **Later writes do not reach the payload** — new RED
   Given case 1, then the factory sets its local `Offset = 99`
   When `d.Execute(5)`
   Then it still returns `15`
3. **Managed handle payload outlives its original owner** — new RED
   Given a payload `UObject@` whose original owner drops its reference
   When `d.Execute()` runs and callable copies are destroyed one by one
   Then the handle stays valid until the last copy dies, then is released once
4. **Escaping stack reference is rejected** — new RED
   Given a payload `int&` bound to a local of the binding scope
   When the bind expression is analysed
   Then diagnostic `E_DELEGATE_PAYLOAD_ESCAPES_SCOPE` (proposed), no callable created
5. **Trailing payload order** — new RED
   Given `OnResult(int Result, int RequestId)` bound with stored `RequestId = 7`
   When the delegate fires with `200`
   Then the handler observes `(200, 7)`
6. **Payload destroyed exactly once across copies and faults** — new RED
   Given a counted payload, a copy of the callable, the copy reset, then a runtime fault inside the target
   Then `FPayloadCounter` net 0 after teardown
7. **Incompatible payload layout cannot rebind** — new RED
   Given a rebind into the same slot with a payload of a different layout
   Then `E_DELEGATE_PAYLOAD_INCOMPATIBLE` (proposed)
8. **Weak UObject receiver is not retained** — new RED
   Given a weak `UObject` member receiver that is garbage-collected
   When `ExecuteIfBound()`
   Then the receiver was not kept alive and the call is skipped
9. **Lambda forms remain rejected** — existing control
   Given `d.BindLambda(...)` or `[](){}`
   Then rejected by 1.3, unchanged

Oracle: `FPayloadCounter` (test-local) increments on construct and decrements on destroy; net 0 after every case.
**Files**

```diff
 Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/
   frontend/as_frontend_sema_postfix.cpp     # bind-expression semantics: payload args, escape check
   frontend/as_expr*                         # callable reference nodes carrying payload plans
+  as_callable.h                             # asSCallablePayload, asCCallableBinder
+  as_callable.cpp                           #
   as_bytecode*                              # payload argument emission only
+Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Delegates/PayloadTests.cpp   # cases 1-9
```

`as_expr*` and `as_bytecode*` cover only bind-expression lowering and payload argument emission; other operators and opcodes are out of scope.

**Verification**

```powershell
Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.Delegates.Payloads'; Fast = $true; TimeoutMs = 600000 }
```

All nine cases discovered and executed; cases 1–8 pass after implementation, case 9 passes before and after; `FPayloadCounter` net 0 in every case.

**Notes**

Implement the payload store on `asSCallableObject` before touching the emitter so case 6 can be proven with a C++-constructed callable first. Allocation tuning is deferred until measured.
````

## What the migration changed against the original 2.2

- Heading is the node; brief paragraph under it; body unindented.
- Interfaces block names actual consumed symbols with file:line and marks every new name `proposed · glossary` — the naming round must settle these before the card is Ready.
- Cases moved from one sentence chain to nine named cases (Given / When / Then, role tag on the name); the counting oracle is named. No table.
- Files is a diff-marked tree (`+` create / ` ` modify / `-` delete, `#` responsibility); the glob exclusion sentence is kept.
- The three RED/implement/GREEN steps are gone; `test-driven-development` runs that cycle from the Cases table. Ordering advice that matters stays in Notes.
- Plan-level header replaces the 45-line preamble; the file map is a diff-marked tree (visual-explain "changes-comparisons") that shows Create (`+`) / Modify (` `) / Delete (`-`) once for the whole plan with the owning task IDs.
