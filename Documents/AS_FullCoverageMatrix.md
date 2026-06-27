# AngelScript 全覆盖测试清单（草案 v0.1）

> 目标：构建一组 "全能"（übershader 式）覆盖测试，覆盖 AngelScript 在本 UE 插件中的**所有用法情况**。
> 本文档是一份**可勾选的覆盖矩阵**：把每种语言特性 / 类型按「用法变体」拆开罗列，作为编写全覆盖脚本的施工蓝图。
> 这是第一版骨架，请在此基础上增删、勾选、补充备注。
>
> **落地决策（已定）**：放进测试模块新主题目录 `Plugins/Angelscript/Source/AngelscriptTest/Coverage/`，
> 不放 `Script/`（避免启动时编译开销）。Automation 前缀 `Angelscript.TestModule.Coverage.*`。
> 由于测试模块约定 **AS 内联在 C++（`ASTEST_AS(R"AS(...)AS")`）+ 每模块唯一命名用完即弃**，
> 全覆盖以"一个矩阵章节 = 一个 `*Tests.cpp`"落地，而非单个巨型 `.as` 文件。

---

## 图例 / 约定

- 覆盖状态：`⬜ 待写` ｜ `🟡 部分` ｜ `✅ 已覆盖` ｜ `🚫 不支持/不适用`
- "变体轴"：指同一个特性在不同上下文下的写法差异（如：局部变量 / UPROPERTY / 函数参数 / 数组元素 …）。
- 对每个大类，先列**变体轴**（横向维度），再列**具体条目**（纵向维度）。
- 备注里标注：是否需要 PIE、是否仅编辑器、是否依赖可选插件（GameplayTags / GAS）。

### 通用"变体轴"（适用于大多数类型）

编写全覆盖脚本时，每种类型应尽量穿过以下变体轴：

| 轴 | 含义 | 示例写法 |
|----|------|----------|
| A. 局部声明 | 函数体内声明 | `int X;` / `int X = 5;` |
| B. 默认初始化 | 是否赋默认值 | `int X;` vs `int X = 5;` |
| C. 全局/常量 | 全局变量、`const` | `const int G = 1;` |
| D. UPROPERTY 裸标记 | 类成员 + `UPROPERTY()` | `UPROPERTY() int X;` |
| E. UPROPERTY + 说明符 | 叠加各类说明符/meta | 见 §11 |
| F. 函数参数（值传递） | by value | `void F(int X)` |
| G. 函数参数（引用） | `&in` / `&out` / `&inout` | `void F(int&out X)` |
| H. 函数返回值 | 作为返回类型 | `int F()` |
| I. 默认参数 | 形参默认值 | `void F(int X = 3)` |
| J. 数组元素 | `TArray<T>` | `TArray<int> Xs;` |
| K. Map 键/值 | `TMap<K,V>` | `TMap<int,int>` |
| L. 运算符 | 算术/比较/位/复合赋值 | `+ - * / % == < << &=` |
| M. 字面量形式 | 进制/后缀/转义 | `0xFF` `0b1010` `1.0f` |
| N. 显式/隐式转换 | cast / 自动提升 | `float(X)` / `int -> int64` |

---

## 0. 现有覆盖盘点（参考起点，避免重复造轮子）

> 下列文件是项目里已有的示例/测试，新"全覆盖文件"可吸收/合并它们的内容。

### `Script/Examples/Core/`
- ⬜ `Example_AccessSpecifiers.as` — 访问修饰符
- ⬜ `Example_FunctionSpecifiers.as` — 函数说明符
- ⬜ `Example_PropertySpecifiers.as` — 属性说明符
- ⬜ `Example_Math.as` / `Example_MathNamespace`（Tests） — 数学库
- ⬜ `Example_Struct.as` — 结构体
- ⬜ `Example_Enum.as` / `Test_Enums.as` — 枚举
- ⬜ `Example_Array.as` / `Example_Map.as` — 容器
- ⬜ `Example_Delegates.as` — 委托
- ⬜ `Example_Functions.as` — 函数
- ⬜ `Example_MixinMethods.as` — mixin
- ⬜ `Example_FormatString.as` — 字符串格式化
- ⬜ `Example_Timers.as` — 定时器
- ⬜ `Example_ConstructionScript.as` / `Example_MovingObject.as` / `Example_Overlaps.as`
- ⬜ `Example_Widget_UMG.as` / `Example_BehaviorTreeNodes.as` / `Example_CharacterInput.as`

