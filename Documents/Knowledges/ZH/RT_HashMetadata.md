# RT_HashMetadata — Hash / 元数据辅助

> **所属前缀**: RT_（运行时子系统族）
> **关注层面**: 把"插件里散落各处的 hash 调用"和"AS 端可见的 metadata 信息流"合在一处看——`GetTypeHash` 桥接如何让 TMap/TSet 容器能用 UE 类型当 key、xxHash 算出的 `CodeHash`/`CombinedDependencyHash` 如何在增量预处理与 PrecompiledData 装载时做内容指纹、StaticJIT 与 Cache 的 `FGuid DataGuid` + `BuildIdentifier` 双重校验链路、以及 UPROPERTY/UFUNCTION/UCLASS 的元数据从注释和 specifier 走到 UE 反射树并回查的全链路。本文不写 TMap/TSet 容器语法（那是 `Syntax_TMap.md` / `Syntax_TSet.md` 的事），不写 PrecompiledData 整体 schema（那是 `RT_StaticJIT.md` 的事），不写预处理器 chunk 切分细节（那是 `Type_Preprocessor.md` 的事）；本文聚焦的是 **hash 与 metadata 这两个跨子系统的"装订辅料"**，把它们的来源、消费端、失效语义、失败回退串成一篇可查的索引。
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/Hash/xxhash.{h,inl}` (~244 行，xxHash 0.6.5 单文件库 vendored)
> · `AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp` (`#define XXH_PRIVATE_API` + `XXH64` 算 `Section.CodeHash` / `Module->CodeHash`，~530 行；`Meta` 字段填充散布于 `Process(Class|Property|Function|Enum)Macro`)
> · `AngelscriptRuntime/Core/AngelscriptEngine.h` (`FAngelscriptModuleDesc::FCodeSection::CodeHash` / `Module::CodeHash` / `Module::CombinedDependencyHash` / `FFilenamePair` 的 `GetTypeHash` 自由函数 / `FAngelscriptClassDesc::Meta` 等)
> · `AngelscriptRuntime/Core/AngelscriptEngine.cpp` (`CompileModule_Types_Stage1` 中 `CombinedDependencyHash ^= ImportModule->...`、`CompiledModule->CodeHash == Module->CodeHash` 增量装载判定、`SetUserData((void*)(size_t)CombinedDependencyHash, 0)`)
> · `AngelscriptRuntime/Core/AngelscriptType.h` (`FAngelscriptType::CanHashValue` / `GetHash` 虚函数 + `FAngelscriptTypeUsage` 转发器)
> · `AngelscriptRuntime/Binds/Helper_CppType.h` / `Helper_PODType.h` (`TModels<CGetTypeHashable, NativeType>` 桥接到 `GetTypeHash(*(NativeType*)Address)`)
> · `AngelscriptRuntime/Binds/Bind_TMap.cpp` / `Bind_TSet.cpp` (`KeyType.CanHashValue()` 检查 + 回退到脚本端 `Hash()` 方法)
> · `AngelscriptRuntime/ClassGenerator/ASStruct.cpp` (~261 行，`FASStructOps::HashFunction` + `Capabilities.HasGetTypeHash` + `CPF_HasGetValueTypeHash`)
> · `AngelscriptRuntime/Binds/Bind_Hash.cpp` (~49 行，`Hash::CityHash32/64` 全局函数暴露)
> · `AngelscriptRuntime/StaticJIT/PrecompiledData.{h,cpp}` (`FAngelscriptPrecompiledModule::CodeHash` / `FAngelscriptPrecompiledData::DataGuid` / `BuildIdentifier`、`CreateFunctionId` 用 `FCrc::StrCrc_DEPRECATED + HashCombine`)
> · `AngelscriptRuntime/StaticJIT/StaticJITHeader.{h,cpp}` (`FStaticJITCompiledInfo::PrecompiledDataGuid` 与 `Get()` 单例)
> · `AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp` (`for (Elem : ClassDesc->Meta) NewClass->SetMetaData(Elem.Key, *Elem.Value)` 等多处把 `Meta` 抄写进 UE 反射)
> · `AngelscriptRuntime/Binds/Helper_FunctionSignature.h` (`Function->FindMetaData(K)` 优化路径)
> **关联文档**:
> `Documents/Knowledges/ZH/RT_HotReload.md` — 增量 reload 何时实际比对 `CodeHash`
> · `Documents/Knowledges/ZH/RT_StaticJIT.md` — `DataGuid` / `BuildIdentifier` 双重校验下 cooked artifact 的接受 / 拒绝
> · `Documents/Knowledges/ZH/RT_GlobalState.md` — `bStaticJITTranspiledCodeLoaded` 是进程级状态
> · `Documents/Knowledges/ZH/Type_Preprocessor.md` — §九 增量预处理：当一个文件 hash 没变就不重编
> · `Documents/Knowledges/ZH/Syntax_TMap.md` / `Syntax_TSet.md` — `KeyFuncs` 怎样调用 `GetTypeHash`
> · `Documents/Knowledges/ZH/Type_ClassGeneration.md` — `SetMetaData` 在 `Finalize` 步骤的位置

---

## 概览

本文聚焦一个核心问题：**插件里到底有几种"hash"？分别由谁算、由谁验、失败时谁兜底？UPROPERTY/UFUNCTION/UENUM 的 metadata 又是从哪来、存在哪、被哪些子系统反查？**

