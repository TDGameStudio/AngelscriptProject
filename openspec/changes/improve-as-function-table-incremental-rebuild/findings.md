# P0 诊断结论 — improve-as-function-table-incremental-rebuild

> 实验日期：2026-06-25。引擎 UE 5.8。Win64。实验为只读 + 一次受控 `touch`（mtime-only，已还原），未改动任何源码内容。

## 结论（一句话）

**不是 codegen 的 bug，也不是"设计如此要全量重生成"。根因是嫌疑 B —— shard 的公共头 include 链传染。** 每个 `AS_FunctionTable_*` shard 都 `#include "Core/AngelscriptEngine.h"`（1645 行、被 164 个文件引用的中心头），只要该头（或另两个公共头）的 mtime 变化，所有 shard 所在的编译单元全部失效重编。codegen 自身的增量护栏（`CommitOutput` 内容 hash 跳过）**工作正常**。

## 证据链

### 事实 1 — codegen 增量护栏有效，shard 从不被无谓重生成

- 记录 29 个 `.gen.cpp`（UnrealEditor target）的 sha256 + mtime 作基线。
- 跑一次增量 editor 构建（`Tools\RunBuild.ps1 -NoXGE`），该构建甚至因 `AngelscriptProjectEditor.Target.cs` 改动而 invalidate makefile 并重编了 `Module.AngelscriptRuntime.12/13.cpp`。
- 构建后复测：**29 个 `.gen.cpp` 中 hash 改变 0 个、mtime 改变 0 个。**
- → `CommitOutput` 的内容 hash 比对确实跳过了未变化文件的写盘。**嫌疑 A（codegen 写盘/`DeleteStaleOutputs` 误删/路径不匹配）排除。**

### 事实 2 — 触碰中心公共头 → shard 全量重编

- `touch` `AngelscriptEngine.h`（仅改 mtime，内容字节不变，已还原）。
- 再跑增量构建：UBT 执行 **71 个 action**，重编几乎所有 `Module.AngelscriptRuntime.*.cpp`（编辑器 target 下 shard 被 inline 进这些 unity 文件）+ 大量 `Module.AngelscriptTest.*`。
- 对比事实 1 的 no-op 构建仅 12 个 action。
- → shard 的重编完全由其 `#include` 的公共头是否失效驱动，与 shard 自身内容无关。**嫌疑 B 证实。**

### 事实 3 — 中心头的传染半径

- `AngelscriptEngine.h`：1645 行，被 **164** 个 `.h/.cpp` 引用。
- `AngelscriptBinds.h`：718 行，被 **131** 个引用。
- `FunctionCallers.h`：393 行。
- 三者都被 `BuildShard()` 无条件注入每个 shard（`AngelscriptFunctionTableCodeGenerator.cs:591-593`，磁盘产物已确认）。
- → 任何业务改动只要间接 touch 到这三个头之一（在如此高的中心度下极易发生），就会触发全部 36 个 shard 重编。

## 关于用户日志（36 个 standalone `[x/36]`）的归因校准

- 用户日志是 **standalone** 逐个 `Compile AS_FunctionTable_*.cpp`，而本次 editor 构建是把 shard inline 进 **unity** 文件（`Module.AngelscriptRuntime.N.cpp`）。
- 磁盘布局确认：**UnrealEditor target** 把 60 个 wrapper 收进 unity；**UnrealGame target** 同样存在 60 个 standalone wrapper（`.../UnrealGame/.../Gen/AngelscriptGeneratedFunctionTableWrappers/*.cpp`）。
- 用户日志来自 **打包**（`Tools\RunPackage.ps1` → `RunUAT BuildCookRun -build`，Game/Client 配置，今日新增脚本），即 Game target，shard 以 standalone 形式编译，故呈现为 `[x/36]`。
- 两种 target 表现不同，但**根因相同**：shard include 了易变的中心公共头。Game 下因非 unity，单头失效的代价更直观（36 个独立 TU 全重编）。

### 术语校准：Editor target vs Game/package target

- **Editor target**：`Tools\RunBuild.ps1` 默认构建 `AngelscriptProjectEditor`，产物是给 Unreal Editor 加载的 `UnrealEditor-*.dll`。该 target 下 generated function table wrapper 被 unity 文件收进 `Module.AngelscriptRuntime.2.cpp`，所以日志常表现为 `Compile Module.AngelscriptRuntime.2.cpp`，而不是逐个 `Compile AS_FunctionTable_*.cpp`。
- **Game/package target**：`Tools\RunPackage.ps1` 通过 `RunUAT BuildCookRun -build` 构建非编辑器运行时游戏目标（例如 `UnrealGame` / client config），用于 cook/package/stage/archive。该 target 下 wrapper 文件也存在于 `.../UnrealGame/.../Gen/AngelscriptGeneratedFunctionTableWrappers/*.cpp`；在非 unity / standalone 编译形态下，日志会直接显示逐个 `Compile AS_FunctionTable_*.cpp`。

