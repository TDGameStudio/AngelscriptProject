# Cache V2 默认关闭与后续重设计边界（2026-08-24）

## 决策

本次 `refactor-as-canonical-typed-ast-compiler` 不再把 Cache V2 的完整
跨 Engine 恢复、调用族重建和函数粒度增量复用作为新版 AST/编译器切换的
完成条件。

- Cache V2 产品默认值改为关闭。
- 关闭不是“只不读磁盘”，而是完整绕过 Cache 编译生命周期。
- `.as` 源码仍是权威输入，并正常完成预处理、编译、模块/AST 发布和执行。
- 已实现的 `ASTBodySidecar`、ExactStartup、DTO 和专项测试保留，不删除。
- 这些代码只能由项目配置或测试的显式 opt-in 进入。
- 未完成的跨 Engine/增量部分留给后续独立 Cache V2 redesign OpenSpec。

```text
产品默认路径（本次主线）

 .as source
     |
     v
 Preprocessor -> Parser/Sema -> Canonical AST -> Bytecode/StaticJIT consumers
                                      |
                                      +-> Snapshot / Hot Reload / tools

 Cache V2 = OFF
     X  ExactStartup restore
     X  initial compile capture
     X  Hot Reload capture
     X  function reuse publication
     X  shutdown persistence


显式实验路径（保留但不阻塞切换）

 project/test opt-in -> Cache V2 prototype
                         |- ASTBodySidecar V3
                         |- ExactStartup
                         |- pointer-free DTO/remap tests
                         `- known unfinished cross-Engine/incremental contracts
```

## 实现落点

### 产品开关

- `UAngelscriptCacheSettings::bEnableCacheV2` 的 C++ 默认值由 `true` 改为
  `false`。
- `FAngelscriptEngine` 构造时把项目设置冻结为 Engine-local 决策，避免一个
  Engine 生命周期中途出现“半开半关”。
- `FAngelscriptEngineConfig::bOverrideCacheV2Enablement` 与
  `bEnableCacheV2` 仅用于显式 host/test override；正常产品 Engine 继续读取
  项目设置。

### 真正的总闸门

当 `IsCacheV2Enabled() == false` 时：

1. `InitialCompile()` 的 ExactStartup 直接 miss，不打开持久化候选；
2. Initial source compile 不准备 `FAngelscriptCacheCompileCaptureContext`；
3. Hot Reload 不准备 Cache capture context；
4. `CompileModules()` 因没有 capture context，不进入 Cache mutation/publish；
5. Shutdown 不 flush/persist Cache generation；
6. 普通源码扫描、编译、模块发布、JIT Provider 路由继续执行。

保留 `FAngelscriptCacheService` 对象本身是为了已有只读诊断/API 的结构稳定，
不代表关闭状态仍参与编译数据流。

### 专项测试 opt-in

真实 Engine Cache 生命周期测试不再依赖全局默认开启。它们在构造测试 Engine
前显式设置：

```cpp
Config.bOverrideCacheV2Enablement = true;
Config.bEnableCacheV2 = true;
```

该规则已应用到 Settings/Shutdown、DecisionTrace、Editor/PIE lifecycle、
Flush/Maintenance、FunctionRoute、MultiModule、Production Warm/Reuse、
ServiceStoreFlush 与 StaticJIT isolation 等 Cache 专项 fixture。

## TDD 证据

### 1. 默认值红灯

先把默认设置断言改为 `IsFalse(Settings->bEnableCacheV2)`，生产默认仍为
`true` 时：

- build：成功；
- `Angelscript.TestModule.Cache.SettingsAndShutdown`：**5/6 PASS**；
- 唯一失败：`DefaultSettingsDisableCacheAndPackagedAutomaticReload`；
- 记录：
  `Saved/Tests/cta-cache-default-off-red-class/20260824_164336_161_284b2818/RunMetadata.json`。

### 2. 总闸门红灯

仅把默认值改为 false 后，日志仍出现 Compile capture/publication，证明旧开关
只挡启动复用和关机落盘，没有挡编译捕获。随后新增
`DefaultDisabledCacheColdCompilesWithoutCaptureOrPersistence`，要求源码模块和
函数存在，同时 Current/Pending/reuse/files 全部为空。实现总闸门前：

- `SettingsAndShutdown`：**5/7 PASS**；
- 失败：默认关闭仍产生 capture；旧 Cache shutdown fixture 未显式 opt-in；
- 记录：
  `Saved/Tests/cta-cache-total-gate-red/20260824_164915_268_69ff29a3/RunMetadata.json`。

### 3. 绿色结果

- Runtime/Editor build：成功；
  `Saved/Build/cta-cache-total-gate-green-build-v2/20260824_165552_066_66c7a1e7/RunMetadata.json`。
- `Angelscript.TestModule.Cache.SettingsAndShutdown`：**7/7 PASS**；
  `Saved/Tests/cta-cache-total-gate-green/20260824_165621_962_77f4513e/RunMetadata.json`。
- 默认关闭测试直接检查从源码构建出的 `Shutdown` module 和动态命名函数，
  因而不是只检查一个布尔值。
- 最终 164-action Editor/plugin rebuild：**PASS**；
  `Saved/Build/cta-cache-default-off-final-build/20260824_180259_671_c0f8af9e/RunMetadata.json`。
- 最终构建后的 `SettingsAndShutdown`：**7/7 PASS**；
  `Saved/Tests/cta-cache-default-off-final/20260824_180600_350_09993273/RunMetadata.json`。

## 保留但延期的已知问题

`AngelscriptCacheInvocationFamilyParityTests` 的跨 Engine 工厂/构造/析构调用族
恢复仍有未完成契约：第二个 Engine 的 candidate types/functions 尚未以完整的
target-Engine public view 暴露，导致调用族 parity 失败。最近的失败证据：

`Saved/Tests/cta-cache-invocation-family-parity-v4/20260824_162511_559_d8fc8641/Summary.json`

测试体和诊断全部保留，class 标记为 Disabled `#cache-v2-redesign`。本轮曾为
该问题添加一个尚不存在的 `ResolveBuildArtifactFactoryConstructor` 红灯 API，
在决定延期后已经撤回，工作树中没有遗留编译错误或空实现。

