# RT_StaticJIT — 统一 JIT 协调器、StaticJIT 与 Runtime JIT

> **所属前缀**：RT_（运行时子系统）
> **适用版本**：Unreal AngelScript 1.0.0，Static Provider ABI Revision 2，Runtime Backend ABI Revision 2
> **关注范围**：统一 JIT 协调器、StaticJIT 的 C++ 生成、可选 Runtime JIT、Provider/Backend 注册、Engine 路由、Cache V2 协作、Editor/PIE 与 Live Coding、DLL 生命周期和诊断。
> **不再适用的旧概念**：`FJITDatabase`、`FStaticJITCompiledInfo::ActiveInfo`、按瞬时 FunctionId 注册、`DataGuid` 整盘配对、`PrecompiledScript.Cache` 与 `.jit.hpp` 成对加载。这些兼容路径已删除，不能再用来解释当前实现。

## 一句话理解

当前 JIT 可以先理解成两个彼此独立的原生代码来源，再由每个 Engine
自己的协调器统一选择：

1. **StaticJIT / AOT**：生成侧把已经编译成功的 AngelScript 函数翻译成普通 C++，并严格按“一个 AS 模块一个 `<源文件名>.<短模块键>.<TargetProfile>.jit.cpp`”落盘；承载模块再把编进 DLL/EXE 的入口作为 Provider 发布。
2. **Runtime JIT**：可选 backend 插件为每个 Engine 创建独立 session，消费不含 Engine 指针的只读字节码快照，返回当前函数版本专属的 `VMEntry + CodeLease`；结果只在版本仍完全一致时发布。

每个 `asIScriptEngine` 只安装一个 `FAngelscriptJITCoordinator` 作为
`asIJITCompiler`。`Auto` 模式逐函数按“精确 Static AOT → 已发布 Runtime
JIT → VM”选择；两个 backend 体系不会互相替换 compiler，也不共用一个
含糊的 backend 基类。

所以这里虽然沿用 `StaticJIT` 名称，本质上是 **静态 AOT 代码生成 + 运行期稳定身份路由**，不是 LLVM、asmjit 那种运行时生成机器码的传统 JIT。
TypedASTJIT 在有密封 AST 快照时可以消费它；HIR oracle 仍在，生产默认不捕获 sidecar HIR。匹配 profile 的 Generate 租用主引擎已编译图/AST，不会为同一 profile 另起编译引擎。
Runtime JIT 才是运行进程内生成可执行代码的扩展点，但首版只支持保守的
whole-function `VMEntry`，不生成 Raw/Parms 入口，也不进入 Cache V2 或
Static Provider。

## 核心链路

```text
.as 源码
  │
  ├─ 预处理、编译、Cache V2 恢复
  │      产生当前 Engine 权威的模块/函数和稳定身份
  │
  ├─ Generate
  │      每个 AS 模块生成一个 <AS相对目录>/<源文件名>.<短ModuleKey>.<Profile>.jit.cpp
  │      Provider.generated.cpp/.h 汇总入口与稳定元数据
  │
  ├─ UBT/C++ 编译
  │      产物进入 AngelscriptJIT 或 AngelscriptTestJIT 的 DLL/EXE
  │
  ├─ UE 模块 StartupModule
  │      以 IAngelscriptJITArtifactProvider 注册 Modular Feature
  │
  ├─ Runtime Registry
  │      校验 Provider ABI，复制成不可变 Catalog，发布 Snapshot
  │
  └─ Engine Router::Refresh
         当前函数 + Provider entry 完全匹配 -> Native
         任一条件不匹配/引用无法解析/出现歧义 -> 该函数 VM
```

可选 Runtime JIT 是另一条链：

```text
当前 Engine 的 verified function route
  -> Coordinator 在 Engine 线程复制 immutable compile snapshot
  -> 选定 Runtime factory 为该 Engine 创建 session
  -> session 同步/后台/首次调用时编译
  -> Coordinator 校验 BackendId、Engine namespace、函数 revision、
     Entry ABI 与 cancellation generation
  -> exact result 在 Engine safe point 发布 VMEntry + CodeLease
  -> unsupported/stale/cancelled/backend failure 保持 VM
```

这里最重要的边界是：

- `.as` 编译结果或 Cache V2 恢复结果始终是当前 Engine 的权威状态；
- Provider 只提供“这个精确函数版本可以调用哪些原生入口”；
- Provider 不能替换当前脚本模块、类型、函数或 Cache V2；
- 数字 FunctionId、对象地址、注册顺序和 Cache 创建顺序都不是跨进程身份。

## 关键源码

| 职责 | 入口 |
|---|---|
| 字节码到 C++ 翻译 | `AngelscriptRuntime/StaticJIT/AngelscriptStaticJIT.*`、`AngelscriptBytecodes.*` |
| 生成模型与严格模块分组 | `AngelscriptJITGeneration.*` |
| 原子写入、owned-file 管理、未变化文件保留 | `AngelscriptJITGeneratedFileStore.*` |
| Provider ABI | `AngelscriptJITProvider.*` |
| 多 Provider Registry | `AngelscriptJITProviderRegistry.*` |
| Provider 与当前 Engine 路由匹配 | `AngelscriptJITProviderMatcher.*`、`AngelscriptJITProviderRouter.*` |
| 每 Engine 唯一 JIT 协调器与 tier 选择 | `RuntimeJIT/AngelscriptJITCoordinator.*`、`AngelscriptJITConfiguration.*` |
| Runtime backend 公共 ABI | `Public/JIT/AngelscriptRuntimeJITBackend.h` |
| Runtime factory/session 发现 | `RuntimeJIT/AngelscriptRuntimeJITBackendRegistry.*` |
| Runtime immutable snapshot | `RuntimeJIT/AngelscriptRuntimeJITSnapshot.*` |
| Runtime 请求、取消和发布状态机 | `RuntimeJIT/AngelscriptRuntimeJITState.*` |
| Runtime host 调用与代码租约 | `RuntimeJIT/AngelscriptRuntimeJITBindingContext.*` |
| 稳定引用解析 | `AngelscriptJITReferenceResolver.*` |
| binding 执行与生命周期 | `AngelscriptJITBindingContext.*`、`AngelscriptJITExecutionContext.*`、`AngelscriptJITProviderLifetime.h` |
| 统一/Runtime 诊断 | `RuntimeJIT/AngelscriptJITDiagnostics.*` |
| Static AOT 专用诊断 | `StaticJITDiagnostics.*` |
| 项目生成/校验 Commandlet | `AngelscriptEditor/StaticJIT/AngelscriptJITProjectGeneration.*`、`AngelscriptJITCommandlet.*` |
| Editor 显式刷新 | `AngelscriptEditor/StaticJIT/AngelscriptJITRefreshService.*` |
| 项目 Provider 载体 | `Source/AngelscriptJIT/` |
| 固定测试 Provider 载体 | `Plugins/Angelscript/Source/AngelscriptTestJIT/` |

