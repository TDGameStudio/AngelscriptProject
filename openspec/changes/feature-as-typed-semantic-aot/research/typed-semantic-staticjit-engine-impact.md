# Typed semantic StaticJIT：Engine 改造面与实施边界

> 2026-08-13 架构收口说明：本文较早使用的 `Legacy`、`Semantic`、`Dual` 是研究阶段词汇。规范性名称现为 `BytecodeJIT`（BackendId `"bytecode"`）和 `TypedASTJIT`（BackendId `"typed-ast"`）；生产系统没有 `"dual"` 后端，差分验证使用相互隔离的 VM、BytecodeJIT、TypedASTJIT 生成/执行。生产接入必须先完成 `refactor-as-unified-jit-coordinator` 的 BytecodeJIT 提取、Static backend contract 和 generation-only Engine 三个基础组；若本文与 proposal/design/spec/tasks 冲突，以规范性文件为准。

## 1. 结论

这里讨论的 “AST JIT” 实际是 **StaticJIT/AOT 功能**：在生成阶段把 AngelScript 源码编译器已经解析和类型化的语义结果转换为 C++，再交给平台 C++ 编译器构建静态 provider。它不是在游戏运行时按热点函数生成机器码，也不属于 `AngelseaRuntimeJIT` 或 `AngelseaLLVMJIT`。

建议的准确管线是：

```text
AngelScript source
    -> parser AST（短生命周期、只服务本次前端编译）
    -> asCCompiler semantic resolution
    -> function-owned structured typed HIR（可选 sidecar）
    -> TypedASTJIT eligibility/reference planning
    -> HIR -> C++ body emitter
    -> C++ toolchain
    -> StaticJIT provider entries
```

现有管线继续保留：

```text
AngelScript source -> bytecode -> VM
AngelScript source -> bytecode -> BytecodeJIT C++ -> StaticJIT provider entries
bytecode -> Angelsea/MIR or LLVM Runtime JIT（由另外两个 OpenSpec 规划）
```

因此，这项功能需要改 maintained AngelScript compiler fork 和插件 `StaticJIT`，但 **不需要修改 Unreal Engine 源码，也不需要把 UE 类型塞进 compiler HIR**。TypedASTJIT 本身不实现 Runtime JIT；它通过统一 Static 生成器产出既有 C++ provider，运行时 provider 选择则由统一 coordinator 管理。

生成时会创建专用的临时 `FAngelscriptEngine`，重新回放完整目标 Bind surface，并以 HIR capture 打开状态重新编译完整 Provider 源码图；它只发出请求的模块。这个路径必须调用 ClassGenerator 的纯 descriptor-analysis seam，禁止普通 `Setup()`、Soft/Full Reload、UObject materialization、reinstancing 和 route publication，因此不会创建脚本 `UClass`、`UScriptStruct`、`UDelegateFunction`、`UFunction` 或 CDO。现有 native UE reflection 只读复用，不需要为临时 Engine 重新创建 native `UClass`。

这里必须固定三个不同入口，不能都叫“生成 HIR”：

| 请求 | Engine | 输出 | 明确禁止 |
| --- | --- | --- | --- |
| compiler/Standalone HIR test snapshot | 测试自有 `asCScriptEngine` | 内存 HIR + deterministic text/JSON/diagnostics | `FAngelscriptEngine`、ClassGenerator、Static backend、C++/Provider、fallback |
| UE integration/developer `AngelscriptHIRDump` | 每个 concrete Profile 一台受限 generation Engine | `.hir.txt`/`.hir.json` 测试诊断文件 | `UAngelscriptJITCommandlet` mode、BackendId、C++/Provider、fallback、dump readback |
| StaticJIT `BackendId="typed-ast"` | 每个 artifact/Profile 恰好一台 generation Engine | C++/Provider + typed fallback diagnostics | 第二台 HIR Engine、backend recompile、默认 HIR 落盘、从 dump 读回 |

