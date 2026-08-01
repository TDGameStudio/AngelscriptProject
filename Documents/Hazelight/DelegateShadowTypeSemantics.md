# Delegate ShadowType 语义记录

> 记录日期：2026-07-08
> 主题：AS `delegate` 生成的 value `struct` 与 `shadowType` 的语义边界
> 关联代码：`AngelscriptPreprocessor.cpp`、`AngelscriptEngine.cpp`、`Bind_Delegates.cpp`、`as_builder.cpp`、`as_objecttype.cpp`、`PrecompiledData.cpp`

## 1. 问题背景

讨论中的问题来自以下观察：

```text
在 AS 里声明一个 delegate，preprocessor 会把它翻译成一个 struct。
这个 struct 又可能被指定 shadowType。

普通 struct 没有 shadowType。
默认有 shadowType 的是 class。

对 Class（reference type，UObject 子类），shadowType 的存在是真正意义上的“继承父类”。
对 delegate struct（value type），设计意图是“shadowType 和 struct 是同一块内存”。
```

核心矛盾是：`shadowType` 这个字段同时可能表达两类语义。

| 场景 | 类型形态 | `shadowType` 期望语义 |
|------|----------|------------------------|
| Script class shadow native class | reference type / `UObject` 子类 | 继承或投影到 native 父类型 |
| Script delegate generated struct | value type | native value payload / storage alias |

如果不区分这两类语义，delegate generated struct 会被误当成 class-style inheritance，从而影响布局、方法查找、属性枚举、类型转换和 precompiled restore。

## 2. `shadowType` 是什么

`shadowType` 是 AngelScript 类型元数据 `asCObjectType` 上的一个指针，指向另一个已注册的 AS type。

在 Unreal-Angelscript 集成里，它主要用于让脚本类型“投影”到 native/bound 类型：

```angelscript
class UMyActor : AActor
{
    int Value;
}
```

对于这种 script class，`shadowType` 指向 `AActor` 对应的 bound AS type，`basePropertyOffset` 使用 C++ 父类已有属性大小。这样脚本类可以访问父类方法和属性，并在对象布局上给 native 部分留空间。

相关本地路径：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h`：`asPreClassData::ShadowType`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`：给 `CodeSuperClass` 设置 `Data.ShadowType`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.cpp`：把 `PreClassData.ShadowType` 写入 `asCObjectType::shadowType`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_objecttype.cpp`：`ShadowsFrom()` / `DerivesOrShadows()` 使用 shadow chain 做类型关系判断

## 3. Delegate 的预处理形态

AS 源码中的 delegate：

```angelscript
delegate int FMyDelegate(int Value);
```

会被 preprocessor 翻译成一个 value `struct`，形态类似：

```angelscript
struct FMyDelegate
{
    _FScriptDelegate _Inner;

    FMyDelegate() __generated no_discard {}
    FMyDelegate(const FMyDelegate& Other) __generated no_discard { this = Other; }
    FMyDelegate& opAssign(const FMyDelegate& Other) __generated
    {
        _Inner = Other._Inner;
        return this;
    }

    int Execute(int Value) const allow_discard __generated { ... }
    int ExecuteIfBound(int Value) const allow_discard __generated { ... }
    void BindUFunction(UObject Object, const FName& BindFunctionName) __generated { ... }
    bool IsBound() const __generated { return _Inner.IsBound(); }
    void Clear() __generated { _Inner.Clear(); }
};
```

多播 delegate 则使用 `_FMulticastScriptDelegate _Inner`。

这里的关键是：`_Inner` 是第一个字段。对于 value storage alias 方案，`FMyDelegate*` 的首地址需要能等价地解释为 `_FScriptDelegate*`，也就是二者共享同一段 native payload 内存起点。

## 4. 我们插件当前的处理

我们当前插件没有给 script-declared delegate generated struct 设置 `ShadowType`。

当前路径是：

```text
AS delegate
  -> preprocessor 生成 struct FMyDelegate { _FScriptDelegate _Inner; ... }
  -> PreClassData.InitialUserData 标记它是 delegate
  -> ClassGenerator 根据 Execute/Broadcast 生成 UDelegateFunction
  -> ScriptType.UserData = UDelegateFunction*
  -> FScriptDelegateType / FMulticastScriptDelegateType 处理 property、参数、返回值、debugger 和签名匹配
```

关键点：

