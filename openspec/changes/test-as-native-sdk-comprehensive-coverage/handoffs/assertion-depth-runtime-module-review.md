# Runtime 与 Module 逐产品断言深度审计

## 结论

本轮严格复用
`assertion-depth-engine-typesystem-embedding-review.{csv,md}` 的字段和判定口径，从
`coverage-products.psd1` 枚举 Owner 位于 `Runtime/` 与 `Module/` 的全部产品，并打开
每个产品指定的精确 `文件 | 测试类 | TEST_METHOD` 逐项核对 `Expected` 和 Evidence。

| Theme | 产品数 | Complete | ChangeRequired | Deferred |
| --- | ---: | ---: | ---: | ---: |
| Module | 19 | 3 | 16 | 0 |
| Runtime | 22 | 11 | 11 | 0 |
| NativeDebug | 10 | 10 | 0 | 0 |
| Runtime.Debug | 2 | 2 | 0 | 0 |
| 合计 | 53 | 26 | 27 | 0 |

逐产品结果、精确源码范围、缺失 oracle 和最小但充分的建议记录在
`assertion-depth-runtime-module-review.csv`。

## 判定口径

- `Compile` 必须有构建结果或精确发布结果断言。
- `Diagnostic` 必须检查拒绝结果、错误边界或拥有诊断；只有调用失败不够。
- `Metadata` 必须查询并比较精确 ID、声明、所有者、标志、索引或调试元数据。
- `Runtime` 必须执行目标并比较返回值、写回值、副作用、异常或分派结果。
- `Debug` 必须检查真实调试回调、帧、位置、局部变量、this 指针或字节码位置。
- `Bytecode` 必须检查真实字节码发布、指针/长度、opcode 或序列化结果。
- `Lifecycle` 必须观察状态转换、引用计数、回调或创建/销毁阶段。
- `Cleanup` 必须观察释放后的状态、计数、回调、模块消失或引用基线；RAII、
  `ON_SCOPE_EXIT`、`Release`、`Destroy` 和案例独占 Engine 本身都不算充分 oracle。
- `Isolation` 必须有独立 owner/control、跨 cell 不污染、旧状态缺失或基线恢复断言。
- `SaveLoad` 必须覆盖保存和加载两端，并验证加载后的身份、元数据或行为。
- `Recovery` 必须在失败后执行修正后的同名/同 Context 操作并验证恢复结果。

本轮没有用断言数量、方法长度或同文件内其他方法替代精确 Owner 的行为证明。

## 缺失 Evidence 类别

在 catalog 已声明、但精确 Owner 没有实际 oracle 支持的类别中：

| 缺口 | 产品数 | 主要表现 |
| --- | ---: | --- |
| Cleanup | 26 | 只有 Context/Module/Engine scope、Release 或 Destroy，没有释放后结果 |
| Isolation | 13 | 只有局部 fixture，没有独立 owner/control 或跨场景不污染断言 |
| Lifecycle | 7 | 有对象或 API 调用，但没有可观察的引用、状态或销毁阶段 |
| Runtime | 5 | 只查询元数据/编译结果，或只执行序列化前的源模块 |
| Diagnostic | 4 | Expected 含拒绝/损坏路径，但精确 Owner 没有执行 |
| Metadata | 1 | 目标场景没有精确 ABI/所有权元数据查询 |

所有声明的 `Debug` 和 `Bytecode` 产品均有对应 oracle；没有产品出现
compile-only 被误判为 Debug 或 Bytecode 的情况。

catalog 没有为这些产品声明 `SaveLoad` 或 `Recovery`，但源码实际已经具备：

- `SaveLoad`：3 个产品。
  - `MOD-BYTECODE-STREAM-RESTORE`
  - `MOD-SCRIPT-CLASS-SAVELOAD-LIFECYCLE`
  - `MOD-SAVELOAD-FUNCTION-RESTORE`
- `Recovery`：5 个产品。
  - `DBG-EXCEPTION-CAUGHT-QUERY`
  - `MOD-IMPORT-UNBIND-ALL`
  - `MOD-BUILD-FAILURE-RECOVERY`
  - `RT-CTX-EXCEPTION-RECOVERY-SIGNATURE`
  - `DBG-STACK-POP-EXIT`

CSV 的 `EvidenceObserved` 已记录这些“实际存在但 catalog 未声明”的证据。

## Module 的主要问题

Module 的 19 个产品中只有 3 个达到完整深度：

- `MOD-SCRIPT-CLASS-SAVELOAD-LIFECYCLE`
- `MOD-USERDATA-LIFECYCLE`
- `MOD-BUILD-FAILURE-RECOVERY`

其余 16 个均需要调整，主要分为两类。

### Expected 超出精确 Owner

- `MOD-BYTECODE-STREAM-RESTORE` 的 Owner 只验证 CopyScript 保存确定性和当前 fork 的
  shared `$obj` 加载拒绝，没有覆盖 Expected 中全部 primitive、debug-info 模式、
  空/截断/失败/v1 stream、成功恢复运行和清理生命周期。
- `MOD-FUNCTION-INVENTORY-RUNTIME` 的 Owner 只执行三个零参数 `int` 函数，没有覆盖
  Expected 中的 scalar return ABI 和多种参数/返回路径。
