# Reference

## 目的

- 本目录用于集中维护当前项目依赖的外部参考仓库说明。
- 这些仓库不属于当前项目提交内容，只用于对照、迁移分析、架构参考和实现取舍判断。
- `Agents_ZH.md` 只保留索引级信息；具体说明、用途边界、优先级判断统一维护在本文件。

## 外部参考仓库总表

| 名称 | 入口与说明 |
| --- | --- |
| AngelScript v2.38.0 | 使用 `Tools\PullReference\PullReference.bat angelscript` 默认拉取到当前项目的 `Reference\angelscript-v2.38.0`；GitHub `https://github.com/anjo76/angelscript.git`；SSH `git@github.com:anjo76/angelscript.git`；用于对照 AngelScript 语言本体与官方测试 |
| Hazelight Angelscript | 读取 `AgentConfig.ini` 中 `References.HazelightAngelscriptEngineRoot`；本地配置来源；当前未记录到可直接拉取的 GitHub 地址；用于参考 Hazelight 的 Angelscript 集成、模块拆分、绑定、测试组织以及引擎侧改造 |
| Hazelight Docs | 使用 `Tools\PullReference\PullReference.bat hazelightdocs` 默认拉取到当前项目的 `Reference\Docs-UnrealEngine-Angelscript`；GitHub `https://github.com/Hazelight/Docs-UnrealEngine-Angelscript.git`；SSH `git@github.com:Hazelight/Docs-UnrealEngine-Angelscript.git`；用于参考 Hazelight 公开文档站源码、内容结构和对外能力说明 |
| Hazelight VS Code Angelscript | 使用 `Tools\PullReference\PullReference.bat hazelightvscode` 默认拉取到当前项目的 `Reference\vscode-unreal-angelscript`；GitHub `https://github.com/Hazelight/vscode-unreal-angelscript.git`；SSH `git@github.com:Hazelight/vscode-unreal-angelscript.git`；Marketplace ID `Hazelight.unreal-angelscript`；用于参考 Hazelight 的 VS Code Language Server、Debug Adapter、错误展示、断点调试与编辑器连接工作流 |
| Aura GAS Course Initial Project | 使用 `Tools\PullReference\PullReference.bat aura` 默认拉取到当前项目的 `Reference\GameplayAbilitySystem_Aura_Initial`；GitHub `https://github.com/DruidMech/GameplayAbilitySystem_Aura.git`；SSH `git@github.com:DruidMech/GameplayAbilitySystem_Aura.git`；固定到初始提交 `f778ff39e873a756d5a3f97f263d6f24662fdde9`；用于参考 Aura GAS 课程起始练习资产、UE 5.2 示例内容工程结构和 Gameplay Ability System 练习素材 |
| Aura GAS Course C++ Project | 使用 `Tools\PullReference\PullReference.bat auracpp` 默认拉取到当前项目的 `Reference\GameplayAbilitySystem_Aura_Cpp`；GitHub `https://github.com/DruidMech/GameplayAbilitySystem_Aura.git`；SSH `git@github.com:DruidMech/GameplayAbilitySystem_Aura.git`；跟随 `main` 分支；用于参考实现完成后的 Aura C++ GAS 项目、UE 5.3 工程结构、GameplayAbilities/MVVM/MotionWarping 接入和课程实现演进 |
| Aura GAS Angelscript Rewrite | 使用 `Tools\PullReference\PullReference.bat auraas` 默认拉取到当前项目的 `Reference\AngelscriptAura`；GitHub `https://github.com/najoast/AngelscriptAura.git`；SSH `git@github.com:najoast/AngelscriptAura.git`；跟随 `main` 分支；用于参考第三方 Aura GAS Angelscript 改写、AS 侧 GAS 脚本组织和实现笔记 |
| UnrealCSharp | 使用 `Tools\PullReference\PullReference.bat unrealcsharp` 默认拉取到当前项目的 `Reference\UnrealCSharp`；GitHub `https://github.com/crazytuzi/UnrealCSharp.git`；SSH `git@github.com:crazytuzi/UnrealCSharp.git`；用于横向参考 Unreal 脚本插件工程架构 |
| Tencent UnLua | 使用 `Tools\PullReference\PullReference.bat unlua` 默认拉取到当前项目的 `Reference\UnLua`；GitHub `https://github.com/Tencent/UnLua.git`；SSH `git@github.com:Tencent/UnLua.git`；用于参考 Lua 脚本方案的 UE 反射接入、事件覆写、调试和教程组织 |
| Tencent puerts | 使用 `Tools\PullReference\PullReference.bat puerts` 默认拉取到当前项目的 `Reference\puerts`；GitHub `https://github.com/Tencent/puerts.git`；SSH `git@github.com:Tencent/puerts.git`；用于参考 TypeScript/JavaScript 脚本运行时、声明生成和多后端工程组织 |
| Tencent sluaunreal | 使用 `Tools\PullReference\PullReference.bat sluaunreal` 默认拉取到当前项目的 `Reference\sluaunreal`；GitHub `https://github.com/Tencent/sluaunreal.git`；SSH `git@github.com:Tencent/sluaunreal.git`；用于参考另一套成熟 Lua 方案的静态导出、性能取舍和热更新工作流 |
| Blender MCP | 使用 `Tools\PullReference\PullReference.bat blendermcp` 默认拉取到当前项目的 `Reference\blender_mcp`；Blender Forge `https://projects.blender.org/lab/blender_mcp.git`；无 SSH 地址；用于参考 Blender 官方 MCP Server 实现、MCP 协议接入方式和工具链集成模式 |
| Angelsea | 使用 `git clone --recurse-submodules https://github.com/asumagic/angelsea.git Reference\angelsea` 拉取；SSH `git@github.com:asumagic/angelsea.git`；C++20、BSD-2-Clause、alpha 阶段的 AngelScript JIT compiler，用于参考 `asIJITCompilerV2`、bytecode-to-C、MIR、lazy/async JIT 与解释器回退策略；仅为次级研究源 |
| Daslang / daScript | 使用 `git clone --recurse-submodules https://github.com/GaijinEntertainment/daScript.git Reference\daScript` 拉取；SSH `git@github.com:GaijinEntertainment/daScript.git`；BSD-3-Clause 的高性能游戏脚本语言，用于横向参考 C++ 零拷贝互操作、tree interpreter、AOT-to-C++、LLVM JIT、hot reload、semantic hashing、宏系统和 compiler-backed MCP |
| Cython | 使用 `git clone --depth 1 --recurse-submodules https://github.com/cython/cython.git Reference\Cython` 拉取研究快照；SSH `git@github.com:cython/cython.git`；Apache-2.0，用于优先研究 typed AST、declaration/expression/type analysis、C/C++ emitter、temporary cleanup、引用生命周期与异常 lowering |
| Numba | 使用 `git clone --depth 1 --recurse-submodules https://github.com/numba/numba.git Reference\numba` 拉取研究快照；SSH `git@github.com:numba/numba.git`；BSD-2-Clause，用于优先研究 bytecode → untyped/typed IR → LLVM、specialization、typed rewrite、native lowering 与 object cache |
| Luau | 使用 `git clone --depth 1 --recurse-submodules https://github.com/luau-lang/luau.git Reference\luau` 拉取研究快照；SSH `git@github.com:luau-lang/luau.git`；MIT，用于优先研究 bytecode native codegen、bytecode type analysis、guard、fallback block、VM exit 与 x64/A64 code lifecycle |
| GenericMessagePlugin | 使用 `git clone --recurse-submodules https://github.com/wangjieest/GenericMessagePlugin.git Reference\GenericMessagePlugin` 拉取；SSH `git@github.com:wangjieest/GenericMessagePlugin.git`；Apache-2.0 的 UE message bus，用于参考跨 C++、Blueprint、AngelScript 与其他脚本后端的消息签名、类型校验、代码生成和编辑器工作流 |
| GenericStorages | 使用 `git clone --recurse-submodules https://github.com/UnrealBytes/GenericStorages.git Reference\GenericStorages` 拉取；SSH `git@github.com:UnrealBytes/GenericStorages.git`；MIT 的 UE 通用工具插件，用于低优先级参考 registry/storage/singleton/subsystem、编辑器 picker、平台持久化与 S3 helper |
| UECling | 使用 `git clone --recurse-submodules https://github.com/Evianaive/UECling.git Reference\UECling` 拉取；SSH `git@github.com:Evianaive/UECling.git`；在 Unreal 中集成 Cling/CppInterOp 的运行时 C++ 解释器插件，用于低优先级参考 interpreter pool、REPL/notebook、Blueprint C++ script node、脚本生成类与语义信息；上游无仓库级 LICENSE，采用前必须单独审查 |
| TiddlyWiki document migration sources | 通过 `itonnote-theme`、`itonnote-plugin`、`tiddlyseq`、`tw-command-palette`、`tiddlywiki-plugins`、`tiddlywiki-codemirror-6` 键拉取到 `Reference\tiddlywiki-*`；全部使用 SSH 并固定审计提交；用于 `Wiki/` 的 itonnote 主题迁移、document 插件决策和本地源码核查。运行时选中的外部插件源码已导入 `Wiki/src/`，由 Wiki 主仓库跟踪；Reference 只用于分析和复核。 |
| TW Icons catalogue snapshot | 位于 `Reference\tw-icons`；GitHub `https://github.com/morosanuae/tw-icons.git`；固定提交 `d4a58efeddaa683af69fba1a43717a16e4f0d2ca`（`v1.10`）；一个约 56 MiB 的单文件 TiddlyWiki 图标目录快照。仅用于离线查找、审计和手动挑选极少量图标；最低优先级、非运行时依赖，严禁整库导入 `Wiki/`，单个图标采用前还须复核其所属上游图标库许可证。 |
| Kookma TW5 plugin sources | 位于 `Reference\kookma\`；以 `git@github.com:kookma/<repo>.git` 独立 SSH 克隆可访问的 Kookma 插件和扩展源码，并保留 `TW-PluginLibrary` 的完整封装目录快照；用于 AngelScript Wiki 的 WikiText、宏、组件、样式和作者工作流二次开发研究。非运行时依赖，日常构建不会读取或联网更新。详见 `Reference\kookma\README.md`。 |
| AngelScript code-generator research sources | 使用 SSH 拉取 `Reference\fuzzilli`、`Reference\grammarinator`、`Reference\csmith`、`Reference\yarpgen` 与 `Reference\creduce`；分别用于 ASIR 架构、parser fuzz、受控正例／oracle 与失败样本缩减的离线设计参考 |

## 参考源说明

### 1. AngelScript v2.38.0

- 默认路径：当前项目的 `Reference\angelscript-v2.38.0`
- GitHub：`https://github.com/anjo76/angelscript.git`
- SSH：`git@github.com:anjo76/angelscript.git`
- 拉取命令：`Tools\PullReference\PullReference.bat angelscript`
- 重点目录：
- `Reference\angelscript-v2.38.0\sdk\angelscript\source\`
- `Reference\angelscript-v2.38.0\sdk\add_on\`
- `Reference\angelscript-v2.38.0\sdk\tests\`
- 主要用于确认 AngelScript 原生运行时、编译器、语法行为、调用约定、标准附加组件和官方测试基线。
- 涉及引擎核心源码文件时，应优先以这个上游版本为准，避免把 Unreal 集成差异误判成 AngelScript 原生行为。

### 2. Hazelight Angelscript

- 路径来源：读取 `AgentConfig.ini` 中的 `References.HazelightAngelscriptEngineRoot`
- GitHub：当前未记录到可直接使用的远程地址
- SSH：当前未记录到可直接使用的远程地址
- 拉取命令：当前不支持通过 `Tools\PullReference\PullReference.bat` 自动拉取
- 该参考源统一承载原先拆开的两类信息：Hazelight Unreal 插件集成方式，以及 Hazelight 引擎侧的 Angelscript 改造与底层支撑。
- 主要用于确认 Unreal 集成方式，包括插件结构、模块拆分、UE 类型绑定、编辑器扩展、测试组织方式以及脚本资产工作流。
- 同时也用于比对引擎级补丁、引擎内扩展点、底层绑定支撑和插件与引擎协同方式。
- 当前仓库里的 `Plugins/Angelscript` 本质上是朝"插件化、可维护"的方向整理这个参考源，因此后续迁移、对齐、补能力时都优先参考这个本地配置路径。
- 该参考源由本机配置显式指定，不走当前项目内置的 GitHub 同步脚本流程。

### 3. Hazelight Docs

- 默认路径：当前项目的 `Reference\Docs-UnrealEngine-Angelscript`
- GitHub：`https://github.com/Hazelight/Docs-UnrealEngine-Angelscript.git`
- SSH：`git@github.com:Hazelight/Docs-UnrealEngine-Angelscript.git`
- 拉取命令：`Tools\PullReference\PullReference.bat hazelightdocs`
- 重点目录：
- `Reference\Docs-UnrealEngine-Angelscript\content\`
- `Reference\Docs-UnrealEngine-Angelscript\templates\`
- `Reference\Docs-UnrealEngine-Angelscript\static\`
- 该参考源用于查看 Hazelight 对外公开的能力说明、示例叙述、文档编排方式以及站点内容结构。
- 它不是 Hazelight 引擎/插件源码参考源，不能替代 `HazelightAngelscriptEngineRoot` 指向的本地源码路径；源码对照与能力 parity 仍应优先看 `Hazelight Angelscript`。

### 4. Hazelight VS Code Angelscript

- 默认路径：当前项目的 `Reference\vscode-unreal-angelscript`
- GitHub：`https://github.com/Hazelight/vscode-unreal-angelscript.git`
- SSH：`git@github.com:Hazelight/vscode-unreal-angelscript.git`
- Marketplace ID：`Hazelight.unreal-angelscript`
- 拉取命令：`Tools\PullReference\PullReference.bat hazelightvscode`
- 重点目录：
- `Reference\vscode-unreal-angelscript\client\`
- `Reference\vscode-unreal-angelscript\server\`
- `Reference\vscode-unreal-angelscript\syntaxes\`
- 该参考源用于查看 Hazelight VS Code 扩展如何组织 Angelscript Language Server、Debug Adapter、断点调试、错误展示、语义高亮、Go To Definition、命令入口与编辑器连接。
- 它是编辑器外部工具链参考源，不是 UE 插件源码参考源；调试协议、VS Code 工作流、workspace 约定和用户侧错误展示可优先参考它，Runtime / Editor 插件内部实现仍应优先参考 `Hazelight Angelscript`。

### 5. Aura GAS Course Initial Project

- 默认路径：当前项目的 `Reference\GameplayAbilitySystem_Aura_Initial`
- GitHub：`https://github.com/DruidMech/GameplayAbilitySystem_Aura.git`
- SSH：`git@github.com:DruidMech/GameplayAbilitySystem_Aura.git`
- 拉取命令：`Tools\PullReference\PullReference.bat aura`
- 固定提交：`f778ff39e873a756d5a3f97f263d6f24662fdde9`（`Initial Project Files`，2023-03-23）
- 工程版本：初始提交的 `Aura.uproject` 关联 `EngineAssociation` 为 `5.2`；仓库 `main` 后续升级到 UE 5.3，不要把两者混作同一基线。
- 重点目录：
- `Reference\GameplayAbilitySystem_Aura_Initial\Content\Assets\`
- `Reference\GameplayAbilitySystem_Aura_Initial\Content\Maps\`
- `Reference\GameplayAbilitySystem_Aura_Initial\Config\`
- 该参考源用于查看 Stephen Ulibarri Aura GAS 课程起始练习资产、Top Down RPG 示例项目素材组织、角色/地牢/UI 资源布局和初始内容工程结构。
- 它不是 Angelscript 插件源码参考源，也不是 Hazelight Angelscript 能力 parity 基准；只在需要练习素材、GAS 示例资产组织或 UE 示例项目对照时使用。
- 如果需要课程完成态或后续实现演进，应显式切换到上游 `main` 或另建单独本地副本，避免污染起始练习资产基线。

### 6. Aura GAS Course C++ Project

- 默认路径：当前项目的 `Reference\GameplayAbilitySystem_Aura_Cpp`
- GitHub：`https://github.com/DruidMech/GameplayAbilitySystem_Aura.git`
- SSH：`git@github.com:DruidMech/GameplayAbilitySystem_Aura.git`
- 拉取命令：`Tools\PullReference\PullReference.bat auracpp`
- 分支：`main`
- 工程版本：当前 `main` 的 `Aura.uproject` 关联 `EngineAssociation` 为 `5.3`，包含 `Aura` C++ Runtime 模块，并启用 `GameplayAbilities`、`MotionWarping`、`ModelViewViewModel` 等插件。
- 重点目录：
- `Reference\GameplayAbilitySystem_Aura_Cpp\Source\Aura\`
- `Reference\GameplayAbilitySystem_Aura_Cpp\Data\`
- `Reference\GameplayAbilitySystem_Aura_Cpp\Content\`
- `Reference\GameplayAbilitySystem_Aura_Cpp\Plugins\`
- 该参考源用于查看课程完成态或接近完成态的 C++ GAS 项目实现，包括 Ability System Component、Attribute Set、Gameplay Effect / Ability 数据组织、UI/MVVM 接入、敌人/玩家控制流和课程资产最终落地方式。
- 它可以作为本项目 GAS Angelscript 示例和绑定体验的横向参考，但不是 Angelscript 插件架构基准；迁移设计时仍需回到当前插件边界和 Hazelight Angelscript 参考源做判断。
- 如果需要稳定复盘某一课的状态，应额外记录具体提交，而不是把 `auracpp` 的 `main` 工作副本固定成历史点。

### 7. Aura GAS Angelscript Rewrite

- 默认路径：当前项目的 `Reference\AngelscriptAura`
- GitHub：`https://github.com/najoast/AngelscriptAura.git`
- SSH：`git@github.com:najoast/AngelscriptAura.git`
- 拉取命令：`Tools\PullReference\PullReference.bat auraas`
- 分支：`main`
- 重点目录：
- `Reference\AngelscriptAura\Script\`
- `Reference\AngelscriptAura\Script\GAS\`
- `Reference\AngelscriptAura\Script\Documents\`
- `Reference\AngelscriptAura\Content\`
- 该参考源用于查看第三方 Aura GAS Angelscript 改写中的脚本分层、GAS API 调用方式、属性集、伤害计算、AI、角色和 UI 组织方式。
- 它不是官方 Aura 课程完成态，也不是 Hazelight Angelscript 插件能力基准；执行移植时应把它作为 AS 写法参考，再回查 `GameplayAbilitySystem_Aura_Cpp` 和当前插件绑定能力。

### 8. UnrealCSharp

- 默认路径：当前项目的 `Reference\UnrealCSharp`
- GitHub：`https://github.com/crazytuzi/UnrealCSharp.git`
- SSH：`git@github.com:crazytuzi/UnrealCSharp.git`
- 拉取命令：`Tools\PullReference\PullReference.bat unrealcsharp`
- 该参考源主要用于参考另一套成熟的 Unreal 脚本插件工程如何组织模块、桥接运行时、管理代码生成、处理编辑器集成以及维护插件工程边界。
- 对于"插件架构怎么拆""宿主工程怎么最小化""代码生成和绑定流程怎么组织"这类问题，可以把 `UnrealCSharp` 作为横向参考。

