# Canonical prepared import publication gate（2026-08-25）

## 1. 本切片关闭的真实生产缺口

普通的 detached `asCBytecodeCodeGen::Generate()` 已经能够自行创建 import slot，
因此早期 import 单测通过并不能证明 UE 使用的分阶段编译入口可用。真实入口先由
Builder Stage2 注册 import、占用 Engine `FUNC_IMPORTED` id 并建立
`module->bindInformations`，之后才把 sealed AST 交给
`GeneratePreparedModule()`：

```text
source import declaration
  -> Parser + Sema
  -> sealed asAST_DECL_IMPORT
       stableKey + origin + namespace + source signature
  -> Builder Stage2
       authoritative asFUNC_IMPORTED shell
       authoritative Engine importedFunctions slot / FunctionId
  -> GeneratePreparedModule
       exact shell binding
       DeclId -> Runtime function relocation
       caller emits CALLBND
  -> public BindImportedFunction
  -> provider execution
```

旧实现遇到 `module->bindInformations.GetLength() != 0` 就直接返回：

```text
prepared Canonical import bindings are not implemented
```

这意味着 detached fixture 是绿的，但真正的 UE prepared-module Canonical 入口仍然
无法编译任何显式 import。本切片删除了这个入口级硬拒绝，并且没有让 CodeGen 创建
第二套 import：Stage2 shell 和 Engine slot 继续是唯一 Runtime 权威对象。

## 2. 精确身份与 publication 规则

### Builder producer identity

`asCBuilder::RegisterImportedFunction()` 在 Parser 节点仍然可用时，把 sealed producer
declaration identity 写入刚注册的 import shell。CodeGen 后续不再用名称或顺序猜测
import declaration。

### Prepared exact binding

`FindPreparedImportedFunction()` 要求以下事实全部一致，且只能命中一个 shell：

- shell 属于当前 module，类型为 `asFUNC_IMPORTED`，id 指向 exact Engine import slot；
- declaration kind 为 `asAST_DECL_IMPORT`；
- producer-carried stable declaration key 一致；
- `origin` 与 `importFromModule` 一致；
- namespace 和函数名一致；
- return type 一致；
- 每个参数的 Runtime type 与 direction 一致；
- 同一个 shell 不得绑定两个 declaration；
- sealed import 数量必须与 Runtime `bindInformations` inventory 完全相等。

成功后只增加 `DeclId -> existing shell` relocation。调用表达式已经由 Sema 把
`resolvedDecl` 精确绑定到 import DeclId，因此 emitter 直接生成该 shell id 的
`CALLBND`。失败时返回稳定诊断：

```text
prepared import must bind exactly one producer shell
```

或：

```text
prepared import shell inventory differs from the sealed graph
```

## 3. 失败事务与可重试性

永久 gate 在 Stage2 完成后故意把 import shell 的 stable key 改成
`poisoned-prepared-import-key`，再调用 `GeneratePreparedModule()`。预期并已证明：

```text
identity mismatch
  -> asINVALID_DECLARATION
  -> exact boundary diagnostic
  -> caller body bytecode remains empty
  -> import pointer/id/count unchanged
  -> no publication
```

测试随后恢复原 key，在同一个 Builder/module 上重试。第二次 CodeGen 必须成功、
保持同一个 import pointer 和 FunctionId、发出 `CALLBND`，绑定 provider 后执行得到
`42`。这个 gate 防止错误实现先部分写入函数体，再在 import publication 阶段失败，
从而让同一 candidate 无法安全放弃或重试。

完整模块失败时，Stage2 shell 的销毁仍由外层 Builder/module 编译事务负责；
Canonical CodeGen 不重复拥有或释放该 shell。

## 4. 源码签名与 Runtime ABI 是两层事实

带参数的 prepared import 回归又暴露了一个更深的兼容问题：

```text
source stable identity             Runtime Builder ABI
----------------------             -------------------
int Echo(int Value)                int Echo(const int)
Read(ValueObject Payload)          Read(const ValueObject&inout)
```

源码级 `const` 不能凭空写回 stable overload identity，但 Runtime shell 必须保持
现有 Builder/VM ABI。旧 detached Canonical `FillFunctionSignature()` 直接复制源码
类型，所以 Module import 的“provider 签名不匹配必须拒绝”回归中，provider 甚至无法
用现有公开声明 `int SharedValue(const int)` 找到。

现在 `asCRuntimeTypeBridge::NormalizeScriptParameterABI()` 是 Canonical 侧唯一共享规则：

