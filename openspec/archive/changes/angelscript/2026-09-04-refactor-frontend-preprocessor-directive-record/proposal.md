## Why

The reconstructed frontend needs conditional compilation without inheriting the C preprocessor's textual macro system. The current runtime preprocessor blanks directive and inactive text while chunking, so later AST and tooling consumers cannot reconstruct the full `#if` tree, distinguish taken and skipped branches, or reliably ask which conditional region affected a source range.

Clang demonstrates that typed AST nodes and preprocessing information should remain separate queryable products. Its `PreprocessingRecord` and conditional-region record are useful precedents, but neither is a complete inactive-source syntax tree. AngelScript therefore needs a smaller language-owned model that preserves every conditional branch while routing only the selected branch to the parser.

## What Changes

- Add a frontend-owned conditional preprocessor under the new isolated `source/frontend/` boundary.
- Accept the frozen UTF-8 source snapshot, raw token stream, and frozen flag configuration produced by prerequisite frontend stages.
- Parse `#if`, `#ifdef`, `#ifndef`, `#elif`, `#else`, and `#endif` into a complete directive tree with exact source ranges, parentage, branch evaluation, and skipped ranges.
- Preserve `#restrict usage allow/disallow` as a typed directive record with validated arguments, and reject `#include` without suggesting `import` as a replacement.
- Produce a deterministic active token stream plus snapshot-local preprocessing records and range-query APIs for AST/tooling backquery.
- Keep inactive source as raw syntax and token ranges rather than manufacturing typed AST nodes for mutually exclusive branches.
- Allow the ThirdParty implementation to use Unreal core value/container types such as `FString`, `FName`, `TArray`, `TMap`, and `TSharedPtr`; the same-module boundary does not require a host-neutral DTO rewrite.
- Diagnose malformed conditional structure and unsupported preprocessing directives without publishing partial frontend state.

## Capabilities

### New Capabilities

- `angelscript/language/frontend/preprocessing`: Deterministic conditional token routing, complete directive records, skipped ranges, and snapshot-bound source backquery.

### Modified Capabilities

None.

## Impact

The implementation belongs to `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/` with replacement tests under `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Preprocessor/`. It consumes contracts from `angelscript/refactor-frontend-source-diagnostics-model` and `angelscript/refactor-frontend-lexer-token-pipeline`, and its CQTest work consumes the isolated foundation from `angelscript/refactor-native-engine-test-foundation`. Those are coordinator-managed cross-Change prerequisites, not dependencies in this Change's local Task DAG.

This Change does not implement `#define` or function-like macro expansion, module dependency discovery, UE reflection descriptor production, UHT policy, code generation, or live `FAngelscriptEngine`/`UObject` publication. The reconstructed architecture does not use or generate `import`; reflection and dependency projection remain owned by `angelscript/refactor-preprocessor-reflection-dependency-output` after Parser and Sema have produced typed declarations.
