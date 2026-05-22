# Syntax_PropertyAccessor - `property` 访问器的移除说明

> **定位**: 这是历史记录页，不是当前使用指南。
> **当前结论**: `refactor-as-remove-autoaccessor` 已移除脚本侧 `property` 装饰器、虚拟属性块，以及 C++ 绑定的隐式 property 提升。
> **现行写法**: 直接写显式方法 `GetX()` / `SetX()`，或直接访问普通 `UPROPERTY` 字段。

---

## 现在应该怎么写

- 旧的 `void GetX() property { ... }` 现在改成普通方法 `void GetX() { ... }`。
- 旧的 `int X { get { ... } set { ... } }` 现在改成两个明确的方法 `GetX()` / `SetX(...)`。
- 旧的 `obj.X` / `obj.X = ...` 语法不再作为 accessor sugar 使用。
- `GetX()` / `SetX()` 仍然是普通方法名，可以直接调用，但不再自动参与属性式重写。

典型迁移：

```angelscript
class FExample
{
    private int Stored;

    int GetValue() const
    {
        return Stored;
    }

    void SetValue(int InValue)
    {
        Stored = InValue;
    }
}
```

如果你需要的是 UE 反射字段，请直接使用 `UPROPERTY` 暴露字段本身，而不是依赖脚本侧自动 accessor sugar。

---

## removed in `refactor-as-remove-autoaccessor`

这次变更把旧的三条入口都关掉了：

1. 脚本 decorator `property`
2. 虚拟属性块 `int X { get; set; }`
3. C++ 绑定的隐式 property 提升

也就是说，下面这些旧行为都不再是当前约定：

```angelscript
void GetHealth() property { }
int Health { get { } set { } }
```

```cpp
FAngelscriptBinds::Method("FString GetName() const", &Foo::GetName);
```

后者现在只是一个普通的 `GetName()` 方法绑定，不会再因为名字形态自动进入 property sugar 路径。

---

## 历史附录 - 原 §1-§3 实现细节

> 以下内容保留 `refactor-as-remove-autoaccessor` 之前的原 §1-§3 实现说明，便于回看 fork 历史。这里的源码行号、代码片段和行为描述指向旧实现，不代表当前可用语法。

### 原 §一、词法识别：`PROPERTY_TOKEN` 装饰器

**源码所在**: `as_tokendef.h:334`、`as_parser.cpp:3216-3230` 与 `as_parser.cpp:5118-5128`。

#### 1.1 token 定义

```cpp
// as_tokendef.h:334
const char * const PROPERTY_TOKEN  = "property";
```

注意：**`property` 不是 ttKeyword**。它是普通标识符，与 `final` / `override` / `mixin` / `accept_temporary` 等并列，统一通过 `IdentifierIs(token, PROPERTY_TOKEN)` 字符串比较识别。这与 `default` / `class` 等真正的关键字（有专属 ttToken）形成对比。

#### 1.2 在两处 decorator 列表中出现

```cpp
// as_parser.cpp:3216-3230  方法 decorator (类成员函数)
GetToken(&t1);
if( !IdentifierIs(t1, FINAL_TOKEN)
    && !IdentifierIs(t1, OVERRIDE_TOKEN)
    && !IdentifierIs(t1, PROPERTY_TOKEN)
    && !IdentifierIs(t1, MIXIN_TOKEN)
    && !IdentifierIs(t1, ACCEPT_TEMPORARY_TOKEN)
    && ...
)

// as_parser.cpp:5118-5128  函数体后 decorator
if (IdentifierIs(t1, FINAL_TOKEN)
    || IdentifierIs(t1, OVERRIDE_TOKEN)
    || IdentifierIs(t1, PROPERTY_TOKEN)
    || IdentifierIs(t1, MIXIN_TOKEN)
    || ...)
```

两处的语义略有不同：

| 位置 | 适用对象 | 写法 |
|------|---------|------|
| L3216 | 类内方法、全局函数 decorator 列表 | `void GetX() property { ... }` |
| L5118 | 一般函数声明的尾部 decorator | 同上，处理函数体后的修饰符 |

**关键约束**：`property` 必须出现在**函数签名后、函数体前**（与 `const` / `final` 同位置）。写在返回类型前会被解析为标识符（变量名），导致语法错误。

#### 1.3 与 `Mixin` 装饰器的实现对称性

`property` 与 `mixin` 在 parser 层走的是同一套 decorator 字符串识别框架。这也是为什么 `Syntax_Mixin.md` §1.1 提到的 `IdentifierIs(t1, PROPERTY_TOKEN)` 行为可以无缝迁移到本文。两者唯一的差别是：

- `mixin` 限定到全局函数（且第一个参数即"宿主类型"）；
- `property` 既可在成员函数也可在全局函数上，且对参数形态有专门约束。

