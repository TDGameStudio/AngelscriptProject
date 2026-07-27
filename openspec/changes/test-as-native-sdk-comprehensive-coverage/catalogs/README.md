# Expected Coverage Catalogs

`coverage-products.psd1` is the reviewed source of truth for finite semantic products. `scripts/ExpandCoverageProducts.ps1` expands it deterministically into `audits/expected-coverage.csv` and `audits/product-cardinalities.csv`.

The generated CSV files are audit evidence, not substitutes for tests. Every expanded row must eventually occur exactly once in native SDK source as a stable case ID and must satisfy its declared evidence layers. One broad CQTest method may own a closely related data-driven batch only when every row remains individually named and independently asserted.

## Authoring decision

The implementation uses reviewed data tables for repetitive type/value/operator inputs and explicit CQTest methods for scenario flow, setup, diagnostics, lifecycle order, callback order, and cleanup. It does not generate opaque C++ test bodies from prose. This keeps the large suite reviewable while preventing manual omission of combinations.

Every registered AS source generator calls `PrintGeneratedAsSource` exactly once for each module version immediately before compilation. Automation output uses `[AS-SOURCE-BEGIN]`, line-numbered `[AS-SOURCE]`, and `[AS-SOURCE-END]` records with stable IDs and module names. This makes successful and failing sources reviewable from retained test logs; rebuild/rebind variants are separate records.

`generated-source-registry.csv` records the owning file/class/method/product, every named builder, formatting contract, rationale, and the exact number of source-reporting call sites in that source file. A file may contain multiple independently owned products when each has a distinct method and registry row; shared source-reporting helpers still count once at file scope. Catalog validation fails when a builder is absent, the owner does not match the product, an exact owner row is duplicated, the declared reporting-site count differs from source, or a `.cpp` file that constructs AS through `AppendGeneratedAsLine`/`AppendGeneratedLine` is not registered. The count is explicit because an owner may also compile a separate hand-written negative fixture; only generated module versions belong to this registry.

Generated C++ is permitted later only for mechanically repeated case descriptors. If introduced, its input, output path, command, deterministic ordering, source formatting, and checked-in review diff must be recorded here before use. Generated line count never counts as completeness evidence by itself.

## Row contract

Each product declares:

- a stable product ID and source coverage document;
- one semantic theme and element;
- complete finite axes;
- classification and expected result;
- required evidence layers;
- a final file, CQTest class, and method owner.

Reduced products are not accepted implicitly. A product may exclude a cell only through a separately reviewed exclusion row with the exact axis values, reason, and replacement coverage ID. The initial catalog intentionally uses legal equivalence groups so most products have no exclusions.
