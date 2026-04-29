# Syntax_PropertyAccessor — `property` 关键字与 Get/Set 访问器实现原理

> **所属前缀**: Syntax_（关键字与修饰符族）
> **关注层面**: 语法机制与实现原理（非用户使用指南）
> **关键源码**:
> `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_config.h`（`AS_GET_PREFIX`/`AS_SET_PREFIX` 定义）
> · `ThirdParty/angelscript/source/as_tokendef.h`（`PROPERTY_TOKEN` 词元）
> · `ThirdParty/angelscript/source/as_parser.cpp`（`ParseVirtualPropertyDecl` / decorator 识别）
> · `ThirdParty/angelscript/source/as_builder.cpp`（`asTRAIT_PROPERTY` 标记 / `ValidatePropertyAccessorFunc`）
> · `ThirdParty/angelscript/source/as_compiler.cpp`（`FindPropertyAccessor` 主流程，L13996-14430、L14632、L11264-11270、L14959-14965）
> · `Core/AngelscriptBinds.cpp:487-511`（`OnBind` 隐式 `SetProperty(true)`）
> · `Core/AngelscriptSettings.h:55-56`（`bAllowImplicitPropertyAccessors` 全局开关）
> **关联文档**:
> `Documents/Knowledges/ZH/Syntax_UFUNCTION.md`（UFUNCTION 修饰符 → AS 端方法暴露与 traits）
> · `Documents/Knowledges/ZH/Syntax_Mixin.md`（同样基于 `IdentifierIs(t, PROPERTY_TOKEN)` 的 decorator 识别框架）
> · `Documents/Knowledges/ZH/Type_BindSystem.md`（`FAngelscriptBinds::OnBind` 在所有 C++ 绑定函数上的统一钩子）
> · `Documents/Guides/ASSDK_Fork_Differences.md`（与 vanilla AS 在 `get_/set_` 与 `Get/Set` 前缀上的根本差异）

---

## 概览：四种触发路径，一个统一的 `asTRAIT_PROPERTY`

`property` 在当前插件里**不是独立的语法节点**——它是一个标志位 `asTRAIT_PROPERTY`，被挂在 `asCScriptFunction::traits` 上。任何被打上这个标志的方法都进入"访问器候选池"，由 `as_compiler.cpp::FindPropertyAccessor` 在每次属性式访问（`obj.X` / `obj.X = ...`）时按 `Get<Name>` / `Set<Name>` 命名约定查找匹配的方法对。

```text
"property" 标志的 4 条进入路径

[Path 1] AS 脚本显式装饰
    形如:    void GetHealth() property { ... }
    实现:    as_parser 把 "property" 作为函数 decorator 识别
             -> as_builder.cpp:1470 SetProperty(true)
    范围:    单个方法

[Path 2] AS 脚本虚拟属性语法 (vanilla AS get/set 块)
    形如:    int Health
             {
                 get const { return _Health; }
                 set       { _Health = value; }
             }
    实现:    as_parser ParseVirtualPropertyDecl -> snVirtualProperty 节点
             -> as_builder L5380-5443 拆成 GetHealth() / SetHealth(int)
                并强制 SetTrait(asTRAIT_PROPERTY, true)
    范围:    同一对 get/set 自动配对

[Path 3] C++ 端绑定的隐式提升 (★ 当前 fork 最重要的特征)
    形如:    FAngelscriptBinds::Method("FString GetName() const", &Foo::GetName);
             FAngelscriptBinds::Method("void SetName(const FString&)", &Foo::SetName);
    实现:    AngelscriptBinds.cpp:487-511 OnBind 钩子
             -> 若 ConfigSettings->bAllowImplicitPropertyAccessors == true (默认!)
             -> 所有绑定函数无差别 SetProperty(true)
    范围:    所有 C++ 绑定的方法/全局函数

[Path 4] 全局函数装饰 (脚本侧)
    形如:    FString GetGreeting() property { return "Hi"; }
    实现:    as_parser 在全局函数 decorator 阶段识别 PROPERTY_TOKEN
             -> as_builder.cpp:4681-4682 funcTraits.SetTrait(asTRAIT_PROPERTY, true)
    范围:    模块全局函数, 不需要属于某个对象
```

四条路径**最终汇合到同一个标志位**——后续 `FindPropertyAccessor` 不区分函数从哪条路径来的。

### 4 阶段管线

```text
源码层 (Source)                AS 解析器层 (as_parser.cpp)
=====================          ====================================
.as 中三种写法:                  - 装饰器 "property" -> snDeclaration 子节点
  (1) GetX() property              [as_parser.cpp:3216-3230 在 decorator 列表]
  (2) int X { get { } set { } }  - 虚拟属性 -> snVirtualProperty 节点
  (3) C++ 绑定的 Get/Set 函数      [as_parser.cpp:3468 ParseVirtualPropertyDecl]
                                  - C++ 绑定走另一条入口, 不经过 parser
        |
        v
AS 构建器层 (as_builder.cpp)
====================================
- 装饰器: L1470, L4681 SetTrait(asTRAIT_PROPERTY, true)
- 虚拟属性: L5380-5443 拆 get/set 块 -> 强制注入 asTRAIT_PROPERTY
            + 把方法名改写为 "Get<Name>" / "Set<Name>"
- 校验: L1724 ValidatePropertyAccessorFunc
        - 必须有 Get/Set 前缀 (-2 if not)
        - getter: 非 void 返回, ≤1 参数 (索引属性)
        - setter: void 返回, 1-2 参数 (后者为索引属性)
        |
        v
C++ 绑定层 (AngelscriptBinds.cpp)
====================================
- OnBind 钩子: 任何 RegisterObjectMethod / RegisterGlobalFunction 完成后调用
- 若 bAllowImplicitPropertyAccessors == true (默认开)
  -> ScriptFunction->SetProperty(true) 无差别提升
- 这意味着 C++ 端的 Get/Set 方法不需要写 "property" 关键字
        |
        v
AS 编译器层 (as_compiler.cpp::FindPropertyAccessor, L13996+)
====================================
[Step 1] 在 obj.X 类型表达式遇到时被触发
[Step 2] 计算候选名: getName = "Get" + "X", setName = "Set" + "X"
[Step 3] 在对象类型 (含基类链) 中 FindMethodUntil 收集所有同名方法:
           - multipleGetFuncs: 名字 == getName 且 IsProperty()
           - multipleSetFuncs: 名字 == setName 且 IsProperty()
[Step 4] 按 const-ness 过滤 (FilterConst)
[Step 5] 校验 get 与 set 类型一致 (允许 getter 返回 handle / setter 接收 ref 的特例)
[Step 6] ctx->property_get = getId; ctx->property_set = setId;
         在后续读 / 写表达式时插入函数调用字节码
```

