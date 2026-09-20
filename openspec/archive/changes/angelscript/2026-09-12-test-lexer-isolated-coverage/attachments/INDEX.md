# INDEX

## Current position

All four tasks and completion verification are green. Both durable deltas are synchronized into strictly valid current specs, the reusable lexer-test guidance is promoted to lexing capability knowledge, and the Change is ready for completed closure.

## Hard conclusions

- Populate the reserved `TestFramework/NativeEngine/NativeEngineTokenizerTest.h/.cpp` pair with Lexer-only `LexerTest::FNativeEngineTokenizerTest`; leave sibling placeholders untouched.
- Own test bytes/names/descriptions with `std::string`, collections with `std::vector`, stable run state with `std::unique_ptr`, and expose `std::string_view` / `std::span`; UE/product adapters stay explicit at their boundaries.
- Inputs are named `FromText(FStringView)` and `FromUtf8Bytes(std::string_view)`.
- Each CQTest scenario class stays global, privately aliases only the `LexerTest` helper types it uses, and restores `public:` before `TEST_METHOD`; no helper import or alias leaks to file/Unity scope.
- Tests live in `AngelscriptTest/NativeEngine/Lexer/` as `Contracts`, `SpelledKinds`, and `Recovery`; the 17 current methods move and one stable empty/pure-trivia EOF contract is added.
- One primary EOF stays in captured tokens and one separate repeated-EOF probe retains the current sticky-terminal assertion.
- The spelling walk executes 107 rows; fixed `0xa912c3f84387564e` independently anchors 115 kind/spelling rows; a casing matrix freezes keyword policy.
- Recovery keeps the bounded 16-row malformed generator and adds exact source/buffer-edge/Unicode/CRLF/Raw parity checks.
- Leading `EF BB BF` is three-byte whitespace. Task 1.3 observes the current Unicode diagnostic RED before repairing live `frontend/Lexer/as_tokenizer.cpp`.
- Generic TestCode, source catalogs, typed rows, artifacts, and reusable generators remain owned by `angelscript/refactor-testing-unified-framework`.
- Normalize only Scenario Card ownership indentation in the affected current lexing and testing-baseline specs before sync; preserve every word, ordering decision, and parent relationship.
- The isolated pull-lexer oracle guidance is verified reusable and promoted to `angelscript/language/frontend/lexing/knowledges/isolated-lexer-test-oracles.md`.

## Forbidden

- Do not wrap `TEST_CLASS_WITH_FLAGS` in a namespace, add a namespace-wide using-directive or file-scope helper alias, or retain `TEST_CLASS Lexer` after TestDir nesting.
- Do not dynamically register generated negative rows or derive their expected output from tokenizer output.
- Do not edit `angelscript/refactor-testing-unified-framework`, add `AS_TEST_SOURCE`, or create a competing generic frontend fixture.
- Do not import Clang macro provenance, token splitting, lookahead/navigation, preamble/header/module, or C/C++ line-splice behavior into this tokenizer Change.
- Do not freeze ordinary string/newline recovery, CR-only line policy, non-BMP identifier categories, or malformed bytes inside comments/strings in this Change.
- Do not edit historical findings/talks/replans to rewrite superseded counts, namespace/import choices, or string-container decisions.

## Attachment index

- drafts/design.md — approved creation-time lexer-slice design; historical input superseded by current `design.md` and replans — consult for original rationale only
- drafts/handoff.md — creation-time Change identity and task boundaries — consult when tracing provenance
- drafts/glossary.md — creation-time names (`FLexerSource`, `CheckLex`, two classes); current names supersede them — consult when tracing naming evolution
- drafts/findings/lexing-overview.md — Lex chapter entry — load when explaining the product lexer
- drafts/findings/lexer.md — tokenizer implementation and RawDirective-as-Retain evidence — load when wiring `Lex`
- drafts/findings/lexer-tests.md — historical inventory says 16; live TU has 17 — load when moving Contracts
- drafts/findings/lexer-kind-matrix-plan.md — creation-time spelling walk; its self-oracle claim is superseded by the fixed fingerprint — load when writing SpelledKinds
- drafts/findings/lexer-change-scope.md — original in/out and landing options — load when tracing scope evolution
- drafts/findings/lexer-design-names.md — creation-time Contracts/CheckLex rationale — load only for naming provenance
- drafts/findings/test-prefix.md — why TestDir must nest — load before public identities
- drafts/findings/test-helper-namespace.md — historical helper namespace and first class-scope alias choice; current exact alias sets supersede it — load only for decision provenance
- drafts/findings/clang-lexer-tests.md — historical Clang comparison with 12-file error; superseded by current fixed coverage map — load only for the first comparison
- talks/talk-20260912-114500-helper-and-test-layout.md — TestFramework vs NativeEngine/Lexer split — load before moving files
- talks/talk-20260912-114500-lexer-public-names.md — Contracts/SpelledKinds names; Recovery was added by the first replan — load for name history
- talks/talk-20260912-114500-kind-matrix.md — spelling walk stays inside a few static methods — load before SpelledKinds
- talks/talk-20260912-114500-no-testcode-in-this-change.md — generic TestCode stays outside this Change — load before source wiring
- talks/talk-20260912-122229-unified-tokenizer-test-boundary.md — lexer-only fixture/oracle/generator seam; namespace and no-std conclusions superseded — load for first replan provenance
- talks/talk-20260912-130915-std-helper-and-cqtest-using.md — standard-library ownership retained; file-scope import decision superseded by the Unity-safe alias talk — load only for decision provenance
- talks/talk-20260912-133353-unity-safe-class-aliases.md — current exact class-scope alias boundary and CQTest access shape — load before task 1.1
- knowledges/isolated-lexer-checklex-matrix.md — promoted: std-owned isolated run, independent oracle, separate repeated EOF, bounded recovery; generalized into lexing capability knowledge
- data/planning-validation.md — current three-part plan self-review — load when judging coverage, placeholders, symbols, or oracle validity
- data/clang-lexer-coverage-map.md — fixed LLVM/Clang 22.1.8 inventory, mapping, BOM evidence, accepted gaps, and exclusions — load before task 1.2 or 1.3
- data/completion-verification.md — final source identity, Automation results, structural checks, strict validation, spec-sync disposition, exclusions, and knowledge disposition — load for closure evidence
- data/completed-closure.yaml — requested completed-closure manifest supplied to the deterministic archive command
- `data/workflow-evaluation.md` — canonical completed-lifecycle evaluation bound to the final active Change input digest
- replans/replan-20260912-123336-unified-tokenizer-test-boundary.md — first applied three-task replan — load only when tracing plan evolution
- replans/replan-20260912-130915-std-cqtest-clang-gaps.md — applied std/import/coverage/BOM/path replan with base/result hashes — load only when tracing current plan evolution
- replans/replan-20260912-133353-unity-safe-class-aliases.md — applied Unity-safe alias replan with unchanged Task DAG — load before implementing any scenario TU
- replans/replan-20260912-142757-current-spec-indentation-prerequisite.md — applied verification-driven formatting prerequisite and task 1.4 — load before spec synchronization
