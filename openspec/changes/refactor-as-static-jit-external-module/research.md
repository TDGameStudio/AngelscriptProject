# StaticJIT 外置模块与稳定函数路由研究记录

> 状态：研究中（plan-only，不实施）
> OpenSpec change：`refactor-as-static-jit-external-module`
> 首次记录：2026-08-07
> 记录方式：按研究轮次增量追加；已证实事实、推断、候选方案和未决问题分开记录。

## 1. 研究目标

评估把现有 StaticJIT 演进为 **Editor-first 的逐函数 Native 加速能力**：Editor 仍按正常开发模式从源码编译并保留 AS 热重载，同时从独立游戏模块发现 Native 工件；函数身份、内容和兼容性匹配时走 Native，修改或失配时安全回退 VM。独立游戏模块是交付与编译边界，不是本 change 的唯一目标。

本研究重点回答：

1. 独立游戏模块应承载哪些生成物、注册表与生命周期职责，哪些基础设施仍必须留在 `AngelscriptRuntime`。
2. 当前 `.Cache` 的真实内容、构建身份、加载时机和全量耦合点是什么；能否拆成清单、函数切片和必要的共享数据。
3. 当前 StaticJIT `FunctionId` 如何产生并绑定生成的 C++ 函数；它是否跨进程、跨编译顺序和热重载稳定。
4. 能否建立“稳定函数身份 + 内容哈希 + ABI/环境指纹”的函数粒度 Native 路由，使未修改函数继续命中已有 Native 入口，修改函数安全回退到 VM 或新生成入口。
5. Editor 中源码修改、模块重编译/动态加载、AS 热重载、旧 UObject/脚本实例和 Native 入口的生命周期如何协同。

### 1.1 用户确认的优先级（2026-08-07）

- **首要目标**：Editor 主流程可以实际使用 StaticJIT，而不是只让外部模块服务 cooked/game 启动。
- **必要体验**：Editor 继续使用当前源码/preprocessor/hot-reload 流程；未修改函数可持续命中 Native 入口。
- **外置目标**：StaticJIT 生成代码、manifest 和 UE 编译成本从核心 Runtime 模块移到独立游戏模块；Runtime 只保留通用生成/路由/校验基础设施。
- **当前建议的首版刷新语义**：修改的 AS 函数在热重载事务完成时立即撤销旧 Native 路由并回退 VM；未修改函数保持 Native。新 Native 入口经显式生成后，优先通过 UE Live Coding 在同一 Editor 会话编译/发布；Live Coding 不可用或失败时仍保持 VM，并允许离线构建/重启恢复。是否每次 AS 保存都自动触发 Live Coding，继续作为待确认产品选择。

## 2. 当前范围与边界

### 本轮包含

- 阅读现有 StaticJIT、预编译数据、生成文件、Editor 编译/热重载和测试路径。
- 对照已有 OpenSpec 规格与历史计划，识别已存在的契约。
- 比较 2–3 种外置与路由架构。
- 形成推荐设计、风险清单、分阶段实施计划和准确验证命令。
- 以 Editor 正常开发会话为主验收场景，cooked/game 路径作为必须保持兼容的第二场景。

### 本轮不包含

- 不修改 `Plugins/Angelscript` 源码、Build.cs、`.uplugin` 或生成工具。
- 不实际生成/加载新的游戏模块。
- 不把一次 Editor 热重载能力误写成已经验证的 Live Coding/DLL 卸载能力。
- 不承诺跨引擎版本、跨平台或跨编译器复用 Native 代码；这些必须由兼容性指纹显式约束。

## 3. 初始问题模型

### 3.1 身份不是单一 GUID 问题

预期至少需要区分三类信息：

- **逻辑函数身份**：回答“这是哪个函数”，应尽量不受声明枚举顺序和运行时 `FunctionId` 影响。
- **函数实现内容**：回答“函数体及其编译语义是否变化”，用于增量命中和失效。
- **Native 兼容性**：回答“这段已编译 C++ 是否可以在当前宿主中安全调用”，需要覆盖 ABI、引擎/插件构建、生成器版本、编译选项及依赖表版本。

把三者压缩成一个 GUID 会让重命名、移动、函数体修改和 ABI 变化的语义混在一起；研究将优先评估分层键，再按需派生最终 GUID/哈希。

### 3.2 函数切片不等于只哈希函数体文本

函数的 Native 结果可能还受下列信息影响：

- 规范化后的签名、所属类型/命名空间和模块身份；
- 默认参数、属性、访问控制和生成的隐式函数；
- 所调用脚本函数的调用约定或签名；
- 全局变量、类型布局、属性偏移、绑定 Native 入口和反射函数；
- 预处理结果、条件编译宏和 include 输入；
- StaticJIT 生成器版本、优化/调试选项及目标平台 ABI。

因此“脚本文本没改就直接走 Native”只能作为用户体验目标；实现判定应基于规范化编译输入及依赖指纹，而不是原始文件时间戳或裸文本哈希。

## 4. 已发现的仓库证据（第 1 轮）

### 4.1 当前实现与测试入口

- StaticJIT 主实现位于 `Plugins/Angelscript/Source/AngelscriptRuntime/StaticJIT/`。
- 运行时的 `ClassGenerator/ASFunction_Dispatch.cpp`、`ASFunction_CallHelpers.h` 与 `ASFunction.cpp` 共同负责 UASFunction/反射调用到 JIT 或 VM 的分派，需要纳入外置边界分析。
- AOT 测试位于 `Plugins/Angelscript/Source/AngelscriptTest/StaticJIT/AOT/`；生成物包括：
  - `Generated/AngelscriptJitInfo.jit.cpp`
  - `Generated/AngelscriptJitCode_0.jit.cpp`
  - `Generated/ASStaticJITAotFixture.as.jit.hpp`
  - 本地 `StaticJITAotFixture.Cache`（测试代码要求存在，但仓库文件索引未显示该文件）。
- `AngelscriptStaticJITAotFixture.cpp` 明确把 `.Cache` 与 `.jit.cpp/.jit.hpp` 称为“matched build pair”，并禁止运行时单独重建 cache 或跳过生成源码重编译。这是当前全量耦合的重要证据。
- 当前诊断表面提供 `ResolveFunctionId`、`IsFunctionRegistered`、`HasJitFunction` 和入口计数，注册表以 `uint32 FunctionId` 查询。是否稳定仍需追踪 ID 计算与生成代码。

### 4.2 已有规格与历史材料