### 9. Tencent UnLua

- 默认路径：当前项目的 `Reference\UnLua`
- GitHub：`https://github.com/Tencent/UnLua.git`
- SSH：`git@github.com:Tencent/UnLua.git`
- 拉取命令：`Tools\PullReference\PullReference.bat unlua`
- 重点目录：
- `Reference\UnLua\Source\`
- `Reference\UnLua\Docs\`
- `Reference\UnLua\Content\Script\Tutorials\`
- 该参考源主要用于观察 Lua 如何直接接入 UE 反射系统、如何覆写 Blueprint 事件、如何组织 Lua 教程与调试支持，以及如何在插件工程中同时承载运行时、编辑器与示例内容。
- 当需要横向比较"脚本事件覆写""Lua 调试与智能提示""零胶水反射暴露"时，优先先看 `UnLua`。

### 10. Tencent puerts

- 默认路径：当前项目的 `Reference\puerts`
- GitHub：`https://github.com/Tencent/puerts.git`
- SSH：`git@github.com:Tencent/puerts.git`
- 拉取命令：`Tools\PullReference\PullReference.bat puerts`
- 重点目录：
- `Reference\puerts\unreal\`
- `Reference\puerts\doc\unreal\`
- `Reference\puerts\doc\unreal\en\`
- 该参考源主要用于观察 TypeScript/JavaScript 运行时如何集成 Unreal、如何组织声明文件生成、如何支持 V8 / QuickJS / Node.js 后端切换，以及如何把脚本生态与宿主引擎解耦。
- `puerts` 虽然与 `UnLua` / `sluaunreal` 同属腾讯生态，但在 Unreal 场景下主要提供的是 JavaScript / TypeScript 能力，应视为独立参考源而不是重复拉取项。

### 11. Tencent sluaunreal

- 默认路径：当前项目的 `Reference\sluaunreal`
- GitHub：`https://github.com/Tencent/sluaunreal.git`
- SSH：`git@github.com:Tencent/sluaunreal.git`
- 拉取命令：`Tools\PullReference\PullReference.bat sluaunreal`
- 重点目录：
- `Reference\sluaunreal\Source\`
- `Reference\sluaunreal\Tools\`
- `Reference\sluaunreal\Content\`
- 该参考源主要用于观察另一套成熟 Lua 插件如何结合 Blueprint 反射、静态代码生成与 CppBinding，以及如何围绕热更新、性能分析与调试器形成完整工作流。
- 当需要比较腾讯内部两条 Lua 路线的差异时，可把 `sluaunreal` 视为偏"静态导出 / 性能 / 线上热更新"的对照项。

### 12. Blender MCP

- 默认路径：当前项目的 `Reference\blender_mcp`
- Blender Forge：`https://projects.blender.org/lab/blender_mcp.git`
- SSH：无（Blender Forge 不提供 SSH clone）
- 拉取命令：`Tools\PullReference\PullReference.bat blendermcp`
- 重点目录：
- `Reference\blender_mcp\mcp\`（MCP Server 工作目录）
- 该参考源用于查看 Blender 官方 MCP Server 的实现方式、MCP 协议接入模式、工具定义与注册方式，以及 DCC 工具链如何通过 MCP 对外暴露能力。
- 未来可能作为子仓库（submodule）独立管理；当前先以 Reference 形式引入做参考。

### 13. TiddlyWiki Document Migration Sources

- 默认路径与固定提交：
  - `Reference\tiddlywiki-itonnote-theme`：`git@github.com:tiddly-gittly/itonnote-theme.git`，`f7e29d2f00c4d24a2eefee9b4b4f27dcf0e918e1`
  - `Reference\tiddlywiki-itonnote-plugin`：`git@github.com:tiddly-gittly/itonnote-plugin.git`，`726a0f00b9fe46890fbdebfb33a38768a5515959`
  - `Reference\tiddlywiki-seq`：`git@github.com:Gk0Wk/TiddlySeq.git`，`96e48da076b86b475948a930ab5f60abe5961d77`
  - `Reference\tiddlywiki-command-palette`：`git@github.com:tiddly-gittly/tw-command-palette.git`，`b3d0535fd499e9fbe00312d0d51e7e5d9b7961df`
  - `Reference\tiddlywiki-plugins`：`git@github.com:tiddly-gittly/tiddlywiki-plugins.git`，`d1ae085fbea63ff39f5474f5d165b3cb4af6704a`
  - `Reference\tiddlywiki-codemirror-6`：`git@github.com:oeyoews/tiddlywiki-codemirror-6.git`，`3854131afe31fa225936808526e9c0cd29524661`
- 拉取命令：`Tools\PullReference\PullReference.bat <对应 key>`。这些命令只在维护者显式执行时访问远端；日常 Wiki 构建只使用本地 `Wiki/src/` 中已导入的源码，不会访问 GitHub。
- 用途边界：itonnote theme 是本地 `$:/themes/angelscript` 的迁移来源，其 Fira Code 资源现已随本地主题打包；itonnote-plugin 不启用，其选定的移动行为已移植到 TDGameStudio plugin；tiddlyseq、tw-command-palette 与 tiddlywiki-plugins 提供已选择 document 体验插件及其依赖。`tiddlywiki-codemirror-6` 仅保留为离线审计参考，不属于运行时导入集合。
- 优先级：当调整 Wiki 的主题、代码展示、sidebar、命令面板或链接预览时，先检查此处固定本地 source 与 `Wiki/external-plugins.json`；运行时外部来源以 `Wiki/src/` 中由主仓库跟踪的导入源码维护，manifest 的 `baselineCommit` 记录最初审计状态。不要反复在线检索或未经审计地升级上游。若将来明确采用编辑器增强，先评估 TiddlyWiki 内置的 `tiddlywiki/codemirror`，不默认启用第三方 CodeMirror 6。

### 14. TW Icons Catalogue Snapshot

- 默认路径与固定提交：`Reference\tw-icons`；`https://github.com/morosanuae/tw-icons.git`，`master` 分支的 `d4a58efeddaa683af69fba1a43717a16e4f0d2ca`（提交说明 `v1.10`，2021-05-07）。
- 形式与体积：上游仓库并未提供拆分式插件或构建工程；历史始终维护一个自包含的 TiddlyWiki `index.html`。当前快照约 56 MiB，内含约 17,000 个跨多个图标库的图标 tiddler，因此它适合本地搜索与逐项核查，不适合在浏览器或 Wiki 运行时加载。
- 许可证边界：仓库没有 `LICENSE` 或打包清单；单文件仅带 TiddlyWiki 本体的 BSD-3-Clause 声明，不能推断其中各图标库的授权。必须在采用单个图标前追溯并复核其对应上游库的许可证和署名要求。
- 优先级与用途：**最低优先级**。只有在当前 `Wiki/src/` 本地图标无法满足需求时，才将它作为离线目录挑选极少量单图标；不得整库导入、不得作为离线导出依赖、不得由日常构建自动 fetch 或更新。