### `Script/Examples/Extended/`
- ⬜ `Example_NetworkReplication.as` — 网络复制
- ⬜ `Example_InterfaceDispatch.as` — 接口分发
- ⬜ `Example_BlueprintSubclass.as` — 被 BP 继承
- ⬜ `Example_SubsystemLifecycle.as` — 子系统生命周期
- ⬜ `Example_ConsoleWorkflow.as`

### `Script/Tests/`
- ⬜ `Test_Handles.as` `Test_Inheritance.as` `Test_ActorLifecycle.as` `Test_GameplayTags.as` `Test_SystemUtils.as`

### 测试模块主题（C++ 侧，已建立的分类，可作为脚本侧分类参照）
`AngelScriptSDK / Bindings / ClassGenerator / Compiler / Core / Debugger / Delegate / Dump / Editor / FileSystem / Functional / GC / HotReload / Memory / Networking / Performance / Preprocessor / StaticJIT / Syntax / UHTTool / Validation`

---

## 1. 基础值类型（Primitive Types）

### 1.1 类型清单
- ⬜ `int8` / `int16` / `int` (int32) / `int64`
- ⬜ `uint8` / `uint16` / `uint` (uint32) / `uint64`
- ⬜ `float` (float32)
- ⬜ `double` (float64)
- ⬜ `bool`
- ⬜ 类型别名 / `auto` 推导

### 1.2 用法矩阵（建议对每个类型穿过下列轴）

| 用法 | int 家族 | uint 家族 | float/double | bool |
|------|:---:|:---:|:---:|:---:|
| A. 局部声明 + 默认初始化 | ⬜ | ⬜ | ⬜ | ⬜ |
| C. 全局 + `const` | ⬜ | ⬜ | ⬜ | ⬜ |
| D. `UPROPERTY()` 成员 | ⬜ | ⬜ | ⬜ | ⬜ |
| L. 算术运算 `+ - * / %` | ⬜ | ⬜ | ⬜ | 🚫 |
| L. 比较 `== != < <= > >=` | ⬜ | ⬜ | ⬜ | `== !=` |
| L. 位运算 `& \| ^ ~ << >>` | ⬜ | ⬜ | 🚫 | 🚫 |
| L. 逻辑 `&& \|\| !` | 🚫 | 🚫 | 🚫 | ⬜ |
| L. 复合赋值 `+= -= *= /= %= &= ...` | ⬜ | ⬜ | ⬜ | ⬜ |
| L. 自增自减 `++ --`（前/后缀） | ⬜ | ⬜ | ⬜ | 🚫 |
| M. 字面量进制 `0x` `0b` `0o`/八进制 | ⬜ | ⬜ | n/a | n/a |
| M. 浮点字面量后缀 `1.0f` `1.0` 科学计数 `1e3` | n/a | n/a | ⬜ | n/a |
| N. 数值转换（提升/截断/cast） | ⬜ | ⬜ | ⬜ | ⬜ |
| F/G. 函数参数（值 / `&in` / `&out` / `&inout`） | ⬜ | ⬜ | ⬜ | ⬜ |
| H. 函数返回值 | ⬜ | ⬜ | ⬜ | ⬜ |
| I. 默认参数 | ⬜ | ⬜ | ⬜ | ⬜ |
| J. 数组元素 `TArray<T>` | ⬜ | ⬜ | ⬜ | ⬜ |
| K. Map 键/值 | ⬜ | ⬜ | ⬜ | ⬜ |

---

## 2. 字符串类型（String Types）

| 用法（变体轴） | `FString` | `FName` | `FText` |
|------|:---:|:---:|:---:|
| 局部声明 + 默认值 | ⬜ | ⬜ | ⬜ |
| 字面量形式 | `"abc"` `f"...{X}"` ⬜ | `n"Name"` ⬜ | `LOCTEXT/NSLOCTEXT` 等价 ⬜ |
| 拼接 `+` / `+=` | ⬜ | 🚫 | ⬜ |
| 比较 `== !=` | ⬜ | ⬜ | ⬜ |
| 常用方法 | `Len/Substring/Split/Replace/ToInt/ToFloat/Format` ⬜ | `IsNone` ⬜ | `Format` ⬜ |
| `UPROPERTY()` 成员 | ⬜ | ⬜ | ⬜ |
| 参数 `const&in` | ⬜ | ⬜ | ⬜ |
| 返回值 | ⬜ | ⬜ | ⬜ |
| 容器元素 | ⬜ | ⬜ | ⬜ |
| 三者互转 | ⬜ | ⬜ | ⬜ |

