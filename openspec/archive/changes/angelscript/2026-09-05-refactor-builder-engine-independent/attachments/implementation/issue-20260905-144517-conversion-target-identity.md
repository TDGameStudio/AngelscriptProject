---
issue_schema: openspec-material-issue-v2
issue_id: issue-20260905-144517-conversion-target-identity
status: resolved
source: implementation
source_ref: "task 4.1 maintained grammar inventory"
affected_tasks: ["4.3", "4.1", "7.2"]
created_at: 2026-09-05T14:45:17+08:00
resolved_at: 2026-09-05T21:20:00+08:00
resolution_ref: "tasks.md 4.3/8.2 NativeEngine 84f867a143f44031a1ca2aeefefd5b3f"
---

## Symptom

The maintained fork permits conversion operators with distinct destination types, but the new Function identity rejects every same-name/same-parameter return-type difference. Ordinary functions must retain that rejection; applying it unchanged to conversion operators removes maintained behavior.

## Investigation Log

- Retained `as_builder.cpp:5851` explicitly treats `opConv`, `opImplConv`, `opCast` and `opImplCast` as distinct candidates when return types differ. Ordinary methods instead emit `TXT_DERIVED_METHOD_MUST_HAVE_SAME_RETTYPE_s`.
- `frontend/as_type_identity.cpp`, `EncodeFunctionIdentity`, omits ReturnType from every Function encoding; `InternCanonicalLocked` returns `ReturnTypeConflict` for equal identity with a different return type.
- Current design and stable-identity delta describe the ordinary rule without this exception. Current Sema covers builtin/enum conversions, exact references, contextual null and construction, but not selection of the four user conversion operators.

## Root Cause

An ordinary-overload identity constraint was generalized to a maintained special declaration category whose destination participates in overload selection. This is an accepted-contract gap, not a Harness defect or a normal parser typo.

## Disposition

Keep 4.1 incomplete. After the current grammar/codec batch is verified, apply an evidence-gated planning update before implementing conversion overload admission and selection. The candidate retains the single key family and normal return-only conflicts, but represents a conversion function kind with an explicit canonical destination TypeUse edge. Do not synthesize names/parameters, reparse display text or permanently exclude conversions. Ordinary/conflicting/destination-distinct, inherited and ambiguous-selection tests are required.

On 2026-09-05, after complete 481/481 batch `df8e2e24acba4e0ebaa17a1412449c2a`, `replan-20260905-152247-conversion-target-identity` updated the stable-identity delta/design and retained all Task DAG edges. The issue remains open: a corrected plan is not implemented conversion behavior or GREEN evidence.

## Evidence

### Failure Evidence (RED)

- Command: `rg -n 'TXT_DERIVED_METHOD_MUST_HAVE_SAME_RETTYPE_s|opImplConv|opImplCast' Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.cpp`
- Command: `rg -n 'ReturnTypeConflict' Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_identity.cpp`
- Artifact: `attachments/replans/replan-20260905-152247-conversion-target-identity.md`, preserving the accepted ordinary-rule correction. The retained exception conflicts with the original unconditional rule. This is source/contract evidence, not a newly executed UE failing test.

### Resolution Evidence (GREEN)

Task 4.3 admitted destination-distinct conversion functions and selected them without relaxing ordinary ReturnTypeConflict. Task 8.2 authenticated nested UserConversionExpr projection and rejected a known TypeUse key in a ConversionFunction slot. NativeEngine `84f867a143f44031a1ca2aeefefd5b3f` maps ConversionIdentity, BodiesConversions, ConversionDefinitions and ASTCodec V7 conversion cases as Success.

### What This Proves

The full maintained-grammar objective cannot be completed by applying the current ordinary function identity rule unchanged to conversion operators.

### What This Does Not Prove

No ordinary key or verified registration contract needs to be discarded. This does not authorize VM execution, old AST fallback, another public key family or a Harness API change.

## Links

- `design.md`, Stable identity
- `specs/angelscript/language/types/stable-identity/spec.md`
- `attachments/data/language-coverage.md`
- `tasks.md`, tasks 4.3, 4.1 and 7.2