StaticJIT 的 bytecode 与 HIR 来自同一次完整 source build，HIR 在 Engine 存活期内同步以内存方式交给 TypedASTJIT。单独的 HIR dump 只在明确运行测试/开发请求时存在；它不是生产缓存、Provider owned artifact 或后续编译输入。`BackendId="bytecode"` 始终 capture-off，也不创建额外 HIR Engine。

## 2. 为什么不能在 `WriteOutputCode()` 直接读取 parser AST

当前源码编译时序已经决定了 raw parser tree 不能成为 StaticJIT 的延迟输入：

1. `asCCompiler::CompileFunction()` 在 `as_compiler.cpp` 中创建局部 `asCParser parser(builder)`。
2. `parser.ParseStatementBlock(...)` 生成 `asCScriptNode` 语法树，随后 `CompileStatementBlock(...)` 在同一个局部作用域内消费它。
3. `asCParser::CreateNode()` 使用 parser 自有的 `FMemStackBase MemStack` 分配节点；`asCParser::~asCParser()` 调用 `Reset()`，parser 生命周期结束后节点不再是可保留的编译产物。
4. `asCCompiler::FinalizeFunction()` 完成 bytecode finalize、exception/object-variable metadata 提取，并把最终 bytecode 写入 `asCScriptFunction::ScriptFunctionData`。
5. UE 的 `FAngelscriptEngine::CompileModule_Code_Stage3()` 先删除 `ScriptModule->builder`，再调用 `ScriptModule->JITCompile()`。
6. `FAngelscriptStaticJIT::OnFunctionReady()` 在生成模式下只把函数加入 `FunctionsToGenerate`；最终 `WriteOutputCode()` 才统一执行 `AnalyzeScriptFunction()` 和 `GenerateCppCode()`。
7. 当前 `GenerateCppCode()` 明确调用 `GetByteCode()` 并通过 `FAngelscriptBytecode` 解释指令；当前 reference resolver 也会扫描 bytecode 收集函数引用。

这意味着 `WriteOutputCode()` 到达时：

- 完整源码语义已经解析完毕；
- parser 和 builder 都已经结束生命周期；
- 可稳定访问的函数级编译产物主要是 `ScriptFunctionData` 中的 bytecode 和 metadata；
- 如果此前没有主动保留 typed semantic artifact，StaticJIT 只能从 bytecode 反推语义。

所以正确方向不是延长 raw AST 生命周期，而是在 `asCCompiler` 做语义决策的当下同步构造一个更小、更稳定、只包含最终语义的 function-owned typed HIR。

## 3. Maintained compiler fork 需要的改造

### 3.1 新增 fork-private typed HIR 模型

建议在 `ThirdParty/angelscript/source/as_typed_semantic_ir.h/.cpp` 增加 `asCTypedSemanticFunction`，使用 indexed arenas 保存：

- function-local symbol；
- typed expression；
- structured statement；
- switch case/child list；
- source span；
- resolved call target；
- unsupported marker。

节点之间使用整数 ID，不保存 parser node 指针，也不引入 UE `TArray`、`FString`、`UObject` 或反射类型。类型继续使用 maintained frontend 已有的 `asCDataType`；调用目标保存同一 engine 内的 resolved function ID，而不是保留 `asCScriptFunction*`，避免递归函数引用、模块替换和销毁顺序把指针生命周期带进 HIR。normalized dump 和稳定诊断均不能使用进程指针值作为 identity。

HIR 是 compiler-private sidecar，不通过 `angelscript.h` 发布稳定 ABI。第一版不序列化到 `PrecompiledScript.Cache`、`SaveByteCode()` 或任何独立缓存。

### 3.2 `asCExprContext` 必须携带 expression identity

