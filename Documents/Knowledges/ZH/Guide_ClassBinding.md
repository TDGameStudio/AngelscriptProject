# Guide_ClassBinding — C++ 类 / 枚举 / 委托绑定暴露给 AS（C++ 工程师视角）

> **所属前缀**: Guide_（实践指南族）
> **适用读者**: 在项目里写 C++ 的工程师——你手里有一个 `UCLASS` / `USTRUCT` / `UENUM` / `DECLARE_DYNAMIC_*_DELEGATE`，想让 `.as` 脚本能调用、读写、Cast、Bind，但不打算研究插件内部实现细节。
> **前置知识**: 看完 `Documents/Knowledges/ZH/Guide_QuickStart.md` 至少前 6 个案例（知道脚本作者会怎么"用"你的类型）；了解 UE 反射宏 `UCLASS / UFUNCTION / UPROPERTY / UENUM / USTRUCT`。
> **关联 Knowledges**:
> `Documents/Knowledges/ZH/Guide_QuickStart.md` —— 脚本侧消费视角
> · `Documents/Knowledges/ZH/Guide_ScriptMixin.md` —— mixin 注入完整指南（本文 §六 只做导引）
> · `Documents/Knowledges/ZH/Guide_DelegateSystem.md` —— delegate / event 在脚本侧的完整玩法
> · `Documents/Knowledges/ZH/Guide_UHTToolchain.md` —— UHT 工具链使用与注意事项（用户视角）
> · `Documents/Knowledges/ZH/Type_BindSystem.md` —— 维护者视角的三层模型（深入阅读）
> · `Documents/Knowledges/ZH/Type_Core.md` —— `FAngelscriptType` 数据库（深入阅读）
> · `Documents/Knowledges/ZH/Type_BaseClass.md` —— UClass Runtime-linked骨架（深入阅读）
> · `Documents/Knowledges/ZH/Type_FunctionLibrary.md` —— FunctionLibrary 暴露面（深入阅读）
> · `Documents/Knowledges/ZH/Arch_UHTToolchain.md` —— UHT 工具链构建期边界（深入阅读）
> · `Documents/Knowledges/ZH/Note_InterfaceBinding.md` —— UInterface 现状清单

---

## 概览

本文聚焦一个核心问题：**我手里有一个 C++ 类型，怎样以最低成本让 `.as` 脚本看见它？**

`Type_BindSystem.md` 已经从维护者视角讲清楚了"125 份 `Bind_*.cpp` + 30+ 份 UHT 生成的 `AS_FunctionBinding_*.cpp` + `Bind_Defaults` 反射兜底"三层模型。本文翻过来，只回答一个问题——**作为业务侧 C++ 工程师，你应该走哪一层？**

```text
                你的 C++ 类型 → 让脚本能用，三条路径

      ┌─────────────────────────────────────────────────────────────┐
      │  ① 反射兜底（最便宜，0 行 .cpp 代码）                        │
      │     ─────────────────────────────────────────────           │
      │     在你的 .h 上加 UFUNCTION(BlueprintCallable) /          │
      │     UPROPERTY() / UCLASS() / UENUM(BlueprintType)           │
      │     ─→ Bind_Defaults @ Late+100 自动扫到 → 走               │
      │     UFunction::Invoke + FFrame 反射 trampoline              │
      │     代价：性能比Runtime-linked慢 3–6 倍；最多 16 个参数                 │
      └────────────────┬────────────────────────────────────────────┘
                       │ 不够快？需要 > 16 参 / CustomThunk？
                       ▼
      ┌─────────────────────────────────────────────────────────────┐
      │  ② UHT 自动生成（中等成本，由构建期生成）                    │
      │     ─────────────────────────────────────────────           │
      │     UHT 工具链扫所有 BlueprintCallable / Pure 头文件         │
      │     ─→ 构建期自动写出 AS_FunctionBinding_*.cpp 分片            │
      │     ─→ FuncPtr 直接命中 exec* thunk，避免反射                 │
      │     你只需把模块加到 AngelscriptRuntime.Build.cs 依赖         │
      │     代价：依赖 UCLASS 公开头；不走 .as 文件；不处理 mixin     │
      └────────────────┬────────────────────────────────────────────┘
                       │ 还是不够？需要脚本特化签名 / lambda / ?& 模板？
                       ▼
      ┌─────────────────────────────────────────────────────────────┐
      │  ③ 手写 Bind_*.cpp（高成本，但最自由）                       │
      │     ─────────────────────────────────────────────           │
      │     写一份 Plugins/Angelscript/Source/AngelscriptRuntime/   │
      │     Binds/Bind_<YourType>.cpp，顶部写一个 FBind 全局对象      │
      │     ─→ Lambda 内调 ValueClass / ReferenceClass /             │
      │        ExistingClass + Constructor / Method / Property        │
      │     代价：每条 method 都要手写签名；维护成本高                 │
      │     收益：可以写 ?& 模板、lambda 转换、特化运算符、no_discard │
      └─────────────────────────────────────────────────────────────┘
```

后续章节按 **决策树 / UHT 自动 / 反射兜底 / 手写 Bind / 暴露 USTRUCT / 暴露 UENUM / 暴露 Delegate / mixin 与 FunctionLibrary 导引 / 命名约定 / 测试 / 调试 / 附录** 的顺序展开。如果你只看一节，直接翻到 §一 决策树。

---

## 一、决策树：你应该用哪一层？

### 1.1 三个问题就能定路径