```text
========================================================================
  Hash / Metadata 全景：四个 Hash 角色 + 三个 Metadata 来源
========================================================================

[Hash 角色 1] 容器键 hash — GetTypeHash 桥接
  Helper_CppType::GetHash → TModels<CGetTypeHashable, T>::Value 静态分派
    命中: GetTypeHash(*(T*)Address) (UE 内置或 fork 注入的重载)
    脚本 struct: ASStruct.cpp 通过 FASStructOps::HashFunction 桥到
                 脚本 method "uint32 Hash() const"，并把
                 CPF_HasGetValueTypeHash 写进 ComputedPropertyFlags

[Hash 角色 2] 模块内容指纹 — XXH64 + XOR 聚合
  Section.CodeHash = XXH64(ProcessedCode, len*sizeof(TCHAR), 0)
  Module->CodeHash ^= Section.CodeHash                  // 文件内异或聚合
  Module->CombinedDependencyHash = self.CodeHash
  Module->CombinedDependencyHash ^= ImportModule->CombinedDependencyHash
  用途:
    ① if (Compiled.CodeHash == Module.CodeHash) → ApplyToModule_Stage1 跳编译
    ② SetUserData((void*)(size_t)CombinedDependencyHash, 0) 给 transpile

[Hash 角色 3] cooked artifact 完整性 — FGuid + BuildIdentifier
  FAngelscriptPrecompiledData::DataGuid = FGuid::NewGuid()  (cook)
  AngelscriptJitInfo.jit.cpp:
    static FStaticJITCompiledInfo Info(FGuid(A,B,C,D));    // link 期固化
  if (CompiledInfo->PrecompiledDataGuid != Data->DataGuid)
     FJITDatabase::Get().Clear()                           // 整盘丢 jit 入口表
  BuildIdentifier: Debug=1 / Dev=2 / Test=3 / Shipping=4，不一致 → 整盘丢字节码

[Hash 角色 4] 函数 ID — FCrc::StrCrc_DEPRECATED + HashCombine
  Id = HashCombine(Id, StrCrc(ModuleName))
  Id ^= (uint32)(size_t)ScriptModule->GetUserData()       // 来自角色 2
  Id = HashCombine(Id, StrCrc(TypeDeclaration))
  Id = HashCombine(Id, StrCrc(FunctionDeclaration))
  与 .jit.cpp 中 AS_xxx_Register(0x..u, ...) 的 magic 数严格对应

[Metadata 来源] AS 注释（仅 WITH_EDITOR）/ specifier / UHT 已存反射
  Sink: ClassGenerator: for (Elem : ClassDesc->Meta) NewClass->SetMetaData(...)
        Property/Function/Struct/Enum 各有一处对偶代码（仅 WITH_EDITOR）
```

后续按 [hash 库 → 容器键桥接 → 模块指纹 → cooked 校验 → 函数 ID → metadata 三源 → metadata 入反射 → reload 协同 → 性能/调试 → 速查] 顺序展开。

---

## 一、Hash 库与统一接口

插件运行期可见的 hash 实现来自三个独立库：

| 库 | 来源 | 输出 | 主要消费者 |
|----|-----|------|-----------|
| `Hash/xxhash.h/.inl` | vendored xxHash 0.6.5 | `XXH64_hash_t = unsigned long long` | `FAngelscriptPreprocessor::Process` 一个调用点 |
| `Hash/CityHash.h`（UE 自带） | UE Core | `uint32 / uint64` | `Bind_Hash.cpp` 暴露给 AS `Hash::CityHash32/64` |
| `GetTypeHash(...)` 重载族 | UE Core / 插件类型自家 | `uint32` | TMap/TSet KeyFuncs / `Helper_CppType::GetHash` |

xxHash 是插件**自带**的（`Plugins/Angelscript/Source/AngelscriptRuntime/Hash/`），仅 `AngelscriptPreprocessor.cpp` 一个翻译单元 `#define XXH_PRIVATE_API` 导入。其他位置一律走 `GetTypeHash` / `CityHash` / `FCrc`。

为了让 TMap / TSet 在通用代码里能问"我能不能拿这个类型当 key"，类型系统在 `FAngelscriptType` 上挂了两个虚函数：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptType.h
// 角色: 类型系统的 hash 能力查询接口（基类默认 false）
// ============================================================================
virtual bool   CanHashValue(const FAngelscriptTypeUsage& Usage) const { return false; }
virtual uint32 GetHash(const FAngelscriptTypeUsage& Usage, const void* Address) const
{
    ensure(false);              // ★ 基类调用即编程错误
    return 0;
}

// FAngelscriptTypeUsage 的转发器（同文件 ~527 行）
FORCEINLINE bool   CanHashValue() const { return Type.IsValid() && Type->CanHashValue(*this); }
FORCEINLINE uint32 GetHash(const void* Address) const { return Type->GetHash(*this, Address); }
```

**只有"显式声明可 hash"的类型才返回 true**——基类是 false，重写发生在 `Helper_CppType.h` / `Bind_BlueprintType.cpp` / `Bind_UEnum.cpp` / `Bind_UStruct.cpp`。

---

## 二、Hash 角色 1：容器键 hash（GetTypeHash 桥接）

### 2.1 C++ POD 类型：`TModels<CGetTypeHashable, T>` 静态分派

`Helper_CppType.h`（共享给所有 C++ 包装类型）与 `Helper_PODType.h`（POD-only fast path）都用同一段编译期分派：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Helper_CppType.h
// 函数: TAngelscriptCppType<NativeType>::CanHashValue / GetHash
// ============================================================================
bool CanHashValue(const FAngelscriptTypeUsage& Usage) const
{
    return TModels<CGetTypeHashable, NativeType>::Value;       // ★ 静态特征查询
}

uint32 GetHash(const FAngelscriptTypeUsage& Usage, const void* Address) const
{
    if constexpr (TModels<CGetTypeHashable, NativeType>::Value)
        return GetTypeHash(*(NativeType*)Address);             // ★ ADL 命中 UE 重载
    else
        return 0;
}
```

`TModels<CGetTypeHashable, T>` 是 UE concept：编译期看 `GetTypeHash(T const&)` 能否 ADL 到匹配签名。命中→ `CanHashValue() = true` 自动；不命中→ 自动 false，后续 `TMap<DelegateValue, X>` 在 `RegisterTemplate` 时被报为 `"Key type does not have a hash function defined"`。

### 2.2 UObject* / UEnum / 各种基础类型

```cpp
// Bind_BlueprintType.cpp:301 — UObject* 走指针 hash
return GetTypeHash(*(UObject**)Address);

// Bind_UEnum.cpp:238 — UEnum 用底层 uint8
return GetTypeHash(*(uint8*)Address);

// Bind_FName.cpp:175 / Bind_FString.cpp:406 / Bind_FGuid.cpp:63
//   FName/FString/FGuid 都暴露 .GetHash() 方法，内部走 GetTypeHash
```

### 2.3 USTRUCT 桥：`FStructOps::HasGetTypeHash` + fake vtable

USTRUCT（含 AS 端 `struct` 关键字）走另一条桥。`FCppStructOps::HasGetTypeHash` 是 UE 反射约定的"我有 hash"标志位；`FASStructOps`（脚本生成 struct 的 ops）在构造时检查脚本类的 `Hash()` 方法：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/ASStruct.cpp
// 函数: FASStructOps::SetFromStruct（节选 hash 段）
// ============================================================================
if (ScriptType->GetFirstMethod("Hash") != nullptr)
{
    const FString HashDecl = TEXT("uint32 Hash() const");
    HashFunction = ScriptType->GetMethodByDecl(TCHAR_TO_ANSI(*HashDecl));
}
else { HashFunction = nullptr; }

