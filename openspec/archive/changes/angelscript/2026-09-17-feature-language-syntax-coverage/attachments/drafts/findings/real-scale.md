# Real scale of this Change

An earlier handoff read like "split six files, thicken five thin slices, add Interface". Disk numbers say otherwise.

## How thin the corpus is

Admitted Language: 53 positive files / 324 `@begin`; 53 Fail files / 289 `@begin`.

**35 of 53 positive files have ≤5 cases** (about two thirds), including:

| Area | Positive files with ≤5 cases |
|---|---|
| Operators | Arithmetic, Assignment, Bitwise, Comparison, Logical, Ternary, ExpressionEdges, DefiniteAssignment |
| Syntax | FunctionReturn, EmptyFunction, Variables, NamedArguments, ForNested, Const, References, Blocks, Struct* |
| ControlFlow | If, IfNested, IfElse, While, DoWhile, LoopJump, Foreach |
| Namespace | all five positives ≤4 |
| Casting | NullHandle, NumericExplicitConversion, ClassHandleCast=5 |
| Preprocessor | DirectiveInString |

Worse: one `@begin` can hold a whole family. `Operators/Arithmetic` `arithmetic` packs add/sub/mul/div/mod, floats, and increments. `FunctionReturn` has two identical `return 42` cases. Thickening splits claims and fills gaps.

The six second-wave flats hold only 87 positives in six files. Class is 547 lines / 22 cases and still mixes constructor, field, method, access, and this.

## Auto is not four small files

Live `auto` has at least these independent claims (positives where legal, Fail where illegal; not an int8×int16 matrix):

```
declaration site
├─ local
├─ several auto in one statement
├─ for initializer
└─ foreach iteration variable

inference source
├─ literal family (int/float/bool/string, once each)
├─ enum
├─ constructor
├─ non-void call
├─ representative member / subscript / ternary / Cast
└─ handle / nullptr if the grammar allows

qualifier
├─ const auto
└─ auto& / const auto&

use
├─ read
├─ same-type reassign
├─ expression / argument / return
└─ wrong-type reassign, no initializer, void call → Fail
```

That is one chapter: about a dozen slices and tens of `@begin` cases.

Class, Inheritance, Typedef, and Interface are the same size of work.

## Identity rewrite is itself large

Flat names already appear in:

- `openspec/specs/angelscript/testing/language-fixtures/spec.md`
- Skill and `test-code-database.md`
- `LanguageFixtureCorpusTests.cpp`
- `test_second_wave_authors.py`
- Language Migration and Pending Migration
- twelve `Generated/Language/<Theme>.generated.cpp` units

Author file count will rise from about 106 toward 150–200 (order of magnitude).

## Hand-writing multiplies schedule

No script-merge. Every `@begin` is written and reviewed. Expect hundreds of new or rewritten cases, not dozens. The Task DAG is a dozen-plus author nodes plus generate/spec/corpus, not five "thicken a bit" cards.
