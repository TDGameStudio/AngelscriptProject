# Canonical native non-POD member lifecycle gate（2026-08-25）

## Scope

This gate advances Tasks `0.2`, `5.7`, `5.8`, `5.9`, `9.5`, and `13.6` for one production form exposed by the real StaticJIT generation source graph: a script value type containing an inline, registered, non-POD application value object such as `_FScriptDelegate`.

The first slice covers exact default construction into member storage and matching reverse destruction. Copy construction and `opAssign` remain separate follow-on slices and may not be claimed by this card.

## AST-first card

| Field | Evidence |
| --- | --- |
| Test source | `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/Compiler/CanonicalAST/AngelscriptNativeCanonicalASTProductionCodeGenTests.cpp` |
| Exact method | `PreparedNativeNonPodMemberDefaultConstructsInExactFieldStorage` |
| Source fixture | `FPreparedNativeLifecycleOwner` owns `FProdNativeLifecycleMember Inner`; two unused same-name `void GetInner()/SetInner()` methods deliberately suppress automatic by-value accessors so this card does not claim the separate copy/assignment slice; `RunPreparedNativeLifecycleMember()` creates the owner and returns `42`; native constructor/destructor counters independently prove the member lifecycle |
| Runtime fixture | 32-byte `asOBJ_VALUE | asOBJ_APP_CLASS_CD | asOBJ_APP_CLASS_ALLINTS`, with registered generic constructor/destructor and observable counters |
| Required sealed facts | owner `Inner` field has the exact native value QualType; the generated owner constructor has an InitPlan assignment whose lhs resolves to that exact field; the unwrapped rhs is `Construct`; that Construct resolves to the exact zero-argument native constructor declaration owned by `FProdNativeLifecycleMember` |
| RED contract | sealed assertions pass, then `GeneratePreparedModule` fails closed because the current member-init lowering materializes the non-POD object in a local and calls scalar `EmitWriteValue` for the 32-byte field |
| CodeGen GREEN contract | owner constructor emits `CALLSYS` to the exact registered constructor with `this + fieldOffset` as destination; it must not authorize raw storage copy or widen scalar WRTV |
| Lifecycle GREEN contract | owner destructor emits `CALLSYS` to the exact registered field destructor; execution returns `42`; construct/destruct counters are exactly `1/1` |
| Broader regression | focused ProductionCodeGen, complete ProductionCodeGen, generation, SemaAuthority, identity and rollback gates |

## Root-cause boundary

The sealed graph already identifies the field and constructor. The defect is downstream: constructor InitPlan emission calls general expression emission first, producing a temporary, then routes the result through scalar member storage. The legacy working pattern calls a value member's constructor directly with the member address. The production fix must consume the sealed constructor declaration and exact sealed field offset to do the same.

`_FScriptDelegate` is not POD. A 32-byte `COPY`, `memcpy`, or relaxed `EmitWriteValue` width is forbidden because it would bypass registered construction, assignment, destruction, exception, and ownership semantics.

## Evidence log

- Build: `Saved/Build/cta-native-nonpod-member-red-build/20260825_030938_038_01544711` — PASS.
- RED: `Saved/Tests/cta-native-nonpod-member-red-production/20260825_031050_849_075cb5a3` — the new AST assertions passed, then CodeGen failed exactly with `unsupported write width function=FPreparedNativeLifecycleOwner::FPreparedNativeLifecycleOwner() type=FProdNativeLifecycleMember bytes=32 typeFlags=0x10702 object=1 handle=0 reference=0`.
- GREEN build: `Saved/Build/cta-native-nonpod-member-green3-build/20260825_031652_200_d5b3c519` — PASS.
- Focused GREEN: `Saved/Tests/cta-native-nonpod-member-green3/20260825_031710_007_ab7a87cc` — **1/1 PASS**. The emitted owner constructor calls the exact registered native constructor in `this + fieldOffset`; the owner destructor calls the exact native destructor; execution returns `42`; constructor/destructor counters are `1/1`.
- Regressions: the complete ProductionCodeGen and generation groups still require a fresh run after this slice. This card does not claim generated accessor copy construction or `opAssign` support.