FakeVTable.Capabilities.HasGetTypeHash = (HashFunction != nullptr);                      // ★
FakeVTable.Capabilities.ComputedPropertyFlags |=
    (HashFunction != nullptr) ? CPF_HasGetValueTypeHash : CPF_None;                      // ★
```

实际调 hash 时进 AS VM：

```cpp
// 文件: ASStruct.cpp:195
static uint32 GetStructTypeHash(FASStructOps* Ops, const void* Src)
{
    if (Ops->HashFunction == nullptr) return 0;
    FAngelscriptContext Context(Ops->HashFunction->GetEngine());
    if (!PrepareAngelscriptContextWithLog(Context, Ops->HashFunction, TEXT("FASStructOps::GetStructTypeHash")))
        return 0;
    Context->SetObject(const_cast<void*>(Src));
    Context->Execute();                                                // ★ 进 VM
    return Context->GetReturnDWord();
}
```

### 2.4 TMap/TSet 模板实例化期的 hash 门禁

`Bind_TMap.cpp` 在 `RegisterTemplate`（每次脚本里写 `TMap<K, V>` 第一次出现时）做能力检查：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Bind_TMap.cpp:1317
// 角色: 模板实例化期的 hash 检查 + 脚本端兜底
// ============================================================================
bool bCanHash = KeyType.CanHashValue();
if (!bCanHash)
{
    // 退路：若 K 是脚本端 class/struct 且声明了 uint32 Hash() const
    if (asCTypeInfo* SubType = (asCTypeInfo*)TemplateType->GetSubType(0))
    {
        auto* ObjectType = CastToObjectType(SubType);
        if (ObjectType != nullptr && ObjectType->GetFirstMethod("Hash") != nullptr)
        {
            Ops->HashFunction = SubType->GetMethodByDecl("uint32 Hash() const");
            bCanHash = Ops->HashFunction != nullptr;                   // ★ 脚本端兜底
        }
    }
}
Ops->bValid = KeyType.CanConstruct() && KeyType.CanCompare() && bCanHash && ...;
```

`Bind_TSet.cpp` 是同段（少一个 ValueType）。这两个文件的 hash 通路是 AS 容器"接收 UE 类型当 key"的唯一入口——任何不在四个桥接路径里的类型，写 `TMap<X, ...>` 都会得到清晰编译错误。详见 `Syntax_TMap.md` §三 与 `Syntax_TSet.md` §四。

### 2.5 暴露给 AS 的 hash 工具函数

```cpp
// 文件: Bind_Hash.cpp 节选
FAngelscriptBinds::FNamespace ns("Hash");
FAngelscriptBinds::BindGlobalFunction("uint32 CityHash32(const FString& buf)", ...);
FAngelscriptBinds::BindGlobalFunction("uint64 CityHash64(const FString& buf)", ...);
// + WithSeed / WithSeeds / TArray<int8> 重载
```

加上各基础类型的 `GetHash() const`（FName/FString/FGuid/FNumberFormattingOptions），AS 脚本既能把它们当 TMap 键，也能直接拿到 hash 值做自定义算法。

---

## 三、Hash 角色 2：模块内容指纹（XXH64）

### 3.1 单文件 `CodeHash` 与模块 `CodeHash`

整个 hash 的源头是 `FAngelscriptPreprocessor::Process` 末尾一行：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp:530
// 函数: FAngelscriptPreprocessor::Process（节选）
// ============================================================================
Section.CodeHash = 0;
if (File.ProcessedCode.Len() > 0)
{
    Section.CodeHash = XXH64(&File.ProcessedCode[0],
                             File.ProcessedCode.Len() * sizeof(TCHAR), 0);   // ★ 文件 hash
    File.Module->CodeHash ^= Section.CodeHash;                                // ★ 模块聚合
}
File.Module->Code.Emplace(MoveTemp(Section));
```

要点：

- **算的是预处理后的 `ProcessedCode`** ——不是磁盘原文。注释剥离 / `#if EDITOR` 分支选择 / `default Foo = X` 提升 / 自动注入的 `Spawn / Get / GetOrCreate` 等都已发生，**只有真正给 AS 编译器看的字符串才参与 hash**；只改注释不会影响 `CodeHash`。
- **聚合用 XOR**：模块多文件按位异或所有 `Section.CodeHash`，**文件顺序无关**——不管按什么顺序 `AddFile`，最后 `Module->CodeHash` 一致。
- **xxHash 0.6.5 单文件库**：vendored 在 `Plugins/Angelscript/Source/AngelscriptRuntime/Hash/`，`#define XXH_PRIVATE_API` inline 进 `AngelscriptPreprocessor.obj`，不污染其他翻译单元。

### 3.2 `CombinedDependencyHash`：跨模块依赖闭包

文件级 hash 满足"我自己变了吗"，但 AS 模块 A `import B` 时还要看 B 变没变：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:4673
// 函数: FAngelscriptEngine::CompileModule_Types_Stage1（节选）
// ============================================================================
Module->CombinedDependencyHash = Module->CodeHash;       // ★ 自身 hash

bool bAllImportsPreCompiled = true;
for (auto ImportModule : ImportedModules)
{
    if (ensure(ImportModule->ScriptModule != nullptr))
        ImportIntoModule(ScriptModule, ImportModule->ScriptModule);

    if (!ImportModule->bLoadedPrecompiledCode)
        bAllImportsPreCompiled = false;

    Module->CombinedDependencyHash ^= ImportModule->CombinedDependencyHash;   // ★
}

// 行 4760
#if AS_CAN_GENERATE_JIT
    ScriptModule->SetUserData((void*)(size_t)Module->CombinedDependencyHash, 0);     // ★
