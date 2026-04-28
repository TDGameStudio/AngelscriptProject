# AngelScript Fork 演进策略指南

## 核心定位

**当前 ThirdParty/angelscript 已经是一个深度定制的 fork，不是、也不再可能是 vanilla AngelScript 的某个版本。**

当前 fork 基于 2.33 WIP 起步，经过大量 `[UE++]` 改造（78 个源文件中 32 个包含定制标记，累计 73+ 处显式改动），已经在内存管理、模块系统、对象类型、编译器、解析器、恢复器、类型系统等核心面形成了与上游不可调和的结构分叉。同时，又从 2.38 选择性吸收了 foreach 语法解析、模块查找 API、导入函数 traits、恢复器表面等能力。

这意味着：
- ❌ **整体升级到 2.38（或任何未来版本）已不可行**：改动规模和语义差异太大，强行整包替换会破坏所有现有的 UE 集成、热重载、类生成、绑定系统和调试协议。
- ✅ **正确策略是持续从高版本中选择性吸收改进**：把上游视为"改进来源"而非"升级目标"。

## fork 与 vanilla AS 的关键分叉点

以下差异是结构性的，不会也不应该被"修复"回 vanilla 行为：

| 领域 | 本 fork 行为 | Vanilla AS 行为 | 分叉原因 |
|------|-------------|----------------|---------|
| 对象引用 | 自动引用语义，无 `@` 句柄 | 显式 `@` 句柄语法 | UE 对象生命周期由引擎管理 |
| 全局变量 | 必须 `const` | 支持可变全局 | 防止脚本侧全局状态副作用 |
| 脚本 `interface` | 不支持，仅原生注册 | 支持脚本层 interface | 接口通过 UE 反射 UINTERFACE 实现 |
| `mixin class` | 不支持，仅 mixin 函数 | 支持 mixin class | 与 UE 类层级模型冲突 |
| 内存分配 | `FMemory` 接管，APV2 池管理 | 标准 malloc/free | 统一到 UE 内存跟踪 |
| 模块系统 | APV2 符号存储 + 热重载状态 | 标准模块存储 | 支持 UE 热重载与版本链 |
| 对象类型 | APV2 私有高位标志 | 标准标志位 | 扩展类型元信息 |
| 字节码恢复 | 2.33 式字节码布局 + APV2 容器 | 标准 2.38 恢复器 | 保持与预编译数据兼容 |

## 从高版本吸收改进的操作原则

### 什么适合吸收

1. **Bug 修复**：崩溃、内存安全、编译器正确性 → 逐条对照 changelog，验证是否在当前 fork 上复现，再移植
2. **语言能力**：foreach、bool 上下文转换、默认拷贝语义等 → 把语法解析和编译器改动适配到当前 fork 结构上
3. **性能改进**：computed goto、JIT v2 接口改进 → 评估是否与 APV2 内存/执行模型兼容
4. **类型系统补齐**：TOptional intrusive state、UStruct 类型表示等 → 在当前绑定架构上做最小闭环

### 什么不适合吸收

1. **与 fork 分叉点冲突的改动**：涉及 `@` 句柄、可变全局、脚本 interface、mixin class 的变更 → 跳过
2. **需要整体替换模块系统的改动**：触及模块存储、符号表、热重载链路的大范围重构 → 除非能证明比当前 APV2 方案更好，否则不吸收
3. **仅与 vanilla 使用模式相关的修复**：如 `?&` unsafe ref、显式句柄工厂等 → 当前 fork 没有这些特性，不适用

### 操作流程

```
1. 识别目标改进
   ↓ 从 changelog、diff、issue tracker 确定候选项
2. 适用性评审
   ↓ 对照 ASSDK_Fork_Differences.md 和当前 [UE++] 标记点，判断是否可移植
3. 影响面分析
   ↓ 确定涉及的 ThirdParty 源文件和依赖的 Runtime/Binds 文件
4. 先补 failing test
   ↓ 在 AngelscriptTest 中建立能暴露当前行为不正确或能力缺失的测试
5. 最小实现
   ↓ 只改必要的代码，新增的 [UE++] 改动必须加注释标记
6. 回归验证
   ↓ 全量 AngelscriptFast + 受影响主题的 AngelscriptFunctional
```