`asCExprContext` / `asCExprValue` 已经携带编译器最终解析出的类型、常量、临时变量、属性/调用等状态，是建立 typed expression 的正确位置，但仅在最外层 compiler hook 临时重建表达式会丢失值身份和求值顺序。

需要为 capture-on 编译增加一个 invalid-by-default 的 HIR expression ID，并覆盖所有 context 生命周期操作：

- 构造与 `Clear()`：重置为 invalid；
- `Copy()`：复制值 identity；
- `Merge()`：按被合并 expression context 的最终值更新 identity；
- conversion、assignment、unary/binary、call、short-circuit：在语义决定完成后创建新 expression node，并把结果 ID 写回 context；
- 丢弃值或 void expression：显式清空 identity；
- branch/temporary rewrite：不得错误复用已经被消费的 expression ID。

这不是把 HIR 反向接入编译决策，而是给已经存在的 expression value 增加一个只读“该值来自哪个 semantic node”的 sidecar identity。capture-off 时该字段必须没有可观察行为和额外节点分配。

### 3.3 statement capture 跟随现有递归 compiler path

statement builder 应在 `CompileStatementBlock` 及各 statement compiler 路径中记录结构化关系，而不是从 `asBC_JMP*` 重建 CFG：

- block 与 declaration order；
- if/else；
- for/while/do-while；
- switch/case/default/fallthrough；
- break/continue target category；
- return 与返回 expression；
- expression statement。

第一版保留 structured HIR，不提前转换为 typed CFG/SSA。LLVM、MIR 或优化 pass 将来如果需要，可从 HIR 单独 lowering；这不应阻塞 HIR -> C++ 的初始 StaticJIT。

### 3.4 使用 provisional transaction，成功后才提交

HIR builder 必须是函数编译事务的一部分：

1. `asCCompiler::Reset()` 根据 engine capture flag 创建 provisional builder；
2. semantic compile 过程中只向 provisional arenas 写入；
3. 正常 bytecode compile/finalize 仍是主流程；
4. 只有函数无编译错误、bytecode finalize 成功且 HIR verifier 通过，才把 HIR owner 提交给 `outFunc->scriptData`；
5. 编译错误时丢弃 provisional HIR；
6. bytecode 成功但 HIR verify 失败时保留 bytecode，记录 invalid-HIR 诊断，TypedASTJIT 逐函数 fallback；
7. function/module replacement 或 destruction 时，在现有函数/类型引用释放之前先丢弃 HIR，再按原顺序销毁 `ScriptFunctionData`。

不能在 statement block 编译一半时把可访问指针发布到 function，也不能让 HIR verifier failure 改写合法脚本的 bytecode 结果。

除普通 `CompileFunction()` 外，还要显式盘点 default constructor/destructor、factory、list factory、lambda/accessor 和 compiler-synthesized function。第一版可以为不在支持范围的函数生成 deterministic unsupported disposition，但不能遗漏清理或留下半提交 sidecar。

### 3.5 捕获开关必须在源码编译前确定

捕获开关应是 fork-private engine setting，默认关闭。关键不是选项名字，而是设置时机：

- BackendId `"bytecode"`：不捕获 HIR；
- BackendId `"typed-ast"`：创建 generation Engine 后、任何目标源码模块 build 之前启用 HIR capture；
- 到最终 output generation 才切换为 TypedASTJIT 已经太晚，因为 parser/compiler 临时状态已经销毁；
- TypedASTJIT generation 必须重新从完整源码图编译；从 bytecode-only cache/load 得到的函数不能补造 HIR。

命令行 `-as-static-jit-backend=bytecode|typed-ast` 只是一个 Static artifact 入口。programmatic Provider generation API 和 StaticJIT AOT fixture 必须显式携带 BackendId/capture profile，不能依赖当前进程恰好带了命令行。普通 compiler HIR test helper 与 `AngelscriptHIRDump` 不携带 Static BackendId，只携带自己的 capture/profile/snapshot 设置。`dual` 不是生产 BackendId，`DumpHIR` 也不是 BackendId。

