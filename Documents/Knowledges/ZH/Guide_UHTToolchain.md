# Guide_UHTToolchain — UHT 工具链使用与注意事项（C++ 工程师视角）

> **所属前缀**: Guide_（实践指南族）
> **关注层面**: 站在"我是一个写 UE C++ 的业务工程师"视角看 `AngelscriptUHTTool`——我应该怎么标 `UCLASS / UFUNCTION / UPROPERTY` 让 UHT 自动给我生成绑定？哪些事要做、哪些事不要做、何时这条路径不够要退回手写 `Bind_*.cpp`、产物长什么样、出错怎么排查、与 HotReload / BlueprintImpact 是不是同一条链路？不深入 C# UHT plugin 内部的 `AngelscriptHeaderSignatureResolver` 实现细节（那是 `Arch_UHTToolchain.md` 的职责）；不深入 `Build.cs` 的非默认 flag（那是 `Note_UBT.md` 的职责）；不重复"反射兜底 vs UHT Runtime-linked vs 手写 Bind"的三层模型决策树（那是 `Guide_ClassBinding.md` §一的职责）
> **适用读者**: 你在项目里写 UE C++，会标 `UFUNCTION(BlueprintCallable)`，希望脚本作者能直接调用——但不想了解插件内部实现
> **前置知识**: 看完 `Documents/Knowledges/ZH/Guide_QuickStart.md` 至少前 6 个案例（知道脚本侧"消费"你的 C++ 类型时长什么样）；了解 UE 反射宏 `UCLASS / UFUNCTION / UPROPERTY`
> **关联文档**:
> `Documents/Knowledges/ZH/Guide_ClassBinding.md` — 三层路径决策树（本文是其 §三 UHT 自动一节的深入展开）
> · `Documents/Knowledges/ZH/Guide_QuickStart.md` — 脚本侧消费现场
> · `Documents/Knowledges/ZH/Arch_UHTToolchain.md` — 维护者视角：C# UBT plugin 的实现细节（深入阅读）
> · `Documents/Knowledges/ZH/Note_UBT.md` — UBT 构建约束：`.uplugin / Build.cs / .ubtplugin.csproj` 配置面（深入阅读）
> · `Documents/Knowledges/ZH/Type_BindSystem.md` — 维护者视角：三层 fallback 模型（深入阅读）

---

## 概览

本文聚焦一个核心问题：**我作为 UE C++ 工程师，写一行 `UFUNCTION(BlueprintCallable)`，UHT 工具链就会替我把这个函数暴露给 `.as` 脚本。我需要做什么？什么时候不够？怎么排查它没生效？**

`AngelscriptUHTTool` 是一套构建期 C# UBT plugin，跟 UE 自带的 UnrealHeaderTool 共生。每次 build 时它会：扫描你的 C++ 头里所有 `UCLASS + UFUNCTION(BlueprintCallable / BlueprintPure)`，按项目级 `FunctionBindingMethod` 生成 `AS_FunctionBinding_<Module>_<NNN>.cpp` 分片，编入 `AngelscriptRuntime.dll` 或目标模块，让脚本侧像调 C++ 一样直接调用——**整个过程零手写代码**。

```text
================================================================================
       你的 .h 文件                       UHT 工具链做的事
================================================================================

  YourGame/Public/MyActor.h                    [构建期]
  ┌─────────────────────────────┐              ┌──────────────────────────┐
  │ UCLASS()                    │              │ UnrealBuildTool 启动      │
  │ class AMyActor : public     │              │  ▼                       │
  │   AActor {                  │   ─扫描─→    │ UnrealHeaderTool 解析     │
  │   UFUNCTION(BlueprintCallable)│            │  ▼                       │
  │   void Fire();              │              │ AngelscriptUHTTool       │
  │   UPROPERTY()               │              │ [UhtExporter] 拉取        │
  │   int32 Ammo;               │              │  ▼                       │
  │ };                          │              │ 生成 AS_FunctionBinding_*.cpp│
  └─────────────────────────────┘              │  ▼                       │
                                                │ 编入 AngelscriptRuntime  │
                                                └──────────────────────────┘
                                                          │
                                                          ▼ [运行期]
  Script/MyGame/Test.as                                AS 引擎初始化时
  ┌─────────────────────────────┐              ┌──────────────────────────┐
  │ AMyActor A = ...;           │   ─调用→     │ FAngelscriptFunctionBinding 表查找          │
  │ A.Fire();                   │              │ NativeRuntimeLinked → native │
  │ A.Ammo = 30;                │              │ ReflectiveFallback → 反射 │
  └─────────────────────────────┘              └──────────────────────────┘
```

**关键定位**：UHT 工具链不是"另一种 binding 写法"——它是**反射宏的自动延伸**。你写 `UFUNCTION(BlueprintCallable)` 是为了让 BP 看到，UHT 顺手让 AS 也看到，**几乎不需要额外操心**。

后续章节按"工具链是什么 → 你只需要做什么 → 你不需要做什么 → 何时不够 → 产物在哪 → 读懂 Summary → 增量缓存 → 常见错误 → 查表诊断 → 与 BlueprintImpact 的非协同 → 附录"的顺序展开。

---

## 一、UHT 工具链是什么，跑在什么时候

### 1.1 一句话定位

`AngelscriptUHTTool` 是一份 **C# UBT plugin**（`.NET 8.0` 类库 DLL），通过 `[UhtExporter]` 协议挂入 UnrealHeaderTool 流水线。它**在你 build 项目时跑**，**不在 UE 进程内跑**。