## 0. 统一协调器和两套独立 backend 契约

### 0.1 为什么不能让每个 backend 自己安装 compiler

maintained AngelScript fork 的一个 `asIScriptEngine` 同时只能持有一个
`asIJITCompiler`。如果 StaticJIT、MIR 和 LLVM 插件都调用
`SetJITCompiler()`，后加载的模块会覆盖先加载的模块，执行结果会依赖 UE
模块加载顺序。

现在只有 Engine 拥有的 `FAngelscriptJITCoordinator` 可以安装到
`asIScriptEngine`。它接收 function-ready/release 回调，维护 Engine-local
Runtime 请求状态，在 safe point 发布 binding，并和 Static Provider Router
共同决定最终 tier。Static 字节码/Typed AST 生成器仍是一次生成任务里的
普通同步对象，不再假装成 live Engine compiler。

### 0.2 Static 与 Runtime 为什么必须分开

| 维度 | Static backend | Runtime backend |
|---|---|---|
| 用途 | 构建期生成 C++ 和 Provider artifact | 进程内为一个 Engine 编译可执行入口 |
| 契约可见性 | Runtime 模块私有 `IAngelscriptStaticJITBackend` | 导出的版本化 factory/session ABI |
| 初始 BackendId | `bytecode`、`typed-ast` | 插件自有，例如 `angelsea-mir`、`angelsea-llvm` |
| 输入 | 同步 complete source graph + 独立 emit set | 当前函数的 owned immutable bytecode snapshot |
| 输出 | C++ body、稳定引用和逐函数实际 backend | whole-function `VMEntry`、诊断和 `CodeLease` |
| 生命周期 | UBT 编译后随 Provider DLL/EXE | 随 Engine session、函数 revision 和 reader lease |
| 持久化 | Provider artifact/manifest | 不进 Cache V2，不发布为 Provider，不落盘 |

Static `typed-ast` 请求要求 generation Engine 已捕获 verified typed HIR；其
逐函数后备链是 `typed-ast → bytecode → VM`。生成器的 pointer-free output
记录 requested BackendId、capture profile、fallback chain，以及每个函数的
actual BackendId/disposition 和按顺序保留的 backend attempt/reason，便于
TypedASTJIT 和 BytecodeJIT 做一致性测试。

TypedASTJIT 是对 BytecodeJIT/VM 的补充，不是替换，也不是 Runtime JIT。
它只消费同一次源码编译得到的内存 HIR，不回读 `.hir.txt` / `.hir.json`。
生产环境没有 `dual` backend。普通调用实参按 AngelScript 的反向形式参数
顺序物化，不是从左到右；变异目标只求值一次。循环/switch 保留显式阶段和
转移目标。位置帧不是 debugger / coverage / loop-timeout 对等能力。直接
递归需要 native frame 预算。`bExceptionThrown` 只是快路径，不是完整公共
异常 payload。cleanup plan 必须显式、反向、只覆盖当时仍存活的槽；不能把
C++ 词法作用域当成 AngelScript 清理。当前源级 `try` / `catch` 仍被拒绝。
可变全局和 import 槽需要生命周期路由。native-form 显示名本身不能证明跨
DLL 可链接：`HeaderInline` 才直接嵌入符号；非 inline 导出走
`CurrentNativeBinding` / `InvokeBoundNative`；未导出标量走
`InvokeBound` → `InvokeBoundViaVM`。

### 0.3 generation-only Engine 做什么

Static 生成不借用当前 Editor Engine，也不会创建第二套脚本 UObject。每次
生成任务创建 `StaticJITGeneration` purpose 的临时 Engine：完整重放 sealed
native Bind、编译完整 source graph、执行纯 descriptor/Entry Plan 分析，随后
只把 emit set 中的模块交给 backend。

这个 Engine 不安装普通 primary context、DebugServer、CodeCoverage、测试
发现、热重载路由或全局 editor/package cache；不创建脚本 `UClass`、
`UFunction`、CDO，也不做 reinstancing、redirect 或默认对象初始化。backend
可在同步调用期间查看该任务的 Engine-local handle，但输出和异步工作只能
保留稳定键、hash、声明、布局等 pointer-free 值。

### 0.4 执行模式、Runtime 策略和五条执行路径

执行模式：

- `Auto`：精确 Static AOT 优先，其次已配置 Runtime JIT，最后 VM；
- `VMOnly`：绕过两种原生 tier；
- `StaticAOTOnly`：只允许 Static AOT，否则 VM；
- `RuntimeOnly`：绕过 AOT，只尝试 Runtime JIT，否则 VM，主要用于差分测试和基准。

Runtime 编译策略：

- `EagerSync`：第一个 authoritative route-ready safe point 同步编译、校验并发布；
- `EagerBackground`：先保留 VM，后台编译，结果只能在之后的 Engine safe point 发布；
- `LazyFirstCall`：首次调用只负责 claim/编译，并继续走它已经保留的 VM；后续调用才能看到新入口。

从实际调用入口看共有五条路径：

1. 普通 AngelScript VM；
2. Static AOT `VMEntry`，由 VM 调用生成的 C++；
3. Static AOT `RawEntry`，满足原生 ABI 时直接调用；
4. Static AOT `ParmsEntry`，由 `UASFunction`/反射参数块进入；
5. Runtime JIT `VMEntry`，先经过 Runtime host trampoline 统计执行并保住 binding/code lease，再进入 backend 代码。

首版 Runtime JIT 是 whole-function 加速器。只要函数包含不支持的调用、
managed lifetime、对象 receiver、suspend/latent、exception cleanup，或 Entry
ABI 不匹配，就整函数保持 VM。Debugger 或 CodeCoverage 需要字节码可见性
时也只 gate Runtime tier；既有 Static AOT 调试语义不因此改变。

