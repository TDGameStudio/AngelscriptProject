# Language and Conformance assertion-depth review

## Scope and result

This read-only review reconciles every catalog product whose exact Owner is rooted in `Language/` or `Conformance/`. It applies the same evidence rules as `assertion-depth-engine-typesystem-embedding-review`: compilation, guards, case-owned engines, `Release`, `Destroy`, `DiscardModule`, and `ON_SCOPE_EXIT` are not promoted into stronger evidence without an observable oracle.

- Catalog products reviewed: **132** (`Language/`: 128; `Conformance/`: 4).
- ChangeRequired: **7**.
- Complete: **124**.
- Deferred: **1**.
- Target-set reconciliation: exact Owner-root selection, one row per ProductId, no missing or extra products.

## Theme distribution

| Theme | Products | Complete | ChangeRequired | Deferred |
|---|---:|---:|---:|---:|
| Conformance | 3 | 0 | 3 | 0 |
| Constructors | 7 | 7 | 0 | 0 |
| ControlFlow | 11 | 9 | 2 | 0 |
| Conversions | 12 | 12 | 0 | 0 |
| CrossTheme | 1 | 1 | 0 | 0 |
| Declarations | 3 | 3 | 0 | 0 |
| Destructors | 3 | 3 | 0 | 0 |
| Exceptions | 4 | 4 | 0 | 0 |
| Expressions | 10 | 10 | 0 | 0 |
| Foreach | 4 | 4 | 0 | 0 |
| Functions | 19 | 17 | 2 | 0 |
| Future238 | 1 | 0 | 0 | 1 |
| Inheritance | 5 | 5 | 0 | 0 |
| Operators | 25 | 25 | 0 | 0 |
| Properties | 9 | 9 | 0 | 0 |
| References | 7 | 7 | 0 | 0 |
| Variables | 8 | 8 | 0 | 0 |

## Products requiring action

| ProductId | Disposition | Missing oracle |
|---|---|---|
| `CONF-APPLICATION-INTERFACE-REGISTRATION` | ChangeRequired | The independent control engine proves registration isolation, but engine destruction is only RAII and no callback/count/state transition proves lifecycle completion or cleanup. |
| `CONF-CALL-LIMIT-PROPERTIES-STORAGE-ONLY` | ChangeRequired | Context/engine release is only scheduled by scope guards, and same-context execution or a case-owned engine does not prove independent-owner isolation. |
| `CONF-RECURSION-DATA-STACK-LIMIT` | ChangeRequired | Context/engine release is only scheduled by scope guards, and same-context execution or a case-owned engine does not prove independent-owner isolation. |
| `LANG-CF-BRANCH-CONDITION-DEPTH` | ChangeRequired | Module/context cleanup is scheduled by ON_SCOPE_EXIT without an observable post-cleanup assertion, and the case-owned engine/generated cell does not prove cross-cell or cross-owner isolation. |
| `LANG-CF-LOOP-COND-TRANSFER-DEPTH` | ChangeRequired | Module/context cleanup is scheduled by ON_SCOPE_EXIT without an observable post-cleanup assertion, and the case-owned engine/generated cell does not prove cross-cell or cross-owner isolation. |
| `LANG-FN-MIXIN-DIRECT-DISPATCH` | ChangeRequired | Cleanup is represented only by scoped module/engine destruction, and Isolation is represented only by separate generated cells/local receivers; there is no post-cleanup state query or independent contamination control. |
| `LANG-FN-MIXIN-FREE-CALL-REJECTION` | ChangeRequired | Cleanup is represented only by scoped module/engine destruction, and Isolation is represented only by separate generated cells/local receivers; there is no post-cleanup state query or independent contamination control. |
| `V238-DESIRED-BEHAVIOR` | Deferred | The entire selected-2.38 owner class is Disabled under #as-v238-backport, so none of its compile, diagnostic, runtime, metadata, or cleanup assertions contributes current executable evidence. |

## Judgment notes

- The generated products generally have strong compile, diagnostic, exact-metadata, runtime, lifecycle, bytecode, and debug assertions. The review therefore does not penalize generation itself; it checks the oracle reached by the exact Owner.
- Observable module absence, zero live-object/callback counts, cleared context exception/callstack state, or a verified restored baseline can satisfy Cleanup. Merely scheduling teardown cannot.
- Isolation requires an independent owner/control, a cross-cell no-contamination assertion, or an asserted restored baseline. A fresh case-owned engine alone cannot satisfy it.
- `V238-DESIRED-BEHAVIOR` is Deferred rather than Complete because its complete class is Disabled and tagged `#as-v238-backport`; source-level future assertions are not current executed evidence.

## Validation boundary

No tests, catalog entries, tasks, progress records, generators, builds, or test runs were changed or executed by this review. Validation is limited to catalog/CSV bijection, uniqueness, field parity, source Owner resolution, disposition-field integrity, and whitespace checks for these two handoff artifacts.
