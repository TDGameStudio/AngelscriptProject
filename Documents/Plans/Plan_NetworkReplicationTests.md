# 网络复制与 RPC 验证闭环计划

## 背景与目标

### 背景

- 当前插件并非完全没有网络支持。`Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` 已解析 `NetMulticast`、`Client`、`Server`、`BlueprintAuthorityOnly`、`Replicated`、`ReplicationCondition`、`ReplicatedUsing`；`ClassGenerator/AngelscriptClassGenerator.cpp` 会把这些描述写入 `FUNC_Net*` / `FUNC_BlueprintAuthorityOnly` / `CPF_Net` / `CPF_RepNotify`；`Core/AngelscriptEngine.cpp` 会校验 `ReplicatedUsing` 回调签名；`Core/AngelscriptComponent.cpp` 会在 `FUNC_NetValidate` 路径先执行脚本 `_Validate`。
- 当前插件也保留了最小网络测试 seam：`Plugins/Angelscript/Source/AngelscriptRuntime/Testing/Network/FakeNetDriver.h/.cpp` 与 `Testing/LatentAutomationCommand.cpp` 已把脚本类复制列表接入 `GetLifetimeScriptReplicationList()`。
- 当前真正薄弱的是**验证闭环和用户可见性**：`Plugins/Angelscript/Source/AngelscriptTest/` 下尚无 `Networking/` 主题目录，也没有 `AngelscriptRuntime/Tests/*FakeNetDriver*` 基线测试；插件内没有独立 `.as` 示例目录，当前可直接命中的网络示例只剩 `Examples/AngelscriptScriptExampleActorTest.cpp` 与 `Examples/AngelscriptScriptExampleMovingObjectTest.cpp` 里的 `default bReplicates = true`。
- 对照 `AgentConfig.ini` 中 `References.HazelightAngelscriptEngineRoot` 指向的 Hazelight 基线，以及公开文档 `Hazelight/Docs-UnrealEngine-Angelscript/content/scripting/networking-features.md`，Hazelight 已把 `NetMulticast` / `Client` / `Server` / `BlueprintAuthorityOnly`、`Replicated`、`ReplicationCondition`、`ReplicatedUsing` 作为第一层对外能力，并提供 `Script-Examples/GASExamples/Example_GASAttributes.as` 这类 `ReplicatedUsing + OnRep` 样例。
- 当前可直接确认的一条源码级差异是：Hazelight 不仅在 `ASClass` 里额外维护 `PushModelReplicatedProperties`，并在 `GetLifetimeScriptReplicationList()` 里写入 `REPNOTIFY_OnChanged` 与 push-model 标记；它还会在 property specifier 解析与 class generation 阶段接入 `ReplicationPushModel`。当前插件虽然已支持 `Replicated` / `ReplicationCondition` / `ReplicatedUsing`，但还未接通这整条 push-model 复制链路。

### 目标

- 在**插件边界**内把网络复制与 RPC 能力拆成「源码能力是否存在」「runtime seam 是否稳定」「UE 场景测试是否覆盖」「示例与文档是否可见」四层闭环。
- 先把当前插件已经具备但缺证据的能力固化为测试，再处理当前唯一可直接确认的源码级差异（push-model / `REPNOTIFY_OnChanged` 复制列表差异）。
- 用一份独立的网络专题计划承接 `Plan_HazelightCapabilityGap.md` 中的 `P2.2`，避免网络问题继续只以一句“部分对齐”停留在总览层。

## 范围与边界

- 对比对象：当前 `Plugins/Angelscript` 与 `References.HazelightAngelscriptEngineRoot` 指向仓库中的 Angelscript 相关网络能力，以及 Hazelight 公共文档 `content/scripting/networking-features.md`。
- 纳入范围：`Replicated` / `ReplicationCondition` / `ReplicatedUsing`、`Server` / `Client` / `NetMulticast` / `NetValidate`、`BlueprintAuthorityOnly`、`FakeNetDriver`、脚本类复制列表、测试目录与回归入口、最小网络示例与文档入口。
- 排除范围：真实跨进程 client/server、真实 packet 流、完整多人玩法同步、GAS 复杂 replication 玩法矩阵、`WITH_ANGELSCRIPT_HAZE` 专属 `NetFunction` / `CrumbFunction` / `DevFunction` 路径。
- 对比口径：凡是依赖 Haze 引擎分支、`WITH_ANGELSCRIPT_HAZE` 或引擎侧补丁的行为，必须标记为 **Hazelight / 引擎侧差异**，不能直接当作普通插件缺口。

