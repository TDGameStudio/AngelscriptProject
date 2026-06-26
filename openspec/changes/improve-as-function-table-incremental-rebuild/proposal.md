## Why

改动项目业务代码时，构建会重新编译全部 36 个自动生成的 `AS_FunctionTable_*` 分片（如 `AS_FunctionTable_Engine_000.cpp` ... `AS_FunctionTable_UMG_002.cpp`），即便改动与这些绑定无关，显著拖慢迭代。codegen 本身有正确的增量护栏（`CommitOutput` 内容 hash 比对 + 确定性排序），所以全量重编是护栏被击穿的可优化问题，**不是设计如此**。需要先定性根因，再定向修复。

## What Changes

- **先定性（P0）**：用一次"只改无关 `.cpp`"的增量构建，区分两种情况：
  - (a) `.gen.cpp` 被 UHT 重新写盘（codegen 侧：内容/路径/误删问题）；
  - (b) `.gen.cpp` 未变，但其 TU 因 `#include` 的公共头（`AngelscriptEngine.h` 等）失效而重编（include 链传染）。
- **再定向修复**（依 P0 结论二选一或并行）：
  - 若为 (b)：收窄 `BuildShard` 注入的 include（`AngelscriptFunctionTableCodeGenerator.cs:591-593`），拆出最小稳定头，避免业务改 `AngelscriptEngine.h`(1645 行) 时全 shard 传染。
  - 若为 (a)：加固 codegen 增量护栏 —— 审查 `DeleteStaleOutputs`(`:1229`) 路径规范化（Windows 大小写/分隔符），确认 live 集与写盘路径一致，杜绝"误删→重生→全量重编"；核实 cross-module 分片(`.cpp`)是否同享 `CommitOutput` 护栏。
- 不预先假定方向，P0 实验结论是后续修复的唯一依据。

## Capabilities

### New Capabilities
（无脚本/工具可见新能力 —— 这是构建增量性能 improve，不改变规格级对外行为。）

### Modified Capabilities
（无规格级行为变化；产物内容与对外 API 不变，仅改善重编粒度。）

## Impact

- 涉及模块：`Plugins/Angelscript/Source/AngelscriptUHTTool`（C# UBT codegen）与 `AngelscriptRuntime` 公共头（submodule 内）。
- 关键文件：
  - `AngelscriptUHTTool/AngelscriptFunctionTableCodeGenerator.cs`（`:103` Generate、`:370/:394` CommitOutput、`:581/:591` BuildShard、`:1229` DeleteStaleOutputs、`:942` Build.cs 依赖）
  - `AngelscriptUHTTool/AngelscriptFunctionTableExporter.cs`（`[UhtExporter]` 入口）
  - `AngelscriptRuntime/AngelscriptRuntime.Build.cs:92-121`（wrapper inline + 模块白名单）
  - shard 共享头：`AngelscriptRuntime/Core/AngelscriptEngine.h`(1645 行)、`AngelscriptBinds.h`、`FunctionCallers.h`
  - 参考文档：`Documents/Knowledges/ZH/Note_UBT.md`(§七 `:321-366`)、`Arch_UHTToolchain.md`(§七 `:527-533`)
- 关键不确定点（必须 P0 验证）：
  1. wrapper 经 `UE_INLINE_GENERATED_CPP_BY_NAME` inline `.gen.cpp`，UBT 对其增量判定基于**内容 hash 还是 mtime** —— 若 mtime，则任何重写时间戳（即便内容相同）都触发全量重编。
  2. cross-module 当前 `enabled:false`（`cross-module-generation-modules.json`），36 个文件主要是运行期分片 + link probe，归因需据此校准。
- 验证：以"只改无关 `.cpp`"为基准，修复后该场景下 `AS_FunctionTable_*` 重编数应显著下降（理想为 0）。
