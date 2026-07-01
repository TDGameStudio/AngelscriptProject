# 网络 / 复制 / RPC 覆盖矩阵

> **本矩阵是网络测试的设计规格("头")**：每行是一个**具体可验证场景**，指导 `AngelscriptCoverageNetworkingTests.cpp` 的实现。⬜＝待实现，✅ 注明覆盖它的 `TEST_METHOD`，🚫＝fork/headless 不支持。
>
> - 测试文件：`AngelscriptCoverageNetworkingTests.cpp`（28 方法）
> - Automation 前缀：`Angelscript.TestModule.Coverage.Networking`
> - 图例见 `../coverage-matrix.md`。
> - 说明：RPC 实际路由依赖 `BlueprintCallableReflectiveFallback`；headless 下多以"编译 + 静态元数据 + 反射表面 + 权限分支"方式断言。

## 1. RPC 说明符与可靠性

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| RPC 元数据标志 | ✅ | `RPCMetadataFlags` |
| RPC 可靠性变体 | ✅ | `RPCReliabilityVariations` |
| 单类多 RPC / 带参 RPC | ✅ | `MultipleRPCsInSingleClass` `RPCWithParameters` |
| WithValidation 签名元数据 | ✅ | `RPCValidationSignatureMetadata` |
| RPC 说明符互斥静态元数据 | ✅ | `RPCSpecifierFlagsAreExclusiveStaticMetadata` |

## 2. 属性复制

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 复制属性与 LifetimeList / 继承 LifetimeList | ✅ | `ReplicatedPropertiesAndLifetimeList` `InheritedReplicationLifetimeList` |
| Actor 复制默认值 | ✅ | `ActorReplicationDefaults` |
| 复制条件元数据 / 复制元数据静态表面 | ✅ | `ReplicationConditionsMetadata` `ReplicationMetadataStaticSurface` |
| 复杂复制类型 / 带默认值的复制属性 | ✅ | `ComplexReplicatedTypes` `ReplicatedPropertiesWithDefaults` |

## 3. 网络角色与权限

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| 网络角色/模式枚举 | ✅ | `NetworkRoleAndModeEnums` |
| Pawn/Controller/本地控制查询 | ✅ | `PawnControllerAndLocalControlQueries` |
| Actor 网络角色查询可见 | ✅ | `ActorNetworkRoleQueriesAreVisible` |
| 权限查询分支 headless 执行 | ✅ | `ActorAuthorityQueryBranchesExecuteHeadless` |
| Owner 与相关性设置 | ✅ | `ActorOwnerAndRelevancySettings` |
| NetMode 查询可见 | ✅ | `WorldNetModeQueryIsVisible` |
| NetMode 查询 fork 不支持 / Actor 网络角色属性不支持 | 🚫 | `WorldNetModeQueryUnsupportedInHaze` `ActorNetworkRolePropertiesUnsupported` |

## 4. 框架表面（GameMode / GameState / PlayerState / World）

| 场景 | 状态 | 覆盖测试方法 |
|------|------|------------|
| World/GameState/ServerTravel 表面 | ✅ | `WorldGameStateAndServerTravelSurface` |
| GameMode/GameState/PlayerState 静态表面 | ✅ | `GameModeGameStateAndPlayerStateStaticSurface` |
| GameState PlayerArray 与 PlayerState 身份表面 | ✅ | `GameStatePlayerArrayAndPlayerStateIdentitySurface` |
| PlayerController 连接表面编译 | ✅ | `PlayerControllerConnectionSurfaceCompiles` |
| GameMode 登录/登出原生表面 | ✅ | `GameModeLoginLogoutNativeSurface` |
| Actor 休眠/更新原生表面 | ✅ | `ActorDormancyAndUpdateNativeSurface` |
| 控制台/ClientTravel 边界 | 🚫 | `NetworkConsoleAndClientTravelBoundaries` |

---

**对应测试方法**：28 方法。
**待实现（⬜）**：当前无硬缺口；真实多机网络往返非 headless 范畴，部分网络模式查询为 fork 边界。
