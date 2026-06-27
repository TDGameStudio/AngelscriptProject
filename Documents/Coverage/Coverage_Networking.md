# AngelScript 网络和复制全覆盖矩阵

> 本文覆盖 AngelScript 中 **网络复制和多人游戏**的所有用法。
> 包括属性复制、RPC、网络角色、连接管理等。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| 属性复制 | `AngelscriptTest/Coverage/AngelscriptCoverageReplicationTests.cpp` | ⬜ 计划 |
| RPC 调用 | `AngelscriptTest/Coverage/AngelscriptCoverageRPCTests.cpp` | ⬜ 计划 |
| 网络角色 | `AngelscriptTest/Coverage/AngelscriptCoverageNetworkRoleTests.cpp` | ⬜ 计划 |
| 多人测试 | PIE 多人环境 | ⬜ 需要特殊环境 |

## ⚠️ 重要说明

**网络测试需要 PIE 多人环境**：
- 需要至少 2 个客户端
- 需要专用服务器模式或 Listen Server
- 测试复杂度高，需要独立测试套件

---

## 子矩阵 1：属性复制基础

### 1.1 Replicated 说明符

| 说明符 | 写法 | 状态 | 说明 |
|-------|------|------|------|
| Replicated | `UPROPERTY(Replicated) int Health;` | ⬜ | 基础复制 |
| ReplicatedUsing | `UPROPERTY(ReplicatedUsing=OnRep_Health) int Health;` | ⬜ | 复制+回调 |

### 1.2 GetLifetimeReplicatedProps

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 注册复制属性 | `GetLifetimeReplicatedProps(TArray<FLifetimeProperty>&)` | ⬜ | 必须实现 |
| DOREPLIFETIME | `DOREPLIFETIME(ClassName, PropertyName)` | ⬜ | 无条件复制 |
| DOREPLIFETIME_CONDITION | `DOREPLIFETIME_CONDITION(Class, Prop, Condition)` | ⬜ | 条件复制 |

### 1.3 复制条件（Replication Conditions）

| 条件 | 枚举值 | 状态 | 说明 |
|------|-------|------|------|
| None | `COND_None` | ⬜ | 无条件 |
| InitialOnly | `COND_InitialOnly` | ⬜ | 仅初始 |
| OwnerOnly | `COND_OwnerOnly` | ⬜ | 仅所有者 |
| SkipOwner | `COND_SkipOwner` | ⬜ | 跳过所有者 |
| SimulatedOnly | `COND_SimulatedOnly` | ⬜ | 仅模拟客户端 |
| AutonomousOnly | `COND_AutonomousOnly` | ⬜ | 仅自主客户端 |
| ReplayOrOwner | `COND_ReplayOrOwner` | ⬜ | 回放或所有者 |
| Custom | `COND_Custom` | ⬜ | 自定义 |

### 1.4 RepNotify 回调

| 场景 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 声明回调 | `UFUNCTION() void OnRep_Health();` | ⬜ | |
| 触发时机 | 属性值改变时 | ⬜ | 客户端调用 |
| 获取旧值 | （需手动保存） | ⬜ | |

---

## 子矩阵 2：RPC（Remote Procedure Call）

### 2.1 Server RPC

| 说明符 | 写法 | 状态 | 说明 |
|-------|------|------|------|
| Server | `UFUNCTION(Server) void ServerDoAction();` | ⬜ | 客户端→服务器 |
| Server + Reliable | `UFUNCTION(Server, Reliable) void ServerDoAction();` | ⬜ | 可靠传输 |
| Server + Unreliable | `UFUNCTION(Server, Unreliable) void ServerDoAction();` | ⬜ | 不可靠 |
| Server + WithValidation | `UFUNCTION(Server, Reliable, WithValidation)` | ⬜ | 需验证函数 |

### 2.2 Client RPC

| 说明符 | 写法 | 状态 | 说明 |
|-------|------|------|------|
| Client | `UFUNCTION(Client) void ClientShowMessage();` | ⬜ | 服务器→特定客户端 |
| Client + Reliable | `UFUNCTION(Client, Reliable)` | ⬜ | 可靠传输 |
| Client + Unreliable | `UFUNCTION(Client, Unreliable)` | ⬜ | 不可靠 |

### 2.3 NetMulticast RPC

| 说明符 | 写法 | 状态 | 说明 |
|-------|------|------|------|
| NetMulticast | `UFUNCTION(NetMulticast) void MulticastExplode();` | ⬜ | 服务器→所有客户端 |
| NetMulticast + Reliable | `UFUNCTION(NetMulticast, Reliable)` | ⬜ | 可靠 |
| NetMulticast + Unreliable | `UFUNCTION(NetMulticast, Unreliable)` | ⬜ | 不可靠（推荐） |

### 2.4 RPC Validation

| 操作 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 验证函数 | `bool ServerDoAction_Validate() { return true; }` | ⬜ | 防作弊 |
| 实现函数 | `void ServerDoAction_Implementation() { ... }` | ⬜ | 实际逻辑 |
| 调用 | `ServerDoAction();` | ⬜ | 自动路由 |

