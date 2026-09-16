## Why

The Language corpus has 122 documented generator products and 36,686 declared filtered cells, but only FForLoopGenerator exists in the replacement framework. The earlier three-product handoff incorrectly narrowed the whole delivery to an initial batch. Consumers need all documented products to generate source without reviving the dormant language runtime.

## What Changes

- Deliver all 122 products, retaining and verifying the existing ForLoop baseline and implementing the other 121 products in the owning plugin.
- Provide deterministic typed single-case generation, non-reject aggregate modules, separate reject modules and the documented observation contracts.
- Preserve the complete per-product catalog, explicit host dependencies, fault classifications and limited numerical observations.
- Add bounded C++ generator proofs and an aggregate 122-product/36,686-cell completeness gate. Generation tests do not compile or execute AS.

- Add owned per-case enumeration with exact entry declarations, typed expected outcomes and explicit execution support, plus canonical single-case generation by CaseId.

- Use PascalCase canonical entry names without underscores. Each generator has one unit test that exports all cases in one readable .as dump beside its current test log.

## Capabilities

### New Capabilities

- `angelscript/testing/language-generators`: reusable deterministic Language source generation, category separation and explicit observation boundaries.

### Modified Capabilities

None. Existing code-database projection remains separate.

## Impact

Implementation belongs to the Plugins/Angelscript submodule, in AngelscriptTest Framework/Generate and FrameworkTests/Generate. The parent repository owns this Change and its source catalog. Source/AngelscriptProject stays minimal. Excluded: the separate 47-container hand-authored corpus, codegen.py changes, enabling Legacy, Builder/VM execution, generic recipe engines, commits and publication.
