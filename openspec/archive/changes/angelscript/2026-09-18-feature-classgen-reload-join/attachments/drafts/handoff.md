# Handoff: join hot reload to ClassGen

Source: draft `angelscript/classgen-register-join` scope `reload-classgen-join`. Approval R10.

## OpenSpec Handoff

- Scope: reload-classgen-join
- Target Change: angelscript/feature-classgen-reload-join

## Problem

`CompileModules(Initial)` already runs Builder+Register and materializes UserData. `PerformHotReload` still sends new preprocessor `ModuleDesc` values through the dead Stage1–4 block. The missing skip is not the root cause: the live `asCModule` name and the single Initial `asCDefinitions` occupy `GetModule` / `TypesByName`, so a second `Register` conflicts. Full-engine `RetireExternalDefinitions` is not usable.

## Success

- Register produces one `asCDefinitions` per preprocessor `ModuleDesc` / `.as` (Dependencies = host graph + already attached script sets).
- `CompileModules(FullReload)` and `SoftReloadOnly` retire that file's compile set and its dependents, then Builder+Register, then skip Stage1–4.
- Existing ClassGen Soft/Full and PIE structural downgrade/reject stay unchanged.
- `ClassGenReload`: after reload, class/struct/enum UserData and reverse pointers match; failure keeps the last generation.

## Evidence

- [reload-join.md](findings/reload-join.md): module-name clash, single-set ownership, no full-engine retire.
- [design.md](design.md): P + S call chain.
- Test: `Angelscript.UnitTest.NativeEngine.Compile.ClassGenReload`.

## Scope

Do: one Change. Per-file definitionSet first, then Full+Soft skip with retire/re-Register.

Do not: CacheV2 reuse; delegate/event UserData; frontend UObject; ClassGen rewrite; `ALWAYS_CREATE` / `Build`; shadow engine; full-engine retire; K replace-by-key.

## Constraints

- ClassGen still reads `FAngelscriptEngine::Get().Engine` and preprocessor `ModuleDesc`.
- Builder input remains `ProcessedCode`; Path remains preprocessor `ModuleName`.
- Retire compile definitionSets only; leave the host graph.
- A failed compile must keep a lookup-able last-good shell (roll back any pre-compile rename).
- Entry remains `CompileModules`.

## Approach

1. Change Initial (and later reload) from one `TakeDefinitions` for every file to one Builder+Register per `ModuleDesc`.
2. On reload: mark sets to replace by dependency, detach them from the engine index, retire those compile sets, Register in the same order.
3. Skip Stage1–4 for `FullReload` and `SoftReloadOnly` the same way as Initial.
4. Land in existing ClassGen / SwapIn. Old-shell rename stays on the successful SwapIn path; failure leaves `ActiveModules`.

## Alternatives and flip conditions

- W1=F (FullReload only): flip if the in-PIE Soft path must also produce new shells immediately. This Change skips the dead block for both compile types.
- R1=K (replace-by-key): flip if Initial single-set ownership cannot change. Rejected.
- C1=two Changes: flip if per-file sets must ship alone before reload work. Rejected.

## Failures

- Widening only `if (Initial)`: second Register hits name/key conflict.
- Full-engine retire: host binds and unchanged files disappear.
- Pre-compile rename without rollback: the editor cannot find the last generation.

## Verification

- `ClassGenReload`: after an Initial materialization, `CompileModules(FullReload)` and `SoftReloadOnly` update UserData.
- Existing `ClassGenMaterialization.ReloadKeepsLegacyStageError` is turned green or replaced; this Change must not keep requiring the Stage1 death error.
- CacheV2 and the full editor `.as` suite are omitted.

## Exploration Carryover

| Source | Target | Reason |
| --- | --- | --- |
| design.md | attachments/drafts/design.md | Accepted scoped design |
| handoff.md | attachments/drafts/handoff.md | Accepted handoff |
| glossary.md | attachments/drafts/glossary.md | Confirmed public names |
| ../../findings/reload-join.md | attachments/drafts/findings/reload-join.md | Replacement clashes and options |
| ../../log.md#r8 | attachments/talks/talk-20260918-123000-reload-width-and-replace.md | W1=S and R1=P |
| ../../log.md#r9 | attachments/talks/talk-20260918-123100-packaging-and-names.md | One Change and names |
| ../../log.md#r10 | attachments/talks/talk-20260918-123200-approval.md | Scope approval |
| ../../findings/reload-join.md | attachments/knowledges/per-file-definition-sets-enable-reload-retire.md | Reusable: a single set cannot retire per file |