- `openspec/specs/as-static-jit-aot-test/spec.md`：已有 AOT 生成、构建、加载与执行测试契约。
- `openspec/specs/static-jit-diagnostics/spec.md`：已有 StaticJIT 诊断契约。
- `openspec/specs/uasfunction-dispatch-matrix-and-jit-paths/spec.md`：已有 UASFunction Dispatch/JIT 路径契约。
- `Documents/Plans/Plan_StaticJITOfflineGeneration.md` 与 `Documents/Plans/Plan_AS238JITv2Port.md` 是历史计划，只作为证据，不能作为新计划载体。
- `Documents/Knowledges/ZH/RT_StaticJIT.md` 可能包含当前机制说明，需与源码核对。

### 4.3 工作区与版本事实

- 当前在主 checkout 的 `main` 分支，不创建 worktree。
- `Plugins/Angelscript` 子模块当前指向 `4899ff5e...`（`main`）。
- 工作区有与本研究无关的既有修改；本 change 只新增/修改自己的 OpenSpec 文档。

## 5. 初始假设（尚未定案）

| 编号 | 假设 | 当前状态 | 需要的证据 |
|---|---|---|---|
| H1 | 当前 `FunctionId` 至少部分来自非稳定运行时编号或全局编译状态，不能直接作为跨 Editor 会话持久键 | 待验证 | 追踪 ID 生成、序列化和生成代码注册 |
| H2 | `.Cache` 不只是函数到 Native 地址的映射，还保存模块、类型、全局引用或指针重定位数据 | 待验证 | 阅读 `PrecompiledData.*` 的 Save/Load/Reference 路径 |
| H3 | 外置模块可只拥有生成代码和静态注册清单；执行器、VM 回退、ABI 校验与路由应留在 Runtime | 候选方向 | 追踪 `FJITDatabase`、`FStaticJITCompiledInfo` 和模块启动顺序 |
| H4 | Editor 的首个可交付版本应是“启动/编译后加载已构建模块 + AS 热重载时逐函数命中或 VM 回退”，而不是未经验证就承诺在同一进程内自动编译并热替换 DLL | 候选范围 | 检查现有 Editor 热重载与 UBT/Live Coding 边界 |
| H5 | 稳定键应由逻辑身份、实现摘要和兼容性指纹组成；运行时 `FunctionId` 只作为本次引擎实例的快速索引 | 候选方向 | 验证调用入口与注册表可否增加二级解析 |

## 6. 待追踪的关键调用链

1. StaticJIT 生成：脚本模块/函数 → 字节码降低 → `.jit.hpp/.jit.cpp` → `FJITDatabase` 注册。
2. 预编译数据：`FAngelscriptPrecompiledData::Save/Load` → build identifier/GUID → 模块与引用恢复。
3. 执行路由：`asCScriptFunction` → JIT function pointer → UASFunction/VM fallback。
4. Editor 更新：文件变更 → 预处理/编译 → 函数对象替换 → JIT 入口重绑或失效。
5. UE 模块生命周期：生成游戏模块加载 → 注册 manifest → Runtime 验证 → AS 编译完成后绑定。

## 7. 研究日志

### 2026-08-07 / 轮次 1：建档与证据面盘点

- 创建 OpenSpec change，并确认采用 `spec-driven` schema。
- 识别出三个必须复用或修改的现有 capability：AOT 测试、StaticJIT 诊断、UASFunction Dispatch/JIT 路径。
- 确认当前测试把 Cache 和生成 C++ 当作不可拆分的 matched build pair；后续设计必须说明是保留整对原子性、将其升级为 manifest + slices，还是引入两级兼容模型。
- 暂不填写 proposal/design/tasks：先完成实际 ID、Cache 和加载/调用链调查，避免把推测固化为规格。

### 2026-08-07 / 轮次 2：FunctionId 与 Cache 职责还原

#### 已确认：当前 `FunctionId` 不是函数实现内容哈希

`FAngelscriptPrecompiledData::CreateFunctionId()` 当前执行：

1. 若函数名为空（全局属性初始化函数），使用两次 `FMath::Rand()` 拼出 ID，并明确注释“不需要保持一致”。
2. 普通函数依次哈希：
   - Script module 名称；
   - Script module `UserData`；
   - 所属对象类型的完整类型声明（若有）；
   - 函数完整声明。
3. 若 `ProcessedIdToFunction` 已占用该 `uint32`，循环执行 `++Id` 直到空位。

`AngelscriptEngine.cpp` 在 `AS_CAN_GENERATE_JIT` 下把模块的 `CombinedDependencyHash` 写入 module `UserData`。因此当前 ID 的语义更接近：

```text
Hash32(ModuleName, ModuleCombinedDependencyHash, OwnerType, FunctionDeclaration)
```

直接结果：

- 任何导致 `CombinedDependencyHash` 改变的模块或依赖修改，都可能让该模块全部普通函数换 ID；它不是函数粒度失效键。
- `uint32` 加线性碰撞修正依赖本次处理集合/顺序，不能作为持久工件的唯一可信身份。
- 空名初始化函数本身不稳定，必须在新模型中定义可重复的 synthetic identity，或明确排除其 Native 增量复用。
- 当前生成的 `.jit.hpp` 使用该 ID 创建静态 `FStaticJITFunction`，模块加载时直接写入全局 `FJITDatabase::Functions`。

据此，H1 更新为 **已证实**。

#### 已确认：`.Cache` 是完整脚本快照兼重定位数据库

`FAngelscriptPrecompiledData` 的序列化字段至少包含：

- `DataGuid` 与 `BuildIdentifier`；
- 完整 `Modules` 表；
- 类型引用与 type-id-to-old-pointer 映射；
- 函数引用与 function-id-to-old-pointer 映射；
- 全局变量引用；
- 属性引用；
- 静态 `FName` 字符串表。

运行时加载该 Cache 后，`GetModulesToCompile()` 直接重建预处理产物/模块描述；`AngelscriptEngine.cpp` 明确记录此路径会使用 fully precompiled scripts、绕过普通预处理输入并禁用本次运行的热重载。

生成 C++ 同时嵌入 `FJitRef_Function`、`FJitRef_SystemFunctionPointer`、`FJitRef_Type`、`FJitRef_GlobalVar`、`FJitRef_PropertyOffset` 等对象。其构造参数目前是生成时对象地址派生的 archive reference（例如测试工件中的 `0x29b...`），加载 Cache 后由 `PrepareToFinalizePrecompiledModules()` 解析为当前 engine/module lifetime 的实际地址。也就是说：

```text
生成的 Native 代码中的旧 reference token
        + 同一代 .Cache 的 reference 描述表
        = 当前进程可调用的指针/偏移
```