- `MOD-GLOBAL-STATE-LIFECYCLE` 的 Owner 只枚举初始化后的 globals，没有 reset、
  直接常量存储变更、remove 或 discard 前后的状态。
- `MOD-IMPORT-BINDING-CONTRACT` 的 Owner 只查询绑定前 import metadata，没有执行
  manual/automatic binding、mismatch、unbind/rebind。
- `MOD-LIFECYCLE-REBUILD-ISOLATION` 的 Owner 只完成第一次 create/build/execute，
  没有 existing/missing discard、独立名称、replace、discard/rebuild 身份。
- `MOD-NAMESPACE-LOOKUP-CONTRACT` 的 Owner 只验证 default namespace 不重归属声明，
  没有显式 namespace、malformed text rejection 和 prior-state preservation。
- `MOD-SAVELOAD-FUNCTION-RESTORE` 只执行序列化前的源模块；加载后只查声明，没有执行
  恢复函数，也没有 truncated retry 和 multi-function runtime。
- `MOD-SECTION-BUILD-DIAGNOSTIC` 只验证一个错误 section 的名称与偏移，没有成功
  single/multi-section runtime、section metadata 和 cross-module isolation。
- `MOD-STATE-TABLE-REBUILD` 只验证第一次 rich module publication 和 `Entry=47`，
  没有 same-name rebuild、obsolete row removal 和 latest-body execution。

这些产品应把 Expected 的所有行为移入精确 Owner，或者拆成多个产品，不能依赖同文件
其他方法或历史 predecessor 说明来补足。

### Cleanup 只有动作，没有结果

Rename、CompileFunction、RemoveFunction、typedef boundary、UnbindAll、
PreClass metadata、NestedImport 等 Owner 已有 scope 或显式 Release，但没有：

- discard 后 `GetModule(..., asGM_ONLY_IF_EXISTS) == nullptr`；
- retained function/type/reference 回到基线；
- Context cleanup callback 或成功 `Unprepare` 后复用；
- 同名模块在清理后可无污染重建。

CSV 为每个产品给出了对应的最小补充断言。

## Runtime 的主要问题

Runtime 的核心 Context public API、异常恢复、调用 arity 和 script-function reference
释放产品整体较强；主要缺口集中在旧 Context tests、GC aggregate Owner 和
script-object cleanup。

### Context cleanup 不充分

以下产品执行结果和元数据已充分，但只依赖 Context Release/module scope：

- `RT-CTX-CONTROL-FLOW-EXECUTION`
- `RT-CTX-ARITHMETIC-EXCEPTION-DETAILS`
- `RT-CTX-SUSPEND-FORK-REJECTION`
- `RT-CTX-STACK-OVERFLOW-METADATA`
- `RT-CTX-RETURN-ABI-SHAPES`
- `RT-CTX-RETURN-CONTROL-PATHS`

最小修复通常是增加成功 `Unprepare`、同 Context recovery/reuse、Context cleanup
callback 计数，或 module discard 后 null lookup；不能只增加另一个 guard。

### GC Owner 范围不匹配

- `RT-GC-EMPTY-SERVICE-CONTRACTS` 的精确 Owner
  `GarbageCollectorStatistics` 只断言初始五个计数为零；full empty collection、
  invalid lookup 输出清零、undestroyed count 在其他方法里，不能算该 Owner 的证据。
- `RT-GC-CYCLE-TOPOLOGY-PHASES` 的精确 Owner `ManualCycleCollection` 只覆盖 self-cycle
  的 full collection；two-node、detect-only retention 和 detected statistics 不在该方法。

应将完整场景放回对应 Owner，或拆成多个具有精确 Expected/Evidence 的产品。

### Script object 生命周期

- `RT-OBJ-CONSTRUCT-COPY-ASSIGN-PROPERTY` 有真实 construct/copy/assign/CopyFrom 与属性值，
  但没有 destruction/refcount 最终基线，也没有对象间独立变更控制。
- `RT-OBJ-REFCOUNT-WEAKFLAG-FORK` 调用了 AddRef/Release，但没有可观察的引用计数或
  销毁 callback，因此不能声称 balanced Lifecycle/Cleanup。
- `RT-OBJ-TYPE-ENGINE-IDENTITY` 已验证三种创建来源的 TypeInfo/type ID/engine identity，
  但对象和 module 释放后没有最终基线。

## NativeDebug 状态

NativeDebug 10 个产品和 Runtime.Debug 2 个产品均达到 Complete。其关键原因不是断言多，
而是 Owner 具有明确的负向和清理 oracle：

- callback replacement 后旧 recorder 不再增长；
- clear 后事件数保持不变；
- 无效 frame/index 返回精确 null/asINVALID_ARG；
- exception 后同 Context `Unprepare` 并执行 recovery；
- line/stack-pop/instruction 事件包含精确 function、section、line、range 或 opcode；
- absent/cleared callback 路径明确断言零事件。

这些模式可作为 Runtime 与 Module 补充 Isolation/Cleanup 的参考。

## 验证边界

本轮只进行只读源码审计并新增本 CSV 与摘要：

- 没有修改测试代码、catalog、`tasks.md` 或 progress。
- 没有运行生成/重写审计脚本。
- 没有执行构建或自动化测试。
- CSV 应与 `coverage-products.psd1` 中 Owner 位于 `Runtime/` 或 `Module/` 的产品集合
  一一对应。
