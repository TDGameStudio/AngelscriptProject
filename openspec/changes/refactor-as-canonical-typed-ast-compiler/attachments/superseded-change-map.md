# Superseded change absorption map

`refactor-as-primary-engine-typed-ast-generate` is superseded in full after this replacement record validates. It is archived with `--skip-specs`, so none of its competing TypedHIR deltas are merged into current specs.

| Superseded task area | Replacement owner in this change |
|---|---|
| Cache V2 `TypedHIRSidecar` codec and remap | Canonical AST Cache V2 DTO and `ASTBodySidecar` milestone |
| Primary Engine optional HIR capture | Module AST retention policy and retained snapshot milestone |
| Hot Reload HIR replacement | Atomic module/snapshot publication and lease milestone |
| Process-global native-form recipe catalog | Primary Generate/native-form milestone, unchanged in intent |
| Matching-profile primary Engine Generate | `as-primary-engine-typed-ast-generate` delta using retained canonical AST |
| Non-matching profile generation Engine | Contained one-Engine-per-profile canonical AST generation path |
| Editor/commandlet batch generation | Shared sequential generation helper milestone |
| HIR dump behavior | Public/internal canonical AST snapshot dump and diagnostics milestone |
| Capture mismatch/fallback | AST retention/profile validation plus existing TypedASTJIT/BytecodeJIT/VM fallback |
| Final build/cache/StaticJIT/Standalone gates | Final verification milestone in this change |

The completed `feature-as-typed-semantic-aot` change remains the semantic and test baseline. Its HIR layout is not the target architecture, but its evaluation order, call provenance, cleanup, verifier, eligibility, routing, dependency, exception, and fallback requirements are carried forward.
