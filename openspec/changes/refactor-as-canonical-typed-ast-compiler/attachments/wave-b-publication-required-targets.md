# Wave B — sealed publication requires executable expression targets

Worktree: `D:\as-cta`
Change: `refactor-as-canonical-typed-ast-compiler`
Scope: a narrow publication-verifier firewall increment from
`wave-b-verifier-135-next.md`.

## The boundary

The canonical AST deliberately permits recovery nodes while Sema is still
building a graph. In particular, an unresolved source call remains a `CALL`
with an error type and no invented `resolvedDecl`; this keeps diagnostics and
debug dumps faithful to the source failure.

The prior verifier used the same permissive check for a sealed graph's public
publication. Consequently, an executable `CALL`, `CONSTRUCT`, or `DECL_REF`
without a target could pass `asCASTVerifyPublication` after `Seal()`.

This increment separates those two contracts:

```text
construction / Sema recovery
    asCASTVerify()       accepts missing targets
    Seal()               stays usable for diagnostics

sealed graph publication
    asCASTVerifyPublication()
        CALL       requires resolvedDecl  -> call-decl on miss
        CONSTRUCT  requires resolvedDecl  -> construct-decl on miss
        DECL_REF   requires resolvedDecl  -> declref-decl on miss
```

Unsealed publication still returns `unsealed-publication` before this target
check. Existing generic integrity errors are also preserved: publication runs
the normal structural verifier first, then applies the sealed-only target
requirement.

## TDD evidence

Three construction-API tests were added first. They deliberately require all
of the following at once:

- unsealed `asCASTVerify()` succeeds with the missing target;
- unsealed publication still reports `unsealed-publication`;
- `Seal()` succeeds so recovery diagnostics remain available; and
- sealed publication reports the precise missing-target token.

The existing Sema authority lock for unresolved `Missing()` was retargeted only
at its final publication assertion; it still locks `CALL` kind, `<unresolved>`
type, diagnostics, unsealed verification, and successful sealing.

### RED

- Build:
  `Saved/Build/cta-publication-target-gate-red-build/20260823_032510_830_be979c32`
  — succeeded (test code compiled; known fixture warnings only).
- Verifier:
  `Saved/Tests/cta-publication-target-gate-red/20260823_032527_503_47a59a4e`
  — `20 total, 17 passed, 3 failed` as intended. The failures were exactly
  `CALL`, `CONSTRUCT`, and `DECL_REF` accepting sealed publication without
  `resolvedDecl`.

### GREEN

- Build:
  `Saved/Build/cta-publication-target-gate-green-build/20260823_032632_703_d4f48bed`
  — succeeded.
- Verifier bucket:
  `Saved/Tests/cta-publication-target-gate-verifier-green/20260823_032644_086_ec0e0433`
  — `20/20 PASS`, `0 failed`, `0 skipped`.
- Sema authority bucket:
  `Saved/Tests/cta-publication-target-gate-sema-green/20260823_032725_187_73502049`
  — `250/250 PASS`, `0 failed`, `0 skipped`.

## Deliberate non-claims

- `asCASTVerify()` and `Seal()` remain intentionally permissive for unresolved
  recovery nodes. This change must not be moved into them.
- `CLEANUP` remains optional when Sema cannot select a destructor; no cleanup
  plan or statement-level payload was invented.
- This does not add expression ownership/reachability/cycle checking, callee
  kind/signature/receiver/argument-role verification, or error-node rejection.
- `asCBytecodeCodeGen::Generate()` is now wired to
  `asCASTVerifyPublication()` by the separately audited follow-up
  `wave-b-codegen-publication-gate.md`. That integration rejects before any
  CodeGen mutation; it does not make CANONICAL the default compiler.
- Do not mark or unmark Tasks 13.5, 13.2, 5.5, 5.6, or 9.4. This reduces one
  documented publication hole; it is not full verifier or compiler authority.
