# Tasks — chore-drop-deprecated-structutils-plugin-dependency

> 改动文件位于 submodule `Plugins/Angelscript`，按 `Documents/Guides/SubmoduleWorktreeWorkflow.md` 处理 submodule 提交与主仓库指针更新。

## 1. 确认前提

- [ ] 1.1 确认引擎版本：检查 `AngelscriptProject.uproject` 的 `EngineAssociation` 为 `5.8`。
- [ ] 1.2 确认唯一改动点：`Plugins/Angelscript/Angelscript.uplugin` 第 35-39 行存在 `{ "Name": "StructUtils", "Enabled": true }`。
- [ ] 1.3 确认需保留项：`Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` 的 `PublicDependencyModuleNames` 含 `"StructUtils"`（module 依赖，不动）。
- [ ] 1.4 确认无关项：AngelscriptGAS / AngelscriptGameplayTags / AngelscriptProjectEditor 无 StructUtils 引用，本次不触碰。

## 2. 修改依赖声明

- [ ] 2.1 在 `Angelscript.uplugin` 中删除 StructUtils plugin 条目，保持 JSON 数组语法（逗号）正确。
- [ ] 2.2 确认 `AngelscriptRuntime.Build.cs` 的 `"StructUtils"` module 依赖**未被改动**。
- [ ] 2.3 确认相关 include（`StructUtils/InstancedStruct.h`）**未被改动**。

## 3. 验证

- [ ] 3.1 运行 `Tools\RunBuild.ps1 -NoXGE` 构建，确认编译/链接通过（`FInstancedStruct` 绑定无链接错误）。
- [ ] 3.2 确认 StructUtils plugin 弃用警告不再出现。
- [ ] 3.3 若构建报 `StructUtils` module 找不到（退路触发）：改 `AngelscriptRuntime.Build.cs` 依赖为 `CoreUObject` 并核实 include 路径，重新构建。

## 4. 收尾

- [ ] 4.1 在 submodule `Plugins/Angelscript` 内提交改动。
- [ ] 4.2 在主仓库更新 submodule 指针。
- [ ] 4.3（可选）同步修正 `Documents/Knowledges/ZH/Guide_QuickStart.md` 引擎版本号（5.7 → 5.8）。
