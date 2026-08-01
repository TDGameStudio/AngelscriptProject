# AngelScript Standalone 离线契约导出

本文说明 Unreal Editor 如何把当前**最终完成注册**的 AngelScript 编译表面导出为 Standalone 编译器可消费的离线 Bundle。该 Bundle 是声明与类型检查契约，不是运行时快照，也不是可执行缓存。

## 边界

- 导出发生在引擎配置、手写 Binding、UHT 生成 Binding、反射回退、可选插件注册和当前成功脚本编译之后。
- 导出器只观察最终 `FAngelscriptEngine` / `asIScriptEngine`；`Bind_*.cpp`、ClassGenerator 和第三方 Binding 不需要添加 standalone 分支、宏或导出调用。
- Standalone 进程只读取 JSON 文件，不加载 Unreal Engine、项目 DLL、插件 DLL、UObject 或 Asset Registry。
- Bundle 不记录原生函数地址、对象地址、C++ 源码、AngelScript 源文、函数体、字节码、资产 payload 或可变 Editor 状态。
- JSON 中的稳定 ID 来自规范化语义身份，不使用进程内 type/function ID，因此不受 ASLR、热重载和原生地址变化影响。

## Commandlet

仓库内通过统一 runner 执行。多个 Commandlet 参数建议先组成数组，避免
PowerShell 把 `-BundleKind` 等参数误绑定为 runner 自身的参数：

```powershell
$bundleArgs = @("-BundleKind=Project", "-Output=D:\Exports\MyProjectAS", "-AssetRoots=/Game,/MyPlugin")
& Tools\RunCommandlet.ps1 -Commandlet AngelscriptOfflineExport -Label offline-bundle-project -TimeoutMs 600000 -ExtraArgs $bundleArgs
```

`RunCommandlet.ps1 -ProjectFile <绝对或相对 .uproject>` 可在外部消费项目上运行同一插件内 Commandlet；省略时保持 `AgentConfig.ini` 的仓库默认项目行为。若通过 `powershell.exe -File` 启动子 PowerShell 并传递多个以 `-` 开头的 Commandlet 参数，请把参数保存为 JSON 字符串数组，使用 `-ExtraArgsFile <json>`；runner 会把文件参数与直接 `-ExtraArgs` 按顺序合并并验证每项均为非空字符串。

可用参数：

| 参数 | 含义 |
|---|---|
| `-Output=<目录>` | Bundle 目标目录。未指定时，项目包写入 `Saved/AngelscriptStandalone/project/`，默认引擎包写入 `Saved/AngelscriptStandalone/default-engine/`。`Saved/` 已被版本控制忽略。 |
| `-BundleKind=Project\|DefaultEngine` | 两者都导出当前宿主的完整最终表面。`Project` 表示由用户显式选择的精确项目 Bundle；`DefaultEngine` 表示发行包中省略 `--bundle` 时选中的默认 Bundle。该参数不筛选符号。默认是 `Project`。 |
| `-AssetRoots=/Game,/PluginMount` | 逗号或分号分隔的 Asset Registry 根。`Project` 未指定时默认 `/Game`；`DefaultEngine` 必须由发布流程显式声明需要收录的根。 |
| `-AssetExcludeRoots=/Game/Internal` | 可选的资产排除根；排除范围会写入 manifest。 |
| `-AllowIncompleteAssets` | 明确允许资产作用域不完整。符号作用域仍必须完整。 |

Commandlet 不提供模块或插件符号过滤参数。未知参数（包括 `-Modules`、`-Plugins`）会返回非零退出码，避免把局部符号集伪装成完整 Bundle。

`DefaultEngine` 是选择/分发角色，不是“只含引擎”或“最小宿主”过滤器。
官方默认包由仓库中签入的 `AngelscriptProject.uproject` 及其正常启用插件生成，
显式收录 `/Game`，因此会如实包含项目注册、可选插件、当前成功脚本基线和项目
资产作用域。生成命令为：

