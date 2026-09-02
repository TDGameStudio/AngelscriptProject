# Canonical AST → Bytecode → StaticJIT 生产链问题台账（2026-08-25）

## 1. 记录目的

本文记录 `refactor-as-canonical-typed-ast-compiler` 在真实 StaticJIT 生产链闭环中暴露的问题。记录范围不仅包含最终修复，也明确区分：

- 产品语义缺陷；
- 调试/测试基础设施问题；
- 无效 RED（测试没有真正命中预期语义）；
- 已验证修复；
- 尚在调查的后续阻塞点。

后续遇到的相关问题继续追加到本文，至少记录“现象、根因、为什么既有闸门没有发现、RED/GREEN 证据、影响范围、剩余风险”。不能只在会话中描述，也不能把测试选择器错误或无效 fixture 当成产品缺陷。

## 2. 当前生产链与问题推进关系

```text
Canonical typed AST
        |
        v
Stage 2 prepared-body publication
        |
        +-- [已修复] 生成 factory 替换函数数据后丢失源码元数据
        |
        v
Canonical bytecode generation
        |
        +-- [已修复] 普通成员访问未发布精确 property-layout 依赖
        +-- [已修复] int& 二元运算按引用/指针宽度选择 MULi64
        +-- [已修复] 返回 self handle 的返回槽没有 pointer frame 元数据
        +-- [已修复] 非 null handle ==/!= 发成 CMPi
        |
        v
StaticJIT fact capture / provider selection
        |
        +-- Candidates=7, Captured=7, Skipped=0
        |
        v
BytecodeJIT lowering
        |
        v
Native artifact generation and execution
```

这条推进顺序很重要：后一个错误之前可能一直被前一个错误遮蔽。真实 StaticJIT 测试每越过一个阻塞点，才会触达更深一层，因此单看局部 AST/Bytecode 单测全绿不能证明整条生产链闭环。

## 3. 已确认并修复的问题

### 3.1 Prepared generated factory 丢失 constructor 源码元数据

**现象**

Stage 2 为生成的 default factory 发布 prepared body 时，会事务性替换 `ScriptFunctionData`。替换后的 synthetic factory shell 没有重新携带 constructor declaration 的 source metadata。真实 StaticJIT 事实抓取因此出现 factory source authority 缺口。

**根因**

源码元数据原本存在于准备阶段的 constructor declaration，但 `GeneratePreparedModule()` 替换函数数据后，factory emission 没有调用统一的 `FillFunctionSourceMetadata(...)`。这不是 Parser 缺信息，而是 producer 在发布新函数数据时丢失已有权威事实。

**为什么既有闸门漏检**

既有测试验证了 factory 可以生成和执行，却没有在 body swap 之后检查最终 `asCScriptFunction` 的 section/row/column/source authority。也就是说，测试覆盖了“有函数”，没有覆盖“函数仍可追溯到 canonical source”。

**修复**

factory emission 使用 constructor declaration 调用 `FillFunctionSourceMetadata(...)`；无法建立来源时 fail closed，而不是发布 source-less synthetic function。

**证据**

- RED：`Saved/Tests/cta-prepared-factory-source-red/20260825_144126_058_d2c00331`
- Build GREEN：`Saved/Build/cta-prepared-factory-source-green/20260825_144223_049_f642d48d`
- 精确测试 GREEN：`Saved/Tests/cta-prepared-factory-source-green/20260825_144236_722_b08d49e7`
- 真实 StaticJIT 推进证据：`Saved/Tests/cta-staticjit-factory-source-green/20260825_144316_129_25143326`
  - `NullSectionWarnings=0`
  - `SourceAuthorityDiagnostics=0`

**新增闸门**

`PreparedGeneratedDefaultFactoryPublishesConstructorSourceMetadataAfterBodySwap`

### 3.2 Generic member property 没有进入 artifact dependency envelope

**现象**

真实 StaticJIT 对 `ObjectLastNativeForAOT` 生成 artifact 时，发现 bytecode 实际使用了 property relocation/layout symbol，但 artifact 声明的依赖中缺少对应 `EnvironmentAbi/EnvironmentSymbol`。

**根因**

generic member address/load/store 三条路径直接读取 sealed field 的 `byteOffset` 并发出 `ADDSi`，没有经过 `PropertyFromFieldDecl(...)`。结果是：

- 执行 bytecode 知道偏移；
- dependency collector 不知道这是哪个 runtime property；
- artifact 无法证明其布局依赖完整。

这是典型的“双真相”问题：数值偏移足够让局部 bytecode 工作，却不足以形成可验证、可失效的生产 artifact。

**为什么既有闸门漏检**

既有 member codegen 测试主要检查偏移和执行结果；已有 sealed-field regression 也只覆盖“不是第一个 property 时仍选对字段”。它们没有检查 property identity 是否进入 artifact 的精确依赖集合。

**修复**