```text
                 我有一个 C++ 类型 / 函数 / 枚举 / Delegate
                                  │
                  ┌───────────────┴───────────────┐
                  ▼                                ▼
        Q1：它已经有 UCLASS /              否：纯 C++ 类型
        UFUNCTION / UPROPERTY /            （不是 UE 反射对象）
        UENUM 反射宏吗？                   ─→ 必须手写 Bind_*.cpp
                  │                            （走 §四）
                 是
                  ▼
        Q2：它的所属模块在
        AngelscriptRuntime.Build.cs
        的 PrivateDependencyModuleNames 里吗？
                  │
              ┌───┴───┐
              否       是
              ▼        ▼
         加进 .Build.cs   Q3：你需要
         即可（让 UHT     脚本端有"特化签名"
         自动跑到）       （?& 模板 / 自定义参数转换 /
                          lambda / no_discard / namespace）吗？
                              │
                          ┌───┴────┐
                         否         是
                          ▼          ▼
                  ① 反射兜底     ③ 手写 Bind_*.cpp
                  + UHT 自动     （走 §四）
                  （走 §二、§三）
```

### 1.2 三个权衡维度

| 维度 | 反射兜底 | UHT 自动 | 手写 Bind |
|------|---------|---------|----------|
| 写代码的成本 | 0（只要 UFUNCTION 标对） | ≈ 0（自动生成） | 中–高（每条 method 一行 + 签名） |
| 调用性能 | 慢（`UFunction::Invoke`） | 快（直接函数指针） | 最快（lambda + JIT 友好） |
| 签名灵活度 | 死板：只能镜像 UFUNCTION 签名 | 死板：UHT 按反射元数据生成 | 全自由：lambda / ?& / 默认参数 |
| 参数上限 | ≤ 16 个非返回参数 | ≤ UFUNCTION 上限 | 无上限 |
| 维护成本 | 0 | 0（构建期自动跑） | 类升级时所有签名都要改 |
| 谁能写 | 任何业务 C++ 工程师 | 任何业务 C++ 工程师 | 插件维护者（要懂 AS 框架） |
| 适合场景 | 普通业务函数 | 模块级批量暴露 | 数学结构 / 容器 / 运算符 |

### 1.3 一句话路线推荐

- **写新 gameplay 代码** → 反射兜底足够，加 `UFUNCTION(BlueprintCallable)` 就行
- **想让一整个模块（GameplayAbilities / 你的子系统）批量暴露** → 把模块加进 `AngelscriptRuntime.Build.cs`，UHT 会自动 cover
- **要给已有 UClass 补几条 helper** → 写 `FunctionLibraries/<X>Library.h`，标 `UCLASS(meta=(ScriptMixin="..."))`（详见 §六 与 `Guide_ScriptMixin.md`）
- **想让脚本写 `MyVector + OtherVector`** → 必须手写 `Bind_*.cpp` 注册 `opAdd` 运算符
- **不在 UE 反射体系里的纯 C++ 类型**（如某个 `template<>` POD） → 必须手写

---

## 二、第一层：反射兜底（你不写一行 .cpp 也能跑）

### 2.1 它在做什么

插件启动期 `Bind_Defaults`（`EOrder::Late + 100`）会**遍历所有 UClass**，对每个 `UFUNCTION(BlueprintCallable)` / `BlueprintPure` 检查：

1. 这个 UFunction 在 UHT 表里有直接函数指针吗？
2. 没有？那就给它包一层 `UFunction::Invoke + FFrame` 反射 trampoline，注册到 AS 引擎

**结论**：只要你的函数标了 `BlueprintCallable`，**根本不用写任何 binding 代码，脚本就能调用**——只是性能比 UHT Runtime-linked慢约 3–6 倍。这条路径在维护者文档 `Note_InterfaceBinding.md` §三的 Phase 5 与 `Type_BindSystem.md` §六.3 有完整描述。

### 2.2 最小示例：让一个 helper 函数被脚本看见

```cpp
// ============================================================================
// 文件: YourGame/Public/MyHelpers.h
// 角色: 业务侧普通 C++ 类，0 行 binding 代码
// ============================================================================
UCLASS()
class YOURGAME_API UMyHelperLibrary : public UBlueprintFunctionLibrary
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable, Category="MyGame")
    static int32 AddOne(int32 Value) { return Value + 1; }

    UFUNCTION(BlueprintPure, Category="MyGame")
    static FString FormatScore(int32 Score) { return FString::Printf(TEXT("Score=%d"), Score); }
};
```

脚本侧自动可用：

```angelscript
// ============================================================================
// 文件: Script/MyGame/MyTest.as
// ============================================================================
void TestHelper()
{
    int32 Next = UMyHelperLibrary::AddOne(41);              // = 42
    FString Pretty = UMyHelperLibrary::FormatScore(100);    // "Score=100"
    Print(Pretty);
}
```

**没有任何 `Bind_MyHelper.cpp`**——AS 引擎初始化时 `Bind_Defaults` 自动把它扫进类型表。

### 2.3 反射兜底覆盖什么 / 不覆盖什么

```text
┌─ 覆盖 ─────────────────────────────────────────────────────────────┐
│  • UFUNCTION(BlueprintCallable)                                    │
│  • UFUNCTION(BlueprintPure)                                        │
│  • UFUNCTION(BlueprintCallable, Category=...) 等带 meta 的变体     │
│  • UPROPERTY() 字段（读 / 写均支持）                                │
│  • UCLASS / USTRUCT / UENUM 类型本身（自动出现在脚本里）            │
│  • Server / Client / NetMulticast RPC（脚本侧调用走标准 ProcessEvent│
└────────────────────────────────────────────────────────────────────┘
┌─ 不覆盖 ───────────────────────────────────────────────────────────┐
│  • 非 UFUNCTION 的普通 C++ 函数（要手写 Bind 或加 UFUNCTION 宏）    │
│  • UFUNCTION 但参数 > 16 个（超过 fallback 上限，必须 UHT Runtime-linked）     │
│  • UFUNCTION(CustomThunk)（被显式 skip，除非你也 NotInAngelscript）  │
│  • UFUNCTION(BlueprintInternalUseOnly) 但没标 UsableInAngelscript    │
│  • UFUNCTION(meta=(NotInAngelscript))                                │
│  • UInterface 上的方法（CLASS_Interface 在 fallback 黑名单里）        │
│  • UClass::GetOwner（手写已绑，避免冲突）                            │
│  • 运算符 / Cast / 隐式转换（必须手写）                              │
│  • USTRUCT 上的方法 method（USTRUCT 字段可读写，但 method 通常要手写） │
└────────────────────────────────────────────────────────────────────┘
```