因此 `.Cache` 与生成 C++ 的 matched-pair 约束不仅来自 `DataGuid`，还来自这些 archive-local reference token。只替换 Cache 而保留旧函数切片会使 token 失去对应关系。

据此，H2 更新为 **已证实**。

#### 已确认：当前注册与激活模型是进程级单实例

- `FStaticJITCompiledInfo` 构造时写入一个函数静态 `ActiveInfo`，并用 `checkf` 强制“进程中只能编译一个 Static JIT info”。
- `FJITDatabase` 是函数静态单例，按 `uint32 FunctionId` 持有三个入口：VM、Parms、Raw。
- 预编译函数恢复时，仅在非 script-development-mode 下按 Cache 内 ID 查询数据库并写入 `asCScriptFunction::{jitFunction,jitFunction_ParmsEntry,jitFunction_Raw}`；缺失则走 VM/普通 fallback。

这说明“外置为独立游戏模块”不仅是 Build.cs 搬文件，还需要把单个全局 CompiledInfo 改为可注册、可枚举、可验证且能处理模块生命周期的 artifact provider/manifest 模型。

#### 研究判断：需要拆成两类工件

目前证据支持将未来模型明确拆成：

1. **可选脚本启动快照（Script Bootstrap Snapshot）**：若 cooked/启动性能仍需要，可继续承担完整模块、字节码与描述符恢复；它可以保持较粗粒度和严格整体兼容。
2. **Native Artifact Manifest + 函数切片**：供 Editor 正常源码编译之后进行逐函数匹配，只描述稳定身份、实现摘要、环境/ABI 指纹、Native 三入口及符号化依赖，不得要求 Editor 绕过预处理或关闭 AS 热重载。

这不是最终命名，但职责拆分已成为后续方案必须满足的设计约束。

#### 假设状态更新

| 编号 | 更新后状态 | 结论 |
|---|---|---|
| H1 | 已证实 | 当前 ID 包含模块 `CombinedDependencyHash`，且用 `uint32 + 顺序相关碰撞修正`，不适合作为跨会话函数身份。 |
| H2 | 已证实 | `.Cache` 同时是完整脚本快照与旧 reference token 的重定位字典。 |
| H3 | 加强 | 外置模块应承载生成函数和 manifest；Runtime 必须拥有注册、兼容性校验、符号解析和 VM 回退。 |
| H4 | 加强 | Editor 必须保留普通源码编译/热重载；Native 匹配应发生在新 `asCScriptFunction` 已编译完成、ClassGenerator 消费它之前，并允许 provider 晚到后再次匹配。 |
| H5 | 加强 | 运行时 `FunctionId` 应降级为会话内索引；持久匹配需使用更宽、可验证的结构化键。 |

### 2026-08-07 / 轮次 3：Editor 热重载事务与 UASFunction 分派风险

#### 已确认：当前 Editor 从编译配置和启动路径两层禁用 StaticJIT

- `StaticJITConfig.h` 在 `WITH_EDITOR` 下定义 `AS_SKIP_JITTED_CODE`，除非测试专用地定义 `AS_ENABLE_EDITOR_JITTED_CODE`。
- `FAngelscriptEngine` 只在非 Editor、非 script-development-mode 且未忽略预编译数据时启用 `bUsePrecompiledData`。
- `CheckForHotReload()` 一旦发现使用过预编译 preprocessor data 就直接返回；当前完整 Cache 启动路径和 AS 热重载在产品语义上互斥。

因此目标不能通过“在 Editor 打开 `AS_ENABLE_EDITOR_JITTED_CODE`”单点完成；必须同时解除 **JIT 入口依赖完整 Cache** 的前提，让 Editor 的普通源码编译成为权威，再把匹配到的 Native 入口附着到本轮编译出的函数对象。

#### 已确认：存在合适的事务内绑定点，但结构化 compilation event 不能直接承担绑定

`CompileModules()` 的成功路径顺序是：

```text
新模块完成 AS parse/type/layout/code/globals
  -> CompileClassGenerationHandoff 只读事件
  -> GetPreGenerateClasses().Broadcast(CompiledModules)
  -> ClassGenerator.AddModule / Setup
  -> SwapInModules
  -> SoftReload 或 FullReload
  -> 删除旧模块
  -> GetPostCompile().Broadcast()
  -> CompileEnd 只读事件
```

现有 `as-compilation-events` capability 明确要求事件 payload 是只读摘要，不能暴露或修改 builder/module 内部。因此：

- `CompileClassGenerationHandoff` 可用于诊断命中率和耗时，但不适合作为写入 JIT 三入口的 API。
- `GetPreGenerateClasses()` 已携带真实 `CompiledModules`，且发生在 ClassGenerator 检查/分配 UASFunction wrapper 之前，是首选的 **候选路由绑定点**。
- 若后续 ClassGenerator 拒绝这次 reload，新模块会被丢弃，旧模块仍保持原有路由；因此绑定动作必须只修改新函数对象，不得预先清空当前活跃旧模块。
- provider 在初始 AS 编译之后才加载时，还需要一次显式的“扫描当前模块并补绑定”入口；不能只依赖编译 delegate。

#### 已确认：Editor Soft Reload 会留下缓存 JIT 指针

`UASFunction::AllocateFunctionFor()` 在 final 函数同时具有 VM/Raw/Parms 三入口时选择 `_JIT` wrapper；Full Reload 随后把三入口复制到 `UASFunction` 字段。`TNonVirtual=true` 的调用模板读取这些缓存字段。

但 Soft Reload 当前只执行：

```text
ExistingUASFunction->ScriptFunction = NewScriptFunction
```

它没有刷新或清空 `JitFunction`、`JitFunction_Raw`、`JitFunction_ParmsEntry`。所以“旧函数命中 Native，编辑后新函数回退 VM”时，现有 `_JIT` wrapper 仍可能调用旧 DLL 中的入口。

首版 Editor hybrid 必须建立下列不变量之一：

1. **推荐**：热重载可用的 Editor 会话永不分配会缓存 Native 入口的 `_JIT` wrapper；保留按当前 `ScriptFunction` 动态读取入口的 wrapper。cooked/不可变脚本路径继续使用 `_JIT` wrapper。
2. 或者在每次 route rebind/soft reload 时原子刷新所有 `UASFunction` 缓存入口，并证明所有专用 wrapper 都覆盖到。

方案 1 的正确性面更小，也天然支持 provider 晚加载/解绑；需要用测试确认普通 wrapper 在全部反射 ABI shape 下都能在 Native 与 VM 间动态切换。

### 2026-08-07 / 轮次 4：逐函数路由的跨函数调用闭包

