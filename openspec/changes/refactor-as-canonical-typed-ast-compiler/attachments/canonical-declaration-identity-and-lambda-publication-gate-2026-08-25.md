# Canonical declaration identity 与 lambda publication gate（2026-08-25）

## 结论

Canonical source build 现在能够把 generated constructor factory、generated
accessor 和嵌套 lambda 的 Runtime function 精确连接到同一份 sealed AST 声明。
prepared-module 路径不再要求 Builder 预先制造 lambda shell；Canonical Bytecode
CodeGen 会在 detached candidate artifact 中建立 shell、追加 Sema-sealed capture
参数、生成函数体，并在全部生成成功后统一发布。

本轮最终回归为：

- StaticJIT CanonicalASTIdentity：**12/12 PASS**；
- Canonical ProductionCodeGen：**94/94 PASS**；
- sibling captured-lambda focused execution：**1/1 PASS**。

这关闭的是 9.5、13.3、13.6 中的一条纵向切片，而不是完整关闭 9.5。stored
closure 生命周期、exception/suspend 完整协议及其余全语言面仍需后续 gate。

## 1. generated factory 到 constructor 的声明身份

Runtime factory 是全局 wrapper ABI，但语义上对应 class constructor。旧 binder
把它当普通 object method，因 Runtime `objectType == null` 与 Canonical constructor
owner 不同而 fail-closed。

现在的精确协议是：

```text
Runtime generated factory
  invocationKind = FACTORY
  objectType      = null              (global wrapper ABI)
  artifactOwner   = exact class type
  return          = exact owner handle
  parameters      = exact constructor parameters
                 |
                 v
Canonical constructor DeclId / stableKey
```

`asCRuntimeTypeBridge::BindFunctionDeclaration` 只有在 invocation kind、owner、
namespace、return handle 和全部参数均精确匹配时才绑定 constructor DeclId。它不会
退化为首个同名构造器或仅按名称猜测。

TDD 证据：

- RED：
  `Saved/Tests/cta-synthetic-factory-bind-red2/20260825_073359_648_ac719ed7`
  报告 `owner mismatch`；
- build：
  `Saved/Build/cta-synthetic-factory-bind-green-build/20260825_073556_044_fc6bd47c`；
- GREEN：
  `Saved/Tests/cta-synthetic-factory-bind-green/20260825_073619_190_7584c73a`
  （**1/1 PASS**）。

## 2. generated accessor 的直接 Canonical ABI

authored function 的 Builder shell 会做既有 ABI normalization；generated accessor
没有 authored Builder shell，其参数签名由 sealed AST 和 Canonical CodeGen 直接
定义。若再次套用 authored normalization，primitive/value 参数会出现 `const` 或
passing-mode 偏差，non-POD setter 的 by-value ownership transfer 也会被破坏。

Runtime bridge 现在明确区分：

```text
authored Builder shell     -> compare against normalized authored ABI
generated accessor/lambda -> compare against direct sealed Canonical ABI
```

snapshot freeze 失败现在还会输出 invocation kind、Runtime owner、artifact owner
和 exact structural mismatch，避免只得到模糊的 DeclId 0。

证据：

- accessor RED：
  `Saved/Tests/cta-generated-accessor-bind-red/20260825_074101_735_8b9b2b33`；
- accessor build：
  `Saved/Build/cta-generated-accessor-bind-green-build/20260825_074150_668_59bd5c55`；
- accessor GREEN：
  `Saved/Tests/cta-generated-accessor-bind-green/20260825_074204_202_86f3a092`
  （**1/1 PASS**）；
- 真实 generation：
  `Saved/Tests/cta-generation-after-generated-accessor-bind/20260825_074240_151_af387475`
  （**1/1 PASS**，freeze `2 modules / 31 functions / 5 types / 3 globals / 10 descriptors`）；
- snapshot bind diagnostic build：
  `Saved/Build/cta-snapshot-bind-detail-build/20260825_073815_140_92f6c547`。

## 3. prepared-module lambda shell 与发布

旧 detached `GenerateInternal` 会为 lambda 建 shell，但生产 `GeneratePreparedModule`
只消费 Stage 2 已有 authored shells。lambda 嵌套在函数体内，Builder 不会为它提供
prepared shell，因此 source build 曾在 emission 前报告：