```powershell
$defaultArgs = @("-BundleKind=DefaultEngine", "-Output=D:\Exports\AngelscriptProject-UE5.8-default", "-AssetRoots=/Game")
& Tools\RunCommandlet.ps1 -Commandlet AngelscriptOfflineExport -Label offline-bundle-default-ue58 -TimeoutMs 600000 -ExtraArgs $defaultArgs
```

当前签入的默认快照来自
`UE 5.8.0-55116800+++UE5+Release-5.8`，项目名为
`AngelscriptProject`，包含 `130068` 条符号和 `9` 条资产记录，完整
symbol/asset scope，Bundle identity 为
`f40af33a32752146226f0ed92eaaed7c6e35de4c14caa27c969527237c80ae1c`。
源码分发文件位于
`Plugins/Angelscript/Standalone/Contracts/UE5.8/default-engine.zip`；
CMake 会展开并校验其三个文件，构建树和安装包仍只暴露普通的
`contracts/default-engine/` 目录，Standalone 运行时不读取 ZIP。

发布前必须从相同最终状态导出两次，并逐字节比较三个文件。当前文件哈希为：

| 文件 | SHA-256 |
|---|---|
| `manifest.json` | `a8dfe32e63967a6ef49cd6c3e8089e24be0393dab3f8d003d9ec2d25eb434ffa` |
| `symbols.jsonl` | `911698ba49bf65c6ac7abacd5938691ce0872e81bbfd16c17a5d0a7ff3d71f54` |
| `assets.jsonl` | `28a4028fc2418ca96f5a82734265ca9dfdf59f5903056882039b77be98d45d9f` |

其他 UE 项目无需依赖本仓库宿主模块或复制导出代码；只要启用
`Angelscript` 插件，就可以在自己的 `.uproject` 上运行同一个
`AngelscriptOfflineExport` Commandlet，生成 `Project` Bundle 后通过
Standalone 的 `--bundle <目录>` 显式选择。该显式 Bundle 会完整替换发行包
默认值，不发生合并或回退。