### 核心特性速览

| 特性 | 语法 | 实现策略 |
|------|------|---------|
| **AS 显式装饰** | `void GetX() property { }` | `asTRAIT_PROPERTY` 标志 + 名字必须是 `Get<X>` / `Set<X>` |
| **虚拟属性块** | `int X { get { } set { } }` | parser 拆分为 `GetX()` + `SetX(int value)` 自动注入 trait |
| **C++ 隐式提升** | `Method("FString GetName()", ...)` | `OnBind` 钩子 + `bAllowImplicitPropertyAccessors=true`（默认） |
| **读访问** | `auto Name = Player.Name;` | 编译器查 `GetName` → 调用 |
| **写访问** | `Player.Name = "Hero";` | 编译器查 `SetName(...)` → 调用 |
| **复合赋值** | `Player.Score += 10;` | 必须 get + set 都存在；展开为 `Set(Get() + 10)` |
| **索引属性** | `Container.Item[0] = X;` | `GetItem(int)` + `SetItem(int, T)` 双参签名 |
| **const 过滤** | `const Player.Name` | `FilterConst` 选 const 重载 |
| **类型不匹配检测** | get 返回 `int`，set 接收 `FString` | `TXT_GET_SET_ACCESSOR_TYPE_MISMATCH_FOR_s` 编译期报错 |
| **同名属性遮蔽** | shadow 父类方法 | `shadowed_property_get` 备用通路保留可达性 |

### 与 vanilla AS 的关键差异（必读）

| 维度 | vanilla AS 2.38 | 当前 fork |
|------|----------------|----------|
| 前缀 | `get_X` / `set_X`（小写带下划线） | `GetX` / `SetX`（UE PascalCase） |
| 配置点 | `as_config.h` 同名宏 | 同样在 `as_config.h:1267-1268`，但**值**改为 `"Get"` / `"Set"` |
| C++ 绑定提升 | 必须显式 `SetProperty(true)` | **默认全部隐式提升**（`bAllowImplicitPropertyAccessors=true`） |
| 调用约定 | `obj.x` 严格按属性语法 | 同 + 还可继续按方法语法 `obj.GetX()`，两者**等价共存** |

这个 fork 选择**与 UE C++ 命名约定保持一致**——`AActor::GetActorLocation()` 直接被 AS 端写成 `Actor.ActorLocation`，无需任何额外标注。这是当前项目最显著的"无感糖化"之一。

---

## 一、词法识别：`PROPERTY_TOKEN` 装饰器

**源码所在**: `as_tokendef.h:334`、`as_parser.cpp:3216-3230` 与 `as_parser.cpp:5118-5128`。

### 1.1 token 定义

```cpp
// as_tokendef.h:334
const char * const PROPERTY_TOKEN  = "property";
```

注意：**`property` 不是 ttKeyword**——它是普通标识符，与 `final` / `override` / `mixin` / `accept_temporary` 等并列，统一通过 `IdentifierIs(token, PROPERTY_TOKEN)` 字符串比较识别。这与 `default` / `class` 等真正的关键字（有专属 ttToken）形成对比。

### 1.2 在两处 decorator 列表中出现

```cpp
// as_parser.cpp:3216-3230  方法 decorator (类成员函数)
GetToken(&t1);
if( !IdentifierIs(t1, FINAL_TOKEN)
    && !IdentifierIs(t1, OVERRIDE_TOKEN)
    && !IdentifierIs(t1, PROPERTY_TOKEN)              // ★ 此处
    && !IdentifierIs(t1, MIXIN_TOKEN)
    && !IdentifierIs(t1, ACCEPT_TEMPORARY_TOKEN)
    && ...
)

// as_parser.cpp:5118-5128  函数体后 decorator
if (IdentifierIs(t1, FINAL_TOKEN)
    || IdentifierIs(t1, OVERRIDE_TOKEN)
    || IdentifierIs(t1, PROPERTY_TOKEN)               // ★ 此处
    || IdentifierIs(t1, MIXIN_TOKEN)
    || ...)
```

两处的语义略有不同：

| 位置 | 适用对象 | 写法 |
|------|---------|------|
| L3216 | 类内方法、全局函数 decorator 列表 | `void GetX() property { ... }` |
| L5118 | 一般函数声明的尾部 decorator | 同上，处理函数体后的修饰符 |

**关键约束**：`property` 必须出现在**函数签名后、函数体前**（与 `const` / `final` 同位置）。写在返回类型前会被解析为标识符（变量名），导致语法错误。

### 1.3 与 `Mixin` 装饰器的实现对称性

`property` 与 `mixin` 在 parser 层走的**完全相同的 decorator 字符串识别框架**——这也是为什么 `Syntax_Mixin.md` §1.1 提到的 `IdentifierIs(t1, PROPERTY_TOKEN)` 行为可以无缝迁移到本文。两者唯一的差别是：

- `mixin` 限定到全局函数（且第一个参数即"宿主类型"）；
- `property` 既可在成员函数也可在全局函数上，且对参数形态有专门约束（详见 §三）。

---

## 二、虚拟属性语法：`int X { get; set; }` 的 parser 展开

**源码所在**: `as_parser.cpp:3468-...` 的 `ParseVirtualPropertyDecl` + `as_builder.cpp:5380-5443`。

### 2.1 parser 阶段：生成 `snVirtualProperty` 节点

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
      ├─ snDataType       (int)
      ├─ snIdentifier     (Health)
      ├─ snVirtualProperty   ← get 子节点
      │    ├─ snIdentifier (get)
      │    ├─ ttConst       ← 可选 const 标记
      │    └─ snStatementBlock { return _Health; }
      └─ snVirtualProperty   ← set 子节点
           ├─ snIdentifier (set)
           └─ snStatementBlock { _Health = value; }
```

### 2.2 builder 阶段：拆成两个独立函数

```cpp
// as_builder.cpp:5380-5443  关键拆分逻辑
funcTraits.SetTrait(asTRAIT_PROTECTED, isProtected);

// Virtual property accessor methods are implicitly marked as property accessors
funcTraits.SetTrait(asTRAIT_PROPERTY, true);                                // ★ 强制注入

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

### 2.3 拆分前后对照

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

### 2.4 设计要点

| 要点 | 说明 |
|------|------|
| **强制 `asTRAIT_PROPERTY`** | 虚拟属性块拆出来的 `Get/Set*` 自动带 trait，不依赖 `bAllowImplicitPropertyAccessors` |
| **参数命名固定为 `value`** | setter 形参强制叫 `value`，对应 set 块内 `value` 表达式 |
| **必须有函数体** | 接口除外。否则 `TXT_PROPERTY_ACCESSOR_MUST_BE_IMPLEMENTED` |
| **支持 final/override/const** | 与普通成员方法一致 |
| **未实现的 TODO** | 源码注释 L5385-5386 提到 ① 还不支持单独给 get/set 加 `private`；② 自动声明同名底层字段尚未实现 |

