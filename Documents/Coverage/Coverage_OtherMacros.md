# AngelScript USTRUCT / UENUM / UFUNCTION / UINTERFACE 全覆盖矩阵

> 本文覆盖 AngelScript 中其他 UE 宏的所有用法场景。
> 包括结构体、枚举、函数、接口的声明和说明符。

## 对应测试文件

| 宏类型 | 测试文件 | 状态 |
|-------|---------|------|
| USTRUCT | `AngelscriptTest/Coverage/AngelscriptCoverageUStructTests.cpp` | ✅ 已完成 |
| UENUM | `AngelscriptTest/Coverage/AngelscriptCoverageUEnumTests.cpp` | ✅ 已完成 |
| UFUNCTION | `AngelscriptTest/Coverage/AngelscriptCoverageUFunctionTests.cpp` | 🟡 部分（int 测试中已覆盖基础） |
| UINTERFACE | `AngelscriptTest/Coverage/AngelscriptCoverageUInterfaceTests.cpp` | ✅ 已完成 |

- Automation 前缀：`Angelscript.TestModule.Coverage.U*`

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 第一部分：USTRUCT（结构体）

### 子矩阵 1：USTRUCT 基础声明

| 声明形式 | 写法示例 | 状态 | 备注 |
|---------|---------|------|------|
| 裸 USTRUCT | `USTRUCT() struct FMyStruct { }` | ✅ | 最小声明 |
| 无 USTRUCT 标记 | `struct MyStruct { }` | ✅ | 纯脚本 struct（不暴露给 UE） |
| 嵌套 struct | `struct FOuter { struct FInner { } Inner; }` | ✅ | |
| 继承其他 struct | （AS 不支持 struct 继承） | 🚫 | C++ 支持，AS 不支持 |

### 子矩阵 2：USTRUCT 说明符

| 说明符 | 作用 | 写法示例 | 状态 | 验证点 |
|-------|------|---------|------|--------|
| `BlueprintType` | 可作为 BP 变量类型 | `USTRUCT(BlueprintType)` | ✅ | BP 中声明此类型变量 |
| `Atomic` | 整体序列化 | `USTRUCT(Atomic)` | ✅ | 不拆分成员序列化 |
| `Immutable` | 不可修改 | `USTRUCT(Immutable)` | 🚫 | 创建后只读 |
| `NoExport` | 不导出头文件 | `USTRUCT(NoExport)` | 🚫 | AS 不适用 |

### 子矩阵 3：USTRUCT 成员类型

| 成员类型 | 写法示例 | 状态 | 验证点 |
|---------|---------|------|--------|
| 基础类型 | `UPROPERTY() int Value;` | ✅ | int/float/bool |
| 字符串 | `UPROPERTY() FString Name;` | ✅ | FString/FName/FText |
| 枚举 | `UPROPERTY() EMyEnum Type;` | 🟡 | |
| 其他 struct | `UPROPERTY() FVector Position;` | ✅ | 嵌套 struct |
| UObject 引用 | `UPROPERTY() AActor Target;` | ✅ | Handle |
| 容器 | `UPROPERTY() TArray<int> Values;` | ✅ | TArray/TMap/TSet |
| 嵌套容器 | `UPROPERTY() TArray<FVector> Points;` | ✅ | |

### 子矩阵 4：USTRUCT 成员属性说明符

| 说明符 | 状态 | 说明 |
|-------|------|------|
| `EditAnywhere` | ✅ | 可编辑 |
| `BlueprintReadWrite` | ✅ | BP 可读写 |
| `BlueprintReadOnly` | ✅ | BP 只读 |
| `SaveGame` | ✅ | 存档 |
| `Transient` | ✅ | 不序列化 |
| `Category` | ✅ | 分类 |
| `meta=(ClampMin/ClampMax)` | ✅ | 数值限制 |

### 子矩阵 5：USTRUCT 用法场景