### 原 §二、虚拟属性语法：`int X { get; set; }` 的 parser 展开

**源码所在**: `as_parser.cpp:3468-...` 的 `ParseVirtualPropertyDecl` + `as_builder.cpp:5380-5443`。

#### 2.1 parser 阶段：生成 `snVirtualProperty` 节点

```cpp
// as_parser.cpp:2462  (类成员声明 dispatcher)
else if (t.type == ttIdentifier && IdentifierIs(t, ...))
{
    if (... 是虚拟属性形式 ...)
        node->AddChildLast(ParseVirtualPropertyDecl(false, false));
    else if (IsVarDecl())
        node->AddChildLast(ParseDeclaration(false, true));
}
```

`ParseVirtualPropertyDecl` 创建 `snVirtualProperty` 类型的语法节点，把 get/set 块作为子节点挂上：

```text
源码:
    int Health
    {
        get const { return _Health; }
        set       { _Health = value; }
    }

解析后 AST 节点结构:
    snVirtualProperty
      - snDataType       (int)
      - snIdentifier     (Health)
      - snVirtualProperty (get 子节点)
          - snIdentifier (get)
          - ttConst       (可选 const 标记)
          - snStatementBlock { return _Health; }
      - snVirtualProperty (set 子节点)
          - snIdentifier (set)
          - snStatementBlock { _Health = value; }
```

#### 2.2 builder 阶段：拆成两个独立函数

```cpp
// as_builder.cpp:5380-5443  关键拆分逻辑
funcTraits.SetTrait(asTRAIT_PROTECTED, isProtected);

// Virtual property accessor methods are implicitly marked as property accessors
funcTraits.SetTrait(asTRAIT_PROPERTY, true);

// TODO: getset: Allow private for individual property accessors
// TODO: getset: If the accessor uses its own name, then the property should be automatically declared

if (node->firstChild->nodeType == snIdentifier
    && file->TokenEquals(node->firstChild->tokenPos, node->firstChild->tokenLength, GET_TOKEN))
    name = AS_GET_PREFIX;                                                    // = "Get"
else if (node->firstChild->nodeType == snIdentifier
    && file->TokenEquals(node->firstChild->tokenPos, node->firstChild->tokenLength, SET_TOKEN))
    name = AS_SET_PREFIX;                                                    // = "Set"
else
    WriteError(TXT_UNRECOGNIZED_VIRTUAL_PROPERTY_NODE, file, node);

if (name != "")
{
    success = true;
    funcNode = node->firstChild->next;

    if (funcNode && funcNode->tokenType == ttConst)                          // get const 处理
    {
        funcTraits.SetTrait(asTRAIT_CONST, true);
        funcNode = funcNode->next;
    }

    while (funcNode && funcNode->nodeType != snStatementBlock)               // final / override
    {
        if (funcNode->tokenType == ttIdentifier
            && file->TokenEquals(funcNode->tokenPos, funcNode->tokenLength, FINAL_TOKEN))
            funcTraits.SetTrait(asTRAIT_FINAL, true);
        else if (funcNode->tokenType == ttIdentifier
            && file->TokenEquals(funcNode->tokenPos, funcNode->tokenLength, OVERRIDE_TOKEN))
            funcTraits.SetTrait(asTRAIT_OVERRIDE, true);

        funcNode = funcNode->next;
    }

    if (funcNode == 0 && (objType == 0 || !objType->IsInterface()))
    {
        WriteError(TXT_PROPERTY_ACCESSOR_MUST_BE_IMPLEMENTED, file, node);   // 必须有函数体
    }

    if (name == AS_GET_PREFIX)
    {
        // Setup the signature for the get accessor method
        returnType = emulatedType;                                            // 返回类型 = 属性类型
        name = AS_GET_PREFIX + emulatedName;                                  // "Get" + "Health" = "GetHealth"
    }
    else if (name == AS_SET_PREFIX)
    {
        // Setup the signature for the set accessor method
        returnType = asCDataType::CreatePrimitive(ttVoid, false);             // void
        paramModifiers.PushLast(asTM_NONE);
        paramNames.PushLast("value");                                         // 参数名 = "value"
        paramTypes.PushLast(emulatedType);                                    // 参数类型 = 属性类型
        defaultArgs.PushLast(0);
        name = AS_SET_PREFIX + emulatedName;                                  // "Set" + "Health" = "SetHealth"
    }
}
```

#### 2.3 拆分前后对照

```text
源码 (用户写):
    int Health
    {
        get const { return _Health; }
        set       { _Health = value; }
    }

builder 拆分等价于:
    int GetHealth() const property { return _Health; }
    void SetHealth(int value) property { _Health = value; }

外部调用看起来:
    obj.Health           -> 调 GetHealth()
    obj.Health = 100     -> 调 SetHealth(100)
```