```text
                        UHT 工具链的时序位置

构建期（UnrealBuildTool 进程内，C# 环境）       ★ UHT 工具在这里运行
    │
    ├── UBT 启动
    ├── 扫描 *.ubtplugin.csproj，build 出 .dll
    ├── UnrealHeaderTool 解析所有 UCLASS / UFUNCTION 头
    ├── ★ 调 AngelscriptUHTTool 写 AS_FunctionBinding_*.cpp
    └── UBT 按 FunctionBindingMethod 编入 Runtime 或目标模块
                            │
                            ▼ [构建结束]
运行期（UE 进程内，C++ 环境）                   UHT 已经退出
    │
    ├── UE 进程启动
    ├── AngelscriptRuntime.dll 加载
    ├── 静态构造期：AS_FunctionBinding_*.cpp 内的 FBind 入队
    └── FAngelscriptEngine::Initialize → 回放 Bind → AS 类型表就绪
```

**直接结论**：

- **改 `.h` 头文件 = 触发 UHT 重跑**（增量；只重跑受影响模块）
- **改 `.as` 脚本 = 不触发 UHT**（脚本走 HotReload 链路，与 UHT 无关）
- **UE 进程已经在跑 = UHT 早已退出，改 .h 必须重启进程**才能生效

### 1.2 它扫什么、不扫什么

UHT 工具链**只**关心 `UFUNCTION(BlueprintCallable)` 与 `UFUNCTION(BlueprintPure)` 这两个 flag。其他 UE 反射元素的处理路径不同：

| UE 反射元素 | 谁处理 | 你需要怎么标 |
|------------|--------|-------------|
| `UCLASS` 类型本身 | 反射兜底 + UHT 协作 | 标 `UCLASS()` 即可，类自动出现在 AS |
| `USTRUCT` 类型 | 反射兜底 | 标 `USTRUCT(BlueprintType)`，字段 `UPROPERTY()` |
| `UPROPERTY` 字段 | 反射兜底 | 标 `UPROPERTY()`（读写自动可用） |
| `UFUNCTION(BlueprintCallable)` | **UHT 工具** | 标 `UFUNCTION(BlueprintCallable)` |
| `UFUNCTION(BlueprintPure)` | **UHT 工具** | 标 `UFUNCTION(BlueprintPure)` |
| `UFUNCTION(Server / Client / NetMulticast)` | UHT + RPC 框架 | RPC 修饰符自动传到脚本侧 |
| `UFUNCTION(BlueprintEvent)` | 类生成器 | 不走 UHT，由 ClassGenerator 桥接 |
| `UENUM` | 反射兜底（`Bind_Enums`） | 标 `UENUM(BlueprintType)`，自动覆盖 |
| `DECLARE_DYNAMIC_*_DELEGATE` | `Bind_Delegates` | 写 UE 标准宏即可 |
| `mixin / ScriptMixin` | FunctionLibrary 链路 | UHT **不读** mixin，单独走（参 `Guide_ScriptMixin.md`） |

**记住**：UHT 工具链**只**为 `BlueprintCallable / Pure` 函数生成绑定。USTRUCT 上的 method、UENUM、Delegate、mixin 都不是它的职责。

---

## 二、你只需要做的两件事

### 2.1 ① 标对反射宏

```cpp
// ============================================================================
// 文件: YourGame/Public/MyWeaponSystem.h
// 角色: 普通业务 C++ 类——零行 binding 代码，UHT 自动覆盖
// ============================================================================
UCLASS()
class YOURGAME_API UMyWeaponSystem : public UActorComponent
{
    GENERATED_BODY()

public:
    // 字段：UPROPERTY 即可，脚本读写自动可用（反射兜底）
    UPROPERTY(BlueprintReadWrite, Category="Weapon")
    int32 CurrentAmmo = 30;

    UPROPERTY(BlueprintReadWrite, Category="Weapon")
    float ReloadTime = 1.5f;

    // 函数：BlueprintCallable 让 UHT 知道要为 AS 生成绑定
    UFUNCTION(BlueprintCallable, Category="Weapon")
    void Fire();

    UFUNCTION(BlueprintCallable, Category="Weapon")
    bool TryReload(float OverrideTime);

    UFUNCTION(BlueprintPure, Category="Weapon")
    int32 GetAmmoCount() const { return CurrentAmmo; }

    // ★ 静态 BlueprintCallable 也能覆盖
    UFUNCTION(BlueprintCallable, Category="WeaponMath")
    static float ComputeDamage(int32 BaseDamage, float Multiplier);
};
```

——就这。**没有任何额外 binding 代码**。下次 build 时 UHT 会扫到这个头，把 4 个 `BlueprintCallable / Pure` 函数加到生成的 `AS_FunctionBinding_<Module>_<NNN>.cpp` 里，脚本侧立即可用：

```angelscript
// ============================================================================
// 文件: Script/MyGame/Test.as
// 角色: 脚本作者直接调用，无需任何注册
// ============================================================================
class APlayerWithWeapon : APawn
{
    UPROPERTY(DefaultComponent)
    UMyWeaponSystem WeaponSystem;

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        WeaponSystem.CurrentAmmo = 60;       // ★ UPROPERTY 字段
        WeaponSystem.Fire();                  // ★ BlueprintCallable 方法
        bool bOk = WeaponSystem.TryReload(2.0);
        int32 N = WeaponSystem.GetAmmoCount();
        float Dmg = UMyWeaponSystem::ComputeDamage(10, 1.5);  // ★ 静态方法
    }
};
```

### 2.2 ② 把模块加入绑定数组

UHT 不会主动扫描整个引擎。Runtime-linked 模式下，把模块加入项目自己的编译选项配置，UBT 会同步添加 `AngelscriptRuntime` 的合法依赖并生成 wrapper：

```ini
[/Script/AngelscriptRuntime.AngelscriptCompileOptions]
FunctionBindingMethod=NativeRuntimeLinked
+NativeRuntimeLinkedModules=YourGame
```