- primitive source value -> Runtime const value，仍不是 reference；
- VALUE object source value -> Runtime `const T&inout`；
- 显式 reference 不再二次改写；
- lambda 与 generated accessor 继续使用 sealed direct ABI，避免破坏 accessor 的
  by-value ownership-transfer contract。

prepared import matcher、detached function shell producer和 Runtime structural binder
复用同一规则。

仅规范化 shell 仍不够：CodeGen 调用端必须通过 sealed formal declaration 区分：

```text
source T     -> by-value copy / non-POD ownership transfer
source T&    -> caller alias

两者的 Runtime shell 都可能表现为 reference，不能从 Runtime datatype 反推源码语义。
```

因此 call emitter 现在以 sealed source formal 决定 VALUE copy/ownership，以 Runtime
signature 决定实际栈 ABI。十二字节 POD 仍先复制到 caller-owned storage 再传地址，
而不是因为 shell 已规范化为 `const T&inout` 就错误地把原对象当作显式引用。

## 5. TDD 证据

### prepared-module feature RED

- 构建：
  `Saved/Build/cta-prepared-import-red-build2/20260825_083311_378_a9eb4f65`
- 有效 exact RED：
  `Saved/Tests/cta-prepared-import-red3/20260825_083425_199_cdec601e`
  — **0/1 PASS**，Stage2 已建立一个 import shell，随后只因
  `prepared Canonical import bindings are not implemented` 失败。

两次更早的 no-match run 省略了 CQTest class 名，不属于 RED 证据。

### transaction / parameterized prepared import GREEN

- transaction build：
  `Saved/Build/cta-prepared-import-transaction-build/20260825_084127_249_42514595`
- identity mismatch -> no mutation -> restored retry：
  `Saved/Tests/cta-prepared-import-transaction-green/20260825_084207_827_4f4ae6ab`
  — **1/1 PASS**。
- 参数化 prepared import build：
  `Saved/Build/cta-prepared-param-import-green-build/20260825_085139_971_9f8430f8`
- 参数化 exact test：
  `Saved/Tests/cta-prepared-param-import-green/20260825_085158_184_141fd074`
  — **1/1 PASS**；provider/import 为 primitive value 参数，Runtime shell 为 const，
  保持同一个 Stage2 pointer/id，`CALLBND` 执行返回 `42`。

### ABI RED/GREEN

- Module import regression RED：
  `Saved/Tests/cta-module-imports-after-prepared-import/20260825_084353_449_0f9afa20`
  — **6/7 PASS**；失败点是 Canonical provider 不再暴露 Builder-compatible
  `int SharedValue(const int)`。
- focused primitive ABI RED：
  `Saved/Tests/cta-primitive-param-abi-red/20260825_084755_795_745c5bf1`
  — **0/1 PASS**。
- GREEN build：
  `Saved/Build/cta-runtime-abi-call-semantics-build/20260825_085611_554_47eb0055`
- focused primitive ABI GREEN：
  `Saved/Tests/cta-primitive-param-abi-green/20260825_085011_838_481d2216`
  — **1/1 PASS**。

### fresh regression matrix

- complete Canonical ProductionCodeGen：
  `Saved/Tests/cta-production-codegen-runtime-abi-green/20260825_085630_666_bbe27f87`
  — **98/98 PASS**；包括 overload/funcdef lookup 与十二字节 POD by-value copy。
- Module import public contract：
  `Saved/Tests/cta-module-imports-final-prepared-import/20260825_085829_607_fa0e66b3`
  — **7/7 PASS**。
- StaticJIT Canonical declaration identity：
  `Saved/Tests/cta-staticjit-identity-after-prepared-import/20260825_085711_061_8f021eec`
  — **12/12 PASS**。

## 6. 明确没有声称完成的范围

这关闭的是 Task 9.5 的 explicit import / prepared publication 纵向切片，不是整个
Task 9.5：

- imported/indirect **non-POD by-value** 调用仍 fail closed；当前 sealed call plan 没有
  证明最终 target 是否接收 ownership，不能把 provider 未知的调用伪装成 script
  direct call；
- Cache V2 默认关闭且计划另行重构，本切片不声称 import cache replay；
- automatic import、mutable global lifecycle、exceptional cleanup、suspend/resume 和
  debug/coverage metadata 仍由各自任务验收；
- 完整 heap closure 已按产品决定延期，与 import slice 无关；
- LEGACY 继续作为显式兼容/差分 oracle，没有在本切片删除。

因此 Task 9.5 保持未勾选，严格任务数不因一个纵向 slice 虚增。