---

## 子矩阵 3：网络角色和权限

### 3.1 网络角色（ENetRole）

| 角色 | 枚举值 | 状态 | 说明 |
|------|-------|------|------|
| Authority | `ROLE_Authority` | ⬜ | 服务器 |
| AutonomousProxy | `ROLE_AutonomousProxy` | ⬜ | 所有者客户端 |
| SimulatedProxy | `ROLE_SimulatedProxy` | ⬜ | 其他客户端 |
| None | `ROLE_None` | ⬜ | 无网络 |

### 3.2 网络角色查询

| 查询 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 获取本地角色 | `GetLocalRole()` | ⬜ | 本机角色 |
| 获取远程角色 | `GetRemoteRole()` | ⬜ | 对端角色 |
| 是否服务器 | `HasAuthority()` / `GetLocalRole() == ROLE_Authority` | ⬜ | |
| 是否客户端 | `GetLocalRole() < ROLE_Authority` | ⬜ | |

### 3.3 网络模式（ENetMode）

| 模式 | 枚举值 | 状态 | 说明 |
|------|-------|------|------|
| Standalone | `NM_Standalone` | ⬜ | 单机 |
| DedicatedServer | `NM_DedicatedServer` | ⬜ | 专用服务器 |
| ListenServer | `NM_ListenServer` | ⬜ | 监听服务器 |
| Client | `NM_Client` | ⬜ | 客户端 |

### 3.4 权限检查宏

| 宏 | 状态 | 说明 |
|------|------|------|
| `HasAuthority()` | ⬜ | 是否有权限 |
| `IsLocallyControlled()` | ⬜ | 是否本地控制 |
| `IsNetMode(NM_Client)` | ⬜ | 检查网络模式 |

---

## 子矩阵 4：Actor 复制设置

### 4.1 Actor 复制配置

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 启用复制 | `bReplicates = true;` | ⬜ | 构造函数设置 |
| 复制移动 | `bReplicateMovement = true;` | ⬜ | 自动复制 Transform |
| 设置所有者 | `SetOwner(AActor)` | ⬜ | 网络所有权 |
| 获取所有者 | `GetOwner()` | ⬜ | |
| 始终相关 | `bAlwaysRelevant = true;` | ⬜ | 所有客户端可见 |
| 仅所有者可见 | `bOnlyRelevantToOwner = true;` | ⬜ | |
| 网络优先级 | `NetPriority = 1.0f;` | ⬜ | 更新频率 |
| 更新频率 | `NetUpdateFrequency = 10.0f;` | ⬜ | 每秒更新次数 |

### 4.2 连接相关性

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 是否相关 | `IsNetRelevantFor(...)` | ⬜ | 对特定连接是否可见 |
| 休眠 | `SetNetDormancy(...)` | ⬜ | 降低更新频率 |

---

## 子矩阵 5：连接和会话

### 5.1 PlayerController

| 操作 | 方法 | 状态 | 说明 |
|------|------|------|------|
| 获取 PlayerController | `GetPlayerController()` | ⬜ | |
| 是否本地 PlayerController | `IsLocalPlayerController()` | ⬜ | |
| 客户端旅行 | `ClientTravel(URL, ...)` | ⬜ | 切换地图 |

### 5.2 PlayerState

| 特性 | 状态 | 说明 |
|------|------|------|
| 玩家信息 | ⬜ | 名称、分数等 |
| 跨地图保留 | ⬜ | 切换地图不销毁 |
| 自动复制 | ⬜ | 所有客户端可见 |

### 5.3 GameMode（仅服务器）

| 特性 | 状态 | 说明 |
|------|------|------|
| 仅服务器存在 | ⬜ | 客户端无 GameMode |
| 玩家登录 | `PostLogin(APlayerController)` | ⬜ |
| 玩家登出 | `Logout(AController)` | ⬜ |

### 5.4 GameState

| 特性 | 状态 | 说明 |
|------|------|------|
| 游戏状态 | ⬜ | 比赛时间、队伍信息等 |
| 自动复制 | ⬜ | 所有客户端可见 |
| PlayerArray | ⬜ | 所有玩家状态 |

---

## 子矩阵 6：网络优化

### 6.1 相关性优化

| 技术 | 状态 | 说明 |
|------|------|------|
| 距离剔除 | ⬜ | 远处对象不复制 |
| 休眠（Dormancy） | ⬜ | 静止对象降低频率 |
| 仅所有者相关 | ⬜ | 只对所有者可见 |
| 网络优先级 | ⬜ | 重要对象优先更新 |

### 6.2 带宽优化

| 技术 | 状态 | 说明 |
|------|------|------|
| 条件复制 | ⬜ | 按需复制属性 |
| 更新频率 | ⬜ | 降低更新频率 |
| Delta 压缩 | ⬜ | 仅复制变化 |

---

## 子矩阵 7：网络调试

### 7.1 调试工具