### 15. AngelScript Code-Generator Research Sources

- 默认路径、SSH 来源与定位：
  - `Reference\fuzzilli`：`git@github.com:googleprojectzero/fuzzilli.git`（`main`）；ASIR / ProgramBuilder、corpus、mutation、minimizer 与 lifter 的首要架构参考。
  - `Reference\grammarinator`：`git@github.com:renatahodovan/grammarinator.git`（`master`）；仅作为 grammar-aware parser / lexer fuzz、变异与重组的辅助参考。
  - `Reference\csmith`：`git@github.com:csmith-project/csmith.git`（`master`）；受控正例生成与稳定行为 oracle 的原则参考。
  - `Reference\yarpgen`：`git@github.com:intel/yarpgen.git`（`main`）；可执行程序生成、checksum 和优化测试策略的补充参考。
  - `Reference\creduce`：`git@github.com:csmith-project/creduce.git`（`master`）；保持失败性质的 test-case reduction 工作流参考。
- 这些仓库对应 `AngelScriptCodeGeneratorResearch.md` 的调研结论：Fuzzilli 优先级最高；Grammarinator 不能替代有类型的正例生成器；Csmith/YARPGen 仅借鉴生成约束与 oracle；C-Reduce 仅借鉴 reducer 闭环。
- 它们全部只用于离线设计、实现对照和失败分析，不是 Angelscript 插件的运行时或构建依赖；不应由日常构建自动 fetch。需要固定某次调研基线时，在相关 OpenSpec / 研究记录中记录具体 SHA。