标准外部消费验证会创建一个没有 `Modules` 字段、没有 C++ host module 的临时 content-only 项目；它只通过 `AdditionalPluginDirectories` 指向仓库插件目录并启用 `Angelscript`。项目使用正常引擎插件基线，而不是 `DisableEnginePluginsByDefault` 的非典型最小描述符，以保持 Commandlet 初始化/退出生命周期与真实消费项目一致：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite StandaloneRelease -TimeoutMs 1200000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStandaloneExternalSmoke.ps1 -TimeoutMs 1200000
```

smoke 会分别验证项目本地默认输出和显式输出、逐字节比较三个 Bundle 文件、扫描机器绝对路径与仓库宿主模块泄漏，然后从最终 Release ZIP 解压唯一的 `as-standalone.exe` 消费显式 Project Bundle。机器可读结果写入 `Saved/StandaloneExternalSmoke/<RunId>/Summary.json`。

## Bundle 布局

成功发布的目录只包含三个规范文件：

```text
manifest.json
symbols.jsonl
assets.jsonl
```

- `manifest.json`：schema、Bundle 类型、producer/plugin/fork/compiler contract 版本、UE/平台/配置、引擎属性、feature flags、已加载模块与插件、符号/资产作用域、适配器、文件字节数、记录数、SHA-256 和 Bundle identity。
- `symbols.jsonl`：规范排序的类型、枚举、typedef、funcdef、delegate、行为、属性、方法、全局函数和全局变量声明。Callable 参数可携带可选 `resourceKind` / `resourceTypeStableId`；该标记来自最终手写注册或反射元数据，Standalone 仍必须先按稳定 callable ID 解析调用，不能只靠参数名或函数名推断资源语义。
- `assets.jsonl`：规范化 package/object/generated-class 路径、类/父类关系、mount、模块/插件来源、redirect、availability 和经过审查的类型检查标签。

三个文件均为无 BOM UTF-8、LF 换行和确定性字段/记录顺序。相同最终状态重复导出应得到逐字节相同的内容和相同 Bundle identity。

写入使用同级 staging 目录。只有 JSONL、计数、哈希和 manifest 全部完成后才原子替换目标目录；参数、前置条件、序列化、完整性或重命名失败时，不留下 manifest-valid 的局部目标。

## 完整性语义

符号与资产使用两个独立作用域：

- `symbolScope.complete` 必须为 `true`。最终引擎遍历失败、稳定 ID 冲突、符号过滤或不能证明完整时，Commandlet 失败且不发布。
- `assetScope.complete` 可以为 `false`，但只有显式传入 `-AllowIncompleteAssets` 才能发布。manifest 会保留扫描根、排除根、skipped 项、Registry 状态和诊断；Standalone 在未被完整覆盖的范围只能返回 `unknown`，不能断言资源缺失。

符号记录还区分两层：

- `host-surface`：手写、UHT 生成、native-module、反射、Blueprint、可选插件和项目注册形成的最终宿主声明；
- `script-baseline`：当前最后一次成功编译并仍处于 active 状态的脚本声明。

失败或过时的脚本替换不会进入基线。基线只含声明和关系，不含源码、函数体或字节码。Standalone 始终回放 host surface；对本次源码闭包中的脚本模块，按稳定模块 ID 替换相同 baseline，闭包外 baseline 仅作为依赖声明。

离线稳定模块 ID 与 Standalone frontend 的内部源码身份是两个有意分离的身份域；内部身份只属于 Standalone 私有实现，不形成 UE/Standalone 共享 ABI。Bundle 侧使用 `SHA-256("module-id-v1\n" + logical-module-name + "\n" + virtual-source-identity)`；UE-validation 的 `--script-root` 在 v1 表示项目 `Script/` 根，因此 `Foo/Bar.as` 的虚拟源身份为 `/Angelscript/Game/Foo/Bar.as`。这使当前项目源码能够精确替换由 UE 导出的同名 baseline，同时同名但虚拟来源不同的记录仍按冲突失败，不能靠模块名静默覆盖。v1 没有插件/memory mount 推断；这类源码需要后续显式 mount 契约，不能把任意目录猜成项目脚本。

## Bundle 类型与选择

`project` 与 `default-engine` 都是**完整、独立的符号快照**，不是增量或 overlay：

1. Standalone 指定显式 Bundle 时，只加载该目录；
2. 未指定时，只加载发行包内的 `default-engine`；
3. v1 不合并默认包和项目包，不搜索“最新缓存”，不从环境变量隐式选择；
4. 显式 Bundle 无效时直接失败，不回退到默认包。

Producer 与 consumer 都校验 schema major、必需字段、UTF-8、文件清单、记录数、SHA-256、稳定 ID 一致性和完整符号作用域。新增可选字段使用 schema minor；破坏性字段或语义变更提升 schema major/contract version。

发行包在 `Schemas/` 中同时提供 manifest、symbol、asset、result、differential-result 与 corpus-index 的 machine-readable schema。差分结果只允许规范化编译状态、诊断、稳定符号、portable class/resource 子集及 bytecode 是否完成；不记录或比较 bytecode bytes、进程内 ID、地址、耗时和机器绝对路径。

## 相关验证

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.CppTests.OfflineContract" -Label offline-contract-runtime -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTests.ps1 -TestPrefix "Angelscript.Editor.OfflineContract" -Label offline-contract-editor -TimeoutMs 600000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite Standalone -TimeoutMs 900000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunTestSuite.ps1 -Suite StandaloneRelease -TimeoutMs 1200000
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunStandaloneExternalSmoke.ps1 -TimeoutMs 1200000
```

阶段证据记录在 `openspec/changes/feature-ue-angelscript-standalone-compiler/verification/phase-02-offline-contract.md`。
