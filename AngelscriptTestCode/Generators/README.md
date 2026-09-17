# Language generator rules

Author-facing product rules for the 122 Language source generators. These Markdown files are not part of the ordinary `.as` projection and are not generated dumps.

## Layout

Each theme folder holds one rule file per product ID:

| Theme | Folder | Products |
|---|---|---:|
| ControlFlow | `cf/` | 11 |
| Operators | `op/` | 25 |
| Expressions | `expr/` | 10 |
| Conversions | `conv/` | 11 |
| Functions | `fn/` | 19 |
| Variables | `var/` | 8 |
| References | `ref/` | 7 |
| Properties | `prop/` | 9 |
| Inheritance | `inh/` | 5 |
| Declarations | `decl/` | 3 |
| Constructors | `ctor/` | 7 |
| Destructors | `dtor/` | 3 |
| Foreach | `foreach/` | 4 |

[INDEX.md](INDEX.md) is the complete 122-row catalog with class names and cell counts.

## C++ ownership

Generators live under `Plugins/Angelscript/Source/AngelscriptTest/Framework/Generate/` as `AngelscriptTest<ClassWithoutF>.h/.cpp`. Tests live under `FrameworkTests/Generate/`, one `GeneratesAndExportsAllCases` method per product. ForLoop keeps `Angelscript.UnitTest.Framework.ForLoopGenerator`; every other product uses `Angelscript.UnitTest.Framework.Generate.<ClassWithoutF>`.

The cross-product acceptance fixture is `LanguageGeneratorCorpus.VerifiesCompleteCorpus`. It constructs every `F*Generator` directly, uses `ListCases` for enumeration, and treats the inventory table as the independent oracle. It does not write product dumps, enable Legacy, or compile or execute generated AngelScript.

## Names and dumps

Canonical entries are PascalCase without underscores. Example: `LANG-CF-LOOP-DEPTH-WHILE-ZERO-BREAK` becomes `EntryLangCfLoopDepthWhileZeroBreak`.

Each product owns one dump filename, `GeneratedCases/<ClassWithoutF>.as`, with no underscores. Product tests write that file beside the Unreal log. The corpus acceptance test only checks the filename contract.

## Observation categories

Non-reject cells are inventory Normal plus Fault. They appear in `BuildAllSource` and `OutCaseCount`. Compile rejects are `ListRejectCaseIds` / `CompileReject` rows with an empty `EntryDeclaration` and an independent `BuildCaseSource` module. `GetExpected == 0` for an unknown ID is not membership. A listed normal zero keeps `ExpectedReturn` set to 0.
