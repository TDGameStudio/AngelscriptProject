# Singleton syntax and lowering contract

## 1. Public grammar

The normative surface is intentionally small:

```text
singleton-declaration := singleton-specifier? "singleton" identifier "of" uobject-type singleton-body
singleton-specifier   := "USINGLETON" "(" singleton-scope? ")"
singleton-scope       := "Global" | "World"
singleton-body        := "{" lifecycle-block* "}"
lifecycle-block       := create-block | init-block | reload-block | deinit-block
create-block          := "Create" block
init-block            := "Init" block
reload-block          := "Reload" block
deinit-block          := "Deinit" block
```

Scope defaults:

| Source | Effective scope |
| --- | --- |
| no `USINGLETON` | Global |
| `USINGLETON()` | Global |
| `USINGLETON(Global)` | Global |
| `USINGLETON(World)` | World |

`USINGLETON` is consumed only when it directly decorates the following `singleton` declaration after trivia/comments. It is not a freestanding directive, cannot decorate `class`, and cannot replace the `singleton` token. Unknown/duplicate arguments are compile errors.

Declarations are allowed at module top level and inside an AngelScript namespace. They are not allowed inside a class, struct, function or another singleton body.

## 2. Canonical examples

```angelscript
singleton DefaultConfig of UGameConfig
{
    Init
    {
        Profile = n"Default";
        MaxPlayers = 4;
    }
}

USINGLETON(Global)
singleton PreviewConfig of UGameConfig
{
    Init
    {
        Profile = n"Preview";
    }
}

namespace Combat
{
    USINGLETON(World)
    singleton Manager of ACombatManager
    {
        Create
        {
            return SpawnActor(ACombatManager, Context);
        }

        Init
        {
            Capacity = 128;
        }

        Reload
        {
            RebuildCaches();
        }

        Deinit
        {
            StopAllTasks();
        }
    }
}
```

The World `Create` block receives an implicit generated parameter named `Context`; the Global form does not define it. `Init`, `Reload` and `Deinit` use implicit `this`, so the assignments above target the candidate instance.

## 3. Generated public surface

For each declaration, the preprocessor reserves a namespace at the declaration's namespace level:

```angelscript
// Global
UGameConfig DefaultConfig::Get();

// World
ACombatManager Combat::Manager::Get();
ACombatManager Combat::Manager::Get(UObject Context);
```

The no-context World overload resolves exactly the current `FAngelscriptEngine` ambient World. The explicit overload resolves `Context->GetWorld()`. Both route to the same definition ID and World slot.

The generic, unnamed surface is bound independently:

```angelscript
namespace Singleton
{
    UObject GetGlobal(UClass Type); // DeterminesOutputType(Type)
    UObject GetWorld(UClass Type, UObject Context); // DeterminesOutputType(Type)
}
```

Typical calls therefore keep a concrete static type:

```angelscript
UMyService Service = Singleton::GetGlobal(UMyService);
UMyWorldService WorldService = Singleton::GetWorld(UMyWorldService, this);
```

There is deliberately no declaration synthesized for these calls, and no default API can discover or execute a named declaration's lifecycle blocks.

## 4. Fixed lifecycle signatures

Conceptual hidden signatures are:

| Block | Global hidden shape | World hidden shape | Invocation |
| --- | --- | --- | --- |
| `Create` | `Type __Create()` | `Type __Create(UObject Context)` | only when an Empty slot is first accessed |
| `Init` | `void __Init(Type __Receiver) external_implicit_this` | same | `__Init(Candidate)` after UE construction, before Ready publication |
| `Reload` | `void __Reload(Type __Receiver) external_implicit_this` | same | `__Reload(Replacement)` only after compatible structural replacement |
| `Deinit` | `void __Deinit(Type __Receiver) external_implicit_this` | same | `__Deinit(ReadyObject)` once before final Registry release |

At most one block of each kind is legal. Block order in source does not change call order. `Create` must return a handle assignable to the declared Type. The other blocks cannot declare a return type or arguments.

