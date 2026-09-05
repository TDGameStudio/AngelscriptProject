# INDEX

## Current position

All six tasks are complete. The dormant facade returns one atomic resolved result with retained preprocessing/AST leases, concrete descriptors, typed declaration dependencies, a separate body graph, and structured failure diagnostics; durable spec and knowledge ownership are synchronized. Completion verification and archive gates remain.

## Hard conclusions

- `asCPreprocessor` returns the concrete `FAngelscriptPreprocessResult`; the Change adds no generic reflection IR or DTO.
- The same typed Parser/Sema `Decl`, `Attr`, and type-use facts populate both the AST and the existing concrete descriptor family.
- Descriptor state stops at `Resolved`; every Runtime and UE materialization pointer remains null.
- Declaration dependencies retain reason, source range, and completeness, use SCCs for cycles, and remain separate from body invalidation facts.
- The existing descriptor family has one shared UE-aware definition, and the dormant Runtime preprocessor remains untouched.
- New fork-internal leaves use `source/frontend/` plus the lowercase `frontend` namespace inside `BEGIN_AS_NAMESPACE`; names are final and never suffixed `V2`.

## Forbidden

- Do not add a regular-expression or chunk-based declaration authority, generated or inferred `import`, string-spelling dependency repair, or generic annotation property bag.
- Do not create UObjects, attach Runtime pointers, publish to `asCScriptEngine`, or route production compilation to the new facade in this Change.
- Do not promote the assembly-oriented material in [Temp reconstruction transcript 1](../../../../../Temp/as%E5%A4%A7%E9%87%8D%E6%9E%84/1.md), lines 1-1400, or unverified Temp claims about legacy dependency sorting.

## Attachment index

- `talks/talk-20260905-010721-direct-descriptors-and-dependency-authority.md` — Settles direct FDesc projection and typed dependency authority while recording rejected alternatives and flip conditions — read before changing the result or consumer boundary.
- `knowledges/semantic-events-to-reflection-and-dependency-graphs.md` — promoted — Generalizes how one semantic event stream can feed host descriptors and source-aware dependency graphs without duplicate parsing; the durable copy is owned by `openspec/specs/angelscript/language/frontend/reflection-dependencies/knowledges/`.
- `data/workflow-evaluation.md` — passed — Canonical completed-closure evaluation covering lifecycle friction, focused verification, durable sync, and intentionally omitted heavy suites.

## Verification evidence

- Initial contract build `c434f01fd6d1443bbfe1febbac4cca68` reached one test-only `TSharedRef` API compile error; this ordinary local defect was fixed without changing planning truth.
- Intermediate contract build `093b121e2bf446a5aec86117106c71e9` passed after the test correction.
- Physical single-owner extraction build `c59c27a51aec49fe91221782d287777c` passed after removing the quarantined definitions from `AngelscriptEngine.h`.
- Final exact Task `1.1` build `20108c9915bc43508165eef08f74b613` succeeded against the current descriptor/result/test content.
- Expected Task `1.2` RED run `245834968ab447459383210cc26cab55` discovered all 12 focused tests: the header single-owner proof passed, while 11 descriptor-result, graph-finalization, SCC, separation, and deterministic-order scenarios failed with zero skips or warnings. Report: `Saved/Harness/Unreal/Runs/245834968ab447459383210cc26cab55/AutomationReport/index.json`.
- Task `2.1` compile attempts `4960a8a2d7084ea7b2d8860d956d55b4` and `c86c80174de74934888de6e7c98c5c77` exposed only local `FStringView` and `TSharedRef` API mismatches. Exact build `41a632612b044d538b245793a3b079d5` succeeded after those ordinary corrections; planning truth was unchanged.
- Task `2.2` build `6c597071d6c24c609f70d77e7145cb28` exposed a unity-build-only collision between two anonymous-namespace `HasAttr` helpers. Renaming the graph-local helper fixed the ordinary implementation defect; exact build `24ab60e9d14a465d8181c1d3905debaa` then succeeded with all five UBT actions complete.
- Expanded RED build `63b654f7bc6849ba8f4b3642913c3a1b` succeeded, and focused run `758f475e3d564db4a4678af5f42da0fd` left exactly seven facade/reflection behaviors failing, including enum/delegate projection and type-use-derived dependency assembly.
- Task `3.1` final build `c2d99017077647a581b33517159983fa` succeeded. Its immediately following focused run `3cda9a15092f4f6db860f6e265447540` passed all `14/14` Reflection and ModuleGraph tests with zero warnings, errors, or skips; report: `Saved/Harness/Unreal/Runs/3cda9a15092f4f6db860f6e265447540/AutomationReport/index.json`.
- Because the implementation also touched shared identifier classification, declaration Parser/Sema, and record type-kind, adjacent run `8f0007d3679e4357a96db5475add06a5` passed all `37/37` Lexer, Declarations, and Bodies tests with zero warnings, errors, or skips.
- Harness `Quick`, `Performance`, `Integration`, complete UE suites, Standalone, and dormant legacy tests were intentionally omitted: this Change is bounded to the isolated reconstructed frontend, has no performance or cross-product integration contract, and does not route production compilation.
- The new `angelscript/language/frontend/reflection-dependencies` capability was created through OpenSpec and synchronized with all five verified requirements. Strict Change validation `ad54eb7c9e4e4fa784c4cbb8afbb72f9` passed `1/1`; strict current-spec validation `e575f2c2ca9c4e0eb8537ea9fdf11707` passed `14/14`.