## 4. `FAngelscriptEngine` / generation orchestration 需要的改造

### 4.1 两阶段配置契约

需要区分两个时间点：

| 阶段 | 必须完成的事情 | 不能做的事情 |
| --- | --- | --- |
| Engine/source build 前 | 冻结 Static BackendId；只为 `"typed-ast"` 启用 private HIR capture；冻结 generation profile、完整 Provider source domain 与 `EmitModuleSet` | 不能等待 descriptor root classification 后才决定是否 capture |
| Generation view freeze | 校验请求 BackendId 与已编译 Engine 的 capture profile 一致；冻结完整 `CompiledSourceGraph`；建立 UFUNCTION root index | 不能补造缺失 HIR，不能从 observer 或 bytecode 猜回 typed HIR |
| Final output generation | 逐函数选择 TypedASTJIT/BytecodeJIT/VM，并仅为 `EmitModuleSet` 打包 | 不能因输出过滤而隐藏跨模块语义依赖 |

因此建议 generation request/settings 记录：

- requested Static BackendId；
- capture expected/enabled；
- complete Provider source domain 与独立 `EmitModuleSet`；
- profile/content identity 所需的 backend-relevant version；
- mismatch diagnostic。

如果 programmatic generation 请求 `"typed-ast"`，但目标 Engine 是 capture-off 编译的，整个任务必须以 `CaptureProfileMismatch` 失败；不得在 backend 内重编译、不得退成全 BytecodeJIT 后仍宣称 TypedASTJIT artifact 已生成。只有 capture profile 已正确验证后，函数级 unsupported/emitter failure 才能走 TypedASTJIT → BytecodeJIT → VM 回退。

### 4.2 不需要修改 UE Engine 源码

所有必要改造均位于：

- maintained AngelScript compiler fork；
- `AngelscriptRuntime/Core` 的 generation configuration/bootstrap；
- `AngelscriptRuntime/StaticJIT`；
- `AngelscriptTest` 和 Standalone tests；
- OpenSpec/架构文档。

不需要：

- 改 Epic Unreal Engine 源码；
- 在 UE runtime 动态编译 C++；
- 为 typed HIR 建 UObject/UStruct 镜像；
- 把 ClassGenerator 语义改写成另一套系统；但需要从其现有分析阶段抽出纯 descriptor-analysis seam；
- 在 TypedASTJIT backend 内实现 Runtime JIT coordinator、code memory、hotness 或 invalidation。

ClassGenerator 的纯分析 seam 在临时 Engine 内提供最终 `FAngelscriptFunctionDesc::ScriptFunction` identity 和 Entry Plan 所需描述符，但不执行 UObject materialization、reload 或 route publication。统一 coordinator 只负责加载后的 Provider/Runtime/VM 路由，不参与 HIR lowering。

### 4.3 generation Engine 的影响面必须按 owner 隔离

临时 Engine 不是“完整启动一次插件 Runtime”。它只允许执行 Bind replay、完整源码编译、HIR capture、descriptor analysis 和同步 output planning。compile purpose 必须禁止：

- 获取、清扫或修改共享 `/Script/Angelscript`、`/Script/AngelscriptAssets` package domain；
- 创建脚本 UObject、native/script CDO，或通过 `GetDefaultObject()` 隐式创建 CDO；
- redirect、reload planner、Soft/Full Reload、reinstancing、default initialization；
- DebugServer、CodeCoverage/Crash extension、Hot Reload watcher/thread、test discovery、`PostEngineInit` delegate；
- runtime Provider refresh/publication、BindDB 写入、Cache V2 restore 冒充 HIR source build、cache publication；
- 清空或替换 `GBlueprintEventsByScriptName`、Editor class cache、primary route/module/type/descriptor registry、其他 Engine 的 pooled contexts。