## 当前事实状态快照

### 当前插件已可直接确认的能力

- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`
  已解析 `NetMulticast`、`Client`、`Server`、`BlueprintAuthorityOnly`、`ReplicationCondition`、`ReplicatedUsing`，并把 `Server/Client` 自动接到 `bNetValidate`。
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp`
  已把 `bNetMulticast` / `bNetClient` / `bNetServer` / `bNetValidate` 写成 `FUNC_Net*`，并为 replicated property 写入 `CPF_Net`、`CPF_RepNotify` 与 replication condition。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
  已校验 `ReplicatedUsing` 目标函数存在、参数个数和参数类型。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptComponent.cpp`
  已在 `FUNC_NetValidate` 路径调用脚本 `_Validate` 并按返回值决定是否继续 RPC。
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.*`
  已保存 `bNetMulticast` / `bNetClient` / `bNetServer` / `bNetValidate` / `bBlueprintAuthorityOnly` / `bReplicated` / `bRepNotify` / `ReplicationCondition` 等描述。
- `Plugins/Angelscript/Source/AngelscriptRuntime/Testing/Network/FakeNetDriver.*` 与 `Testing/LatentAutomationCommand.cpp`
  已提供最小复制 seam，可作为 runtime / scenario 测试的起点。

### 当前插件相对 Hazelight 的直接欠缺

1. **缺少 push-model 复制链路对齐**
   - 当前 `Preprocessor/AngelscriptPreprocessor.cpp` 已解析 `Replicated`、`ReplicationCondition`、`ReplicatedUsing`，但没有像 Hazelight 那样把 `ReplicationPushModel` 作为 property specifier 接进描述符。
   - 当前 `ClassGenerator/AngelscriptClassGenerator.cpp` 会写入 `CPF_Net` / `CPF_RepNotify` 与 replication condition，但不会像 Hazelight 一样把 push-model 属性登记进 `PushModelReplicatedProperties`。
   - 当前 `ClassGenerator/ASClass.cpp` 只把 `CPF_Net` 属性加入 `FLifetimeProperty(RepIndex, ReplicationCondition)`；Hazelight 基线还会写入 `REPNOTIFY_OnChanged` 与 push-model 标记。
2. **缺少网络专题测试层**
   - 当前仓库没有 `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/*FakeNetDriver*`。
   - 当前仓库没有 `Plugins/Angelscript/Source/AngelscriptTest/Networking/`。
   - `Documents/Guides/TestCatalog.md` 没有网络复制 / RPC 专题条目。
3. **缺少用户可见的网络示例与说明**
   - 当前仓库没有插件级 `.as` 示例目录。
   - `Documents/Guides/` 下没有与 Hazelight `networking-features.md` 对等的网络能力说明。
   - 当前可直接命中的示例只证明 `default bReplicates = true`，没有 `ReplicatedUsing` / `ReplicationCondition` / `Server` / `Client` / `NetMulticast` 示例闭环。

### 不应直接算作普通插件缺口的项目

- `#if WITH_ANGELSCRIPT_HAZE` 保护下、且在 stock plugin 默认关闭的 `NetFunction`、`CrumbFunction`、`DevFunction`。
- 任何要求真实多进程网络编排、Haze 专有 replication 语义或引擎分支补丁的路径。

## 影响范围

本计划预计涉及以下操作（按需组合）：

- **复制元数据链路对齐**：补 `ReplicationPushModel` specifier 解析、push-model property 登记、`REPNOTIFY_OnChanged` 与 push-model lifetime replication list 数据流。
- **runtime 单元测试新增**：为 `FakeNetDriver`、脚本复制列表、flag materialization 补 `Angelscript.TestModule.CppTests.*`。
- **UE 场景测试新增**：在 `Angelscript.TestModule.Networking.*` 下补脚本类网络场景与负例诊断。
- **示例与文档同步**：新增最小网络 example test，并同步 `Test.md` / `TestCatalog.md` / `TestConventions.md` / 相关计划索引。