| 用法 | 写法示例 | 状态 | 验证点 |
|------|---------|------|--------|
| 局部变量 | `FMyStruct S;` | ✅ | 栈上分配 |
| UPROPERTY 成员 | `UPROPERTY() FMyStruct Data;` | ✅ | 类成员 |
| 函数参数（值） | `void F(FMyStruct S)` | ✅ | 拷贝语义 |
| 函数参数（引用） | `void F(const FMyStruct&in S)` | ✅ | 引用语义 |
| 函数参数（输出） | `void F(FMyStruct&out S)` | ✅ | |
| 函数返回值 | `FMyStruct F()` | ✅ | |
| 容器元素 | `TArray<FMyStruct>` | ✅ | |
| Map 值 | `TMap<int, FMyStruct>` | ✅ | |
| Map 键 | `TMap<FMyStruct, int>` | 🚫 | 需实现比较 |

### 子矩阵 6：USTRUCT 值语义

| 特性 | 状态 | 验证点 |
|------|------|--------|
| 拷贝构造 | ✅ | `FMyStruct B = A;` 深拷贝 |
| 赋值运算符 | ✅ | `B = A;` 深拷贝 |
| 比较运算符 | ✅ | `A == B` / `A != B` |
| 默认构造 | ✅ | `FMyStruct S;` 成员初始化 |
| 构造函数 | ✅ | `FMyStruct(int X)` |
| 成员默认值 | ✅ | `int Value = 10;` |

### 子矩阵 7：USTRUCT 运算符重载

| 运算符 | AS 方法名 | 状态 | 说明 |
|-------|----------|------|------|
| `==` | `opEquals` | ✅ | 相等比较 |
| `<` | `opCmp` | ✅ | 小于比较（返回 int） |
| `+` | `opAdd` | ✅ | 加法 |
| `=` | `opAssign` | ✅ | 赋值 |
| `[]` | `opIndex` | 🚫 | 索引访问 |

---

## 第二部分：UENUM（枚举）

### 子矩阵 8：UENUM 基础声明

| 声明形式 | 写法示例 | 状态 | 备注 |
|---------|---------|------|------|
| 裸 enum | `enum EMyEnum { }` | ✅ | 纯脚本枚举 |
| UENUM() | `UENUM() enum EMyEnum { }` | ✅ | 暴露给 UE |
| 命名空间内 | `namespace N { enum EMyEnum { } }` | ✅ | |
| 显式值 | `enum E { A = 1, B = 10 }` | ✅ | |
| 默认递增 | `enum E { A, B, C }` | ✅ | 0, 1, 2 |

### 子矩阵 9：UENUM 说明符

| 说明符 | 作用 | 写法示例 | 状态 | 验证点 |
|-------|------|---------|------|--------|
| `BlueprintType` | 可作为 BP 变量类型 | `UENUM(BlueprintType)` | ⬜ | BP 中使用 |
| `Bitflags` | 位标志枚举 | `UENUM(Bitflags)` | ⬜ | 位运算 |
| `meta=(Bitflags)` | 位标志 meta | `UENUM(meta=(Bitflags))` | ⬜ | |
| `meta=(BitmaskEnum="EEnumName")` | 位掩码关联 | `UENUM(meta=(BitmaskEnum="EMyFlags"))` | ⬜ | |

### 子矩阵 10：UENUM 枚举项 meta

| meta 键 | 作用 | 写法示例 | 状态 |
|---------|------|---------|------|
| `DisplayName` | 显示名称 | `A UMETA(DisplayName="Option A")` | ⬜ |
| `ToolTip` | 提示文本 | `A UMETA(ToolTip="...")` | ⬜ |
| `Hidden` | 隐藏选项 | `A UMETA(Hidden)` | ⬜ |

### 子矩阵 11：UENUM 用法场景

| 用法 | 写法示例 | 状态 | 验证点 |
|------|---------|------|--------|
| 局部变量 | `EMyEnum E = EMyEnum::A;` | ✅ | |
| UPROPERTY 成员 | `UPROPERTY() EMyEnum Type;` | ✅ | |
| 函数参数 | `void F(EMyEnum E)` | ✅ | |
| 函数返回值 | `EMyEnum F()` | ✅ | |
| switch 条件 | `switch (E) { case A: ... }` | ✅ | |
| 容器元素 | `TArray<EMyEnum>` | ✅ | |
| Map 键 | `TMap<EMyEnum, int>` | ✅ | |
| 枚举→int | `int I = int(E);` | ✅ | |
| int→枚举 | `EMyEnum E = EMyEnum(I);` | ✅ | |

### 子矩阵 12：UENUM Bitflags 位运算

