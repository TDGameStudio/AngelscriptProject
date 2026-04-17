# ReviewPrompt 中文版
#
# 用途：供人工编辑，修改后同步更新 ReviewPrompt.md（英文版为工具实际使用版本）
# 占位符 {OUTPUT_PATH} 由脚本在运行时自动替换，不要手动修改。

## 任务

严格遵循 Documents/Rules/ReviewRule_ZH.md，对当前仓库主干执行全面工程审核。
审核中心是 Plugins/Angelscript/，宿主工程 Source/AngelscriptProject/ 仅做必要观察。

## 工作方式

边审边写，逐步追加。

1. 创建输出文件 {OUTPUT_PATH}，先写入全部章节标题作为骨架。
2. 按"审计清单"逐项执行。每完成一项扫描，将发现立即追加到输出文件对应章节。
3. 发现问题就写入，不要攒。同一个章节可以反复追加。
4. 所有审计项完成后，回头填写"执行摘要"和"结论"——这两节需要全局视角，放最后写。

## 证据规则

- 所有数字必须自己扫描产生（glob/grep/find），不得照抄 AGENTS.md 或任何 Plan 文档。
- 定性判断必须读源码验证，不能只看文件名或目录结构就下结论。
- 每条 finding 至少给出一个 文件:行号 作为证据锚点。
- 如实记录：好的如实写，差的如实写，不夸大不掩饰。
- 推断必须显式标注为"推断"，并说明依据。

## 去重规则

如果某个问题已在某个 Plan 文档中被明确追踪，只需写一行"已追踪于 Plan_XXX.md"然后继续，不要展开。
把时间花在团队还不知道的问题上。

## 审计清单

逐项执行以下检查。每项完成后把结果写入文件，不要跳过。

### A. 结构与依赖

A1. 读取 AngelscriptRuntime.Build.cs、AngelscriptEditor.Build.cs、AngelscriptTest.Build.cs 三个文件，提取 PublicDependencyModuleNames 和 PrivateDependencyModuleNames，列出声明的依赖列表。

A2. 对 AngelscriptRuntime/、AngelscriptEditor/、AngelscriptTest/ 三个模块的 .cpp 文件，grep 其 #include 指令，检查是否存在：
    - 声明了依赖但从未 include 的模块（多余依赖）
    - include 了但未声明依赖的模块（缺失依赖）
    - Runtime 代码 include Editor 头文件（方向违规）
    - Test 代码 include Private/ 路径（封装违规）

A3. 检查 AngelscriptRuntime.Build.cs 中 PublicIncludePaths 是否把 ThirdParty/angelscript/source/ 暴露为公共路径，以及有多少个非 ThirdParty 文件直接 #include "source/as_*.h"。

### B. 代码质量抽样

B1. 随机选取 5 个 Bind_*.cpp 文件，逐个读取，对每个文件报告：
    - 文件行数
    - 是否有空指针 / 无效引用检查
    - 是否有硬编码的调试日志、场景名称或 TODO/FIXME/HACK 标记
    - 绑定函数的命名是否与相邻文件一致

B2. 抽查 10 个公共头文件（分布在 Core/、ClassGenerator/、Binds/、Debugging/ 等不同目录），检查：
    - 是否有 #pragma once
    - 是否有明显多余的 #include（可以用前向声明替代的）
    - ANGELSCRIPTRUNTIME_API 导出宏的使用是否一致

B3. 在核心公共头文件（AngelscriptBinds.h、AngelscriptEngine.h、AngelscriptPreprocessor.h 等）中搜索 TODO、FIXME、HACK、WILL-EDIT、TEMP 等临时标记，统计数量和分布。

### C. 第三方代码

C1. 统计 ThirdParty/angelscript/source/ 下 //[UE++] 和 //[UE--] 标记的总数、分布在多少个文件中。

C2. 对标记最密集的 3 个文件，读取标记周围的代码，判断修改性质（bug fix / 功能扩展 / 适配 UE / 其他）。