“Cannot declare arguments” applies to the user-facing lifecycle block. The generated global AngelScript function has exactly one real declared parameter of the singleton's Type. The maintained compiler aliases parameter zero's object type and stack slot as the implicit receiver; the parameter remains in bytecode, raw and StaticJIT entry ABI. The lowerer must not emit `void __Init()` with only the trait, because the current compiler cannot establish an external receiver without object-typed parameter zero.

For every lifecycle entry the hidden symbol contains the stable definition hash, but the semantic shape is independently asserted after compile: `objectType == nullptr`, `EXTERNAL_IMPLICIT_THIS == true`, declared parameter count `1`, parameter zero assignable to the descriptor Type, and an explicit Registry invocation with the current candidate/replacement/ready object. Unqualified member access, explicit `this`, and unqualified method calls inside the body resolve through that same parameter symbol. A local or explicit symbol with the same name keeps the normal compiler's lookup precedence.

Lifecycle script is ordinary AngelScript and may call other APIs; unlike Dynamic Asset builders it is not a pure-data subset. Runtime cycle detection, World validation and candidate rollback still apply.

## 5. Descriptor shape and hashes

The planned Core descriptor needs enough information to classify reload before swapping a module:

```text
FAngelscriptSingletonDesc
  SourceFile / SourceLine / SourceColumn
  ModuleStableId
  Namespace
  DeclarationName
  Scope
  StableDefinitionId = Hash(Scope, ModuleStableId, Namespace, DeclarationName)
  DeclaredTypeName / DeclaredClassStablePath
  GeneratedGetterNames
  Optional Create/Init/Reload/Deinit hidden entries
  DescriptorHash
  TypeDependencyHash
  PerLifecycleBodyHash
```

`DescriptorHash` includes scope, name, namespace, module identity, declared type and lifecycle presence/signatures, but excludes lifecycle body text. `TypeDependencyHash` tracks the referenced UClass shape/routing needed for PIE related-change detection. Per-body hashes distinguish a lifecycle-only edit from unchanged declarations.

The descriptor is copied through `FAngelscriptModuleDesc`, StaticJIT precompiled data and the offline JSON bundle. Pointer values and transient UClass addresses are never serialized.

## 6. Lowering constraints

- Hidden symbol names must include the stable definition hash; user names alone are not collision-safe across namespaces/modules.
- Generated code preserves original source-line mapping for diagnostics and debugger stepping.
- No generated Getter is appended to `PostInitFunctions`.
- Compilation and module activation register descriptors/routes only; they must not call the Registry's Get path.
- The generated namespace collision is diagnosed at the source declaration instead of surfacing as an opaque AngelScript duplicate-symbol error.
- Comments and strings containing `singleton`/`USINGLETON` are ignored; multiline declarations and nested braces inside lifecycle blocks are parsed structurally rather than with one regex.

## 7. Diagnostic catalogue

Every diagnostic includes declaration name, effective scope, source position and one repair suggestion:

| Code | Condition | Required guidance |
| --- | --- | --- |
| `AS-SINGLETON-001` | malformed declaration/specifier | show canonical `USINGLETON(World) singleton Name of Type` form |
| `AS-SINGLETON-002` | duplicate stable definition | identify both source locations |
| `AS-SINGLETON-003` | Type is not a UObject class | select a concrete UObject subclass |
| `AS-SINGLETON-004` | invalid lifecycle block/signature | list the four supported block shapes |
| `AS-SINGLETON-005` | generated namespace/API collision | rename the declaration or conflicting symbol |
| `AS-SINGLETON-006` | Scope incompatible with Type | use World for Actor/Widget/Component or ordinary UObject for Global |
| `AS-SINGLETON-007` | subsystem/collection-owned Type | use the corresponding existing Subsystem Getter |
| `AS-SINGLETON-008` | related reload rejected during PIE | stop PIE or wait for queued full reload |

Runtime errors add Engine id, key kind, stable ID/type, World identity and the creation chain where applicable.