### 2.5 与 vanilla AS 的等价对照

```text
vanilla AS:                      当前 fork:
  int x { get { } set { } }      int x { get { } set { } }
  -> get_x() / set_x(value)      -> Getx() / Setx(value)
                                     ↑↑↑       ↑↑↑
                                   注意大小写不同!
```

虚拟属性语法本身在两边一致；差异在于**展开后的方法名前缀**——这与 §一所述的 `AS_GET_PREFIX = "Get"` 重定义直接相关。

---

## 三、核心约束：`ValidatePropertyAccessorFunc`

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

### 3.1 合法签名矩阵

| 形态 | Getter 签名 | Setter 签名 | 用法 |
|------|------------|------------|------|
| **普通属性** | `T GetX()` 或 `T GetX() const` | `void SetX(T value)` | `obj.X` / `obj.X = v` |
| **索引属性** | `T GetX(K index)` | `void SetX(K index, T value)` | `obj.X[k]` / `obj.X[k] = v` |

### 3.2 三个非法形态

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

### 3.3 隐式提升下的"误判"风险

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

这种情况下函数依然存在并可调用（`obj.GetActorBounds(...)` 仍然有效），只是它**不会**通过 `obj.ActorBounds` 形式被访问——`ValidatePropertyAccessorFunc` 在 builder 后期校验时会把它从属性候选列表中剔除，但不影响普通方法调用路径。这就是"全员隐式提升"安全工作的关键：**校验失败 = 退化为普通方法**，不抛错。

---

## 四、C++ 端的隐式提升：`OnBind` 钩子

**源码所在**: `Core/AngelscriptBinds.cpp:487-511`。

### 4.1 `OnBind` 在所有绑定后被统一调用

```cpp
void FAngelscriptBinds::OnBind(int FunctionId, void* UserData,
                                const FAngelscriptType::FBindParams* BindParams)
{
    auto& Manager = FAngelscriptEngine::Get();
    asCScriptFunction* ScriptFunction = (asCScriptFunction*)Manager.Engine->GetFunctionById(FunctionId);
    if (ScriptFunction != nullptr)
    {
        if (UserData != nullptr)
            ScriptFunction->SetUserData(UserData, 0);

        if (BindParams != nullptr && BindParams->bProtected)
            ScriptFunction->SetProtected(true);

        // ★ 关键: 所有 C++ 绑定函数被无差别提升为 property accessor
        if (Manager.ConfigSettings->bAllowImplicitPropertyAccessors)
        {
            ScriptFunction->SetProperty(true);
        }
    }

    GetPreviouslyBoundFunctionRef() = FunctionId;
}
```

### 4.2 `OnBind` 的覆盖范围

`OnBind` 被以下入口统一调用——本质上是"任何向 AS 引擎注册的可调用函数"：

| 入口 | 用途 |
|------|------|
| `BindMethod` / `Method` | 类成员方法 |
| `BindGlobalFunction` | 模块全局函数 |
| `BindExternBehaviour` | 外部行为（`opAssign` 等运算符） |
| `BindStaticBehaviour` | 静态行为 |
| `BindConstructor` / `BindDestructor` | 构造/析构 |

**全部都会**经过 `OnBind` → 默认全部 `SetProperty(true)`。

### 4.3 全局开关：`bAllowImplicitPropertyAccessors`

```cpp
// Core/AngelscriptSettings.h:55-56
/* Whether to allow any C++ function that starts with Get...() to be accessed as a property.
   (Requires editor restart) */
UPROPERTY(Config, EditDefaultsOnly, Category = "Angelscript", Meta = (ConfigRestartRequired = true))
bool bAllowImplicitPropertyAccessors = true;
```

这是项目级配置，可通过 `Config/DefaultEngine.ini` 关闭：

```ini
[/Script/AngelscriptRuntime.AngelscriptSettings]
bAllowImplicitPropertyAccessors=false
```

关闭后：

- C++ Get/Set 方法**不再**自动暴露为 `obj.X` 形式；
- 必须仍以方法形式调用 `obj.GetX()`；
- `.as` 脚本侧的 `property` 装饰器和虚拟属性块**不受影响**。

### 4.4 设计哲学：为什么默认开？

```text
+ 默认开的优势:
  - UE 现有的所有 GetXxx() / SetXxx() 函数 (成千上万个) 自动获得 AS 属性糖
    -> Actor.GetActorLocation() -> Actor.ActorLocation
    -> Component.SetVisibility() -> Component.Visibility = ...
  - 对脚本作者: 与 Blueprint 的 "Get Actor Location" 节点风格一致
  - C++ 端零侵入: 不需要在 Bind_*.cpp 中给每个函数手写 property 标志

- 代价:
  - 命名冲突: 如果 C++ 类有 Get/Set 但语义不是属性 (如工厂方法 GetInstance()),
    可能被脚本作者误用为属性式访问. 实际影响小, 因为 ValidatePropertyAccessorFunc
    会按签名过滤掉绝大多数误命中
  - 调试可读性: 看脚本看不到 .Foo 调用的 C++ 端究竟是普通方法还是属性
```

**结论**：当前 fork 用"宁可错放、不可漏放"的策略最大化了 UE API 的可读性。这是和 vanilla AS"显式才生效"哲学的根本分歧。

---

## 五、`FindPropertyAccessor` —— 编译期解析主流程

**源码所在**: `as_compiler.cpp:13996-14430`（核心循环）+ `L11264-11270`（`shadowed_property_get` 备用通路）+ `L14959-14965`（同上 fallback）+ `L14632`（无 getter 时报错）。

### 5.1 入口：表达式遇到 `obj.X` 时调用

```cpp
// as_compiler.cpp:13996  (简化)
asCString getName = AS_GET_PREFIX + name;            // 如: "GetHealth"
asCString setName = AS_SET_PREFIX + name;            // 如: "SetHealth"
asCArray<int> multipleGetFuncs, multipleSetFuncs;

if (ctx->type.dataType.IsObject())
{
    asASSERT(ns == 0);
    // 在对象类型 + 基类链中遍历方法
    objectType->FindMethodUntil(getName.AddressOf(), [&](asCScriptFunction* getterFunc)
    {
        if (!getterFunc->IsProperty()) return false;          // ★ 必须有 property 标志
        // ... 收集到 multipleGetFuncs ...
    });
    objectType->FindMethodUntil(setName.AddressOf(), [&](asCScriptFunction* setterFunc)
    {
        if (!setterFunc->IsProperty()) return false;
        // ... 收集到 multipleSetFuncs ...
    });
}
```