#endif
```

`CombinedDependencyHash` 是个传染量：A → B → C 时，C 的字符变化异或到 B 的 CombinedDependencyHash，再异或到 A。它不被 PrecompiledData 装载判断使用（那只看自身 CodeHash），但被 StaticJIT transpile 用作 module userdata，cook 期 `CreateFunctionId` 读取它做函数 ID 的加盐项——任何依赖路径上的字符变化都让函数 ID 飘移，强制 .jit.cpp 重新生成。

### 3.3 XOR 聚合的语义与碰撞缓解

| 性质 | 后果 |
|------|------|
| 顺序无关（A^B^C == C^B^A） | 文件 / 依赖添加顺序不影响 |
| 同值抵消（A^A == 0） | 两个完全相同文件互相抵消（罕见） |
| 碰撞概率高于强 hash | XXH64 本身好，但 XOR 聚合非 cryptographic |
| 单条 XOR 指令 | 装载阶段对几百模块算 O(n) 几乎零开销 |

插件不把 `CodeHash` 当"安全签名"，只当快速变更检测。`PrecompiledData` 的真正完整性签名是 `FGuid DataGuid`（128 位随机）+ `BuildIdentifier`（详见 §四），即使 XXH64 碰撞，cooked 路径下还有 `bAllImportsPreCompiled`、模块名 `Find` 命中等多重护栏。

### 3.4 装载 PrecompiledData 时的 CodeHash 比对

cooked 启动期，每个模块都会被检查"我能不能直接复用 cache 里的字节码"：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp:4694
// 函数: CompileModule_Types_Stage1（节选）
// ============================================================================
if (PrecompiledData != nullptr && bAllImportsPreCompiled && bUsePrecompiledData)
{
    const FAngelscriptPrecompiledModule* CompiledModule
        = PrecompiledData->Modules.Find(Module->ModuleName);
    if (CompiledModule != nullptr)
    {
        // ★ 关键：自身 CodeHash 一致即视为"未变化"
        if (CompiledModule->CodeHash == Module->CodeHash)
        {
            CompiledModule->ApplyToModule_Stage1(*PrecompiledData, ScriptModule);
            Module->bLoadedPrecompiledCode = true;
            return;       // ★ 跳过 AS 内核编译，直接复用缓存的字节码
        }
        else
        {
            UE_LOG(Angelscript, Warning, TEXT("...did not match script as loaded from file. Discarding."));
        }
    }
}
```

注意是**只对自身 `CodeHash`** 做相等比较，不对 `CombinedDependencyHash`。原因：`bAllImportsPreCompiled` 已经从语义上保证"我所有的依赖都来自同一份 cache"，所以"我自己没改"就够了。如果某个 import 也改了，它自身的相同分支会失败，向下传染回来。

---

## 四、Hash 角色 3：cooked artifact 完整性校验

### 4.1 `FGuid DataGuid`：cache 与 .jit.cpp 的"配对码"

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/StaticJIT/PrecompiledData.cpp:2658
// 函数: FAngelscriptPrecompiledData::FAngelscriptPrecompiledData
// ============================================================================
FAngelscriptPrecompiledData::FAngelscriptPrecompiledData(asIScriptEngine* InEngine)
    : AllocMark(GScriptPreallocatedMemStack)
    , Engine((asCScriptEngine*)InEngine)
{
    DataGuid = FGuid::NewGuid();      // ★ cook 期一次性生成的 128-bit 随机 GUID
}
```

cook 流水线把：

- `DataGuid` 序列化进 `PrecompiledScript.Cache`
- 同一个 `DataGuid` 嵌入到 `AngelscriptJitInfo.jit.cpp`：
  `static FStaticJITCompiledInfo Info(FGuid(A,B,C,D));`

两份产物在 cook 完成的瞬间签了"同一份订单"。

### 4.2 link 期固化与单例自检

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/StaticJIT/StaticJITHeader.cpp:19-36
// 角色: FStaticJITCompiledInfo 进程级单例
// ============================================================================
static const FStaticJITCompiledInfo*& GetActiveCompiledInfo()
{
    static const FStaticJITCompiledInfo* ActiveInfo = nullptr;
    return ActiveInfo;
}

FStaticJITCompiledInfo::FStaticJITCompiledInfo(FGuid Guid)
    : PrecompiledDataGuid(Guid)
{
    const FStaticJITCompiledInfo*& ActiveInfo = GetActiveCompiledInfo();
    checkf(ActiveInfo == nullptr,
           TEXT("Only one angelscript static JIT info can be compiled in!"))
    ActiveInfo = this;             // ★ 静态构造期登记
}

const FStaticJITCompiledInfo* FStaticJITCompiledInfo::Get() { return GetActiveCompiledInfo(); }
```

- 整个进程**只允许有一份** `FStaticJITCompiledInfo`——多份会 `checkf` 死掉。
- `Get()` 在 `FAngelscriptEngine::Initialize` 末尾被调用做 GUID 比对，没有兜底——返回 `nullptr` 表示该 build 没 link 进 transpiled JIT 代码，等同于"无 jit"。

