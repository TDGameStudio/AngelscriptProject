# Handoff: second-wave Language themes

## OpenSpec Handoff

- Scope: pending-coverage
- Target Change: angelscript/feature-language-second-wave-fixtures

## Problem

After the first six Language themes were admitted, Auto, Class, Inheritance, Destructors, Typedef, and Mixin remain in Pending as old `root` stars, so Language looks thin.

## Success

- Six admitted positive pockets plus CompileFail siblings using the current `@begin` / `@function` contract.
- Overlapping negatives in `Language/Syntax/ClassDeclarationCompileFail` are merged, not duplicated.
- CodeGen generate/check and the language-fixtures inventory include these FileTags.
- Admission does not compile or execute AngelScript.

## Evidence

- [pending-coverage.md](findings/pending-coverage.md): 475 `@begin` cases versus 558 Pending files; the six themes have no U macros.
- [two-changes.md](findings/two-changes.md): split from the Unreal Change.
- Pending `Language/Migration.md` second-wave list.

## Scope

Do: rewrite the six themes as `AngelscriptTestCode/Language/{Theme,ThemeCompileFail}.as`; update the census/Migration notes, Skill examples, language-fixtures spec, and projections.

Do not: thicken the first wave; Properties / Const / Syntax/Function; UClass / World / Bindings; the 122 generators; parser changes.

## Constraints

- Author `.as` files in English; Change records in English.
- Parentless cases, Fail siblings, and function-header fields follow `theme-case-containers`.
- No task dependency on `feature-unreal-fixture-root`.

## Approach

Merge one-concern Pending files per theme. Split positives and negatives. Diff Class/Inheritance against the existing Syntax CompileFail pocket before moving cases.

## Alternatives and flip

- One file per concern: rejected at Q26. Flip if a merged pocket cannot state one theme claim.
- One Change with Unreal: rejected at Q27.

## Failure

- Copying `@version root` stars recreates a privileged root or fails the current parser.
- Putting UClass material under `Language/Class` conflicts with Q22.

## Verification

`codegen.py check`; the corpus can Get the six positive FileTags and their CompileFail siblings; Class negative identities are unique.

## Exploration Carryover

Exported from the approved draft handoff. Required copies live beside this file.