#### 已确认：当前生成代码会把脚本到脚本调用直接链接到 C++ 符号

`FCallScriptFunction::MakeCall()` 会尝试解析/devirtualize callee；只要 callee 同批生成，`WriteDirectCall()` 就：

- 把 callee 加入 `ExternFunctions`；
- 在 caller 的 C++ 中直接调用 callee 的生成符号。

对于“always JIT”的虚调用，生成代码直接读取 `CallRealFunction->jitFunction_Raw` 并调用，当前没有空指针 fallback。只有 `WriteDynamicCall()` 会建立新的 AS context，从当前 `asCScriptFunction` 执行，因而能自然落到当前 Native 或 VM 实现。

反例：

```text
函数 A 内容没改，外置模块中有旧 Native A
函数 B 被编辑，本轮 AS 编译出的 B 不再匹配旧 Native B
旧 Native A 仍直接调用外置模块中的旧 Native B
=> A 虽然自身内容哈希命中，整体行为却是旧语义
```

因此逐函数路由必须显式选择一种跨函数策略：

- **Editor routed-call 模式（推荐首版）**：Editor-hybrid 工件禁止脚本函数间的直接生成符号调用；经当前函数对象/route cell 检查 Native，失配时安全进入 VM。这样真正实现“B 改了只让 B 回退，A 仍可 Native”。首版可先复用正确但较重的 dynamic-call 语义，再独立优化轻量 route thunk。
- **依赖闭包失效模式**：保留直接符号调用，但 A 的摘要必须包含 B（以及必要的传递闭包/SCC）摘要；B 一变，A 也失效回 VM。性能较好，但不满足最强的“仅修改函数回退”体验，且虚调用仍需空入口保护。
- **无保护的直接调用**：不可接受，会执行旧实现或空入口。

Cooked/不可变脚本仍可保留当前 direct-call 优化；这个限制只需要施加于 Editor-hybrid 生成 profile。

#### 新结论：函数“切片”必须同时是代码切片和引用切片

每个可独立匹配的函数 slice 至少需要：

- 三类 Native 入口（VM、Parms、Raw，缺失能力要显式标志）；
- 稳定逻辑键与完整内容摘要；
- 它使用的类型、属性、global、script function、system function/native binding 等符号依赖；
- debug/source mapping 策略；
- profile 与 ABI/环境指纹。

如果切片仍引用一份整代 Cache 中的旧指针 token，它就不是真正独立切片。引用必须改成稳定符号描述，加载/编译后由 Runtime 为 provider 拥有的可写 reference cell 做解析；解析失败只拒绝该 slice，不清空其他命中函数。

### 2026-08-07 / 轮次 5：稳定身份、内容摘要与物理分片

#### 推荐的三层键模型

```text
LogicalFunctionKey
  = Hash256(schema/version,
            canonical virtual module identity,
            function kind,
            namespace + owner type,
            canonical declaration + semantic traits)

FunctionContentDigest
  = Hash256(canonical compiled function semantics,
            stable dependency descriptors,
            selected Editor-hybrid codegen profile)

NativeEnvironmentFingerprint
  = Hash256(target platform/arch/config,
            UE + plugin/fork build identity,
            compiler/toolchain ABI,
            codegen/bridge/layout versions,
            native binding/type-layout contract)
```

匹配条件是三者共同相等，而不是把它们压成一个模糊 GUID。对外可以把 `LogicalFunctionKey` 的前 128 位表示为稳定 `FGuid`，但 manifest 必须保留完整 256 位摘要和规范化身份记录用于碰撞验证；碰撞时拒绝条目并诊断，不能像当前 `uint32` 一样执行 `++Id`。

逻辑身份不应包含绝对磁盘路径、声明枚举顺序或源代码行号。重命名/改签名应产生新身份；只移动源码位置、调整注释/空白而不改变规范化模块与声明时，身份应保持稳定。

#### 内容摘要应来自已编译语义，不从原始文本粗暴切行

当前 preprocessor 的 `FCodeSection` 只有整段 processed code 和 XXH64；`FAngelscriptFunctionDesc` 有起始行，但没有可靠函数结束范围。仅靠文本切片容易被宏展开、生成函数、条件编译和同文件多函数破坏。

建议实现独立的 canonical fingerprint builder，从已编译 `asCScriptFunction`/bytecode 构建稳定记录：

- opcode 与常量保留；
- 运行时 function id、type id、对象地址、archive old-pointer token 转成稳定符号描述；
- 绝对行号/debug 信息从语义摘要分离；
- 签名、traits、依赖类型/属性/global/binding 契约纳入摘要；
- 匿名 global-init 函数首版默认不参与增量 Native 复用，直到能从被初始化 global 得到稳定 synthetic identity。

为保证未修改函数在上方插入注释/代码后仍可 Native，长期正确形态是：生成代码使用函数内稳定的 debug-location token，由 Runtime 绑定当前编译的 source map；若首版暂时保留硬编码绝对行号，则 `DebugMappingDigest` 必须参与匹配，代价是行号漂移会保守回退 VM，不能静默显示旧 callstack。

#### 逻辑逐函数、物理固定分片

物理上“一函数一个 `.cpp`”会导致 UBT action/TU 数量膨胀；“一模块一个 `.cpp`”又会让任意变化重编整个模块。推荐：

```text
每个函数 = 独立确定性 `.jit.inl` slice + manifest entry
每个 slice 按 LogicalFunctionKey 固定映射到 N 个 bucket
每个 bucket = 一个稳定 `.jit.cpp`，只 include 自己的 slices
```

- 未修改 slice 文件内容不变；
- 新增/删除/修改函数只触发对应 bucket；
- bucket 数作为模块生成配置并写入 manifest，改变 bucket 数视为生成布局变化；
- 生成器只能清理自己 manifest 记录的旧文件，不能宽泛删除项目目录。

### 2026-08-07 / 轮次 6：外置游戏模块边界

仓库已有 `NativeModuleFunctionAddress` 的可借鉴模式：版本化 POD view/table、`IModularFeatures` 注册/注销、Runtime 监听 provider 早到/晚到、layout version 文件和严格 malformed/version 校验。StaticJIT 外置模块应复用这种架构原则，但使用独立 feature 和 ABI，因为它还需要函数内容摘要、三入口、符号依赖与 route 生命周期。

建议边界：