#### 2.4 设计要点

| 要点 | 说明 |
|------|------|
| **强制 `asTRAIT_PROPERTY`** | 虚拟属性块拆出来的 `Get/Set*` 自动带 trait，不依赖 `bAllowImplicitPropertyAccessors` |
| **参数命名固定为 `value`** | setter 形参强制叫 `value`，对应 set 块内 `value` 表达式 |
| **必须有函数体** | 接口除外。否则 `TXT_PROPERTY_ACCESSOR_MUST_BE_IMPLEMENTED` |
| **支持 final/override/const** | 与普通成员方法一致 |
| **未实现的 TODO** | 源码注释 L5385-5386 提到：还不支持单独给 get/set 加 `private`；自动声明同名底层字段尚未实现 |

#### 2.5 与 vanilla AS 的等价对照

```text
vanilla AS:                      当前 fork:
  int x { get { } set { } }      int x { get { } set { } }
  -> get_x() / set_x(value)      -> Getx() / Setx(value)
```

虚拟属性语法本身在两边一致；差异在于**展开后的方法名前缀**。这与旧实现中 `AS_GET_PREFIX = "Get"` 的重定义直接相关。

### 原 §三、核心约束：`ValidatePropertyAccessorFunc`

**源码所在**: `as_builder.cpp:1721-1746`。

```cpp
// Returns a negative value on invalid property
// -2 incorrect prefix
// -3 invalid signature
int asCBuilder::ValidatePropertyAccessorFunc(asCScriptFunction* func)
{
    if (!func->IsProperty())
        return 0;                                              // 非属性, 不校验

    bool hasGetPrefix = func->name.StartsWith(AS_GET_PREFIX);  // "Get"
    bool hasSetPrefix = func->name.StartsWith(AS_SET_PREFIX);  // "Set"

    // A property accessor func must have the prefix one of the get/set prefixes
    if (!hasGetPrefix && !hasSetPrefix)
        return -2;

    // A getter must return a non-void type and have at most 1 argument (indexed property)
    if (hasGetPrefix
        && (func->returnType == asCDataType::CreatePrimitive(ttVoid, false)
            || func->parameterTypes.GetLength() > 1))
        return -3;

    // A setter must return a void and have 1 or 2 arguments (indexed property)
    if (hasSetPrefix
        && (func->returnType != asCDataType::CreatePrimitive(ttVoid, false)
            || func->parameterTypes.GetLength() < 1
            || func->parameterTypes.GetLength() > 2))
        return -3;

    return 0;
}
```

#### 3.1 合法签名矩阵

| 形态 | Getter 签名 | Setter 签名 | 用法 |
|------|------------|------------|------|
| **普通属性** | `T GetX()` 或 `T GetX() const` | `void SetX(T value)` | `obj.X` / `obj.X = v` |
| **索引属性** | `T GetX(K index)` | `void SetX(K index, T value)` | `obj.X[k]` / `obj.X[k] = v` |

#### 3.2 三个非法形态

```cpp
[非法 1] 函数名前缀不对
    void Compute() property;        // 既不是 Get 也不是 Set 开头
    -> 返回 -2

[非法 2] Getter 无返回值或参数过多
    void GetX() property;           // 返回 void
    int  GetX(int a, int b) property; // 参数 > 1
    -> 返回 -3

[非法 3] Setter 返回非 void / 参数缺失 / 参数过多
    int  SetX(int v) property;      // 返回非 void
    void SetX() property;           // 0 参数
    void SetX(int a, int b, int c) property; // 3 参数
    -> 返回 -3
```

#### 3.3 隐式提升下的"误判"风险

由于 C++ 端**所有** `Get*` / `Set*` 函数被默认提升为 property，下列 C++ 函数会变成名义上的属性访问器：

```cpp
// C++ 中
FAngelscriptBinds::Method("void GetActorBounds(bool bOnlyColliding,
    FVector& OutOrigin, FVector& OutBoxExtent) const", ...);
```

```text
ValidatePropertyAccessorFunc:
  - hasGetPrefix = true
  - 返回类型 void
  - 参数数 = 3 > 1
  -> 返回 -3
```

这种情况下函数依然存在并可调用（`obj.GetActorBounds(...)` 仍然有效），只是它**不会**通过 `obj.ActorBounds` 形式被访问。`ValidatePropertyAccessorFunc` 在 builder 后期校验时会把它从属性候选列表中剔除，但不影响普通方法调用路径。这就是旧版"全员隐式提升"安全工作的关键：**校验失败 = 退化为普通方法**，不抛错。

---

## 相关引用

- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h`
- `Plugins/Angelscript/Source/AngelscriptRuntime/Preprocessor/AngelscriptPreprocessor.cpp`
