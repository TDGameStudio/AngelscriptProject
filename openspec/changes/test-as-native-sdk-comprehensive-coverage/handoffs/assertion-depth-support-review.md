# Support Product Assertion-Depth Review

## Scope and result

The catalog has one product whose exact owner is under `Support/`. It was not
included in the eight raw-SDK domain reviews because its owner path is neither
a language/runtime domain nor a behavior-specific test folder.

| Theme | Products | Complete | ChangeRequired | Deferred |
| --- | ---: | ---: | ---: | ---: |
| NativeDomains | 1 | 0 | 1 | 0 |

## Finding

`NATIVE-DOMAIN-API-LIFECYCLE` declares a complete product of eight domain
labels, six operation labels, and six evidence labels, producing 288 cells.
The owner does not dispatch those labels to distinct raw SDK behavior. Every
cell compiles the same `DomainEntry()` function, queries the same scalar type,
executes the same return value, discards the same module shape, and destroys a
fresh engine. Only the `invalid_argument` operation performs one additional
missing-type lookup.

Consequently:

- `Domain` is a comment label, not an API receiver or behavior selector;
- `invalid_state`, `repeat`, `cross_engine`, and `release_cleanup` do not
  exercise their named operation;
- `Diagnostic` has no owning message/stage/symbol oracle;
- a fresh engine per cell does not prove cross-engine isolation;
- the printed source is reviewable, but its labels overstate semantic depth.

This is a coverage-quality defect, not a request to add more nominal cells.
The owner must be replaced by exact receiver/operation contracts or split into
real domain-specific products. If existing focused products already own a
cell's behavior, the synthetic cell should be removed and its API audit
mapping redirected to the exact stronger owner.

## Verification

- Reviewed catalog products under `Support/`: 1.
- Review rows: 1.
- Unique ProductId: 1.
- Owner file, class, and method exist.
- Catalog Theme, Owner, and declared evidence match the CSV.
- No build or Automation result is claimed by this read-only review.
