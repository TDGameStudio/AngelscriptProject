# Component Coverage Matrix

> **This matrix is the design specification header for component tests**: each row is a concrete verifiable scenario guiding the four test files. ⬜ means pending and ✅ identifies the covering `TEST_METHOD`.
>
> - Test files: `Component`(25) / `SceneComponent`(8) / `PrimitiveComponent`(11) / `SpecialComponent`(11) Tests.cpp
> - Automation prefix: `Angelscript.TestModule.Coverage.<Component|SceneComponent|PrimitiveComponent|SpecialComponent>`
> - See `../coverage-matrix.md` for the legend; system-level physics/collision coverage is in `13-physics-collision.md`.

## 1. UActorComponent Basics, ComponentTests 25

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Basic declaration / special type declarations | ✅ | `ComponentBasicDeclaration` `ComponentSpecialTypeDeclarations` |
| AudioComponent declaration and controls / fade and filter / routing and reflection | ✅ | `AudioComponentDeclarationAndControls` `AudioComponentFadeAndFilterControls` `AudioComponentRoutingAndReflectionSurface` |
| Property specifiers | ✅ | `ComponentPropertySpecifiers` |
| Lifecycle / ordering / multi-component and dynamic ordering / custom Super calls | ✅ | `ComponentLifecycle` `ComponentLifecycleOrdering` `ComponentActorMultiAndDynamicLifecycleOrdering` `CustomComponentLifecycleSuperCalls` |
| Tick control / configuration and prerequisites / runtime interval control | ✅ | `ComponentTickControl` `ComponentTickConfigurationAndPrerequisites` `ComponentRuntimeTickIntervalControl` |
| Activation / registration and activation | ✅ | `ComponentActivation` `ComponentRegistrationAndActivation` |
| Finding, generic/by class/by tag / tags | ✅ | `ComponentFinding` `ComponentFindingByClassAndTag` `ComponentTags` |
| Custom script component / reuse inheritance and instantiation | ✅ | `CustomScriptComponent` `CustomComponentReuseInheritanceAndInstantiation` |
| Manual NewObject registration | ✅ | `ComponentManualNewObjectRegistration` |
| Destruction / destruction callbacks and state / destroy promotes children and K2 metadata | ✅ | `ComponentDestruction` `ComponentDestructionCallbacksAndState` `ComponentDestroyComponentPromoteChildrenAndK2Metadata` |
| Scene attachment rule transforms | ✅ | `ComponentSceneAttachmentRuleTransforms` |

## 2. USceneComponent, SceneComponentTests 8

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| World / relative transform / full transform | ✅ | `SceneComponentWorldTransform` `SceneComponentRelativeTransform` `SceneComponentCompleteTransform` |
| Attachment / attachment rules / socket attachment | ✅ | `SceneComponentAttachment` `SceneComponentAttachmentRules` `SceneComponentSocketAttachment` |
| Hierarchy | ✅ | `SceneComponentHierarchy` |
| Tags | ✅ | `SceneComponentTags` |

## 3. UPrimitiveComponent, PrimitiveComponentTests 11

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Rendering / hidden in game | ✅ | `PrimitiveRendering` `PrimitiveHiddenInGame` |
| Collision setup / configuration readback / response / channel matrix readback | ✅ | `PrimitiveCollisionSetup` `PrimitiveCollisionConfigurationReadback` `PrimitiveCollisionResponse` `PrimitiveCollisionChannelMatrixReadback` |
| Collision events / Hit events | ✅ | `PrimitiveCollisionEvents` `PrimitiveHitEvents` |
| Physics / physics state readback | ✅ | `PrimitivePhysics` `PrimitivePhysicsStateReadback` |
| Trace object query readback | ✅ | `PrimitiveTraceObjectQueryReadback` |

## 4. Specialized Components, SpecialComponentTests 11

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| StaticMesh / CharacterMovement / Camera / SpringArm | ✅ | `StaticMeshComponent` `CharacterMovementComponent` `CameraComponent` `SpringArmComponent` |
| Shape components: Box / Sphere / Capsule / multiple shapes | ✅ | `BoxComponent` `SphereComponent` `CapsuleComponent` `MultipleShapeComponents` |
| Custom script SceneComponent | ✅ | `CustomScriptSceneComponent` |
| Additional default component types / specialized component operations | ✅ | `AdditionalDefaultComponentTypes` `SpecialComponentOperations` |

---

## Summary

| File | Methods |
|------|------|
| Component | 25 |
| SceneComponent | 8 |
| PrimitiveComponent | 11 |
| SpecialComponent | 11 |
| **Total** | **55** |

**Pending (⬜)**: no hard gaps currently; the component API surface is mature.
