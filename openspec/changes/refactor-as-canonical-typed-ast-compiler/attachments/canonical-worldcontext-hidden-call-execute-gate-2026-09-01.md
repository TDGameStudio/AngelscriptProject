# Canonical WorldContext hidden-call execute (CTA-S163)

Date: 2026-09-01

## Scope

CTA-S135 sealed the dump of `WithWorld(3)` as HIDDEN Call of
`__WorldContext()` plus positional `3`, with CodeGen/provenance `N/A`.
This card is the missing execute lock. It is characterization: the
focused execute test passed immediately. Do not treat dump-only S135 as
an unfinished execute gap.

Does not check 5.3 as a whole, 5.4–5.9, 13.2, or section 10.
Product default stays LEGACY.

## Gate card: `WithWorld(3)` executes the injected host

- **OpenSpec task(s):** `5.3`, overlapping `13.2`
- **Source fixture:** native `WorldContextHost __WorldContext()` plus
  `int WithWorld(WorldContextHost WorldContext, int Visible)` with
  `hiddenArgumentIndex = 0` and `hiddenArgumentDefault =
  "__WorldContext()"`. Script `return WithWorld(3);`.
- **Canonical facts:**
  1. Publisher is `asBYTECODE_PUBLISHER_CANONICAL_CODEGEN`.
  2. `GetLastLegacyCompilerInvocationCount() == 0`.
  3. Injector runs once and `WithWorld` sees that host pointer;
     `Entry() == 43` (`3 + 40`).
- **AST test:** existing
  `CanonicalWorldContextHiddenCallSealsInjectedCall` now also asserts
  publisher/legacy.
- **CodeGen test:**
  `FCanonicalASTProductionCodeGenTests::CanonicalWorldContextHiddenCallExecutesWithoutLegacyCompiler`
- **AST-red / CodeGen-red:** `cta-sema-call-53-worldcontext-exec-red`
  `20260901_113904_179_f81237a9` **1/1 PASS immediately**.
  Characterization, not a new Sema/CodeGen gap.
- **Focused regression:** included in later CTA-S164 named prefixes.
- **Remaining boundary:** 5.3 stays `[ ]`. Logical `Object && true`
  leftover VALUE cond is CTA-S164.