```text
AngelscriptRuntime（插件）
  - 稳定身份/内容 fingerprint builder
  - versioned provider ABI 与 registry
  - manifest 校验、符号解析、route attach/detach
  - Editor hybrid VM fallback 与诊断
  - StaticJIT codegen 核心

<Project>AngelscriptStaticJIT（项目自有 Runtime 游戏模块）
  - 生成的函数 slices/buckets
  - 编译进模块的只读 manifest/provider table
  - provider StartupModule/ShutdownModule 注册
  - provider 自有 reference cells

AngelscriptEditor（插件）
  - 生成/刷新命令及 Editor UI/通知（若纳入首版）
  - 调用 Runtime codegen，不拥有执行路由
  - 可选地协调 UBT/Live Coding，但不能把未验证的 DLL 卸载当成安全能力
```

项目模块必须同时进入 Game 与 Editor target，且 Runtime 不能反向依赖它。provider 可能先于或晚于 AS 初始编译加载，两种顺序都必须测试。

首版不应允许任意卸载包含正在执行 Native frame 的 DLL。最小安全承诺是：已加载 provider 在本 Editor session 内常驻；AS 热重载只清除/重绑函数路由。Live Coding 可以负责发布新 generation，但 route 设计必须避免依赖“旧 patch DLL 永远不会卸载”这一未经约束的假设。

## 8. 架构候选（研究草案，待用户确认）

### 方案 A：模块级 Cache + 外置编译模块

保持当前 GUID/Cache 整体匹配，只把生成 `.jit.cpp` 搬进游戏模块，并在 Editor 特殊启动模式加载完整 Cache。

- 优点：改动最少，接近历史 `Plan_StaticJITOfflineGeneration.md`。
- 缺点：Editor 仍无法保留正常源码编译与热重载；任一脚本/依赖变化导致整代失效；没有真正函数路由。
- 判断：只能作为外置构建的过渡实验，不满足本次 Editor-first 目标。

### 方案 B：逐函数 manifest + Editor hybrid route（推荐）

Editor 正常编译 AS；Runtime 对每个当前函数计算稳定键/内容/环境指纹，与外置 provider manifest 匹配；命中后在 class-generation handoff 前附着三入口，失配函数保持 VM。Editor-hybrid 工件禁止无保护的脚本函数 direct-call，并使用动态 UASFunction wrapper。

- 优点：直接满足“未改函数 Native、修改函数 VM”；Cache 与 Native 工件职责解耦；外置模块可同时服务 Editor 和 Game。
- 缺点：需新增稳定 fingerprint、符号化 reference、route manager 与 hybrid codegen profile；跨脚本调用的安全路由会有性能成本。
- 判断：推荐作为正式设计主线。

### 方案 C：方案 B + 每次保存自动生成并触发 Live Coding

在逐函数路由之上，Editor 文件保存后自动生成变化 slice、触发编译并动态注册新 provider generation。

- 优点：修改函数也能在同一会话较快恢复 Native，体验最完整。
- 缺点：引入编译队列、失败恢复、DLL generation 共存、active Native frame、线程与卸载安全、Live Coding 平台差异；会显著扩大首版验证矩阵。
- 判断：Live Coding 后端本身应从首版设计，因为它影响符号版本和 provider ABI；“每次保存都自动触发”适合作为独立可选阶段，不应成为基础路由正确性的前提。

## 9. 当前推荐的首版验收语义

1. 启动 Editor 时加载已构建的项目 StaticJIT 模块；Editor 仍从当前 `.as` 源码进行正常初始编译。
2. 初始编译后逐函数匹配；命中函数走 Native，失配/不支持函数走 VM，并可查询原因。
3. 编辑 B 并成功 AS 热重载后，B 立即不再调用旧 Native；未修改且依赖仍兼容的 A 保持 Native。
4. 编译失败时旧 AS 模块与旧 Native 路由整体保持，不发生半提交。
5. 新 Native slices 在显式重新生成后，若当前 Editor 的 Live Coding 可用，则通过 Live Coding patch 在同一会话发布；失败时函数继续 VM。离线构建/重启始终是 fallback。
6. cooked/game 可继续使用完整 bootstrap Cache，但 Native 函数 manifest 不再依赖该 Cache 的 archive-local pointer token；最终是否让 cooked 也统一走逐函数 manifest，可分阶段迁移。
7. 诊断至少报告：provider generation、环境指纹、总函数数、Native 命中/VM fallback 数，以及每函数的 `identity-miss`、`content-miss`、`environment-miss`、`dependency-resolution-failed`、`unsupported-function-kind` 等原因。

## 10. 2026-08-08 / 轮次 7：UE Live Coding 可用性与安全边界

#### 已确认：Live Coding 对本方案直接有用

当前工作区指向的 UE 5.8 安装源码中，`ILiveCodingModule` 公开提供：

- `Compile()`；
- 带 `WaitForCompletion` 和结果枚举的 `Compile(Flags, Result)`；
- `IsCompiling()`；
- `GetOnPatchCompleteDelegate()`。

UE 在触发编译前会调用 `UpdateModules(false)`，把当前已加载模块交给 Live Coding；Patch 成功后，Editor 依次完成 UObject reload/reinstancing、`ReloadCompleteDelegate`、GC、`LiveCodingReload` delayed auto-registration，最后才广播 `OnPatchCompleteDelegate`。

因此它能承担：

```text
AS 热重载成功
  -> 修改函数先回退 VM
  -> 生成变更 slices/manifest
  -> ILiveCodingModule::Compile()
  -> UE 加载并应用 patch
  -> OnPatchComplete
  -> Runtime 重新获取 provider generation
  -> 校验当前 AS fingerprint
  -> 原子发布匹配的新 Native routes
```

Live Coding 解决的是“如何在不重启 Editor 的情况下，把已生成 C++ 变成可执行代码并装入进程”。它不替代稳定函数身份、内容摘要、引用解析、路由事务或 VM fallback。

#### 已确认：外置模块必须预先存在并在 Editor target 中加载

Live Coding 会维护 enabled/lazy-loaded module 列表，UBT 会拒绝修改当前未启用的受保护模块。UE 5.8 默认 preload project modules，但不能依赖 Live Coding 在一次普通 patch 中可靠地从零创建整个新 UE 模块。

所以需要一次性 bootstrap：

1. 先 scaffold `<Project>AngelscriptStaticJIT`；
2. 加入 Game 与 Editor target；
3. 预先生成固定数量的 bucket `.cpp`，允许初始为空；
4. 至少做一次离线 Editor build 并启动 Editor；
5. 此后只修改既有 bucket/source include 图和 manifest TU，交给 Live Coding 增量编译。

新增函数不应依赖在会话中新增一个全新的 `.cpp` 才能生效；它应进入预先存在的固定 bucket。这样既降低 UBT/Live Coding action 不确定性，也使生成布局可预测。