进程配置项为：

```text
-as-jit-mode=auto|vm|aot|runtime
-as-runtime-jit-backend=none|<backend-id>
-as-runtime-jit-compile=eager-sync|eager-background|lazy-first-call
```

非法 execution mode 确定性退到 `VMOnly`。非法/未知 Runtime BackendId 或
compile policy 只关闭该 Engine 的 Runtime 编译，不会清掉本来 exact 的
Static AOT。

## 1. 为什么严格一个 AS 模块一个 `.jit.cpp`

### 1.1 当前目录布局

项目 Provider 的真实生成目录是：

```text
Source/AngelscriptJIT/Generated/
├── Provider.generated.h
├── Provider.generated.cpp
├── EditorDevelopment/
│   ├── Provider.generated.h
│   ├── Provider.generated.inl
│   ├── ProviderManifest.generated.json
│   ├── OwnedFiles.generated.json
│   ├── Tests/Test_Handles.07a7af43.EditorDevelopment.jit.cpp
│   └── Examples/Core/Example_Math.7fca3709.EditorDevelopment.jit.cpp
├── GameDevelopment/
│   └── ……同样按 AS 源码目录组织……
└── GameShipping/
    └── ……同样按 AS 源码目录组织……
```

当前 Profile：

- `EditorDevelopment`
- `GameDevelopment`
- `GameShipping`

`Provider.generated.*` 是 UE Provider 汇总表，不代表某个 AS 模块。`ProviderManifest.generated.json` 和 `OwnedFiles.generated.json` 是元数据，也不属于 AS 模块翻译单元。因此“一个 AS 模块一个 `.jit.cpp`”约束只针对按 AS 源码目录生成的翻译源文件。

路径映射规则是：

- `/Angelscript/Game/Tests/Test_Handles.as` → `EditorDevelopment/Tests/Test_Handles.<短键>.EditorDevelopment.jit.cpp`；
- `/Angelscript/Plugin/MyPlugin/Foo/Bar.as` → `<Profile>/Plugin/MyPlugin/Foo/Bar.<短键>.<Profile>.jit.cpp`；
- 内存模块 → `<Profile>/Memory/<Provider>/...`。

### 1.2 可读文件名和完整稳定身份怎样配合

文件名使用“AS 源文件 stem + 稳定模块键短前缀 + Profile”。短键默认取 8 个十六进制字符；如果整个生成集合里出现不区分大小写的 basename 冲突，就确定性地扩到 12、16 位，直到唯一。这样既能一眼看出对应哪个 `.as`，又能避免同名模块和 UBT 把不同目录的 `.cpp` basename 压平时产生对象文件冲突。

短键只用于物理文件名。完整 256 位 `StableModuleKey` 仍保存在文件头和 manifest，内部 C++ symbol 仍是完整 `ASJIT_<StableFunctionKey>_<ExecutionHash>...`，没有缩短。每个 `.jit.cpp` 的 revision-2 ownership marker 仍是第一行，随后有模块元数据块；每个函数还有声明、虚拟源位置、完整函数键与各类 hash，并在 Raw/VM/Parms 入口正上方重复一行易读的 AS 函数/源位置注释。

完整稳定键继续避免：

- 两个挂载点或插件里出现同名模块；
- 路径大小写、重命名和特殊字符影响 UBT；
- 生成顺序变化导致文件重排；
- 瞬时模块地址或 FunctionId 泄漏到持久化产物。

manifest schema revision 3 同时保存 canonical module/source 和每个函数的声明、行列号；ownership revision 与 Provider ABI 仍分别保持 2。

### 1.3 一个 AS 函数改动时会发生什么

假设 `Inventory.as` 所属稳定模块键为 `abc...`：

```text
修改前：Tests/Inventory.abc12345.EditorDevelopment.jit.cpp
修改后：Tests/Inventory.abc12345.EditorDevelopment.jit.cpp
```

函数 body、常量或该模块内部内容改变时：

1. 文件路径不变；
2. 生成器只重写这个模块文件和必要的 Provider 元数据；
3. 其他 AS 模块的 `.jit.cpp` 字节和时间戳保持不变；
4. UBT 增量构建只需编译这个 `.jit.cpp`，再链接它所属的 UE Provider 模块；
5. 新 DLL/patch 发布前，改动函数因内容摘要不匹配回退 VM；未改函数仍可 Native；
6. 新一代 Provider 成功发布并刷新路由后，改动函数恢复 Native。

若新增或删除了整个 AS 模块，生成目录下的 C++ 源文件集合也会变化。UBT/Live Coding 不能把未进入当前 target action graph 的全新源文件安全补进来，因此这类变化要求一次普通完整构建。

旧的 `Private/Generated/<Profile>` 和 `Private/Generated/Profiles/<Profile>` 只由 Generate 迁移：Verify 只读报告 stale；Generate 必须先验证 revision-2 inventory、Profile、ProviderId 和每个现存清单文件的 ownership marker，之后只删除清单列出的文件。旧的固定模块源码与 selector 由 Scaffold 在内容完全匹配受管模板时迁到模块根及 `Generated/`。清单无效、文件被用户替换或混入非 owned 内容时会拒绝迁移并原样保留。迁移改变 UBT source set，必须普通构建，不能直接 Live Coding。

### 1.4 全局函数放在哪里

全局函数完全支持 StaticJIT。它与类方法一样，根据**所属 AS 模块**进入该模块唯一的 `.jit.cpp`。

“类图不能放全局函数”的意思只是 UML 表达规则：全局函数不属于某个类，所以不要为了画图硬塞进类框。可以这样表示：

```text
AS 模块 Inventory
├── 全局函数 CreateInventory()
├── 全局函数 FindItem(...)
├── class UInventoryComponent
│   ├── AddItem(...)
│   └── RemoveItem(...)
└── class FInventoryEntry
    └── IsValid()

生成结果：Inventory 对应的唯一 Inventory.<短StableModuleKey>.<Profile>.jit.cpp
```

生成拓扑按模块，不按“全局函数/类方法”分类，也不按类拆文件。

## 2. JIT 函数怎样注册

### 2.1 不再注册进一个全局 Database

