# Tasks — feature-as-blueprint-parent-jump-to-source

> 改动位于 submodule `Plugins/Angelscript/Source/AngelscriptEditor`，按 `Documents/Guides/SubmoduleWorktreeWorkflow.md` 处理提交与主仓库指针。
> 测试遵循项目约定：Editor 层（`AngelscriptEditor/Tests/`），文件名以 `Angelscript` 前缀；用现有导航测试接缝，禁止真正拉起 VS Code。

## 1. 确认引擎门控形态

- [ ] 1.1 在父类为 AS 类的蓝图编辑器中实际操作，确认右上角"打开父类源码"按钮的状态（隐藏 / 显示但无效 / 当作普通蓝图父类）。记录结论。
- [ ] 1.2 复核 `AngelscriptClassGenerator.cpp:3319` 的 `CLASS_CompiledFromBlueprint` 标记，确认 AS 父类不被引擎判为 native。
- [ ] 1.3 复核已注册 handler `FAngelscriptSourceCodeNavigation`（`AngelscriptSourceCodeNavigation.cpp/.h`）与注册点（`AngelscriptEditorModule.cpp:815`），确认 `NavigateToClass` 对 `UASClass`/`UASStruct` 可用。

## 2. 实现工具栏入口 <!-- TDD -->

- [ ] 2.1 先写失败测试（Editor 层）：构造一个父类为 AS 类的场景，通过导航测试接缝断言触发动作后解析出的 `path:line` 正确（不启动 VS Code）。参考 `AngelscriptSourceNavigationTests.cpp`。
- [ ] 2.2 在 `ScriptEditorMenuExtension.cpp` 中通过 `UToolMenus` 为蓝图编辑器新增"打开 Angelscript 父类源码"入口。
- [ ] 2.3 入口可见性/可用性绑定 `Cast<UASClass>(Blueprint->ParentClass) != nullptr`（镜像 `CanNavigateToClass`）。
- [ ] 2.4 执行逻辑调用现有 `FSourceCodeNavigation::NavigateToClass(ParentClass)`（落到 AS handler → `OpenVsCode`/`OpenModule`）。
- [ ] 2.5 父类无法解析为脚本源时，记录可见日志/提示，不静默失败、不打开错误位置。
- [ ] 2.6 运行 2.1 测试至通过。

## 3. 边界与回归

- [ ] 3.1 验证父类为 C++ 类时，引擎自带按钮行为不受影响（本入口不显示或不干扰）。
- [ ] 3.2 验证父类为 AS 类、源文件存在时跳转到正确 `path:line`。
- [ ] 3.3 验证 `code` 不在 PATH 时不崩溃（既有 `OsExecute` 行为，文档注明）。

## 4. 验证与收尾

- [ ] 4.1 `Tools\RunBuild.ps1 -NoXGE` 构建通过。
- [ ] 4.2 `Tools\RunTests.ps1`（或 `RunTestSuite.ps1`）运行新增 Editor 测试通过。
- [ ] 4.3 在 submodule 提交，主仓库更新 submodule 指针。
- [ ] 4.4 在 GitHub Issue #2 回链本 change 结论与实现。
