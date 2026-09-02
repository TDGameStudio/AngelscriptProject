# CTA-S176 Sequence designator firewall review — 2026-09-01

## Review result

CTA-S176 is accepted as a concrete Task 5.4 sequencing slice. It removes two
semantic guesses from ordinary Canonical Bytecode Sequence emission and makes
the canonical publication/verifier boundary reject the parser/compiler
designators that those guesses previously hid. No blocking regression was
found in the fresh SemaAuthority, ProductionCodeGen or Frontend CanonicalAST
prefixes.

This slice does **not** close Task 5.4. Formal progress therefore remains
**108/136 = 79.4%**, with **28** rows open. The practical engineering estimate
remains **about 82% (plus or minus 4%)**: CTA-S176 reduces one known 5.4 risk,
but the remaining single-evaluation/side-effect-trace matrix and the larger
backend/cutover gates still dominate delivery risk.

## Finding and correction

Ordinary `asAST_EXPR_SEQUENCE` emission contained two downstream repairs:

1. skip a receiver-less unresolved `Call` presumed to be a parser-interned
   companion of the real member call;
2. skip a `DeclRef` naming a function-like declaration or class, presumed to
   be an IIFE / `T()` companion designator.

Those repairs violated the approved Clang-shaped ownership model. Sema must
publish the executable expression graph; CodeGen must consume that graph
mechanically. CTA-S176 now enforces that boundary as follows:

- publication already requires every `Call` to own a resolved declaration and
  dispatch;
- the verifier rejects a direct `Sequence` child that is a `DeclRef` naming a
  Function, Method, Constructor, Destructor, Mixin or Class, with stable detail
  `sequence-non-executable-designator`;
- ordinary Sequence emission evaluates every child instead of classifying and
  silently discarding semantic-looking nodes.

The existing special `OpaqueValue` path and authenticated lifetime protocol
were not changed.

## TDD and regression evidence

| Gate | Result | Evidence |
|---|---:|---|
| Forged verifier RED | **0/2 expected pass; 2 expected failures** | `cta-sema-sequence-54-designator-red-v2/20260901_172221_619_6412d0b6` |
| Forged verifier GREEN | **2/2 PASS** | `cta-sema-sequence-54-designator-green/20260901_172423_686_1e26bc5f` |
| Real-source sealed graph | **1/1 PASS** | `cta-sema-sequence-54-designator-source-green/20260901_172459_514_98220398` |
| Build | **PASS** | `cta-sema-sequence-54-designator-green/20260901_172404_949_a20199e1` |
| Complete SemaAuthority | **536/536 PASS** | `cta-sema-sequence-54-designator-sema-full/20260901_172620_289_e0119010` |
| Complete ProductionCodeGen | **229/229 PASS** | `cta-sema-sequence-54-designator-prodcodegen-full/20260901_172802_571_5da83ebb` |
| Complete Frontend CanonicalAST | **189/189 PASS** | `cta-sema-sequence-54-designator-frontend-full/20260901_173432_099_528daca5` |
| Parent/plugin diff check | **PASS** | exit 0; plugin line-ending notices only |
| OpenSpec strict validation | **PASS** | change valid |

All completed GREEN reports have zero failures and zero skips. The first RED
attempt omitted the CQTest class segment and matched no tests; it is excluded
from evidence. The `red-v2` result is the valid pre-production RED.

## Cache scope clarification

Cache V2/V12 remains contained and deferred for a later standalone refactor.
CTA-S176 changes neither the Sidecar V12 schema nor cache serialization bytes,
so a new complete Cache run is not an acceptance gate for this slice. A run
started under `cta-sema-sequence-54-designator-cache-full-v12` was intentionally
stopped after this scope was reconfirmed; its exit code reflects user-requested
interruption and is not a product failure. The previously completed committed
baseline remains **586/586 PASS** and is historical evidence only.

## Remaining Task 5.4 work

Task 5.4 still needs a final requirement-by-requirement closure audit across:

- property/index/mutation single evaluation, including the remaining
  compiler-generated-value forms;
- short-circuit and conditional side-effect traces;
- temporary materialization and cleanup interaction;
- separate LEGACY and CANONICAL observable-trace parity without rebuilding a
  shared semantic record in consumers.

CTA-S176 prevents CodeGen from hiding malformed Sequence contents. It does not
prove that every required source family has already been characterized, so no
OpenSpec checkbox changes in this review.
