# Handoff: join Initial thin host to ClassGen

Source: local draft `angelscript/classgen-register-join` scope `register-classgen-join` `handoff.md`. Approval: R4. Translated from the approved Chinese handoff; identifiers unchanged.

## OpenSpec Handoff

- Scope: register-classgen-join
- Target Change: angelscript/feature-classgen-register-join

## Problem

Register already creates one `asCModule` per file. `CompileModules` still runs the dead Stage1–4 block, including an unconditional globals failure, so ClassGen never sees a shell and the first editor compile cannot emit `UASClass` / `UASStruct` / `UEnum`.

## Success

- `CompileModules(Initial)` runs one Builder+Register onto the host Engine and skips the whole Stage1–4 block.
- ClassGen still consumes preprocessor `ModuleDesc` values (`CodeSuperClass` already filled).
- After materialization: `asType.GetUserData()` is `UASClass*` / `UASStruct*` / `UEnum*`; reverse pointers match.
- Frontend `CompileDeclarations` stays unchanged: those pointers stay null.

## Evidence

- [thin-host-join.md](findings/thin-host-join.md): dead compile is wider than Stage1; ProcessedCode; Path=ModuleName.
- [join-gap.md](findings/join-gap.md): ClassGen is bound to the host singleton.
- [design.md](design.md): call chain.
- Test: `Angelscript.UnitTest.NativeEngine.Compile.ClassGenMaterialization`.

## Scope

Do: Initial source compile through Builder skip; attach shells to preprocessor descriptors; existing ClassGen Setup/Reload; UserData proof.

Do not: reload skip; CacheV2 reuse; delegate/event UserData; frontend UObject; rewrite ClassGen; `ALWAYS_CREATE` / `Build`; Project replacing preprocessor; restore `BindRegisteredTypesForClassGeneration`.

## Constraints

- ClassGen reads `FAngelscriptEngine::Get().Engine`.
- Builder input is `ProcessedCode`; source Path is preprocessor `ModuleName`.
- Modules that already have `ScriptModule` or precompiled code do not rerun Builder.
- No new public helper; the entry remains `CompileModules`.

## Approach

1. When `CompileType == Initial` and the module is not precompiled, turn `InModules` into Builder sources.
2. `RunThrough(ByteCodeEmitted)`, then `Register(Sets, Output)` onto `this->Engine`.
3. Write shells back onto preprocessor `ScriptModule` by `ModuleName`.
4. Skip Stage1–4 and fall through to existing ClassGen / SwapIn.

## Alternatives and flip

- Q2=R (include reload): flip if file edits must materialize in this Change. Explicitly out.
- B / H2 (Project replaces preprocessor): flip if preprocessor descriptors cannot align with asType.
- Restore a bind helper: flip if `CompileModules(Initial)` cannot drive ClassGen in tests.

## Failure

- Patching only Stage1 still fails in the globals loop after a successful shell exists.
- Feeding disk source misaligns preprocessor expansion with asType.
- Testing ClassGen on `asCreateScriptEngine()` reads the wrong Engine.

## Verification

- `ClassGenMaterialization`: after `CompileModules(Initial)`, class/struct/enum UserData and reverse pointers.
- Existing `ReflectionDescriptors`: materialization pointers stay null after CompileDeclarations.
- Full/SoftReload is not required green.

## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Accepted scoped design |
| handoff.md | attachments/drafts/handoff.md | Accepted handoff |
| glossary.md | attachments/drafts/glossary.md | Confirmed public names |
| ../../findings/thin-host-join.md | attachments/drafts/findings/thin-host-join.md | Initial skip and name join |
| ../../findings/join-gap.md | attachments/drafts/findings/join-gap.md | ClassGen gap evidence |
| ../../log.md#r2 | attachments/talks/talk-20260918-100000-scope.md | Q1=C thin host |
| ../../log.md#r3 | attachments/talks/talk-20260918-100100-initial-and-names.md | Q2=I and names |
| ../../log.md#r4 | attachments/talks/talk-20260918-100200-approval.md | Whole-scope approval |
| ../../findings/thin-host-join.md | attachments/knowledges/initial-skips-dead-compile-stages.md | Reusable: dead compile is wider than Stage1 |
