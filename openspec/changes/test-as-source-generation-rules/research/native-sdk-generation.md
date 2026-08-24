# Native SDK Source Generation Research

## Authoritative records

- `openspec/changes/test-as-native-sdk-comprehensive-coverage/catalogs/generated-source-registry.csv`
- `openspec/changes/test-as-native-sdk-comprehensive-coverage/audits/product-cardinalities.csv`
- `openspec/changes/test-as-native-sdk-comprehensive-coverage/catalogs/coverage-products.psd1`
- the referenced `Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/**` methods and generator helpers

The registry contains exactly 271 source-producing products. Every ProductId joins to a cardinality row, and their `ExpandedCells` sum to 45,760. These are the generation-rule baseline; all 320 products in the broader cardinality table are not automatically source generators.

## Theme distribution

The 271 registered products cover Frontend (38), Operators (25), Engine (23), Runtime (20), Functions (19), Compiler (17), TypeSystem (13), ControlFlow (11), Conversions (11), NativeDebug (10), Module (10), Properties (9), Embedding (9), Expressions (9), Variables (8), Constructors (7), References (7), Inheritance (5), Exceptions (4), Foreach (4), Declarations (3), Destructors (3), Conformance (2), Runtime.Debug (2), CrossTheme (1), and Future238 (1).

This breadth answers the question “besides definitions and SDK expressions, what can be generated?” The existing suite already demonstrates finite products for:

- declaration family/scope/order/collision/recovery;
- parameters by type/direction/position, signature arity/pattern, return and transfer;
- operators, assignments, conversions, lvalue/rvalue/reference relations, evaluation paths;
- variables, properties, constructors/destructors, inheritance, foreach, control flow, exceptions;
- frontend token/parser/source-position/diagnostic forms;
- compiler builder stages, layout, bytecode, lifecycle, collisions and recovery;
- runtime execution, exception, context, ownership and cleanup behavior;
- module/import/bind/save-load/rebuild/isolation states;
- type IDs, declarations, layouts, ownership and reference release;
- embedding API state/arguments/results;
- debug line/frame/trace shapes.

## What the new rule captures per product

`catalogs/sdk-generated-product-rules.csv` preserves, for every exact ProductId:

- legacy file/class/method/helper;
- theme, axes, cardinality, classification, evidence, and formatting contract;
- recipe family and future static symbol;
- generated AS scope and complete oracle scope;
- fixed exhaustive inputs and controlled random slots;
- constraints that keep cell membership and semantics frozen;
- negative single-mutation and recovery policy;
- case-specific comment knowledge and references;
- `PlannedNoReplacement` status.

## Product granularity

The SDK registry is product-level, and release code should remain product-level. One product such as parameter direction may contain dozens or hundreds of cells, but its generated C++ API is one static function returning a result that contains those cells. This avoids 45,760 C++ entry functions while preserving complete enumeration and per-cell CaseKeys/oracles inside the result.

## Oracle depth rule

The legacy generator helper name alone is not enough. Rule implementation must read the owning test and preserve its full evidence:

- compilation and exact diagnostic anchors;
- metadata/publication/type/layout/bytecode observations;
- typed returns, parameter transfer, out/inout writeback, side-effect counts;
- exception/lifecycle/cleanup/ownership/isolation;
- module/import/save-load/rebuild/recovery.

The catalog provides the implementation starting point, and each product's paired tasks require exact owner review and parity tests before a rule can pass.

## Adoption conclusion

All 271 products are planned as additive generation rules, but none of their current C++ builders is replaced here. Later adoption can proceed product by product after source/manifest/oracle parity and UE behavior evidence exist.