旧实现依赖静态构造器把 `FunctionId -> 原生指针` 写进 `FJITDatabase`，再用 whole-cache `DataGuid` 判断整盘能不能用。它存在几个根本问题：

- FunctionId 是当前 Engine 的瞬时编号，跨启动、编译顺序和 Cache 恢复不稳定；
- 一个进程里很难安全容纳项目、插件、测试和 Live Coding 多个 Provider；
- 全局表无法自然描述 DLL 卸载和旧代码仍被执行中的生命周期；
- 一个函数变化可能迫使整盘 JIT 清空。

当前实现改为 UE Modular Feature：每个承载生成代码的 UE 模块实现 `IAngelscriptJITArtifactProvider`。

项目载体 `Source/AngelscriptJIT/AngelscriptJITModule.cpp` 的核心行为等价于：

```cpp
class FAngelscriptJITModule
    : public IModuleInterface
    , public IAngelscriptJITArtifactProvider
{
    void StartupModule() override
    {
        IModularFeatures::Get().RegisterModularFeature(
            IAngelscriptJITArtifactProvider::FeatureName(), this);
    }

    void ShutdownModule() override
    {
        IModularFeatures::Get().UnregisterModularFeature(
            IAngelscriptJITArtifactProvider::FeatureName(), this);
    }

    const FAngelscriptJITProviderView*
    GetAngelscriptJITProviderView() const override
    {
        return GetCurrentGeneratedAngelscriptJITProviderView();
    }
};
```

Provider View 包含：

- ABI Revision；
- 稳定 `ProviderId`；
- 内容派生的 `ProviderGeneration`；
- 完整 artifact-set digest；
- Target Profile 与 native environment fingerprint；
- Provider/Owner UE 模块名；
- 按稳定模块键、稳定函数键排序的 entry 表；
- 每个 entry 的 execution/debug/entry ABI 摘要；
- VM、Raw、Parms 三种原生入口；
- 所需的稳定引用槽描述。

### 2.2 Registry 做什么

`FAngelscriptRuntimeModule::StartupModule()` 启动 `FAngelscriptJITProviderRegistry` 的 Modular Feature 发现。Registry 同时处理：

- Runtime 启动前已经注册的 Provider；
- Runtime 启动后新加载的 Provider；
- Provider 模块卸载；
- Live Coding 发布的新一代 Provider。

注册时 Registry 会完整校验 ABI、结构大小、数量上限、稳定键、摘要、排序、重复项、引用槽和 artifact-set 一致性，然后**复制** Provider View，形成 Runtime 自己持有的不可变 Catalog。运行时不会长期借用生成模块的 view 数组。

每次接受注册、替换或卸载，Registry 都发布新的不可变 Snapshot，并增加 `PublicationOrdinal`。读取者拿共享快照，不依赖 UE 模块加载顺序。

同一个 `ProviderId` 被不同 owner 冲突注册，或者不同 Provider 都对同一函数声称 exact，都会 fail closed；不会“后注册者覆盖前注册者”。

## 3. Engine 初始化时怎样消费

### 3.1 当前 Engine 状态先成为权威

Engine 的初始编译有两种来源：

- 从当前 `.as` 源码编译；
- 从 Cache V2 恢复完全匹配的记录。

无论来源是哪一种，最终都先建立当前 Engine 私有的模块、函数、类型、引用和稳定 route snapshot。Provider 不能跳过这一步。

### 3.2 Router 逐函数匹配

成功初始编译/恢复之后，Engine 调用：

```cpp
FAngelscriptJITProviderRouter::Refresh(*this);
```

热重载成功后也会在结构变更 guard 释放、post-compile consumer 运行前刷新。

对每个当前函数，Router 检查：

1. 稳定 ModuleKey；
2. 稳定 FunctionKey；
3. ExecutionHash；
4. 需要时的 DebugHash；
5. Target Profile；
6. Native environment fingerprint；
7. Entry ABI；
8. Provider artifact set 完整性；
9. 稳定引用槽能否在**当前 Engine**唯一解析；
10. 是否只有一个无歧义的 exact Provider。

全部通过后，Router 构造包含入口、引用槽和代码生命周期 lease 的完整 immutable binding，并一次发布给当前 `asCScriptFunction`。否则该函数保持或回退 VM，同时记录类型化 mismatch reason。

### 3.3 VM、Raw、Parms 分别是什么

| 入口 | 典型消费者 | 作用 |
|---|---|---|
| `VMEntry` | AngelScript VM 调用脚本函数 | 从 VM 栈/寄存器进入生成代码 |
| `RawEntry` | 满足 ABI 的原生直调路径 | 避免通用 VM 分发 |
| `ParmsEntry` | `UASFunction`、反射/FFrame 参数块 | 从 UE Parms 内存进入生成代码 |

三者属于一个 binding 快照，不能分别写入并形成半更新状态。函数替换、模块丢弃、compiler 更换或卸载时，由 `asCScriptFunction` 的统一 binding 生命周期安全退休。

### 3.4 为什么不能直接按 FunctionId 查

FunctionId 只用于当前进程诊断上下文。以下情况都可能改变它：

- 模块编译顺序变化；
- Cache V2 恢复顺序变化；
- 热重载创建新函数版本；
- 两个 Engine 以不同顺序创建；
- 函数删除后编号复用。

因此 Provider 只发布稳定键，Router 在每个 Engine 内重建“稳定键 -> 当前函数对象/FunctionId”的本地关系。两个 Engine 可以共享同一份 Provider Catalog，但绝不共享 Engine-local 指针或解析后的引用槽。

## 4. Stable Reference Slot

生成代码可能需要引用：

- 另一个脚本函数；
- 脚本或原生类型；
- 脚本属性/全局存储；
- 字符串字面量；
- import；
- Runtime helper；
- 最终初始化后的 UE 环境符号。

Provider 中只存指针无关的 `FAngelscriptArtifactReference` 描述。Router 刷新时把描述解析成当前 Engine 的 immutable slots，再交给生成入口使用。

`EnvironmentSymbol` 的解析当前采用一次批量索引：先收集本轮请求的稳定键，再单次遍历当前 UClass、注册类型/属性和脚本函数。它不会为每个引用重复扫描整个 Engine，也不会把进程指针缓存到下一轮或另一个 Engine。