native reflection 只读复用；如果不创建 CDO/UObject 就无法证明某个 ABI/route，该函数必须 fail closed。无论成功、source compile failure、HIR verify failure、descriptor/backend/packaging failure，销毁都只释放该请求拥有的 `asIScriptEngine`、modules/functions/types、contexts、descriptor/HIR arenas 和 owned database/snapshot；主 Engine 的 package、registry、cache、route、UObject、delegate、world、context pool 前后快照必须不变。

### 4.4 Editor Generate/Refresh 只做 freshness gate

Editor 的 Typed StaticJIT Generate/Refresh 先只读比较 primary Engine authoritative source inventory/content/profile 与当前请求。若已 current，才把同一 source snapshot 交给一台临时 generation Engine；若 stale，则返回 `AuthoritativeEngineStale`，要求用户/调用者先走现有普通 Hot Reload/recompile，再重试。

StaticJIT action 不调用 `ForceCleanCacheModules()`，不触发 primary `CompileModules()`、ClassGenerator reload/reinstancing 或 Live Coding，也不负责把 live Engine 修到最新。这样 fresh path 只有 generation Engine 的一次完整 source compile，避免“主 Engine 编译一次 + 临时 Engine 再编译一次”。隔离 Commandlet 的显式 source/profile request 自身就是该进程内 authority，但仍只创建一台受限 Engine。

## 5. StaticJIT 需要的结构性拆分

### 5.1 保留 collector，拆分 analyzer 和 body emitter

现有生成收集行为在重构期间由 facade 保持兼容，但 output pipeline 需要从单一 bytecode path 拆成：

```text
Function collection
    -> shared route/root/entry planning
    -> per-function backend disposition
        -> BytecodeJIT analyzer -> bytecode emitter
        -> TypedASTJIT eligibility/reference analyzer -> HIR emitter
        -> VM-only disposition
    -> shared provider artifact/registration packaging
```

建议职责边界：

- `FStaticJITEntryPlan`：C++ signature、VM stack/Parms offset、return placement、VM/raw/parameter wrappers；
- BytecodeJIT analyzer/emitter：整体迁入 `StaticJIT/BytecodeJIT`，保持当前 `AnalyzeScriptFunction()`、`GenerateCppCode()`、`FStaticJITContext` 和 `AngelscriptBytecodes.cpp` 行为；
- TypedASTJIT analyzer：读取 HIR、UFUNCTION descriptor、route/native-call metadata，产出 eligibility、dependency/reference、call plans 和 fallback reason；
- TypedASTJIT emitter：只消费 HIR + shared entry plan + semantic call plan，不调用 `GetByteCode()`；
- provider packaging：不关心 body 来自 BytecodeJIT 还是 TypedASTJIT，复用同一 entry/provider identity。

### 5.2 TypedASTJIT reference collection 也不能扫描 bytecode

“TypedASTJIT emitter 不读 bytecode”还不够。如果生成前的 reference resolver 仍为 TypedASTJIT function 扫 `GetByteCode()`，那么 TypedASTJIT backend 依然隐式依赖 bytecode 反汇编。

TypedASTJIT path 的依赖/reference 需要直接来自：

- HIR resolved call targets；
- HIR type/symbol references；
- shared entry plan；
- explicit external-native-call descriptor；
- provider route/identity metadata。

BytecodeJIT 继续使用现有 bytecode reference scan。测试应在 analyzer 和 emitter 两个层面设置 bytecode-access sentinel，证明一个 eligible TypedASTJIT function 从支持度分析、reference collection 到 C++ body emission 都没有读取 VM instruction stream。

### 5.3 Shared entry plan 不等于重写 BytecodeJIT

抽取 shared entry plan 的目的只是避免两套 emitter 分别发明 VM/raw/parameter ABI。它不能顺带删除或大改 bytecode lowering：