- `ProcessDelegates()` 生成 `struct`，并插入 `_FScriptDelegate _Inner` 或 `_FMulticastScriptDelegate _Inner`。
- `FAngelscriptEngine` 给 delegate 的 `asPreClassData` 只设置 `InitialUserData`，不设置 `ShadowType`。
- `FAngelscriptClassGenerator` 先用 `TAG_UserData_Delegate` / `TAG_UserData_Multicast_Delegate` 标记 script type。
- 生成 `UDelegateFunction` 后，把 `ScriptType->SetUserData(Function)`，让类型系统能拿到真实 delegate signature。
- `FAngelscriptTypeUsage::FromTypeId()` 根据 userdata tag 或 `UDelegateFunction*` 把该 script value type 映射为 script delegate type。
- `FScriptDelegateType` / `FMulticastScriptDelegateType` 负责 UE 侧 `FDelegateProperty`、`FMulticastInlineDelegateProperty`、参数传递、返回值和调试展示。

本地关键代码：

- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptType.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Delegates.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_Analyze.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_FullReload.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ClassGenerator/AngelscriptClassGenerator_SoftReload.cpp`

结论：我们当前实现通过 userdata + delegate-specific type handler 避免了 `shadowType` 的双重语义冲突。

## 5. Hazelight 的处理

Hazelight 的方案不同。Hazelight 会给 script-declared delegate generated struct 设置 `ShadowType`：

```cpp
if (DelegateDesc->bIsMulticast)
{
    Data.InitialUserData = FAngelscriptType::TAG_UserData_Multicast_Delegate;
    Data.ShadowType = FAngelscriptType::MulticastTypeInfo;
}
else
{
    Data.InitialUserData = FAngelscriptType::TAG_UserData_Delegate;
    Data.ShadowType = FAngelscriptType::DelegateTypeInfo;
}
```

其中：

- `_FScriptDelegate` 注册后保存到 `FAngelscriptType::DelegateTypeInfo`
- `_FMulticastScriptDelegate` 注册后保存到 `FAngelscriptType::MulticastTypeInfo`
- delegate generated struct 的 `shadowType` 指向这两个 native value type 之一

但 Hazelight 不是裸用 class-style shadow。官方当前 `angelscript-master` 里，AS core 对 value type 做了专门保护。

### 5.1 Builder：struct 不写 base property offset

官方当前 `as_builder.cpp` 逻辑是：

```cpp
asPreClassData* classData = module->PreClassData.Find(name);
if (classData != nullptr)
{
    if (!isStruct)
        st->basePropertyOffset = (int)classData->PropertyOffset;
    st->shadowType = classData->ShadowType;
    st->plainUserData = (asPWORD)classData->InitialUserData;
}
```

也就是说：

- class/reference type 可以用 `basePropertyOffset` 表达 native 父类大小
- struct/value type 可以有 `shadowType`
- 但 struct/value type 不从 `PropertyOffset` 继承 native base size

这使 delegate generated struct 的第一个字段 `_Inner` 仍然可以从 offset 0 开始。

### 5.2 Type relation：value shadow 不参与继承判断

官方当前 `as_objecttype.cpp` 中，`ShadowsFrom()` 和 `DerivesOrShadows()` 对 value type 直接返回 false：

```cpp
bool asCObjectType::ShadowsFrom(const asITypeInfo *objType) const
{
    if (flags & asOBJ_VALUE)
        return false;
    ...
}

bool asCObjectType::DerivesOrShadows(const asITypeInfo *objType) const
{
    if (this == objType)
        return true;
    if (flags & asOBJ_VALUE)
        return false;
    ...
}
```

这说明 Hazelight 明确区分：

- class shadow：参与继承链、类型转换、访问控制
- value shadow：只表达 storage/native payload 关联，不表达“我是它的子类”

### 5.3 PrecompiledData：value shadow 不重建 class-style base offset

Hazelight 的 precompiled restore 也有对应保护：

```cpp
Type->shadowType = Context.GetTypeInfo(ShadowType);

if (Type->shadowType != nullptr && !(Type->flags & asOBJ_VALUE))
    Type->basePropertyOffset = ((asCObjectType*)Type->shadowType)->size;
else
    Type->basePropertyOffset = 0;