### 2.4 让函数对 AS **不可见**：`NotInAngelscript`

如果某个 `BlueprintCallable` 函数你不希望脚本看到（比如内部 helper 不想暴露），加一行 meta：

```cpp
// ============================================================================
// 文件: YourGame/Public/SomeAdminPanel.h
// ============================================================================
UFUNCTION(BlueprintCallable, meta=(NotInAngelscript))
void AdminOnlyDangerousReset();        // ★ 脚本编译期看不到这个符号
```

这是**唯一**强力屏蔽 BlueprintCallable 函数的渠道。配合 `UsableInAngelscript`（用在 BP-internal 上）可以做更细粒度的开闸/关闸。

### 2.5 反射兜底的"15-参数边界"实战

`BlueprintCallableReflectiveFallbackMaxArgs = 16`。如果你的 UFUNCTION 有 17 个参数（除返回值之外），fallback 会拒绝注册——脚本编译期表现为"找不到该方法"。这种 case 罕见但存在；典型修复方案是：

- 把多个参数打包成一个 USTRUCT（推荐）
- 拆成两次调用
- 或者上手写 Bind（走 §四）

---

## 三、第二层：UHT 自动生成

### 3.1 你只做一件事：把模块加进 `Build.cs`

UHT 工具链 `AngelscriptUHTTool` 在构建期反向解析 `Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs` 的 `PrivateDependencyModuleNames`，**只为 list 中出现的模块生成绑定**。这意味着——

```cs
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/AngelscriptRuntime.Build.cs
// ============================================================================
PrivateDependencyModuleNames.AddRange(new string[] {
    "Engine", "CoreUObject", "AIModule", "UMG",
    "GameplayAbilities", "GameplayTags", "EnhancedInput",
    "MyGameModule",            // ★ 加这一行，下次 build 你的模块就被自动扫描
});
```

加完之后 rebuild，UHT 会在
`Plugins/Angelscript/Intermediate/Build/<Plat>/<Tgt>/Inc/AngelscriptRuntime/UHT/AS_FunctionBinding_MyGameModule_*.cpp`
写出几个分片，自动编入 `AngelscriptRuntime.dll`。

### 3.2 UHT 自动生成什么 / 不生成什么

```text
┌─ 生成 ────────────────────────────────────────────────────────────┐
│  • UFUNCTION(BlueprintCallable / BlueprintPure)                   │
│  • UCLASS 在公开 header 中（/Public/ 或非 /Private/）              │
│  • Static 与成员 UFUNCTION 都能覆盖                                │
│  • Server / Client / NetMulticast RPC                             │
└───────────────────────────────────────────────────────────────────┘
┌─ 不生成 ──────────────────────────────────────────────────────────┐
│  • /Private/ 下的 header（私有头）                                 │
│  • UFUNCTION(meta=(NotInAngelscript))                              │
│  • UFUNCTION(BlueprintInternalUseOnly) 但缺 UsableInAngelscript    │
│  • UFUNCTION(CustomThunk)                                          │
│  • mixin（ScriptMixin meta）—— UHT 不读，要靠 Bind_Defaults 处理    │
│  • .as 文件（UHT 不读 .as，只读 C++ 头）                           │
│  • 模板函数 / 没出现在反射元数据里的纯 C++ 函数                     │
└───────────────────────────────────────────────────────────────────┘
```

详细边界见 `Arch_UHTToolchain.md`。脚本作者视角的工具链使用注意事项见 `Guide_UHTToolchain.md`。

### 3.3 你怎么知道 UHT 跑没跑成功？

构建产物里有几个文件可以看：

```text
Plugins/Angelscript/Intermediate/Build/<Plat>/<Tgt>/Inc/AngelscriptRuntime/UHT/
├── AS_FunctionBinding_Engine_0.cpp       ← UE Engine 模块的分片之一
├── AS_FunctionBinding_Engine_1.cpp
├── AS_FunctionBinding_GameplayAbilities_0.cpp
├── ...
└── AS_FunctionBindingStatistics.json       ← 总览：每模块多少函数 / Runtime-linked率
```

打开 `Summary.json` 能看到每个模块"覆盖了多少 BlueprintCallable / Runtime-linked成功多少 / 走 reflectiveFallback 多少"。如果你的模块名根本不在 Summary 里——多半是 `Build.cs` 还没加。

---

## 四、第三层：手写 `Bind_*.cpp`（你需要写什么）

> **注意**：本节展示"你需要写什么"，**不**展示插件框架内部如何调度这些代码。深入实现细节（`FBind` 构造时机 / `BindArray` 排序 / `CallBinds` 回放）请阅读 `Type_BindSystem.md`。

### 4.1 最小骨架：一个 POD 数学结构

假设你有一个 `FMyVector2D`（一个简单的二维数学结构），希望脚本能像用 `FVector` 一样使用它：

```cpp
// ============================================================================
// 文件: YourGame/Public/MyVector2D.h
// ============================================================================
USTRUCT(BlueprintType)
struct YOURGAME_API FMyVector2D
{
    GENERATED_BODY()
    UPROPERTY(BlueprintReadWrite) double X = 0.0;
    UPROPERTY(BlueprintReadWrite) double Y = 0.0;

    FMyVector2D() = default;
    FMyVector2D(double InX, double InY) : X(InX), Y(InY) {}
    FMyVector2D operator+(const FMyVector2D& Other) const
    { return FMyVector2D(X + Other.X, Y + Other.Y); }
    bool operator==(const FMyVector2D& Other) const
    { return X == Other.X && Y == Other.Y; }
};
```

对应的手写 binding 文件——文件**必须**放在 `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/` 下，由插件维护者协助 review：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FMyVector2D.cpp
// 角色: 把 FMyVector2D 暴露给脚本，注册构造、运算符、字段
// ============================================================================
#include "AngelscriptBinds.h"
#include "AngelscriptEngine.h"
#include "YourGame/Public/MyVector2D.h"

AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_FMyVector2D(
    FAngelscriptBinds::EOrder::Early, []
{
    FBindFlags Flags;
    Flags.bPOD = true;
    Flags.ExtraFlags |= asOBJ_BASICMATHTYPE;

    auto FMyVector2D_ = FAngelscriptBinds::ValueClass<FMyVector2D>(
        "FMyVector2D", Flags);

    // 默认构造
    FMyVector2D_.Constructor("void f()", [](FMyVector2D* A) {
        new(A) FMyVector2D();
    });

    // 带参构造（脚本里 FMyVector2D V(1.0, 2.0)）
    FMyVector2D_.Constructor("void f(float64 X, float64 Y)",
        [](FMyVector2D* A, double X, double Y) {
            new(A) FMyVector2D(X, Y);
        });
    FAngelscriptBinds::SetPreviousBindNoDiscard(true);   // 禁止 FMyVector2D(1,2);

    // 字段
    FMyVector2D_.Property("float64 X", &FMyVector2D::X);
    FMyVector2D_.Property("float64 Y", &FMyVector2D::Y);

    // 运算符（让脚本能 A + B、A == B）
    FMyVector2D_.Method("FMyVector2D opAdd(const FMyVector2D& Other) const",
        METHODPR_TRIVIAL(FMyVector2D, FMyVector2D, operator+, (const FMyVector2D&) const));
    FMyVector2D_.Method("bool opEquals(const FMyVector2D& Other) const",
        METHODPR_TRIVIAL(bool, FMyVector2D, operator==, (const FMyVector2D&) const));
});
```

脚本侧立即可用：

```angelscript
// ============================================================================
// 文件: Script/MyGame/MyVector2DTest.as
// ============================================================================
void TestVec()
{
    FMyVector2D A(1.0, 2.0);
    FMyVector2D B(3.0, 4.0);
    FMyVector2D C = A + B;
    check(C.X == 4.0 && C.Y == 6.0);
}
```

### 4.2 三个核心函数：`ValueClass` / `ReferenceClass` / `ExistingClass`

| 函数 | 适合谁 | 一句话用途 |
|------|--------|-----------|
| `ValueClass<T>(name, flags)` | POD struct / 数学结构 / 容器 | 注册一个全新值类型（脚本里按值传递、栈上构造） |
| `ReferenceClass(name, UClass*)` | UClass 反射类型首次注册 | 把一个 UCLASS 注册成 AS 引用类型（`@` 句柄） |
| `ExistingClass(name)` | 给已被注册的类型补方法 | 不重复注册类型本身，只追加 `Method` / `Property` |

**99% 的业务场景**：

- 你有个 USTRUCT → 用 `ValueClass<T>(...)`
- 你有个 UCLASS 但还没人 binding 过 → 通常 UHT 已经覆盖；如果要补充手写方法用 `ExistingClass(name).Method(...)`
- 你有个完全脱离 UE 反射的纯 C++ 类 → 用 `ValueClass<T>(...)` 但手动管理生命周期（罕见）

### 4.3 给一个已绑定的 UClass 补充手写方法

如果 UHT 已经覆盖了 `AYourActor` 的所有 `UFUNCTION`，但你想加一条**带 `?&` 模板参数**的脚本特化方法（典型场景：`Foo(?&out OutValue)`）——这种方法 UHT 反射不支持，必须手写：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_AYourActor.cpp
// 节选自: 给已绑定 UClass 追加手写方法
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_AYourActor_Base(
    (int32)FAngelscriptBinds::EOrder::Late - 1, []
{
    auto AYourActor_ = FAngelscriptBinds::ExistingClass("AYourActor");

    // 一个 UHT 不支持的脚本特化签名：?& 让脚本在调用点指定输出类型
    AYourActor_.Method("void GetTypedComponent(?&out OutComp) const",
        [](const AYourActor* Self, void* OutPtr, int TypeId) {
            // 用 TypeId 反查 UClass，从 Self->GetComponents 里挑一个
            // ...
        });
});
```

### 4.4 加一个全局函数（不在任何类里）

如果你只是想加一个 free function，不属于任何类：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_MyGlobals.cpp
// ============================================================================
AS_FORCE_LINK const FAngelscriptBinds::FBind Bind_MyGlobals(
    FAngelscriptBinds::EOrder::Normal, []
{
    // 直接全局
    FAngelscriptBinds::BindGlobalFunction("int32 RollD20()", FUNC_TRIVIAL(MyGlobals::RollD20));

    // 或者收纳到命名空间下
    {
        FAngelscriptBinds::FNamespace ns("MyGame");
        FAngelscriptBinds::BindGlobalFunction(
            "int32 ComputeScore(int32 Base, int32 Bonus)",
            FUNC_TRIVIAL(MyGlobals::ComputeScore));
    }
});
```

脚本里：

```angelscript
int v = RollD20();              // 全局
int s = MyGame::ComputeScore(10, 3);   // 命名空间形式
```

### 4.5 选 `EOrder` 的简易版规则

```text
你的 Bind 注册的是…                推荐 EOrder
────────────────────────────────  ─────────────────────────
全新的 POD 数学结构                EOrder::Early
全新的容器模板（罕见）              EOrder::Early
依赖 FString / FName / FVector
等已存在类型的二级类型              EOrder::Early + 1
全局函数 / FunctionLibrary 风格     EOrder::Normal（默认）
给一个核心 UClass 补 5–10 条方法    EOrder::Late - 1
跨类型转换运算符（FFoo↔FBar）       EOrder::Late + 10
不确定                              EOrder::Normal，跑一次看顺序日志
```

完整阶段语义见 `Type_BindSystem.md` §二.3。**强烈建议**：写新的 Bind 时跟现有同类 `Bind_*.cpp` 保持一致——例如新数学结构对齐 `Bind_FBox.cpp`（Early 主体 + Late 二级方法），新 UClass 补充对齐 `Bind_AActor.cpp`。

### 4.6 完整一行 Method 的解构

```cpp
FMyVector2D_.Method("FMyVector2D opAdd(const FMyVector2D& Other) const",
    METHODPR_TRIVIAL(FMyVector2D, FMyVector2D, operator+, (const FMyVector2D&) const));