### 16. Angelsea

- 默认路径：当前项目的 `Reference\angelsea`
- GitHub：`https://github.com/asumagic/angelsea.git`
- SSH：`git@github.com:asumagic/angelsea.git`
- 拉取命令：`git clone --recurse-submodules https://github.com/asumagic/angelsea.git Reference\angelsea`
- 分支与本次初始快照：跟随 `main`；2026-08-12 拉取时为 `1d367d431cdfd7e5e51b2341312078fd40cc10a4`。
- 许可证与成熟度：Angelsea 本体为 BSD-2-Clause；上游明确标记为 alpha quality，依赖 AngelScript 2.37.0+ 与其下游 MIR fork。
- 重点目录：
  - `Reference\angelsea\include\`：公共 JIT API 与配置。
  - `Reference\angelsea\src\`：AngelScript bytecode-to-C、MIR codegen、lazy/async compilation 与 VM fallback 实现。
  - `Reference\angelsea\tests\`：JIT 语义、配置与 benchmark 覆盖。
  - `Reference\angelsea\vendor\`：上游锁定的 AngelScript、fmt 与 MIR 子模块；测试依赖另见 `tests\vendor\`。
- 用途与优先级：只在研究 `asIJITCompilerV2`、跨平台 runtime JIT、bytecode-to-C、MIR、lazy/async 编译或解释器回退策略时作为**次级横向参考**。当前项目的 StaticJIT、UE 生命周期与平台约束、maintained AngelScript fork 以及相应测试始终是实现和兼容性判断的首要依据。
- 边界：它不是当前插件的运行时或构建依赖，不直接替换 UE-coupled StaticJIT，也不得因参考其 AngelScript 2.37+ API 而绕过本项目的 2.33 WIP + selective 2.38 backport fork strategy。

### 17. Daslang / daScript

- 默认路径：当前项目的 `Reference\daScript`
- GitHub：`https://github.com/GaijinEntertainment/daScript.git`
- SSH：`git@github.com:GaijinEntertainment/daScript.git`
- 拉取命令：`git clone --recurse-submodules https://github.com/GaijinEntertainment/daScript.git Reference\daScript`
- 分支与本次初始快照：跟随 `master`；2026-08-12 拉取时为 `ae21253fea2b8184f81c00013f2684c98c31174d`。
- 许可证与依赖形态：Daslang 本体为 BSD-3-Clause；当前 checkout 的 `.gitmodules` 为空，第三方源码直接保留在 `3rdparty\` 等目录中。
- 重点目录：
  - `Reference\daScript\include\` 与 `src\`：语言 runtime、compiler、interpreter 和 C++ embedding surface。
  - `Reference\daScript\doc\source\reference\embedding\`：C/C++ 嵌入、外部模块和 AOT 工作流。
  - `Reference\daScript\modules\dasLLVM\`：LLVM JIT、缓存与跨目标 codegen。
  - `Reference\daScript\tree-sitter-daslang\` 与 `utils\mcp\`：结构化语法工具和 compiler-backed MCP server。
  - `Reference\daScript\tests\`、`tests-cpp\` 与 `dastest\`：语言和 runtime 验证组织。
- 用途与优先级：用于横向比较游戏脚本语言的 C++ 数据布局/低开销互操作、tree interpreter、AOT-to-C++、LLVM JIT、hot reload、semantic hashing、compile-time macros、包管理与编译器工具暴露。它是**跨语言次级架构参考**，可启发 standalone、StaticJIT、codegen 或 IDE/tooling 设计，但不能作为 AngelScript 语义、ABI、fork backport 或 UE 集成行为的依据。
- 边界：不是本项目的运行时、编译时或发布依赖；不得把 Daslang 语言设计直接投射成 AngelScript 能力，也不得绕过当前插件的 maintained fork、UE lifecycle 和测试基线。

### 18. Cython

- 默认路径：当前项目的 `Reference\Cython`
- GitHub：`https://github.com/cython/cython.git`
- SSH：`git@github.com:cython/cython.git`
- 拉取命令：`git clone --depth 1 --recurse-submodules https://github.com/cython/cython.git Reference\Cython`
- 分支与本次研究快照：`master`；2026-08-12 为 `86b94cef002aa23aea0b390335ea3d9e9b62c19e`。
- 许可证与仓库形态：Apache-2.0；本轮使用浅克隆，只保留当前研究所需源码，不作为构建依赖。
- 重点目录：
  - `Cython\Compiler\Pipeline.py`：parse、declaration、control-flow、expression/type analysis、typed transform 与 codegen stage。
  - `Cython\Compiler\Nodes.py`、`ExprNodes.py`：statement/expression AST、resolved type、coercion、temporary 和 codegen 行为。
  - `Cython\Compiler\ModuleNode.py`、`Code.py`：C/C++ module emitter、writer、异常和 cleanup 生成。
  - `docs\src\devguide\` 与 `docs\src\userguide\`：compiler internals、C/C++ compilation、对象生命周期和异常契约。
- 用途与优先级：这是 typed semantic HIR → C++ Static AOT emitter 的**第一梯队近邻参考**。优先研究 frontend 已解析语义如何直接驱动 C/C++ codegen，以及类型、coercion、temporary cleanup、引用计数和 error path 如何显式 lowering。
- 边界：不得照搬 CPython C API、GIL、引用计数、extension-module ABI 或表达式级 object-mode slow path；AngelScript/UE ABI、GC 和 dispatch 仍以当前插件为准。

### 19. Numba

- 默认路径：当前项目的 `Reference\numba`
- GitHub：`https://github.com/numba/numba.git`
- SSH：`git@github.com:numba/numba.git`
- 拉取命令：`git clone --depth 1 --recurse-submodules https://github.com/numba/numba.git Reference\numba`
- 分支与本次研究快照：`main`；2026-08-12 为 `43b83d9a0ea3c07108cb73484fcbcc5284615958`。
- 许可证与仓库形态：BSD-2-Clause；本轮使用浅克隆，只作 compiler pipeline 离线研究。
- 重点目录：
  - `numba\core\compiler.py`：untyped、typed、lowering pipeline 组合。
  - `numba\core\untyped_passes.py`、`typed_passes.py`：bytecode/IR analysis、type inference、typed rewrite、IR legalization。
  - `numba\core\lowering.py`、`codegen.py`：typed IR → LLVM 与 executable materialization。
  - `numba\core\caching.py`：signature、target、bytecode/closure identity 和 serialized object cache。