最新基准中，46 条 route/37 个稳定引用的这部分从约 12.1–12.5 秒降到约 0.70–0.76 秒，减少约 94.3%。

## 5. Cache V2 与 StaticJIT 的关系

两者共享稳定 artifact identity，但职责不同：

```text
Cache V2：恢复“当前脚本是什么”
Provider：提供“这个精确脚本函数是否有原生入口”
Router：证明两者一致，并把入口挂到当前 Engine
```

Cache V2 不保存 Provider 代码指针；Provider 也不保存 Cache V2 的瞬时 FunctionId。Cache 命中不等于一定 Native，Provider 存在也不等于可以绕开脚本恢复。

典型结果：

| 当前状态 | Cache | Provider | 路由 |
|---|---|---|---|
| 源码、Profile、环境、ABI 全匹配 | 命中或源码编译 | exact | Native |
| 一个函数 body 改动 | 该函数重新编译/失效 | 旧 entry content mismatch | 该函数 VM |
| 另一个未改函数 | 仍有效 | exact | 仍 Native |
| Provider DLL 未加载 | Cache 可正常恢复 | 无 entry | VM |
| Cache 关闭/无缓存 | 源码正常编译 | exact | 仍可 Native |

这也是修复 Cache 问题时必须保持的边界：Cache V2 负责内容恢复和依赖失效，StaticJIT 只负责精确 Native 绑定，不能重新引入 whole-cache GUID 耦合。

## 6. Editor、PIE、热重载与 Live Coding

### 6.1 Editor 现在可以消费 StaticJIT

旧文档里“Editor 永远禁用 JIT”“StaticJIT 与热重载无关”的说法已经失效。当前 `EditorDevelopment` Provider 可以在 Editor/PIE 中被发现和路由。

普通 `.as` 保存仍只做：

1. AS 源码重编译；
2. ClassGenerator/热重载处理结构变化；
3. StaticJIT route 失效和重新匹配；
4. 改动函数在新原生代码到来前走 VM。

系统**不会**每保存一次 `.as` 就自动生成 C++ 并触发 Live Coding。这样可以避免保存风暴、重复链接和编辑器不可预测停顿。

### 6.2 显式 Generate/Refresh

Editor 显式动作由 `FAngelscriptJITRefreshService` 承担：

1. 先编译权威 AS 源码；
2. 为 `EditorDevelopment` 生成 owned files；
3. 判断 `.jit.cpp` 源文件集合是否已经属于当前 target；
4. 集合未变化且 Live Coding 可用时，请求 patch；
5. patch 完成后只接受**严格更新**且 ABI/Profile/环境兼容的新 ProviderGeneration；
6. 刷新 Router；新 entry exact 的函数恢复 Native。

以下情况要求普通完整构建，并继续保持 VM 正确性：

- 第一次 scaffold 后尚未完成完整构建；
- 新增或删除 AS 模块，导致 `.jit.cpp` 源文件集合变化；
- Live Coding 不可用、正在编译或 patch 失败；
- patch 没有产生严格更新的兼容 Provider；
- AS 本身编译失败。

### 6.3 结构变化谁负责

StaticJIT 只绑定“新权威编译代里确实存在、身份完全匹配”的函数，不接管 UObject/UClass 结构变更。

- 类布局、继承、属性、函数签名变化：仍由 AS 编译、ClassGenerator 和 ClassReloadHelper 处理；
- 函数执行内容变化：Router 用 ExecutionHash 决定旧 Native 是否还能用；
- whitespace/debug-only 变化：根据 execution/debug identity 和 entry flags 决定是否保留 Native；
- 删除函数：新 route snapshot 中没有该函数，旧 binding 随旧函数版本退休。

### 6.4 怎样做一次真实 Editor Live Coding 验收

这项测试不是只看“C++ 编译成功”，而是验证同一个 Editor 进程里的完整状态迁移：

```text
正常构建的 AS/JIT 内容一致
  -> Native / Exact
临时修改一个 AS 函数 body，旧 Provider 仍在
  -> VM / ContentMismatch
显式 EditorRefresh 生成 C++ 并完成 Live Coding
  -> 新 ProviderGeneration
Router 重新匹配
  -> Native / Exact
```

为什么一定要看三段状态：

- 第一段证明基线 DLL 真的装载并被 Router 消费，而不是一开始就在 VM；
- 第二段证明旧原生代码不会错误执行新脚本，即 fail-closed 生效；
- 第三段才证明 Live Coding 后运行中 Provider、Registry 和函数 binding 都换成了新代；
- `Live coding succeeded` 只证明 UE 编译/链接/patch 流程返回成功，不能代替第三段的 Provider/Route 证据。

这套验收采用“由小到大”的测试分层：

1. **契约单测**：先用假 Provider/假 patch backend 精确复现一个规则，例如旧 generation 替换、代码镜像 lease、Provider owner 交接和失败错误码；
2. **编译门禁**：确认 Runtime、Editor、生成器和测试模块的接口同时成立；
3. **相关前缀回归**：把 ProviderRegistry、MultiProvider、RefreshService、Cache/EditorRouting 等相邻行为一起跑，防止局部修复破坏冲突拒绝或 VM fallback；
4. **真实进程状态迁移**：在一个 `UnrealEditor.exe` 进程中观察 Native → VM → Native，而不是把“Live Coding 编译成功”当作最终结果；
5. **恢复与复验**：恢复 AS 源码后重新 Generate、Build、Verify，证明测试临时内容没有留在生成 C++ 或 DLL 中。

这种顺序的关键是：单测负责快速定位规则，真实 Editor 负责证明 UE/Live++/DLL/Registry 的组合行为，JSON 负责给出可重复、可机器判断的最终结论。

推荐选一个**只改函数 body**的探针，保持 AS 模块名、函数声明和 `.jit.cpp` 文件集合不变。新增/删除 AS 模块会改变 UBT 源文件集合，本来就应走普通完整构建，不属于这个 smoke。