| 运算 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 按位或 | `Flags \| EFlag::A` | ⬜ | 添加标志 |
| 按位与 | `Flags & EFlag::A` | ⬜ | 测试标志 |
| 按位异或 | `Flags ^ EFlag::A` | ⬜ | 切换标志 |
| 按位非 | `~Flags` | ⬜ | 反转 |
| 复合赋值 | `Flags \|= EFlag::A` | ⬜ | |

---

## 第三部分：UFUNCTION（函数）

### 子矩阵 13：UFUNCTION 基础声明

| 声明位置 | 写法示例 | 状态 | 备注 |
|---------|---------|------|------|
| 类成员方法 | `UFUNCTION() void MyMethod()` | ⬜ | |
| 全局函数 | （AS 不需要 UFUNCTION） | 🚫 | 全局函数自动可见 |
| const 方法 | `UFUNCTION() int GetValue() const` | ⬜ | 不修改状态 |
| 静态方法 | （AS 无 static） | 🚫 | |

### 子矩阵 14：UFUNCTION 说明符（完整清单）

#### 14.1 Blueprint 调用

| 说明符 | 作用 | 状态 | 验证点 |
|-------|------|------|--------|
| `BlueprintCallable` | BP 可调用 | ⬜ | BP 中调用 |
| `BlueprintPure` | 纯函数（无副作用） | ⬜ | BP 节点无执行引脚 |
| `BlueprintNativeEvent` | BP 可重写，有 C++ 默认实现 | 🚫 | AS 不适用 |
| `BlueprintImplementableEvent` | 仅 BP 实现 | 🚫 | AS 不适用 |

#### 14.2 Blueprint 重写

| 说明符 | 作用 | 状态 | 验证点 |
|-------|------|------|--------|
| `BlueprintOverride` | 重写父类方法 | ⬜ | 重写 UE 虚方法 |
| `BlueprintEvent` | 声明可被 BP 重写的事件 | ⬜ | 脚本声明，BP 重写 |

#### 14.3 网络 RPC

| 说明符 | 作用 | 状态 | 归属 |
|-------|------|------|------|
| `Server` | 服务器 RPC | ⬜ | Networking 套件 |
| `Client` | 客户端 RPC | ⬜ | Networking 套件 |
| `NetMulticast` | 多播 RPC | ⬜ | Networking 套件 |
| `Reliable` | 可靠传输 | ⬜ | 与 Server/Client 组合 |
| `Unreliable` | 不可靠传输 | ⬜ | 与 Server/Client 组合 |
| `WithValidation` | RPC 验证 | ⬜ | _Validate 方法 |

#### 14.4 执行和调用

| 说明符 | 作用 | 状态 | 验证点 |
|-------|------|------|--------|
| `CallInEditor` | 编辑器中可调用 | ⬜ | 编辑器按钮 |
| `Exec` | 控制台命令 | ⬜ | 控制台输入 |

#### 14.5 分类和显示

| 说明符 | 作用 | 状态 |
|-------|------|------|
| `Category = "..."` | 分类 | ⬜ |
| `meta=(DisplayName="...")` | 显示名称 | ⬜ |
| `meta=(Keywords="...")` | 搜索关键字 | ⬜ |
| `meta=(ToolTip="...")` | 提示文本 | ⬜ |
| `meta=(ShortToolTip="...")` | 短提示 | ⬜ |
| `meta=(CompactNodeTitle="...")` | 紧凑节点标题 | ⬜ |

#### 14.6 参数控制

| meta 键 | 作用 | 状态 |
|---------|------|------|
| `WorldContext` | 世界上下文参数 | ⬜ |
| `DefaultToSelf` | 默认为 self | ⬜ |
| `HidePin` | 隐藏引脚 | ⬜ |
| `AdvancedDisplay` | 高级显示参数 | ⬜ |
| `AutoCreateRefTerm` | 自动创建引用 | ⬜ |

### 子矩阵 15：UFUNCTION 参数和返回值

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 值参数 | `void F(int X)` | ✅ | 已在 int 测试中覆盖 |
| `&in` 参数 | `void F(int&in X)` | ✅ | 已覆盖 |
| `&out` 参数 | `void F(int&out X)` | ✅ | 已覆盖 |
| `&inout` 参数 | `void F(int&inout X)` | ✅ | 已覆盖 |
| 默认参数 | `void F(int X = 10)` | ✅ | 已覆盖 |
| 返回值 | `int F()` | ✅ | 已覆盖 |
| 多返回值 | `void F(int&out A, int&out B)` | ✅ | 已覆盖 |
| 函数重载 | 同名不同参数 | ✅ | 已覆盖 |