`NativeRuntimeLinkedModules` 只能填写 `AngelscriptRuntime` 能合法依赖的模块；依赖不存在或形成 UBT 依赖环时，构建直接失败。不要再通过手工修改 `AngelscriptRuntime.Build.cs` 维护这份绑定列表。

如果使用目标模块函数地址模式，模块应放入独立的显式数组：

```ini
[/Script/AngelscriptRuntime.AngelscriptCompileOptions]
FunctionBindingMethod=NativeModuleFunctionAddress
+NativeModuleFunctionAddressModules=YourGame
```

这个模式不把 `YourGame` 反向链接进 `AngelscriptRuntime`，而是在 `YourGame` 自己的输出目录生成模块内 thunk；它要求源码版引擎，且只处理当前安全签名集合。构建版/安装版引擎会在 Editor、UBT 或 UHT 阶段拒绝该模式。

改完后**必须 rebuild**（不能只依赖 incremental build）。Runtime-linked 输出位于 `.../UHT/AS_FunctionBinding_YourGame_*.gen.cpp`；目标模块输出位于 `YourGame` 自己的 UHT 输出目录。

> **提示**：如果你不知道模块名，看 `<YourGame>/Source/<YourGame>/<YourGame>.Build.cs` 的类名，或确认它出现在本次 UHT session 中。

### 2.3 速记：标 + 配置数组 = 完事

```text
你的 C++ 头里：     UFUNCTION(BlueprintCallable / BlueprintPure)
DefaultAngelscriptCompileOptions.ini：+NativeRuntimeLinkedModules=你的模块
                                   │
                                   ▼ rebuild
                  AS_FunctionBinding_<你的模块>_<NNN>.cpp 自动生成
                                   │
                                   ▼ 脚本侧
                     YourClass.YourMethod()  直接可用
```

99% 的常规业务场景就这两步。剩下不到 1% 才需要走"手写 Bind_*.cpp"路径——参 §四与 `Guide_ClassBinding.md`。

---

## 三、你不需要做的事情

很多人第一次接触 UHT 工具链时会想"我是不是该手写一个 `AS_FunctionBinding_MyModule.cpp`？"——**不要**。下面这些事都**不**需要你做：

### 3.1 ✗ 不需要手写 `AS_FunctionBinding_*.cpp`

`AS_FunctionBinding_<Module>_<NNN>.cpp` 是**构建期产物**，路径在 `Plugins/Angelscript/Intermediate/Build/...`——`Intermediate/` 目录下的所有内容都是自动生成的，**任何手动改动都会被下次 build 覆盖**。也不要把这类文件 commit 进 git。

如果你看到自己写的 .cpp 文件名以 `AS_FunctionBinding_` 开头，那是错的——立刻删掉，改成 `Bind_<Topic>.cpp`（手写绑定）放到 `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/` 下，参 §四。

### 3.2 ✗ 不需要在 Build.cs 里给 UHT 工具单独配置

`AngelscriptUHTTool.ubtplugin.csproj` 是**插件维护者**维护的——业务工程师不需要碰。你也不需要在自己的 game module 的 `<YourGame>.Build.cs` 里写任何"启用 UHT 工具"的开关——UHT 工具靠扫描 `*.ubtplugin.csproj` 文件名自动启用，不需要你显式声明。

### 3.3 ✗ 不需要清理 `Intermediate/`

UHT 工具链**自带** `DeleteStaleOutputs` 逻辑——上一轮生成、本轮不需要的孤儿分片会被自动删除。你**不**需要手动 `rm Intermediate/Build/Win64/.../UHT/*.cpp` 之后再 build。

唯一例外：你怀疑 UHT 工具自身的 `.dll` 缓存出了问题（极少见），可以删 `Plugins/Angelscript/Binaries/DotNET/UnrealBuildTool/Plugins/AngelscriptUHTTool/` 强制 csproj 重 build。

### 3.4 ✗ 不需要为已有 UClass 写"补绑表"

如果 `AYourActor::Foo` 已经被 UHT 自动覆盖（你能在 `AS_FunctionBinding_*.cpp` 里 grep 到它），就**不要**再去 `Bind_AYourActor.cpp` 手写一份 `Method("void Foo()", ...)`——会引发"重复注册"警告。AS 端 `RegisterFunctionBinding` 是先到先得，但手写 Bind 直接调 `RegisterObjectMethod` 会跟 UHT 路径冲突。

正确做法：UHT 已覆盖 → 不动；UHT 没覆盖（你想要 `?&` 模板 / lambda 转换 / 自定义运算符） → 手写 Bind。

### 3.5 ✗ 不需要为 mixin / FunctionLibrary 担心 UHT

UHT **不读** `meta=(ScriptMixin="...")` 这类 meta——mixin 走另一条路径（`Bind_Defaults` @ `EOrder::Late + 100`）。你给 `FunctionLibraries/` 下加新 mixin 时不需要担心 UHT 配置——参 `Guide_ScriptMixin.md`。

---

## 四、UHT 处理不了什么：何时退回手写 Bind

UHT 工具链是 95% 场景的最优解，但有 5% 的场景它做不到。下面这些情况要走手写 `Bind_*.cpp`（详见 `Guide_ClassBinding.md` §四）：

### 4.1 不在 `BlueprintCallable / BlueprintPure` 表面的函数

```cpp
// ✗ UHT 看不到这两类
UFUNCTION()
void MyHelper();         // 没 BlueprintCallable / Pure

void RawCppFunction();   // 完全没 UFUNCTION
```

修复路径：要么加 `BlueprintCallable`（前提是你愿意让 BP 也看到）；要么手写 Bind。

### 4.2 USTRUCT 上的方法

UHT 工具链**只**生成 UCLASS 上的 BlueprintCallable / Pure 函数——USTRUCT 上的 UFUNCTION method **不**生成绑定，即使标了也不会出现在 AS 端。