### 5.2 重载消歧：const 过滤

```cpp
bool isConst = ctx->type.dataType.IsObjectConst();

if (multipleGetFuncs.GetLength() > 0)
{
    FilterConst(multipleGetFuncs, !isConst);                  // const 对象优先选 const 方法

    if (multipleGetFuncs.GetLength() > 1)
    {
        // 仍然 > 1 -> 真正歧义, 报错
        asCString str;
        str.Format(TXT_MULTIPLE_PROP_GET_ACCESSOR_FOR_s, name.AddressOf());
        Error(str, node);
        PrintMatchingFuncs(multipleGetFuncs, node);
        return -1;
    }
    else
    {
        getId = multipleGetFuncs[0];
    }
}
```

`FilterConst` 的语义：

```text
isConst (对象是 const) -> 保留 const 方法; 非 const 方法不能在 const 对象上调用
!isConst (对象非 const) -> 优先选非 const 方法 (若存在); 否则保留 const 方法

效果:
  const Player.Score   -> 选 int GetScore() const  (避免选非 const)
  Player.Score          -> 选 int GetScore()       (普通对象, 通用情况)
```

### 5.3 类型一致性校验

```cpp
if (getId && setId)
{
    asCScriptFunction* getFunc = builder->GetFunctionDescription(getId);
    asCScriptFunction* setFunc = builder->GetFunctionDescription(setId);

    int idx = (arg ? 1 : 0);                                  // arg=true 时是索引属性, 第二个参数才是 value
    if (!getFunc->returnType.IsEqualExceptRefAndConst(setFunc->parameterTypes[idx])
        && !((getFunc->returnType.IsObjectHandle() && !setFunc->parameterTypes[idx].IsObjectHandle())
             && (getFunc->returnType.GetTypeInfo() == setFunc->parameterTypes[idx].GetTypeInfo())))
    {
        // get / set 类型不匹配
        asCString str;
        str.Format(TXT_GET_SET_ACCESSOR_TYPE_MISMATCH_FOR_s, name.AddressOf());
        Error(str, node);
        // ...
        return -1;
    }
}
```

允许的特例：**getter 返回句柄、setter 接收引用**（同一类型）也算匹配。这是给 UObject 指针属性的兼容路径——`UObject@ GetTarget()` 与 `void SetTarget(UObject& target)` 视为合法配对。

### 5.4 自递归保护

```cpp
// Avoid recursive call, by not treating this as a property accessor call.
// This will also allow having the real property with the same name as the accessors.
if ((isThisAccess || outFunc->objectType == 0)
    && ((getId && getId == outFunc->id)
        || (setId && setId == outFunc->id)))
{
    getId = 0;
    setId = 0;
}
```

如果当前正在编译的就是 `GetX` / `SetX` 本身，访问 `this.X` 不会被解析为属性访问——避免无限递归。同时也允许 getter 内部访问同名底层字段：

```angelscript
class Foo
{
    int _Health;
    int Health
    {
        get const { return _Health; }    // 这里 _Health 是真正的字段, 不会触发 GetHealth
        set       { _Health = value; }   // 同上
    }
}
```

如果不写下划线、字段就叫 `Health`，递归保护使 `return Health;` 也合法（解析为字段访问而非 `GetHealth()` 调用）。

### 5.5 全局开关：`engine->ep.propertyAccessorMode`

```cpp
// Check if the application has disabled script written property accessors
if (engine->ep.propertyAccessorMode == 1)
{
    // 仅允许应用注册的, 禁用脚本声明的访问器
    ...
}
```

`asEP_PROPERTY_ACCESSOR_MODE` 引擎属性允许更精细的策略：

| 值 | 含义 |
|----|------|
| 0 | 完全禁用属性访问器 |
| 1 | 只允许应用 (C++) 注册的访问器 |
| 2 | 允许应用 + 脚本声明的访问器（默认） |

当前项目使用默认值 2，未观察到对此配置的修改。

---

## 六、`shadowed_property_get` —— 同名遮蔽的备用通路

**源码所在**: `as_compiler.cpp:11264-11270` 与 `L14959-14965`（两处对称代码）。

### 6.1 场景：访问器与同名子对象冲突

考虑这种情形：

```angelscript
class FInner { int Value; }

class FOuter
{
    FInner Data;                              // 同名字段 "Data"
    int Data { get { return 42; } }            // 同名虚拟属性 "Data"
}

void Test(FOuter& Outer)
{
    Outer.Data;                                // ←歧义: 字段 还是 属性?
    Outer.Data.Value;                          // ←需要走字段, 才有 .Value
}
```

### 6.2 编译器的"双轨"解析

```cpp
// as_compiler.cpp:11264-11270 + L14959-14965
asCString getName = AS_GET_PREFIX + name;             // "GetData"
asCString setName = AS_SET_PREFIX + name;

auto* getFunc = accessorObj->GetFirstMethod(getName.AddressOf());
auto* setFunc = accessorObj->GetFirstMethod(setName.AddressOf());

ctx->shadowed_property_get = getFunc && getFunc->IsProperty()
    && getFunc->parameterTypes.GetLength() == 0 ? getFunc->GetId() : 0;
ctx->shadowed_property_set = setFunc && setFunc->IsProperty()
    && setFunc->parameterTypes.GetLength() == 1 ? setFunc->GetId() : 0;
```

`shadowed_property_*` 是 ctx（表达式上下文）的备用槽位：

```text
正常路径:   ctx->property_get / property_set      <- 用于 obj.X 形式访问
备用路径:   ctx->shadowed_property_get / set      <- 在字段访问受阻时回退
```

当编译器在主路径选择了"按字段访问"，但后续操作需要属性语义时（比如类型不匹配），可以**回滚**到备用路径，重新发射属性访问字节码。

### 6.3 设计意图

这套备用通路解决了"前向消歧错了怎么办"的问题：

```text
without shadowed_property_*:
  解析 Outer.Data.Value -> 必须立即决定 Data 是字段还是属性
  -> 二选一错了无法回头, 只能报错

with shadowed_property_*:
  解析 Outer.Data       -> 主路径选字段 (得到 FInner 类型)
  解析 .Value           -> FInner.Value 字段访问 (合法)
  返回正确结果
  备用路径未使用, 静默丢弃

  反过来:
  解析 Outer.Data       -> 主路径选字段 (得到 FInner 类型)
  解析 = 100            -> FInner 没有 opAssign(int), 主路径失败
  尝试备用路径          -> shadowed_property_set 调 SetData(100)
  成功
```

这是极少数场景才会激活的细节，但**对可读性有显著改善**——脚本作者不需要为同名担心。

---

## 七、复合赋值与索引属性