C3. 检查是否存在没有 //[UE++] 标记但明显被修改过的代码段（例如注释掉的原始代码、新增的 #if 分支等）。

### D. 测试覆盖

D1. 统计 AngelscriptTest/ 下按子目录（Actor/、Bindings/、Blueprint/、Component/、Core/、Debugger/、Delegate/、Dump/、GC/、HotReload/、Interface/、Internals/、Preprocessor/、Subsystem/ 等）分组的 .cpp 文件数和测试宏定义数（IMPLEMENT_*_AUTOMATION_TEST、BEGIN_DEFINE_SPEC 等）。

D2. 对照 AngelscriptRuntime/ 的功能子目录（Core/、ClassGenerator/、Binds/、Debugging/、StaticJIT/、CodeCoverage/、Dump/、FunctionLibraries/、Preprocessor/、BaseClasses/），标记哪些子目录有专门的测试文件对准它，哪些没有。

D3. 统计 AngelscriptRuntime/Tests/ 目录（如果存在）下的测试文件数量和内容，它们与 AngelscriptTest/ 模块的测试是什么关系。

### E. 脚本示例

E1. 列出 Script/ 目录下所有 .as 文件，统计总数。

E2. 逐个读取每个 .as 文件，评估：文件长度、是否有注释说明用途、是否能独立运行/学习、覆盖了哪些 API 或概念。

### F. 文档与代码同步

F1. 从 AGENTS.md 中挑选 5 条具体的事实性声明（如模块数量、文件数量、能力描述），独立对照源码验证，记录匹配或不匹配。

F2. 从 Plan_StatusPriorityRoadmap.md 中挑选 3 条关于"已完成"或"已落地"的声明，独立验证其对应代码是否真的存在于主干。

F3. 检查 README.md 的内容是否为空或仅有占位符。检查 Angelscript.uplugin 中 DocsURL、SupportURL、MarketplaceURL 字段是否有实际值。

## 输出文档结构

输出文件 {OUTPUT_PATH} 包含以下 8 个章节，不跳过不合并。

### 第 1 章 审核范围
列出本次审核实际扫描的模块、目录和关键文件。

### 第 2 章 执行摘要
审计维度汇总表（维度 | 发现数 | 风险最高等级），加 3-5 条核心结论。此章最后写入。

### 第 3 章 当前主干进度
对运行时核心能力、编辑器集成、测试体系、对外交付入口分别标注 [已落地] / [部分落地] / [仅计划]，每条附证据锚点。

### 第 4 章 关键问题
审计过程中发现的所有问题，逐条追加，不设上限。每条遵循以下格式：

> **问题 N：[标题]**
>
> | 项目 | 内容 |
> |------|------|
> | 问题描述 | [具体是什么问题] |
> | 影响范围 | [模块/文件] |
> | 证据 | [文件:行号] |
> | 风险等级 | 高 / 中 / 低 |
> | 推荐动作 | [具体可执行的动作] |

### 第 5 章 风险与阻塞

| 阻塞项 | 影响 | 当前状态 | 解除路径 |
|--------|------|----------|----------|

### 第 6 章 文档与测试缺口
两张子表：

文档缺口：

| 缺口项 | 当前状态 | 目标状态 | 承接计划 |
|--------|----------|----------|----------|

测试缺口：

| 缺口项 | 当前状态 | 目标状态 | 承接计划 |
|--------|----------|----------|----------|

### 第 7 章 建议的下一步动作
分三个优先级：P0（立即）、P1（短期）、P2（中期）。
每条动作必须具体到"改哪个文件/做什么检查/产出什么"。

### 第 8 章 结论
3-5 条客观总结。此章最后写入。

## 禁止事项

- 不要写泛泛的项目介绍或历史回顾。
- 不要用空泛表扬填充篇幅。
- 不要把"Plan 里写了"当成"主干已完成"。
- 不要照搬 AGENTS.md 或 Plan 文档中的数字，必须自己统计。
- 不要一次性在最后才输出整份文档。
- 不要生成 TodoList。