```cpp
USTRUCT(BlueprintType)
struct FMyDamageInfo
{
    GENERATED_BODY()
    UPROPERTY() float Amount = 0.0f;          // ✓ 字段反射兜底自动覆盖

    UFUNCTION(BlueprintCallable)              // ✗ UHT 不为 USTRUCT 生成
    bool IsLethal() const { return Amount >= 100.0f; }
};
```

修复路径首选 **mixin**（最便宜、最 idiomatic）：写一个 `FunctionLibraries/MyDamageInfoLibrary.h` 标 `UCLASS(meta=(ScriptMixin="FMyDamageInfo"))`，把 `static bool IsLethal(const FMyDamageInfo& Info)` 写进去——脚本侧自动得到 `Damage.IsLethal()`。详见 `Guide_ScriptMixin.md`。

### 4.3 头在 `/Private/` 下

UHT 跳过 `/Private/` 路径下的所有头文件。修复路径：把声明挪到 `/Public/`；或保持 `/Private/` 但写手写 Bind。

### 4.4 类标了 `MinimalAPI` 或方法不在 `_API` 宏下

UHT 需要**直接拿到函数指针**才能生成 `ERASE_AUTO_METHOD_PTR(...)` Runtime-linked——这要求函数能跨 dll link。`UCLASS(MinimalAPI)` 是 UE 常见标注，"只导出 RTTI、不导出方法"——这种类的方法 UHT 会写 `ERASE_NO_FUNCTION()` reflectiveFallback，让运行期反射 fallback 兜底。

```cpp
UCLASS(MinimalAPI)              // ★ 类只导出 RTTI
class AMinimalAPIActor : public AActor
{
    GENERATED_BODY()
    UFUNCTION(BlueprintCallable)
    void Foo();                 // ★ UHT 会 reflectiveFallback 这个

    UFUNCTION(BlueprintCallable)
    YOURGAME_API void Bar();    // ★ 单条方法导出，UHT 能Runtime-linked
};
```

**这不算"失败"**——脚本仍然能调用 `Actor.Foo()`，但走的是反射 fallback（性能比Runtime-linked慢约 3-6 倍）。如果你的函数是热点路径，去掉 `MinimalAPI` 让类整体导出，或单独给该方法加 `_API` 宏。

### 4.5 需要 `?&` 模板 / 自定义运算符 / lambda 转换

脚本里写 `Foo(?&out OutValue)` 让脚本作者在调用点指定输出类型——这种"AS 特化签名"UHT 完全做不到，必须手写 Bind。其他必须手写的场景：

- 注册 `opAdd / opEquals / opCmp` 等运算符（脚本里 `A + B`）
- 注册自定义构造（`FMyType(A, B, C)`）
- 命名空间投影（`MyGame::SomeFunc(...)`）
- 跨类型转换运算符（`opConv`）
- 超过 16 参的 UFUNCTION（反射 fallback 上限是 16）

### 4.6 `CustomThunk` 函数 / 显式不暴露

`UFUNCTION(CustomThunk)` 反射元数据不完整，UHT 显式跳过。要在 AS 暴露需要走手写 Bind（罕见且复杂），通常交给 BP 即可。

加 `UFUNCTION(BlueprintCallable, meta=(NotInAngelscript))` 或 `meta=(BlueprintInternalUseOnly)` 让脚本看不到——这是**唯一可靠**的"屏蔽 AS 暴露"机制，UHT 与反射兜底两路都尊重。

---

## 五、生成产物在哪、长什么样

### 5.1 产物路径

UHT 产物落到 `AngelscriptRuntime` 模块的 `Intermediate` 目录下：

```text
Plugins/Angelscript/Intermediate/Build/<Platform>/<Target>/Inc/AngelscriptRuntime/UHT/
├── AS_FunctionBinding_AIModule_000.cpp          ← AIModule 模块的分片之一
├── AS_FunctionBinding_Engine_000.cpp            ← Engine 模块的 16 个分片之一
├── AS_FunctionBinding_Engine_001.cpp
├── ...
├── AS_FunctionBinding_Engine_015.cpp
├── AS_FunctionBinding_UMG_000.cpp
├── AS_FunctionBinding_UMG_001.cpp
├── AS_FunctionBinding_UMG_002.cpp
├── AS_FunctionBinding_<YourModule>_000.cpp      ← 你的模块的分片
│
├── AS_FunctionBindingStatistics.json              ← 全局总目录（人类可读）
├── AS_FunctionBindingModuleStatistics.csv         ← 每模块汇总
├── AS_FunctionBindingDiagnostics.csv               ← 逐条目清单
├── AS_FunctionBindingSkippedFunctions.csv        ← 跳过的逐条目
└── AS_FunctionBindingSkippedFunctionStatistics.csv  ← 跳过原因聚合
```

`<Platform>` = `Win64` / `Mac` / `Linux`；`<Target>` = `UnrealEditor` / `UnrealGame` / 其他自定义 target。

> **关键约定**：这是 `Intermediate/`，**不**进 git，**不**手动改。如果你的 IDE 把这些当源码加进了项目视图，那是 UE Solution 自动生成的——把 .cpp 当只读看待。

### 5.2 单个分片长什么样

下面是真实的 `AS_FunctionBinding_AIModule_000.cpp` 节选（来自当前 baseline）：

