## Why

UE 在启动时对 `Plugins/Angelscript/Angelscript.uplugin` 报弃用警告：它依赖的 `StructUtils` 已不再是独立 plugin（在 UE 5.5 弃用、后续合并进引擎核心，作为 engine module 存在）。本仓库实际引擎版本为 **UE 5.8**，该 plugin 已不存在，故触发警告。需要移除这个失效的 plugin 依赖声明，消除警告并避免未来引擎版本彻底移除 plugin 解析后构建失败。

## What Changes

- 从 `Plugins/Angelscript/Angelscript.uplugin` 的 `Plugins` 列表中移除 `{ "Name": "StructUtils", "Enabled": true }` 条目。
- **保留** `AngelscriptRuntime.Build.cs` 中 `PublicDependencyModuleNames` 的 `"StructUtils"` —— 这是 engine **module** 依赖（`FInstancedStruct` 等仍由该 module 提供），不是 plugin 依赖。移除会导致链接错误。
- include 路径保持不变：现有 `#include "StructUtils/InstancedStruct.h"` 在 UE 5.8 下仍有效。
- 该文件位于 git submodule `Plugins/Angelscript` 内，需走 submodule 修改流程（submodule 内提交 + 主仓库更新指针）。

### 范围修正（相对原 Issue #3）

原 Issue 基于 UE 5.5，声称 4 个模块受影响（Angelscript、AngelscriptGAS、AngelscriptGameplayTags、AngelscriptProjectEditor）。探索确认：

- 引擎实际为 **UE 5.8**。
- **仅 Angelscript 插件**真实声明并使用 StructUtils（AngelscriptRuntime + AngelscriptTest，共约 60 处 API 引用，主要是 `FInstancedStruct`）。
- AngelscriptGAS、AngelscriptGameplayTags、AngelscriptProjectEditor **均无任何 StructUtils 引用**，不在本次范围内。

## Capabilities

### New Capabilities
（无 —— 这是依赖维护类 chore，不引入脚本/工具可见的新能力，也不改变规格级行为。）

### Modified Capabilities
（无规格级行为变化。）

## Impact

- 唯一改动文件：`Plugins/Angelscript/Angelscript.uplugin`（submodule 内）。
- 风险点：必须区分 plugin 依赖（删）vs Build.cs 的 module 依赖（留）；混淆会把"弃用警告"变成"链接错误"。
- 验证：构建 `AngelscriptRuntime` 与 `AngelscriptTest`，确认弃用警告消失且 `FInstancedStruct` 绑定仍正常链接。
- 待确认：UE 5.8 下 `StructUtils` 是否仍是独立可链接 module 名（当前 include 路径与 Build.cs module 名一致指向"module 仍存在"）；若构建报 module 找不到，退路是改依赖 `CoreUObject` 并核实 include 路径。