先建立匹配基线：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile EditorDevelopment
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label static-jit-livecoding-baseline -TimeoutMs 1800000 -NoXGE
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Verify -Profile EditorDevelopment
```

临时编辑 `.as` 后，以真实 `UnrealEditor.exe` 启动一次隐藏的完整 Editor。核心参数如下：

```powershell
$exec = "as.StaticJIT.DumpDiagnostics -Function=<FunctionKey> -Output=<before.json>,as.StaticJIT.EditorRefresh,as.StaticJIT.DumpDiagnostics -Function=<FunctionKey> -Output=<after.json>,QUIT_EDITOR"
$arguments = @(
    '<Project>.uproject',
    '-LiveCoding', '-Unattended', '-NoPause', '-NoSplash',
    '-stdout', '-FullStdOutLogOutput', '-UTF8Output',
    '-NOSOUND', '-NullRHI',
    '-ABSLOG=<Editor.log>',
    "-ExecCmds=$exec"
)
$startInfo = [System.Diagnostics.ProcessStartInfo]::new()
$startInfo.FileName = '<UE>/Engine/Binaries/Win64/UnrealEditor.exe'
$startInfo.UseShellExecute = $false
$startInfo.CreateNoWindow = $true
foreach ($argument in $arguments) {
    [void]$startInfo.ArgumentList.Add($argument)
}
$process = [System.Diagnostics.Process]::Start($startInfo)
$process.WaitForExit()
if ($process.ExitCode -ne 0) { throw "Editor smoke failed: $($process.ExitCode)" }
```

Windows 上这里有五个容易误判的点：

1. 用 `ProcessStartInfo.ArgumentList` 保留每个参数的真实边界；`-ExecCmds` 自身包含空格，`Start-Process -ArgumentList` 可能重新拼接字符串并丢掉整体引号，表现为 UE 只执行第一个无参数命令；
2. 必须 `WaitForExit()`；直接调用 GUI 程序时 PowerShell 可能提前返回，脚本会在 Editor 读到改动前就把源文件恢复；
3. `-ExecCmds` 用逗号分隔多条 UE 控制台命令，不是分号；
4. 完整 Editor 用 `QUIT_EDITOR` 退出；
5. `-Unattended -NullRHI` 会让普通 Editor 窗口不可见，但 Live Coding Console 仍可能出现。`Quick restart disabled when re-instancing is enabled.` 只是 Quick Restart 能力提示，不等于编译失败。

最终以 JSON 为准：

```powershell
python Tools\Diagnostics\InspectStaticJITDump.py <before.json>
python Tools\Diagnostics\InspectStaticJITDump.py <after.json> --fail-on-mismatch
```

`before.json` 应看到改动函数走 `Vm`，旧候选是 `ContentMismatch`；`after.json` 必须看到新 `ProviderGeneration`、`Native` 和 `Exact`，且 Inspector 返回 0。测试无论成功失败都要先恢复 `.as`，再重新 Generate、Build、Verify，避免“源码已恢复但生成 C++ 仍是临时版本”。

本变更的固定探针、完整命令、哈希、RED/GREEN 证据和失败实验解释记录在 `openspec/changes/refactor-as-static-jit-multi-provider/attachments/real-editor-livecoding-smoke.md`。2026-08-13 的最终真实进程 `r9` 已完成验收：`before.json` 为 `Vm + ContentMismatch`，Live Coding 发布 generation `e3113f...`，`after.json` 为 `Native + Exact`、Registry publication `2 → 3`、引用 `7/7`，严格 Inspector 返回 0。随后已把源码恢复为 `* 2.0`，重新 Generate、Build、Verify，基线 generation 回到 `cd4129...`。

## 7. DLL 加载、卸载和 Live Coding 旧镜像

UE ModuleManager 仍然拥有 DLL 的主加载/卸载流程，StaticJIT 和 Runtime JIT
都不自己 `LoadLibrary`/`FreeLibrary`。

安全性由两层保证：

1. **Registry owner 退注册**：Provider 的 `ShutdownModule()` 注销 Modular Feature，Registry 从之后发布的 Snapshot 移除它，新 route 不再选择该 Provider；
2. **代码生命周期 lease**：已发布 binding 持有包含入口地址的代码镜像生命周期。旧 Catalog、旧 binding 或正在执行的调用还持有共享引用时，对应代码不能提前失效。

因此卸载顺序是逻辑上的：

```text
Provider 从新 Snapshot 消失
  -> 新刷新不再选择它
  -> 已发布旧 binding 被替换/退休
  -> 最后一个执行者释放 lease
  -> 旧代码镜像才具备安全释放条件
```

Live Coding patch 可能把新旧入口放在不同 patch 镜像中。生命周期实现会按地址确定并保留对应镜像，而不是假设“模块名相同就是同一段代码”。Monolithic 构建没有独立 Provider DLL，代码镜像自然随进程存活。

Runtime backend 插件也通过 Modular Features 发布 factory，但可执行代码不
进入全局 Provider Registry。每个 Engine 的 coordinator 复制并校验 factory
metadata，再创建独立 session。重新配置或 Engine shutdown 时顺序是：

```text
关闭新请求 admission
  -> 对当前 session/cancellation generation 发 Cancel
  -> 等待已经 admission 的同步、后台和 lazy 操作结束
  -> 丢弃 stale completion，退休当前 Runtime binding
  -> 等待最后一个 binding reader 退出
  -> 释放 CodeLease 和 session
  -> backend/factory 所属 UE 模块才具备安全卸载条件
```

单个函数被替换或丢弃时不会调用 generation-wide `Cancel`，只移除该函数的
exact record 并让旧结果按 revision 检查 stale-drop，避免误取消同一 session
中其他函数。代码释放由 backend 提供的 `CodeLease` 完成且 exactly once；
Runtime host trampoline 确保最后一次调用返回前，session/DLL 中的真正入口
不会失效。

这套设计避免两类错误：

- Provider 一卸载，正在执行的原生函数立刻跳进已释放代码；
- 为保住一个 Provider，永久钉住其他无关 Provider 或整个全局 JIT 表。

## 8. 生成和构建命令

首次启用项目 Provider：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Scaffold
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunBuild.ps1 -Label jit-first-build -TimeoutMs 1800000 -NoXGE
```

生成单一 Profile：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile EditorDevelopment
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile GameDevelopment
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile GameShipping
```

生成三个 Profile：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Generate -Profile All
```

只读校验：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File Tools\RunAngelscriptJIT.ps1 -Mode Verify -Profile All
```

推荐完整顺序：

```text
Scaffold（仅第一次）
  -> 完整 Editor/Game 构建，让 UBT 发现模块和所有源文件
  -> Generate 指定 Profile
  -> 再构建
  -> Verify
  -> 运行目标测试或 package smoke
