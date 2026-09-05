# Frontend lexer verification

## TDD sequence

- Task `1.1` expected RED build `6f6caf04f5db42abbbfe26f6ca462f2`: the new `frontend/as_character_stream.h` contract did not yet exist.
- Task `1.1` local API RED `954671d4208b457a8b4bfa440ff1c92e`: a Boolean Unicode-policy constructor admitted an engine pointer through pointer-to-bool conversion.
- Task `1.1` GREEN build `d070a67f8c0c434ca922ee70c72d773a`: frozen strong-enum options, validated character stream, token kinds, and compact source-referential tokens compiled.
- Task `1.2` expected RED build `2cece68cb7bb411d9be21821bff4a520`: session identifier-table and tokenizer declarations did not yet exist.
- Task `1.2` GREEN build `1d3889103b514a2ebb4f3733756245b5` and exact Fast test `0c649506fa7e40ffbb1b099a37037b68`: 6/6 core lexer tests passed.
- Task `2.1` expected RED build `0d7107769ee74a9f915d19889a7828a9`: structured lexical diagnostic IDs did not yet exist.
- Task `2.1` GREEN build `7bc58cd1715e4bc9b32ba99f241b293e` compiled Unicode, malformed-input, trivia, recovery, and concurrent-session behavior.
- Test runs `d1de6aab2afd498d969ac8bc27b3176a` and `6d30f313de324ed89c825e08acef71f3` exposed only CQTest representation ensures in the new range-equality assertion. The assertion was reduced to supported scalar fields without changing production behavior.
- Task `2.1` repaired build `e7c60165d4ea48439cb3f41a26e67aea` and exact Fast test `4e29fd17bd0a44c693f50d52268a7f21`: 11/11 passed with zero warnings and errors.
- Task `3.1` measurement build `d5d303db4568426395d702726bab78d1` and exact Fast test `bc2097f7758d456eb34c5835016b5d9f`: 12/12 passed and emitted the indexed cold/warm evidence.
- Final incremental build `b4b2d64ee293432385456788b45a6e6b`: succeeded, exit 0, 1,439 ms managed duration.
- Final exact Fast test `fb0813c4e6d2487d8f86aa2ceaaa26f0`: 12/12 passed, 0 failed, 0 skipped, 0 not-run, 0 warnings, and 0 errors.

The final Automation report is `Saved/Harness/Unreal/Runs/fb0813c4e6d2487d8f86aa2ceaaa26f0/AutomationReport/index.json`; its complete public scope is `Angelscript.UnitTest.NativeEngine.Lexer.*`.

## Final content identity

| File | SHA-256 |
|---|---|
| `frontend/as_frontend_options.h` | `8fb04eb35f533ac16e60ecea484ee0682ca9ce747d5823685c38d956e2a80ebb` |
| `frontend/as_character_stream.h` | `b5b943123b0bd9629be5f078f2c865a1e1878a761037676a8ab2bf11a2e9cca9` |
| `frontend/as_token_kinds.def` | `644a5e36da040b91848e66793287ec25a964c1155f81ba0f4c63292608abc5da` |
| `frontend/as_token.h` | `c4fada888efc529f63c25135a306e81d7f6dbda6a0eec7a803750f11c08a9323` |
| `frontend/as_identifier_table.h` | `099dcb722b808d458e5f5dca586092d8f7f5d8e371e9a2a3e6a18c99054cd0d0` |
| `frontend/as_identifier_table.cpp` | `baf2de50cf5a9437998671b6434139192021f1bec0f1c79232b6505b4ad422d6` |
| `frontend/as_tokenizer.h` | `0e424d2ad7e9b0c19a2fc85e7d79f78e44b23b44925a8478c469b2172f55f1b9` |
| `frontend/as_frontend_tokenizer.cpp` | `9c6f928cbb78e88b3ca57f9f9cddf756f1e92e4cd2ae7a3a80b54fff662156b9` |
| `LexerTests.cpp` | `d6ddab3f0a71a7c822456b0c1d497bc4cc9f5d2ba3faa1f483fa75ec4f323f23` |
| current `lexing/spec.md` | `df726ac810885b08e077611258d2e970834d3220e2f63d7c04c6ad22419c2eee` |

## Durable contract and knowledge

- CLI-created capability `angelscript/language/frontend/lexing` contains all five requirements without delta-operation headings.
- `lexing/knowledges/clang-lexer-hot-path.md` retains the adopted Clang ownership/layout lessons and explicit non-goals.
- Strict active-Change validation passed 1/1; strict all-current-spec validation passed 9/9.
- OpenSpec doctor reported valid with zero diagnostics, and status reported apply progress 5/5 with archive ready.

## Impact boundary

The new API is compiled and tested but has no production Parser, Builder, Engine, preprocessor, reflection, VM, or Standalone consumer. `import` is not introduced as a keyword. Harness aggregate profiles, full UE suites, Standalone, legacy tokenizer/parser tests, upper Runtime tests, and UE product builds were intentionally omitted because the exact editor target and complete isolated Lexer prefix prove the changed boundary.

One non-reproduced Harness caller-envelope observation is retained as an evidence-backed rejected issue. It did not hide managed run evidence and does not invalidate lexer verification.
