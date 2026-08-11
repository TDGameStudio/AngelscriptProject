## Why

AngelScript 当前通过 `FConsoleVariable` 同时承担“定义新 CVar”和“查找既有 CVar”，但没有明确的类型、所有权、延迟注册、模块卸载或热重载契约；底层还把多个 `FScriptConsoleVariable<T>` 特化存入只按 `int32` 特化注册的 AngelScript 值类型。正常读写虽已可用，但同名声明、初始编译竞争、失效句柄和脚本删除/改名后的残留行为都不确定，继续扩展 flags、优先级或回调会放大这些风险。

## What Changes

- 将 AngelScript 的 `FConsoleVariable` 底层改为单一非模板句柄，消除跨模板特化布局、成员函数和析构调用的依赖，并明确复制/赋值语义。
- 在 `AngelscriptRuntime` 内引入脚本 CVar registry，区分脚本创建与原生借用对象，并以脚本模块/generation 管理定义提交、卸载和热重载协调。
- 新增显式的 `Console::Define(...)` 与 `Console::Find(...)` API；保留现有 `FConsoleVariable(Name, DefaultValue, Help)` 构造形式作为兼容入口。
- 为句柄增加有效性、就绪状态、名称和类型查询，避免延迟注册期间静默返回零值或吞掉写入。
- 规定同名兼容定义、类型不匹配、CVar/Console Command 撞名、编译失败和延迟注册竞争的确定性行为与诊断。
- 增加受控的持久 flags 与设置来源语义；首期不暴露原始 UE flags 位掩码、直接 CVar change callback 或 `TConsoleVariable<T>` 泛型 API。
- 在 `AngelscriptTest` 新建 ConsoleVariable 主题测试目录，按当前测试规范覆盖值类型、生命周期、初始编译、热重载、原生借用、冲突和设置优先级，并补充一个真实 `.as` 使用示例。

## Capabilities

### New Capabilities

- `as-console-variable-contract`: 规定 AngelScript 定义、查找、读写和管理 Unreal Console Variable 时的 API、类型、所有权、生命周期、热重载、诊断与优先级行为。

### Modified Capabilities

- None.

## Impact

- 主要修改 `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Console.*`，并在 Runtime 中增加聚焦的 CVar registry 实现；不新增 Editor binding 或 Editor 模块依赖。
- 测试位于 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/ConsoleVariable/`，继续使用现有 AngelScript engine/module fixture 和 UE Automation 入口。
- 现有脚本构造语法保持兼容；新增 API 和诊断属于增量改进，不计划破坏已有 `Get*`/`Set*` 调用。
- 不改变 `FConsoleCommand` 的公开行为，只有共享名称冲突检查和必要的 registry 协调可以触及其实现。
- 插件源码和测试属于 `Plugins/Angelscript` 子模块；OpenSpec 记录属于父仓库，实施时必须先提交子模块，再提交父仓库 gitlink。
