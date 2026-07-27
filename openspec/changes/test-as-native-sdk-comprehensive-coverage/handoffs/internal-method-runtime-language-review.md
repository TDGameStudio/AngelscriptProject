# Runtime / Language Internal-Method Review Handoff

## Purpose and scope

This handoff reconciles the native AngelScript SDK internal methods that remain after excluding the separately owned Engine, Frontend, and Compiler implementation units. It covers all `431` rows from:

- Runtime: `113`
- Module: `120`
- TypeSystem: `178`
- Embedding: `20`

The reviewed implementation units are:

| Implementation unit | Methods |
|---|---:|
| `as_configgroup.cpp` | 10 |
| `as_context.cpp` | 72 |
| `as_datatype.cpp` | 51 |
| `as_gc.cpp` | 18 |
| `as_generic.cpp` | 20 |
| `as_globalproperty.cpp` | 8 |
| `as_module.cpp` | 59 |
| `as_objecttype.cpp` | 25 |
| `as_restore.cpp` | 61 |
| `as_scriptfunction.cpp` | 58 |
| `as_scriptobject.cpp` | 23 |
| `as_typeinfo.cpp` | 22 |
| `as_variablescope.cpp` | 4 |

The excluded units are `as_atomic.cpp`, `as_memory.cpp`, `as_scriptengine.cpp`, `as_thread.cpp`, `as_parser.cpp`, `as_scriptcode.cpp`, `as_scriptnode.cpp`, `as_string.cpp`, `as_tokenizer.cpp`, `as_builder.cpp`, `as_bytecode.cpp`, `as_compiler.cpp`, and `as_outputbuffer.cpp`.

This is a review handoff, not a direct edit of `audits/internal-method-reconciliation.csv`. The owning reconciliation pass must decide whether to copy these terminal classifications into the main audit.

## Review method

Every source row was classified independently by the exact tuple:

`ImplementationUnit + Class + Method + Line`

The review used two evidence paths:

1. `DirectCovered` requires a test method that contains the exact internal receiver class and invokes the exact method by `->Method(...)` or `.Method(...)`. Its rationale names the test source and `TEST_METHOD`.
2. `PublicContractCovered` requires a method-specific observable product through the public SDK path. The coverage ID is selected from the method's semantic behavior, not merely from its file or class. Its rationale preserves the implementation source line and explicitly does not claim unobserved branches.

When neither evidence path can independently distinguish the internal behavior, the row is `ApiDeferred`. No file-wide or class-wide blanket classification was used. Constructor, destructor, overload, GC-release, callback, state-transition, restore, and type-query rows remain separate records even when they share a product-level test.

## Terminal result

All `431/431` target rows now have a terminal recommendation:

| Disposition | Count | Meaning |
|---|---:|---|
| `DirectCovered` | 81 | Exact internal receiver and method invocation exists in a named test method. |
| `PublicContractCovered` | 336 | A method-specific externally observable contract is covered, without claiming hidden branch coverage. |
| `ApiDeferred` | 14 | Current public behavior cannot independently prove this internal operation; a focused seam or fault fixture is required. |
| `NotApplicable` | 0 | No reviewed method was dismissed as irrelevant. |

Validation of the CSV confirms:

- `431` unique method keys and exact key-set equality with the in-scope source audit rows.
- `0` duplicate, missing, or extra keys.
- `0` excluded implementation units.
- `0` empty coverage IDs or rationales.
- `0` non-final states or unsupported dispositions.

## True remaining test or seam gaps

The following `14` rows are the only recommendations that still require new test capability. These are not counted as covered.

### Configuration-group reference graph and removal lifecycle

Six `asCConfigGroup` methods need a fixture that exposes the reference graph and live-object/removal state before and after the exact operation:

- `AddReferencesForFunc` at `as_configgroup.cpp:92`
- `AddReferencesForType` at `as_configgroup.cpp:99`
- `AddType` at `as_configgroup.cpp:73`
- `HasLiveObjects` at `as_configgroup.cpp:107`
- `RefConfigGroup` at `as_configgroup.cpp:79`
- `RemoveConfiguration` at `as_configgroup.cpp:116`

The preferred closure is a focused internal accessor or fault-injection fixture that creates cross-group function/type references, retains a live object, attempts removal, and asserts the exact graph and lifetime transitions. Each overload must retain a separate assertion even if one fixture drives several methods.

### Native application exception translation

- `asCContext::HandleAppException` at `as_context.cpp:5283`

The fork's `AS_NO_EXCEPTIONS` configuration prevents a normal public-path test from independently reaching and identifying this translation method. Closure requires a guarded raw accessor or a build/configuration-specific injection seam. Until that exists, this is an API/configuration limitation rather than a passing semantic test.

### External-memory invalidation

- `asCContext::InvalidateReferencesToMemoryBlock` at `as_context.cpp:6157`

Closure requires an externally owned memory block with live context references, a controlled invalidation operation, and assertions that distinguish reference rewriting/invalidation from ordinary context cleanup. A public script result alone is insufficient to attribute this method.

### Object-type destruction ordering

Three `asCObjectType` methods require release-order instrumentation:

- `DestroyInternal` at `as_objecttype.cpp:82`
- `ReleaseAllFunctions` at `as_objecttype.cpp:717`
- `ReleaseAllProperties` at `as_objecttype.cpp:682`

The focused fixture should construct an object type with functions and properties, retain observable reference/lifetime sentinels, invoke the exact internal operation, and assert ordering and final ownership state. Ordinary module teardown does not independently identify these methods.

### Script-function GC reference enumeration and release

Three `asCScriptFunction` methods require explicit GC/reference instrumentation:

- `EnumReferences` at `as_scriptfunction.cpp:1620`
- `ReleaseAllHandles` at `as_scriptfunction.cpp:1630`
- `ReleaseReferences` at `as_scriptfunction.cpp:1286`

Closure requires a script function containing observable referenced objects/types, a GC callback or internal accessor that records enumeration, and separate assertions for enumeration versus each release path. End-to-end garbage collection alone cannot prove which internal release method produced the result.

## Integration guidance

- Preserve all `14` deferred IDs from the CSV so implementation work can close them one by one.
- Do not collapse overloads or lifecycle operations into a single “covered by file” row.
- Where a new seam is added, keep it test-only and prefer state observation over changing production semantics.
- Follow `unittest.md` / the repository AngelScript test conventions: CQTest structure, repository naming, matcher assertions, scoped engine/module lifetime, and the prescribed inline AngelScript formatting.
- Generated AngelScript cases must print or otherwise persist the generated source in the test log on failure and in the configured review artifact path, so failures are reproducible and the generated input remains inspectable.
- The fork remains the semantic baseline. AngelScript 2.38-only expectations should be present as explicitly tagged disabled/future cases until the corresponding selective backport is implemented.
- This handoff made no production source, test catalog, `tasks.md`, or main reconciliation-table edits. No build or test run was requested or performed for this evidence-only pass.