### 4.3 Initialize 中的双层 GUID/BuildID 比对

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Core/AngelscriptEngine.cpp（节选 cooked 装载分支）
// 函数: FAngelscriptEngine::Initialize
// ============================================================================
PrecompiledData = new FAngelscriptPrecompiledData(Engine);
PrecompiledData->Load(Filename);
if (!PrecompiledData->IsValidForCurrentBuild())     // ★ BuildIdentifier 不匹配 → 整盘丢弃
{
    delete PrecompiledData; PrecompiledData = nullptr;
    UE_LOG(Angelscript, Warning, TEXT("...Discarding all precompiled data."));
}
else
{
    const FStaticJITCompiledInfo* CompiledInfo = FStaticJITCompiledInfo::Get();
    if (CompiledInfo != nullptr
        && CompiledInfo->PrecompiledDataGuid != PrecompiledData->DataGuid)   // ★ GUID 校验
    {
        UE_LOG(Angelscript, Warning, TEXT("...Transpiled code will not be used!"));
        FJITDatabase::Get().Clear();          // ★ 单独丢 JIT，字节码保留
    }
}
```

**两层失败语义**：

| 校验 | 不一致后果 |
|------|------------|
| `BuildIdentifier`（Debug=1/Dev=2/Test=3/Shipping=4）| 整盘 `PrecompiledData` 抛弃——连字节码都用不上，回到全量重编 |
| `PrecompiledDataGuid`（128-bit FGuid）| `FJITDatabase::Get().Clear()` 把所有 jit 入口清空，但字节码继续用——回退到解释器 |

### 4.4 `IsValidForCurrentBuild` 的实现

```cpp
// 文件: PrecompiledData.cpp
int32 FAngelscriptPrecompiledData::GetCurrentBuildIdentifier()
{
#if   UE_BUILD_DEBUG       return 1;
#elif UE_BUILD_DEVELOPMENT return 2;
#elif UE_BUILD_TEST        return 3;
#elif UE_BUILD_SHIPPING    return 4;
#else                      return -1;     // ★ 未知配置永远视为无效
#endif
}
bool IsValidForCurrentBuild()
{
    return BuildIdentifier == GetCurrentBuildIdentifier() && BuildIdentifier != -1;
}
```

故意不允许 cross-config 复用 cache，因为不同 build config 的 `WITH_EDITOR` / `UE_BUILD_SHIPPING` 等宏深刻影响 binding 注册表与字段布局。

> 注：题目里提到的 `'ASBD' magic` / `FAngelscriptCacheVersion` 这种"ASCII magic + 整数版本"的传统 cache 头，**当前代码里不存在**。完整性校验完全靠 `FGuid DataGuid` + `BuildIdentifier` 这一对，外加 `FArchive` 的二进制 property 序列化模式。详见 `RT_StaticJIT.md` §三。

---

## 五、Hash 角色 4：函数 ID（FunctionId）

### 5.1 为什么要给每个函数派生稳定 ID

cooked 启动期 `FStaticJITFunction(0xRRRu, &VMEntry, &ParmsEntry, &Raw)` 在 link 期通过 `AS_FORCE_LINK` 注册到 `FJITDatabase::Get().Functions[FuncId]`。AS 内核运行时拿到一个 `asCScriptFunction*`，要回查"这个函数的 jit 入口在哪里"——key 必须能由两端独立、确定地从同一个函数派生出来：cook 期算一遍写到 .jit.cpp，run 期算同一遍 lookup。

### 5.2 派生算法

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/StaticJIT/PrecompiledData.cpp:2761
// 函数: FAngelscriptPrecompiledData::CreateFunctionId
// ============================================================================
uint32 Id = 0;
if (Function->GetName()[0] == '\0')
{
    // 全局变量初始化函数：无名，用随机 ID（不需跨进程一致）
    Id = ((uint32)FMath::Rand() << 16) | ((uint32)FMath::Rand() & 0xffff);
}
else
{
    auto* ScriptModule = Function->GetModule();
    if (ScriptModule != nullptr)
    {
        Id = HashCombine(Id, FCrc::StrCrc_DEPRECATED((const ANSICHAR*)ScriptModule->GetName()));
        Id = HashCombine(Id, (uint32)(size_t)ScriptModule->GetUserData());     // ★ 角色 2 的 hash
    }
    auto* ObjectType = Function->GetObjectType();
    if (ObjectType != nullptr)
        Id = HashCombine(Id, FCrc::StrCrc_DEPRECATED(
            (const ANSICHAR*)ObjectType->GetEngine()->GetTypeDeclaration(ObjectType->GetTypeId(), true)));

    Id = HashCombine(Id, FCrc::StrCrc_DEPRECATED(
        (const ANSICHAR*)Function->GetDeclaration(true, true)));
}

while (ProcessedIdToFunction.Contains(Id))
    ++Id;                       // ★ 冲突时线性递增
```

四个加盐项：

| 加盐项 | 来源 |
|--------|------|
| `ScriptModule->GetName()` | AS 内核 |
| `ScriptModule->GetUserData()` | 角色 2 的 `CombinedDependencyHash` 低 32 位 |
| `ObjectType->GetTypeDeclaration` | AS 内核（含 namespace） |
| `Function->GetDeclaration(true, true)` | AS 内核（含 namespace/类前缀/const 标记） |

`FCrc::StrCrc_DEPRECATED` 是 UE 自带字符串 CRC，名字带 DEPRECATED 是因为 UE 自身在迁移到更现代 hash，但插件这里**故意保留**——key 的稳定性比安全性重要，已经被 cook 出来的所有 .jit.cpp 写死。

### 5.3 冲突处理与对应关系

`while (Contains(Id)) ++Id` 让算法**容忍碰撞**：碰撞时把 ID 递增 1 直到不冲突。后果：

- cook 期的 `FunctionId` 与 .jit.cpp 中 `Register(0x..u, ...)` 的 magic 数完全一致。
- run 期 `MapFunctionId` 必须按 cook 期的"递增插入顺序"重放，所以 PrecompiledData 中的函数遍历顺序在序列化 / 反序列化时严格保持。
- 单次 cook 内的 ID 集合天然无重；两次独立的 cook 可能给同一个函数派生不同 ID（递增起点取决于先到的同 hash 函数顺序）—— `DataGuid` 校验保证两端始终来自同一次 cook。

---

## 六、Metadata 三个来源

### 6.1 来源 1：AS 源码注释（仅 WITH_EDITOR）

只有 `WITH_EDITOR` 路径下才采集注释，目的是给 BP 节点 / 属性面板提供 ToolTip：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp
// 角色: 类 / 函数 / 属性 / 枚举值的注释 → Meta[ToolTip] 归一化
// ============================================================================
static FName PP_NAME_ToolTip("ToolTip");

// 类 / struct（行 1015）
#if WITH_EDITOR
if (Chunk.Comment.Len() != 0)
    ClassDesc->Meta.Add(PP_NAME_ToolTip, FormatCommentForToolTip(Chunk.Comment));
#endif

// UFUNCTION（行 1577） / UPROPERTY（行 2552） 同模式
#if WITH_EDITOR
if (Macro.Comment.Len() != 0)
    FunctionDesc->Meta.Add(PP_NAME_ToolTip, FormatCommentForToolTip(Macro.Comment));
#endif

// UENUM 值（行 2922）— 用 (FName, int32) 复合 key，因为同名 ToolTip 落在不同 value
auto MetaKey = TPair<FName, int32>(PP_NAME_ToolTip, Macro.SubjectIndex);
if (!EnumDesc->Meta.Contains(MetaKey))
    EnumDesc->Meta.Add(MetaKey, FormatCommentForToolTip(Macro.Comment));
```

`FormatCommentForToolTip`（`Helper_CommentFormat.h`）剥离 `//`、`/* */`、`*` 行首星号、规整换行——`FHeaderParser` 系出同源。

### 6.2 来源 2：UPROPERTY/UFUNCTION/UCLASS specifier

`ParseSpecifiers` 把 `UPROPERTY(EditAnywhere, Category="Foo", Meta=(ClampMin="0"))` 切成 `FSpecifier` 列表，按白名单决定哪些进 `Meta`：

```cpp
// ============================================================================
// 文件: AngelscriptPreprocessor.cpp
// 函数: ProcessFunctionMacro / ProcessPropertyMacro / ProcessClassMacro 共用 specifier 路由
// ============================================================================
TArray<FSpecifier> Specs = ParseSpecifiers(Macro.Arguments);
for (auto& Spec : Specs)
{
    // 一组 specifier 命中布尔位
    if (Spec.Name == PP_NAME_BlueprintCallable) FunctionDesc->bBlueprintCallable = true;

    // 另一组直接进 Meta
    else if (Spec.Name == PP_NAME_Category
          || Spec.Name == PP_NAME_Keywords
          || Spec.Name == PP_NAME_ToolTip
          || Spec.Name == PP_NAME_DisplayName
          || Spec.Name == PP_NAME_BlueprintProtected)
    {
        FunctionDesc->Meta.Add(Spec.Name, Spec.Value);   // ★
    }
}
```