- ⬜ 字符串转义：`\n \t \" \\`、多行字符串
- ⬜ 格式化插值 `f"格式化 {Var} {Var.Member}"`

---

## 3. 内建数学 & 值类型结构（Built-in Math Structs）

| 类型 | 构造函数 | 成员访问 | 运算符 | `Math::` 函数 | UPROPERTY | 参数 `&in` | 返回值 | 容器元素 |
|------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| `FVector` | ⬜ | `.X.Y.Z` ⬜ | `+ - *` 点/叉乘 ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| `FVector2D` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| `FVector4` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| `FIntPoint` / `FIntVector` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| `FRotator` | ⬜ | `.Pitch/Yaw/Roll` ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| `FQuat` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| `FTransform` | ⬜ | `.Location/Rotation/Scale` ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |
| `FLinearColor` / `FColor` | ⬜ | `.R.G.B.A` ⬜ | ⬜ | ⬜ | `MakeEditWidget`? ⬜ | ⬜ | ⬜ | ⬜ |
| `FMatrix` / `FBox` / `FBox2D` / `FPlane` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ |

- ⬜ `FVector`/`FTransform` 配合 `meta=(MakeEditWidget)` 的 UPROPERTY 用法

---

## 4. 容器类型（Containers）

| 容器 | 声明 | 增删改查 | 遍历 foreach | 运算符/方法 | UPROPERTY | 嵌套 |
|------|:---:|:---:|:---:|:---:|:---:|:---:|
| `TArray<T>` | ⬜ | `Add/Insert/Remove/RemoveAt/Find/Contains/Num` | ⬜ | `[]` 索引、`==` | ⬜ | `TArray<TArray<T>>` |
| `TSet<T>` | ⬜ | `Add/Remove/Contains` | ⬜ | ⬜ | ⬜ | ⬜ |
| `TMap<K,V>` | ⬜ | `Add/Remove/Find/Contains/Keys/Values` | ⬜ | `[]` | ⬜ | `TMap<K,TArray<V>>` |
| AS 原生 `array<T>` / `dictionary` | ⬜ | （若暴露） | ⬜ | ⬜ | n/a | ⬜ |
| `TArrayView` / span | ⬜ | 只读视图 | ⬜ | ⬜ | n/a | n/a |

- ⬜ 元素类型覆盖：基础类型 / struct / UObject handle / FString / 枚举
- ⬜ 排序、过滤、初始化列表 `= {1,2,3}`

---

## 5. 句柄、引用与对象语义（Handles / References / Ownership）

| 引用类型 | 声明 | `null`/`IsValid` | `==` 比较 | `Cast<>` | UPROPERTY | 参数 | 返回 | 容器元素 | 备注 |
|------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|------|
| UObject `handle` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 基础引用语义 |
| `TObjectPtr<T>` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 路由验证 |
| `TWeakObjectPtr<T>` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 弱引用失效 |
| `TSoftObjectPtr<T>` | ⬜ | ⬜ | ⬜ | n/a | ⬜ | ⬜ | ⬜ | ⬜ | 异步加载 |
| `TSoftClassPtr<T>` | ⬜ | ⬜ | ⬜ | n/a | ⬜ | ⬜ | ⬜ | ⬜ | 类软引用 |
| `TSubclassOf<T>` | ⬜ | ⬜ | ⬜ | n/a | ⬜ | ⬜ | ⬜ | ⬜ | 类引用 |
| `TScriptInterface<T>` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 接口引用 |

- ⬜ 引用限定符：`&in` / `&out` / `&inout` / `const T&in`（贯穿上表各列）
- ⬜ 值类型 vs 引用类型语义对比（struct 拷贝 vs class 引用别名）
- ⬜ GC：`NewObject` 创建、脚本对象被引用/释放、跨帧持有