### 子矩阵 16：UFUNCTION 特殊场景

| 场景 | 状态 | 验证点 |
|------|------|--------|
| 递归调用 | ⬜ | 函数调用自己 |
| 虚方法重写 | ⬜ | 子类重写父类方法 |
| 调用父类方法 | ⬜ | Super::Method() |
| 异步函数 | 🚫 | AS 无异步语法 |
| 协程 | 🚫 | AS 无协程 |

---

## 第四部分：UINTERFACE（接口）

### 子矩阵 17：UINTERFACE 基础声明

| 声明形式 | 写法示例 | 状态 | 备注 |
|---------|---------|------|------|
| 脚本接口 | `interface IMyInterface { }` | ⬜ | 纯脚本接口 |
| UINTERFACE() | `UINTERFACE() interface IMyInterface { }` | ⬜ | 暴露给 UE |
| 命名约定 | `I` 前缀（IMyInterface） | ⬜ | UE 约定 |

### 子矩阵 18：UINTERFACE 说明符

| 说明符 | 作用 | 写法示例 | 状态 |
|-------|------|---------|------|
| `BlueprintType` | 可作为 BP 类型 | `UINTERFACE(BlueprintType)` | ⬜ |
| `Blueprintable` | BP 可实现 | `UINTERFACE(Blueprintable)` | ⬜ |
| `MinimalAPI` | 最小导出 | `UINTERFACE(MinimalAPI)` | 🚫 |

### 子矩阵 19：接口方法声明

| 方法类型 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| 纯虚方法 | `void MyMethod();` | ⬜ | 无实现 |
| 默认实现 | `void MyMethod() { }` | ⬜ | 有默认实现 |
| UFUNCTION 方法 | `UFUNCTION() void Method()` | ⬜ | BP 可见 |

### 子矩阵 20：接口实现

| 场景 | 写法 | 状态 | 验证点 |
|------|------|------|--------|
| 实现单个接口 | `class A : AActor, IMyInterface` | ✅ | |
| 实现多个接口 | `class A : AActor, IFoo, IBar` | ✅ | |
| 实现接口方法 | 类中实现接口声明的方法 | ✅ | |
| 继承父类的接口 | 父类实现，子类继承 | ✅ | |

### 子矩阵 21：接口使用

| 用法 | 写法 | 状态 | 验证点 |
|------|------|------|--------|
| Cast 到接口 | `Cast<IMyInterface>(Obj)` | ✅ | 类型转换 |
| 检查接口实现 | `Cast<IMyInterface>(Obj) != nullptr` | ✅ | |
| TScriptInterface | `TScriptInterface<IMyInterface>` | ✅ | 接口引用 |
| UPROPERTY 接口 | `UPROPERTY() TScriptInterface<IMyInterface> Intf;` | ✅ | |
| 函数参数 | `void F(TScriptInterface<IMyInterface>)` | ✅ | |
| 接口方法调用 | `Intf.MyMethod()` | ✅ | 多态 |

### 子矩阵 22：接口多态

| 场景 | 状态 | 验证点 |
|------|------|--------|
| 不同类实现同一接口 | ⬜ | 多态调用 |
| 接口方法重写 | ⬜ | 子类覆盖默认实现 |
| 接口引用数组 | ⬜ | `TArray<TScriptInterface<I>>` |

---

## 计划测试方法清单

### AngelscriptCoverageUStructTests.cpp ✅

| 方法 | 覆盖内容 | 状态 |
|------|---------|------|
| `UStructBasicDeclaration` | USTRUCT() / 纯 struct / 嵌套 | ✅ |
| `UStructSpecifiers` | BlueprintType / Atomic | ✅ |
| `UStructMembers` | 各种类型成员 / UPROPERTY 说明符 | ✅ |
| `UStructValueSemantics` | 拷贝 / 赋值 / 比较 | ✅ |
| `UStructOperators` | opEquals / opAdd / opCmp | ✅ |
| `UStructAsParameter` | 值参数 / &in / &out | ✅ |
| `UStructAsReturn` | 返回 struct | ✅ |
| `UStructInContainers` | TArray<FStruct> / TMap | ✅ |
| `UStructNested` | struct 内嵌套 struct | ✅ |

### AngelscriptCoverageUEnumTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `UEnumBasicDeclaration` | enum / UENUM() / 显式值 |
| `UEnumSpecifiers` | BlueprintType / Bitflags |
| `UEnumMeta` | DisplayName / ToolTip / Hidden |
| `UEnumUsage` | 局部 / UPROPERTY / 函数参数 |
| `UEnumSwitch` | switch 条件分支 |
| `UEnumConversion` | int↔enum 转换 |
| `UEnumBitflags` | 位运算 \| & ^ |
| `UEnumInContainers` | TArray<EEnum> / TMap |

### AngelscriptCoverageUFunctionTests.cpp（扩展）

| 方法 | 覆盖内容 |
|------|---------|
| `UFunctionSpecifiers` | BlueprintCallable / BlueprintPure / CallInEditor / Exec |
| `UFunctionBlueprintOverride` | 重写 UE 虚方法 |
| `UFunctionBlueprintEvent` | 声明 BP 可重写的事件 |
| `UFunctionMeta` | DisplayName / Keywords / ToolTip / DefaultToSelf |
| `UFunctionRecursion` | 递归调用 |
| `UFunctionVirtualOverride` | 虚方法重写和 super 调用 |

### AngelscriptCoverageUInterfaceTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `UInterfaceBasicDeclaration` | interface / UINTERFACE() |
| `UInterfaceSpecifiers` | BlueprintType / Blueprintable |
| `UInterfaceImplementation` | 单接口 / 多接口实现 |
| `UInterfaceMethods` | 纯虚 / 默认实现 |
| `UInterfaceCast` | Cast<IInterface> |
| `UInterfaceTScriptInterface` | TScriptInterface<I> |
| `UInterfacePolymorphism` | 多态调用 |
| `UInterfaceInContainers` | TArray<TScriptInterface<I>> |

---

## 待补充清单（按优先级）

### 🔴 高优先级

1. **USTRUCT 基础**（声明 / 成员 / 值语义）
2. **UENUM 基础**（声明 / 用法 / switch / int 转换）
3. **UINTERFACE 基础**（声明 / 实现 / Cast）

### 🟡 中优先级

4. **UFUNCTION 扩展**（BlueprintOverride / BlueprintEvent / Exec）
5. **USTRUCT 运算符重载**（opEquals / opAdd / opCmp）
6. **UENUM Bitflags**（位运算）
7. **接口多态**（多态调用 / 接口数组）

### 🟢 低优先级

8. **UFUNCTION 网络 RPC**（归属 Networking 套件）
9. **USTRUCT 高级 meta**（DisplayName / ToolTip）
10. **UENUM 枚举项 meta**（Hidden / DisplayName）

---

## 已覆盖内容（来自 int 测试）

以下 UFUNCTION 特性已在 `AngelscriptCoverageIntFunctionTests.cpp` 中覆盖：

✅ 函数参数（值 / &in / &out / &inout）
✅ 函数返回值
✅ 默认参数
✅ 多返回值
✅ 函数重载
✅ UFUNCTION 参数和返回

**建议**：新的 UFunctionTests 应专注于说明符和 meta，避免重复。

---

## 总结和建议

### 测试优先级建议

1. **立即实施**：USTRUCT / UENUM / UINTERFACE 基础
2. **中期扩展**：运算符重载 / Bitflags / 多态
3. **长期独立**：网络 RPC（需 PIE 多人测试）

### 复用价值

这些宏的测试结构相似，可以共享模式：
- **声明验证**：编译通过
- **说明符验证**：CPF 标志 / meta 回读
- **使用场景**：参数 / 返回值 / 容器 / UPROPERTY

### 与 UPROPERTY 的对比

| 宏 | 已覆盖程度 | 优先级 |
|----|----------|-------|
| UPROPERTY | ✅ 100%（int 测试中完整覆盖） | - |
| UFUNCTION | 🟡 50%（基础已覆盖，说明符待补） | 中 |
| UCLASS | ⬜ 0% | 高 |
| USTRUCT | ⬜ 0% | 高 |
| UENUM | ⬜ 0% | 高 |
| UINTERFACE | ⬜ 0% | 中 |