```text
sealed function has no exact prepared Runtime shell:
key=Entry()::<lambda>(int)@95
```

现在的 transaction 是：

```text
sealed lambda Decl
  stableKey = parent::<lambda>(signature)@source-offset
  captures  = Sema-owned exact capture DeclIds
                 |
                 v
detached Runtime lambda shell
  name           = $<parent-stable-key>$<source-offset>
  invocationKind = LAMBDA
  visible params = exact declared params
  hidden params  = exact captures, sealed order
                 |
                 v
Canonical body emission
                 |
                 v
atomic module publication
  engine function table + module scriptFunctions
  excluded from ordinary public global-function lookup
                 |
                 v
StaticJIT snapshot exact DeclId/stableKey binding
```

Runtime 名称恢复 `$` 前缀，是 AngelScript module/save-restore 对匿名内部函数的既有
协议；尾部数字采用 source offset。真正的 Canonical identity 始终是
`canonicalASTStableDeclKey`，不会用 Runtime rank 代替。

捕获协议也经过了执行验证：两个 sibling lambda 分别捕获同一个外层 `X=21`，
拥有两个不同 Runtime FunctionId；父函数 Bytecode 分别 CALL 两者，最终执行
`A + B == 42`。测试使用明确的 `artifactInvocationKind == LAMBDA` 识别语义角色，
不再依赖 `<lambda>` 这一临时显示名。

## 4. RED / GREEN / 回归证据

### RED

- prepared shell 缺失：
  `Saved/Tests/cta-staticjit-identity-after-declaration-bind-fixes-v2/20260825_074418_696_932f5558`
  （**11/12 PASS**，唯一失败为 multiple lambda）；
- shell 建立后 Runtime 名称不符合匿名函数协议：
  `Saved/Tests/cta-prepared-lambda-shell-green/20260825_074748_965_4991ed08`
  （snapshot 已 freeze `1 module / 4 functions`，但测试看不到 `$` lambda）；
- Runtime 命名修复后，旧捕获测试仍按 `<lambda>` 字符串筛选：
  `Saved/Tests/cta-production-codegen-after-lambda-runtime-name/20260825_075422_311_84c1236a`
  （**93/94 PASS**）。

### GREEN

- prepared lambda shell build：
  `Saved/Build/cta-prepared-lambda-shell-green-build/20260825_074729_259_b0eaa0ba`；
- Runtime name focused identity：
  `Saved/Tests/cta-canonical-lambda-runtime-name/20260825_075156_920_db4b12f0`
  （**1/1 PASS**）；
- StaticJIT CanonicalASTIdentity：
  `Saved/Tests/cta-staticjit-identity-after-lambda-runtime-name/20260825_075241_925_10d16407`
  （**12/12 PASS**）；
- role-based captured-lambda test build：
  `Saved/Build/cta-canonical-lambda-role-test/20260825_075541_005_f4d7eb58`；
- sibling captured-lambda focused execution：
  `Saved/Tests/cta-canonical-sibling-lambda-role-green/20260825_075608_444_31c85722`
  （**1/1 PASS**）；
- final Canonical ProductionCodeGen：
  `Saved/Tests/cta-production-codegen-after-lambda-role-green/20260825_075648_156_347fe7bb`
  （**94/94 PASS**）。

## 5. 对剩余任务的影响

本轮证明了以下事实：

1. Canonical AST 已能给 generated factory/accessor/lambda 提供生产级稳定声明身份；
2. prepared production build 可自行建立和原子发布 lambda Runtime shell；
3. no-capture 与 sibling captured IIFE 均不需要 legacy emitter；
4. StaticJIT snapshot 不再通过名称/rank 猜测多个 lambda；
5. generated non-POD setter 的 ownership closure 未被 lambda 改动回退。

仍未完成的主要 lambda/9.5 边界是 stored closure 的跨作用域生命周期、复杂 value
capture/handle capture、exception unwind 与 suspend/resume 组合，以及完整 SDK/script
corpus 差分。所以下一步继续扩展 AST-first 语言面，而不是重画 AST 数据结构。