以下 generic 路径统一先通过 `PropertyFromFieldDecl(...)` 解析权威 `asCObjectProperty`，再使用其 `byteOffset`：

- `EmitLValueAddress` 的 member 分支；
- `EmitMember`；
- `EmitMemberStore`。

解析失败时 fail closed，避免继续发出没有精确 property identity 的 bytecode。

**证据**

- RED：`Saved/Tests/cta-native-member-property-dependency-red/20260825_144724_507_cfd55938`
- 首次构建暴露变量遮蔽（已修正）：`Saved/Build/cta-native-member-property-dependency-green/20260825_145046_140_acc4e38e`
- Build GREEN：`Saved/Build/cta-native-member-property-dependency-green-r2/20260825_145115_409_684a158b`
- 精确测试 GREEN：`Saved/Tests/cta-native-member-property-dependency-green-r2/20260825_145240_254_cf1ae348`
- 既有 sealed-field regression GREEN：`Saved/Tests/cta-native-member-sealed-field-regression/20260825_145317_822_f8a63896`
- 真实事实抓取推进到：`Candidates=7 Captured=7 Skipped=0`

**新增闸门**

`CanonicalNativeMemberRefPublishesExactPropertyLayoutDependency`

**非产品问题说明**

`Saved/Tests/cta-native-member-property-dependency-green/20260825_145141_024_707ee13e` 使用了缺少 CQTest class segment 的错误过滤器。该次结果是测试选择器错误，不是语义 RED/GREEN 证据。

### 3.3 `int&` 二元运算错误选择 64 位 opcode

**现象**

真实 StaticJIT 在处理 reference scalar 运算时，`asBC_MULi64` 的目标槽被识别为 DWord，BytecodeJIT 在宽度契约检查处失败。

**根因**

canonical AST 的 `TypeOf(lhs)` 对 `int&` 正确保留了引用限定，但 `EmitBinary` 直接用这个带引用的类型选择整数 opcode 和临时槽元数据。引用在 AST 类型层表达 alias/lvalue 语义，算术运算的值宽度应取 pointee `int`，不能把引用表示宽度当成算术值宽度。

**为什么既有闸门漏检**

普通 `int` 算术和引用读写分别有覆盖，但没有一个精确 fixture 强制 `int&` 与运行时变量走 generic binary opcode。最初用常量 `Value * 2` 的 fixture 实际生成专用 `MULIi`，因此没有命中缺陷。

**修复**

`EmitBinary` 在 opcode 宽度选择和临时元数据发布之前，对“非 handle reference”执行 `MakeReference(false)`，保留 pointee value type。

**证据**

- 有效 RED build：`Saved/Build/cta-reference-scalar-width-red-r2/20260825_150339_310_89278a0a`
- 有效 RED test：`Saved/Tests/cta-reference-scalar-width-red-r2/20260825_150401_541_2cd3cdc4`
  - AST facts：`Value type=int&`、`Factor type=const int`
  - 错误 bytecode：`MULi64`
- Build GREEN：`Saved/Build/cta-reference-scalar-width-green-r2/20260825_150459_538_07424838`
- 精确测试 GREEN：`Saved/Tests/cta-reference-scalar-width-green-r2/20260825_150515_469_9da4fa70`

**新增闸门**

`CanonicalInRefScalarBinaryUsesPointeeWidth`

**无效 RED 说明**

第一版 fixture 使用 `Value * 2`，编译器合法选择了 `MULIi`，没有经过待验证的 generic `MULi/MULi64` 分支。该结果不能证明产品缺陷，也不能作为修复证据。最终 fixture 改为 `Value * Factor` 后才形成有效 RED。

### 3.4 返回 self object handle 的返回槽缺少 pointer metadata

**现象**

真实 StaticJIT 处理 `UStaticJITAotFunctionCarrier::ReturnSelfObject()` 时，无法解析 bytecode offset 11、variable offset 2 的 VM variable type。对应 bytecode 为 `CpyVtoV8` 后接 `LOADOBJ`，但返回槽既不在 explicit/object/temporary/local inventory，也不在 pointer inventory。

**根因**

函数初始化无条件通过 `AllocTemporary(func->returnType, returnDwords)` 创建 return slot。object handle/funcdef 的 VM frame 语义是 pointer slot，应通过 `AllocPointerVariable()` 登记；仅按返回 dword 数分配临时槽会丢失 StaticJIT 所需的槽类型事实。

**为什么既有闸门漏检**

VM 可以依靠 opcode 和运行时值完成简单返回，但 StaticJIT 必须提前把每个 frame offset 映射为确定的 C++ 表示。既有执行测试没有检查返回槽 inventory，因而没有覆盖“能在 VM 跑”与“能被 BytecodeJIT 静态类型化”的差异。

**修复**

return slot 分配规则改为：

- object handle 或 funcdef：`AllocPointerVariable()`；
- 其他返回类型：`AllocTemporary(returnType, returnDwords)`。

**证据**

