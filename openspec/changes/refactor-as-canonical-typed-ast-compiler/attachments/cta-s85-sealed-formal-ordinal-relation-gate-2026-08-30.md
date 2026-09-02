# CTA-S85 sealed formal-ordinal relation gate — 2026-08-30

## Status

This non-Standalone slice closes the remaining reviewed positional parameter
identity defect at the TypedASTJIT root-entry boundary. Every Canonical
`DECL_PARAM` now owns an explicit, sealed `formalIndex`; consumers resolve a
formal by that relation instead of treating declaration-child order as the
Runtime ABI slot order.

```text
callable Decl
    ParamDecl(formalIndex = 0, stable id = d3)
    ParamDecl(formalIndex = 1, stable id = d4)

Runtime entry slot 0 -> GetFormalDecl(callable, 0) -> d3
Runtime entry slot 1 -> GetFormalDecl(callable, 1) -> d4
```

Child order remains structural/traversal order and may be changed by a graph
transformation without silently redirecting same-typed Runtime inputs. The
removed TypedASTJIT rule was effectively:

```text
Runtime entry slot N -> nth DECL_PARAM child
```

Formal OpenSpec progress remains **102/136 = 75.0%** because 7.2 and 7.4 are
umbrella tasks and the remaining language/call/provider/default-cutover matrix
is still open. After this slice, the engineering estimate is about **93%** for
the requested non-Standalone architecture and about **78%** for a safe product-
default CANONICAL switch. These are estimates, not task-completion claims. The
product default remains LEGACY. The original native AngelScript parser AST
remains available for parsing, recovery, reference and differential/rollback
work. HIR remains physically absent. Standalone was neither changed nor run.

## Problem

Canonical parameter declarations had stable node IDs and canonical types, but
did not publish the parameter's semantic ordinal. TypedASTJIT root emission
therefore scanned the callable's children and associated the first
`DECL_PARAM` child with Runtime parameter slot zero, the second child with slot
one, and so on.

That was a positional convention rather than a verifier-authenticated semantic
relation. If two parameters had the same type, swapping only their child order
kept the graph structurally and type-valid while silently exchanging which
Canonical declaration received each Runtime input. Type checks could not
expose the error:

| Runtime slot | Declared formal | Reordered child selected by old code |
| ---: | --- | --- |
| 0 | `First` (`d3`) | `Second` (`d4`) |
| 1 | `Second` (`d4`) | `First` (`d3`) |

This is the root-entry counterpart of CTA-S84: CTA-S84 fixed call-site argument
placement; CTA-S85 fixes callee-entry parameter identity.

## Frozen relation contract

1. `PARAM` creation assigns a zero-based `formalIndex` within its callable
   owner. The index is an explicit semantic fact, not derived after sealing.
2. The owning declaration context resolves an exact formal through
   `GetFormalDecl(owner, formalIndex)` and returns no result for a missing or
   duplicate slot.
3. Publication verification requires every `PARAM` to have a supported
   callable owner, a non-sentinel in-range index, one unique exact slot, and a
   complete contiguous formal table. Non-parameter declarations must retain
   the sentinel value.
4. Direct-call verification authenticates both the call record's
   `formalIndex` and the resolved `ParamDecl.formalIndex`; a matching type or
   child position cannot substitute for the relation.
5. Stable callable signatures and Runtime type-bridge authentication enumerate
   parameters by exact formal ordinal. Child order is not identity authority.
6. TypedASTJIT root emission requires Canonical formal count to equal Runtime
   shape count, resolves every slot by exact `formalIndex`, compares the sealed
   Canonical reviewed C++ spelling with the Runtime ABI spelling, and emits the
   variable using the resolved ParamDecl ID.
7. The public immutable declaration view exposes `formalIndex` as an append-
   only field. Original V1-sized callers and the prior access-specifier-sized
   view remain accepted through staged `structSize` capacity checks.
8. Cache sidecar V10 serializes and authenticates `formalIndex` in structural
   and reference identity. Older/incompatible payloads fail as a normal safe
   miss; restore never guesses an ordinal from child order.
9. Dump and shadow-diff output include the formal ordinal so diagnostics can
   explain relation mismatches without making dump text a compiler input.

## RED evidence

The regression method was added before production relation publication and
consumption changed:

`CanonicalRootEmissionRequiresSealedFormalOrdinalRelation`

The fixture builds `Subtract(int First, int Second)`, lets Sema establish the
original declarations, then swaps only the two same-typed parameter children.
The old emitter succeeded but generated the second declaration ID for Runtime
slot zero and the first declaration ID for slot one.

- RED test build: PASS —
  `Saved/Build/cta-s85-root-formal-ordinal-red-build/20260830_094513_199_27e36ce5`;