#### 新关键决策：逻辑符号稳定，Native 实现符号必须内容寻址

Live Coding 的职责是 patch 既有 C++ 符号。如果生成函数只用稳定 `LogicalFunctionKey` 命名，那么函数内容改变后，Live Coding 可能把旧入口原地跳转到新实现；Runtime 手中的“旧 Manifest + 旧内容摘要”就不再保证该地址仍执行旧内容，而且 public API 没有可用于预先撤销所有 routes 的 `OnPatchBegin` delegate。

推荐把两类名称分离：

```text
逻辑路由键：ASJIT_<LogicalFunctionKey>
实现符号：  ASJIT_<LogicalFunctionKey>_<FunctionContentDigest>
```

- AS 内容不变：实现符号不变，可复用已构建 Native。
- AS 内容改变：产生新实现符号；旧 route 仍指向旧符号，不被同名 patch 原地改写。
- Patch 完成：provider 发布新 manifest generation；Runtime 验证后才把新调用切到新符号。
- 已进入旧 Native 的 frame 可以完成；新调用走新 generation 或 VM。

这使 Live Coding 成为 generation publisher，而不是绕过 StaticJIT 路由的一次隐式函数替换。

#### Provider 不能只是一块被注册一次的静态 POD 内存

如果 Runtime 在 Editor 启动时只保存一个静态 manifest table 指针，Live Coding patch 后该指针不一定自动指向 patch DLL 中的新表。推荐 provider 暴露稳定的 versioned accessor/callback，例如“读取当前 manifest generation”，而不是让 Runtime 永久缓存 table 地址。

运行时在 `OnPatchComplete` 后：

1. 重新枚举/刷新全部 StaticJIT providers；
2. 调用 accessor 获取当前 generation view；
3. 完整校验 layout/environment/manifest；
4. 构建新的不可变 route snapshot；
5. 在安全点一次交换；
6. 不修改正在执行的 snapshot/entry storage。

外置模块的 `StartupModule()` 仍负责第一次注册；Live Coding patch 不要求重跑 `StartupModule()`。UE 的 `LiveCodingReload` delayed registration 可作为刷新辅助，但主设计优先使用一次注册的稳定 accessor + `OnPatchComplete` 主动刷新，避免重复 provider 注册。

#### Patch/生命周期限制

- 当前 UE 5.8 的标准 `ILiveCodingModule` public API只有 Patch 完成通知，没有 Patch 开始通知。因此不能靠公共 delegate 在任意手动 Live Coding 编译前抢先做路由失效；内容寻址实现符号是必要保护。
- Live Coding 内部确实存在 Patch DLL unload 命令，至少用于模块/session 卸载及失败 Patch 清理。成功 generation 的存活期不能只靠猜测，需要 provider 注销、Editor shutdown 和失败回滚测试。
- 首版不主动卸载旧 generation。Runtime 不持有已注销 provider/失效 patch 的裸入口；发布前后的 route snapshot 需要明确所有权/存活期契约。
- Live Coding 编译失败、取消、无变化或未启动时，不触碰当前有效 route snapshot；本轮已修改且内容失配的 AS 函数继续走 VM。
- 任意其他 C++ Live Coding patch 也会触发 `OnPatchComplete`。Runtime 应重新校验现有 provider/dependencies，而不是无条件认为只有 StaticJIT bucket 发生变化。

#### 平台与配置边界

UE 5.8 的 `bWithLiveCoding` 默认范围是 Win64 x64、非 Shipping/Test、非 Program target。StaticJIT 的 Editor 产品语义不能依赖所有平台都有 Live Coding：

- Win64 Editor：提供同会话 patch 后端；
- Live Coding 不可用的平台/配置：仍支持生成、离线构建、重启加载；
- cooked/game：不走 Editor Live Coding 协议。

#### 更新后的首版建议

把能力分为三个层级：

1. **必选正确性核心**：Editor 正常编译、逐函数 match、VM fallback、外置 provider、内容寻址实现符号；完全不依赖 Live Coding 也正确。
2. **首版建议包含**：显式 `Generate/Refresh StaticJIT` 命令调用 Live Coding；Patch 成功后同会话发布新 generation，失败保持 VM。
3. **可选自动化**：AS 保存后自动排队生成和 Live Coding；需要 debounce、编译队列、PIE/active script callback 安全点、失败通知与关闭开关。

这样 Live Coding 是首版可用的刷新后端，但“自动保存即编译”不是首版正确性的硬依赖。

## 11. 2026-08-08 / 轮次 8：函数粒度 Cache、首次启动生成与持续更新

#### 先区分两种“缓存”

用户提出的“第一次启动游戏生成，以后不断更新，PIE 和运行时都能加载”是可行方向，但必须区分：

1. **AS Data Cache**：预处理描述、声明/类型结构、AS bytecode、debug map 和符号依赖；这是普通数据，可在有源码和写权限的运行环境现场生成。
2. **Native StaticJIT Artifact**：由 `.jit.cpp/.jit.inl` 经 C++ compiler/linker 形成的机器码；普通 packaged game 第一次启动不能自行生成，除非目标机同时具备项目源码、UE headers、UBT、工具链和允许加载 patch 的平台能力。Editor 可以用 Live Coding 完成这一段。

因此统一加载模型可以覆盖 PIE 和运行时，但“现场生成”能力不同：

```text
PIE / Editor
  AS Data Cache：可读、可写、可增量更新
  Native Artifact：可生成 C++，可选 Live Coding 编译/发布

桌面 Development Runtime（带源码/开发环境）
  AS Data Cache：可读写
  Native Artifact：只有显式开发工具链模式才可能生成，不作为产品保证

Packaged Shipping / Console
  AS Data Cache：可加载随包 baseline；是否允许写本地 overlay 由平台/安全策略决定
  Native Artifact：只加载构建时已签名/已编译 provider，不在首启时生成机器码
```

#### 已确认：当前无 Cache 时本来就会回退源码编译，但不会回写

当前初始化逻辑只在非 Editor、非 development-mode 时设置 `bUsePrecompiledData`。若目标 Cache 文件不存在，`PrecompiledData` 保持 null，`InitialCompile()` 会扫描脚本、预处理并正常编译；也就是说“首启没有 Cache 仍可运行”已有基础。

缺少的是 write-through：普通源码编译成功后不会保存 Cache。当前保存只发生于 `-as-generate-precompiled-data` 模式，写到 Script root 的 `PrecompiledScript.Cache`，随后强制退出。这一路径面向构建/commandlet，不适合作为运行时可持续 Cache。

