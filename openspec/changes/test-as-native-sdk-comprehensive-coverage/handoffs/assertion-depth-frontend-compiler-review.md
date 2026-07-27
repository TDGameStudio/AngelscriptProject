# Frontend 与 Compiler 逐产品断言深度审计

## 结论

本轮从 `catalogs/coverage-products.psd1` 精确枚举 Owner 位于
`Frontend/` 和 `Compiler/` 的全部 70 个产品，并打开每个产品指定的
`文件 | 测试类 | TEST_METHOD`，逐项核对 `Expected` 与声明的 Evidence。

| Theme | 产品数 | Complete | ChangeRequired | Deferred |
| --- | ---: | ---: | ---: | ---: |
| Frontend | 40 | 10 | 30 | 0 |
| Compiler | 30 | 13 | 17 | 0 |
| 合计 | 70 | 23 | 47 | 0 |

逐产品结果、精确 Owner、源码范围、实际观察到的 Evidence、缺失 oracle
和最小充分后续动作记录在
`assertion-depth-frontend-compiler-review.csv`。

## 审计口径

本轮严格复用
`assertion-depth-engine-typesystem-embedding-review.{csv,md}` 的字段与判定：

- `Compile` 必须检查完整构建/编译结果或精确发布结果；直接 tokenizer、
  parser predicate、字符串或内部 helper 调用不能自动算 Compile。
- `Diagnostic` 必须检查拒绝边界或拥有诊断；仅 `Messages.Num() > 0`
  不能证明 owning section、stage、row 或 symbol。
- `Metadata` 必须比较精确 token/node/opcode/type/function/section、ID、声明、
  所有者、标志、索引、跨度或回调元数据。
- `Runtime` 必须执行目标行为或内部运行路径并比较返回值、写回值、副作用
  或分类结果；compile-only 不能替代 Runtime。
- `Debug` 必须检查 section、line、locals、调用栈或调试 API 结果。
- `Bytecode` 必须检查发布、opcode、序列化内容、长度或跳转边界。
- `Lifecycle` 必须观察构造、Reset、状态转换、引用计数或销毁回调。
- `Cleanup` 必须观察释放后的计数、空状态、模块消失或引用基线；RAII、
  `FScopedNativeModuleName`、`ON_SCOPE_EXIT`、`Destroy/Release` 本身不算。
- `Isolation` 必须有第二 owner/control、跨 cell 不污染或恢复基线断言；
  case-owned engine/fixture 本身不算。
- `SaveLoad` 必须验证保存和加载两端以及加载后身份或行为。
- `Recovery` 必须在失败后执行修正后的同名/同状态操作并验证恢复结果。

## 缺失 oracle 汇总

| 缺失 Evidence | 产品数 | 主要表现 |
| --- | ---: | --- |
| Cleanup | 28 | 只有 scope guard/RAII，或没有释放后的空状态、模块消失、引用/存储基线。 |
| Isolation | 18 | 只有案例局部 fixture，缺少第二 owner/control 或跨 cell 无污染断言。 |
| Compile | 14 | Tokenizer/internal helper 直接分类被标成 Compile，但没有 Module::Build 或完整发布。 |
| Diagnostic | 2 | 失败路径只检查消息存在，未检查 owning section/stage/row/symbol。 |

同一产品可同时缺少多类 oracle，因此本表不能相加为产品数。

## Frontend 重点结论

### Tokenizer 的 Compile 声明过宽

11 个深度 tokenizer 产品、`FRONTEND-TOKENIZER-INTERNAL-HELPERS`、
`FRONTEND-PARSER-INTERNAL-PREDICATES` 和
`FRONTEND-TOKEN-LONG-IDENTIFIER-BOUNDARIES` 都有精确 token/predicate
oracle，但没有执行完整编译或发布。要么增加代表性完整 compile/publication
oracle，要么从产品 Evidence 删除 `Compile`。

### Parser/Node 的 Cleanup 不能由作用域所有权代替

多数 parser/node 产品已经检查 AST kind/count/link/range、Reset recovery
或 copy fingerprint，但 scoped module 和 engine guard 只安排释放，没有证明
释放后的模块消失、树状态或引用基线。深拷贝所有权产品会在原 scope 释放后
继续检查 copy，因此可以保留 Cleanup。

### String 所有权的释放后证据

核心字符串操作通过显式 `Clear` 观察空状态；深拷贝/alias 产品证明 mutation
independence，但没有在 ownership graph 离开作用域后检查外部 buffer、控制副本
或引用基线，因此仍为 ChangeRequired。

## Compiler 重点结论

### Builder failure 的 diagnostic 不够精确

`COMPILER-BUILDER-SHAPE-FAILURE` 和
`COMPILER-BUILDER-REBUILD-RECOVERY` 对阶段、发布边界和恢复运行已有强断言，
但失败分支只检查消息列表非空。产品要求 owning diagnostic，必须增加 section、
stage/row 和 symbol/message fragment oracle。

### 显式 module absence 是 Cleanup，scope guard 不是

Dependency、cross-section、call/control、CompileFunction 与 warning 产品中，
执行 `DiscardModule` 并检查
`GetModule(..., asGM_ONLY_IF_EXISTS) == nullptr` 的路径可以保留 Cleanup。
Cartesian shape、optimization、direct builder application、declaration、
const-global、layout 和 parse-stage 仍缺释放后状态。

### Isolation 必须有控制面

Direct builder application、warning、CompileFunction、declaration、const-global、
layout 和 parse-stage 的主行为断言大多充分，但独立 engine/module 本身不是
Isolation。应加入第二 module/engine 或前后 registry/property baseline。

### 已有强内部生命周期证据

`COMPILER-INTERNAL-COMPILER-LIFECYCLE` 通过 tracking string factory 验证
compiler-owned scope 析构后 acquire/release 恰好平衡；
`COMPILER-INTERNAL-TEMPLATE-COVARIANCE` 对两个内部分类器执行 8 个关系、
16 个结果 oracle。两项均不是 compile-only，可保持 Complete。

## Deferred 判定

本轮没有产品标记为 Deferred。源码中记录的 class-value construction 等 fork
限制已被相关 Expected 明确排除，没有把未执行行为伪装成当前成功；也没有发现
需要用 Deferred 掩盖本应补断言的产品。

## 验证边界

本轮只做源码与 catalog 的只读审计，并新增本摘要和逐产品 CSV：

- 没有修改测试代码、catalog、tasks 或 progress。
- 没有运行生成/catalog/audit 脚本。
- 没有执行构建或自动化测试。
- CSV 产品集合必须与 catalog 的 Frontend + Compiler Owner 一一对应。
- ProductId 必须唯一，Owner、Theme、EvidenceDeclared 必须与 catalog 一致。
