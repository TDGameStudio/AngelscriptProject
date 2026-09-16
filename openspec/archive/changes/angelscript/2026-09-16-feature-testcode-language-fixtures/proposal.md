## Why

The public author tree still contains only the demonstration Language/Counter fixture, while reusable hand-written language scenarios remain in the legacy tree. The accepted design calls for 47 focused complete-version containers, separate from the 122 C++ generator products.

## What Changes

- Migrate all 47 accepted FileTags across Operators, ControlFlow, Casting, Namespace, Syntax and Preprocessor; put Const under Syntax.
- Preserve positive and negative source variants with valid v1 container metadata and explicit legacy-source dispositions.
- Generate the corresponding checked-in structured C++ projections with the existing tool.
- Replace production Counter with Syntax/StructFields in real database integration tests, preserving private tool/parser fixtures and their annotation coverage.
- Update authoring examples and verify the whole corpus through one compiled-database dump method and one independent authored-source byte comparison, with two aggregate .as artifacts beside the run log. No per-container C++ tests or AS execution are added.

## Capabilities

### New Capabilities

- `angelscript/testing/language-fixtures`: reusable hand-authored core-language source containers and their database identities.

### Modified Capabilities

None. The existing code-database API and projection grammar are retained.

## Impact

Parent repository: AngelscriptTestCode/Language, bounded CodeGenTool test-fixture maintenance and angelscript-test Skill examples. Plugins/Angelscript submodule: generated carriers and Framework database integration tests. The sibling generator Change is independent; no old source tree is moved or deleted and no host project behavior is added.
