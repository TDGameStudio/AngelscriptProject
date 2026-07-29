# 项目内 VS Code Angelscript 扩展

项目内维护的 VS Code 扩展源码位于 `Extensions/AngelscriptVSCode/`。它基于 Hazelight 公开的 `vscode-unreal-angelscript` 1.9.2，并作为本项目的一部分独立演进。

`Reference/vscode-unreal-angelscript/` 仍然只是本地参考副本，不要在其中开发项目功能。

## 构建扩展

在仓库根目录执行：

```powershell
cd Extensions/AngelscriptVSCode
npm install
npm run compile
npx --yes @vscode/vsce package --no-dependencies
```

成功后会生成：

```text
Extensions/AngelscriptVSCode/angelscript-1.9.2.vsix
```

在 VS Code 中运行 `Extensions: Install from VSIX...` 安装该文件。构建产生的 `node_modules/`、`dist/` 和 `.vsix` 已被扩展目录的 `.gitignore` 忽略。

## 使用方式

1. 使用 VS Code 打开项目的 `Script/` 目录作为 workspace root。
2. 启动带有 Angelscript 插件的 Unreal Editor。
3. 确认 Unreal DebugServer 使用 `27099` 端口；如果通过启动参数修改端口，需要同步修改 VS Code 的 `UnrealAngelscript.unrealConnectionPort`。
4. 打开任意 `.as` 文件，等待扩展完成脚本扫描和 Unreal 类型数据库加载。

扩展通过 DebugServer 提供：

- AngelScript 语义高亮、补全和签名帮助；
- 编译诊断、悬停信息和代码操作；
- 定义跳转、引用搜索、重命名、Symbol 和 API 搜索；
- Unreal 类型数据库、Asset 数据和 Blueprint 相关辅助；
- 断点、调用栈、变量、求值、步进和数据断点调试。

当前 Runtime 已保持 Hazelight `DebugDatabaseSettings` 的 version 7 线协议布局，同时不恢复 Haze 语义。Hazelight 扩展中的 `StopPIE` 命令暂未接入当前项目 Runtime，普通编辑、诊断、导航和调试流程不受影响。

## 开发边界

- VS Code 客户端改动放在 `Extensions/AngelscriptVSCode/`。
- Unreal 侧协议和数据源改动放在 `Plugins/Angelscript/Source/AngelscriptRuntime/Debugging/`。
- 协议变更必须同步更新 Debugger 自动化测试，并按 `Tools\RunBuild.ps1`、`Tools\RunTests.ps1` 验证。
- 不要把 `Reference/` 中的嵌套 `.git`、依赖目录或生成产物复制回项目。
