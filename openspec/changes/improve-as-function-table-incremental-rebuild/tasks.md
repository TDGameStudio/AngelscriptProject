# Tasks — improve-as-function-table-incremental-rebuild

> 改动位于 submodule `Plugins/Angelscript`（`AngelscriptUHTTool` C# codegen + `AngelscriptRuntime` 公共头），按 `Documents/Guides/SubmoduleWorktreeWorkflow.md` 处理提交。
> 验证仅用 `Tools\RunBuild.ps1` / `Tools\RunTests.ps1`，禁止手写 UBT/Build.bat。

## 1. P0 诊断（已完成 → 见 findings.md，结论：嫌疑 B / include 链传染）

- [x] 1.1 复核产物链路：`AngelscriptFunctionTableExporter.cs:22-28`、`AngelscriptFunctionTableCodeGenerator.cs:103/304/370`、`AngelscriptRuntime.Build.cs:92-121`，确认 36 个文件的构成（运行期分片 + link probe；cross-module 当前 `enabled:false`）。
- [x] 1.2 记录 `Intermediate/.../UHT/AS_FunctionTable_*.gen.cpp` 的 mtime + 内容 hash 基线（29 个 editor target 分片）。
- [x] 1.3 增量构建后复测：no-op 构建仅 12 action，shard `.gen.cpp` 0 hash / 0 mtime 变化。
- [x] 1.4 分流根因：**文件未变但 TU 重编 → 嫌疑 B（include 链传染）确认；嫌疑 A 排除（codegen 护栏有效）**。
- [x] 1.5 排除缓存假象：受控实验（touch 中心头）可稳定复现，非缓存偶发。
- [x] 1.6 wrapper inline 增量判定：UBT 依赖 include 依赖图 + 头 mtime；shard 内容相同不足以避免重编，只要其 include 的头被判过期即重编。
- [x] 1.7 P0 结论已写入 `findings.md`。
- [x] 1.8 归因校准：用户 standalone `[x/36]` 日志来自打包（Game target，`Tools\RunPackage.ps1`）；editor target 走 unity。根因相同。
- [x] 1.9 追加触发矩阵：host project `.cpp`、普通 Runtime `.cpp`、`.Target.cs`、`.uproject` 不触发 function table；`AngelscriptBindDatabase.h` 和 `AngelscriptRuntime.Build.cs` 会触发 wrapper 所在 TU 重编（Editor 下表现为 `Module.AngelscriptRuntime.2.cpp`，Game/package 下可能表现为 standalone `AS_FunctionTable_*.cpp`）。

## 2. 修复 —— 路径 B：切断公共头 include 传染（主攻 —— P0 已确认为根因）

- [ ] 2.1 分析 `BuildShard`(`AngelscriptFunctionTableCodeGenerator.cs:591-593`) 注入的三个公共头，确定哪些是 shard 编译真正必需。
- [ ] 2.2 拆出稳定最小注册接口头（如 `AngelscriptBindsFwd.h`），将 shard 依赖从 `AngelscriptEngine.h`(1645 行) 收窄到该最小头。
- [ ] 2.3 更新 codegen 注入的 include 列表。
- [ ] 2.4 diff 重构前后 `.gen.cpp`，确认生成产物字节级不变（仅 include 行变化、绑定逻辑不变）。

## 3. 修复 —— 路径 A：加固 codegen 增量护栏（已降级 —— P0 排除嫌疑 A，护栏已证明有效，下列仅作顺带核查）

- [ ] 3.1 审查 `DeleteStaleOutputs`(`:1229`) 的 `Path.GetFullPath` + 大小写比较(`:1231`)，确认 Windows 大小写不敏感下 live 集与写盘路径一致，杜绝误删→重生。
- [ ] 3.2 核实 cross-module 分片(`.cpp`, `:394`) 是否同享 `CommitOutput`(`:370`) 内容 hash 护栏；若否，补齐。
- [ ] 3.3 若 wrapper 增量基于 mtime（1.6 结论），确保未变内容不重写时间戳（CommitOutput 已跳过写盘即可满足）。

## 4. 验证

- [ ] 4.1 `Tools\RunBuild.ps1 -NoXGE` 完整构建通过，产物正确。
- [ ] 4.2 复测 1.3 场景（只改无关 `.cpp`）：修复后 `AS_FunctionTable_*` 重编数显著下降（理想为 0），记录前后对比数据到 `findings.md`。
- [ ] 4.3 `Tools\RunTests.ps1` 相关绑定测试通过，确认绑定行为无回归。

## 5. 收尾

- [ ] 5.1 在 submodule `Plugins/Angelscript` 提交，主仓库更新 submodule 指针。
- [ ] 5.2 在 GitHub Issue #1 回链根因结论（设计 vs bug）与修复数据。