按目录分组的潜在文件清单：

Runtime/ClassGenerator（3-4 个）：
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.h` — 复制列表数据结构对齐（若引入 push-model 成员）
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/ASClass.cpp` — `GetLifetimeScriptReplicationList()` 对齐
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp` — property/function flag materialization 对齐

Runtime/Core / Preprocessor / StaticJIT（4-5 个）：
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.h` — property/function descriptor 字段对齐
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp` — `ReplicatedUsing` / compile diagnostics 维持一致
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` — networking specifier / meta 解析对齐
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/PrecompiledData.h`

Runtime/Tests（2-3 个）：
- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptFakeNetDriverTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptNetworkMetadataTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/AngelscriptScriptReplicationListTests.cpp`

TestModule/Networking / Examples（3-4 个）：
- `Plugins/Angelscript/Source/AngelscriptTest/Networking/AngelscriptNetworkingReplicationTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Networking/AngelscriptNetworkingRpcTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Networking/AngelscriptNetworkingDiagnosticsTests.cpp`
- `Plugins/Angelscript/Source/AngelscriptTest/Examples/AngelscriptScriptExampleNetworkingTests.cpp`

文档（3-5 个）：
- `Documents/Guides/Test.md`
- `Documents/Guides/TestCatalog.md`
- `Documents/Guides/TestConventions.md`
- `Plugins/Angelscript/AGENTS.md`
- `Documents/Plans/Plan_HazelightCapabilityGap.md`

## 分阶段执行计划

### Phase 1：收口源码级网络能力差异

> 目标：先把“当前插件已经支持但缺证据”的部分与“确有源码级差异”的部分拆开，避免一上来就把所有网络问题都当成 feature missing。

- [ ] **P1.1** 审计并补齐 push-model 复制元数据链路
  - 以当前 `Preprocessor/AngelscriptPreprocessor.cpp`、`ClassGenerator/AngelscriptClassGenerator.cpp`、`ClassGenerator/ASClass.cpp`、`Core/AngelscriptEngine.h` 与 Hazelight 对位实现为基准，确认 `ReplicationPushModel` specifier 是否被 parser 接收、descriptor 是否能跨 StaticJIT round-trip、class generation 是否登记 push-model property、runtime replication list 是否需要 `REPNOTIFY_OnChanged` / push-model 参数。
  - 若 stock Unreal 插件边界内可安全移植，则把 `PushModelReplicatedProperties` 与 lifetime replication list 的差距补齐；若确认依赖引擎侧能力，则显式降级为“记录边界，不阻塞本计划后续 phase”。
  - 这一步的产物必须回答清楚：哪些网络能力是**已经支持但未验证**，哪些是**确有源码差异**，哪些属于 **Haze-only / engine-side**。
- [ ] **P1.1** 📦 Git 提交：`[Runtime/Networking] Feat: align push-model replication metadata`

- [ ] **P1.2** 为现有 `ReplicatedUsing` / `_Validate` / `BlueprintAuthorityOnly` 路径建立 reflection smoke 证明
  - 当前 parser / generator / StaticJIT / runtime 调用路径都保留了这些能力描述，但仓库里没有一个稳定的自动化测试明确证明它们仍然可用。
  - 先在 runtime C++ 测试层补一组窄测试，通过编译脚本类、读取 `UFunction::FunctionFlags`、读取 property flags / replication condition、手动触发 `_Validate` 路径，把“底座存在”转成“行为有证据”。
  - 这里不追求真实 client/server，会优先使用 reflection、`UASFunction`、`UAngelscriptComponent::ProcessEvent()` 与 `FakeNetDriver` seam 固化最小可回归面。
- [ ] **P1.2** 📦 Git 提交：`[Runtime/Networking] Test: prove existing network metadata paths`

### Phase 2：建立 runtime 网络单元测试基线

> 目标：先把不依赖 World / Actor 多进程会话的 networking runtime 路径固定下来，避免后续所有网络回归都只能靠重场景测试兜底。