```

这避免了预编译数据加载时把 delegate value shadow 恢复成 class inheritance layout。

### 5.4 Hazelight 方案总结

Hazelight 的 delegate 处理可以概括为：

```text
AS delegate
  -> preprocessor 生成 struct FMyDelegate { _FScriptDelegate _Inner; ... }
  -> _FScriptDelegate 注册为 native value type，并保存 DelegateTypeInfo
  -> FMyDelegate 的 PreClassData:
       InitialUserData = delegate tag
       ShadowType = DelegateTypeInfo
  -> AS core 对 asOBJ_VALUE shadow 做特殊处理:
       不写 class-style basePropertyOffset
       不参与 DerivesOrShadows / ShadowsFrom
       precompiled restore 不恢复 native base offset
  -> ClassGenerator 生成 UDelegateFunction 后把 UserData 改成 signature function
```

## 6. 两套方案对比

| 维度 | 我们当前插件 | Hazelight |
|------|--------------|-----------|
| delegate 是否生成 struct | 是 | 是 |
| struct 首字段 | `_FScriptDelegate _Inner` / `_FMulticastScriptDelegate _Inner` | 同 |
| 是否给 delegate struct 设置 `ShadowType` | 否 | 是 |
| delegate 类型识别 | userdata tag / `UDelegateFunction*` | userdata tag / `UDelegateFunction*` |
| native payload 关联 | 通过 `_Inner` 和 delegate-specific type handler | 通过 `_Inner` + value `shadowType` |
| class shadow 与 value shadow 是否分离 | 当前不需要，因为 delegate 不用 shadow | 需要，且 AS core 已做特判 |
| 主要风险 | 与 Hazelight 行为不完全一致，部分依赖 shadow 的 JIT/工具路径需要单独处理 | 迁移不完整时容易把 value shadow 当 class inheritance |

## 7. 风险分析

如果只照 Hazelight 给 delegate 增加：

```cpp
Data.ShadowType = FAngelscriptType::DelegateTypeInfo;
Data.ShadowType = FAngelscriptType::MulticastTypeInfo;
```

但没有同步 value-type guard，会产生以下风险：

1. `basePropertyOffset` 可能被当成 native base size，导致 `_Inner` 不再位于 offset 0。
2. `DerivesOrShadows()` 可能把 `FMyDelegate` 当作 `_FScriptDelegate` 的子类型，开放错误的隐式转换或访问路径。
3. 方法和属性查找可能沿 shadow chain 暴露 `_FScriptDelegate` 的成员，而不是只通过 wrapper method 访问。
4. StaticJIT 或 precompiled restore 可能在加载时重新计算错误布局。
5. debugger、Blueprint type query、property iteration 可能把 value payload shadow 误判成 class inheritance shadow。

因此，Hazelight delegate shadow 方案是一个成套设计，不是单点赋值。

## 8. 迁移判断

当前建议：

- 不要为了“看起来和 Hazelight 一致”单独给 delegate struct 补 `ShadowType`。
- 如果未来确实需要对齐 Hazelight 的 value shadow 语义，应作为独立行为变更处理。
- 迁移范围至少包括：
  - `as_builder.cpp`：struct/value type 不写 class-style `basePropertyOffset`
  - `as_objecttype.cpp`：`ShadowsFrom()` / `DerivesOrShadows()` 对 `asOBJ_VALUE` 返回 false
  - `PrecompiledData.cpp`：value shadow restore 不重建 native base offset
  - `StaticJIT`：确认 shadow property offset 计算对 value type 不产生父布局
  - `Bind_BlueprintType.cpp` / debugger / property iteration：确认 value shadow 是否应该跟随
  - delegate tests：覆盖单播、多播、属性、参数、返回值、热重载、precompiled/JIT 相关路径

从当前代码看，我们插件选择“不对 delegate 使用 `ShadowType`”是合理的保守方案。它避免了 `shadowType` 语义复用带来的布局和类型关系风险。Hazelight 的方案更接近 native payload alias，但依赖 AS core 中多处 value-type 特判共同成立。

## 9. 结论

这次讨论里的问题可以归纳为一句话：

```text
shadowType 对 class 表示“继承 native 父类型”；
shadowType 对 delegate value struct 如果存在，只能表示“native value payload shadow”，不能参与继承语义。
```

我们当前插件：

```text
delegate 不设置 ShadowType；
通过 _Inner + userdata + delegate-specific type handler 对接 UE delegate。
```

Hazelight：

```text
delegate 设置 ShadowType；
但 AS core 对 asOBJ_VALUE shadow 做专门保护，让它保持 storage alias 语义，而不是 class inheritance。
```

后续如果要同步 Hazelight 的 delegate shadow 行为，必须同步迁移整套 value shadow guard，并补齐测试；不能只迁移 `Data.ShadowType = DelegateTypeInfo` 这一层。