---

## 6. 枚举（Enums）

| 用法（变体轴） | 脚本 `enum` | `UENUM()` 脚本枚举 | C++ 绑定枚举 | 位标志 `Bitflags` |
|------|:---:|:---:|:---:|:---:|
| 声明 | ⬜ | ⬜ | n/a（引用） | ⬜ |
| 显式值 / 默认递增 | ⬜ | ⬜ | n/a | ⬜ |
| `UPROPERTY()` 成员 | ⬜ | ⬜ | ⬜ | ⬜ |
| `switch` 条件 | ⬜ | ⬜ | ⬜ | ⬜ |
| 参数 / 返回值 | ⬜ | ⬜ | ⬜ | ⬜ |
| `EEnum::Value` 访问 | ⬜ | ⬜ | ⬜ | ⬜ |
| 命名空间内枚举 | ⬜ | ⬜ | ⬜ | ⬜ |
| ↔ 整型转换 | ⬜ | ⬜ | ⬜ | ⬜ |
| 暴露给 BP | 🚫 | ⬜ | ⬜ | ⬜ |
| 位运算 `\| & ^`（仅 Bitflags） | n/a | n/a | n/a | ⬜ |

- ⬜ `meta=(Bitmask)` / `meta=(BitmaskEnum=...)` 写法

---

## 7. 结构体（Structs）

| 用法（变体轴） | 脚本 `struct` | `USTRUCT()` | C++ 绑定 struct（FHitResult 等） |
|------|:---:|:---:|:---:|
| 声明 + 成员默认值 | ⬜ | ⬜ | n/a（引用） |
| 构造函数 / 默认构造 | ⬜ | ⬜ | ⬜ |
| 值语义（拷贝而非别名） | ⬜ | ⬜ | ⬜ |
| 运算符重载（`opEquals/opAdd/opAssign/opCmp`） | ⬜ | ⬜ | n/a |
| 嵌套结构体 | ⬜ | ⬜ | ⬜ |
| 含容器 / handle 成员 | ⬜ | ⬜ | ⬜ |
| `UPROPERTY()` 成员 | ⬜ | ⬜ | ⬜ |
| 参数 `const&in` | ⬜ | ⬜ | ⬜ |
| 返回值 | ⬜ | ⬜ | ⬜ |
| 容器元素 | ⬜ | ⬜ | ⬜ |
| 暴露给 BP / 序列化 | 🚫 | ⬜ | ⬜ |

---

## 8. 类（Classes）

### 8.1 继承基类覆盖

| 基类 | 派生声明 | 生命周期重写 | DefaultComponent | Replicated | 被 BP 继承 | 备注 |
|------|:---:|:---:|:---:|:---:|:---:|------|
| `AActor` | ⬜ | `BeginPlay/Tick/EndPlay` ⬜ | ⬜ | ⬜ | ⬜ | 最常用 |
| `UObject` | ⬜ | n/a | 🚫 | ⬜ | ⬜ | 纯数据/逻辑 |
| `UActorComponent` | ⬜ | `BeginPlay/Tick` ⬜ | n/a | ⬜ | ⬜ | |
| `USceneComponent` | ⬜ | ⬜ | n/a | ⬜ | ⬜ | 带 transform |
| `APawn` | ⬜ | `SetupPlayerInputComponent` ⬜ | ⬜ | ⬜ | ⬜ | |
| `ACharacter` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | Movement |
| `APlayerController` | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 输入 |
| `AGameModeBase` | ⬜ | ⬜ | ⬜ | 🚫 | ⬜ | |
| `UUserWidget` | ⬜ | `Construct/Tick` ⬜ | n/a | 🚫 | ⬜ | UMG |
| `UWorldSubsystem` | ⬜ | `Initialize/Deinitialize` ⬜ | 🚫 | 🚫 | 🚫 | |
| `UGameInstanceSubsystem` | ⬜ | ⬜ | 🚫 | 🚫 | 🚫 | |
| `ULocalPlayerSubsystem` | ⬜ | ⬜ | 🚫 | 🚫 | 🚫 | |
| 脚本类 → 脚本类 | ⬜ | super 调用 ⬜ | ⬜ | ⬜ | ⬜ | 多级继承 |