| 工具 | 命令 | 状态 | 说明 |
|------|------|------|------|
| 网络模拟 | `Net PktLag=100` | ⬜ | 模拟延迟 |
| 丢包模拟 | `Net PktLoss=10` | ⬜ | 模拟丢包 |
| 显示网络统计 | `stat net` | ⬜ | 带宽统计 |
| 显示网络图 | `stat netgraph` | ⬜ | 网络图表 |

### 7.2 日志

| 日志类别 | 状态 | 说明 |
|---------|------|------|
| LogNet | ⬜ | 网络日志 |
| LogNetTraffic | ⬜ | 流量日志 |
| LogRep | ⬜ | 复制日志 |

---

## 子矩阵 8：网络使用场景

### 8.1 角色同步

| 场景 | 状态 | 方法 |
|------|------|------|
| 移动复制 | ⬜ | bReplicateMovement |
| 生命值同步 | ⬜ | Replicated + OnRep |
| 动画状态 | ⬜ | Replicated 变量 |

### 8.2 武器射击

| 场景 | 状态 | 方法 |
|------|------|------|
| 开火请求 | ⬜ | Server RPC |
| 命中验证 | ⬜ | 服务器检查 |
| 特效播放 | ⬜ | Multicast RPC |

### 8.3 拾取物品

| 场景 | 状态 | 方法 |
|------|------|------|
| 拾取请求 | ⬜ | Server RPC |
| 物品销毁 | ⬜ | 服务器销毁+自动复制 |
| 背包更新 | ⬜ | Replicated 数组 |

---

## 子矩阵 9：常见网络模式

### 9.1 客户端预测

| 技术 | 状态 | 说明 |
|------|------|------|
| 本地预测移动 | ⬜ | CharacterMovement |
| 服务器校正 | ⬜ | 位置回滚 |

### 9.2 延迟补偿

| 技术 | 状态 | 说明 |
|------|------|------|
| 插值 | ⬜ | 平滑移动 |
| 外推 | ⬜ | 预测位置 |

---

## 计划测试方法清单

### AngelscriptCoverageReplicationTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `ReplicatedProperty` | Replicated 属性 |
| `ReplicatedUsing` | RepNotify 回调 |
| `ReplicationConditions` | COND_OwnerOnly 等 |
| `GetLifetimeReplicatedProps` | 注册复制属性 |
| `ReplicateMovement` | bReplicateMovement |

### AngelscriptCoverageRPCTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `ServerRPC` | Server RPC 调用 |
| `ClientRPC` | Client RPC 调用 |
| `MulticastRPC` | Multicast RPC 调用 |
| `RPCReliability` | Reliable vs Unreliable |
| `RPCValidation` | WithValidation |

### AngelscriptCoverageNetworkRoleTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `NetworkRoles` | Authority/AutonomousProxy/SimulatedProxy |
| `HasAuthority` | 权限检查 |
| `IsLocallyControlled` | 本地控制检查 |
| `NetworkMode` | Standalone/Client/Server |
| `SetOwner` | 网络所有权 |

---

## 待补充清单

### 🔴 高优先级

1. **属性复制基础**（Replicated / ReplicatedUsing）
2. **RPC 三种类型**（Server / Client / Multicast）
3. **网络角色检查**（HasAuthority）

### 🟡 中优先级

4. **复制条件**（OwnerOnly / SkipOwner）
5. **RPC 验证**（WithValidation）
6. **Actor 复制设置**（bReplicates / NetUpdateFrequency）

### 🟢 低优先级

7. **网络优化**（相关性 / 休眠）
8. **网络调试工具**
9. **高级网络模式**（客户端预测）

---

## ⚠️ 测试难点和要求

### 测试环境要求

1. **PIE 多人模式**
   - 至少 2 个客户端
   - 专用服务器或 Listen Server
   - 需要特殊的测试 harness

2. **验证困难**
   - 需要在不同客户端验证状态
   - 需要模拟网络延迟和丢包
   - 需要异步等待复制完成

3. **测试隔离**
   - 网络测试应独立于其他测试
   - 需要更长的超时时间
   - 可能需要专用的 CI 环境

### 建议的测试策略

1. **基础功能测试**
   - 在单机环境验证 API 可用性
   - 验证编译通过
   - 验证函数签名正确

2. **集成测试**
   - PIE 多人环境
   - 真实网络场景
   - 端到端验证

3. **分离测试套件**
   - 基础测试：不需要网络，快速
   - 网络测试：需要 PIE，慢速，独立标签

---

## 总结

网络和复制是 **多人游戏的核心**：
- 属性复制 → 状态同步
- RPC → 客户端-服务器通信
- 网络角色 → 权限管理

**估计工作量**：
- 基础 API 测试：3 个文件，15 个方法
- 完整网络测试：需要专用 PIE 测试环境
- **优先级**：🔴🔴 高（多人游戏必需，但测试复杂）

**特殊说明**：
- 网络测试需要独立的测试套件
- 建议先做基础 API 验证
- 完整的网络测试可以后续独立进行