- intended semantic RED: **0/1**, assertion only —
  `Saved/Tests/cta-s85-root-formal-ordinal-red/20260830_094533_688_36f1f76c`.

The failed generated-definition assertion showed the declaration order as
`d4`, then `d3`, where the sealed formal relation requires `d3`, then `d4`.
This proves the defect was silent same-typed parameter redirection, not a parser
or C++ compilation failure.

## Resolution map

| Boundary | Implementation |
| --- | --- |
| Canonical declaration fact | `ThirdParty/angelscript/source/as_decl.h` (`formalIndex`, sentinel) |
| Assignment and exact lookup | `ThirdParty/angelscript/source/as_ast_context.h/.cpp` |
| Publication and call-relation authentication | `ThirdParty/angelscript/source/as_ast_verifier.cpp` |
| Stable signature publication | `ThirdParty/angelscript/source/as_sema.cpp` |
| Runtime shape/key authentication | `ThirdParty/angelscript/source/as_runtime_type_bridge.cpp` |
| Public append-only view | `Core/angelscript.h`, `ThirdParty/angelscript/source/as_ast_public_view.cpp` |
| Sidecar V10 persistence and identity | `ThirdParty/angelscript/source/as_ast_sidecar.h/.cpp`, `Cache/AngelscriptCacheASTBodySidecar.h` |
| Direct root consumer | `StaticJIT/TypedASTJIT/AngelscriptTypedASTJITCanonical.cpp` |
| Diagnostics/shadow comparison | `ThirdParty/angelscript/source/as_ast_dump.cpp`, Canonical shadow diff |
| Same-typed adversarial regression | `AngelscriptTest/StaticJIT/TypedASTJIT/CanonicalASTMigration/AngelscriptCanonicalASTJITAdapterTests.cpp` |

No HIR adapter, declaration-name lookup, dump input, Runtime pointer identity,
numeric TypeId identity or new Provider ABI relation was introduced.

## GREEN and regression evidence

| Gate | Result |
| --- | --- |
| UE 5.8 Editor build after public/header and Sidecar V10 changes | PASS, 202/202 actions — `Saved/Build/cta-s85-formal-ordinal-green-build/20260830_095506_459_dbd89261` |
| Complete CanonicalASTJIT adapter class, including exact formal regression | **27/27 PASS** — `Saved/Tests/cta-s85-canonical-adapter-class-green/20260830_101002_338_f7e49437` |
| Canonical verifier class | **53/53 PASS** — `Saved/Tests/cta-s85-verifier-green/20260830_101055_781_aa5585f8` |
| Cache AST Body Sidecar V10 class | **24/24 PASS** — `Saved/Tests/cta-s85-sidecar-v10-green/20260830_101055_781_5c426aed` |
| Public Canonical AST snapshot class | **12/12 PASS** — `Saved/Tests/cta-s85-snapshot-green/20260830_101055_781_1a3bb76a` |
| Compiler CanonicalAST + TypedASTJIT + NativeBridge | **705/705 PASS**, zero failures/skips — `Saved/Tests/cta-s85-compiler-typedjit-nativebridge-full-green/20260830_101139_078_6e311d3a` |

The broad count increased from **704** to **705** only because this slice adds
one regression method. Existing HTTP connectivity warnings appeared in provider
reload tests; they did not fail or skip a test and are unrelated to the
compiler relation.

One attempted GREEN invocation used the incomplete prefix
`...CanonicalASTMigration.CanonicalRootEmission...` and matched zero tests.
CQTest registration includes the class segment
`FCanonicalASTJITAdapterTests`; the no-match report is retained at
`Saved/Tests/cta-s85-root-formal-ordinal-green/20260830_100802_855_60ed6cdd`
as a test-selection diagnostic only. It is not counted as semantic evidence.

## Remaining work and non-claims

CTA-S85 closes the reviewed callee-entry positional formal binding, but does not
close all of 7.2 or 7.4:

- receiver-bearing, virtual and indirect call lowering remains explicit typed
  fallback where exact receiver/provenance/ABI contracts are absent;
- mutable-global/import-slot lifecycle, native object-frame cleanup and the
  remaining import/mixin/property/constructor/delegate/funcdef/lambda/cross-TU
  matrices remain incomplete or explicit fallback;
- other bytecode/compiler loops that iterate parameter children still require
  consumer-by-consumer audit before claiming every parameter-related algorithm
  is reorder-independent; CTA-S85 closes shared identity/signature validation
  and the TypedASTJIT root consumer specifically;
- final default-cutover scans, complete focused matrix, full All verification
  and default selection remain open;
- this slice does not archive the change, switch the product default to
  CANONICAL, remove explicit LEGACY, remove the original native AngelScript
  parser AST or claim Standalone parity.
