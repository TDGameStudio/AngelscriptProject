# How "all" Unreal intake is cut

Date: 2026-09-17. Q25 user: "all of them". Not a Casting pilot. Q29 confirmed 124 UClass + World. Source draft finding (Chinese original; approval R27).

The 580 files under `Pending/Bindings-不要这个目录了…` stay excluded: type-API axis pockets, rejected directory name, later handover.

The 124 UClass files are several concerns. Merge like Language (Q26):

```
Unreal/
├─ Casting/                 // ObjectCast, HandleCast, HandleComparison
├─ Strings/                 // FString UClass 9 + StringNameText
├─ GarbageCollection/       // GC* + GCLocalVariable
├─ Input/                   // Key/Mouse/Gamepad/Action/Axis
├─ Events/                  // EventBind, EventBus, Lifecycle
├─ Reflection/              // Int/Float/Bool/Quat properties and defaults
├─ ActorClass/              // Empty/Final/Inherit, This/Override/Super UCLASS forms
├─ Hooks/                   // Preprocessor/UClass 12
└─ World/
   ├─ Actor/                // 40
   ├─ Component/            // 72
   ├─ Blueprint/            // 6
   ├─ Streaming/            // 2
   └─ Subsystem/            // 4
```

Each theme is about one positive pocket plus CompileFail. Author files must use `@begin` or CodeGen will not accept them.
