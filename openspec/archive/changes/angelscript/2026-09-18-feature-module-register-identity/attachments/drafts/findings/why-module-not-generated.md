# Each .as is already a module; asCModule was not created

Source: local draft finding `why-module-not-generated.md`. Approval: R4.

## The frontend already splits per file

`asCCompilationSession` interns a `Kind=Module` identity per `LogicalSourceKey`. `DescriptorConsumer.Project` emits one `FAngelscriptModuleDesc` per fragment, `ModuleName = file key`.

The missing third piece is `new asCModule`.

```
N .as files
├─ Session.ModuleIdentities[file]            // stable module identity already
├─ CompileOutput.Modules[file]               // FAngelscriptModuleDesc already
│     ScriptModule == null
└─ 1 asCDefinitions                          // all Type/Function in one graph
      Type.module == null
      Register writes Type.engine + TypeId only
```

This is not “a file is not a module”. Descriptors exist; the runtime shell does not.

## Why nothing created it

`2026-09-12-refactor-sdk-compile-lifecycle` hung TypeInfo on Definitions and forbade hanging the set on `asCModule`. Removing `GetModule` / `AddScriptSection` / `Build` closed the **old compile entry**, not the “one file, one module” idea.

`RegisterExternalDefinitions` takes one Definitions graph and ignores the N ModuleDesc values, so no shell exists after install. ClassGen still `check(ScriptModule)`.

## This is not Engine-free Module

Creating the shell does not require an offline `asCModule`. Construction stays `asCModule(name, engine)`. Delay means: compile on Definitions first, then birth one shell per ModuleDesc at Register.
