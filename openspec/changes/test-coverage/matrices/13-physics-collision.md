# Physics And Collision Coverage Matrix

> **This matrix is the design specification header for physics/collision tests**: each row is a concrete verifiable scenario guiding `AngelscriptCoveragePhysicsTests.cpp` implementation. ⬜ means pending and ✅ identifies the covering `TEST_METHOD`.
>
> - Test file: `AngelscriptCoveragePhysicsTests.cpp`, 25 methods
> - Automation prefix: `Angelscript.TestModule.Coverage.Physics`
> - See `../coverage-matrix.md` for the legend.

## 1. Physics Simulation And Forces

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Physics simulation toggle and state | ✅ | `PhysicsSimulation` | SetSimulatePhysics / state readback |
| Apply force / impulse / torque | ✅ | `PhysicsForces` | AddForce/AddImpulse/AddTorque |
| Linear velocity / angular velocity | ✅ | `PhysicsVelocity` | Set/GetPhysicsLinearVelocity and related APIs |

## 2. Collision Event Dispatch

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Component-level collision events | ✅ | `CollisionEvents` | OnComponentHit/BeginOverlap |
| Actor-level collision events | ✅ | `ActorCollisionEvents` | ActorHit delegate |
| Movement-generated overlap | ✅ | `ActorOverlapGeneratedByMovement` | Overlap produced by movement |
| Component collision event dispatch chain | ✅ | `ComponentCollisionEventDispatch` | Event routing |

## 3. Trace / Overlap Queries

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Line / sweep trace | ✅ | `TraceOperations` | LineTrace/SweepTrace |
| Overlap detection | ✅ | `OverlapDetection` | OverlapMulti/Components |
| Object/Profile/Sweep trace variants | ✅ | `TraceObjectProfileAndSweepVariants` | ByObjectType/ByProfile |
| Collision query parameter containers | ✅ | `CollisionQueryParameterContainers` | FCollisionQueryParams |
| Collision object query init types | ✅ | `CollisionObjectQueryInitTypes` | FCollisionObjectQueryParams |

## 4. Collision Channels / Responses / Profile

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Collision channel and response settings | ✅ | `CollisionChannelsAndResponses` | SetCollisionResponseToChannel |
| Collision Profile and enabled modes | ✅ | `CollisionProfilesAndEnabledModes` | SetCollisionProfileName / ECollisionEnabled |
| Collision channel matrix readback | ✅ | `CollisionChannelMatrix` | All-channel response matrix |
| Collision response container operations | ✅ | `CollisionResponseContainerOperations` | FCollisionResponseContainer |

## 5. HitResult

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Basic HitResult fields | ✅ | `HitResultFields` | Location/Normal/Distance |
| Extended HitResult accessors | ✅ | `HitResultExtendedAccessors` | Extended fields |
| Physics material HitResult reference | ✅ | `PhysicsMaterialHitResultReference` | PhysMaterial reference |

## 6. Character Movement, CharacterMovementComponent

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Character movement physics settings | ✅ | `CharacterMovementPhysicsSettings` | Gravity/friction/max speed |
| Movement mode query states | ✅ | `CharacterMovementModeQueryStates` | Walking/Falling and related states |
| Movement velocity query | ✅ | `CharacterMovementVelocityQuery` | Velocity readback |

## 7. Constraints And Projectile Movement

| Scenario | Status | Coverage Test Method | Notes / Pending Work |
|------|------|------------|-------------|
| Physics constraint component settings | ✅ | `PhysicsConstraintComponentSettings` | PhysicsConstraint parameters |
| Physics constraint preset recipes | ✅ | `PhysicsConstraintPresetRecipes` | Common constraint presets |
| Projectile movement settings | ✅ | `ProjectileMovementSettings` | ProjectileMovementComponent |

---

## Summary

| Dimension | Scenarios | Status |
|------|------|------|
| 1 physics simulation and forces | 3 | ✅ |
| 2 collision event dispatch | 4 | ✅ |
| 3 Trace/Overlap queries | 5 | ✅ |
| 4 channels/responses/Profile | 4 | ✅ |
| 5 HitResult | 3 | ✅ |
| 6 character movement | 3 | ✅ |
| 7 constraints and projectile movement | 3 | ✅ |

**Corresponding test methods**: 25 methods, all ✅.
**Pending (⬜)**: no hard gaps currently. If more physics subsystems are added later, such as cloth or Chaos destruction fields, add ⬜ rows to the relevant section and schedule them.
