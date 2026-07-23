# AngelScript 代码生成器：调研结论与设计建议

> 状态：调研 / 设计记录，尚未实现。
> 目标：为 AngelScript，包括本项目的 Unreal Engine 集成，生成测试脚本，覆盖解析、类型检查、编译、字节码、VM、GC 与宿主绑定边界。
> 核心建议：以 Fuzzilli 架构为主参考；以 AngelScript 官方测试为语料与回归样板；以 Grammarinator 补 parser fuzz；以 C-Reduce 的 reducer 思路缩减失败样本。

---

## 1. 问题定义

这里讨论的不是给业务函数自动写普通单测，而是生成 AngelScript 程序来测试语言实现与嵌入层：

~~~
生成 AngelScript 源码
        ↓
预处理 / 解析 / 类型检查 / 编译
        ↓
字节码、VM、GC、宿主调用、UE 类型与绑定
        ↓
发现崩溃、断言、错误诊断、行为不一致或覆盖率盲区
~~~

输入必须分为两个独立生成器：

| 生成器 | 样本性质 | 主要判定方式 |
|---|---|---|
| 正例生成器 | 应当通过编译，尽量也应可执行 | Build 成功、运行结束、trace 或 checksum 稳定、无 sanitizer 报告 |
| 负例生成器 | 有意违反一条局部规则 | 产生预期诊断，且不崩溃、不 hang |

不要把两类样本混在一个随机生成器中。否则编译失败时无法判断是引擎问题、宿主注册问题，还是生成器本身产出了无效程序。

---

## 2. 最终选型