未来运行时 Cache 必须写入可写位置，例如：

```text
Saved/Angelscript/Cache/<ProfileKey>/
```

而不是覆盖 Content/Script/plugin/cooked package 中的 baseline。随包 Cache 是只读 baseline，本地生成的是 overlay。

#### 已确认：现有数据结构已经有“函数记录”，但不是独立可装载 slice

`FAngelscriptPrecompiledFunction` 已独立保存：

- 函数名、namespace、return/parameter types 和 traits；
- bytecode 与 bytecode reference positions；
- variable space、object variables、stack requirement；
-当前 `uint32 Id`；
- declared position 与 line numbers；
- UFUNCTION metadata 和反射 traits。

但它仍依赖顶层 `FAngelscriptPrecompiledData` 的：

- `TypeReferences` 与旧 type-id/pointer map；
- `FunctionReferences` 与旧 function-id/pointer map；
- global/property references；
- static name table；
- 模块级 class/enum/global/import 声明与三阶段 Apply；
- 单一随机 `DataGuid`。

所以当前格式是“顶层共享重定位字典里的函数子记录”，不能把单个 `FAngelscriptPrecompiledFunction` 直接另存文件并独立恢复。

#### 推荐：两层语义、三类物理工件

逻辑层拆为：

1. **Module Structure Layer**
   - 模块身份、imports、class/enum/global 声明；
   - UPROPERTY/UFUNCTION/metadata；
   - 类型和全局布局；
   - 函数签名目录、global-init 顺序、post-init；
   - `ModuleInterfaceDigest` / `TypeLayoutDigest`。

2. **Function Body Layer**
   - `LogicalFunctionKey`；
   - `FunctionContentDigest`；
   - canonical bytecode、局部布局与可选 debug map；
   - 稳定符号依赖描述；
   - `DependencyDigest`。

物理工件使用：

```text
CacheManifest
  - schema/profile/environment
  - committed generation id
  - module structure records
  - logical function -> content blob 映射

FunctionBlobStore / immutable packs
  - 按 FunctionContentDigest 内容寻址
  - 一个 blob 对应一个逻辑函数实现记录
  - 可被不同 manifest generation 复用

WritableOverlay
  - 只保存相对 shipped baseline 新增或替换的结构/blob
  - 原子发布新 manifest
```

“函数切片”应是逻辑和内容寻址单位，不建议“一函数一个松散文件”。脚本项目可能有成千上万函数，单文件会带来目录枚举、open handle、杀毒扫描和小文件开销。可使用固定 bucket pack 或 append-only blob pack，manifest 中保存 offset/size/hash；后台/下次启动再做 GC/compaction。

#### UUID 不应继续承担内容匹配

用户提出“UUID 对不上就重新生成”在**事务完整性**层面是对的，但若仍只有一个全局 UUID，会回到当前整盘失效问题。推荐四层身份：

| 层级 | 建议字段 | 失配动作 |
|---|---|---|
| 格式 | `CacheSchemaVersion` | 不能解析旧格式；切换新 cache namespace，按需重建 |
| 环境/Profile | `EnvironmentFingerprint` | 不跨 Editor/Game、平台、配置、bind surface 复用；选择/生成另一份 profile |
| 原子提交 | `ManifestGenerationId` + checksum | 发现 manifest/blob 不完整时拒绝这次 generation，回退上一代/baseline |
| 内容 | Module/Function/Dependency digests | 只失效对应结构 cluster、函数或依赖闭包 |

当前 `FGuid::NewGuid()` 生成的 `DataGuid` 可以演进成 `ManifestGenerationId`，用于确认“一份 Manifest 与其 blobs/provider 属于同一成功提交”，但不能再作为“所有内容是否相同”的唯一答案。

Native provider 还有独立 `ProviderGenerationId`。AS Data Cache UUID 失配不应让可用 bytecode和 Native 状态混为一谈：

- AS function blob 命中、Native provider 不命中：加载 bytecode，走 VM；
- AS function blob 和 Native provider 都命中：加载 bytecode/当前函数并附着 Native；
- AS function blob 不命中：从源码编译该函数/结构，随后再判断是否有匹配 Native；
- provider ABI/environment 失配：只拒绝 Native，不应阻止 AS 源码或 bytecode运行。

#### 增量失效不能保证永远只动一个函数

需要按修改类型分级：

| 修改类型 | 建议失效范围 |
|---|---|
| 只改函数体，签名/依赖契约不变 | 仅函数 blob；routed-call 模式下 caller 不必因 callee body 改变而失效 |
| 改函数签名/traits/default args | 新 LogicalFunctionKey；模块 interface record、importer/caller link 关系需要更新 |
| 改 class/property/type/global 布局 | module structure/type cluster，以及依赖这些布局的函数 slices |
| 改 import/preprocessor profile | 受影响模块和依赖闭包 |
| 改 UE/plugin/binding ABI | 由 Environment/Dependency fingerprint 精确或保守失效 |
| global init/post-init 顺序变化 | 首版按模块结构整体处理，不把匿名 init function 当独立可复用函数 |

这比“任意 UUID 失配全部重新生成”复杂，但正是函数粒度复用必须具备的边界。

#### 推荐的首次启动与持续更新流程

```text
1. 选择 CacheProfile
   WITH_EDITOR / preprocessor flags / platform / build config / bind surface 等进入 ProfileKey

2. 读取只读 baseline + Saved overlay manifest
   校验 schema、environment、generation checksum

3. 扫描当前源码/输入目录
   计算 module structure/interface digests 和源输入摘要

4. 构建类型/声明图
   命中结构 cache则恢复；失配部分从源码编译声明

5. 逐函数解析
   命中 content + dependency blob则恢复 bytecode；否则编译当前函数

6. 完成 imports/link/class generation
   整个 AS compile transaction 成功后才允许发布 cache

7. 原子写 overlay
   先写临时 blobs/pack和临时 manifest，校验后 rename/commit generation

8. 绑定 Native provider
   对当前函数再次匹配 provider；命中走 Native，否则 VM
```

- 首次启动无 Cache：全量正常编译，成功后生成第一代 Saved overlay；当前启动不必退出。
- 后续启动：复用结构和函数 blobs，只编译 miss。
- PIE/热重载：只在 AS reload transaction 成功后提交新 overlay；编译失败保持上一代 cache 和当前活跃模块。
- 进程在写 Cache 时崩溃：下一次启动忽略未提交 temp generation，继续使用上一代 manifest/baseline。
- 多 Editor/游戏进程并发：需要 writer lock 或 generation compare-and-swap；reader 永远只读已提交 immutable generation。