- BytecodeJIT 默认输出保持 golden-compatible；
- `FStaticJITContext`、`FAngelscriptBytecode` 和 `AngelscriptBytecodes.cpp` 继续存在；
- per-function TypedASTJIT fallback 仍能调用 BytecodeJIT；
- bytecode-only module 仍能走 BytecodeJIT/VM；
- 差分测试使用相互隔离的 VM/BytecodeJIT/TypedASTJIT artifacts，不引入生产 `dual` 后端。

## 6. 第一版支持边界

第一版建议继续限定为 ordinary scalar/enum UFUNCTION root：

- 参数/返回：`void`、bool、定宽整数、float、double、enum，全部 by value；
- 表达式：literal、parameter/local、assignment、conversion、基础 unary/binary、short circuit；
- statement：block、if/else、for/while/do-while、switch、break/continue、return；
- 调用：已解析、scalar marshalling 可证明、route 安全的 direct 或 bridge call。

以下逐函数 fallback：

- UObject/property/object-valued expression；
- reference/out、handle、struct/container/delegate；
- managed temporary/destructor/复杂 exception cleanup；
- coroutine/suspend；
- RPC、BlueprintEvent、virtual/override raw-direct；
- 无法证明 external DLL linkage 或 bridge ABI 的 native call；
- invalid/missing HIR。

这里的 UE 约束主要来自最终 entry/call routing，而不是 HIR 本身。HIR 仍然是 host-neutral；UFUNCTION eligibility 和 `ProcessEvent`/RPC route 检查属于 UE StaticJIT backend 层。

## 7. 失败与回退矩阵

| 情况 | Bytecode | HIR | TypedASTJIT | 结果 |
| --- | --- | --- | --- | --- |
| BytecodeJIT/default generation | 正常 | 不捕获 | 不请求 | BytecodeJIT/VM |
| compiler/Standalone HIR snapshot | 正常 | test engine capture + verify | 不构造 | text/JSON/diagnostics；无 C++/Provider/fallback |
| `AngelscriptHIRDump` | 正常 | restricted generation Engine capture + verify | 不构造 | filtered deterministic dump；无 C++/Provider/fallback |
| `"typed-ast"`，支持函数 | 正常 | valid | eligible | HIR -> C++ |
| `"typed-ast"`，HIR 有 unsupported marker | 正常 | valid but ineligible | fallback | 该函数 BytecodeJIT/VM，模块内其他函数仍可 TypedASTJIT |
| `"typed-ast"`，HIR verifier 失败 | 正常 | 不发布/invalid | fallback + diagnostic | 保留 bytecode，禁止 partial TypedASTJIT entry |
| 源码编译失败 | 不发布有效函数 | provisional discard | 不运行 | 原编译错误权威 |
| bytecode-only load | 正常 | absent | 不允许用于本次 typed generation | orchestration 从完整源码图重新编译 |
| generation BackendId/capture profile mismatch | 正常 | absent/unexpected | `CaptureProfileMismatch` | 整个任务失败，不得伪装为成功 TypedASTJIT artifact |
| TypedASTJIT emitter 声称支持但失败 | 正常 | valid | `EmitterFailure` | production 逐函数回退；差分 fixture 失败 |
| Editor authoritative source/profile stale | 不启动 generation compile | 不捕获 | 不构造 | `AuthoritativeEngineStale`；先走普通 Hot Reload |

## 8. 推荐实施顺序

具体 patch 落点、接口骨架、首个 scalar fixture 和验证命令见 `typed-semantic-staticjit-patch-cookbook.md`；可在真实代码落地前运行的 synthetic corpus 位于 `fixtures/semantic-aot-v1/`。