### 7.1 复合赋值：`obj.X += value`

**源码所在**: `as_compiler.cpp:14485-14504`。

```cpp
// 复合赋值要求 get + set 都存在
// Compound assignment for indexed property accessors is not supported yet
if (lctx->property_arg != 0)
{
    // 索引属性 + 复合赋值 -> 当前不支持
    Error(TXT_COMPOUND_ASGN_REQUIRE_GET_SET, errNode);
    return -1;
}
```

复合赋值的展开等价于：

```text
源码:        obj.Score += 10;

编译器展开:   obj.SetScore(obj.GetScore() + 10);
```

这要求 `GetScore` 与 `SetScore` 都被识别为属性访问器。**只有 getter 没有 setter** 的属性是只读的，复合赋值会触发 `TXT_PROPERTY_HAS_NO_SET_ACCESSOR`（`as_compiler.cpp:14421`）：

```cpp
// 只有 getter
int Health
{
    get const { return _Health; }
}

// 调用
obj.Health += 1;
// -> TXT_PROPERTY_HAS_NO_SET_ACCESSOR 编译期报错
```

### 7.2 索引属性：`obj.X[key]`

**源码所在**: `as_compiler.cpp:15246-15287`。

```cpp
// Since there are opIndex methods, the compiler should not look for get/set_opIndex accessors
lookForProperty = false;

// Determine which of opIndex methods that match
MatchFunctions(funcs, args, node, "opIndex", 0, objectType, isConst);
if (funcs.GetLength() != 1)
{
    // ...
    Error(TXT_PROP_ACCESS_WITH_INDEX_ONE_ARG, node);
    isOK = false;
}
else
{
    // 检查 opIndex 的属性访问器: get/set_opIndex 或同名属性
    int r = 0;
    if (propertyName == "")
        r = FindPropertyAccessor(propertyName == "" ? "opIndex" : propertyName.AddressOf(), &lctx, args[0], node, ns);
    // ...
}
```

索引属性的两种命名模式：

| 模式 | C++ 形态 | AS 调用形态 |
|------|----------|------------|
| **属性式索引** | `T GetX(K key)` + `void SetX(K key, T value)` | `obj.X[k]` / `obj.X[k] = v` |
| **opIndex 索引** | `T& opIndex(K key)` | `obj[k]` / `obj[k] = v` |

后者是 AS 内置的下标运算符，前者是属性糖。**两者可共存**——编译器会根据是否存在 `opIndex` 决定优先级（有 `opIndex` 时跳过属性查找）。

### 7.3 索引属性的限制

```cpp
// as_compiler.cpp:15272-15273
// TODO: opIndex: Implement support for multiple index arguments in set_opIndex too
Error(TXT_PROP_ACCESS_WITH_INDEX_ONE_ARG, node);
```

当前实现**仅支持单参索引**（`obj.X[k]`），不支持 `obj.X[i, j]` 这种多维索引。源码 TODO 注释表明未来可能扩展。

---

## 八、与值类型的限制

**源码所在**: `as_compiler.cpp:14506-14507` 注释。

```cpp
// Property accessors on value types (or scoped references types) are not supported since
// it is not possible to guarantee that the object will stay alive between the two calls
```

复合赋值场景下，`obj.X += v` 会展开为两次方法调用（先 get 再 set）。如果 `obj` 是**值类型临时对象**或**作用域引用**，无法保证两次调用之间对象仍然存在：

```angelscript
// 假设 GetTransform() 返回一个 FTransform 值类型副本
Actor.GetTransform().Translation += FVector(1, 0, 0);   // ✗ 不会按预期工作
```

```text
展开等价于:
    FTransform tmp1 = Actor.GetTransform();              // 取临时副本
    FVector    tmp2 = tmp1.GetTranslation();             // 在副本上 get
    tmp1.SetTranslation(tmp2 + FVector(1, 0, 0));        // 在副本上 set
    // 离开作用域时 tmp1 析构, 修改丢失
```

这是 AS 编译器的**保守拒绝**——遇到值类型属性的复合赋值会直接报错 `TXT_PROP_ACCESS_NOT_SUPPORTED_ON_VALUE_TYPES` 之类，强制用户改写为：

```angelscript
FTransform Trans = Actor.GetTransform();
Trans.Translation += FVector(1, 0, 0);
Actor.SetTransform(Trans);
```

明确两次调用 + 中间临时变量，意图无歧义。

---

## 九、字节码层面：属性访问的展开

**源码所在**: `as_compiler.cpp:558-563`、`L3324-3340`。

### 9.1 读访问

```text
源码:                        字节码 (概念):
    int v = obj.Health;       PSF [obj]
                              CALLSYS [GetHealth]    ← 系统调用 (C++ 绑定)
                              LOAD                  ← 取返回值
                              STR int v
                              ASSIGN
```

`CALLSYS` vs `CALLINTF` vs `CALL`：

| 字节码 | 用途 |
|--------|------|
| `CALLSYS` | C++ 端绑定函数（隐式提升的属性） |
| `CALL` | AS 脚本定义的虚拟属性（成员函数） |
| `CALLINTF` | 接口方法（当前 fork 用得少） |

### 9.2 写访问

```text
源码:                        字节码 (概念):
    obj.Health = 100;         PSF [obj]
                              PSI 100               ← push immediate value
                              CALLSYS [SetHealth]
                              POP                   ← 丢弃 void 返回
```

### 9.3 复合赋值：两次调用

```text
源码:                        字节码 (概念):
    obj.Health += 10;         PSF [obj]
                              CALLSYS [GetHealth]   ← 第一次调用
                              LOAD
                              ADDI 10
                              PSF [obj]
                              CALLSYS [SetHealth]   ← 第二次调用
                              POP
```

注意：`obj` 被 push 两次。如果 `obj` 是**有副作用**的表达式（如 `GetEnemy(idx)`），两次副作用都会发生：

```angelscript
GetEnemy(0).Health += 10;
// 实际等价于:
//   GetEnemy(0).SetHealth(GetEnemy(0).GetHealth() + 10);
//   ↑ GetEnemy 被调了两次!
```

这是 AS 编译器的已知行为。最佳实践：**对副作用表达式先存到局部变量**：

```angelscript
auto Enemy = GetEnemy(0);
Enemy.Health += 10;
```

---

## 十、关键限制与边缘案例

### 10.1 命名约束总结

```text
合法属性方法名:
  GetX, GetXxxYyy             -> 属性 X / XxxYyy
  SetX, SetXxxYyy             -> 属性 X / XxxYyy

不被识别为属性的方法:
  get_X, set_X                -> 不识别 (vanilla AS 命名, 当前 fork 不用)
  GetterX, GetXValue          -> 属性名变成 "terX" / "XValue", 不是想要的
  Get, Set                    -> 属性名为空, 行为未定义 (一般不会发生)
  IsX                         -> 不识别 (当前 fork 没有 Is 前缀的特殊处理)
```