### 8.2 类特性
- ⬜ `UCLASS()` 说明符（见 §12）
- ⬜ `abstract` 类
- ⬜ 实现接口 `: AActor, IMyInterface`
- ⬜ `default` 关键字：覆盖父类属性默认值 / 调用父类 setter（见 §15）
- ⬜ 成员访问修饰符 `private/protected/public`（见 §14）
- ⬜ 构造函数 / `BeginPlay` / `Tick` / `EndPlay` 生命周期重写
- ⬜ `DefaultComponent` 组件成员、`RootComponent`、`Attach`

---

## 9. 接口（Interfaces）

- ⬜ `interface IMyInterface { ... }` 声明（含 `UINTERFACE` 等价）
- ⬜ 类实现接口
- ⬜ 接口方法调用 / 多态分发
- ⬜ `Cast<IMyInterface>` / `TScriptInterface`
- ⬜ C++ 接口在脚本中实现 / 脚本接口被 C++ 调用
- ⬜ 默认方法实现（若支持）

---

## 10. 函数（Functions）

| 特性（变体轴） | 全局自由函数 | 类成员方法 | `const` 方法 | `UFUNCTION` 暴露 |
|------|:---:|:---:|:---:|:---:|
| 基本声明 / 调用 | ⬜ | ⬜ | ⬜ | ⬜ |
| 重载（同名不同参） | ⬜ | ⬜ | ⬜ | ⬜ |
| 默认参数 | ⬜ | ⬜ | ⬜ | ⬜ |
| 参数 `&in` | ⬜ | ⬜ | ⬜ | ⬜ |
| 参数 `&out` | ⬜ | ⬜ | ⬜ | ⬜ |
| 参数 `&inout` | ⬜ | ⬜ | ⬜ | ⬜ |
| 多返回值（`&out`） | ⬜ | ⬜ | ⬜ | ⬜ |
| 递归 | ⬜ | ⬜ | n/a | n/a |
| 命名参数调用 | ⬜ | ⬜ | ⬜ | ⬜ |

- ⬜ `funcdef` 函数指针 / 回调
- ⬜ 局部 lambda / 匿名函数（若支持）
- ⬜ mixin 方法（见 §20）

---

## 11. UPROPERTY 说明符 & meta（全覆盖）

> 参考已删除的 `Example_Coverage_PropertySpecifiers.as` + 现有 `Example_PropertySpecifiers.as`。
> 状态列：编译通过 / 编辑器表现验证 / 运行期验证。

| 分组 | 说明符 / meta | 示例写法 | 状态 |
|------|------|------|:---:|
| 基础 | `UPROPERTY()` 裸标记 | `UPROPERTY() int X;` | ⬜ |
| 编辑 | `EditAnywhere` | `UPROPERTY(EditAnywhere)` | ⬜ |
| 编辑 | `EditDefaultsOnly` | | ⬜ |
| 编辑 | `EditInstanceOnly` | | ⬜ |
| 可见 | `VisibleAnywhere` | | ⬜ |
| 可见 | `VisibleDefaultsOnly` / `VisibleInstanceOnly` | | ⬜ |
| 可编辑性 | `NotEditable` | | ⬜ |
| 可编辑性 | `EditConst` | | ⬜ |
| BP 访问 | `BlueprintReadOnly` | | ⬜ |
| BP 访问 | `BlueprintReadWrite` | | ⬜ |
| 分类 | `Category = "A\|B"` | | ⬜ |
| 存储 | `Transient` / `Config` / `SaveGame` / `Instanced` | | ⬜ |
| meta | `ClampMin/ClampMax/UIMin/UIMax` | `meta=(ClampMin="0")` | ⬜ |
| meta | `EditCondition` + `InlineEditConditionToggle` | | ⬜ |
| meta | `MakeEditWidget` | | ⬜ |
| meta | `ShowOnlyInnerProperties` | | ⬜ |
| meta | `AllowPrivateAccess` | | ⬜ |
| meta | `DisplayName` / `ToolTip` | | ⬜ |
| 组件 | `DefaultComponent` | | ⬜ |
| 组件 | `RootComponent` | | ⬜ |
| 组件 | `Attach = OtherComponent` | | ⬜ |
| 组件 | `AttachSocket = "Socket"` | | ⬜ |
| 组件 | `ShowOnActor` | | ⬜ |
| 复制 | `Replicated` | | ⬜ |
| 复制 | `ReplicatedUsing = OnRep_X`（RepNotify） | | ⬜ |
| 复制 | 复制条件（如有 meta 暴露） | | ⬜ |