```

| 片段 | 作用 |
|------|------|
| `"FMyVector2D opAdd(...) const"` | AS 端**签名字符串**——脚本编译器看到的就是这个 |
| `METHODPR_TRIVIAL` | 处理函数重载的 4-arg 宏：`(返回类型, 类名, 方法名, 参数列表)` |
| `METHOD_TRIVIAL` | 同上但用于无重载情形（3-arg） |
| `FUNC_TRIVIAL` | 自由函数（非成员） |
| `_TRIVIAL` 后缀 | 告诉 StaticJIT "这条调用可以原地内联"，性能更好 |

---

## 五、暴露 USTRUCT（值类型）

### 5.1 第一选择：UHT 自动 + UPROPERTY

```cpp
// ============================================================================
// 文件: YourGame/Public/MyDamageInfo.h
// ============================================================================
USTRUCT(BlueprintType)
struct YOURGAME_API FMyDamageInfo
{
    GENERATED_BODY()
    UPROPERTY(BlueprintReadWrite) float Amount = 0.0f;
    UPROPERTY(BlueprintReadWrite) FName DamageType = NAME_None;
    UPROPERTY(BlueprintReadWrite) AActor* Instigator = nullptr;
};
```

**这就够了**——脚本侧立即可用：

```angelscript
FMyDamageInfo D;
D.Amount = 25.0;
D.DamageType = n"Fire";
D.Instigator = SomeActor;
```

USTRUCT 字段读写、构造、拷贝都由插件框架自动处理（`Type_StructGeneration.md` 描述实现细节）。

### 5.2 USTRUCT 上的 method 通常要手写

UHT 工具**只**生成 UCLASS 的 BlueprintCallable 函数。USTRUCT 上的方法（即使 `UFUNCTION` 标了），通常要走"手写补函数"或"BlueprintFunctionLibrary 风格"路径之一：

**选项 A**：在 `FunctionLibraries/` 下做成 mixin（推荐，参 §六 与 `Guide_ScriptMixin.md`）

```cpp
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/MyDamageInfoLibrary.h
UCLASS(meta=(ScriptMixin="FMyDamageInfo"))
class UMyDamageInfoLibrary : public UObject
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintPure)
    static bool IsLethal(const FMyDamageInfo& Info)
    {
        return Info.Amount >= 100.0f;
    }
};
```

脚本侧自动可用 `Damage.IsLethal()`。

**选项 B**：手写 `Bind_FMyDamageInfo.cpp` 注册成员方法（与 §四.1 同样模式，但用 `ExistingClass`）。

### 5.3 USTRUCT 暴露面速查

| 想暴露什么 | 推荐路径 |
|----------|---------|
| 字段读写 | `UPROPERTY(BlueprintReadWrite)` 即可 |
| 默认构造 / 拷贝 / 析构 | 自动（USTRUCT 反射体系处理） |
| `operator+` / `operator==` 等运算符 | 必须手写 Bind_*.cpp |
| `IsLethal()` / `Format()` 等 helper | mixin（FunctionLibraries） |
| 显式带参构造（`FMyDamageInfo(Amount, Type)`） | 手写 Bind_*.cpp 的 `Constructor` |
| `ToString()` | 通常注册到 `FToStringHelper`（手写） |

---

## 六、暴露 UENUM（最便宜，几乎不用手写）

### 6.1 一行也不用写：UE 反射自动覆盖

`Bind_Enums`（`EOrder::Early - 1`）启动时通过 `TObjectRange<UEnum>` 遍历**所有引擎已知的枚举**，按规则自动注册：

```cpp
// 你只要正常加 UENUM 标记即可
UENUM(BlueprintType)
enum class EMyAttitude : uint8
{
    Friendly,
    Neutral,
    Hostile,
};
```

脚本侧立即可用：

```angelscript
EMyAttitude A = EMyAttitude::Friendly;
if (A == EMyAttitude::Hostile) { /* ... */ }
```

### 6.2 排除规则（哪些 UENUM 不会暴露）

源码中 `ShouldBindEngineType` 函数实现了过滤逻辑——通常不需要你关心，但有几个边界 case 要知道：

```text
✗ 不暴露：UENUM(meta=(NotBlueprintType))
✗ 不暴露：UENUM(meta=(NotInAngelscript))
✗ 不暴露：EObjectTypeQuery / EDateTimeStyle（硬编码 skip，避免与其他绑定冲突）
✗ 不暴露：UUserDefinedEnum 在 /Script/Angelscript/ 包下（来自 .as 自身）
✓ 其余 BlueprintType / 普通 UENUM 全部自动覆盖
```

### 6.3 命名空间形式 vs 全局形式

`UENUM` 在脚本里默认是**作用域形式**（必须 `EMyAttitude::Friendly`）。如果你的 enum 是 `UENUM(BlueprintType)` + 普通 `enum`（非 `enum class`），脚本侧会以全局名访问——具体规则见 `AS_LanguageSyntax.md`。**经验法则**：所有新 enum 都用 `enum class`，更安全。

### 6.4 脚本侧 enum：可以从 .as 反向定义

`.as` 脚本作者也可以定义 `enum class EMyScriptEnum`，由 ClassGenerator 注册成 `UUserDefinedEnum`，反过来 C++ 可见——但这是**脚本侧消费视角**，不是本文重点，参 `Guide_QuickStart.md`。

---

## 七、暴露 Delegate（C++ 声明 + 脚本端 delegate / event 关键字）

### 7.1 C++ 端正常声明

UE 标准 dynamic delegate 宏：

```cpp
// ============================================================================
// 文件: YourGame/Public/MyEvents.h
// ============================================================================
DECLARE_DYNAMIC_DELEGATE_OneParam(FMyOnHit, AActor*, HitActor);

