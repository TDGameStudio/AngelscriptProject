# Accepted: second-wave Language theme admission

Status: designed (R27). Source draft: `openspec/drafts/angelscript/language-fixture-quality/designs/pending-coverage/design.md` (Chinese original; approval R27).

Names: [glossary.md](glossary.md). Evidence: [pending-coverage.md](findings/pending-coverage.md), [two-changes.md](findings/two-changes.md).

## Problem

The first wave admitted only Casting, ControlFlow, Namespace, Operators, Preprocessor, and Syntax. Auto, Class, Inheritance, Destructors, Typedef, and Mixin still sit in Pending as old `@version root` stars. File counts mislead: admitted Language already has 475 `@begin` cases. The gap is missing theme roots.

## Accepted direction

- Q21=A, Q24: migrate only these six themes. Do not thicken the first wave. Do not copy 558 files.
- Q26: about one positive pocket plus `CompileFail` per theme.
- Q27/Q28: this Change is `angelscript/feature-language-second-wave-fixtures`.
- Keep the handed-off pocket contract: `@begin`, Fail siblings, `@function` headers. Do not reopen the parser.

## Contract

```
Pending/Language/{Auto,Class,Inheritance,Destructors,Typedef,Mixin}
        ->
Language/{Auto,Class,Inheritance,Destructors,Typedef,Mixin}.as
Language/{Theme}CompileFail.as
```

Overlap already stored in `Language/Syntax/ClassDeclarationCompileFail` moves into `Language/ClassCompileFail` or `Language/InheritanceCompileFail`. Do not keep two copies.

Properties, top-level Const, Syntax/Function, UClass, World, and the 580 Bindings leftovers are out of this Change.

## Verification

Each new FileTag is queryable in the existing code database. `codegen.py check` passes. Class negatives are not duplicated. This Change does not prove AngelScript compilation or execution.