1. 先验证 synthetic HIR corpus，再实现 HIR 数据模型、ownership、verifier、dump 和 capture-off 零行为测试。
2. 实现 provisional transaction、`ScriptFunctionData` commit/destruction，以及 `asCExprContext` expression ID 的 `Clear/Copy/Merge/conversion` 传播。
3. 只捕获 `SemanticScalarBranch` 所需的 scalar expression 和 block/if/return；证明 capture-on/off bytecode 与 VM 行为一致。
4. 实现独立的 compiler/Standalone snapshot helper，验证 deterministic text/JSON 与不读回；再以另一个请求实现不接收 bytecode/provider state 的纯 HIR analyzer/emitter，生成并编译测试专用 TypedASTJIT probe。
5. 对同一源码和四组输入执行隔离的 VM、BytecodeJIT、TypedASTJIT 三路对照，并用 entry counter 证明 TypedASTJIT body 真正执行。
6. 在功能纵切转绿后扩展 scalar/enum、structured control flow 和异常边界。
7. 等 unified change 的 groups 1-3 完成后，再接入 Static BackendId/capture 两阶段生产配置、单 generation Engine/单 source build/内存 HIR 交接、完整 `CompiledSourceGraph`/`EmitModuleSet`、UFUNCTION root、shared entry plan 和 programmatic generation mismatch tests。
8. 实现 native direct/bridge call contract 和 external DLL linkage 测试。
9. 增加独立 `AngelscriptHIRDump`、全影响面 success/failure containment、Editor read-only freshness gate，再对接稳定后的 provider ABI、诊断、基准和全套验证。

前两步是 compiler 前提；第 3-5 步构成功能闭环。provider/runtime 架构不是这个闭环的前置条件，也不能用 test-only probe 冒充生产 provider/UASFunction 接入完成。

## 9. 外部架构参考及优先级

| 优先级 | 参考 | 最值得借鉴 | 不应照搬 |
| --- | --- | --- | --- |
| 1 | `Reference/Cython` | typed source tree 经 declaration/type analysis 后直接输出 C/C++；最接近本变更的 output boundary | Python C-API/object semantics |
| 2 | `Reference/daScript` | typed AST、支持度预检、函数级 tree/AOT/JIT 混合、semantic hash 思路 | 直接把 LLVM backend 和运行时体系移入 UE 插件 |
| 3 | Dart Kernel 官方资料 | frontend semantic IR 与 backend 解耦、明确 schema/生命周期 | 第一版就持久化 HIR 并承担兼容 schema |
| 4 | Haxe/hxcpp 官方资料 | typed source -> C++ target、target runtime/ABI 分层 | 认为生成 C++ 就自动解决 reflection/GC/exception ABI |
| 5 | Julia/Numba | 未来 structured HIR -> typed CFG/SSA 的 pass 分层 | 第一版先建 LLVM/SSA 再做 C++ emitter |
| Runtime 专用 | `Reference/angelsea`、`Reference/luau` | bytecode native lowering、VM exit、fallback、函数安装 | 把 bytecode Runtime JIT 设计当作 typed source StaticJIT frontend |

如果只拉取/长期保留少量目录，`Reference/Cython` 和 `Reference/daScript` 对这个 OpenSpec 最有价值；`Reference/angelsea` 和 `Reference/luau` 应归入另外两个 Runtime JIT OpenSpec 的核心参考。

## 10. 最终判断

这项改造不是“改几个 emitter 函数就结束”，但也不需要碰 UE Engine 或发明完整 optimizing compiler。真正的难点集中在三个边界：

1. 在 frontend 语义决定仍然存在时，稳定、无副作用地捕获 typed HIR；
2. 把 capture backend 在源码编译前冻结，并在 final generation 验证 profile 一致；
3. 让 TypedASTJIT analyzer/reference/emitter 真正独立于 bytecode，同时复用现有 entry/provider ABI 并保留逐函数 BytecodeJIT/VM fallback。

一旦这三个边界处理好，scalar/enum HIR -> C++ emitter 本身是可控、可渐进扩展的工作。它应作为现有 StaticJIT 的第二个可配置静态 backend，而不是 Runtime JIT，也不是对 bytecode backend 的替换。