如果只能参考一个项目，选择 **[Fuzzilli](https://github.com/googleprojectzero/fuzzilli)**。

它的价值不在 JavaScript，而在于它避免直接随机拼源码文本。Fuzzilli 先构造自定义中间表示 FuzzIL，在构造阶段维持变量、控制流和数据流约束，再将程序输出为 JavaScript。其主要组件包括 ProgramBuilder、Environment、Corpus、MutationFuzzer、Minimizer 和 Lifter。[Fuzzilli README](https://github.com/googleprojectzero/fuzzilli)

推荐闭环：

~~~
AngelScript 官方测试 / 历史复现 / 项目脚本
                    │
                    ▼
               Seed corpus
                    │
    ┌───────────────┼────────────────┐
    │               │                │
    ▼               ▼                ▼
ASIR Builder   Grammar fuzzer   Corpus mutation
  主路径        parser 辅助     与程序拼接
    │               │                │
    └───────────────┴───────┬────────┘
                            ▼
                     AngelScript 源码
                            │
                            ▼
      编译 / 执行 / 覆盖率 / sanitizer / oracle
                            │
                            ▼
        reducer 缩小失败样本，并沉淀固定回归测试
~~~

---

## 3. Fuzzilli 上游路径

当前项目中没有 Fuzzilli 本地 checkout。若以后要固定一个参考副本，建议放在：

~~~
Reference/fuzzilli/
~~~

仅为了当前设计文档不需要克隆。

| 资源 | 路径 / 链接 | 用途 |
|---|---|---|
| 仓库根 | [googleprojectzero/fuzzilli](https://github.com/googleprojectzero/fuzzilli) | README、总体结构、运行方式 |
| 核心实现 | [Sources/Fuzzilli](https://github.com/googleprojectzero/fuzzilli/tree/main/Sources/Fuzzilli) | fuzzer 主架构 |
| 自定义 IR | [Sources/Fuzzilli/FuzzIL](https://github.com/googleprojectzero/fuzzilli/tree/main/Sources/Fuzzilli/FuzzIL) | 指令表示、程序构建约束 |
| 目标适配 | [Targets](https://github.com/googleprojectzero/fuzzilli/tree/main/Targets) | 各 JS 引擎 profile 与 patch |
| 项目测试 | [Tests/FuzzilliTests](https://github.com/googleprojectzero/fuzzilli/tree/main/Tests/FuzzilliTests) | 组件测试方式 |

应借鉴：

- 使用内部 IR，而不是文本，作为生成与变异的基本单位；
- ProgramBuilder 维护 scope、可用变量、类型和控制流位置；
- Environment 明确描述目标运行时可用的类型、函数、方法和属性；
- Corpus 仅保留新增覆盖、失败或其他有价值的样本；
- 在有效样本上做小变异、拼接和重组；
- 将打印职责隔离到 Lifter 或 pretty-printer；
- 以 Minimizer 将失败输入缩成可读复现。

不应照抄 FuzzIL 的具体指令集、JavaScript 的动态类型策略或其 REPRL 引擎 patch 方式。AngelScript 需要自己的强类型 IR 和 runner。

---

## 4. LLVM / Clang 的测试模式

LLVM/Clang 的主力不是“生成海量测试并全部提交”，而是一个闭环：

1. 小而精确、可读的固定回归测试；
2. 持续运行 fuzz 和随机程序生成；
3. 对失败样本自动最小化；
4. 将最小复现提交回固定回归测试。

Clang 官方将功能测试分为 unit test、diagnostic test、AST dump test 和 LLVM IR test。诊断测试在源码内标出预期错误，AST/IR 测试匹配关键输出。[Clang CFE Internals Manual — Testing](https://clang.llvm.org/docs/InternalsManual.html#testing) [LLVM Testing Guide](https://llvm.org/docs/TestingGuide.html)

LLVM 同时具有两种互补 fuzzer：

| 工具 | 输入特点 | 主要覆盖区域 |
|---|---|---|
| clang-fuzzer | 不努力保证有效 C++ 的字节级变异 | lexer、parser、错误恢复、崩溃 |
| clang-proto-fuzzer | 用 protobuf 描述 C++ 子集，生成结构有效程序 | 语义分析、优化与更深编译管线 |

官方明确说明结构化 fuzzer 只针对 C++ 子集，以生成有效程序并进入 parser error handling 之后的路径。[LLVM Fuzzing Guide](https://llvm.org/docs/FuzzingLLVM.html) [Clang fuzzer source](https://github.com/llvm/llvm-project/tree/main/clang/tools/clang-fuzzer)

对 AngelScript 的启示：先用固定 case 做回归，再为受控语言子集做生成器，最后将新失败经 reducer 固化。

---

## 5. 其他参考工具的定位

| 工具 | 最适合的用途 | 对 AngelScript 的作用 |
|---|---|---|
| [Grammarinator](https://github.com/renatahodovan/grammarinator) | ANTLR v4 grammar、grammar-aware generation 和 mutation | parser、lexer、错误恢复、深层嵌套的辅助 fuzz |
| [Csmith](https://github.com/csmith-project/csmith) | 无未定义行为的随机 C 和差分测试 | 借鉴受控正例与行为 oracle |
| [YARPGen](https://github.com/intel/yarpgen) | 正确可运行的 C/C++ 程序与优化器测试 | 借鉴可执行程序和 checksum |
| [C-Reduce](https://github.com/csmith-project/creduce) | 保持失败性质的 test-case reduction | 借鉴 AngelScript reducer 工作流 |
| [AngelScript 官方仓库](https://github.com/anjo76/angelscript) | 官方实现、测试和历史修复 | 初始 corpus、feature matrix 与回归样板 |

Grammarinator 可从 ANTLR grammar 创建生成器，并支持生成、变异、重组和与 libFuzzer 或 AFL++ 集成。[Grammarinator 文档](https://grammarinator.readthedocs.io/en/latest/introduction.html) 但 grammar 不知道名字是否存在、类型是否相容、out 参数是否是可写 lvalue、重载是否唯一匹配、宿主 API 是否注册。因此它只能做辅助 parser fuzzer，不是正例主生成器。

Csmith 和 YARPGen 同样不是首选架构：AngelScript 没有可直接作普通双实现差分的同类编译器，且脚本可用 API 由宿主注册决定。不过二者仍然强调了两个重要原则：生成器要规避自身噪声，且可执行程序必须提供稳定行为 oracle。[Csmith README](https://github.com/csmith-project/csmith) [YARPGen README](https://github.com/intel/yarpgen)

---

## 6. AngelScript 为什么必须有 Environment

AngelScript 的脚本世界并不固定。应用可以注册全局函数、全局属性、对象类型、接口、函数定义、枚举和 typedef；string 没有统一内建实现，默认 array 也需要由嵌入方配置。[AngelScript Registration API](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_register_api.html)

因此“语法正确”不等于“在当前引擎可编译”。例如：

~~~angelscript
Actor@ a = CreateActor();
~~~

此语句可能因任意原因失败：Actor 未注册、CreateActor 不存在或签名不同、返回值不是 handle、handle 可为 null，或者当前 profile 禁止会改变世界状态的 API。

主生成器需要 machine-readable Environment。MVP 可以先人工维护受控 profile：

~~~json
{
  "types": [
    { "name": "int", "kind": "primitive" },
    { "name": "bool", "kind": "primitive" },
    { "name": "string", "kind": "value" },
    { "name": "array<T>", "kind": "template" },
    { "name": "Actor", "kind": "reference", "allows_handle": true }
  ],
  "functions": [
    { "name": "Record", "return": "void", "params": ["int"] },
    { "name": "CreateActor", "return": "Actor@", "params": [] }
  ]
}
~~~

长期可由测试引擎的注册 wrapper、binding dump 或 state dump 输出这个 profile。Environment 应成为“生成器允许使用哪些 API”的唯一真相。

---

## 7. 推荐架构：ASIR + ProgramBuilder

~~~
Environment
  类型、注册 API、方法签名、模板、属性、feature 开关、host 约束
       │
       ▼
ASIR ProgramBuilder
  scope、可用变量、类型、初始化状态、控制流上下文
       │
       ├──── Statement Generator
       ├──── Expression Generator
       └──── Corpus Mutator
                       │
                       ▼
                ASIR Program / Module
                       │
                       ▼
        Lifter / Pretty-printer 输出 AngelScript 源码
                       │
                       ▼
          Compiler + VM + Oracle Harness
                       │
                       ▼
       Coverage corpus / Reducer / Regression case
~~~

ASIR 的最小节点集：

~~~
Program
  ├─ Module / Namespace
  ├─ GlobalVariable
  ├─ Function
  ├─ Class / Interface
  ├─ Statement：declaration、block、if、switch、loop、return、expression
  └─ Expression：literal、variable、call、assignment、operator、
                 constructor、member/index access、cast、handle、null
~~~

表达式不能只是可打印文本，应至少携带：

~~~
Expr {
  type: Type,
  category: value | lvalue | handle,
  nullable: true | false,
  pure: true | false,
  may_throw: true | false
}
~~~

这些属性让 builder 在构造时保证：

- 变量先定义后使用；
- return 与函数签名匹配；
- break 和 continue 只生成在合法控制流；
- out 参数使用可写 lvalue；
- inout 参数使用已初始化、类型相容的变量；
- T、T@、const T@ 不被混用；
- nullable handle 的成员访问经过判空或已知非空路径；
- 重载调用只从确定可匹配的候选中选择；
- class/interface、成员可见性和继承关系符合当前 feature 子集。

---

## 8. Feature 扩展顺序

| 阶段 | 生成特性 | 目标 |
|---|---|---|
| 0 | int、uint、bool、函数、局部变量、算术、if、循环、return | 最小可执行正例闭环 |
| 1 | float、double、显式转换、string、array | 表达式和容器路径 |
| 2 | 默认参数、重载、in/out/inout 参数 | 调用匹配和引用语义 |
| 3 | script class、interface、继承、property accessor | 类型系统和脚本对象 |
| 4 | T@、null、weakref、GC | handle 与生命周期 |
| 5 | funcdef、delegate、匿名函数、异常、协程 | 高级执行路径 |
| 6 | namespace、多 module、多 section、shared、预处理器 | 编译与工程边界 |
| 7 | UE binding profile、热重载、bytecode round-trip | 本项目 fork 与宿主路径 |

每增加一个 feature，都要同时增加固定正例与负例、Environment 签名、ASIR 约束、oracle 和 reducer 的安全规则。

AngelScript 当前维护记录中的 namespace、foreach、初始化列表、继承、三元表达式、模板函数、重载、inout、handle conversion 与 bytecode 加载问题，正好是高优先级 feature matrix。[AngelScript WIP / Change Log](https://www.angelcode.com/angelscript/wip.php)

---

## 9. Oracle：怎样判定生成的程序

AngelScript 没有可直接替代 GCC/Clang 的第二成熟实现，因此不能只依赖双编译器差分。建议组合以下 oracle：

| Oracle | 检查内容 |
|---|---|
| 编译成功 | valid 样本 Build 成功，诊断为空或符合约定 |
| 不崩溃 / 不 hang | 编译、执行、GC、序列化路径不触发 crash、assert、超时 |
| ASan / UBSan | 检查引擎 C++ 实现中的内存错误和 UB |
| trace / checksum | 将脚本执行行为压缩成稳定、可比较结果 |
| bytecode round-trip | 源码执行与编译、保存、加载、再执行的结果一致 |
| 变形测试 | 语义等价且受约束的变体输出一致 |
| 精确诊断 | invalid 样本的错误类别、位置与关键文本稳定 |
| coverage feedback | 只保留新增 compiler 或 VM 覆盖的样本 |

建议提供确定性的最小测试 host：

~~~
void Record(int value)
int DeterministicInput(int index)
int main()
~~~

runner 流程：Build module → 执行 main → 收集 Record trace、返回值和异常状态 → 计算 checksum → 可选地保存、重新加载 bytecode 后重复执行。

可在受限条件下做变形测试：

~~~
int x = E;        ↔  int x; x = E;
return E;         ↔  T temp = E; return temp;
if (C) A; else B; ↔  bool c = C; if (c) A; else B;
x = x + y;        ↔  x += y;
a is null         ↔  !(a !is null);
~~~

不要把这些变形用于浮点精度边界、带副作用调用、异常路径、用户自定义 operator 或会改变临时对象生命周期的表达式。

---

## 10. Reducer 与固定回归

failure predicate 由 runner 提供，例如：

~~~
failure(input) ==
    编译器崩溃
 || VM 崩溃
 || sanitizer 报告
 || 超时
 || bytecode round-trip 行为不一致
 || 变形对 checksum 不一致
 || 诊断与期望不符
~~~

初版 AngelScript reducer 可采用贪婪 pass，每一步后都重跑 predicate：

1. 删除无关 global、class、interface、function；
2. 删除函数体中的 statement 或 block；
3. 以 expression 的子表达式替换它；
4. 将常量缩为 0、1、-1、false、true、空字符串或 null；
5. 移除可选参数、修饰符和泛型嵌套；
6. 尝试以内联值替换局部变量。

最小失败样本不能只放入 corpus，也应转成固定 Automation 或 SDK 回归测试。这样形成 LLVM 风格的 fuzz → reduce → regression 闭环。

---

## 11. 与当前项目的集成路径

生成器应先作为**测试侧工具**存在，不要在 MVP 阶段侵入 production runtime：

~~~
第一阶段：Native SDK harness
  Plugins/Angelscript/Source/AngelscriptTest/AngelScriptSDK/
  - 直接测试 asIScriptEngine / asIScriptModule
  - 覆盖 compiler、bytecode、VM、GC 的裸行为

第二阶段：Runtime harness
  Plugins/Angelscript/Source/AngelscriptTest/Compiler/
  Plugins/Angelscript/Source/AngelscriptTest/Syntax/
  - 复用既有 test engine helper
  - 覆盖 fork 特性和预处理器

第三阶段：受控 UE binding profile
  Plugins/Angelscript/Source/AngelscriptTest/Bindings/
  Plugins/Angelscript/Source/AngelscriptTest/Functional/
  - 只暴露可重复、可清理的绑定子集
  - 不让随机脚本直接污染游戏世界
~~~

建议的逻辑组件：

| 组件 | 职责 |
|---|---|
| FAngelscriptGeneratorEnvironment | 描述类型、函数、方法、属性和 feature profile |
| FAngelscriptProgramBuilder | 生成有类型 ASIR，维护 scope、variable、control-flow 状态 |
| FAngelscriptProgramLifter | 输出稳定、可读的 .as 文本 |
| FAngelscriptGeneratedProgramRunner | Build、执行 main、收集 trace/checksum、处理超时和诊断 |
| FAngelscriptProgramReducer | 按 failure predicate 缩减 ASIR 或源文本 |
| FAngelscriptCorpusStore | 保存 seed、覆盖增量样本和最小失败样本 |

---

## 12. 可执行 MVP

第一版应刻意保持小而可验证：

~~~
语言子集：
  int / uint / bool
  函数、局部变量、return
  算术、比较、赋值
  if / for / while

测试 host：
  void Record(int value)
  int main()

成功标准：
  - 每个 valid 样本都能编译；
  - main 在固定预算内结束；
  - Record trace/checksum 确定；
  - 无 crash、assert 或 sanitizer 报告；
  - 失败样本可被缩小，并回灌为固定回归。
~~~

演进顺序：

~~~
MVP  整数/布尔、函数、局部变量、控制流、checksum
v1   string、array<int>、索引、简单 foreach
v2   默认参数、重载、in/out/inout
v3   class、interface、继承、T@、null
v4   bytecode save/load、GC、module/section、预处理器
v5   真实受控 UE binding profile、fork 扩展、热重载路径
~~~

---

## 13. 不建议做的事

- 不要仅从 BNF/ANTLR grammar 随机展开完整 AngelScript，并期待大部分样本通过类型检查。
- 不要把 valid 与 invalid 输入混在一个生成器中。
- 不要用正在被测试的 parser 生成 expected AST，避免自证循环。
- 不要一开始扫描并调用全部 UE 绑定；副作用会破坏可重复性和 reducer 效率。
- 不要将大型 fuzz 样本直接提交为永久回归；必须先最小化。
- 不要把生成数量当成测试质量；稳定 oracle、新覆盖和最小复现才有价值。
- 不要把 Grammarinator 当作类型正确的主生成器。
- 不要把 Csmith/YARPGen 的完整实现模式硬搬到 AngelScript；只借其受控正例和行为 oracle 的思想。

---

## 14. 参考链接

### AngelScript

- [AngelScript 官方仓库](https://github.com/anjo76/angelscript)
- [AngelScript Script Language](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_script.html)
- [AngelScript Registration API](https://www.angelcode.com/angelscript/sdk/docs/manual/doc_register_api.html)
- [AngelScript WIP / Change Log](https://www.angelcode.com/angelscript/wip.php)

### LLVM / Clang

- [Clang CFE Internals Manual — Testing](https://clang.llvm.org/docs/InternalsManual.html#testing)
- [LLVM Testing Guide](https://llvm.org/docs/TestingGuide.html)
- [LLVM Fuzzing Guide](https://llvm.org/docs/FuzzingLLVM.html)
- [Clang fuzzer source](https://github.com/llvm/llvm-project/tree/main/clang/tools/clang-fuzzer)

### 生成、变异与最小化

- [Fuzzilli](https://github.com/googleprojectzero/fuzzilli)
- [Grammarinator](https://github.com/renatahodovan/grammarinator)
- [Csmith](https://github.com/csmith-project/csmith)
- [YARPGen](https://github.com/intel/yarpgen)
- [C-Reduce](https://github.com/csmith-project/creduce)

---

## 一句话建议

> AngelScript 代码生成器的核心不应是一份“随机输出源文本的 grammar”，而应是一个维护 **类型、作用域、handle、引用参数与宿主注册 API** 状态的 ASIR ProgramBuilder：架构学 Fuzzilli，语料与回归学 AngelScript 官方测试，parser fuzz 用 Grammarinator，失败最小化走 C-Reduce 式闭环。