### 代码标记约定

所有对 ThirdParty/angelscript/source 的改动必须使用 `[UE++]` 注释标记：

```cpp
//[UE++]: 简要说明改动目的和与上游的差异
// 例如：
//[UE++]: Lower stock foreach(...) syntax into regular script using opFor* methods.
//[UE++]: Preserve APV2 local/inherited property ownership while exposing the stock restore helper signature.
```

这些标记是后续追踪 fork 分叉点的唯一可靠线索，**不可省略**。

## 当前已吸收的 2.38 能力

| 能力 | 来源 | 落地状态 |
|------|------|---------|
| foreach 语法解析 | `as_parser.cpp` | 已落地，lowering 到 opFor* 方法 |
| foreach 编译器支持 | `as_compiler.cpp` | 已落地 |
| 模块函数/声明查找 API | `as_module.cpp` | 已落地，适配 APV2 符号存储 |
| 导入函数 traits | `as_module.cpp` | 已落地 |
| 恢复器表面 | `as_restore.cpp`, `as_scriptfunction.cpp` | 已落地，桥接 2.33 字节码布局 |
| 对象类型/类型信息宽标志位 | `as_objecttype.cpp`, `as_typeinfo.cpp`, `as_scriptengine.cpp` | 已落地，兼容 APV2 私有高位 |
| 内存池清理逻辑 | `as_memory.cpp` | 已落地，保持 FMemory 后端 |

## 待评估 / 进行中的吸收项

每项均有独立 Plan 文档管理，此处仅列索引：

| 方向 | Plan 文档 | 状态 |
|------|-----------|------|
| foreach 端到端闭环 | `Plan_AS238ForeachPort.md` | 未开始 |
| Lambda / 匿名函数 | `Plan_AS238LambdaPort.md` | 未开始 |
| 函数模板 | `Plan_FunctionTemplate.md` | 未开始 |
| 上下文 bool 转换 | `Plan_AS238BoolConversionPort.md` | 未开始 |
| 默认拷贝语义 | `Plan_AS238DefaultCopyPort.md` | 未开始 |
| using namespace | `Plan_AS238UsingNamespacePort.md` | 未开始 |
| 成员初始化模式 | `Plan_AS238MemberInitPort.md` | 未开始 |
| 关键 Bug 修复回移 | `Plan_AS238BugfixCherryPick.md` | 未开始 |
| JIT v2 接口 | `Plan_AS238JITv2Port.md` | 未开始 |
| Computed goto | `Plan_AS238ComputedGotoPort.md` | 未开始 |
| 非 Lambda 类型系统 | `Plan_AS238NonLambdaPort.md` | 未开始 |

## 参考资源

| 资源 | 路径 / 入口 |
|------|------------|
| 上游 2.38.0 参考源码 | `Reference/angelscript-v2.38.0`（`Tools\PullReference\PullReference.bat angelscript`） |
| Fork 差异记录 | `Documents/Guides/ASSDK_Fork_Differences.md` |
| 当前 ThirdParty 源码 | `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/` |
| `[UE++]` 改动分布 | 32 个文件，73+ 处标记 |
| 2.38 changelog | `Reference/angelscript-v2.38.0/sdk/docs/articles/changes2.html` |
| 优先级总览 | `Documents/Plans/Plan_StatusPriorityRoadmap.md` |
| 机会全景索引 | `Documents/Plans/Plan_OpportunityIndex.md` |

## 文档更新历史

- **2026-04-06**: 初始创建，明确 fork 演进策略定位，记录结构性分叉点和选择性吸收原则