- 用途与优先级：这是 future structured HIR → typed CFG/SSA → LLVM 分层、specialization key、typed pass 和 native cache 的**第一梯队参考**。它不证明当前 Static AOT 必须从 bytecode 起步；Numba 的 bytecode boundary 来自 CPython 输入模型。
- 边界：不引入 Python object mode、NumPy 特定优化、CPython ABI 或 Numba runtime；只借鉴 pass boundary、typed IR contract、cache identity 和错误/回退可观察性。

### 20. Luau

- 默认路径：当前项目的 `Reference\luau`
- GitHub：`https://github.com/luau-lang/luau.git`
- SSH：`git@github.com:luau-lang/luau.git`
- 拉取命令：`git clone --depth 1 --recurse-submodules https://github.com/luau-lang/luau.git Reference\luau`
- 分支与本次研究快照：`master`；2026-08-12 为 `ca128af4c531310d6f5c1b354df4b79fdd782ede`。
- 许可证与仓库形态：MIT；本轮使用浅克隆，仓库不作为 Runtime 或发布依赖。
- 重点目录：
  - `CodeGen\src\IrBuilder.cpp`、`BytecodeAnalysis.cpp`：从 `Proto` bytecode 重建 CFG、读取 type info 并建立 native IR。
  - `CodeGen\src\IrTranslation.cpp`：instruction lowering、type guard、fallback block 和 `vmExit(pc)`。
  - `CodeGen\src\IrLoweringX64.cpp`、`IrLoweringA64.cpp`：architecture-specific lowering。
  - `CodeGen\src\CodeGenContext.cpp`：native code allocation、entry/metadata 安装、销毁和 VM handoff。