- [ ] **P2.1** 新增 `AngelscriptFakeNetDriverTests.cpp`
  - 落点：`Plugins/Angelscript/Source/AngelscriptRuntime/Tests/`，Automation 前缀统一用 `Angelscript.TestModule.CppTests.*`。
  - 覆盖 `UFakeNetDriver` 的构造默认值、`IsServer()` 行为、GC 生存期和最小 `UNetDriver` 继承语义，直接承接 `Plan_AngelscriptUnitTestExpansion.md` 里尚未执行的 `P3.3`。
  - 目标不是做网络协议测试，而是把后续复制 / RPC 场景依赖的 driver seam 固化成可稳定复用的 runtime baseline。
- [ ] **P2.1** 📦 Git 提交：`[Runtime/Networking] Test: add fake net driver baseline coverage`

- [ ] **P2.2** 新增脚本复制列表与 metadata materialization 测试
  - 补 `GetLifetimeScriptReplicationList()`、`ReplicatedUsing` / `ReplicationCondition` / `BlueprintAuthorityOnly` 相关的 runtime unit tests，验证 compiled script class 能把 property / function flags 正确 materialize 到反射层。
  - 若 Phase 1 落地了 push-model 对齐，这里要同步验证 push-model property 是否进入 lifetime replication list；若 Phase 1 结论是“当前边界不支持”，这里要把断言显式固定成“不支持且有文档说明”，避免未来继续误判。
  - 测试命名应突出 runtime / metadata / replication list 主题，而不是混在泛化 `Core` 或 `ClassGenerator` 文件里。
- [ ] **P2.2** 📦 Git 提交：`[Runtime/Networking] Test: cover script replication metadata materialization`

- [ ] **P2.3** 运行 runtime 网络阶段性回归
  - 执行 `Tools/RunTests.ps1 -Group AngelscriptRuntimeUnit`，并单独跑新增 `Angelscript.TestModule.CppTests.*` 前缀。
  - 目标是把 runtime seam 的失败尽量留在这一层暴露，而不是等到场景层才发现生成 flag 或 replication list 已经漂移。
- [ ] **P2.3** 📦 Git 提交：`[Runtime/Networking] Test: verify runtime networking baselines`

### Phase 3：建立 `Angelscript.TestModule.Networking.*` 场景测试层

> 目标：把网络能力从“runtime 反射可见”推进到“脚本类在 UE 场景语义中可验证”，但仍然避免一上来就承诺真实多进程 multiplayer。

- [ ] **P3.1** 创建 `Source/AngelscriptTest/Networking/` 主题目录并同步规范
  - 新目录只承接需要 `UObject` / `World` / `Actor` 生命周期的 network scenario seam；不要把纯 runtime seam 重新塞回 `Scenario`。
  - 同步更新 `Documents/Guides/TestConventions.md`、`Documents/Guides/TestCatalog.md` 与 `Plugins/Angelscript/AGENTS.md`，明确 `Angelscript.TestModule.Networking.*` 的命名、helper 和推荐命令。
  - 若现有 helper 不够表达网络场景，优先在 `Shared/` 下补最小网络专用 helper，而不是在每个 test 文件里复制 world / netdriver 搭建逻辑。
- [ ] **P3.1** 📦 Git 提交：`[Test/Networking] Docs: define networking test directory and naming`

- [ ] **P3.2** 新增复制场景测试
  - 新建 `AngelscriptNetworkingReplicationTests.cpp`，覆盖最小 `UPROPERTY(Replicated)`、`ReplicationCondition = OwnerOnly/SkipOwner`、`ReplicatedUsing` happy path。
  - 先证明“脚本类声明 → 反射信息 → lifetime replication list → `ReplicatedUsing` 回调约束”这一条链是闭环的；不要在这一阶段就追求真实 owner connection / 多角色同步。
  - 如需依赖 `ULatentAutomationCommand` / `IntegrationTestTerminator`，应把使用边界写进测试注释与文档，保证后续维护者知道这仍属于单进程 seam，而不是完整网络仿真。
- [ ] **P3.2** 📦 Git 提交：`[Test/Networking] Test: add replication scenario coverage`

- [ ] **P3.3** 新增 RPC 与 `_Validate` 场景测试
  - 新建 `AngelscriptNetworkingRpcTests.cpp`，至少覆盖 `UFUNCTION(Server)`、`UFUNCTION(Client)`、`UFUNCTION(NetMulticast)`、`UFUNCTION(Server, Unreliable)`、`BlueprintAuthorityOnly` 这几类 reflection / invocation seam。
  - `_Validate` 测试要显式走到 `UAngelscriptComponent::ProcessEvent()` 的分支，验证“validate 成功时继续 RPC、失败时触发 `RPC_ValidateFailed()`”这条当前已实现但未被专题测试保护的路径。
  - 如果真实网络调用语义在 stock plugin 边界内仍难以稳定复现，本阶段至少要固定 metadata / thunk / validate 行为，跨进程 session 另开 sibling plan。