UE 中常见的 `bool IsXxx()` 函数**不会**自动暴露为属性 `obj.Xxx`——必须按方法调用 `obj.IsXxx()`。这是与 vanilla AS 的差异，也是 fork 选择 `Get/Set` 前缀的代价。

### 10.2 重载消歧失败

```angelscript
class Foo
{
    int  GetValue() property;
    int  GetValue(int idx) property;     // 索引属性
    void GetValue(int a, int b);         // 不会成为属性 (参数 > 1)
}

void Test(Foo& f)
{
    f.Value;     // 选 GetValue() (无参)
    f.Value[3];  // 选 GetValue(int) (索引属性)
}
```

如果 const / 非 const 重载都符合且对象是非 const，编译器会优先选非 const 版本。**两个完全相同签名的属性方法**会触发 `TXT_MULTIPLE_PROP_GET_ACCESSOR_FOR_s`。

### 10.3 类型不匹配

```angelscript
class Bar
{
    int  GetX() property;                // 返回 int
    void SetX(FString value) property;   // 接收 FString
}

void Test(Bar& b)
{
    auto v = b.X;        // OK -> 调 GetX, v 类型为 int
    b.X = "hi";          // ✗ 类型不匹配, TXT_GET_SET_ACCESSOR_TYPE_MISMATCH_FOR_s
    b.X += 1;            // ✗ 同上
}
```

类型不匹配在**任何用法触发时**报错，不在声明时。这是因为 builder 阶段不主动校验 get/set 配对——只在 `FindPropertyAccessor` 阶段触发。

### 10.4 "只有 setter 没有 getter" 的限制

```angelscript
class Baz
{
    void SetX(int v) property;           // 只有 setter
}

void Test(Baz& b)
{
    b.X = 100;           // OK
    auto v = b.X;        // ✗ TXT_PROPERTY_HAS_NO_GET_ACCESSOR (as_compiler.cpp:14632)
    b.X += 1;            // ✗ 复合赋值需要 get
}
```

**只读属性**（仅 getter）合法且常见；**只写属性**（仅 setter）也合法但少见。

### 10.5 接口中的属性

```angelscript
interface IDamageable
{
    int Health
    {
        get const;
        set;
    }
}
```

接口中的虚拟属性**只声明不实现**——`as_builder.cpp:5419` 检查 `objType->IsInterface()` 时跳过 `TXT_PROPERTY_ACCESSOR_MUST_BE_IMPLEMENTED` 错误。但当前 fork 整体上**不支持脚本 interface**（见 `Documents/Guides/ASSDK_Fork_Differences.md`），所以这条路径主要是 vanilla 兼容性遗产。

---

## 十一、完整链路 ASCII 全景

下图以 `class Player { int _Health; int Health { get const { return _Health; } set { _Health = value; } } }` + `Player.Health += 10` 为例：

```text
============================================================================
  Property Accessor 完整生命周期 (声明 -> 解析 -> 拆分 -> 编译 -> 执行)
============================================================================

[Phase 1: .as 源码]
   class Player
   {
       int _Health;
       int Health                    ← 虚拟属性块
       {
           get const { return _Health; }
           set       { _Health = value; }
       }
   }

   void DoDamage(Player& p)
   {
       p.Health += 10;              ← 复合赋值
   }
        |
        | as_parser 阶段
        v
[Phase 2: AST 节点]
   类成员节点:
     - snDeclaration { int _Health }
     - snVirtualProperty
         ├ snDataType (int)
         ├ snIdentifier (Health)
         ├ snVirtualProperty (get) { ttConst, snStatementBlock }
         └ snVirtualProperty (set) { snStatementBlock (含 'value') }

   函数体节点:
     - p.Health += 10
       -> snBinary (compound +=)
            ├ snDataAccess { snIdentifier (p), snIdentifier (Health) }
            └ snConst (10)
        |
        | as_builder 阶段 (L5380-5443)
        v
[Phase 3: 拆分为两个独立函数]
   asCScriptFunction GetHealth:
     name = "GetHealth"   (AS_GET_PREFIX + "Health")
     returnType = int
     parameterTypes = []
     traits.SetTrait(asTRAIT_PROPERTY, true)              ← 强制注入
     traits.SetTrait(asTRAIT_CONST, true)                 ← get const
     bytecode: { return _Health; }

   asCScriptFunction SetHealth:
     name = "SetHealth"
     returnType = void
     parameterTypes = [int (paramName="value")]
     traits.SetTrait(asTRAIT_PROPERTY, true)
     bytecode: { _Health = value; }

   ValidatePropertyAccessorFunc 校验:
     GetHealth: hasGetPrefix=true, returnType=int, params=0  -> 0 (合法)
     SetHealth: hasSetPrefix=true, returnType=void, params=1 -> 0 (合法)
        |
        | as_compiler 阶段, 处理 p.Health += 10
        v
[Phase 4: 表达式编译]
   遇到 p.Health 属性访问:
     CompileVariableAccess
       -> 名字 "Health" 在 Player 类中找不到字段
       -> 触发 FindPropertyAccessor("Health", ...)
            getName = "Get" + "Health" = "GetHealth"
            setName = "Set" + "Health" = "SetHealth"
            objType->FindMethodUntil("GetHealth", ...)
              -> 收到 GetHealth, IsProperty()==true -> 加入 multipleGetFuncs
            objType->FindMethodUntil("SetHealth", ...)
              -> 收到 SetHealth, IsProperty()==true -> 加入 multipleSetFuncs
            FilterConst -> 各保留 1 个
            类型一致性: GetHealth 返回 int, SetHealth 第 0 参 int -> 匹配
            ctx->property_get = GetHealth.id
            ctx->property_set = SetHealth.id

   遇到 += 复合赋值:
     CompileCompoundAssignment
       -> property_arg == 0, 非索引属性, 允许
       -> 同时需要 get + set, 都存在, 通过
       -> 字节码生成:
            PSF [p]
            CALL [GetHealth]                  ← 第一次调用
            LOAD
            ADDI 10
            PSF [p]
            CALL [SetHealth]                  ← 第二次调用
            POP
        |
        | 字节码执行
        v
[Phase 5: 运行时]
   asCContext::Execute:
     PSF [p]              -> push p 指针
     CALL GetHealth(p)    -> 进入 GetHealth, return p->_Health
     LOAD                 -> 把返回值搬到栈顶
     ADDI 10              -> 栈顶 += 10
     PSF [p]              -> push p 指针 (再次)
     CALL SetHealth(p, top) -> 进入 SetHealth, p->_Health = value
     POP                  -> 丢弃 void 返回

   结果: p._Health 最终增加了 10
```

