# Descriptor SuperClass and Project authority

The accepted exploration contract is [attachments/drafts/design.md](attachments/drafts/design.md). Names are in [attachments/drafts/glossary.md](attachments/drafts/glossary.md). ClassGen UserData is withdrawn; see [talks after replan](attachments/INDEX.md).

## Context

Builder already yields two products: Resolved `FAngelscript*Desc` values and private Taken `asCDefinitions`. Registration already installs Engine and TypeId. Project originally omitted SuperClass, and DefinitionsBuilt overwrote Project with a TypeInfo name scan. Those two gaps are this Change.

ClassGen still calls `SetUserData` and needs `ModuleDesc->ScriptModule` from an old compile-unit `asCModule`. `asCScriptEngine::GetModule` is intentionally gone. Forging that shell inside a bind helper is out of scope. A later Change owns that join.

## Goals / Non-Goals

**Goals:** fill SuperClass / ImplementedInterfaces at Resolved; keep Project after DefinitionsBuilt; withdraw ClassGen UserData work from this Change.

**Non-Goals:** asType UserData attach; restoring `GetModule`; forging `asCModule` shells; delegate / event verification or redesign; a new publisher type; frontend UObject creation; rewriting `FAngelscriptClassGenerator`; a new `NativeEngine.ClassGen` layer.

## Decisions

- This Change stops at authored SuperClass strings and Project-authoritative CompileOutput. Frontend farthest stage remains `Resolved`.
- Flip recorded in the original scope talk: ClassGen cannot be proven here without old module shells. User chose option C, then asked to close this Change and open a new one for modules.
- `3.1` keeps its ID. Its outcome is rewritten to withdraw the ClassGen bind helper, `ClassGenMaterialization` tests, and ClassGen export edits. The old UserData acceptance is cancelled and needs a follow-up Change.
- SuperClass tests stay on existing `ReflectionDescriptors`. CompileOutput tests stay on `CompileLifecycle`. Do not add `ClassGenMaterialization` in this Change.
- Do not default empty SuperClass to `"UObject"` in Project.

## Call chains

```
asCBuilder.RunThrough(ByteCodeEmitted)
→ DescriptorConsumer.Project                  // authoritative Resolved descriptors
│  ├─ SuperClass / ImplementedInterfaces      // from GetResolvedBases; this Change fills them
│  ├─ UCLASS / USTRUCT → ClassDesc
│  └─ UENUM → EnumDesc
→ RefreshCompileOutput                        // MUST keep Project; no TypeInfo scan overwrite
→ TakeDefinitions()                           // private asCObjectType, Engine = null
→ asCEngineCompileRegistration.Register       // existing: Engine + TypeId; UserData stays null
// ClassGen / asCModule join is a later Change
```

Measured at: d50407196b012854076a4c93e37dc153e9077ff2

dirty: yes; SuperClass fill and Project-keep sources are present. A ClassGen bind helper and `ClassGenMaterializationTests.cpp` exist from the withdrawn attempt and are removed by 3.1. Parent working tree also has unrelated Language, Containers, and Skill edits.

## Risks / Trade-offs

- ClassGen still cannot consume Register-only types. Closing this Change without UserData is the accepted split, not a silent pass of materialization.
- A later Change must decide how `asCModule` (or a replacement) is produced. This Change does not restore the removed SDK `GetModule` path.