```cpp
// ============================================================================
// 文件: Intermediate/.../UHT/AS_FunctionBinding_AIModule_000.cpp
// 性质: UHT 生成产物示例（156 entries / 1 shard for AIModule）
// ============================================================================
PRAGMA_DISABLE_DEPRECATION_WARNINGS
#include "CoreMinimal.h"
#include "Core/AngelscriptBinds.h"
// ... 30+ 行 include 省略

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_AS_FunctionBinding_AIModule_000(
    (int32)FAngelscriptBinds::EOrder::Late + 50, []()
{
    // ★ NativeRuntimeLinked（UHT 拿到了 native 函数指针）
    FAngelscriptBinds::RegisterFunctionBinding(AAIController::StaticClass(), "ClaimTaskResource",
        { ERASE_AUTO_METHOD_PTR(AAIController, ClaimTaskResource) });

    // ★ ReflectiveFallback（UHT 拿不到指针，运行期反射 fallback）
    FAngelscriptBinds::RegisterFunctionBinding(AAIController::StaticClass(), "GetAIPerceptionComponent",
        { ERASE_NO_FUNCTION() });
    // ... 150+ 行 function binding 省略
});
PRAGMA_ENABLE_DEPRECATION_WARNINGS
```

**两类 function binding**：

- `ERASE_AUTO_METHOD_PTR(...)` — **NativeRuntimeLinked**（最优）：UHT 拿到了真实的 native 函数指针，调用时无任何反射开销
- `ERASE_NO_FUNCTION()` — **ReflectiveFallback**：UHT 拿不到符号（私有函数 / `MinimalAPI` 类 / 重载未消歧），运行期由 `Bind_BlueprintCallable.cpp` 的反射 fallback 兜底

——这两类 function binding 在 AS 调用时**对脚本作者透明**：你都能调到，只是性能差几倍。

### 5.3 切片规则：每分片 ≤ 256 entries

单个 UE 模块按 `MaxEntriesPerShard = 256` 切分——`Engine` 有 4054 个 function binding，所以切出 16 个分片：`AS_FunctionBinding_Engine_000.cpp` ... `_015.cpp`。你不需要关心切片，它纯粹是构建优化。

---

## 六、读懂 `Summary.json`：覆盖率与模块分布

`AS_FunctionBindingStatistics.json` 是一份人类可读的总目录，给你（或 CI / 监控脚本）检视用。当前 baseline 看上去这样：

```json
// 文件: AS_FunctionBindingStatistics.json（节选）
{
  "totalAnalyzedFunctions": 5835,
  "totalNativeRuntimeLinkedCount": 3358,
  "totalReflectiveFallbackCount": 2477,
  "nativeRuntimeLinkedRate": 0.5755,
  "totalShardCount": 29,
  "modules": [
    { "moduleName": "Engine",   "totalAnalyzedFunctions": 4239, "nativeRuntimeLinkedRate": 0.4936, "shardCount": 17 },
    { "moduleName": "AIModule", "totalAnalyzedFunctions": 156,  "nativeRuntimeLinkedRate": 0.6987, "shardCount": 1 },
    { "moduleName": "UMG",      "totalAnalyzedFunctions": 767,  "nativeRuntimeLinkedRate": 0.8787, "shardCount": 3 },
    { "moduleName": "AngelscriptRuntime", "totalAnalyzedFunctions": 252, "nativeRuntimeLinkedRate": 0.7341, "shardCount": 1 },
    // ... 8 个其他模块省略
  ]
}
```

### 6.1 关注三个数字

- **`totalAnalyzedFunctions`** = 5835：UHT 一共分析了多少 `BlueprintCallable / Pure` 函数。会随项目添加新 UFUNCTION 自然增长。
- **`nativeRuntimeLinkedRate`** ≈ 0.58：当前 baseline 中约 58% 的函数使用 Runtime-linked，剩余函数走运行期反射 fallback。
- **`modules`**：被覆盖的 UE 模块及其统计。若刚加入 `NativeRuntimeLinkedModules`，rebuild 后应看到对应模块和 shard。

### 6.2 排查"我的模块为什么不在 Summary 里"

```text
搜不到自己的模块名 "YourGame"
        │
        ├── UHT 没扫到 → 模块没加到 Build.cs（§二.2）→ 改 Build.cs + rebuild
        └── 有这一行但 function binding=0 → 模块里没有 BlueprintCallable / Pure 函数 → 标对反射宏
```

### 6.3 关注模块Runtime-linked率的差异

不同模块Runtime-linked率差很大：`UMG` ≈ 88%（导出充分）、`NavigationSystem` ≈ 79%、`AIModule` ≈ 70%、`Engine` ≈ 48%（庞大且大量 `MinimalAPI`）、`GameplayTags` = 0%（整体 `MinimalAPI`，全部 reflectiveFallback）。

**Runtime-linked率低不等于"绑定坏了"**——脚本仍能调用，只是经反射兜底慢一些。如果你的项目某个热点函数经常被脚本调，且它在 reflectiveFallback 一栏（grep `AS_FunctionBindingSkippedFunctions.csv`），可以考虑给类去掉 `MinimalAPI` 或单独给方法加 `_API` 宏。

---

## 七、增量与缓存：什么时候 UHT 会重跑

UHT 工具链没有自己实现 hash / mtime 增量——它直接吃 UBT 的依赖追踪。下表总结哪些改动会触发 UHT 重跑：

| 你改动的内容 | UHT 是否重跑 | 解释 |
|-------------|------------|------|
| 你的 `.h` 头文件（加 / 改 / 删 UFUNCTION） | ✓ 重跑 | UBT 把每个被扫描过的 `.h` 标记为 UHT 的输入 |
| `AngelscriptRuntime.Build.cs`（加新依赖模块） | ✓ 重跑 | UHT 显式声明 Build.cs 为 external dependency |
| 你的 `.cpp` 源文件（不影响反射元数据） | ✗ 不跑 | UHT 只读 `.h`，不读 `.cpp` |
| `.as` 脚本文件 | ✗ 不跑 | UHT 完全不读 `.as`（脚本走 HotReload 链路） |
| `Documents/` 文档 | ✗ 不跑 | 与 UBT / UHT 完全脱钩 |
| `Plugins/Angelscript/Intermediate/` 内容 | ✗ 不跑 | 这本身就是产出目录 |

