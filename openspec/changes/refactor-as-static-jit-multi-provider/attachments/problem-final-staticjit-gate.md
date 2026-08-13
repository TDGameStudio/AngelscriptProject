# 最终 StaticJIT 门禁的递进排障记录

日期：2026-08-13

这份附件记录 `RunStaticJITTests.ps1 -Mode All` 在最终门禁中发现的两个问题，重点说明为什么问题会一层一层出现、修复应放在哪一层，以及以后如何复现和判断。

## 1. 测试流程为什么能发现这些问题

最终 runner 严格按下面的真实消费顺序执行：

1. 基线 Editor 构建；
2. `AngelscriptTestJIT -Mode=Generate` 生成 committed TestJIT Provider；
3. 再次运行 UBT，证明刚生成的 C++ 能被真实编译；
4. `AngelscriptTestJIT -Mode=Verify` 做只读、逐文件校验；
5. 执行完整 `Angelscript.TestModule.StaticJIT` 自动化前缀。

这几层不能相互替代。结构测试能证明模板文本，生成后 UBT 才能发现 C++ 值类别/链接问题，完整前缀则会进入 Cache artifact 编码、Provider 匹配和实际生成源码路径。

## 2. 问题一：固定 TestJIT carrier 对临时 View 取地址

### 现象

第一次最终运行在第三步生成后构建失败：

```text
AngelscriptTestJITModule.cpp(18,49): error C2102
return &GetGeneratedAngelscriptJITProviderView();
```

生成 accessor 为了让 Live Coding 后每次观察都重建最新 generation/entries/references，已经改为按值返回 `FAngelscriptJITProviderView`。项目脚手架 selector 已用 `thread_local` 暂存，但固定 `AngelscriptTestJIT` carrier 漏掉了同样的 ABI 适配。

### 解决位置

- `AngelscriptTestJITModule.cpp`：用 `static thread_local FAngelscriptJITProviderView View` 保存本线程指针稳定的临时 View，每次查询先从当前 patch accessor 重新赋值；
- `AngelscriptJITTestModuleOwnershipTests.cpp`：加入结构回归，要求 fixed carrier 与项目 selector 使用同一观察语义，并禁止再次出现对按值返回结果直接取地址。

不应把 accessor 改回函数局部 `static const View`。真实 Editor `r4` 已证明该对象会跨 Live Coding patch 保留旧 Provider generation。

### 证据

- 原始生成态构建失败：`Saved/Build/staticjit-multiprovider-final_03_generated_build/20260813_144137_645_b1100526`；
- 修复后构建：`Saved/Build/static-jit-testjit-livecoding-view-green-build-r2/20260813_144731_737_e8bff7cc`；
- ownership 回归 `8/8 PASS`：`Saved/Tests/static-jit-testjit-livecoding-view-green/20260813_144802_389_5add2283`。

## 3. 问题二：内存测试模块缺稳定坐标，修正后暴露 reader 崩溃

### 第一层现象：稳定身份 fail-closed

完整 StaticJIT 报告为 `128 Success + 10 SuccessWithWarnings + 1 Fail`。唯一失败是：

```text
TArrayIndexCustomCall
Diagnostic module identity failed: Module has no unique logical source coordinate
```

测试用 `CompileModuleFromMemory` 编译模块，却仍传入普通文件名 `StaticJITTArrayIndexCustomCall.as`。辅助函数只有在输入是规范的虚拟路径时才会填充 `FAngelscriptModuleDesc::Code[0].VirtualPath`，而 Cache V2 / Static JIT 的稳定 `ModuleKey` 必须来自逻辑 mount、相对虚拟路径和模块名。

### 第一层解决位置

修复测试夹具，使用：

```text
/Angelscript/Memory/StaticJITNativeForms/TArrayIndexCustomCall.as
```

不放宽 `TryBuildModuleKey`。没有稳定坐标的模块不能安全参与跨进程 Cache、生成文件归属或 Provider 匹配，生产代码继续拒绝才是正确行为。

### 第二层现象：底层 reader 空指针

规范路径让测试越过身份校验后，`asCReader::ReadUsedFunctions()` 在解析模板 `$beh0` constructor 时崩溃：

```text
EXCEPTION_ACCESS_VIOLATION
as_restore.cpp:1766
asDWORD* bc = f->scriptData->byteCode.AddressOf();
```

`TArray<int>` 的 constructor 列表允许同时出现 native constructor 和编译器生成的 script stub。旧 reader 假定每一个条目都是带 `scriptData` 的 stub，直接解引用；AngelScript 2.38 参考源码中也保留了同一假定，但当前 UE 绑定表实际违反该假定。

### 第二层解决位置

修复放在 vendored AngelScript reader，而不是 Cache codec 外层：

- reader 是实际遍历 `beh.constructors` 并解释 stub 字节码的唯一所有者；
- Cache codec 无法在不复制 reader 内部解析逻辑的前提下提前判断哪个 constructor 会被访问；
- hostile/不兼容 artifact 的验证路径必须返回拒绝或继续匹配，不能因引擎中存在 native constructor 而崩溃。

具体防御包括：

- constructor function ID 读取前做数组范围校验；
- 跳过空 function 和没有 `scriptData` 的 native function；
- 按 `byteCode.GetLength()` 有界扫描 stub，拒绝零长度或越界 instruction；
- 从 `CALLSYS` 得到的真实 function ID 再做范围校验；
- direct-constructor fallback 同样先校验 ID。