#### PIE 与运行时可以共用代码路径，不能无条件共用同一份内容

Editor/PIE 和 Game 的预处理条件、debug line cues、`WITH_EDITOR`、build config、binding surface 可能不同。应共用 `FAngelscriptIncrementalCacheService` 和格式，但通过 `CacheProfileKey` 分目录/namespace：

```text
Editor-Development-Win64-<BindSurface>
Game-Development-Win64-<BindSurface>
Game-Shipping-Win64-<BindSurface>
...
```

如果两个 profile 最终某些纯 bytecode blobs 的完整内容摘要相同，底层 content-addressed store 可以去重；上层 Manifest 不能假设它们天然兼容。

#### Shipping/runtime 的安全约束

Saved overlay 是不可信、可被用户修改的数据。加载时必须验证：

- record size/count 上限、hash/checksum、schema；
- 每个稳定符号依赖都在当前声明/绑定白名单中可解析；
- 不从数据 Cache 恢复或信任任意 Native 地址；
- Native 地址只能来自当前进程已加载、ABI 校验通过的编译模块/provider；
- 需要平台策略开关：某些 Shipping/Console 只允许签名 baseline，禁止本地生成 overlay；
- 若 Shipping 不随包携带 AS 源码，baseline miss 不能现场重编，必须报清晰的 packaging/build 错误，而不是假定首启一定可生成。

#### 与 Live Coding 的组合结果

最终可以形成两条互不绑死的增量链：

```text
AS Data Cache 链（PIE + Runtime）
当前源码 -> 增量编译 miss -> Function Blob/Manifest -> 下次/本次 VM 可执行

Native Artifact 链（Editor Live Coding / 构建机）
当前已编译函数 -> 生成 content-addressed C++ slice -> C++ build/patch
               -> Provider Manifest -> 当前函数 Native route
```

AS Data Cache 更新成功不要求 Native 更新成功。Live Coding 失败时，新函数仍通过当前 bytecode/VM 正确运行；下次 Native provider 匹配后再加速。

#### 当前判断

- “第一次启动生成，之后持续更新”对 AS Data Cache 是推荐方向，比要求用户总是提前运行全量 Cache commandlet 更适合 Editor-first 和桌面 Development。
- “UUID 不匹配重新生成”应保留为 schema/environment/事务损坏的粗粒度 fallback；正常脚本变化改用 module/function digests 做细粒度更新。
- cooked release 仍建议带一份构建机生成的只读 baseline，避免终端用户承担全量首次编译，也覆盖不携带源码或禁止本地写 Cache 的平台。
- Native StaticJIT 在普通 packaged game 中仍必须预编译；首次启动只能匹配/加载 provider，不能把 C++ source Cache 直接变成机器码。

## 12. 研究阶段待确认项（已由第 13 节定案）

原待确认项包括 baseline/overlay、Editor 显式刷新、Live Coding 可选性、legacy Cache 处置、跨函数路由和测试范围；它们均已在用户讨论与第 13 节中关闭，不再保留未决项。

## 13. 2026-08-08 / OpenSpec 拆分与定案

联合研究已经拆为两个可独立验收的 change：

- `refactor-as-incremental-function-cache`：稳定脚本实体/函数工件身份、Cache V2、类型/全局/函数增量命中、Saved-only generation store、首次启动生成、并行准备与原子提交。
- `refactor-as-static-jit-external-module`：外置 Provider、engine-owned route、Editor/PIE、Live Coding、UASFunction 安全分派。

依赖只发生在共享身份层：Cache change 先交付 `StableFunctionKey + FunctionContentHash + ArtifactProfileKey`，之后 Cache store 与 StaticJIT Provider 可以独立推进。Provider mismatch 不使 AS Cache 失效，Cache miss 也不要求生成 Native 工件。

用户确认的最终选择：

- 不兼容旧 `PrecompiledScript.Cache`，因为插件仍处于开发期。
- 外置模块名使用当前项目名称加 `AngelscriptStaticJIT` 后缀。
- 插件提供对应模块的 Scaffold/Generate/Verify 工具。
- Editor Native 更新采用显式 Generate/Refresh；普通保存先完成 AS hot reload，miss 走 VM。
- Cache 在 Editor/PIE/Development/Shipping 中以 loose source 为权威输入，第一次启动生成 Saved generation，之后持续增量更新；不再使用 packaged baseline/overlay 双根模型。
- 实施顺序为“稳定身份基础 → Cache store 与 StaticJIT Provider 分线”。

### Cache 多线程边界补充

当前 `CompileModules()` 已用 `ParallelFor` 调用 `BuildParallelParseScripts()`，但类型/函数生成、layout、`BuildCompileCode()`、globals、module swap 和 ClassGenerator 按一个 engine 的 transaction 顺序执行。因此 Cache V2 首版使用“并行准备、串行提交”：并行扫描、哈希、checksum、解压、纯数据校验、hit/miss 规划和 pack 准备；活动 AS engine restore/compile/swap 保持串行。首版不承诺同一 engine 内逐函数并行编译。

## 14. 2026-08-08 / Cache V2 策略修订（覆盖早期 Cache 候选）

本节覆盖本研究第 5—13 节中与 AS Data Cache baseline/overlay、source-free Shipping 和 whole binding profile 有关的早期候选；那些段落保留为研究历史，不再是实现要求。StaticJIT 外置模块、Provider、Editor/PIE 路由和 Live Coding 的既有结论不变。

- Cache V2 只写 `Saved/Angelscript/CacheV2/<CompatibilityKey>/<ContextKey>/`；不存在 packaged read-only baseline。
- Development 与 Shipping 都携带 loose、可外部修改的 `.as`，第一次启动编译并发布 generation，后续按 source/module/type/global/function 依赖增量更新。
- 当前 source 与 generation 不同且 fresh compile 失败时，不运行不同-source 的旧 generation。
- Cache 逻辑记录分为 SourceIndex、ModuleInterface、TypeSchema、ModuleState、FunctionBody、DebugSidecar，并由 ModuleSnapshot 原子装配；物理上聚合到 pack，不是一函数一文件。
- 根 Profile 不包含完整 binding-surface hash；Cache 与 StaticJIT entry 都通过实际使用的 environment-symbol ABI fingerprints 做局部失效。
- 共享身份使用完整 BLAKE3-256；StaticJIT bucket 直接取稳定 key 的固定字节，不再对 key 二次 SHA-256。
- StaticJIT 只消费 `StableFunctionKey + FunctionContentHash + ArtifactProfileKey`。Provider/Live Coding 失败仍只回退 VM，不影响 AS Cache generation。