- [ ] **P3.3** 📦 Git 提交：`[Test/Networking] Test: add rpc and validate scenario coverage`

- [ ] **P3.4** 新增网络负例与诊断断言
  - 新建 `AngelscriptNetworkingDiagnosticsTests.cpp`，覆盖 `ReplicatedUsing` 指向缺失函数、参数个数错误、参数类型错误、未知 `ReplicationCondition` 等当前 runtime / preprocessor 已具备错误消息的负例。
  - 这一步要把“当前其实会报错、但没人保护”的编译诊断固化下来，避免之后因为 refactor 把错误信息静默打断。
  - 负例优先放在编译 / 诊断最发生处，不要为了“看起来像场景测试”强行塞入 world-based 测试。
- [ ] **P3.4** 📦 Git 提交：`[Test/Networking] Test: lock replication diagnostics behavior`

- [ ] **P3.5** 运行 networking 场景阶段性回归
  - 执行新增 `Angelscript.TestModule.Networking.` 前缀，并至少复跑 `AngelscriptExamples` / `AngelscriptScenario` 的相邻波次，确认网络专题目录没有破坏现有 examples 与场景分层。
  - 如果 networking helper 复用了现有 `Shared/AngelscriptScenarioTestUtils.*`，还要补跑依赖它的 actor / component 样本，避免 helper 侧回归被网络测试遮蔽。
- [ ] **P3.5** 📦 Git 提交：`[Test/Networking] Test: verify networking scenario boundaries`

### Phase 4：补齐示例与文档入口

> 目标：把当前“源码有能力、用户看不见”的状态改成最少有 example test + 文档入口，而不是继续只靠源码搜索证明网络支持存在。

- [ ] **P4.1** 新增最小网络 example test
  - 在 `Plugins/Angelscript/Source/AngelscriptTest/Examples/` 新增 `AngelscriptScriptExampleNetworkingTests.cpp`，沿用现有 inline script 示例风格，至少展示 `default bReplicates = true`、`UPROPERTY(Replicated)`、`ReplicationCondition`、`ReplicatedUsing` 的最小脚本写法。
  - 这里优先遵循当前仓库的 example-test 组织方式，不在本计划里直接复制 Hazelight 的整套 `Script-Examples/` 目录；如果后续仍需要独立 `.as` 教学目录，再单开 sibling plan。
  - 示例代码要刻意保持“脚本作者能直接照着写”的可读性，而不是只验证 obscure internal edge case。
- [ ] **P4.1** 📦 Git 提交：`[Examples/Networking] Test: add script networking example coverage`

- [ ] **P4.2** 同步测试手册、目录总表与上位计划引用
  - 至少更新 `Documents/Guides/Test.md`、`Documents/Guides/TestCatalog.md`、`Documents/Guides/TestConventions.md`，让维护者能直接知道网络专题该跑哪些前缀、有哪些文件、属于哪一层。
  - 如本阶段新增了网络能力说明文档，应同步更新根 `AGENTS.md` 的文档导航；如果不新增新 guide，也要在现有文档里显式写出“当前网络支持以专题测试 + example test 为准”。
  - 同步回写 `Documents/Plans/Plan_HazelightCapabilityGap.md`，把原先宽泛的 `P2.2` 引用收束到本专题 plan，避免后续再次重复盘点。
- [ ] **P4.2** 📦 Git 提交：`[Docs/Networking] Docs: register networking tests and guidance`

### Phase 5：收口回归与边界复核

> 目标：在结束前再次确认“哪些差距已经收口、哪些仍是 Hazelight / 引擎侧边界”，避免把未解决项模糊留在结尾。

- [ ] **P5.1** 执行网络专题最终回归
  - 使用 `Tools/RunTests.ps1` 分别跑 runtime unit、`Angelscript.TestModule.Networking.`、`AngelscriptExamples`，必要时补 `AngelscriptScenario` 邻近波次。
  - 这一步要保留清晰的命令与结果摘要，保证未来对齐 Hazelight 网络能力时不必重新猜测“当时到底验证过什么”。