### 证据

- 完整前缀第一轮报告：`Saved/Tests/staticjit-multiprovider-final-r2_05_tests/20260813_145206_300_fdb26386`；
- 崩溃日志：`Saved/Tests/static-jit-native-form-virtual-path-green/20260813_150218_287_4a46044a`；
- 崩溃快照：`Saved/Angelscript/CrashSnapshots/23188_20260813_150316_854/AngelscriptCrashSnapshot.json`；
- reader 修复构建：`Saved/Build/static-jit-template-constructor-reader-green-build/20260813_150527_081_5c9e194c`；
- 原崩溃用例修复后 `1/1 PASS`：`Saved/Tests/static-jit-template-constructor-reader-green/20260813_150540_460_c6e40f8a`。

## 4. 可复用判断规则

以后遇到类似问题时按边界判断修复位置：

- 测试数据没有真实系统要求的身份/生命周期信息：修夹具，不弱化生产契约；
- generated accessor/ABI 改变但某个 carrier 没同步：修 carrier，并给所有 carrier 增加同构结构测试；
- 解析器在合法引擎状态或不可信输入上崩溃：在解析器内部做有界、空值和索引防御；
- Provider/Cache 不匹配但 VM 可继续执行：保持 fail-closed，并把 typed reason 写入 diagnostics；
- 只有同时经过结构测试、生成后构建、只读 Verify、完整前缀和真实 Editor 状态迁移，才可以声明整个链路闭合。

完整 `Verify + StaticJIT` 复跑结果在完成后追加到 `verification.md`；本附件保留 RED 过程，不用最终 GREEN 覆盖失败历史。

## 5. 广域 Cache 门禁的 timeout 不是测试失败

第一次最终 Cache 前缀使用 `900000 ms`。runner 在 `899788 ms` 精确触发超时并终止进程树；此前已经连续完成 402 个测试，最后完成的是 `SecondEngineConsumesPersistedTwoModuleGenerationBeforeFrontend`，第 403 个 `SecondPreparedModuleFailureRollsBackBatchBeforeNormalCompileFallback` 正在正常初始化第 42 个独立 Engine。日志中没有 assertion、fatal error 或 crash snapshot，也因受控终止而没有最终 JSON 报告。

这类结果只能记为“门禁未完成”，不能记为 PASS，也不能归类成功能 RED。Cache 前缀包含大量 fresh-Engine/full-binding/store-restore 场景，最终重跑将单项 timeout 提高到 `1800000 ms`；configured All suite 也必须为每个 entry 使用足够长的同级 timeout。

超时证据：`Saved/Tests/staticjit-final-cache_01_Cache/20260813_151950_980_98b84ae0`。

## 6. configured All 诊断与影响面门禁收敛

最终阶段曾按原计划启动：

```powershell
.\Tools\RunTestSuite.ps1 -Suite All \
  -LabelPrefix staticjit-final-all \
  -TimeoutMs 1800000 -ContinueOnFail
```

该 runner 内部不是并行单测：37 个前缀串行启动独立
`UnrealEditor-Cmd`，每个会话使用一个 Automation worker 逐项派发。
`ContinueOnFail` 只保留失败后的后续报告。同期机器上另有一个用户拥有的
worktree 在运行自己的 All/Cache；它不属于本次命令，但会造成一定 CPU/磁盘
测量噪声，因此本轮时长不能直接作为硬门槛。

按用户批准，最终门禁收敛为本变更的完整影响面矩阵，不再要求重复覆盖 GAS、
Widget 等无关产品表面。停止请求发出前已经完成并落盘 23 个前缀报告：
`2643` 项通过（其中 `273` 项为 `SuccessWithWarnings`）、`1` 项失败、
`0` 项未运行，共 `2644` 项。权威逐前缀 JSON 保留在
`Saved/Tests/staticjit-final-all_01_Editor` 至 `staticjit-final-all_23_GC`。

唯一失败为：

```text
Angelscript.TestModule.Functional.Inheritance.
FAngelscriptInheritanceTests.Basic
expected: int Test() | Line 1 | Col 227
actual:   int Test() | Line 1 | Col 205
```

异常仍是预期的 `Null pointer access`。独立 `1/1` 复现证明它不是 All 顺序
污染：`Saved/Tests/staticjit-final-functional-inheritance-basic-repro/20260813_172721_583_990be5f1`。
脚本中的第 205 列是未构造 `Derived Instance` 的第一次解引用
`Instance.SetBase(10)`；第 227 列是第二次解引用。测试改为精确匹配第一次
解引用，未放宽异常类型、模块或栈帧检查。增量构建通过：
`Saved/Build/staticjit-functional-inheritance-column-green-build/20260813_172855_868_fb36c9c5`；
完整继承小前缀 `5/5 PASS`：
`Saved/Tests/staticjit-final-functional-inheritance-green/20260813_172923_402_7302d904`。

最终 `verification.md` 使用上述 JSON 汇总数，并以
StaticJIT、Cache、Runtime、HotReload、UASFunction、Editor/PIE/Live Coding、
TestJIT、项目 Generate/Verify 和 Development/Shipping 包为完成证据。
