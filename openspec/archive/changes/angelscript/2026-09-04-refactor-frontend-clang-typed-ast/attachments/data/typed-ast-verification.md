# Typed AST verification

## Focused TDD sequence

- Task `1.1`: expected missing-header RED `1ce695a0bcff42caaf64703608f90cf7`. UBT planning run `9b7e1592c792482abefa8d343b6ed6d7` then proved duplicate implementation basenames and triggered the indexed path-only Replan. GREEN build `a66f428a0e7a400a9145db28b78512a3` and AST run `fe5503aaa0b4489597b11be39809eded` passed 6/6.
- Task `1.2`: expected missing Type/Attr RED `5a60623d95684f52919ded42b90ff3db`. GREEN build `d7327f2e3e9547f780974904b3508dac` and AST run `855be341865244d1b6347d47a78972d2` passed 12/12.
- Task `2.1`: expected missing context RED `4a68434c547645b59c2097952033848d`. GREEN build `213a0e5bad614f6e9267baba3a7ab087` and AST run `932cb00c4014428cbd8e4afee16b18ad` passed 18/18.
- Task `2.2`: expected missing visitor/verifier/projection/codec RED `8c9de0442587494dbcff9a811e602fd2`. GREEN build `e888d5ff97df4b378bc7b32137dc2ae7` and AST run `3fb0ab496ce14dd081ea322f7ae2241e` passed 30/30.
- Final build `485f1c8a199b42d49db165a1295c6d11` succeeded. Final exact Fast run `0c144438537f41f3be1bff63b5bbc99f` passed 30/30 with zero failures, skips, warnings, or errors. Report: `Saved/Harness/Unreal/Runs/0c144438537f41f3be1bff63b5bbc99f/AutomationReport/index.json`.

## Verified surfaces

- Genuine concrete Decl/DeclContext and `Stmt -> ValueStmt -> Expr` families with family-aware casts and compact representative layout checks.
- Canonical Type forms, compact non-node QualType, authored TypeLoc, stable-identity witnesses, ordered generic arguments, and typed Attr targets.
- Context-owned type-erased destruction, source snapshot lease, owner-scoped handles, context-local type uniquing, and one-way seal mutation rejection.
- Deterministic owning traversal and separate cross-reference hooks; exact rejection of foreign nodes/ranges, duplicate edges, cycles, missing children, and reachable recovery.
- Immutable flat projection and deterministic version-2 pointer-free codec with old/unknown version, truncation, invalid-index, witness, runtime-state, and budget gates.

## Representative final content hashes

| File | SHA-256 |
|---|---|
| `as_ast_context.h` | `47c274e65234b74eae8027cde1feedc6ec478b0c35d839a298c8d8e6d6c3bfc7` |
| `as_frontend_ast_context.cpp` | `5135ccd1b4147dd40d67af827012d26bd871b85ef6d369a9baa2fe0f3e1562b6` |
| `as_decl.h` | `9c93cc6f26b66c909c5ccdffef46cf12db2ae07aeb57c4199671012efe462f29` |
| `as_stmt.h` | `e895996fcf7afa3532c48129303fc330b1c0f12ba7c2d01a69e1104de4afadfb` |
| `as_expr.h` | `c5c4cb30502f54cbcfc601e2626d9010b057d05facdcb54eaf6020bea6c1b1ae` |
| `as_type.h` | `857dfeb4f38e40e02689aadad7ffc65b122e958ac3621ef6e69a7227f34fef94` |
| `as_attr.h` | `29869055d8e9cb430eca0d91e9fc26740ab4617a805e9ad3b73038a31beb292f` |
| `as_ast_visitor.h` | `20f2ab727bdefac91b8fb94fb37ff9a94d17d8127f491690d5129bc97b9febdf` |
| `as_frontend_ast_verifier.cpp` | `a7f364e207eacc756274914a044f2b70bb697019e0864e8dc3dd6f6cc41a660c` |
| `as_ast_projection.cpp` | `b96be02a602fc1da10982661fb7d4624ef6cbc90ea0676a2a00974dbdcc7f2f8` |
| `as_ast_codec.cpp` | `16e9c5aa75f47c9ac1590e9d73129c4a982cd42349b3378d62d383edfda5cf6c` |
| current `ast/core/spec.md` | `0687be850c946ce553ae8edece1971c1afc3b6d493c475a9817257baccd58e72` |

## Lifecycle and scope

Strict Change validation passed 1/1 and strict current-spec validation passed 11/11. Doctor `dd9dc75c83bb449ca022545a3a77836c` reported no diagnostics; TaskPlan `c9fa213d4b5e469f8d694557114b9afb` reported 7/7 complete. The full delta and promoted knowledge are synchronized into `angelscript/language/ast/core`.

Aggregate Harness profiles, full UE suites, Standalone, production Parser/Builder, old sidecar tests, reflection, bytecode, and VM tests were intentionally omitted. The Change is an isolated AST authority with no production consumer and an intentionally incompatible codec; the Editor build plus complete 30-test AST prefix directly cover its impact.