`ProcessPropertyMacro` 还多支持 EditInline / ExposeOnSpawn / EditFixedSize 等。`ProcessClassMacro` 处理 NotPlaceable / NotBlueprintable。`ProcessEnumMacro` 用 `(FName, int32)` 作 key（int 是值索引）。

### 6.3 来源 3：UHT / 现有 UE 反射

UE C++ 头的 UFUNCTION/UPROPERTY 经过 UHT 早就在 `UFunction::MetaData` / `FProperty::MetaData` 里。AS 端 binding **不复制**这些数据，需要时直接查：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Binds/Helper_FunctionSignature.h:174
// 角色: 把 HasMetaData + GetMetaData 合并为单次 FindMetaData 调用（Opt 2）
// ============================================================================
auto HasFuncMeta = [&](const FName& K) -> bool
{
    return Function->FindMetaData(K) != nullptr;
};
auto GetFuncMetaRef = [&](const FName& K) -> const FString&
{
    const FString* V = Function->FindMetaData(K);
    return V != nullptr ? *V : EmptyString;
};
```

UField 的 metadata 存在 `FMetaData::Values` 这张 TMap 里，每次 `HasMetaData(K)` 后再 `GetMetaData(K)` 会查两次；改成 `FindMetaData(K)` 单次返回指针，命中即同时拿到了存在性和值，热路径量级减半。

`Bind_BlueprintType.cpp` / `Bind_UStruct.cpp` / `Bind_UEnum.cpp` 等 binding 模块大量使用类似查询，主要 key 集中在：

| 标识符常量 | 用途 |
|------------|------|
| `NAME_Func_Tooltip` (`"ToolTip"`) | 函数 tooltip |
| `NAME_Property_ScriptName` | 属性的 AS 端别名（覆盖 C++ 名字） |
| `NAME_Property_DeprecationMessage` | 属性弃用提示 |
| `NAME_Signature_ScriptName` / `NAME_Signature_ToolTip` / `NAME_Signature_Category` | 签名级 metadata |
| `NAME_Arg_AdvancedDisplay` / `NAME_Arg_WorldContext` | 参数级 metadata |
| `NAME_OptionalWorldContext` / `NAME_CallableWithoutWorldContext` | 隐藏 WorldContext 自动注入开关 |
| `NAME_ScriptKeywords` | DebugServer 自动补全用 keyword 列表 |
| `NAME_UnsafeDuringActorConstruction` | 设置 `asTRAIT_UNSAFE_DURING_CONSTRUCTION` |

### 6.4 三种来源的优先级

来源 1（注释）与来源 2（specifier）写进同一个 `Meta`：来源 2 显式 `ToolTip="..."` 会**覆盖**注释——`Meta.Add` 在 TMap 上是 last-write-wins。来源 3（UHT 头）不参与 AS 描述符的填充，只在 binding 注册时被反查；与 1/2 不冲突，因为各自描述不同对象（C++ 类 vs AS 类）。

---

## 七、Metadata 入 UE 反射：`SetMetaData` sink

`FAngelscriptClassDesc::Meta` / `FAngelscriptPropertyDesc::Meta` / `FAngelscriptFunctionDesc::Meta` / `FAngelscriptEnumDesc::Meta` 最终都要交付 UE 反射。`AngelscriptClassGenerator.cpp` 是唯一 sink：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator.cpp
// 角色: 把 Meta 抄写进各种 UE 反射对象（节选）
// ============================================================================

// 1) UClass（行 ~3354）
for (auto& Elem : ClassDesc->Meta)
    NewClass->SetMetaData(Elem.Key, *Elem.Value);                      // ★

// 2) UScriptStruct（行 ~2782）
for (auto& Elem : ClassDesc->Meta)
    NewStruct->SetMetaData(Elem.Key, *Elem.Value);

// 3) FProperty（行 ~2946）
for (auto& Elem : PropDesc->Meta)
    NewProperty->SetMetaData(Elem.Key, *Elem.Value);

// 4) UFunction（行 ~3450）
for (auto& Elem : FunctionDesc->Meta)
    NewFunction->SetMetaData(Elem.Key, *Elem.Value);

// 5) UEnum 值级（行 ~3868）
for (auto& MetaElement : EnumDesc->Meta)
{
    if (MetaElement.Key.Value < Enum->NumEnums())
        Enum->SetMetaData(*MetaElement.Key.Key.ToString(),
                          *MetaElement.Value, MetaElement.Key.Value);
}
```

注意 `WITH_EDITOR` 守卫——五个 sink 全都包在 `#if WITH_EDITOR` 里。这意味着 cooked Shipping/Test 从一开始就**不写入 metadata**：不浪费内存，BP 编辑器也用不到。

### 7.1 父类 metadata 继承的 trick

`InheritMetaDataFromSuperClass`（行 ~3736）做"父类 metadata 继承到子类"时有个坑：

```cpp
// 文件: AngelscriptClassGenerator.cpp:3736
if (SuperMeta != nullptr)
{
    // Need to copy, because calling SetMetaData could invalidate the SuperMeta pointer,
    // because it adds a new entry into the metadata map for the new class object.
    TArray<TPair<FName, FString>, TInlineAllocator<8>> CopiedMetaData;
    // ...先复制到 CopiedMetaData...
    for (auto& MetaPair : CopiedMetaData)
        NewClass->SetMetaData(MetaPair.Key, *MetaPair.Value);
}
```

UE 的 `FMetaData` 是 `TMap`，rehash 后指针失效——copy 后再写避免 use-after-write。

### 7.2 自动注入的 metadata

除从描述符抄写外，`Finalize` 还会自动加几条：

| 触发 | 自动写入 |
|------|---------|
| AActor 子类 + 没显式 HideCategories | `HideCategories += " DefaultComponents"` |
| Property `bInstancedReference` | `NAME_EditInline = "true"` |
| Property `bIsProtected` | `FUNCMETA_BlueprintProtected = "true"` |
| Function 是 mixin | `MixinArgument` / `DefaultToSelf` |
| Function `bIsNoOp` | `FUNCMETA_ScriptNoOp = "true"` |
| Function `bUsesWorldContext` | `NAME_Arg_WorldContext = "<arg-name>"` |
| 含 default value 的参数 | `CPP_Default_<arg> = "<value>"` |
| Component 类 | `NAME_Component_Spawnable` |