DECLARE_DYNAMIC_MULTICAST_DELEGATE_TwoParams(FMyOnGameOver,
    AActor*, Winner, int32, FinalScore);

// 作为 UPROPERTY 暴露
UCLASS()
class YOURGAME_API AMyArena : public AActor
{
    GENERATED_BODY()
public:
    UPROPERTY(BlueprintAssignable, Category="Events")
    FMyOnGameOver OnGameOver;
};
```

### 7.2 脚本侧自动可见

`Bind_Delegates.cpp` 在 `EOrder::Early` 阶段遍历所有 `UDelegateFunction`（也就是上面 `DECLARE_DYNAMIC_*_DELEGATE` 宏展开出的那个 UFunction），自动注册到 AS 端为：

- 单播 → `delegate void FMyOnHit(AActor HitActor)` 风格的 AS delegate 类型
- 多播 → `event void FMyOnGameOver(AActor Winner, int32 FinalScore)` 风格的 AS event 类型

脚本侧消费：

```angelscript
class AMyArenaController : AActor
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        AMyArena Arena = Cast<AMyArena>(GetOwner());
        if (Arena != nullptr)
            Arena.OnGameOver.AddUFunction(this, n"HandleGameOver");
    }

    UFUNCTION()
    void HandleGameOver(AActor Winner, int32 FinalScore)
    {
        Print(f"Game over! Winner={Winner.Name} Score={FinalScore}");
    }
};
```

完整玩法（绑定 / 解绑 / Broadcast / Sparse / Native delegate）见 `Guide_DelegateSystem.md` 和 `Syntax_DelegateEvent.md`。

### 7.3 脚本端可以直接声明新 delegate

`.as` 脚本作者也可以在脚本里写：

```angelscript
delegate void FOnScoreChanged(int NewScore);          // 单播
event void FOnLevelComplete(AActor Player, int Stars);  // 多播
```

这些会被预处理器识别后注册成 UE 反射 `UDelegateFunction`，反向 C++ 可见——这是消费侧能力，本文不展开。

---

## 八、mixin 与 FunctionLibrary：给已有类型挂功能扩展

### 8.1 什么时候用 mixin

场景：你有一个**已经存在**的 UE 类（`USceneComponent`、`AActor`、`FHitResult`），想给它加一些 helper 方法（"在 AS 里 `Comp.MyHelper()`"），但又**不想**修改引擎源码 / 不想给整个项目加一堆 `BlueprintCallable` 自由函数。

答案：写一份 `FunctionLibraries/<X>Library.h`，标 `UCLASS(meta=(ScriptMixin="USceneComponent"))`：

```cpp
// ============================================================================
// 文件: Plugins/Angelscript/Source/AngelscriptRuntime/FunctionLibraries/AngelscriptComponentLibrary.h
// 角色: 给 USceneComponent 注入 GetRelativeLocation 等 mixin 方法
// 节选自: 真实工程文件（仅取首条作样本）
// ============================================================================
UCLASS(meta = (ScriptMixin = "USceneComponent"))
class UAngelscriptComponentLibrary : public UObject
{
    GENERATED_BODY()
public:
    UFUNCTION(BlueprintCallable)
    static FVector GetRelativeLocation(const USceneComponent* Component)
    {
        return Component->GetRelativeLocation();
    }

    UFUNCTION(BlueprintCallable, Meta=(ScriptName="SetRelativeRotation",
                                       NotAngelscriptProperty))
    static void SetRelativeRotationQuat(USceneComponent* Component,
                                        const FQuat& NewRotation)
    {
        Component->SetRelativeRotation(NewRotation);
    }
    // ... 数十个静态 helper
};
```

`ScriptMixin = "USceneComponent"` 那一行 meta 让插件在 `EOrder::Late + 100` 阶段把每个 `static UFUNCTION` 改写成"USceneComponent 的成员方法"——剥掉第一个参数、把它当 `this`。脚本侧：

```angelscript
USceneComponent Comp = ...;
FVector Loc = Comp.GetRelativeLocation();   // ★ 脚本侧像调成员方法
```

### 8.2 这套机制完整指南另写

mixin 的四种触发方式（`ScriptMixin` meta / `mixin` 关键字 / FunctionLibrary / 手写 `Bind_*ScriptMixins.cpp` 补漏）以及命名约定细节，**完整指南**在 `Guide_ScriptMixin.md`。维护者视角的实现路径在 `Type_FunctionLibrary.md`。

本文只点明：**当你想给已存在的类型加方法时，第一选择是 ScriptMixin，不是手写 Bind**。

---

## 九、命名约定与避免冲突

### 9.1 ScriptName meta：在 AS 里用一个不同的名字

C++ 端方法名可能跟 AS 关键字撞名，或者你想给脚本用更地道的名字：

```cpp
UFUNCTION(BlueprintCallable, meta=(ScriptName="MyAction"))
void Do_ActionInternal();         // C++ 仍叫 Do_ActionInternal
                                  // 脚本里看到的是 MyAction
