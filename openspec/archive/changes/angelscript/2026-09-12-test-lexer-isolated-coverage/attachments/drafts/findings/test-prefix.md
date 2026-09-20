# NativeEngine public test prefix vs submodule filter

Inspected 2026-09-12. Corrects an earlier claim in `nativeengine-tests.md` / `lexer.md`.

CQTest registers `TestDir.ClassName.MethodName`. Harness `ue.test` takes a **prefix**. Skill: run `Angelscript.UnitTest.NativeEngine.<Area>` (`angelscript-test/SKILL.md`).

```
TEST_CLASS_WITH_FLAGS(Lexer, "Angelscript.UnitTest.NativeEngine", …)
└─ [registers] Angelscript.UnitTest.NativeEngine.Lexer.<Method>     ◆ 16 methods
    // TestDir is still the flat NativeEngine string; Lexer is the class token
```

```
ue.test TestPrefix
├─ Angelscript.UnitTest.NativeEngine              // all ~100 NativeEngine classes
├─ Angelscript.UnitTest.NativeEngine.Lexer        // the Lexer class only — works today
├─ Angelscript.UnitTest.NativeEngine.Preprocessor // misses PP: class is PreprocessorPolicy, not Preprocessor…
├─ Angelscript.UnitTest.NativeEngine.AST          // misses ASTCodec; hits ASTTypedNodes if that class exists
├─ Angelscript.UnitTest.NativeEngine.VM           // hits VM* and also VMSource* (SourceExec) and VMFingerprints
└─ Angelscript.UnitTest.NativeEngine.TypeOwnership // already a nested TestDir; 9 classes
```

---

## Lexer: isolated code, and already a selectable prefix

| Meaning of “单独” | Today |
|---|---|
| 实现隔离：只 `asCTokenizer`，不进 PP/Sema/VM | **有。** `LexerTests.cpp`，16 个 `TEST_METHOD` |
| 用前缀只跑词法 | **有。** 公开名已是 `Angelscript.UnitTest.NativeEngine.Lexer.*` |
| TestDir 里写了子模块 | **没有。** TestDir 仍是 `Angelscript.UnitTest.NativeEngine`；`Lexer` 来自类名 |

Earlier inventory said `ue.test …NativeEngine.Lexer` cannot select the suite. That was wrong: CQTest already appends the class name. This session did not re-run Harness; the name shape is from the macro + skill.

`SourceDiagnostics` is a sibling class (`…NativeEngine.SourceDiagnostics.*`), not under Lexer.

---

## Why other units cannot be filtered the same way

Only two TestDirs are nested today:

| TestDir | Classes |
|---|---|
| `Angelscript.UnitTest.NativeEngine` | ~87 classes (Lex, PP, AST, Sema, Identity, Builder, VM, SourceExec, …) |
| `…NativeEngine.TypeOwnership` | Admission, Materialize, Private, … |
| `…NativeEngine.LanguageSurface` | Syntax, Lambda, SDK, … |

PP / AST already sit in folders but register the **flat** TestDir. Class tokens do not share one prefix:

- PP: `PreprocessorPolicy`, `PreprocessorDirectiveTree`, `PreprocessorConditions`, …
- AST: `ASTTypedNodes`, `ASTCodec`, …
- Sema: `BodiesCore`, `BodiesExpressions`, plus Declaration* classes
- SourceExec: `VMSourceCalls`, `VMSourceNumeric`, … — prefix `VM` collides with opcode VM

So `…NativeEngine.Lexer` is lucky (one class named `Lexer`). `…NativeEngine.Preprocessor` does **not** gather the PP folder.

TypeOwnership already did what you asked: submodule in the **TestDir**, class = scenario group.

---

## Two ways to get “run one AS unit”

```
A. 类名当前缀（现状对 Lexer）
TestDir = NativeEngine
Class   = Lexer | PreprocessorPolicy | ASTCodec
Filter  = NativeEngine.Lexer     // 只这一类
        NativeEngine.Preprocessor // 对不上 Policy / Tree / Conditions

B. TestDir 嵌套（TypeOwnership）
TestDir = NativeEngine.Lexer | NativeEngine.Preprocessor | …
Class   = Tokens | Trivia | Policy | Tree
Filter  = NativeEngine.Lexer          // 该 TestDir 下所有类
```

If B uses token `Lexer` and the class stays `Lexer`, names become `…Lexer.Lexer.Method` (redundant). B implies renaming the class to a scenario group.

Q6 unit names (`Lex`, `PP`, `AST`, …) are **inventory / helper** names, not today’s Automation tokens. Public path today says `Lexer`, not `Lex`.

---

## Conclusions

1. 词法**有**单独测试，也**已经**能用 `Angelscript.UnitTest.NativeEngine.Lexer` 只跑它们。
2. 你要的「NativeEngine 后面跟子模块」对词法只是碰巧成立（类名）；PP/AST/Sema 不成立。
3. 若要对齐所有 Q6 单元，应学 TypeOwnership：把子模块放进 **TestDir**，而不是指望类名碰巧叫对。
4. 这是公开测试身份变更；未实现，等你定 TestDir 规则和词法那段叫 `Lexer` 还是 `Lex`。

## Open

- Q23 settled 2026-09-12: nest TestDir (`NativeEngine.<Unit>`), class = scenario group.
- Q24 settled 2026-09-12: public lex token is `Lexer`, not `Lex`.
- Held: `SourceDiagnostics` under `…Lexer` or its own prefix. Not applied to plugin tests yet.