---

## 八、与增量预处理 / HotReload 的协同

`RT_HotReload.md` §四的反向依赖闭包用 `ImportedModules` 字符串列表，**不**直接读 `CodeHash`。但 hash 在 reload 路径上仍有两处隐性影响：

1. **PrecompiledData 命中**：`CompileModule_Types_Stage1` 仍走 §3.4 的逻辑——若改的不是 .as 源码（如改了 C++ 重编 binding），cache 完整命中可以"什么都不做"。
2. **transpile 的 module userdata 一致性**：`SetUserData((void*)(size_t)CombinedDependencyHash, 0)` 让 cook 期 `CreateFunctionId` 拿到的 hash 与运行期 reload 后新 module 的 hash 一致；任何依赖变化让 userdata 飘移、function ID 飘移，进而 jit 入口 lookup miss——`bStaticJITTranspiledCodeLoaded` 仍然为 true，但少数函数走解释器，性能下跌一点点（不会崩溃）。

### 8.1 metadata 在 SoftReload / FullReload 中的命运

| 改动 | 对 Meta 的影响 | reload 决策 |
|------|----------------|------|
| 改 UPROPERTY 的 `Category="X"` | Meta 不一致 | `FullReloadSuggested`：UProperty 重建即可 |
| 改 ToolTip 注释 | Meta[ToolTip] 不一致 | `SoftReload`：注释剥离前后 ProcessedCode 不变，CodeHash 不变；但 reload 一旦走通会重写 SetMetaData |
| 添加 / 删除 specifier `EditAnywhere` | Meta 不一致 + 布尔位变 | `FullReloadRequired`：CPF flag 不同 |
| 类前面加新 `/** ... */` | Meta[ToolTip] 不一致 | `SoftReload`（同上） |

注释级改动有个意外：`Chunk.Comment` 改了不影响 `XXH64(ProcessedCode)`（注释已剥离），所以 `CodeHash` 相同——AS 编译器层面看不到改动。但 DirectoryWatcher 仍会检测到文件 mtime 变化，进入 PerformHotReload 后预处理器会重算 Meta，并经 `OnPostReload` 重新 `SetMetaData`，结果是注释更新会被反应到属性面板的 ToolTip。

---

## 九、性能与调试

### 9.1 各 hash 角色的开销量级

```text
[角色 1] 容器键 hash:
  POD 整型/指针: ~1-3 cycles (UE GetTypeHash 内联)
  FString: O(len)
  FASStructOps: 调脚本 Hash() 方法，VM 调度 ~50-200 cycles 起跳

[角色 2] XXH64 模块指纹:
  XXH64: ~5 GB/s on x64，对 50KB 模块约 10μs
  XOR 聚合: 单条 XOR 指令
  调用频率: 每次 Preprocessor.Process 末尾一次

[角色 3] FGuid + BuildIdentifier:
  调用频率: Initialize 一次，常数

[角色 4] FunctionId 派生:
  FCrc::StrCrc_DEPRECATED + HashCombine: O(len)
  调用频率: 每个函数一次（cook 期），run 期通过 Map 反向恢复
```

缓存策略：`ProcessedFunctionToId`（去重）/ `Section.CodeHash` 字段（reload 不重算）/ `asCModule.userData[0]`（挂 hash） 等。

### 9.2 dump 当前模块 hash

`AngelscriptStateDump.cpp` 的 `Modules` 表导出每个模块的两份 hash：

```cpp
// ============================================================================
// 文件: AngelscriptRuntime/Dump/AngelscriptStateDump.cpp:386
// 角色: Modules 表头 + 一行（节选）
// ============================================================================
Header = { TEXT("ModuleName"), TEXT("CodeSectionCount"),
           TEXT("CodeHash"),                   // ★ 角色 2 的自身 hash
           TEXT("CombinedDependencyHash"),     // ★ 角色 2 的传染 hash
           TEXT("ClassCount"), ... };

Row = { Module->ModuleName, LexToString(Module->Code.Num()),
        LexToString(Module->CodeHash),
        LexToString(Module->CombinedDependencyHash),
        LexToString(Module->Classes.Num()), ... };
```

走法：控制台 `as.DumpEngineState`，CSV 在 `Saved/AngelscriptDump/Modules.csv`。同行可比对两份 hash 是否符合 import 拓扑预期。

### 9.3 验证 PrecompiledData 与 .jit.cpp 配对

`RT_StaticJIT.md` §10.1 已经讲过 `as.StaticJIT.DumpDiagnostics`：

```text
StaticJIT diagnostics: PrecompiledDataGuid=A1B2C3D4-...
StaticJIT diagnostics: CompiledInfoGuid=A1B2C3D4-...
StaticJIT diagnostics: CompiledInfoMatchesPrecompiledData=true
```

不一致就会日志里看到 `Transpiled code will not be used!`。

### 9.4 常见 metadata 失效

| 症状 | 可能原因 |
|------|---------|
| BP 编辑器不显示 ToolTip | `WITH_EDITOR` 关闭 / 注释格式被判为非紧邻 |
| Category 进了 BP 但分组错 | specifier 被覆盖：`Category="A"` 后又有 `Meta=(Category="B")` |
| `EditAnywhere` 没生效 | 误用 `EditDefaultsOnly`，CPF flag 不同 |
| 父类 metadata 没继承到子类 | `InheritMetaDataFromSuperClass` 必须在 Finalize 阶段调用 |

---

## 附录 A：hash 来源速查

| Hash | 算法 | 输入 | 输出 | 何处算 | 何处用 |
|------|------|------|------|--------|--------|
| `Section.CodeHash` | XXH64 | `ProcessedCode` | int64 | `Preprocessor::Process` 末尾 | 聚合到 Module->CodeHash |
| `Module->CodeHash` | XOR | 所有 Section.CodeHash | int64 | 同上 | PrecompiledData 装载时 == 比对 |
| `Module->CombinedDependencyHash` | XOR | self.CodeHash + 所有 import.CombinedDep | int64 | `CompileModule_Types_Stage1` | 挂 asCModule.userData[0] |
| `FAngelscriptPrecompiledData::DataGuid` | `FGuid::NewGuid()` | 时钟+熵 | FGuid 128bit | cook 期构造 | 与 `FStaticJITCompiledInfo::Get()->PrecompiledDataGuid` 比对 |
| `BuildIdentifier` | 静态 switch | 编译宏 | int32 (1/2/3/4/-1) | PrecompiledData 实例 | `IsValidForCurrentBuild` |
| `FunctionId` | StrCrc_DEPRECATED + HashCombine | 模块名 + userdata + 类名 + 函数声明 | uint32 | `CreateFunctionId` | `FStaticJITFunction::Register(Id)` 与 lookup |
| `GetTypeHash(T)` 系列 | 类型自定义 | 类型实例 | uint32 | UE Core / Bind_*.cpp | TMap/TSet KeyFuncs |
| `CityHash32/64` | UE CityHash | bytes | uint32/uint64 | `Bind_Hash.cpp` | AS 端用户脚本可调用 |
| `FFilenamePair` | `HashCombine(GetTypeHash(Abs), GetTypeHash(Rel))` | 文件路径对 | uint32 | `AngelscriptEngine.h:1429` | TSet/TMap 的 Filename key |