- 用途与优先级：这是 Angelsea/LLVM Runtime JIT 的**第一梯队 bytecode-native 参考**，重点用于 VM exit、guard、fallback、code lifecycle 和多架构 backend；不用于证明 typed semantic Static AOT 应放弃 source HIR。
- 边界：Luau 的渐进类型、Lua object model、VM register layout、GC 和 native ABI 都不可直接移植；任何结论必须映射回 AngelScript bytecode、context、GC 和 UE 平台约束。

### 21. GenericMessagePlugin

- 默认路径：当前项目的 `Reference\GenericMessagePlugin`
- GitHub：`https://github.com/wangjieest/GenericMessagePlugin.git`
- SSH：`git@github.com:wangjieest/GenericMessagePlugin.git`
- 拉取命令：`git clone --recurse-submodules https://github.com/wangjieest/GenericMessagePlugin.git Reference\GenericMessagePlugin`
- 分支与本次初始快照：跟随 `main`；2026-08-12 拉取时为 `85283fbec0edba1a04c1cff8181455c5d97ba60a`。
- 许可证与仓库形态：Apache-2.0；当前没有 Git submodule。实际插件位于 `Reference\GenericMessagePlugin\Plugins\GMP\`。
- 重点目录：
  - `Plugins\GMP\Source\GMP\`：Runtime key/message、signature、storage、request/response、serialization 与 script bridge 基础。
  - `Plugins\GMP\Source\GMPEditor\GMPEditor\`：K2 message nodes、签名索引、脚本 codegen 与编辑器集成。
  - `GMPEditor\Private\GMPAngelScriptCodeGen.*`：从消息签名表生成强类型 `Script\GMPMessages.as` 声明的 AngelScript 专项实现。
  - `docs\` 与 `wiki\`：dispatch layer、parameter compatibility、transparent rewrite、jump tracing 等设计说明。
- 用途与优先级：当研究 UE 内跨 C++、Blueprint、AngelScript、UnLua/slua、Puerts 与 C# 的 key-based message bus，或研究签名收集、编辑期类型检查、K2 pin 生成、request/response、sticky/collection message、AS declaration codegen 和调用点追踪时，作为**专项次级参考**。AngelScript 接入结论仍须回到当前插件的 binding、preprocessor、codegen 和测试约定验证。
- 边界：不是当前项目依赖，不直接复制为插件公共 API；其 MessageTags、可选脚本后端和第三方代码需分别审查模块边界、UE 5.7 兼容性及许可证后方可借鉴。

### 22. GenericStorages

- 默认路径：当前项目的 `Reference\GenericStorages`
- GitHub：`https://github.com/UnrealBytes/GenericStorages.git`
- SSH：`git@github.com:UnrealBytes/GenericStorages.git`
- 拉取命令：`git clone --recurse-submodules https://github.com/UnrealBytes/GenericStorages.git Reference\GenericStorages`
- 分支与本次初始快照：跟随 `master`；2026-08-12 拉取时为 `3291175f699fa836799006cf8d03c0db70548ab0`。
- 许可证与仓库形态：MIT；当前没有 Git submodule。实际插件位于 `Reference\GenericStorages\GenericStorages\`，`.uplugin` 版本为 `0.9`，包含一个 `PreDefault` Runtime 模块。
- 重点目录：
  - `GenericStorages\Source\GenericStorages\Public\`：world/subsystem/class/object/member storage、generic singleton/system、deferred component、platform storage 等工具。
  - `GenericStorages\Source\GenericStorages\Template\`：兼容层、property accessor、type-table 和 component/attribute helpers。
  - `GenericStorages\Source\GenericStorages\Private\Editor\`：class/object/data-table/component picker 与 details customization。
  - `GenericStorages\Source\GenericStorages\Classes\S3Helper.*`：S3 upload/download、断点续传与 Blueprint wrapper。
- 用途与优先级：仅作为**低优先级工具类参考**，用于比较 UE registry/storage/singleton/subsystem 模板、延迟组件注册、编辑器 picker、移动端权限/deep-link、持久化 KV 与 S3 helper。它不提供 AngelScript 语义或插件集成基线；涉及类似能力时优先复用 UE 公共 API 和当前插件既有架构。
- 边界：不是当前项目依赖；借鉴前须逐项审查其广泛 public include surface、Runtime 模块内的 editor 条件代码、平台分支、UE 版本兼容宏和安全敏感的凭据/网络处理。

### 23. UECling

- 默认路径：当前项目的 `Reference\UECling`
- GitHub：`https://github.com/Evianaive/UECling.git`
- SSH：`git@github.com:Evianaive/UECling.git`
- 拉取命令：`git clone --recurse-submodules git@github.com:Evianaive/UECling.git Reference\UECling`
- 分支与本次初始快照：跟随 `master`；2026-08-12 拉取时为 `1723959c48ae9316d229cdefece54daf47526427`。
- 仓库形态：当前没有 Git submodule，也没有 README 或仓库级 LICENSE；工作副本约 159 MiB，并直接携带 LLVM/Clang 22 与 CppInterOp 头文件。其 `.tps` 仍是未声明真实第三方来源的 sample 文本，因此不能据此推断许可证或再分发权限。
- 重点目录：
  - `Source\ClingRuntime\`：CppInterOp interpreter wrapper/pool、PCH profile、语义信息、notebook、property bag 和运行时执行入口。
  - `Source\ClingEditor\`：REPL/notebook 编辑器、C++ 语义高亮、Cling notebook/script Blueprint asset factory 与编辑器界面。
  - `Source\ClingKismet\`：`Execute C++ Script` K2 节点、脚本 Blueprint compiler 与恢复代码生成。
  - `Source\ThirdParty\ClingLibrary\`：Cling/CppInterOp 外部模块、LLVM/Clang 22 头文件和 Win64 library/runtime dependency 配置。
  - `Content\`：运行 C++ script、数学和结构体交互的示例资产。
- 用途与优先级：仅作为**低优先级横向参考**，用于研究 Unreal 内嵌增量 C++ interpreter、预热 interpreter pool、PCH/build-info 输入、REPL/notebook、Blueprint 动态参数、脚本生成类和编辑器语义信息。涉及当前项目的语言语义、StaticJIT、热重载、绑定、UObject 生命周期或产品能力时，仍以 Angelscript maintained fork、当前插件实现、Hazelight 参考和现有测试为准。
- 边界：它不是当前项目的运行时、构建或发布依赖，不得直接复制或分发其源码、LLVM/Clang/CppInterOp 内容或示例资产；任何采用都必须先确认上游代码来源、第三方版本、许可证、UE 5.7/5.8 兼容性和平台支持。

## 如何选择参考源

- AngelScript 语言或运行时本体问题，优先参考 `angelscript-v2.38.0`。
- Unreal 集成、绑定策略、编辑器交互、测试工程组织问题，优先参考 `HazelightAngelscriptEngineRoot` 指向的 Hazelight 参考仓库。
- 涉及引擎级补丁、引擎内扩展点或插件无法独立解释的底层行为时，同样优先参考 `HazelightAngelscriptEngineRoot` 指向的仓库。
- 需要确认 Hazelight 对外文档、能力描述、教程结构或站点内容组织时，优先看 `Docs-UnrealEngine-Angelscript`。
- 需要确认 Hazelight VS Code 扩展、Language Server、Debug Adapter、断点调试、错误展示或 workspace 交互时，优先看 `vscode-unreal-angelscript`。
- 需要 Aura 课程起始练习资产、GAS Top Down RPG 示例素材组织或 UE 5.2 示例内容工程结构时，优先看 `GameplayAbilitySystem_Aura_Initial`。
- 需要 Aura 课程实现完成态、C++ GAS 代码结构、Ability/MVVM/MotionWarping 接入和最终资源组织时，优先看 `GameplayAbilitySystem_Aura_Cpp`。
- 需要 Aura GAS 的 Angelscript 写法、AS 侧脚本分层或第三方迁移笔记时，参考 `AngelscriptAura`，但关键行为仍回查 Aura C++ 源码和当前插件绑定。
- 跨语言但同属 Unreal 脚本插件架构、模块边界、工程组织问题，可额外参考 `UnrealCSharp`。
- 需要参考 Lua 反射接入、Blueprint 事件覆写、教程组织时，优先看 `UnLua`。
- 需要参考 JavaScript / TypeScript 运行时、声明生成、脚本后端切换时，优先看 `puerts`。
- 需要比较另一套 Lua 静态导出、性能优化与热更新工作流时，优先看 `sluaunreal`。
- 需要参考 MCP 协议接入、MCP Server 实现方式或 DCC 工具链 MCP 暴露模式时，优先看 `blender_mcp`。
- 需要研究 `asIJITCompilerV2`、bytecode-to-C、MIR、lazy/async runtime JIT 或解释器回退时，可查看 `angelsea`；涉及当前插件落地时仍优先依据本地 StaticJIT、UE 集成边界和 maintained fork。
- 需要横向比较游戏脚本语言的 C++ 互操作、interpreter/AOT/JIT/hot-reload 分层、宏系统或 compiler-backed tooling 时，可查看 `daScript`；AngelScript 行为判断仍回到本项目和官方 AngelScript 参考源。
- 需要研究 typed AST → C/C++ emitter、coercion、temporary cleanup 和异常 lowering 时，优先查看 `Cython`。
- 需要研究 untyped/typed IR 分层、future CFG/SSA、LLVM lowering、specialization 或 object cache 时，优先查看 `numba`。
- 需要研究 bytecode native codegen、type guard、fallback block、VM exit 或 x64/A64 code lifecycle 时，优先查看 `luau`。
- 需要研究 UE 跨 C++、Blueprint、AngelScript 与其他脚本后端的消息签名、编辑期校验、AS codegen、K2 节点或调用追踪时，可查看 `GenericMessagePlugin`。
- 需要参考通用 UE registry/storage/singleton/subsystem、picker、平台持久化或 S3 helper 时，最后再查看 `GenericStorages`，并优先评估 UE 原生能力和当前项目既有工具。
- 需要横向研究 Unreal 内嵌 Cling/CppInterOp、运行时 C++ interpreter、REPL/notebook、Blueprint C++ script node 或预热 interpreter pool 时，可查看 `UECling`；实现判断仍回到当前插件边界，并先核对许可证和第三方来源。
- 需要调整 AngelscriptWiki 的 itonnote 迁移主题或选定 document 插件时，优先看本节固定的本地 TiddlyWiki source；其中运行时版本以 `Wiki/src/` 和 `Wiki/external-plugins.json` 为准。

## 使用约束

- 外部参考仓库不应直接作为当前项目的一部分提交。
- GitHub 来源的参考仓库，应优先使用各自对应的 SSH 地址，通过统一入口 `Tools\PullReference\PullReference.bat` 拉取或同步到当前项目的 `Reference/` 目录。
- 对于 AngelScript v2.38.0，默认按"每个项目各自拉取到自己的 `Reference/` 目录"处理，不再依赖项目外部的固定公共路径。
- 对于 `Docs-UnrealEngine-Angelscript`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理。
- 对于 `vscode-unreal-angelscript`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理。
- 对于 `GameplayAbilitySystem_Aura_Initial`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理，并固定在课程初始提交，除非明确要分析课程完成态。
- 对于 `GameplayAbilitySystem_Aura_Cpp`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理，并跟随上游 `main` 获取课程完成态实现。
- 对于 `AngelscriptAura`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理，并跟随上游 `main` 获取第三方 Angelscript 改写参考。
- 对于 `UnrealCSharp`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理。
- 对于 `UnLua`、`puerts`、`sluaunreal`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理。
- 对于 `blender_mcp`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理；该仓库位于 Blender Forge（非 GitHub），仅支持 HTTPS clone。
- 对于 `angelsea`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理；首次 clone 必须递归初始化其固定子模块，后续更新时应同时核对主仓库 SHA 与 submodule 状态。
- 对于 `daScript`、`GenericMessagePlugin` 与 `GenericStorages`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理；即便当前某仓库没有活动 submodule，统一 clone 命令仍保留 `--recurse-submodules`，后续上游新增依赖时不留下空目录。
- 对于 `Cython`、`numba` 与 `luau`，当前按 OpenSpec 研究所需保留浅克隆快照；更新前先在 `feature-as-typed-semantic-aot` 研究附件记录新 SHA 和结论变化。它们不由日常构建读取，也不自动联网更新。
- 对于 `UECling`，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理；只作为本地研究副本，不由日常构建读取或自动更新。因为上游没有仓库级 LICENSE，任何实现借鉴或再分发之前必须先补齐代码来源和第三方许可证审查。
- 对于 TiddlyWiki document migration sources，同样按"每个项目各自拉取到自己的 `Reference/` 目录"处理，并固定在上表列出的审计提交；日常构建不得自动 fetch 或更新它们。
- 本地配置来源的参考仓库，使用前先读取 `AgentConfig.ini`，不要在通用文档或脚本中写死机器路径。
- 当前本地配置来源包括：`HazelightAngelscriptEngineRoot`。
- 如果不同参考源之间存在差异，应显式区分"语言本体行为""UE 插件集成差异""引擎侧改造差异"，不要混写。
- `Hazelight Docs` 与 `Hazelight Angelscript` 不是同一个参考源：前者是公开文档仓库，后者是本机配置的源码参考路径，不能混用。
- `Hazelight VS Code Angelscript` 与 `Hazelight Angelscript` 也不是同一个参考源：前者是 VS Code 外部工具链，后者是 UE 引擎/插件源码参考路径；调试协议联调时需要同时区分客户端扩展逻辑与插件 DebugServer 逻辑。
- `UnLua` 与 `sluaunreal` 虽然同属 Lua 方案、`puerts` 与它们同属腾讯生态，但三者用途、语言重心和工程结构都不同，不应视为重复仓库。

## 维护规则

- 后续新增参考仓库时，优先按总表补充：名称、入口与说明。
- 如果新增仓库可通过 GitHub 拉取，应优先接入 `Tools\PullReference\PullReference.bat`，而不是再新增单独脚本。
- 如果新增仓库需要更详细的优先级说明，应在本文件追加独立小节，而不是继续堆积到 `Agents_ZH.md`。