## 后续 Cache V2 redesign 至少要重新回答的问题

1. Cache 的产品目标到底是启动缓存、增量编译缓存、离线 artifact store，还是
   三者拆分；不要让一个开关同时代表多种生命周期。
2. Source/Module/Function/AST/Bytecode 的 artifact 边界和 authority 顺序。
3. 跨 Engine 恢复是完整 staging module 重建，还是只恢复独立中间表示；禁止
   依赖 producer Engine 指针、numeric ID 或私有 container 可见性。
4. 构造器、工厂、析构、lambda、import、global、funcdef 等 invocation family
   的统一 stable identity 与 target-Engine materialization 协议。
5. 当前 module-shared `ASTBodySidecar` 是否适合函数粒度增量；如果不适合，
   重新定义 record graph，而不是用测试描述不存在的 per-function 行为。
6. Capture、restore、verify、commit 必须分阶段并 validate-all/commit-all；任何
   失败不得污染 active Engine/module/snapshot。
7. Cache schema、兼容版本、safe miss、磁盘清理和 observability 的独立策略。
8. 与 canonical AST snapshot、SaveByteCode、StaticJIT Provider、Hot Reload 的
   单向依赖关系；Cache 不能重新成为编译语义 authority。

## 对本次 AST change 的完成口径

Cache V2 对本次 change 只剩以下门槛：

- 默认关闭；
- 关闭时不进入 restore/capture/persist；
- 关闭时源码编译和 Hot Reload 正常；
- Cache 专项 fixture 显式 opt-in；
- 原型代码/测试保留并清楚标注非生产完成状态。

跨 Engine AST DTO 完整恢复和函数粒度增量复用不再计入本次完成百分比，也不
能用已有 ExactStartup/sidecar 绿色测试反向证明 canonical compiler 已完成。

## 完整 Cache 前缀尝试的口径

本轮也尝试运行了完整 `Angelscript.TestModule.Cache`。该前缀包含耗时较长的
SemanticDiff 组合测试，外层执行在 15 分钟预算后失去有效汇总；子进程随后自行
退出，但没有生成可用的最终 `Summary.json`，因此这次运行记为 **inconclusive**，
既不能写成通过，也不能写成功能失败：

`Saved/Tests/cta-cache-default-off-full/20260824_170448_409_c9835ec2/RunMetadata.json`

默认关闭边界的有效绿色证据仍是窄门 `SettingsAndShutdown` **7/7 PASS**。完整
Cache 原型回归属于显式 opt-in 的后续非阻塞验证；在改进测试分桶或为
SemanticDiff 建立独立 suite 前，不再用单个超长 Cache 前缀阻塞 canonical
compiler 主线。