---

## 12. UCLASS 说明符（全覆盖）

- ⬜ `UCLASS()` 裸标记
- ⬜ `Abstract`
- ⬜ `Blueprintable` / `NotBlueprintable`
- ⬜ `BlueprintType`
- ⬜ `Config = Game`
- ⬜ `DefaultToInstanced` / `EditInlineNew`
- ⬜ `HideCategories` / `ShowCategories`
- ⬜ `meta=(DisplayName=...)`

---

## 13. UFUNCTION 说明符（全覆盖）

| 分组 | 说明符 | 示例 / 组合 | 状态 |
|------|------|------|:---:|
| 基础 | `UFUNCTION()` 裸标记 | | ⬜ |
| 调用 | `BlueprintCallable` | | ⬜ |
| 调用 | `BlueprintPure` | | ⬜ |
| 调用 | `CallInEditor` | | ⬜ |
| 调用 | `Exec`（控制台命令） | | ⬜ |
| 分类 | `Category = "..."` | | ⬜ |
| meta | `DisplayName/Keywords/ToolTip/WorldContext/DefaultToSelf` | | ⬜ |
| 重写 | `BlueprintOverride`（重写 C++ Implementable/Native Event） | | ⬜ |
| 事件 | `BlueprintEvent`（声明可被 BP 重写的新事件） | | ⬜ |
| RPC | `Server` + `Reliable` + `WithValidation` | | ⬜ |
| RPC | `Server` + `Unreliable` | | ⬜ |
| RPC | `Client` + `Reliable` | | ⬜ |
| RPC | `Client` + `Unreliable` | | ⬜ |
| RPC | `NetMulticast` + `Reliable` | | ⬜ |
| RPC | `NetMulticast` + `Unreliable` | | ⬜ |
| RPC | 与 `Replicated` 属性配合 | | ⬜ |

---

## 14. 访问修饰符（Access Specifiers）

- ⬜ 成员 `private` / `protected` / `public`
- ⬜ 方法可见性
- ⬜ `access` 块语法（若项目支持）
- ⬜ `AllowPrivateAccess` meta 暴露私有成员给 BP
- ⬜ 跨类访问规则验证（应失败的负向用例）

---

## 15. `default` 关键字

- ⬜ `default PropertyName = Value;`（覆盖父类属性默认）
- ⬜ `default SetReplicates(true);`（调用父类默认 setter）
- ⬜ `default Tags.Add(n"Tag");`（默认值修改容器）
- ⬜ 组件属性的 default 覆盖

---

## 16. 运算符重载（Operator Overloading）

| 分组 | 方法名 | 对应符号 | 状态 |
|------|------|------|:---:|
| 算术 | `opAdd` / `opSub` / `opMul` / `opDiv` / `opMod` | `+ - * / %` | ⬜ |
| 算术（右值） | `opAdd_r` 等 `_r` 变体 | 反向操作数 | ⬜ |
| 复合赋值 | `opAddAssign` / `opSubAssign` / ... | `+= -= ...` | ⬜ |
| 比较 | `opEquals` | `== !=` | ⬜ |
| 比较 | `opCmp` | `< <= > >=` | ⬜ |
| 索引 | `opIndex` | `[]` | ⬜ |
| 调用 | `opCall` | `()` 仿函数 | ⬜ |
| 转换 | `opConv` / `opImplConv` | 值类型转换 | ⬜ |
| 转换 | `opCast` / `opImplCast` | 引用类型转换 | ⬜ |
| 赋值 | `opAssign` | `=` | ⬜ |
| 一元 | `opNeg` / `opCom` | `-x` / `~x` | ⬜ |
| 一元 | `opPreInc` / `opPostInc` / `opPreDec` / `opPostDec` | `++x x++ --x x--` | ⬜ |

---

## 17. 控制流与语法结构（Control Flow & Syntax）

