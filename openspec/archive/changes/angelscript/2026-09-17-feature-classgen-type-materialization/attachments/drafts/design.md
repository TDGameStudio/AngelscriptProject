# Candidate: one Change materializes class / struct / enum

Source: draft `angelscript/class-generation-handoff` scope `classgen-handoff`. Approval: R3 scope, R4 names.

## Problem

The new frontend already compiles `asCObjectType` shells and `Resolved` `FAngelscript*Desc` values, but asType has no UClass / UStruct / UEnum pointer. ClassGen still consumes the old preprocessor module descriptors.

## Accepted

- Do not rewrite `FAngelscriptClassGenerator`.
- Frontend stops at `Resolved`: `Class`, `Struct`, `ScriptType`, and `GetUserData()` stay null after `CompileDeclarations`.
- One Change covers UCLASS / USTRUCT / UENUM generation, attach, and verification.
- Delegate / event: existing `Project` may keep emitting descriptors; this Change does not assert Materialized fields and does not change the ClassGen delegate path.

## Call chain

```
asCBuilder.RunThrough(ByteCodeEmitted)
├─ DescriptorConsumer.Project                 // authoritative Resolved descriptors
│  ├─ SuperClass / ImplementedInterfaces      // from GetResolvedBases; this Change fills them
│  ├─ UCLASS / USTRUCT → ClassDesc
│  └─ UENUM → EnumDesc
├─ TakeDefinitions()                          // private asCObjectType, Engine = null
│
▼
asCEngineCompileRegistration.Register         // existing: Engine + TypeId
│  existing test: RegisterInstallsEngineAndTypeId
│
▼
Attach ScriptType onto ClassDesc / EnumDesc by name // still no UObject
│
▼
FAngelscriptClassGenerator.AddModule
├─ Setup / Soft|FullReload
├─ asType.SetUserData(UASClass|UASStruct|UEnum)
└─ UASClass.ScriptTypePtr / UASStruct.ScriptType
```

`RefreshCompileOutput` MUST NOT replace `Project` with a TypeInfo scan once `ModuleDefinitions` exist.

`CodeSuperClass` is a native `UClass*` lookup. Resolve it after Registration and before ClassGen Analyze. Do not fill it in `CompileDeclarations`.

## Acceptance (this Change)

| Kind | asType.GetUserData() | Reverse pointer |
|---|---|---|
| UCLASS | `UASClass*` | `UASClass.ScriptTypePtr == asType` |
| USTRUCT | `UASStruct*` | `UASStruct.ScriptType == asType` |
| UENUM | `UEnum*` | `EnumDesc.Enum` is non-null |
| delegate / event | not asserted | not asserted |

Frontend unit tests keep locking: those pointers stay null after `CompileDeclarations`.

## Out of scope

- A new publisher type (reuse `asCEngineCompileRegistration` and the existing ClassGen).
- Delegate / event redesign.
- Python generation of Language `.as` authors.