**关键性质**：UHT 重跑后，如果新生成的 `AS_FunctionBinding_<Module>_<NNN>.cpp` 与上一轮**内容完全相同**，UBT 用内容 hash 比对会**不写盘**——下游的 `AngelscriptRuntime.dll` 不重链接。这是"我加了一个 UFUNCTION 但 build 后什么都没变"的常见原因：UBT 检测到产物没变，跳过链接。

### 7.1 强制 UHT 重跑

如果你怀疑增量缓存出错（极少见），有几条强制路径：

```powershell
# 路线 A：删 Intermediate 强制全量重生
Remove-Item -Recurse -Force "Plugins/Angelscript/Intermediate/Build"

# 路线 B：清 .ubtplugin DLL 缓存（极少需要）
Remove-Item -Recurse -Force "Plugins/Angelscript/Binaries/DotNET/UnrealBuildTool/Plugins/AngelscriptUHTTool"

# 然后正常 build
.\Tools\RunBuild.ps1
```

正常情况下你不需要走这些路线——UHT 的增量已经很可靠。

---

## 八、常见错误与诊断

### 8.1 错误 A：脚本报"Type 'AYourActor' is not declared"

**症状**：你写了 `UCLASS()` + 一些 `BlueprintCallable` 方法，但脚本里 `AYourActor A; A.Foo();` 编译期挂了。

**典型原因排序**：

1. **模块没加到 `AngelscriptRuntime.Build.cs`**（最常见）—— 看 §二.2
2. **Build.cs 改了但没 rebuild**—— UHT 必须 rebuild，不能 incremental
3. **类在 `/Private/` 下**—— UHT 跳过私有头，挪到 `/Public/`
4. **类标了 `meta=(NotInAngelscript)`** —— 反射兜底也会跳过
5. **module 是 EditorOnly 但你在 cooked client target 下跑**—— EditorOnly 模块不在 cooked 时被编入

**诊断三步**：① grep `Summary.json` 是否含你的模块；② 看 `AS_FunctionBinding_<YourModule>_*.cpp` 是否存在；③ 编辑器 `as.DumpEngineState` 后看 `Saved/AngelscriptStateDump/AS_TypeRegistry.csv`。

### 8.2 错误 B："Method 'Foo' not found"——但类型存在

**症状**：脚本能用 `AYourActor`，但调 `A.Foo()` 时编译期报"找不到方法"。

**典型原因**：

1. **`Foo()` 没标 `UFUNCTION(BlueprintCallable / BlueprintPure)`**
2. **`Foo()` 标了 `meta=(NotInAngelscript)` / `BlueprintInternalUseOnly`**
3. **`Foo()` 是 USTRUCT 上的方法**——UHT 不为 USTRUCT 生成，需要 mixin
4. **`Foo()` 是 `CustomThunk`**——UHT 显式跳过

**诊断**：grep `AS_FunctionBindingSkippedFunctions.csv` 找 `Foo`——若看到 `YourModule,AYourActor,Foo,non-public` 是访问修饰符问题；其他原因见 §八.4。

### 8.3 错误 C：脚本能调，但跑得很慢

**症状**：函数能调用，但脚本的 profiler 显示这条路径耗时异常高。

**典型原因**：UHT 给这个函数写了 reflectiveFallback，运行期走反射 fallback（慢约 3-6 倍）。

**诊断**：在 `AS_FunctionBinding_<Module>_*.cpp` 里 grep 你的方法名——

- `ERASE_AUTO_METHOD_PTR(...)` —— Runtime-linked，不慢；问题在别处
- `ERASE_NO_FUNCTION()` —— reflectiveFallback，反射 fallback 在跑

修复路径：让 UHT 能拿到符号——参 §四.4（去掉 `MinimalAPI` 或加 `_API` 宏）。

### 8.4 跳过原因三类

`AS_FunctionBindingSkippedFunctionStatistics.csv` 在 baseline 看上去：

```text
FailureReason,SkippedCount
non-public,2314                 ← 函数声明在 protected/private
unexported-symbol,1263          ← class 没有 _API 宏（如 MinimalAPI）
overloaded-unresolved,282       ← 重载消歧失败（多候选签名都对不上反射类型）
```

| 原因 | 含义 | 修复路径 |
|------|------|---------|
| `non-public` | `UFUNCTION` 在 `protected:` / `private:` 下 | 改成 `public:` 或接受 reflectiveFallback |
| `unexported-symbol` | 类用了 `MinimalAPI` 或方法没有 `_API` 宏 | 去掉 `MinimalAPI` 或单条加 `_API` |
| `overloaded-unresolved` | 同名多重载，UHT 没法消歧 | 改名其中一个 / 加 `meta=(ScriptName="...")` |

### 8.5 错误 D：改了 `Build.cs` 加新模块但 UHT 没生成

**症状**：你在 `AngelscriptRuntime.Build.cs` 加了 `"YourGame"`，rebuild 后 `Summary.json` 还是没出现 `YourGame`。

**典型原因**：

1. **没真的 rebuild**——只是 incremental build。`Build.cs` 改了必须 rebuild。
2. **加错了位置**——必须加在 `PrivateDependencyModuleNames.AddRange(...)` 这一段里。`LoadSupportedModules` 只识别这一类引号字符串数组。
3. **加的模块名拼错**——大小写敏感，必须跟 `<YourGame>.Build.cs` 类名完全一致。

### 8.6 错误 E：编译失败——某个 `#include` 找不到

**症状**：build 时报 `AS_FunctionBinding_YourGame_000.cpp: #include "<YourHeader.h>" not found`。

**典型原因**：你的模块的 `PublicIncludePaths` 配置不当——某个 `/Public/` 下的子目录没被 export 到 include 路径。**修复**：在你的 `<YourGame>.Build.cs` 加 `PublicIncludePaths.Add(Path.Combine(ModuleDirectory, "Public", "SubDir"));`，或把 .h 挪到 `Public/` 根目录。

