# Store/Apply tests are not the green gate

## Context

About 310 `RuntimeBindings.*` tests still record into `TypeBindInfoStore` and Apply into an Installation. The product path is Collection / HostProcess / Inject. Keeping both as oracles made the predecessor look like it "only ran 30 Host tests".

## Evidence

[Catalog](../drafts/findings/old-runtimebindings-catalog.md) groups Recording, Types/Calls, Reflection, Engine Store, family, and FullRuntime. [Remaining coverage](../drafts/findings/remaining-bind-coverage.md) states they prove the replaced architecture.

## Options

Keep all 310 green as-is; rewrite every Store test in place; or retire Recording/Store, migrate family and Calls contracts onto Host, and delete Store/Apply at the end. The user chose the last option (Q71=A, Q75=A).

## Settled Decision

Recording and Store-only accounted tests are isolated or deleted. Family and Calls executable contracts move to Host fixtures. FullRuntime and no-arg `CreateForBindings()` use Collection inject. `CreateForBindings(Store)` and the Store/Apply production path are deleted at the end of this Change.

## Consequences and Flip Condition

Old Isolation cases that require distinct TypeInfo pointers cannot remain success criteria. Historical Array AV / Calls.Native results are not claimed fixed by this talk. If a required public Store API must survive for a later inspection Change, replan; do not keep Apply as a production path.

## Visual

```text
keep: Host inject + family calls
retire: Recording, Store counts, Apply Installation
```

## Sources

Local provenance: bindings-gap-audit Q69, Q71, Q75. Canonical truth is the Change design and tasks.