```

`ScriptName` 同时被 UHT 和反射 fallback 尊重——是**唯一可靠**的"AS 端别名"机制。

### 9.2 避免与已有 AS 关键字撞名

AS 的关键字与保留字与 C++ 大多重合（`if / else / for / while / class / interface / enum / namespace / new / delete`）。少数特别需要避开的：

```text
mixin           ← AS 关键字（meta 也用了同名）
default         ← AS 关键字
event           ← AS 关键字（多播 delegate 关键字）
delegate        ← AS 关键字（单播 delegate 关键字）
shared          ← AS 关键字
import          ← AS 关键字（参 Type_Preprocessor）
property        ← 历史关键字（已移除，参 Syntax_PropertyAccessor）
```

如果你的 C++ 函数名碰巧叫 `Mixin`，给它一个 `ScriptName="MixinHelper"`。

### 9.3 命名空间：用 `FNamespace` 收纳

全局函数太多容易污染 AS 全局符号表。用 `FNamespace` 收纳：

```cpp
{
    FAngelscriptBinds::FNamespace ns("MyGame");
    FAngelscriptBinds::BindGlobalFunction(
        "int32 ComputeDamage(int32 Base, int32 Boost)",
        FUNC_TRIVIAL(MyGameMath::ComputeDamage));
}
```

脚本侧：`MyGame::ComputeDamage(10, 3)`。

### 9.4 同名重载

AS 支持重载——只要签名不同。但**默认参数**会让重载决议复杂，建议慎用：

```cpp
// 这两个对 AS 都是 "Foo"
FMyType_.Method("void Foo(int X)", ...);
FMyType_.Method("void Foo(float X)", ...);

// 但加了默认参数后，"Foo(0.0)" 该匹配哪个？
FMyType_.Method("void Foo(int X = 0)", ...);     // 默认 0
FMyType_.Method("void Foo(float X)", ...);
```

跟 C++ 类似的"歧义编译错误"会出现在脚本编译期。

---

## 十、写完之后怎么验证（最小测试模板）

### 10.1 .as 端最小验证

把以下脚本扔到 `Script/Tests/MyBindTest.as`，启动编辑器：

```angelscript
// ============================================================================
// 文件: Script/Tests/MyBindTest.as
// 角色: 验证 binding 能编译能调用
// ============================================================================
class TestMyBinding
{
    UFUNCTION()
    void RunOnEnginInit()
    {
        // ① 类型存在且能构造
        FMyVector2D V(1.0, 2.0);
        check(V.X == 1.0);

        // ② 运算符可调用
        FMyVector2D Sum = V + FMyVector2D(3.0, 4.0);
        check(Sum.X == 4.0 && Sum.Y == 6.0);

        // ③ UFUNCTION 可调
        int32 Next = UMyHelperLibrary::AddOne(41);
        check(Next == 42);

        Print("Binding test passed");
    }
};
```

如果脚本编译期挂了——`Type 'FMyVector2D' is not declared` / `Method 'opAdd' not found`——那是 binding 注册失败，去看 §十一 的诊断。

### 10.2 集成测试

如果你想把 binding 验证写成回归测试，扔进 `Plugins/Angelscript/Source/AngelscriptTest/Bindings/AngelscriptMyBindingTests.cpp`，按 `BEGIN_DEFINE_SPEC` / `Describe` / `It` 模式写——脚本片段用 `RunScript(R"(...)")` 内联。详细测试编写模式见 `Guide_TestWriting.md`。

---

## 十一、调试：bind 失败的常见症状

### 11.1 启动期错误：去看 LogAngelscript

`Bind_*.cpp` 注册失败时，AS 内核会通过 `LogAngelscriptError` 输出到 `LogAngelscript`。常见信息：

```text
LogAngelscript: Error: ... Failed to register property 'FMyVector2D X'
        because the type is not declared
