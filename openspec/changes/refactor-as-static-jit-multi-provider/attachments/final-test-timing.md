# 最终门禁耗时观察（2026-08-13）

本文记录 `refactor-as-static-jit-multi-provider` 最终验证阶段的测试耗时，目的是把“功能是否通过”和“为什么全量验证很慢”分开。`Saved/Tests/` 中的 Automation JSON 仍是原始权威证据；本文只摘录排行、解释成本来源，并保留后续优化入口。

## 1. 已完成重点前缀排行

| 前缀/范围 | 结果 | Automation `totalDuration` | 约合分钟 | 报告 |
| --- | ---: | ---: | ---: | --- |
| Cache | 546/546 | 1036.214 s | 17.27 min | `Saved/Tests/staticjit-final-cache-r2/20260813_153515_139_8fbf71aa` |
| Runtime Engine | 130/130 | 404.617 s | 6.74 min | `Saved/Tests/staticjit-final-runtime_01_Engine/20260813_155406_789_0c62fa9f` |
| StaticJIT | 139/139 | 353.190 s | 5.89 min | `Saved/Tests/staticjit-multiprovider-final-r3_02_tests/20260813_150849_863_d5fbae11` |
| HotReload | 122/122 | 112.455 s | 1.87 min | `Saved/Tests/staticjit-final-hotreload_01_HotReload/20260813_160437_397_250caec8` |
| Runtime CppTestsLegacy | 22/22 | 81.814 s | 1.36 min | `Saved/Tests/staticjit-final-runtime_02_CppTestsLegacy/20260813_160156_911_61ad2e57` |

这些数字是测试项自身累计执行时间，不含每个独立 `UnrealEditor-Cmd` 进程约 40–55 秒的冷启动、报告序列化和退出时间。因此 37 条目的 configured `All` 墙钟时间会显著大于各报告 `totalDuration` 之和。

## 2. 当前重点范围内最慢单测

| 排名 | 单测 | 耗时 | 成本来源 |
| ---: | --- | ---: | --- |
| 1 | `StaticJIT.AOT.FreshCacheV2EnginePublishesAndExecutesCommittedProviderRoute` | 98.467 s | fresh Cache V2 Engine、完整绑定、Provider route 发布与 Native 执行 |
| 2 | `StaticJIT.AOT.MultiEngine.SequentialLoadsKeepGeneratedRegistryVisible` | 85.139 s | 多 Engine 顺序加载、Registry 可见性和生成 Provider 保活 |
| 3 | `Cache.ProductionClassGraphCompilerReuse.BodyEditRestoresUnchangedInheritedGraphAcrossThreeEngines` | 81.349 s | 三个完整 Engine、继承图捕获/恢复与 body edit 复用 |
| 4 | `StaticJIT.AOT.GeneratedOutputVerify` | 45.363 s | 重新构造生成输入并逐文件只读比较 |
| 5 | `Cache.BuildArtifactRestoreHook.MissAndCorruptCandidateCompileNormallyWithoutPartialMutation` | 31.517 s | miss/corrupt 两条恢复失败路径、正常编译回退和无部分状态验证 |

configured `All` 的 23 个已落盘前缀中，最慢单测是
`Angelscript.TestModule.Cache.ProductionClassGraphCompilerReuse.BodyEditRestoresUnchangedInheritedGraphAcrossThreeEngines`，耗时约 `79.83 s`。
该运行按用户批准提前停止，因此这里只描述已完成前缀，不把它写成全 37
前缀的最终性能排行。

测量限制：本次 configured `All` 运行期间，机器上另有一个用户拥有的
`.worktree/as-assets-singletons` All/Cache 进程。两套各自内部均为串行
Automation，但会竞争 CPU、内存带宽和磁盘。当前数据适合定位数量级和热点，
不应直接变成 CI 性能阈值。Cache 在本次 All 诊断中仍完成 `546/546`，
`totalDuration=990.6 s`；与独立运行的 `1036.214 s` 同属约 16.5–17.3 分钟
区间。已落盘 23 个前缀合计 `2644` 项：`2643` 项通过（其中 `273` 项带
警告）、`1` 项失败、`0` 项未运行；唯一失败随后通过独立复现、修正精确列号
和完整继承前缀 `5/5 PASS` 闭环。

## 3. Cache 为什么最慢

Cache 前缀不是被一个卡死用例拖慢，而是有大量必须验证进程/Engine 隔离语义的重型场景：

- 反复创建独立 `FAngelscriptEngine`，每次注册完整 UE 类型和函数绑定；
- 写入 generation 后在 fresh Engine 中恢复，验证 FunctionId 重排不影响稳定身份；
- 构造多模块、继承图、属性图、调用图和引用槽，再验证完整或部分复用；
- 对损坏、缺失、过期和不兼容 artifact 执行 fail-closed，并验证无部分 mutation；
- 验证 PIE 延迟、batch rollback、normal-compile fallback 和 shutdown flush。

第一次最终 Cache 门禁用 `900000 ms`，在已经完成 402 项时被 runner 精确终止；没有 assertion、fatal 或 crash。这证明原 timeout 小于正常墙钟成本，因此正式门禁改用每条目 `1800000 ms`。完整重跑随后 `546/546 PASS`。

## 4. 后续性能优化边界

性能优化不能通过复用本应隔离的 Engine 或删除 fresh-process 语义来换取。后续可单独立项评估：

1. 标注哪些用例必须独立 Engine、哪些纯值/codec 测试可以复用只读夹具；
2. 统计每个用例的 Engine 初始化次数和 binding callback 总耗时，而不只看 Automation 外层 duration；
3. 将同一语义矩阵中的纯输入变体合并到一次 Engine 生命周期内，但保留每个变体独立断言和诊断标签；
4. 对真正要求 fresh Engine、fresh process、PIE 或落盘恢复的场景保持现状；
5. 优先优化测试夹具和重复初始化，不改变 Cache/StaticJIT 生产契约来迎合测试时长。

本次变更只记录观察，不把测试性能重构混入 StaticJIT multi-provider 功能收尾。
