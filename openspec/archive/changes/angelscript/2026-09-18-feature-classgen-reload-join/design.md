# Join hot reload to ClassGen through per-file definition sets

Seeded from [attachments/drafts/design.md](attachments/drafts/design.md). Approval R10.

Preprocessor descriptors stay the ClassGen input. Initial ownership splits to one compile `asCDefinitions` per `.as`. FullReload and SoftReloadOnly then retire those compile sets (not the host graph), Builder+Register, and skip the dead Stage1–4 block.

## Goals / Non-Goals

**Goals:** After a file change, a new preprocessor `ModuleDesc` gets a new shell. ClassGen Soft/Full still chooses the reload algorithm. Failure keeps a lookup-able last generation.

**Non-Goals:** CacheV2 reuse; delegate/event UserData; ClassGen rewrite; frontend UObject; `ALWAYS_CREATE` / `Build`; full-engine retire; replace-by-key; shadow Engine.

## Decisions

- W1=S: both `FullReload` and `SoftReloadOnly` skip the dead Stage block.
- R1=P: one Builder+Register per preprocessor `ModuleDesc`. Dependencies = host graph + already attached script sets.
- Builder Path stays preprocessor `ModuleName`. Input stays `ProcessedCode`.
- Retire compile definitionSets only. Do not call `RetireExternalDefinitions` on a live reload.
- Old-shell rename stays on the successful `SwapIn` path. A failed compile must not leave the last-good name unfindable.
- Test identity is `Angelscript.UnitTest.NativeEngine.Compile.ClassGenReload`.

## Call chains

```
PerformHotReload(FullReload|SoftReloadOnly)
→ Preprocess → GetModulesToCompile
→ CompileModules
   now: Stage1 dead ("Legacy module compilation is unavailable")
   target:
     per ModuleDesc: asCBuilder.RunThrough(ByteCodeEmitted)
     retire that file's compile set + dependents
     asCEngineCompileRegistration.Register(Sets, Output)
     skip Stage1–4
→ FAngelscriptClassGenerator.Setup → SoftReload | FullReload | PIE downgrade
→ asType.SetUserData(UASClass|UASStruct|UEnum)
```

Initial today:

```
CompileModules(Initial)
→ one asCBuilder for every new ModuleDesc
→ one TakeDefinitions / one Register
```

Initial after this Change:

```
CompileModules(Initial)
→ for each ModuleDesc: Builder + Register(that set)
→ skip Stage1–4 → ClassGen
```

Measured at: `38e1b7a4fe9bbc540106f28d7858ccd5d899868f`

dirty: yes; parent tree already has Language fixtures, container authors, and other in-flight Changes. This Change owns the per-file Builder join, selected-set retire, ClassGenReload tests, and the Materialization reload-case replacement listed in `tasks.md`.
