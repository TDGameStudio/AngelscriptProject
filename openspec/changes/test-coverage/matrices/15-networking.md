# Networking / Replication / RPC Coverage Matrix

> **This matrix is the design specification header for networking tests**: each row is a concrete verifiable scenario guiding `AngelscriptCoverageNetworkingTests.cpp` implementation. ⬜ means pending, ✅ identifies the covering `TEST_METHOD`, and 🚫 means fork/headless unsupported.
>
> - Test file: `AngelscriptCoverageNetworkingTests.cpp`, 28 methods
> - Automation prefix: `Angelscript.TestModule.Coverage.Networking`
> - See `../coverage-matrix.md` for the legend.
> - Note: real RPC routing depends on `BlueprintCallableReflectiveFallback`; in headless mode, assertions primarily cover compilation, static metadata, reflection surfaces, and authority branches.

## 1. RPC Specifiers And Reliability

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| RPC metadata flags | ✅ | `RPCMetadataFlags` |
| RPC reliability variants | ✅ | `RPCReliabilityVariations` |
| Multiple RPCs in one class / parameterized RPCs | ✅ | `MultipleRPCsInSingleClass` `RPCWithParameters` |
| WithValidation signature metadata | ✅ | `RPCValidationSignatureMetadata` |
| RPC specifier mutual-exclusion static metadata | ✅ | `RPCSpecifierFlagsAreExclusiveStaticMetadata` |

## 2. Property Replication

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Replicated properties and LifetimeList / inherited LifetimeList | ✅ | `ReplicatedPropertiesAndLifetimeList` `InheritedReplicationLifetimeList` |
| Actor replication defaults | ✅ | `ActorReplicationDefaults` |
| Replication condition metadata / replication metadata static surface | ✅ | `ReplicationConditionsMetadata` `ReplicationMetadataStaticSurface` |
| Complex replicated types / replicated properties with defaults | ✅ | `ComplexReplicatedTypes` `ReplicatedPropertiesWithDefaults` |

## 3. Network Roles And Authority

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| Network role / mode enums | ✅ | `NetworkRoleAndModeEnums` |
| Pawn / Controller / local-control queries | ✅ | `PawnControllerAndLocalControlQueries` |
| Actor network role queries visible | ✅ | `ActorNetworkRoleQueriesAreVisible` |
| Authority query branches execute headless | ✅ | `ActorAuthorityQueryBranchesExecuteHeadless` |
| Owner and relevancy settings | ✅ | `ActorOwnerAndRelevancySettings` |
| NetMode query visible | ✅ | `WorldNetModeQueryIsVisible` |
| NetMode query fork unsupported / Actor network role properties unsupported | 🚫 | `WorldNetModeQueryUnsupportedInHaze` `ActorNetworkRolePropertiesUnsupported` |

## 4. Framework Surfaces, GameMode / GameState / PlayerState / World

| Scenario | Status | Coverage Test Method |
|------|------|------------|
| World/GameState/ServerTravel surface | ✅ | `WorldGameStateAndServerTravelSurface` |
| GameMode/GameState/PlayerState static surface | ✅ | `GameModeGameStateAndPlayerStateStaticSurface` |
| GameState PlayerArray and PlayerState identity surface | ✅ | `GameStatePlayerArrayAndPlayerStateIdentitySurface` |
| PlayerController connection surface compiles | ✅ | `PlayerControllerConnectionSurfaceCompiles` |
| GameMode login/logout native surface | ✅ | `GameModeLoginLogoutNativeSurface` |
| Actor dormancy/update native surface | ✅ | `ActorDormancyAndUpdateNativeSurface` |
| Console / ClientTravel boundary | 🚫 | `NetworkConsoleAndClientTravelBoundaries` |

---

**Corresponding test methods**: 28 methods.
**Pending (⬜)**: no hard gaps currently; real multi-machine network round trips are outside headless scope, and some network-mode queries are fork boundaries.
