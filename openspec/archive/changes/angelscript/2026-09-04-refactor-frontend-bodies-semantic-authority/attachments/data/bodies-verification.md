# Body semantic authority verification

## Focused TDD sequence

- Core RED build `12f4922a5989492ea25bdbf6cc09d954` established the missing body-fragment contract.
- Core GREEN build `aec0f388f26c48baa77c14f9d9555028` and focused run `c84562db6760410abee4b8e5b2676684` passed the first 6/6 body scenarios.
- Finalization RED build `b5f1c6f953c34c9cb0ef047085c308da` failed only on the deliberately missing lifetime/exit API.
- Intermediate build `270358ec15e5450fa02bcf23657bb086` exposed one incorrect return-target base type and was repaired locally without changing the plan.
- Finalization build `11bd0780ccf14fadadba5c87ff365546` and exact run `d510ad200ccd4df497c71f9aafcfaa89` passed all 13/13 Bodies tests.
- Because body semantics changed shared typed-AST layout and traversal, focused adjacent run `35c219b766e74afdbbbaaff7ad8f3a60` was added. It exposed one pre-existing 64-byte representative-node layout contract violation.
- Corrective build `1549860d7e2c416fb4d046654069125c` succeeded after packing AST state and expression type/value-category semantics rather than weakening the contract.
- Current exact Fast run `c5586e74431142fc83eeb7c8b6fce687` passed 13/13 Bodies tests, and adjacent exact Fast run `297960d708b54c50913f6d77af8d7ed9` passed 30/30 AST tests. Both report zero warnings, errors, failures, skips, or incomplete tests.

## Verified surfaces

- Body parsing is deferred until the declaration universe is frozen and resolved.
- Parser and Sema produce concrete typed statements/expressions with node-owned types, value categories, explicit conversions, call targets, return/control targets, and source ranges.
- Later-file and mutually recursive calls resolve through stable declaration semantics without live Engine or Builder state.
- Source-language construction and reverse cleanup obligations are explicit before lowering; invalid construction never enters cleanup.
- Malformed bodies retain recovery nodes and diagnostics without suppressing later valid functions.
- Reversed source submission and one-versus-four worker requests produce equal stable body and diagnostic projections.
- Invalid declarations prevent executable body authority; no bytecode, runtime object, JIT, or VM publication occurs.

## Representative final content hashes

| File | SHA-256 |
|---|---|
| as_compilation_session.h | `3fb16ed41167a97bfd4a8d438f8cc50b3143ba0ebd6885fb83c89dde0d1e29c9` |
| as_compilation_session.cpp | `c4db3d95bb346998ff06c9723629bc64ca9a5220018a453d2b939ab9c450711c` |
| as_decl.h | `363ee082fe4a5c66f494fbea11c9668e5d0242c401b2ed5936a8341504c1804a` |
| as_stmt.h | `31a1b16e509affcbcf109549ceb31b27bbd24f0882dd6c3347f0652912b1f0da` |
| as_frontend_parser.cpp | `a03c622b3fa2597940512910b6a92f6230e0a6fdda267bde13d50c9fd0bb5215` |
| as_frontend_sema.cpp | `a1ae4af03293f52d3acc1b39cc4abb7b8ead33f70599f16713c242a9e22b8aec` |
| BodySemanticTests.cpp | `bc88236de8cbb6bc329b2228c13d5c5858145e15dd7a8613a53d531b4c2d63c5` |
| current bodies spec.md | `5e102f14d33078ca3cd503badc68d74cd8e006031b4a29f6c128e74eaa50bef4` |

## Scope

The complete delta and accepted deterministic-body-fragment knowledge are synchronized into `angelscript/language/frontend/bodies`. The adjacent AST prefix was added because this Change directly modified shared AST layout and traversal.

Strict Change validation `4a78acbed99a4ea5b4c95a8a3e7a329b` passed 1/1. Strict current-spec validation `b204a4340e6846a0875ab98f43dbc3a5` passed 13/13. After the task and evidence records were finalized, strict Change validation `0ce4a65756eb49c09c139c8e34f029d3` again passed 1/1 and strict current-spec validation `e79a28622ff7454eb20d6a51924a138a` again passed 13/13. Doctor `80c7512e100b4869ba6208c4e7a84b94` returned zero diagnostics, and TaskPlan `94465a21d53d46718cd799b0e1195c0e` reported 5/5 complete.

Aggregate Harness profiles, full UE suites, Standalone, retained production Parser/Builder, reflection generation, bytecode, JIT, and VM tests were intentionally omitted. This Change stops at the isolated typed-body frontend, so the Editor build plus complete Bodies and adjacent shared-AST prefixes are the smallest complete proof.