---

## 九、查看哪些 UFUNCTION 进了哪一层

调试时常需要回答："这个函数 X 到底是 UHT Runtime-linked、UHT reflectiveFallback + 反射兜底，还是手写 Bind 覆盖？"

```text
                 你的方法 AYourActor::Foo
                            │
         ┌──────────────────┴──────────────────┐
         ▼                                     ▼
 grep AS_FunctionBinding_*.cpp        grep Bind_*.cpp
   找 "Foo"                           找 "Foo" 或 "AYourActor"
         │                                     │
   ┌─────┴─────┐                          ┌────┴────┐
   ▼           ▼                          ▼         ▼
ERASE_AUTO_  ERASE_NO_                   有匹配     无匹配
METHOD_PTR   FUNCTION()                                
   │           │                          │         │
   ▼           ▼                          ▼         ▼
 Layer B：    Layer C：                  Layer A：  完全不在表
 UHT Runtime-linked     UHT reflectiveFallback +                 手写 Bind  → 函数没绑
              反射 fallback                          （检查 §八.1）
```

**两个查表入口**：

- **`as.DumpEngineState`**（编辑器控制台）：把当前 AS 引擎状态导出到 `Saved/AngelscriptStateDump/`，27+ 份 CSV。重点看 `AS_TypeRegistry.csv`（所有已注册类型）、`AS_ClassMethods.csv`（每个类的方法）、`AS_ReflectiveFallbackBindings.csv`（走反射 fallback 的方法）。详见 `RT_StateDump.md`。
- **`LogAngelscript`**（Saved/Logs）：UHT 分片在执行 Bind 时打日志：
  ```
  LogAngelscript: [UHT] Registered 156 generated BlueprintCallable entries for module AIModule shard 1/1 in 2.341 ms
  LogAngelscript: [UHT] Generated function binding summary: total = 5685, NativeRuntimeLinked= 3186, reflectiveFallback= 2499 ...
  ```
  某个模块的日志根本没出现 = 它没出现在 `Build.cs` 依赖里。

---

## 十、与 BlueprintImpact / HotReload 的非协同

许多人会问："我改了 UHT 工具或新加了一批 UFUNCTION，是不是要重跑 BlueprintImpact 扫描？热重载会不会受影响？"

**答案：完全不需要协同**。三条链路彼此独立：

```text
.as 脚本改动                    UHT 工具改动 / .h 改动             BP 改动
   │                                  │                              │
   ▼                                  ▼                              ▼
HotReload                     UBT / UHT 增量                BlueprintImpact 扫描
+ ClassReloadHelper           AS_FunctionBinding_*.cpp 重生成    BP 重编决策
   │                                  │                              │
   ▼                                  ▼                              ▼
脚本类在编辑器中               必须重启 UE 进程才生效          BP 资产被标脏
重新实例化                    （.dll 重链接，不能热重载）      下次重编时重新链接
```

操作上的影响：

- **改 `.h` UFUNCTION 签名**：build → 重启 UE 进程 → 关心的 BP 重编时会自动用新签名。
- **改 `AngelscriptRuntime.Build.cs` 加新模块**：rebuild → 重启 UE 进程 → 新模块的所有 `BlueprintCallable` 函数立即可用。
- **改 `.as` 脚本**：HotReload 自动覆盖；与 UHT 工具完全无关。
- **改 BP 资产**：BlueprintImpact 决定哪些受影响 BP 需要重编；与 UHT 工具完全无关。

你**不**需要因为 UHT 输出变化而重跑 BlueprintImpact——它扫的是 `.as` 脚本对 BP 的影响，UHT 产物变化走 C++ 重编路径，BP 重链接由 UE 标准 OnLoad 流程处理。

---

## 附录 A：UHT 工具链产物速查

| 路径 / 文件 | 类别 | 谁写 | 何时写 | 作用 |
|------------|------|------|--------|------|
| `Source/AngelscriptUHTTool/*.cs` | 源码 | 插件维护者 | OpenSpec 提案 | UHT plugin 实现 |
| `Source/AngelscriptUHTTool/*.csproj` | 配置 | 插件维护者 | 几乎不改 | C# 项目文件 |
| `Binaries/DotNET/UnrealBuildTool/Plugins/AngelscriptUHTTool/*.dll` | 产物 | UBT | 构建期 | UHT plugin DLL |
| `Intermediate/.../AS_FunctionBinding_<Module>_<NNN>.cpp` | 产物 | UHT | 头改动 / Build.cs 改动 | 分片绑定源码 |
| `Intermediate/.../AS_FunctionBindingStatistics.json` | 产物 | UHT | 同上 | 全局指标（人类可读） |
| `Intermediate/.../AS_FunctionBindingModuleStatistics.csv` | 产物 | UHT | 同上 | 每模块覆盖率 |
| `Intermediate/.../AS_FunctionBindingDiagnostics.csv` | 产物 | UHT | 同上 | 逐条目快照 |
| `Intermediate/.../AS_FunctionBindingSkippedFunctions.csv` | 产物 | UHT | 同上 | 跳过逐条（排错用） |
| `Intermediate/.../AS_FunctionBindingSkippedFunctionStatistics.csv` | 产物 | UHT | 同上 | 跳过原因分布 |

`<Platform>` = `Win64` / `Mac` / `Linux`；`<Target>` = `UnrealEditor` / `UnrealGame` / 自定义 target。

---

## 附录 B：排错决策树