---

## 十二、设计哲学

### 12.1 为什么把 `Get/Set` 大写, 而非 vanilla 的 `get_/set_`？

```cpp
// as_config.h:1267-1268  (当前 fork 修改)
#define AS_GET_PREFIX "Get"
#define AS_SET_PREFIX "Set"
```

Vanilla AS 用 `"get_"` / `"set_"`。修改的根本原因：

```text
+ 与 UE C++ 命名一致:
  - UE 风格: GetActorLocation / SetVisible (PascalCase, 无下划线)
  - vanilla 风格: get_x / set_x (snake_case)
  - 两者并存 -> 同一个项目里命名风格分裂

+ 隐式提升的前提:
  - 如果保留 get_/set_, C++ 端的 GetActorLocation 不会被识别
  - 必须用户自己做名字改写 -> 失去 "无侵入接入 UE API" 的核心优势

+ 与脚本作者认知一致:
  - 写 .as 的人多半是 UE C++ 出身, 看到 obj.ActorLocation 比 obj.actor_location 自然
```

代价：失去了 vanilla AS 的字面兼容性。但这个 fork 已经走得很远了（参见 `AngelscriptForkStrategy.md`），命名约定只是众多分歧之一。

### 12.2 为什么 C++ 绑定默认全员提升？

`bAllowImplicitPropertyAccessors = true` 是默认值。设计意图：

```text
+ 减少 Bind_*.cpp 的样板代码:
  - 反例 (如果默认关): 每个 Get/Set 函数都要写 SetProperty(true) 调用
    -> 124 个 Bind_*.cpp 文件 × 平均 20 个 Get/Set -> 2480+ 个手工标记
  - 正例 (当前默认开): 一行 OnBind 处理所有

+ 与 UE 反射哲学一致:
  - UE UPROPERTY 字段被反射时自动有 Get/Set 配对
  - 隐式提升让 AS 端也获得 "默认全暴露" 的对称性

+ 安全网: ValidatePropertyAccessorFunc 过滤
  - 不符合属性签名规范的方法 (如 GetActorBounds 3 参) 自动退化为普通方法
  - 无 silent breakage, 只是属性糖不可用
```

代价：少数命名意外冲突需要脚本作者意识到——但这种情况实际中**极少**，因为 UE 的 `Get/Set` 命名向来都是属性式语义。

### 12.3 为什么 `shadowed_property_*` 而非"立即报错"？

设计可以是：发现属性访问与字段同名 → 立即 `TXT_AMBIGUOUS_NAME` 报错。但选择了"双轨备用"：

```text
+ 优势:
  - 用户的代码意图通常清晰可识别 (字段 .Value 用于读子结构, 属性 .Value 用于赋值)
  - 编译器先按"字段优先"试着走完, 失败再回滚到属性
  - 大多数情况无感, 用户根本不知道有歧义

- 代价:
  - 编译器实现复杂 (要保留备用槽位 + 失败回滚逻辑)
  - 极端情况下错误信息可能指向回滚后的位置, 让用户困惑
```

实践中这套机制极少触发——脚本作者不会主动制造同名陷阱。但当 C++ 端 UPROPERTY 字段名碰巧与 Get 方法对应名称冲突时（如 `UPROPERTY() FVector Location;` + `FVector GetLocation()`），备用通路会**默默选对**。

### 12.4 为什么不支持值类型属性的复合赋值？

```cpp
// as_compiler.cpp:14506-14507
// Property accessors on value types (or scoped references types) are not supported since
// it is not possible to guarantee that the object will stay alive between the two calls
```

替代方案是：编译器引入临时变量绑定（类似 C++ 的 lvalue 引用临时延长）。但选择**直接拒绝**：

```text
+ 优势:
  - 错误信息明确: 用户知道 "这不行, 改写成局部变量"
  - 避免隐藏的 ABI 复杂度 (临时延长生命周期会触发额外构造/析构)
  - 与 C++ 行为一致: GetTransform().Translation += V 在 C++ 也常需先存局部

- 代价:
  - 用户必须多写一行
```

这是"显式优于隐式"哲学的体现，与项目整体的**性能可预测**目标对齐。

### 12.5 为什么不支持 `Is*` 前缀？

UE 大量使用 `bool IsValid()` / `bool IsHidden()` 等命名。理论上可以扩展 `AS_GET_PREFIX` 接受多前缀（`{ "Get", "Is" }`）。当前选择不做：

```text
+ 不做的理由:
  - Is 前缀通常表示"判定方法"而非"状态读取"
    例: IsValid() 内部可能复杂判断, 不是简单字段访问
  - 暴露成 obj.Valid 容易误导脚本作者以为是字段
  - 加成本: parser/builder 多前缀逻辑显著复杂

+ 用户变通:
  - C++ 端额外暴露 GetIsValid() 函数 (笨重, 不优雅)
  - 或脚本端写 obj.IsValid() (与 C++ 一致, 也算合理)
```

实际项目中没有显式需求，故保持 `Get/Set` 二元前缀至今。

---

## 十三、关键结论速查

| 主题 | 结论 |
|------|------|
| **`property` 不是关键字** | 是普通标识符，靠 `IdentifierIs(token, PROPERTY_TOKEN)` 字符串识别；底层是 `asTRAIT_PROPERTY` trait 标志 |
| **核心入口** | `as_builder.cpp:1470, 4681` SetProperty 触发；`as_compiler.cpp:13996` `FindPropertyAccessor` 解析；`AngelscriptBinds.cpp:487-511` C++ 端隐式提升 |
| **4 条进入路径** | ① AS 装饰器 `f() property`；② 虚拟属性 `int X { get; set; }`；③ C++ 绑定隐式提升；④ AS 全局函数装饰 |
| **fork 命名差异** | `AS_GET_PREFIX = "Get"`、`AS_SET_PREFIX = "Set"`（vanilla 用 `"get_"`/`"set_"`），与 UE C++ PascalCase 命名一致 |
| **隐式提升** | `bAllowImplicitPropertyAccessors=true`（默认）让所有 C++ 绑定函数自动获 `asTRAIT_PROPERTY`，配合 UE `GetXxx`/`SetXxx` 命名实现"零侵入糖化" |
| **签名校验** | `ValidatePropertyAccessorFunc` 三项硬约束：①前缀必须 `Get`/`Set`；②getter 非 void + ≤1 参；③setter void + 1-2 参 |
| **校验失败兜底** | 不抛错，函数退化为普通方法（仍可 `obj.GetX()` 调用），只是 `obj.X` 形式不可用 |
| **虚拟属性块拆分** | parser 生成 `snVirtualProperty` 节点；builder 拆为 `Get<Name>()` + `Set<Name>(value)` 两个函数，强制注入 `asTRAIT_PROPERTY` |
| **重载消歧** | `FindPropertyAccessor` 按 const-ness `FilterConst`；多重匹配触发 `TXT_MULTIPLE_PROP_GET_ACCESSOR_FOR_s` |
| **类型一致性** | get 返回类型必须等于 set value 参数类型；特例：getter 返回句柄、setter 接收同类型引用算匹配 |
| **复合赋值** | `obj.X += v` 展开为 `obj.SetX(obj.GetX() + v)`，需要 get + set 双存在；不支持索引属性 |
| **索引属性** | `T GetX(K)` + `void SetX(K, T)` 单参索引；`obj[k]` 形式与 `opIndex` 共存优先 `opIndex` |
| **值类型限制** | 值类型 / 作用域引用 + 复合赋值 → 编译期拒绝（生命周期保证不了），需手动拆分 |
| **shadowed_property_* 备用** | 字段访问与属性同名时编译器先按字段试，失败回滚属性；用户无感 |
| **自递归保护** | getter/setter 内部访问同名属性时不会触发自递归 |
| **不支持 `Is*` 前缀** | UE 的 `bool IsXxx()` 不会自动成为 `obj.Xxx` 属性，必须按方法调用 |

