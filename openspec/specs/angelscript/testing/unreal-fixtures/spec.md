## Purpose

Provide hand-authored UE-feature source fixtures (`UCLASS`, Actor, World) through the existing code database, separate from core Language.

## Requirements

### Requirement: Admitted Unreal inventory

The corpus SHALL expose every accepted Unreal FileTag under prefix `Unreal/`, including first-batch pockets Casting, Strings, GarbageCollection, Input, Events, Reflection, ActorClass, Hooks, World/Actor, World/Component, World/Blueprint, World/Streaming, and World/Subsystem, with complete versions and valid author metadata. A FileTag SHALL NOT be required to contain a version named `root`.

#### Scenario: Query Unreal casting and a World actor pocket

- **WHEN** the admitted catalog is queried for `Unreal/Casting` and `Unreal/World/Actor`
- **THEN** each FileTag returns at least one parentless version
- **AND** `FindFiles` with topic Unreal does not return `Language/Casting/ClassHandleCast`
- **AND** no Unreal query requires VersionTag `root`

    > Boundaries: Language FileTags stay under `Language/`. The 580 Bindings leftovers are not in this inventory.

### Requirement: UE material is not Language

The Language catalog SHALL NOT admit UClass/WorldStory programs that belong to Unreal.

#### Scenario: Language FindFiles ignores Unreal tags

- **WHEN** `FindFiles` is called with topic Language
- **THEN** the result does not contain a FileTag starting with `Unreal/`
- **BUT** host-free Class/Inheritance pockets remain Language
