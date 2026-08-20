# BytecodeJIT native forms and headers

How the existing `"bytecode"` backend already handles “how to spell this call”
and `#include`. TypedASTJIT’s reviewed `ExternalNativeCall` contract is stricter
and separate. Catalog work should preserve this BytecodeJIT behavior unless a
spec explicitly tightens it.

## Call lowering (`AngelscriptBytecodes.cpp`)

On `CALLSYS`-class ops:

1. `FScriptFunctionNativeForm::GetNativeForm(ScriptFunction)` on the **current**
   generation Engine (collect must be true or the form is missing).
2. Analyze `this` / args / return `GetCppForm` (native vs generic C++ spelling).
3. Pick a strategy:

| Path | When | Generated shape |
|---|---|---|
| CustomCall | form implements custom emit | special-case C++ |
| NativeCall | form present and all types have native C++ forms | `Name(args)` / `obj->Method(...)` |
| PointerCall | native call not possible, generic forms exist | function pointer from the current Engine slot |
| DynamicCall | otherwise | AS dynamic / VM bridge |

`bHaveNativeFunction` is false when `GetNativeForm` returns null, so matching
Editor Generate without collect (today) cannot NativeCall those sites.

## Where includes come from

`FNativeFunctionCall` has `CallCode` plus optional `Header`. Emit calls
`FStaticJITContext::AddHeader`, which adds to `File->Headers` for the `.jit.cpp`
preamble.

**Type includes** — `AddNativeHeaders`: `ObjectType` / `ReturnType` / each
argument `CppForm.CppHeader` (for example `FVector`).

**Call includes** — `NativeForm->GenerateCall()` / `GenerateCustomCall()`:

| Bind API | Call header |
|---|---|
| `.NativeFunction("Foo")` | none; emit `Foo(...)` only |
| `.NativeFunctionHeader("Foo", "Some.h")` | `#include "Some.h"` then `Foo(...)` (`FScriptNativeFunctionHeader`) |
| `NativeUFunction` | `FAngelscriptBindDatabase::GetSourceHeader(UClass)`. Non-monolithic builds whitelist `/Script/<Project>` and `/Script/Engine` so the generated module does not link arbitrary DLLs |
| TArray helpers | hardcoded `#include "Binds/Bind_TArray_Structs.h"` |

Shared Entry Plans may also contribute `RequiredIncludes`.

BytecodeJIT does **not** consult `FAngelscriptStaticJITNativeCallRegistry`.
Missing a call header does not by itself reject NativeCall. TypedASTJIT will not
treat a display name as HeaderInline or cross-DLL linkable.

## Implication for the catalog

Store the same Header / type-include / UFunction source-header facts on the
declaration-keyed recipe so matching-profile BytecodeJIT emit can `AddHeader`
without a collect-on pointer map. Do not require TypedASTJIT’s reviewed
descriptor for BytecodeJIT NativeCall compatibility.