- ⬜ `if / else if / else`
- ⬜ `for`（标准三段式）
- ⬜ `for (auto X : Container)`（range-based / foreach）
- ⬜ `while` / `do...while`
- ⬜ `switch / case / default`（含 fallthrough、枚举 switch）
- ⬜ `break` / `continue` / `return`
- ⬜ 三元 `?:`
- ⬜ 短路逻辑 `&& ||`
- ⬜ 块作用域、变量遮蔽
- ⬜ 空语句 / 注释（`//` `/* */` 嵌套）

---

## 18. 命名空间（Namespaces）

- ⬜ `namespace Foo { ... }`
- ⬜ 嵌套命名空间
- ⬜ `Foo::Bar` 访问
- ⬜ 命名空间内的函数 / 枚举 / 常量
- ⬜ 引用 C++ 命名空间（`Math::`、`System::`、`Gameplay::`）

---

## 19. 委托与事件（Delegates / Events）

- ⬜ 单播 `funcdef` / delegate 声明
- ⬜ 动态多播 delegate（`UPROPERTY` 暴露）
- ⬜ `BindUFunction` / 绑定脚本方法
- ⬜ `Broadcast(...)`
- ⬜ `IsBound` / `Unbind` / `Clear`
- ⬜ 委托作为参数 / 成员 / 容器元素
- ⬜ 带参数 / 带返回值的委托

---

## 20. Mixin 方法与函数库（Mixin / Function Libraries）

- ⬜ `mixin` 方法声明（给已有类型挂方法）
- ⬜ 调用 mixin（`Value.MixinMethod()`）
- ⬜ 引用 21 个内建 FunctionLibrary mixin
- ⬜ 自定义 mixin 库

---

## 21. 模板 / 泛型（Templates / Generics）

- ⬜ `TArray<T>` / `TMap<K,V>` 模板实例化
- ⬜ `TSubclassOf<T>` / `TSoftObjectPtr<T>`
- ⬜ AS 原生模板（若暴露 `array<T>` 自定义）
- ⬜ 泛型函数（若支持）

---

## 22. 网络复制（Networking / Replication）

- ⬜ `UPROPERTY(Replicated)` 属性
- ⬜ `ReplicatedUsing` RepNotify 回调
- ⬜ Server / Client / NetMulticast RPC（见 §13.3）
- ⬜ `default SetReplicates(true)` / `SetReplicateMovement`
- ⬜ 复制条件 / 所有权
- ⬜ PIE 多人测试场景（需 PIE）

---

## 23. 异步 / 定时器 / Latent（Async / Timers / Latent）

- ⬜ `System::SetTimer` / `SetTimerForNextTick` / `ClearTimer`
- ⬜ Timer 回调（函数名 / 委托）
- ⬜ Latent action（Delay 等，若脚本支持）
- ⬜ 协程 / coroutine（若支持）
- ⬜ 异步资源加载（`TSoftObjectPtr` 配合）

---

## 24. 预处理器（Preprocessor）

- ⬜ `#include "Other.as"`
- ⬜ `#if / #elif / #else / #endif`
- ⬜ 预定义宏 / 条件编译开关
- ⬜ include 循环 / 依赖解析
- ⬜ 编辑器 only / 平台 only 条件块

---

## 25. 常量、全局与字面量（Constants / Globals / Literals）

- ⬜ `const` 全局常量
- ⬜ 全局变量（脚本模块级）
- ⬜ 数值字面量：十进制 / `0x` 十六进制 / `0b` 二进制 / 八进制
- ⬜ 浮点字面量：`1.0f` / `1.0` / 科学计数 `1e-3`
- ⬜ 布尔字面量 `true/false`
- ⬜ 字符串 / 名称 / 文本字面量：`"..."` / `n"..."` / `f"...{X}..."`
- ⬜ `nullptr` / `null`

---

## 26. const 正确性（Const Correctness）

- ⬜ `const` 局部变量
- ⬜ `const` 成员方法
- ⬜ `const T&in` 参数
- ⬜ const 引用返回
- ⬜ 修改 const 的负向用例（应编译失败）

---

## 27. 类型转换（Casts / Conversions）

- ⬜ 数值隐式提升（int→int64、int→float）
- ⬜ 数值显式截断（`int(Float)`）
- ⬜ `Cast<T>()` 对象向下转型
- ⬜ 枚举 ↔ 整型
- ⬜ struct 之间的转换运算符
- ⬜ FString ↔ FName ↔ FText

