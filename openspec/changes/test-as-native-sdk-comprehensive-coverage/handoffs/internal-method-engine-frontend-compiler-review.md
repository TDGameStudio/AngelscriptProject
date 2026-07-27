# Internal Method Review: Engine, Frontend, Compiler

## Scope and rules

This handoff reviews every internal-method row assigned to Engine, Frontend, or Compiler by audits/internal-classes.csv. It does not modify the authoritative reconciliation.

Disposition vocabulary follows ReconcileInternalMethods.ps1:

- DirectCovered = DirectInternal: a receiver-qualified internal call appears in a concrete product-owning test source.
- PublicContractCovered = PublicBehavior: only an exact asCScriptEngine / observed asIScriptEngine method correlation is accepted.
- NotApplicable: a concrete platform/build non-applicability reason; none was established.
- ApiDeferred = Deferred/real test gap: no direct owner or exact public-method correlation was proven.

Coverage is not inferred from a method name, a class merely appearing in a file, or a broad product that may transitively execute an internal method.

## Counts

| Domain | Rows | DirectInternal | PublicBehavior | NotApplicable | Deferred / real gap |
|---|---:|---:|---:|---:|---:|
| Engine | 126 | 15 | 37 | 0 | 74 |
| Frontend | 99 | 41 | 0 | 0 | 58 |
| Compiler | 345 | 24 | 0 | 0 | 321 |

Total rows: **570**.

- DirectInternal: **80**
- PublicBehavior: **37**
- NotApplicable: **0**
- Deferred / real focused-test gaps: **453**

## Interpretation

ApiDeferred does not claim the production path is unused. It means current evidence is not method-specific enough. Each deferred row requires a focused direct owner with a method-specific oracle, or an exact public-interface path with a behavioral oracle.

The direct scan requires a product marker in the same test file. Legacy calls without product ownership are not promoted. PublicBehavior is restricted to exact observed asIScriptEngine methods; Compiler and Frontend are not broadly covered merely because parsing or compilation succeeded.

No build or runtime test was performed.