---

## 十四、关联文档

- 实现原理（兄弟章节）：
  - `Documents/Knowledges/ZH/Syntax_UFUNCTION.md` —— UFUNCTION 修饰符与 traits 体系，本文 `asTRAIT_PROPERTY` 是同框架中的一员
  - `Documents/Knowledges/ZH/Syntax_Mixin.md` —— `mixin` 与 `property` 共享同一套 decorator 字符串识别（`IdentifierIs(t, *_TOKEN)`）
  - `Documents/Knowledges/ZH/Syntax_DefaultStatement.md` —— `default` 语句与本文都涉及"语法糖到方法调用"的展开模式
- 类型与绑定：
  - `Documents/Knowledges/ZH/Type_BindSystem.md` —— `FAngelscriptBinds::OnBind` 在所有 C++ 绑定函数上的统一钩子，本文隐式提升的入口
  - `Documents/Knowledges/ZH/Type_FunctionCaller.md` —— UFunction ↔ asCScriptFunction 桥接
- 与 vanilla AS 的差异：
  - `Documents/Guides/ASSDK_Fork_Differences.md` —— `AS_GET_PREFIX`/`AS_SET_PREFIX` 定义改动属于此族差异之一
  - `Documents/Guides/AngelscriptForkStrategy.md` —— fork 演进策略，解释为何与 vanilla 命名分歧不可调和
- 核心源码：
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_config.h:1267-1268` —— `AS_GET_PREFIX` / `AS_SET_PREFIX`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_tokendef.h:334` —— `PROPERTY_TOKEN`
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_parser.cpp:3216-3230, 3468, 5118-5128` —— decorator 识别 + 虚拟属性 parser
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_builder.cpp:1470, 1721-1746, 4681-4682, 5380-5443` —— 标志注入 + 拆分 + 校验
  - `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_compiler.cpp:558-563, 3324-3340, 11264-11270, 13996-14430, 14485-14507, 14632, 14959-14965, 15246-15287` —— 解析主流程
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptBinds.cpp:487-511` —— `OnBind` 隐式提升钩子
  - `Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptSettings.h:54-56` —— `bAllowImplicitPropertyAccessors` 配置
- 示例脚本：
  - `Script/Examples/Core/Example_PropertySpecifiers.as` —— UPROPERTY 修饰符示例（与本文虚拟属性互补）
  - 隐式提升的 C++ 端实例：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Actor.cpp` 等大量 `Get*/Set*` 方法绑定

---

## 十五、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-29 | 首版：基于当前项目实际源码（`as_config.h:1267-1268` / `as_tokendef.h:334` / `as_parser.cpp:3216-3230, 3468-, 5118-5128` / `as_builder.cpp:1470, 1721-1746, 4681-4682, 5380-5443` / `as_compiler.cpp:558, 3324, 11264-11270, 13996-14430, 14485-14507, 14632, 14959-14965, 15246-15287` / `AngelscriptBinds.cpp:487-511` / `AngelscriptSettings.h:54-56`）完整产出。覆盖：① 4 条进入路径概览（AS 装饰器 / 虚拟属性 / C++ 隐式提升 / 全局函数装饰）+ 4 阶段管线（源码 → parser → builder → compiler）；② `PROPERTY_TOKEN` 词法识别在两处 decorator 列表中出现的位置 + 与 `MIXIN_TOKEN` 的实现对称性；③ 虚拟属性 `int X { get; set; }` 语法的 `snVirtualProperty` AST 节点结构 + `as_builder.cpp:5380-5443` 的拆分逻辑（强制注入 `asTRAIT_PROPERTY` + 名字改写为 `Get<Name>` / `Set<Name>` + 参数命名固定为 `value`）；④ `ValidatePropertyAccessorFunc` 三项硬约束（前缀 / getter 签名 / setter 签名）+ 校验失败退化为普通方法的兜底机制；⑤ C++ 端 `OnBind` 钩子 + `bAllowImplicitPropertyAccessors=true` 默认配置 + 设计哲学（零侵入糖化 vs 命名冲突风险）；⑥ `FindPropertyAccessor` 主流程：候选名计算 + `FindMethodUntil` 收集 + `FilterConst` 消歧 + 类型一致性校验 + 自递归保护；⑦ `shadowed_property_get/set` 备用通路在同名遮蔽场景下的双轨解析；⑧ 复合赋值 `obj.X += v` 展开 + 索引属性 `obj.X[k]` 与 `opIndex` 的优先级关系；⑨ 值类型限制（生命周期保证不了，编译期拒绝）；⑩ 字节码层面的 `CALLSYS` / `CALL` 展开示意 + 副作用表达式两次调用陷阱；⑪ 命名约束总结（`Is*` 前缀不被识别）+ 6 项关键限制；⑫ 完整 ASCII 全景（虚拟属性声明 → AST → 拆分 → 编译 → 字节码 → 运行时）；⑬ 5 个设计哲学解析（`Get/Set` vs `get_/set_` 命名 / 默认全员隐式提升 / `shadowed_property_*` 双轨备用 / 值类型复合赋值拒绝 / 不支持 `Is*` 前缀）。本文与 `Syntax_TArray.md` v1.0 / `Syntax_Mixin.md` / `Syntax_FString.md` v1.0 / `Syntax_UFUNCTION.md` / `Syntax_UPROPERTY.md` / `Syntax_DefaultStatement.md` 风格统一，所有 ASCII 图遵循纯 ASCII 风格。 |