---

## 28. 可选插件特性（Optional Plugins）

> 仅在对应插件启用时覆盖。

### 28.1 GameplayTags（`AngelscriptGameplayTags`）
- ⬜ `FGameplayTag` / `FGameplayTagContainer`
- ⬜ Tag 字面量 / 匹配 / 查询
- ⬜ UPROPERTY 暴露、复制

### 28.2 GAS（`AngelscriptGAS`）
- ⬜ `UGameplayAbility` 派生
- ⬜ `GameplayEffect` / `AttributeSet`
- ⬜ Ability 激活 / 标签交互

---

## 29. 负向用例 / 错误诊断（Negative / Diagnostics）

> 这些是"应当报错"的用例，验证编译器诊断而非运行。

- ⬜ 类型不匹配赋值
- ⬜ 访问私有成员
- ⬜ 修改 const
- ⬜ 缺失 `UFUNCTION` 却用 `BlueprintOverride`
- ⬜ 未实现接口方法
- ⬜ 非法说明符组合

---

## 30. 运行时验证钩子（如何"测出来"）

> 全覆盖脚本不仅要能编译，还要能在运行时验证行为。

- ⬜ 用 `Log` / `ensure` / `check` 断言
- ⬜ 提供一个统一入口（如 `RunAllCoverage()`），逐项执行并汇总
- ⬜ 与 C++ `AngelscriptTest` 自动化测试对接（PIE / 非 PIE）
- ⬜ 输出每项 PASS/FAIL，便于回归

---

## 待决策问题

- [x] **5. 落地位置** → 测试模块 `AngelscriptTest/Coverage/`（已定，见文首）。
- [x] **1. 单文件 vs 多文件** → 多文件，一章一个 `*Tests.cpp`（受测试框架内联 AS + 模块隔离约定决定）。

仍待你拍板：

2. **覆盖目的**：偏「编译期能力验证」（能不能写出来）还是「运行期行为验证」（结果对不对）？还是两者都要？
   - 框架天然支持两者：`AssertCompiles`（编译期）/ `ExpectGlobalInt`、`VerifyByPath`（运行期）。
3. **是否纳入负向用例**：负向用例（预期编译失败，`AssertFailsWithError`）是否在范围内？
4. **可选插件**：GameplayTags / GAS 是否纳入本轮覆盖？
5. **优先级 / 第一批**：建议先 §1 基础类型 / §8 类 / §11 UPROPERTY / §13 UFUNCTION 各一个 `*Tests.cpp`。

## 目录落地映射（测试模块 `Coverage/`）

| 矩阵章节 | 计划文件名 | 主要 Pattern（见测试指南 §4） |
|------|------|------|
| §1 基础类型 | `AngelscriptCoveragePrimitivesTests.cpp` | B/F（global round-trip / CQTest） |
| §2 字符串 | `AngelscriptCoverageStringsTests.cpp` | F |
| §3 数学结构 | `AngelscriptCoverageMathStructsTests.cpp` | F |
| §4 容器 | `AngelscriptCoverageContainersTests.cpp` | D/F |
| §5 句柄引用 | `AngelscriptCoverageHandlesTests.cpp` | D |
| §6 枚举 | `AngelscriptCoverageEnumsTests.cpp` | A/D |
| §7 结构体 | `AngelscriptCoverageStructsTests.cpp` | D |
| §8 类/继承 | `AngelscriptCoverageClassesTests.cpp` | C/E |
| §9 接口 | `AngelscriptCoverageInterfacesTests.cpp` | C/E |
| §10 函数 | `AngelscriptCoverageFunctionsTests.cpp` | B/C |
| §11 UPROPERTY | `AngelscriptCoveragePropertySpecifiersTests.cpp` | A/D |
| §13 UFUNCTION | `AngelscriptCoverageFunctionSpecifiersTests.cpp` | A/C |
| §16 运算符重载 | `AngelscriptCoverageOperatorsTests.cpp` | C |
| §17 控制流语法 | `AngelscriptCoverageSyntaxTests.cpp` | A |
| §22 网络复制 | `AngelscriptCoverageNetworkingTests.cpp` | E（需 PIE） |
| §29 负向用例 | 分散到各章 `*_Negative` 方法 | A |
| 其余章节 | 按需补充 | — |
