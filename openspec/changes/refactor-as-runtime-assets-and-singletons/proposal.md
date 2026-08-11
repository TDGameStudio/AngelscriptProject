## Why

当前 `asset Name of Type { ... }` 同时承担了脚本级单对象创建、全局命名访问、编译后初始化、内部 package 注册和热重载替换；其名称却暗示 UE Content Browser 资产。它既没有明确 UObject 的生命周期/可变性，也不能表达 UE 的运行时动态资产（Primary Asset ID、软路径、Bundle）或编辑器持久 `.uasset`，导致脚本作者难以判断何时该用它、能否用于 `UDataAsset`、曲线或 Actor。

本变更将把“创建一个脚本托管 UObject”和“声明/管理全局运行时资产”分成两个概念：`singleton` 服务前者，收紧后的 `asset` 直接作为 `UAssetManager::AddDynamicAsset` 的声明式前端。这样可让 API 名称、UE 生命周期和可支持的类型保持一致，并与 UE 的 Dynamic Asset 模型对齐。

## What Changes

- 新增 `singleton` 顶层声明，用于创建并访问一个具名的、脚本托管的 `UObject` 实例；它替代现有 `asset` 的单对象创建语义。
- **BREAKING** 收紧 `asset`：不再是“任意 `NewObject` 的 UObject 实例”的语法糖；它直接定义一个 Asset Manager Dynamic Asset，具有明确的 Primary Asset ID、可选代表对象软路径和 Bundle 语义。
- 为两种声明分别规定可接受的类、作用域、初始化、访问、可变性、生命周期、热重载与冲突行为；明确禁止用任一声明创建 Actor、组件或导入型内容资源本体。
- 将现有 `asset` 的 `Get<Name>()` 兼容策略列为设计和迁移决策：首期必须给出现有脚本的明确诊断与迁移路径，不能静默改变含义。
- 明确 Editor 中创建/保存 `/Game/*.uasset` 的 Factory/AssetTools 流程不属于 runtime `asset`；如未来暴露，必须作为独立的 Editor-only 能力。
- 增加覆盖预处理、UObject 生命周期、Asset Manager 注册、热重载和非法类型/旧语法迁移的自动化测试与脚本示例。

## Capabilities

### New Capabilities

- `as-runtime-asset-and-singleton-model`: 规定 AngelScript `singleton` 与收紧后的 `asset` 的语法、类型限制、运行时所有权、访问方式、Asset Manager 集成边界、热重载和迁移诊断。

### Modified Capabilities

- None.

## Impact

- 主要影响 `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` 中 literal-asset 转写，`Binds/Bind_UObject_Functions.cpp` 中对象创建和 Hot Reload 路径，以及 `ClassGenerator/` 的 post-init 调度。
- 预计需在 Runtime 中增加聚焦的 `UAssetManager::AddDynamicAsset` bridge / registry；它只描述和加载既有 Cookable `/Game` 资产，不在 packaged runtime 创建或保存 `.uasset`。AS 所用 Dynamic Asset Type 必须与项目扫描的磁盘 Primary Asset Type 隔离，避免 UE 禁止的动态/磁盘类型混用。
- 预计新增或调整 `Plugins/Angelscript/Source/AngelscriptTest/Preprocessor/`、`Generator/Core/`、`HotReload/` 和 AssetManager/FunctionLibrary 主题下的测试；需要增加可执行 `.as` 示例和中文使用文档。
- `Plugins/Angelscript` 是 git submodule；OpenSpec 位于父仓库。真正实施时需先提交子模块，再更新父仓库 gitlink。