- 有效 RED build：`Saved/Build/cta-self-handle-return-metadata-red-r2/20260825_151123_736_9bf2f19c`
- 有效 RED test：`Saved/Tests/cta-self-handle-return-metadata-red-r2/20260825_151146_067_5ce5f64c`
  - `slot=2`
  - `temporaryVariables=0`
  - `pointerVariables=0`
  - bytecode 包含 `CpyVtoV8`、`LOADOBJ`
- Build GREEN：`Saved/Build/cta-self-handle-return-metadata-green/20260825_151248_931_07cc4d4b`
- 精确测试 GREEN：`Saved/Tests/cta-self-handle-return-metadata-green/20260825_151304_165_70f44e49`

**新增闸门**

`CanonicalSelfHandleReturnPublishesPointerTemporaryMetadata`

**无效 RED 说明**

第一版 fixture 同时加入了构造与 identity expression，但脚本本身未通过编译，未触达 return-slot inventory，因此不是有效的产品 RED。移除无关表达式、只保留 `return this` 后才得到有效 RED。

### 3.5 Handle `==` / `!=` 被发成 `CMPi`

**现象**

`StaticWorldContextCheck` 的 `__WorldContext() != WorldContextObject` 把两个 pointer 槽交给 `asBC_CMPi`，StaticJIT 在 `VArg_IsNumeric(0)` 断言失败。

**根因**

Canonical `EmitBinary` 只对 `is` / `!is` 和 **null** `==` / `!=` 走 `CmpPtr` / `CmpPtrNull`。非 null handle 比较落到 `EmitCompare`，默认 opcode 是 `CMPi`。Sema 已经把该比较封成 builtin `Binary !=`（不是 `opEquals` Call）；隐式 handle 的 `CObj` QualType 可以没有 `asAST_QUAL_HANDLE`，但 `TypeOf` 对 `asOBJ_REF` 仍解析为 object handle。

**修复**

`EmitBinary` 对 object-handle / funcdef 的 `==` / `!=` 选择 `CmpPtr`，一侧为 `NullLiteral` 时仍用 `CmpPtrNull`。值对象 `opEquals` 继续走 Call。

**闸门**

`attachments/canonical-handle-pointer-equality-codegen-gate-2026-08-26.md`

- AST GREEN：`Saved/Tests/cta-handle-compare-ast/20260826_171131_642_1fbf5353` **1/1**
- CodeGen RED：`Saved/Tests/cta-handle-compare-codegen-red/20260826_171210_346_604956ad` **0/1**
- CodeGen GREEN：`Saved/Tests/cta-handle-compare-codegen-green/20260826_171347_601_af20ee38` **3/3**

**新增测试文件**（不再追加到超大的 SemaAuthority / ProductionCodeGen 翻译单元）

- `AngelscriptNativeCanonicalASTSemaHandleCompareTests.cpp`
- `AngelscriptNativeCanonicalASTProductionHandleCompareTests.cpp`

## 4. 当前调查中的问题：这条 StaticJIT 探针已越过 handle-equality

同一条真实入口在 handle `CmpPtr` 修复后为 **1/1 PASS**：

- `Saved/Tests/cta-staticjit-after-handle-cmpptr/20260826_171429_962_aa3b7e7c`

这只证明 `RecordsFirstVersionHirGenerationAndExecutionTimings` 不再死在 `CMPi`。它不是完整 StaticJIT 前缀、generation 32/32，或 section 10 cutover。下一刀仍是更宽的 StaticJIT/generation 入口，而不是勾选 broad completion task。

## 5. 对 OpenSpec 闸门设计的直接结论

这组问题表明，AST-first 闸门不能只检查树形结构和解释/VM 结果。要证明 canonical AST 可以成为唯一前端事实源，至少需要四层连续验证：

```text
AST 语义事实
  -> bytecode opcode + frame metadata
  -> artifact dependency / source authority
  -> StaticJIT fact capture + provider lowering
  -> native artifact 执行
```

每层应分别有 focused test，同时保留一条真实端到端 fixture。特别需要继续强化：

- synthetic/generated declaration 在事务性 body replacement 后的 source provenance；
- field/function/type identity 到 artifact dependency envelope 的精确映射；
- reference/handle/function-def 在 VM frame 中的 value width 与 storage category；
- comparison/call/return 的 opcode 与 frame inventory 一致性；
- 无效 fixture、过滤器错误和真正产品 RED 的显式分类。

## 6. 当前状态

- 本文列出的前五个产品缺陷（含 handle `==`/`!=` → `CmpPtr`）已经有 focused RED、最小修复和精确 GREEN；
- 真实 StaticJIT 探针 `RecordsFirstVersionHirGenerationAndExecutionTimings` 已越过 source metadata、property dependency、reference width、handle return slot、handle pointer equality，当前为 **1/1 PASS**；
- 完整 StaticJIT 前缀、generation 32/32 和 section 10 仍未作为本切片证据；
- 不因此勾选 broad completion task。
