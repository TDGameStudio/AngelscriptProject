## Why

`TestSource` 的 3,041 个 AngelScript 源文件已经全部物化，但当前 6,927 处 `Observe_*`、342 处 `SurfaceNNN` 和 2,905 处 `_Nominal` 仍以生成式名称、零参数或复合 `bool` 自证为主。它们无法稳定表达外部输入、原始返回值、out/inout 写回、对象身份、World 生命周期和清理责任；文件头注释也没有替代每个函数自身的契约。

本变更现在从“生成大量源码路径”转为“把已物化 TestSource 全量重构成可调用、可诊断、可审核的测试契约”。OpenSpec 必须先冻结每个目录的 CaseId、语义函数名、完整 AS 声明、typed vectors、逐函数注释和 fixture/cleanup 语义，再允许执行代理修改对应 `.as`。

## What Changes

- **BREAKING**：硬重命名所有测试入口中的 `Observe_*`、`SurfaceNNN` 和 `_Nominal`；源码不保留转发别名，旧名称只保留在历史映射中。
- 为每个 `.as` 和每个 callable 建立 `CaseId -> semantic name -> exact declaration -> inputs -> return/writebacks -> vectors -> comment -> fixture/phase/cleanup` 的 v2 authored contract。
- 在 `TestSource/Generation` 增加 v2 schema、Contracts 索引、按主题生成的任务投影和严格源码审计器；生成任务视图不得成为第二份手工真源。
- 把外部输入放入明确参数，把被测 API 的原始结果或对象句柄传出；多个实际结果使用 `&out`，mutation 使用 `&inout`，expected 值存入 vectors 而不是交给 AS 自行比较。
- 每个 global function、method、constructor/destructor、operator/mixin、delegate、UFUNCTION、Blueprint override、生命周期 callback、helper 和 negative trigger 的声明正上方增加独立英文知识注释。
- 先以 `Bindings/TArray` 完成全量试点，再按互不重叠目录重构 Bindings、Containers、Language、Definitions、Feature、World、Gameplay、Optional、HotReload、TestFramework 和 Debugger。
- 修复 Actor/Component DefaultComponent-null、直接调用生命周期 callback、timer 不经 TimerManager、delegate 不经 Broadcast、GC 在一个调用栈内完成、NewObject 身份丢失、AS direct call 冒充 ProcessEvent、Blueprint CDO/instance 混淆和 HotReload retained/replaced 状态不完整等伪覆盖。
- 保留 UE/framework 强制的 callback、override、discovery 和 hook 名称，并在 contract 中记录 `requiredNameReason`；不得为了清除旧命名而破坏引擎协议。
- 将现有 8.7 MB 旧任务表和原设计保存到 `attachments/history/2026-08-24-pre-contract-v2/`，正式 `tasks.md` 改为按契约、试点和主题 wave 驱动的可执行清单。
- `test-as-source-generation-rules` 只能消费 `Reviewed` 的 v2 authored contract；不得再从分号拼接的 `plannedSymbols` 猜测 declaration/entryPoint。

## Capabilities

### New Capabilities

- `as-test-source-authored-contract`: 定义 TestSource 每个案例和 callable 的稳定身份、精确声明、typed vectors、函数级注释、确定性投影和严格验证合同。
- `as-manual-bind-source-coverage`: 定义手写 Bindings 测试的 AS-facing surface、原始输入输出、容器/对象/诊断语义和执行安全合同。
- `as-test-source-theme-coverage`: 定义 TestSource 全主题的唯一真源、语义分区、World/Blueprint/HotReload/框架 fixture 与全量迁移合同。

### Modified Capabilities

- None.

## Impact

- 记录与实现范围：`openspec/changes/test-as-manual-bind-source-coverage/**` 和 `TestSource/**`。
- 源码规模基线：3,041 个 `.as`，顶层主题为 `Bindings`、`Containers`、`Debugger`、`Definitions`、`Feature`、`Gameplay`、`HotReload`、`Language`、`Optional`、`TestFramework`、`World`；`Generation` 是契约工具包。
- 当前结构统计：6,927 处 `Observe_*`、342 处 `SurfaceNNN`、2,905 处 `_Nominal`，均须收敛为 0 个源码声明残留。
- 不修改 `Plugins/**`、`Tools/**`、`Script/**`、`Documents/**` 或 Runtime 公共 API；插件测试代码只作为当前 UE 5.7 语义证据读取。
- 本轮完成 TestSource 源码与机器可读契约；实际 UE Automation typed runner、World driver、ProcessEvent driver 和生成 release mirror 仍由后续消费者变更实现，因此不得把静态 contract 通过表述成运行通过。
