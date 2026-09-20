# Language fixture coverage

Use this reference when authoring, splitting, or thickening `AngelscriptTestCode/Language/**`. Container grammar, annotations, generate/check, and `FAngelscriptTestCode` queries stay in [test-code-database.md](test-code-database.md). Durable inventory identities live in `openspec/specs/angelscript/testing/language-fixtures/spec.md`.

Admission stores complete source. It does not compile or execute AngelScript. `codegen.py generate` / `check` project authors into `TestCode/Generated/Language/`; they do not write `.as` bodies.

## Grain

FileTag is the author path without `.as`. A live syntax becomes a directory when several independently named claims remain after thickening. A thin leftover may stay one file. Fail polarity is the sibling suffix `CompileFail` or `RuntimeFail` on that same slice, not one theme-wide Fail file.

Do not treat a folder move as coverage. One `@begin` is one claim and one complete body. Do not pack a family into a mashup (`arithmetic`, `assignment`, `bitwise`, `comparison`, `logical`, `const-values-methods-and-references`). Do not pad a type matrix (one `int8` local is a declaration-theme claim; do not add every width).

Coverage authority is the **new frontend** (`frontend/Lexer/as_token_kinds.def` and `frontend/Parser/*`), not leftover `as_tokendef.h` `tokenWords`, and not Pending mashups. Pending `Language/` is reading material only.

## Chapter identities

Retire flat FileTags `Language/Auto`, `Language/Class`, `Language/Inheritance`, `Language/Destructors`, `Language/Typedef`, and `Language/Mixin`. Representative Gets use chapter slices:

| Chapter | Representative FileTags |
|---|---|
| Auto | `Language/Auto/InferFromLiteral`, `InferFromCall`, `InferInLoop`, `Qualifiers` |
| Class | `Language/Class/Constructor`, `Fields`, `Methods`, `Access`, `This`, plus `Declaration`, `Handle` |
| Inheritance | `Language/Inheritance/Extends`, `Override`, `Super`, `Final`, `Nested`, `Handle` |
| Typedef | `Language/Typedef/Alias`, `Chain`, `InField`, `Handle`, `InReturn` |
| Mixin | `Language/Mixin/FunctionMixin`, `ConstReceiver`, `ClassMixinCompileFail` |
| Destructors | `Language/Destructors/ClassDestructor`, `StructDestructor`, `Inheritance` |
| Interface | `Language/Interface/Declare`, `Implement`, `Handle` |
| Delegate | `Language/Delegate/Declare` |
| Event | `Language/Event/Declare` |

`Language/Syntax/FunctionModifiers` holds `local` (and `access` policy programs when they belong with modifiers rather than Class access keywords). The production Family example remains `Language/Syntax/StructFields` (`fields-two` / `add-field`). A parentless chapter pocket is `Language/Class/Constructor`, not flat `Language/Class`.

First-wave theme directories keep their FileTags and thicken in place: Operators, ControlFlow, Syntax, Namespace, Casting, Preprocessor. Split mashups. Do not revive `Language/Casting/ClassCast`.

## Cross-chapter owners

| Claim | Owner |
|---|---|
| `invalid-auto-without-initializer` | Auto Fail, not `VariablesCompileFail` |
| `for (auto x : xs)` / foreach-auto | Auto; `ControlFlow/Foreach` stays explicitly typed |
| ordinary `get_Value()` | Class methods, not a Properties pocket |
| string literals | `Language/Syntax/StringLiterals`, not Variables |

A Tag spelled `root` has no privilege. Several versions may be parentless. Write `@parent` only for a real same-program Family.

## Authoring

- Hand-write every `@begin` in English. Do not generate author `.as` with Python or script-merge Pending.
- Pocket format matches `Language/ControlFlow/If.as`: file `@version v1`, parentless `@begin` cases, sibling Fail files.
- Spell live keywords as the new frontend lexes them: `nullptr`, `Cast<T>(…)`, `&&` / `||` / `!` / `^^`. Do not author leftover `null`, lowercase `cast`, or `is` / `!is`.
- After authors exist, run generate/check once for the whole Language tree. Do not generate from a half-written chapter if sibling chapters still own shared Generated paths in the same edit.

## Out of Language

Do not author positives or Fail for removed syntax: import, asset, funcdef, template, coroutine, shared/external, or the `property` decorator.

Do not absorb Pending Properties, FString literals, Syntax/EdgeCases, or UClass into Language. Those stay Pending or belong under `Unreal/` / `Containers/`.

Do not send Bindings leftovers to `Language/`. Host types go to `Containers/` or `Unreal/<Type>/`.
