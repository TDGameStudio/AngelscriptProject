# 网络 / 复制 / RPC 覆盖矩阵

> 域：RPC 说明符与可靠性、属性复制与生命周期、网络角色/模式、权限查询、GameMode/GameState/PlayerState 表面。
> 测试文件：`AngelscriptCoverageNetworkingTests.cpp`（Automation 前缀 `Angelscript.TestModule.Coverage.Networking`）。
> 归属：OpenSpec `test-coverage-matrix-consolidation`。图例见 `../coverage-matrix.md`。

| 状态 | 方法数 |
|------|-------|
| 🟡 | 28 |

## 测试方法清单

| # | TEST_METHOD | 覆盖点 |
|---|-------------|--------|
| 1 | RPCMetadataFlags | RPC 元数据标志 |
| 2 | ReplicatedPropertiesAndLifetimeList | 复制属性与 LifetimeList |
| 3 | InheritedReplicationLifetimeList | 继承复制 LifetimeList |
| 4 | ActorReplicationDefaults | Actor 复制默认值 |
| 5 | ReplicationConditionsMetadata | 复制条件元数据 |
| 6 | RPCReliabilityVariations | RPC 可靠性变体 |
| 7 | ComplexReplicatedTypes | 复杂复制类型 |
| 8 | ActorOwnerAndRelevancySettings | Owner/相关性设置 |
| 9 | MultipleRPCsInSingleClass | 单类多 RPC |
| 10 | RPCWithParameters | 带参 RPC |
| 11 | RPCValidationSignatureMetadata | WithValidation 签名元数据 |
| 12 | ReplicatedPropertiesWithDefaults | 带默认值的复制属性 |
| 13 | NetworkRoleAndModeEnums | 网络角色/模式枚举 |
| 14 | PawnControllerAndLocalControlQueries | Pawn/Controller/本地控制查询 |
| 15 | WorldGameStateAndServerTravelSurface | World/GameState/ServerTravel 表面 |
| 16 | GameModeGameStateAndPlayerStateStaticSurface | GameMode/GameState/PlayerState 静态表面 |
| 17 | WorldNetModeQueryIsVisible | NetMode 查询可见 |
| 18 | WorldNetModeQueryUnsupportedInHaze | NetMode 查询 fork 不支持边界 |
| 19 | ActorNetworkRoleQueriesAreVisible | Actor 网络角色查询可见 |
| 20 | ActorAuthorityQueryBranchesExecuteHeadless | 权限查询分支 headless 执行 |
| 21 | ActorNetworkRolePropertiesUnsupported | Actor 网络角色属性不支持边界 |
| 22 | ReplicationMetadataStaticSurface | 复制元数据静态表面 |
| 23 | RPCSpecifierFlagsAreExclusiveStaticMetadata | RPC 说明符互斥静态元数据 |
| 24 | NetworkConsoleAndClientTravelBoundaries | 控制台/ClientTravel 边界 |
| 25 | GameStatePlayerArrayAndPlayerStateIdentitySurface | GameState PlayerArray/身份表面 |
| 26 | PlayerControllerConnectionSurfaceCompiles | PlayerController 连接表面编译 |
| 27 | GameModeLoginLogoutNativeSurface | GameMode 登录/登出原生表面 |
| 28 | ActorDormancyAndUpdateNativeSurface | Actor 休眠/更新原生表面 |

## 已知边界

- RPC 实际网络路由依赖 `BlueprintCallableReflectiveFallback`，不能直绑裸 thunk；多数复制/RPC 在 headless 下以"编译 + 静态元数据 + 反射表面"方式断言。部分网络模式查询 fork 不支持（`*Unsupported*` 方法）。
