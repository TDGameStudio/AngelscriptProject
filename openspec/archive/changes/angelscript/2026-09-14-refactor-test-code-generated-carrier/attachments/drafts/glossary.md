# Generated C++ Carrier Glossary

Source identity: faithful English export of the approved `generated-cpp-carrier` glossary. Names were settled by the 2026-09-14 design rounds, inspected existing APIs, and the user's explicit authorization to choose a convention-compliant Change name.

| Name | Kind | Meaning and provenance |
|---|---|---|
| `angelscript/refactor-test-code-generated-carrier` | OpenSpec Change ID | Derived from the project `<domain>/<type>-<scope>-<outcome>` convention under delegated naming authority. |
| `AngelscriptTestCode/` | author root | Confirmed; contains authored `.as` test fixtures. |
| `AngelscriptTestCode/CodeGenTool/` | tool root | Confirmed; the complete subtree is excluded from fixture discovery. |
| `codegen.py` | public Python entry | Confirmed thin entry that delegates to the CLI module. |
| `angelscript_test_codegen` | Python package | Convention-derived modular implementation package. |
| `generate` | CLI subcommand | Confirmed sole writer of the generated root. |
| `check` | CLI subcommand | Confirmed read-only comparison of expected projections and disk state. |
| `build_sync_plan()` | Python function | Confirmed shared computation for missing, changed, and stale state. |
| `Plugins/Angelscript/Source/AngelscriptTest/TestCode/Generated/` | generated root | Confirmed root for mirrored `.generated.cpp` projections. |
| `<relative-source>.generated.cpp` | projection rule | Confirmed mapping, for example `Language/Counter.as` to `Language/Counter.generated.cpp`. |
| `FileTag` | logical fixture identity | Existing contract: authored relative path without `.as`, such as `Language/Counter`. |
| `FAngelscriptTestCodeRegistration` | C++ registration seam | Existing public type shared by generated and handwritten providers. |
| `FAngelscriptTestSourceParser::Parse` | C++ parse seam | Existing public function that parses raw `.as` container bytes at activation. |
| `AS_TEST_SOURCE` | handwritten C++ source macro | Existing public macro retained for handwritten registration. |

No public name is introduced for a runtime generated aggregate, numeric resource ID, module-private batch bridge, or runtime generated index.