- [ ] **P5.1** 📦 Git 提交：`[Test/Networking] Test: run final networking regression wave`

- [ ] **P5.2** 复核剩余 Hazelight 差距并显式降级非目标项
  - 复核 `WITH_ANGELSCRIPT_HAZE` 相关 `NetFunction` / `CrumbFunction` / `DevFunction`、真实多进程 networking、独立 `Script-Examples/` 教学目录是否仍未对齐。
  - 对仍未落地且不属于本计划主线的项，必须在计划 closeout 或 sibling plan 里明确标记“后续研究项 / 非阻塞项”，不能把它们留成含糊的“以后可能支持”。
- [ ] **P5.2** 📦 Git 提交：`[Docs/Networking] Docs: close out remaining Hazelight networking gaps`

## 验收标准

1. 当前插件的网络能力被明确拆分成：**已实现且有测试证据**、**已实现但仅限 runtime seam**、**Hazelight / 引擎侧边界** 三类。
2. `Plugins/Angelscript/Source/AngelscriptRuntime/Tests/` 至少新增一组 `FakeNetDriver` / replication metadata 基线测试，Automation 前缀符合 `Angelscript.TestModule.CppTests.*`。
3. `Plugins/Angelscript/Source/AngelscriptTest/Networking/` 建立完成，并至少覆盖 `Replicated`、`ReplicationCondition`、`ReplicatedUsing`、`Server` / `Client` / `NetMulticast`、`_Validate` 相关 case。
4. 当前仓库至少拥有一个可直接阅读的网络 example test，不再只剩 `bReplicates = true` 这一类弱示例。
5. `Documents/Guides/Test.md`、`Documents/Guides/TestCatalog.md` 与 `Documents/Guides/TestConventions.md` 已同步说明网络专题入口与层级边界。
6. 若 push-model 对齐可在插件边界内落地，则测试与文档一起收口；若不能落地，则剩余差距被明确记录为 boundary，不再伪装成普通插件待办。

## 风险与注意事项

### 风险

1. **把 guarded Haze 路径误当成普通插件缺口**
   - `NetFunction` / `CrumbFunction` / `DevFunction` 虽然仍在当前源码里，但位于 `WITH_ANGELSCRIPT_HAZE` 守卫后、在 stock plugin 默认不启用，不能和 stock plugin 主线的 `Server` / `Client` / `NetMulticast` 混为一谈。

2. **过早把专题测试做成重型多人回归**
   - 当前测试指南明确把 Gauntlet / 多进程 session 编排视作更外层能力。本计划必须先用 `FakeNetDriver`、reflection、单进程 world seam 把最小闭环做稳，再决定是否需要 sibling plan 承接真实多人会话。

3. **push-model 差异可能受限于插件边界**
   - Hazelight 的 push-model 语义如果依赖更深的引擎集成，本计划不能为了追平而偷偷引入引擎侧补丁；要么在 stock plugin 内安全实现，要么显式降级记录。

4. **示例与文档范围失控**
   - 当前仓库没有完整 `Script-Examples/` 目录。本计划只要求补最小可复用示例与文档入口，不承担一次性复制 Hazelight 整套公开教学资产的目标。

### 已知行为变化

1. **`GetLifetimeScriptReplicationList()` 语义可能变化**
   - 若引入 `REPNOTIFY_OnChanged` / push-model 标记，依赖当前 `FLifetimeProperty(RepIndex, Condition)` 语义的 runtime 测试断言必须同步调整。
   - 影响文件：未来新增的 `AngelscriptScriptReplicationListTests.cpp`、任何直接断言 lifetime list 内容的 networking tests。

2. **新增 `Networking/` 主题目录后，文档与 AGENTS 必须同步**
   - 一旦创建 `Plugins/Angelscript/Source/AngelscriptTest/Networking/`，就必须同步更新 `Documents/Guides/TestConventions.md`、`Documents/Guides/TestCatalog.md` 与 `Plugins/Angelscript/AGENTS.md`，否则后续维护者会继续把网络测试错误地塞进 `Examples/` 或宽泛的场景目录。
