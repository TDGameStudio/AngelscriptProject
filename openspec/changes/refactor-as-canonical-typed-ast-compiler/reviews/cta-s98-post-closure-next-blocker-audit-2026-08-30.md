# CTA-S98 post-closure next-blocker audit — 2026-08-30

## Executive result

CTA-S98 did not expose a new regression after its focused repair. The complete
validation surface is green:

- focused derived-funcdef gate: **1/1 PASS** after a valid **0/1 semantic RED**;
- SemaAuthority: **458/458 PASS**;
- complete native SDK Compiler: **798/798 PASS**;
- Cache: **585/585 PASS**;
- TypedASTJIT: **56/56 PASS**;
- native SDK Module: **65/65 PASS**;
- Compiler CanonicalAST + ProjectGeneration Engine + TypedASTJIT +
  NativeBridge: **780/780 PASS**, zero failures/skips.

The issue closed by CTA-S98 is therefore no longer a current blocker. This
review records what remains after that closure and distinguishes confirmed
product defects from static hardening opportunities.

## Confirmed closed boundary

A production search under the maintained AngelScript source now finds direct
`FromScriptParameterABI` use only inside the Runtime type bridge's documented
fallback implementation. The reachable funcdef consumers use
`FromScriptFunctionParameterABI`:

- explicit lambda viability;
- omitted lambda contextualization;
- indirect funcdef call formal-view construction.

`FindMatchingFuncdef` also authenticates source-formal metadata and no longer
uses the fork's shared static `asCScriptFunction::funcdefType` field as an
arbitrary-function cache. The remaining references to that field belong to
retained native AST/Builder, type ownership, formatting and save/restore
machinery and are not evidence that CTA-S98's route is still open.

## Remaining blocker class 1: unsupported breadth and product-default cutover

The primary blocker is no longer a known silent misbinding in the currently
supported scalar/reviewed-native subset. It is incomplete proof of the full
product sentence represented by Tasks 5.9, 7.4, 7.5, 9.5, 10.2 and 13.6.

The remaining breadth includes, depending on the backend and route:

- uncommon import/mixin/property/constructor/delegate and cross-TU call forms;
- mutable globals and import-slot lifecycle routes;
- container/template and generated lifecycle/list-factory breadth;
- complete exceptional cleanup and suspend/resume semantics;
- provider fallback evidence for every unsupported family;
- production-entry/default-selection scans and the final focused/All gates.

Several of these families already fail closed or are explicitly deferred. That
is safer than silent emission, but a typed fallback is not the same as proving
that CANONICAL can become the product default for the whole active language
surface. Product default therefore remains LEGACY.

The original AngelScript parser/native AST/Builder/compiler must remain in this
change for syntax/recovery, explicit LEGACY, reference, differential and
rollback use. HIR remains physically absent. Standalone remains deferred.

## Remaining blocker class 2: coarse registered-callable resolver checks

The post-CTA-S98 static review revisited the registered callable resolvers in
`as_bytecode_codegen.cpp`:

- `FindRegisteredGlobalFunction`;
- `FindExactRegisteredConstructor`;
- `FindExactRegisteredListFactory`.

Unlike the already repaired `FindExactRegisteredMethod`, these routes still
compare selected datatype fields manually and compare parameter direction only
when the expected direction is not `asTM_NONE` and the Runtime flag entry is
present. Constructor/factory routes also have hidden-formal and template-stub
offset rules that make a blind shared-helper rewrite risky.

This is an authentication/hardening gap, but the audit did not establish a new
product RED:

- ordinary by-value value objects and explicit reference formals differ in the
  Runtime datatype's reference shape on registered-native routes;
- explicit `in`, `out` and `inout` selected by Sema already enter the non-NONE
  comparison branch;
- list-factory projection normally comes from the same single Runtime factory,
  so a mismatching Canonical declaration is not naturally produced;
- an earlier exploratory registered-global const-reference fixture failed in
  Sema ambiguity and was correctly excluded rather than claimed as resolver
  evidence.

The safe next step is not to change all three resolvers speculatively. First add
natural production fixtures that prove Sema uniquely selects two candidates
whose complete Runtime signatures differ only in a field currently ignored by
the resolver. Only a fixture that reaches CodeGen relocation and fails or binds
the wrong FunctionId is a valid product RED. If no such active form exists,
record exact equality as defense-in-depth and keep it separate from default-
cutover blockers.

## Remaining boundary 3: historical shared `funcdefType`

`asCScriptFunction::funcdefType` remains a historical static field in this
fork. CTA-S98 avoids trusting it in `FindMatchingFuncdef`, which closes the
reachable defect without changing layout or save/restore behavior. Replacing
the field throughout retained native AST, type ownership and serialization is
a wider compatibility project and is not required for the current Canonical
cutover. It should be handled by a separate OpenSpec if the maintained fork
wants to retire that historical design.

## Recommended next execution order

1. Run a read-only production-entry/default-selection scan and enumerate each
   route that can still select LEGACY or publish `Unsupported` for valid active
   language input.
2. Convert only naturally reachable resolver or unsupported-family gaps into
   grouped semantic RED fixtures.
3. Repair confirmed defects in coherent batches, then rerun the affected
   focused prefix plus Compiler CanonicalAST, Cache/Module when persistence or
   identity is involved, and the combined StaticJIT matrix.
4. Reserve the final default switch for the complete cutover matrix; do not
   infer readiness from the current **780/780** supported-subset gate alone.

## Progress disposition

Formal task progress remains **102/136 = 75.0%**, because CTA-S98 is evidence
inside still-open umbrella rows rather than a complete full-language/default-
cutover sentence. The current conservative estimates remain:

- architecture-weighted non-Standalone implementation: **about 98%**;
- end-to-end non-Standalone overall progress: **about 93%**;
- safe product-default CANONICAL readiness: **about 92%**.

The gap between the formal ratio and engineering estimate is expected: many of
the 34 unchecked rows overlap the same unsupported-family, cutover and final-
verification obligations. No percentage is a claim that the product default
may now switch from LEGACY.