```

`Verify` 是只读的：会报告 Provider/Profile/ABI、StableModuleKey、模块源、函数键、符号以及 missing/unexpected/mismatched owned files，发现差异返回非零。

生成器只会改带版本化 owner marker 的 owned files。遇到用户文件、marker 不匹配或保留路径冲突会拒绝覆盖。

## 9. 增量构建规模

当前实测：

| 样本 | `.jit.cpp` 大小/函数数 | 增量动作 | 首次/暖构建 |
|---|---:|---|---:|
| 项目代表模块 | 11,948 bytes / 4 | 只编译该 `.jit.cpp`，链接 `AngelscriptJIT` | 21.47s / 6.49s |
| 当前最大测试模块 | 136,259 bytes / 44 | 只编译该 `.jit.cpp`，链接 `AngelscriptTestJIT` | 8.24s / 6.29s |

未改模块不会重复生成或编译。连续相同 Generate 已验证 39/39 owned files 的路径、哈希、长度和时间戳全部保持不变。

当前生成规模：

| Provider/Profile | 模块文件 | 函数 | 总字节 |
|---|---:|---:|---:|
| 项目 EditorDevelopment | 9 | 19 | 64,835 |
| 项目 GameDevelopment | 8 | 18 | 54,918 |
| 项目 GameShipping | 8 | 18 | 54,650 |
| AngelscriptTestJIT EditorDevelopment | 2 | 46 | 141,221 |

严格按 AS 模块聚合后，文件数量随“有生成代码的 AS 模块数”增长，不再随函数数增长，也没有每函数 slice 或固定 bucket 文件爆炸。

## 10. Packaged 与直接调用状态

`GameDevelopment` 和 `GameShipping` Provider 都走相同的稳定匹配和 fail-closed 规则，不依赖 Editor、Live Coding 或 `AngelscriptTestJIT`。

当前 package multi-start 证据中，Development 和 Shipping 都是：

- 18/18 route Native；
- 0 VM fallback；
- 12/12 stable references 解析成功；
- 两次独立进程启动结果一致。

Provider ABI 已保留 `ImmutableDirectCallSet` 能力，但生产生成器当前显式关闭 script-to-script content-specific direct call emission。也就是说，函数自身可以通过 Native binding 执行，但生成的函数调用另一个脚本函数时仍走当前 binding/route，保证 Editor/PIE 和可重载 Profile 的正确性。

严格 per-module `.jit.cpp` 下的跨翻译单元直调需要额外证明完整 cooked artifact set、链接可见性和 stale-set 原子拒绝。它属于后续独立性能优化，不能把“已支持 Native binding”误写成“已经启用生产直接调用”。

## 11. 诊断

### 11.1 控制台命令

Static AOT 原有命令保持不变：

```text
as.StaticJIT.DumpDiagnostics
as.StaticJIT.DumpDiagnostics -Output=<absolute-or-project-relative-json>
as.StaticJIT.DumpDiagnostics -Function=<canonical-declaration-or-64-hex-function-key>
```

当前机器可读 JSON Schema Revision 为 2。主要内容包括：

- Registry publication ordinal；
- 多 ProviderId、owner UE 模块、generation、Profile 和环境；
- Provider 内 AS 模块成员与生成源文件；
- 当前 Engine route、瞬时 FunctionId 上下文；
- exact/mismatch 结果和类型化原因；
- VM/Raw/Parms 是否发布；
- stable reference slot 请求/解析；
- Native/VM 执行计数；
- route refresh 各阶段耗时。

离线查看：

```powershell
python Tools\Diagnostics\InspectStaticJITDump.py <dump.json>
python Tools\Diagnostics\InspectStaticJITDump.py <dump.json> --fail-on-mismatch
```

Inspector 不启动 Unreal，也不修改 Cache/Registry。仓库内有 valid、mismatch、malformed fixture 独立验证 Schema 行为。

统一 coordinator/Runtime JIT 使用独立的非 Shipping 命令：

```text
as.JIT.DumpDiagnostics
as.JIT.DumpDiagnostics -Output=<json-file>
as.JIT.DumpDiagnostics -Function=<canonical-declaration-or-function-key>
```

其 schema revision 1 是确定性、pointer-free 的当前状态快照，主要记录：

- execution mode 是否有效、Runtime BackendId/compile policy 和配置错误；
- Runtime factory/session 是否可用，以及 debugger/coverage gate；
- 每个函数的 requested/actual tier、Static match、Runtime profile/state/reason；
- compile attempt/result/stale/cancel 总数、编译耗时和代码大小；
- Runtime execution marker、active operation、live/retired code lease 数量。

`FAngelscriptStateDump::CaptureSnapshot()` 只通过公开的
`FAngelscriptJITDiagnostics` observer 增加 `JITCoordinator` 行；Dump 模块不
读取 coordinator 的私有 map、queue、session 或 lease。命令和这些细粒度
lease/queue 诊断不在 Shipping 暴露。

### 11.2 常见 mismatch

| 现象 | 常见原因 | 处理 |
|---|---|---|
| 只有一个改动函数 VM | ExecutionHash 不一致 | 重新 Generate + build/Live Coding；这是正常 fail-closed |
| 全部函数 VM | Provider 模块未加载或 Profile/环境不匹配 | 查 Provider 列表、Target Profile、build 配置 |
| `AmbiguousExactProvider` | 两个不同 ProviderId 同时声称同一 exact entry | 修正 Provider 边界/生成输入，不依赖加载顺序 |
| 引用槽失败 | 类型/函数/属性缺失、歧义或 kind/ABI 不符 | 用 function filter 查看具体 reference |
| Generate 要求 full build | `.jit.cpp` 源集合新增/删除，或尚未完成首次 build | 普通 `RunBuild.ps1`，不要强行 Live Coding |
| Live Coding 后仍 VM | patch 失败或 ProviderGeneration 未严格更新 | 查看 refresh service 和 Registry generation |
| Verify 报 unexpected file | 旧生成拓扑残留或 owned inventory 不一致 | 先核对 owner marker，再运行 Generate 清理 owned stale output |

### 11.3 排查顺序

1. 确认 AS 源码本身编译成功；
2. 用 `as.JIT.DumpDiagnostics` 确认 execution mode、requested/actual tier 和 Runtime factory/session/gate；
3. 若选择 Static，再看 `as.StaticJIT.DumpDiagnostics` 中 Provider、Profile/环境是否正确；
4. 用 `-Function=` 定位 StableModuleKey/FunctionKey、Static mismatch 或 Runtime reason；
5. Static 引用失败时检查 stable reference slots；
6. 运行 `RunAngelscriptJIT.ps1 -Mode Verify -Profile <Profile>`；
7. 只有 source set 没变时才尝试 Live Coding；否则完整构建；
8. package 问题用独立多启动 smoke，避免被当前 Editor 进程状态掩盖。

不要再查 `DataGuid`、`FJITDatabase::Functions`、`bStaticJITTranspiledCodeLoaded` 或旧 `.Cache/.jit.hpp` 配对；它们不是当前 Provider 路由的事实来源。

## 12. 设计不变量

维护当前实现时必须保持：

1. **一个非空 AS 模块严格对应一个 Profile 下的独立 `.jit.cpp`**；
2. 全局函数和类方法都按所属 AS 模块聚合；
3. Provider ABI 不暴露 bucket、slice、翻译单元拓扑或瞬时 FunctionId；
4. Engine/Cache V2 是当前脚本状态权威，Provider 只提供原生入口；
5. Provider 注册先校验再复制，Runtime 不长期借用 view 内存；
6. 多 Provider 选择不依赖 UE 模块加载顺序；
7. exact 冲突、ABI/Profile/环境/引用不匹配全部逐函数回退 VM；
8. binding 一次发布 VM/Raw/Parms/UserData，替换与释放 exactly once；
9. 解析后的函数/类型/属性指针只属于当前 Engine；
10. Provider 卸载先退出未来 Snapshot，旧代码由 lease 保活到最后使用者退出；
11. `.as` 普通保存不自动触发 C++ 生成和 Live Coding；
12. 生产 direct script-call emission 未启用，不能在文档或基准中声称已启用；
13. 一个 Engine 只有一个 `FAngelscriptJITCoordinator`，Runtime 插件不能自行替换 `asIJITCompiler`；
14. Static backend 与 Runtime backend 契约、BackendId 类型、输出和生命周期彼此独立；
15. Runtime worker 只消费 owned immutable snapshot，不持有 AngelScript/UE 对象指针；
16. Runtime result 必须 exact revision 才发布，且只发布 whole-function VMEntry；
17. Runtime code、typed HIR 和 session 状态不进入 Cache V2 或 Static Provider；
18. Runtime shutdown 先关 admission 并等待已接纳操作，再释放 binding、CodeLease 和 session。

## 13. 与 maintained AngelScript fork 的关系

当前 fork 的 JIT 生命周期不是旧 UE fork 接口，也不是照搬 upstream 2.38
的版本切换 API。维护分支拥有一个非版本化 `asIJITCompiler` 契约，当前只
由 `FAngelscriptJITCoordinator` 实现：

- compiled/restored function 完成后通知当前 compiler；
- compiler 延后发布完整 `asSJITFunctionBinding`；
- `asCScriptFunction` 私有持有 binding 和 owner；
- 替换、clear、函数销毁、模块 discard、compiler replacement/removal 都走同一退休协议；
- Static 生成器只观察 generation-only Engine 中已经编译的函数，不临时替换 live Engine 的执行 compiler；
- Runtime backend 永远不能直接写 `asCScriptFunction`，只能把结果交回 coordinator 做 exact 校验和发布。

这是有意的 maintained-fork ABI 不兼容。外部 Runtime backend 必须使用本
仓库的 `Public/JIT/AngelscriptRuntimeJITBackend.h`。当前 Runtime Backend
ABI Revision 固定为 `2`，Entry ABI Revision 为 `1`；任何结构布局、枚举
语义、结果验证或 helper token 契约变化都必须增加 Backend ABI revision，
不能只靠 `StructSize` 假装仍兼容。MIR/LLVM 插件应先通过仓库 fake-backend
conformance tests，再声明支持该 revision。

## 附录：快速回答

### JIT 函数怎么注册到某个 database？

现在不注册到 database。承载生成代码的 UE 模块实现 `IAngelscriptJITArtifactProvider`，在 `StartupModule()` 注册 Modular Feature；Runtime Registry 校验并复制为不可变 Catalog。

### Engine 初始化怎么消费？

先完成当前 AS 源码编译或 Cache V2 恢复，再由 `FAngelscriptJITProviderRouter::Refresh` 按稳定身份逐函数匹配 Provider。exact 才发布 Native binding，否则该函数 VM。

### AS 函数改了，怎样更新对应 `jit.cpp`？

重新 Generate。函数仍落在所属 AS 模块同一个 `<源文件名>.<短StableModuleKey>.<Profile>.jit.cpp`；其他模块文件不变。Editor 中旧 Native 立即因内容不匹配失效，先 VM，显式 Live Coding 或普通 build 发布新 Provider 后再 Native。

### 文件数会不会随函数爆炸？

不会按函数增长。每个 Profile 下 `.jit.cpp` 文件数等于有生成代码的 AS 模块数；一个模块内所有全局函数和类方法都在同一个 `.jit.cpp`。

### DLL 要自己加载卸载吗？

不用。UE ModuleManager 负责；StaticJIT 负责 Provider 注册/退注册、不可变 Catalog 和代码镜像 lease。Runtime JIT 由每 Engine session、关闭 admission、operation drain 和 CodeLease 保活。两条路径都保证卸载/Live Coding 时旧入口不会悬空。

### Runtime backend 怎么注册、由谁消费？

插件实现 `IAngelscriptRuntimeJITBackendFactory` 并注册 Modular Feature。每个
Engine 的 coordinator 按明确 BackendId 选择唯一 factory、校验 ABI 与目标
平台/配置，并创建独立 session；worker 只收到 copied snapshot。backend
返回的入口在 revision/ABI/generation 全匹配后才由 coordinator 发布。

### Cache 有问题会不会导致整个 JIT 清空？

当前不再按 whole-cache GUID 整盘绑定。Cache V2 与 Provider 独立，Router 逐函数 exact 匹配；单个函数或引用失配只影响对应 route。