---

## 附录 B：metadata 查询 API 速查

| API | 返回 | 推荐场景 |
|-----|------|----------|
| `Field->HasMetaData(K)` | bool | 仅判断"有没有" |
| `Field->GetMetaData(K)` | const FString& | 必拿到值，且一定存在 |
| `Field->FindMetaData(K)` | const FString* | **首选**：合并 Has + Get，单次 TMap 查 |
| `Field->RemoveMetaData(K)` | void | swap-in 时把上次冲突的 key 清掉 |
| `Field->SetMetaData(K, V)` | void | sink：仅 ClassGenerator 在 Finalize 阶段调用 |
| `Enum->SetMetaData(K, V, ValueIndex)` | void | 枚举值级（不是枚举本身） |

热路径上**永远用 `FindMetaData`**，参考 `Helper_FunctionSignature.h` 的 Opt 2 注释。

---

## 附录 C：避坑清单

1. **不要把 `CodeHash` 当签名**：它是 XOR 聚合的 64-bit XXH64，能用于变更检测但不是 cryptographic。完整性签名走 `DataGuid` + `BuildIdentifier`。
2. **`uint32 Hash() const` 必须是 const 方法**：`GetMethodByDecl(TEXT("uint32 Hash() const"))` 是字符串精确匹配，少一个 const 就找不到。
3. **AS struct 当 TMap 键**：脚本端写 `Hash()` 方法即可，无需手动注册——`FASStructOps::SetFromStruct` 自动检测。
4. **GUID 不一致一定先查 cook 命令行**：`-as-generate-precompiled-data` 必须传；交付时 .jit.cpp 与 .Cache 必须成对；.jit.cpp 在源码控制系统中要 binary diff、不要 merge。
5. **`FunctionId` 与 `CombinedDependencyHash` 强耦合**：依赖路径上任何文件变了都让 ID 飘——这是设计意图（hot reload 后老 jit 不再适用）。但意味着 cooked build 不能"只换一个文件而不重 cook 整个 transpile 集"。
6. **WITH_EDITOR 关闭后 metadata 全部丢失**：cooked Shipping/Test 不写 SetMetaData，BlueprintCallable 函数仍然能调用（CPF flag 还在），但 BP 编辑器看不到 Category/ToolTip——这是**故意**的，节省内存。
7. **`StrCrc_DEPRECATED` 不能换**：插件代码故意保留 DEPRECATED 名字版的 CRC，因为 cook 出来的 .jit.cpp 用同一个算法。换 hash 算法会让所有现存 cache 失效。
8. **`FAngelscriptType::GetHash` 基类是 `ensure(false)`**：不要让任何包装类型直接用基类的 GetHash——要么重写，要么 `CanHashValue` 返回 false。

---

## 附录 D：跨文档边界

| 主题 | 在哪里写 |
|------|---------|
| TMap KeyFuncs 的 GetTypeHash 用法 | `Syntax_TMap.md` |
| TSet 的 hash 通路 | `Syntax_TSet.md` |
| `FAngelscriptModuleDesc` 完整字段 | `Type_Preprocessor.md` §六 |
| PrecompiledData 详细 schema / Save / Load | `RT_StaticJIT.md` §三 |
| `FStaticJITCompiledInfo` 的 link-期固化机制 | `RT_StaticJIT.md` §四 |
| `bStaticJITTranspiledCodeLoaded` 全局位 | `RT_GlobalState.md` §1.3 |
| `OnPostReload` 后 metadata 反射重新写入 | `RT_HotReload.md` §七 |
| `Helper_FunctionSignature.h` 的 FindMetaData Opt 2 | `Type_BindSystem.md` |
| `FASStructOps` 与 fake vtable | `Type_StructGeneration.md` |
| ToolTip 注释格式化（`Helper_CommentFormat.h`） | `Type_Preprocessor.md` §四 |

---

## 小结

- 插件中"hash"不是单一系统，而是四个职责完全不同的角色：**容器键 hash**（GetTypeHash 桥接）/ **模块内容指纹**（XXH64+XOR 聚合）/ **cooked artifact 校验**（FGuid+BuildIdentifier）/ **函数 ID 派生**（StrCrc+HashCombine）；它们互不替代，加在一起构成 cache 一致性的多重护栏。
- 容器键 hash 通过 `FAngelscriptType::CanHashValue/GetHash` 虚函数 + `TModels<CGetTypeHashable>` 静态分派两条线收口；脚本端 `uint32 Hash() const` 方法是 UE 类型 hash 缺失时的兜底入口。
- 模块 `CodeHash` 是 XXH64 算 `ProcessedCode`、XOR 聚合所有 Section；`CombinedDependencyHash` 把 import 闭包传染进来，挂到 `asCModule.userData[0]`，给 cook 期 `CreateFunctionId` 加盐。
- cooked artifact 完整性靠 `FGuid DataGuid`（cache 与 .jit.cpp 配对）+ `BuildIdentifier`（Debug/Dev/Test/Shipping 隔离）双重比对；任一不匹配触发不同级别的"清空" —— GUID 不匹配仅清 jit 入口表回到解释器，BuildIdentifier 不匹配整盘抛弃 cache。
- Metadata 三源合流：注释（仅 WITH_EDITOR）/ specifier 白名单 / UHT 已存反射；前两者填进 `FAngelscriptClassDesc::Meta` 等描述符，最后由 `AngelscriptClassGenerator` 在 Finalize 阶段 `SetMetaData` 抄写到 UE 反射树；`Function->FindMetaData(K)` 是合并 `HasMetaData + GetMetaData` 的热路径优化首选。
- 调试三件套：`as.DumpEngineState` 看每模块 CodeHash / CombinedDependencyHash、`as.StaticJIT.DumpDiagnostics` 看 GUID 配对、`Property->FindMetaData(K)` 看运行期 metadata。