```text
"我加了 UFUNCTION(BlueprintCallable) 但脚本看不到 / 调不到"
        │
        ▼
Q1：Summary.json 里有你的模块吗？
        │
   ┌────┴────┐
   否        是
   │         │
   ▼         ▼
模块没加进 Build.cs        Q2：AS_FunctionBinding_<你的模块>_*.cpp 里有这个函数名吗？
（§二.2）                          │
                              ┌────┴────┐
                              否        是
                              │         │
                              ▼         ▼
                          看 SkippedEntries.csv    Q3：是 ERASE_AUTO_METHOD_PTR 还是 ERASE_NO_FUNCTION？
                          找跳过原因                       │
                              │                       ┌───┴───┐
                              ▼                       AUTO    NO_FUNCTION
            ┌─────────────────┼─────────────────┐     │       │
            ▼                 ▼                 ▼     ▼       ▼
    non-public           unexported-       overloaded-   Runtime-linked成功    走反射 fallback
    （§四.4 / §八.4）   symbol            unresolved   性能 OK      性能慢；但能调
                       （§四.4）         （§八.4）                 调不到 → 看 LogAngelscript
                                                                    + as.DumpEngineState
```

```text
"我改了 Build.cs 但 UHT 没生效"
        │
        ▼
Q1：是 incremental build 还是 rebuild？
   │
   incremental  rebuild
   │            │
   ▼            ▼
强制 rebuild    Q2：Build.cs 的 AddRange 写法对吗？
                    │
                    错（拼接 / 循环）   对（直接字符串）
                    │                  │
                    ▼                  ▼
                改成直接字符串数组   Q3：Intermediate 完全没动？
                                        │
                                        ▼
                                    删 Plugins/Angelscript/Intermediate/Build/
                                    再 build
```

---

## 附录 C：常见误解速查

| 误解 | 实情 |
|------|------|
| "UHT 工具会读我的 .as 脚本" | ✗ UHT 只读 C++ 头与 `Build.cs`；脚本侧反射在运行期由 ClassGenerator 处理 |
| "我得手写 `AS_FunctionBinding_MyModule.cpp`" | ✗ 这是构建期产物，手写会被覆盖；补绑请写 `Bind_*.cpp` |
| "UHT 跟 BlueprintImpact 联动" | ✗ 两者在不同进程、不同时机、不同输入面 |
| "改了 UHT 工具的 .cs 应该能热重载" | ✗ 必须重 build C# DLL + 重启 UBT；UE 进程内无热重载机制 |
| "nativeRuntimeLinkedRate < 60% 是绑定坏了" | ✗ Runtime-linked率受 `MinimalAPI` / public / `_API` 影响；reflectiveFallback 仍能调用，只是慢 |
| "USTRUCT 上的 UFUNCTION 会被自动暴露" | ✗ UHT 只处理 UCLASS；USTRUCT 上的方法走 mixin 或手写 Bind |
| "加 `meta=(NotInAngelscript)` 反射也看不到" | ✓ UHT 与反射兜底两路都尊重——这是唯一可靠的"对 AS 不可见"渠道 |
| "UHT 失败时 build 会挂" | ✗ 多数情况只记录到 SkippedEntries.csv，构建继续 |
| "必须给类加 `_API` 宏才能被脚本看到" | ✗ 没 `_API` 也能调，只是走反射兜底；前提是函数标了 `BlueprintCallable / Pure` |

---

## 小结

- **UHT 工具链是构建期 C# UBT plugin**，跟 UE 自带的 UnrealHeaderTool 共生。它在 build 时跑、不在 UE 进程内跑；它**只**为 `UFUNCTION(BlueprintCallable / BlueprintPure)` 生成绑定，其他反射元素（USTRUCT method / UENUM / Delegate / mixin）走别的路径。

- **你只需要做两件事**：① 在 `.h` 里标对 `UCLASS / UFUNCTION(BlueprintCallable / Pure) / UPROPERTY`；② 把你的 module 加到 `AngelscriptRuntime.Build.cs` 的 `PrivateDependencyModuleNames`。然后 rebuild，脚本侧立即可用。

- **你不需要做的事**：手写 `AS_FunctionBinding_*.cpp`（产物）、配置 `.ubtplugin.csproj`（维护者维护）、清 Intermediate/（自动）、为 UHT 已覆盖的方法补手写 Bind（会冲突）、为 mixin 担心 UHT（mixin 走另一条路径）。

- **何时退回手写 Bind**：函数没标 `BlueprintCallable / Pure`、USTRUCT 上的 method、`/Private/` 头、需要 `?&` 模板 / 运算符 / lambda 转换、`CustomThunk` 函数。详见 `Guide_ClassBinding.md` §四。

- **产物在 `Intermediate/Build/<Plat>/<Tgt>/Inc/AngelscriptRuntime/UHT/`**：30 个 `AS_FunctionBinding_*.cpp` 分片 + `Summary.json` + 4 份 CSV。`Summary.json` 给出全局Runtime-linked率（baseline ~56%），每模块独立Runtime-linked率，是排查覆盖率退化的第一手依据。

- **诊断三步走**：① 看 `Summary.json` 是否含你的模块；② grep `AS_FunctionBinding_*.cpp` 看你的方法是 `ERASE_AUTO_METHOD_PTR` 还是 `ERASE_NO_FUNCTION`；③ 看 `SkippedEntries.csv` 找跳过原因（`non-public` / `unexported-symbol` / `overloaded-unresolved`）。

- **与 HotReload / BlueprintImpact 不联动**：UHT 产物变化只能通过 UE 进程重启来生效；BP 重链接由 UE 标准 OnLoad 处理，与 UHT 输出变化解耦。.as 脚本改动从不触发 UHT。

- **想深入实现细节，请去 `Arch_UHTToolchain.md`**（C# UBT plugin 内部机制：HeaderResolver / SignatureBuilder / 切片规则）与 `Note_UBT.md`（`Build.cs / .ubtplugin.csproj / .uplugin` 配置面）。