LogAngelscript: Warning: ... Method '... opAdd(...)' has invalid signature
```

**第一步**：在 `Saved/Logs/AngelscriptProject.log` 里 grep `LogAngelscript`，把所有 `Error` / `Warning` 拉出来。

**关键性质**：注册失败**不会中断引擎初始化**——它会继续尝试下一条。所以你可能"启动看着正常，但脚本编译期才报 Type 不存在"。永远先看 LogAngelscript。

### 11.2 编译期错误："Type 'FFoo' is not declared"

```text
ScriptError: ... Type 'FMyVector2D' is not declared
```

可能原因：

1. 你的 `Bind_*.cpp` 没加 `AS_FORCE_LINK` —— LTO 把全局对象 strip 掉了
2. 你的 `Bind_*.cpp` 没加进 build —— 看 `AngelscriptRuntime.Build.cs` 默认会 glob 整个 `Source/AngelscriptRuntime` 目录，但**子目录**可能漏掉
3. `EOrder` 用错了——比如 `FMyType` 的方法签名里出现 `FMyOtherType`，但 `Bind_FMyOtherType` 注册时机晚于 `Bind_FMyType`
4. UFUNCTION 被 `NotInAngelscript` / `BlueprintInternalUseOnly` 过滤了

### 11.3 编译期错误："Method 'X' not found"

通常是你的 binding 注册了，但**签名字符串里类型拼错**——例如：

```cpp
FMyVector2D_.Method("FMyVector2D opAdd(const FMyVector2d& Other) const", ...);
//                                            ^^^ 拼错了：FMyVector2d ≠ FMyVector2D
```

签名字符串用的是**字符串匹配**，AS 没法帮你做编译期检查。

### 11.4 运行期：`as.DumpEngineState`

编辑器命令行里输入：

```
as.DumpEngineState
```

会把当前 AS 引擎的所有类型 / 方法 / 全局函数列出来，以 27+ 份 CSV 写到 `Saved/AngelscriptStateDump/`。`AS_TypeRegistry.csv` 会列出所有已注册类型——你的 `FMyVector2D` 在不在这里？详见 `RT_StateDump.md`。

### 11.5 性能：怎么知道是反射兜底还是Runtime-linked

启用 `AS_FunctionBindingStatistics.json` —— 它会写出每个模块的"Runtime-linked率"。如果你怀疑某个热点函数走了反射 fallback，去看：

```text
Plugins/Angelscript/Intermediate/Build/<Plat>/<Tgt>/Inc/AngelscriptRuntime/UHT/
└── AS_FunctionBindingStatistics.json
```

里面 `NativeRuntimeLinkedCount` / `ReflectiveFallbackCount` 比例就是答案。如果你的关键函数被列在 `ReflectiveFallback`，加 UHT Runtime-linked（确保 `Build.cs` 依赖、确保 header 不在 `/Private/`）或手写 Bind。

---

## 附录 A：三层路径速查表

| 场景 | 推荐路径 | 你需要写什么 |
|------|---------|-------------|
| 加一个 BlueprintCallable helper | 反射兜底 | 0 行 binding 代码，只标 `UFUNCTION(BlueprintCallable)` |
| 暴露一整个新模块 | UHT 自动 | 改一行 `AngelscriptRuntime.Build.cs` |
| 给已有 UClass 加 helper 方法 | mixin | 写一个 `FunctionLibraries/<X>Library.h` |
| 暴露新 USTRUCT 字段 | UHT + UPROPERTY | 0 行 binding 代码 |
| 暴露新 USTRUCT 上的方法 | mixin 或手写 | 推荐 mixin |
| 暴露新 UENUM | 反射兜底 | 0 行 binding 代码，只标 `UENUM(BlueprintType)` |
| 暴露新 Delegate | 反射兜底 | 0 行 binding 代码，只用 `DECLARE_DYNAMIC_*_DELEGATE` 宏 |
| 注册自定义运算符（`opAdd` / `opEquals`） | 手写 Bind_*.cpp | 一份新的 `Bind_F<Type>.cpp` |
| 用 `?&` 模板让脚本指定输出类型 | 手写 Bind_*.cpp | `ExistingClass(name).Method(...)` 加一条 lambda |
| 屏蔽某个不想暴露的函数 | 反射元数据 | `meta=(NotInAngelscript)` 一行 |
| 改 AS 端别名 | 反射元数据 | `meta=(ScriptName="...")` 一行 |
| 暴露 nondefault 构造（`FFoo(A, B)`） | 手写 Bind_*.cpp | `Constructor("void f(...)", lambda)` |
| 暴露超过 16 参的 UFUNCTION | UHT Runtime-linked或手写 | 取决于函数所在模块 |
| 暴露非 UE 反射的纯 C++ 类 | 手写 Bind_*.cpp | 完全自由（无反射兜底） |

---

## 附录 B：常见错误避坑（C++ 工程师视角）

1. **以为加 `Bind_MyType.cpp` 就够了，结果脚本看不到** —— 漏写 `AS_FORCE_LINK`，全局对象被 link 优化扔掉。**所有** `FBind` 全局对象都必须带 `AS_FORCE_LINK`。

2. **签名拼错却没编译错误** —— Method 签名是字符串。AS 引擎在脚本编译期才会发现不匹配。建议复制粘贴 C++ 类型名进签名字符串，**不要凭手感打**。

3. **`UFUNCTION` 没加 `BlueprintCallable` / `BlueprintPure` 标签** —— 反射 fallback 与 UHT 都不会扫到它。**所有**想给脚本用的函数必须有其中之一。

4. **方法在 `/Private/` 头文件里** —— UHT 跳过私有头。把声明挪到 `/Public/`，或写手写 Bind 把它包进 `Bind_*.cpp`。

5. **加了模块到 `Build.cs` 但 UHT 还是不生成** —— 没 rebuild。UHT 只在构建期跑。`Build.cs` 改了**必须 rebuild 而不是 incremental build**。

6. **`USTRUCT` 上的 method 脚本里调不到** —— UHT 不为 USTRUCT 上的 UFUNCTION 生成绑定。改成 mixin（推荐）或手写。

7. **`UENUM` 没出现在脚本里** —— 检查是否被 `meta=(NotBlueprintType)` / `meta=(NotInAngelscript)` 过滤；或者 `UEnum::IsA<UUserDefinedEnum>` 撞到了 `/Script/Angelscript` 包过滤。

8. **Delegate 在脚本里看不到** —— 通常是 `DECLARE_DYNAMIC_*` 宏所在的头没被任何 `BlueprintCallable` 函数 include 到，UFunction 反射没建。把宏放到一个 `BlueprintCallable` 函数所在的 header 旁边，或显式 `_Static_assert` 触发反射。

9. **脚本侧 `MyClass.MyMethod()` 提示找不到，但 `as.DumpEngineState` 说类型存在** —— 可能是 mixin 的"第 0 参数剥离" target 写错了。检查 `UCLASS(meta=(ScriptMixin="USceneComponent"))` 里 target 类型名是否准确。

10. **跨模块依赖问题：你的模块依赖另一个 binding 还没注册的类型** —— `EOrder` 用错。把你的 binding 调成 `Late+1` 或更晚，让被依赖类型先于你注册。

11. **`UFUNCTION(meta=(NotInAngelscript))` 是脚本不可见，不是不可编译** —— 加 meta 后 C++ 仍能调，只是脚本编译器看不到。**不要**用它做权限控制。

12. **改了 `EOrder` 头文件后 UHT 产物里硬编码常量过期** —— `Type_BindSystem.md` §附录 B-10 的同样问题。改 `EOrder` 后 rebuild。

---

## 小结

- **C++ 工程师视角的三层路径**：反射兜底（你只标 UFUNCTION）→ UHT 自动（你只改 Build.cs）→ 手写 Bind（你写一份 `Bind_F<Type>.cpp`）。99% 的业务场景前两层就够。

- **暴露 USTRUCT 用 UPROPERTY；暴露 UENUM 几乎不用做事；暴露 Delegate 用标准 UE 宏即可**——这三类的"自动覆盖率"非常高，几乎不需要手写。

- **手写 `Bind_*.cpp` 的最小骨架就一行 `FBind` + 一段 lambda**：lambda 内 `ValueClass` / `ReferenceClass` / `ExistingClass` 拿到对象，链式 `.Constructor` / `.Method` / `.Property` 注册。维护者视角的完整解释见 `Type_BindSystem.md`。

- **mixin 是给已有类型挂 helper 的最佳路径**：写一份 `FunctionLibraries/<X>Library.h`，`UCLASS(meta=(ScriptMixin="..."))`，剩下交给框架。完整指南见 `Guide_ScriptMixin.md`。

- **写完一定先看 `LogAngelscript`，再用 `as.DumpEngineState` 验证类型存在**——这是排查 binding 问题的双键。