## 2026-06-26 追加触发矩阵（受控 mtime-only 实验）

实验前先确认 Editor 构建基线：`Tools\RunBuild.ps1 -NoXGE` 为 `Target is up to date`，0 action。所有 touch 均只改 mtime，实验后已还原。

| 触发源 | Editor target 结果 | 是否触发 function table |
| --- | --- | --- |
| `Source/AngelscriptProject/AngelscriptProject.cpp` 临时注释 | 4 actions，仅编译/链接 host project 模块 | 否 |
| `Plugins/Angelscript/.../AngelscriptBindDatabase.cpp` touch | 4 actions，仅 `Module.AngelscriptRuntime.13.cpp` + Runtime 链接 | 否 |
| `Plugins/Angelscript/.../AngelscriptBindDatabase.h` touch | 44 actions，Runtime/Test/Editor/GAS 多模块重编 | 是，Editor 日志表现为 `Module.AngelscriptRuntime.2.cpp` 等 unity TU |
| `Source/AngelscriptProjectEditor.Target.cs` touch | makefile invalidated，0 action | 否 |
| `AngelscriptProject.uproject` touch | makefile recreated，0 action | 否 |
| `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` touch | UHT 重新运行 `AngelscriptFunctionTable`，6 actions，编译 `Module.AngelscriptRuntime.2/3/4.cpp` | 是，`Module.AngelscriptRuntime.2.cpp` 包含全部 function table wrappers |

补充确认：

- `Module.AngelscriptRuntime.2.cpp` 直接 include `Gen/AngelscriptGeneratedFunctionTableWrappers/AS_FunctionTable_*.cpp`，因此 Editor 构建日志中的 `Compile Module.AngelscriptRuntime.2.cpp` 等价于 function table wrapper 所在 TU 被重编。
- 单纯改 host project `.cpp` 或普通插件 `.cpp` 不会触发 function table；需要改到 shard include 依赖的公共头，或改到 `AngelscriptRuntime.Build.cs` 这类会让 UHT/exporter 和 wrapper 编译图重新参与的规则文件。

## 关于关键不确定点的回答

- **wrapper inline 的增量基于 hash 还是 mtime**：事实 1 证明 UBT 对 `.gen.cpp` 内容没变时不重编对应 unity（no-op 构建未碰 shard unity）；事实 2 证明头 mtime 变化即触发重编。即 UBT 依赖 include 依赖图 + 文件 mtime/时间戳判定 TU 是否过期，shard 内容相同不足以拯救——只要其 include 的头被判过期，TU 就重编。这正是 include 链传染。
- **cross-module `enabled:false`**：确认当前关闭，36 个文件是各模块运行期分片 + link probe，与归因一致。

## 推荐修复方向（主攻路径 B）

收窄 `BuildShard()` 注入的 include（`AngelscriptFunctionTableCodeGenerator.cs:591-593`）：

1. shard 的真实编译需求只是"注册 binds 的最小接口 + 各 entry 引用的目标类型头"。`AngelscriptEngine.h`(1645 行) 整头注入很可能远超所需。
2. 拆出一个**稳定、极少改动**的最小注册接口前置头（如 `AngelscriptBindsFwd.h` / 精简版 binds 注册头），让 36 个 shard 仅依赖它 + 各自的目标类型头，不再依赖 `AngelscriptEngine.h` 全量。
3. 这样业务改 `AngelscriptEngine.h` 时，shard 编译单元不再失效，打包/增量构建不再无谓重编全部函数表。
4. 验收：重构后 diff `.gen.cpp` 确认绑定逻辑字节级等价（仅 include 行变化）；再 `touch AngelscriptEngine.h` 复测，确认 shard 不再被卷入重编。

嫌疑 A 的加固任务（tasks 第 3 组）可降级为"顺带核查"，非主攻——护栏已被证明有效。

## 后续

- tasks.md 第 1 组 P0 已完成（本文件即产物）。
- 主攻 tasks 第 2 组（路径 B：切断 include 传染）。
- 第 3 组（路径 A）降级。
