# AngelScript `int` 全覆盖矩阵（参考样板 v0.2）

> 本文是「按类型」的细粒度全覆盖矩阵，覆盖**整型（int 家族）在 AngelScript 中的所有用法**：
> 声明 / 全局 / 局部 / UPROPERTY / 函数参数 / 返回值 / 运算符 / 字面量 / 类型转换 / 容器 等。
> 它是 `Documents/AS_FullCoverageMatrix.md` §1 的下钻展开，也是其他类型做同类矩阵的**复制样板**。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|------|------|:---:|
| UPROPERTY 属性用法 | `AngelscriptTest/Coverage/AngelscriptCoverageIntPropertyTests.cpp` | 已建 |
| 声明 / 运算符 / 字面量 / 转换 | `AngelscriptTest/Coverage/AngelscriptCoverageIntExpressionTests.cpp` | 已建（部分） |
| 函数参数 / 返回 / 默认参数 / 重载 | `AngelscriptTest/Coverage/AngelscriptCoverageIntFunctionTests.cpp` | 计划 |

- Automation 前缀：`Angelscript.TestModule.Coverage.Int*`
- 运行（属性部分）：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.IntProperty" -Label coverage-int-property -TimeoutMs 1200000`
- 运行（表达式部分）：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.IntExpression" -Label coverage-int-expression -TimeoutMs 1200000`

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`
- 单元格内 `→方法名` 指向覆盖该格的 `TEST_METHOD`。

---

## 子矩阵 1：int 家族 → UE `FProperty` 映射（权威）

> 权威来源：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Primitives.cpp`
> 这是所有 `VerifyByPath<TProp, T>` 选模板参数的依据。

| AS 类型 | C++ NativeType | UE `FProperty` | 绑定结构体 | 字节宽 | 符号 |
|------|------|------|------|:---:|:---:|
| `int8`   | `int8`   | `FInt8Property`   | `FInt8Type`   | 1 | 有 |
| `int16`  | `int16`  | `FInt16Property`  | `FInt16Type`  | 2 | 有 |
| `int`    | `int32`  | `FIntProperty`    | `FIntType`    | 4 | 有 |
| `int64`  | `int64`  | `FInt64Property`  | `FInt64Type`  | 8 | 有 |
| `uint8`  | `uint8`  | `FByteProperty`   | `FUInt8Type`  | 1 | 无 |
| `uint16` | `uint16` | `FUInt16Property` | `FUInt16Type` | 2 | 无 |
| `uint`   | `uint32` | `FUInt32Property` | `FUIntType`   | 4 | 无 |
| `uint64` | `uint64` | `FUInt64Property` | `FUInt64Type` | 8 | 无 |

> `uint8` 映射到 `FByteProperty`（非 `FUInt8Property`），其余无符号类型各有专属 `FUIntNNProperty`。

---

## 子矩阵 2：声明上下文 × int 家族

> 「int 出现在哪里」。覆盖归属：UPROPERTY 行 → Property 测试；其余 → Expression/Function 测试。

| 声明上下文 | 写法示例 | `int8` | `int16` | `int` | `int64` | `uint8` | `uint16` | `uint` | `uint64` |
|------|------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 局部变量（无默认值） | `int X;` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 局部变量（默认值） | `int X = 5;` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 局部 `const` | `const int X = 5;` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 全局 `const` | `const int G = 1;` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 全局可变 | `int G = 1;` | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 |
| 类成员（无 UPROPERTY，脚本可见） | `int X;` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 类成员 `UPROPERTY()` | `UPROPERTY() int X;` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| `auto` 推导 | `auto X = 5;` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

> 本 fork 禁止可变模块级全局变量（"Mutable global variables are not supported"），故「全局可变」行 🚫，只能用 `const` 全局。

---

## 子矩阵 3：UPROPERTY 属性用法 × int 家族

> 覆盖归属：`AngelscriptCoverageIntPropertyTests.cpp`。

| 属性用法 | `int8` | `int16` | `int` | `int64` | `uint8` | `uint16` | `uint` | `uint64` | 覆盖方法 |
|------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|------|
| 声明默认值读回 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `IntFamilyDeclarationDefaults` |
| 写回环（C++→属性→C++） | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `IntFamilyWriteRoundTrip` |
| 边界值（min/max） | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `IntFamilyBoundaryValues` |
| `UPROPERTY` + 说明符 | 🟡 | 🟡 | ✅ | 🟡 | 🟡 | 🟡 | 🟡 | 🟡 | `IntPropertySpecifierFlags`（int 全说明符排列；其他宽度机制相同） |
| `TArray<T>` 元素 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `IntContainerProperties` + `IntContainerPropertiesExtended` |
| `TMap<*, T>` 值 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `IntContainerPropertiesExtended`（FString作键） |
| `TMap<T, *>` 键 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `IntContainerProperties` + `IntContainerPropertiesExtended` |
| `TSet<T>` 元素 | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `IntContainerPropertiesExtended` |
| 复制 `Replicated` | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | Haze fork 不支持 |
| 复制 `ReplicatedUsing` | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | 🚫 | Haze fork 不支持 |
| USTRUCT 内 int 成员（嵌套路径） | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | ⬜ | 需要先建立 USTRUCT 框架 |

---

## 子矩阵 4：UPROPERTY 说明符 × int（细化）

> 当前只在 `int`(int32) 验证；扩展时其它宽度各挂代表性说明符。
> 权威解析：`AngelscriptPreprocessor.cpp::ProcessPropertyMacro` + `AngelscriptClassGenerator.cpp`。
> 基线：每个 UPROPERTY 默认 `EditAnywhere` + `BlueprintReadWrite`，未显式覆盖则带 `CPF_Edit` + `CPF_BlueprintVisible`。

| 说明符 / meta | 期望结果 | 状态 | 覆盖方法 |
|------|------|:---:|------|
| `EditAnywhere` | `CPF_Edit`，不禁 instance/template | ✅ | `IntPropertySpecifierFlags` |
| `EditDefaultsOnly` | `CPF_Edit` + `CPF_DisableEditOnInstance` | ✅ | 同上 |
| `EditInstanceOnly` | `CPF_Edit` + `CPF_DisableEditOnTemplate` | ✅ | 同上 |
| `NotEditable` | 清除 `CPF_Edit` | ✅ | 同上 |
| `EditConst` | `CPF_Edit` + `CPF_EditConst` | ✅ | 同上 |
| `VisibleAnywhere` | `CPF_Edit` + `CPF_EditConst`（fork 语义） | ✅ | 同上 |
| `VisibleDefaultsOnly` | `CPF_EditConst` + `CPF_DisableEditOnInstance` | ✅ | 同上 |
| `VisibleInstanceOnly` | `CPF_EditConst` + `CPF_DisableEditOnTemplate` | ✅ | 同上 |
| `BlueprintReadWrite` | `CPF_BlueprintVisible`，非只读 | ✅ | 同上 |
| `BlueprintReadOnly` | `CPF_BlueprintVisible` + `CPF_BlueprintReadOnly` | ✅ | 同上 |
| `BlueprintHidden` | 清除 `CPF_BlueprintVisible` | ✅ | 同上 |
| `Transient` | `CPF_Transient` | ✅ | 同上 |
| `Config` | `CPF_Config` | ✅ | 同上 |
| `SaveGame` | `CPF_SaveGame` | ✅ | 同上 |
| `AdvancedDisplay` | `CPF_AdvancedDisplay` | ✅ | 同上 |
| `Interp` | `CPF_Interp` | ✅ | 同上 |
| `ExposeOnSpawn` | `CPF_ExposeOnSpawn` | ✅ | 同上 |
| `meta=(ClampMin/ClampMax)` | meta 回读（WITH_EDITOR） | ✅ | 同上 |
| `meta=(UIMin/UIMax)` | meta 回读 | ✅ | 同上 |
| `meta=(EditCondition=...)` | meta 回读 | ✅ | 同上 |
| `Category="..."` | meta `Category` | ✅ | 同上 |
| 组合 `EditAnywhere+BlueprintReadOnly` | `CPF_Edit`+`BlueprintVisible`+`BlueprintReadOnly` | ✅ | 同上 |
| 组合 `EditDefaultsOnly+BlueprintReadOnly+Transient+Category` | 复合标志 + meta | ✅ | 同上 |
| `Replicated` | `CPF_Net` | 🚫 | Haze fork 非法说明符，归 Networking PIE |
| `ReplicatedUsing=OnRep_X` | `CPF_Net` + `RepNotifyFunc` | 🚫 | 同上 |

> 备注：本 fork（`WITH_ANGELSCRIPT_HAZE`）中 `Replicated`/`ReplicatedUsing` 不是合法属性说明符，会编译报「Unknown property specifier」，复制相关覆盖统一放 Networking PIE 套件。
> `VisibleAnywhere` 系列在本 fork 等价于「可见但 `EditConst`」，并不清除 `CPF_Edit`。
> `NotEditable` 只关 `CPF_Edit`，不关 `CPF_BlueprintVisible`（默认 BlueprintReadWrite 仍在）。

---

## 子矩阵 5：容器形态 × int（细化）

| 容器形态 | 状态 | 覆盖方法 | 备注 |
|------|:---:|------|------|
| `TArray<int>` | ✅ | `IntContainerProperties` | 长度 + 索引读 |
| `TArray<int64>` | ✅ | 同上 | 索引读 |
| `TArray<uint8>` | ✅ | 同上 | 索引读 |
| `TArray<int8>` | ✅ | `IntContainerPropertiesExtended` | 索引读 |
| `TArray<int16>` | ✅ | 同上 | 索引读 |
| `TArray<uint16>` | ✅ | 同上 | 索引读 |
| `TArray<uint>` | ✅ | 同上 | 索引读 |
| `TArray<uint64>` | ✅ | 同上 | 索引读 |
| `TMap<int, int>` | ✅ | `IntContainerProperties` | int 作键+值 |
| `TMap<int, FString>` | ✅ | 同上 | int 作键 |
| `TMap<FString, int>` | ✅ | `IntContainerPropertiesExtended` | int 作值（字符串键） |
| `TMap<int8, FString>` | ✅ | `IntContainerPropertiesExtended` | int8 作键 |
| `TMap<int64, FString>` | ✅ | `IntContainerPropertiesExtended` | int64 作键 |
| `TMap<uint, FString>` | ✅ | `IntContainerPropertiesExtended` | uint 作键 |
| `TMap<int, 其它宽度>` | 🟡 | — | 代表性宽度已覆盖 |
| `TSet<int>` | ✅ | `IntContainerPropertiesExtended` | 通过 GetSetNumByPath / SetContainsByPath |
| `TSet<int8>` | ✅ | `IntContainerPropertiesExtended` | 同上 |
| `TSet<int64>` | ✅ | `IntContainerPropertiesExtended` | 同上 |
| `TSet<uint>` | ✅ | `IntContainerPropertiesExtended` | 同上 |
| `TArray<TArray<int>>` 嵌套 | ⬜ | — | 路径解析器有限制 |

> `TMap`/`TSet` 不能用 `Name["Key"]` 直接索引，必须用 `GetMapValueByPath` / `SetContainsByPath` / `GetMapNumByPath` / `GetSetNumByPath`。

---

## 子矩阵 6：函数用法 × int 家族

> 覆盖归属：`AngelscriptCoverageIntFunctionTests.cpp`（已建）。
> 全局自由函数走 `FASGlobalFunctionInvoker`（Pattern B）；UFUNCTION 走 `FFunctionInvoker`（Pattern C）。

| 函数用法 | 写法示例 | `int8` | `int16` | `int` | `int64` | `uint8` | `uint16` | `uint` | `uint64` | 覆盖方法 |
|------|------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|------|
| 参数（值传递） | `void F(int X)` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `FunctionParametersValue` |
| 参数 `&in` | `void F(int&in X)` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `FunctionParametersIn` |
| 参数 `&out` | `void F(int&out X)` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `FunctionParametersOut` |
| 参数 `&inout` | `void F(int&inout X)` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `FunctionParametersInOut` |
| 返回值 | `int F()` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `FunctionReturnValues` |
| 默认参数 | `void F(int X = 3)` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `FunctionDefaultParameters` |
| 多返回（`&out`） | `void F(int&out A, int&out B)` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `FunctionParametersOut` |
| 重载（按宽度） | `F(int)` vs `F(int64)` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `FunctionOverloading` |
| UFUNCTION 参数/返回 | `UFUNCTION() int F(int)` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | `UFunctionParametersAndReturn` |

---

## 子矩阵 7：运算符 × int 家族

> 覆盖归属：`AngelscriptCoverageIntExpressionTests.cpp`。多通过全局函数返回结果断言。

| 运算符组 | 符号 | `int8` | `int16` | `int` | `int64` | `uint8` | `uint16` | `uint` | `uint64` |
|------|------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 算术 | `+ - * / %` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 一元负 | `-x` | ✅ | ✅ | ✅ | ✅ | 🚫 | 🚫 | 🚫 | 🚫 |
| 比较 | `== != < <= > >=` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 位运算 | `& \| ^ ~` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 移位 | `<< >> >>>` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 复合赋值 | `+= -= *= /= %=` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 位复合赋值 | `&= \|= ^= <<= >>=` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| 自增减（前/后缀） | `++x x++ --x x--` | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |

> 一元负对无符号类型标 🚫（语义上仍可写但属环绕行为，按需可单列边界用例）。
> 移位行 `int` 标 ✅：已覆盖 `<<` / `>>` / `>>>`（算术右移）。
> 当前运算符仅在 `int`(int32) 列落地（代表性宽度），其余宽度待按需铺开。

---

## 子矩阵 8：字面量形式

> 覆盖归属：`AngelscriptCoverageIntExpressionTests.cpp`（计划）。

| 字面量形式 | 写法示例 | 状态 | 备注 |
|------|------|:---:|------|
| 十进制 | `123` | ✅ | |
| 十六进制 | `0xFF` | ✅ | |
| 二进制 | `0b1010` | ✅ | 已验证 AS 支持 `0b` |
| 八进制 | `0o17` | ✅ | 已验证 AS 支持 `0o` |
| 负字面量 | `-123` | 🟡 | 由一元负 + 字面量组合覆盖（见子矩阵 7） |
| 大字面量提升 | `10000000000` → int64 | ✅ | 超 int32 自动提升 |
| 无符号溢出域 | `3000000000` → uint | ✅ | 超 int32 max 的正值 |
| 数字分隔/可读性 | （AS 若支持） | ⬜ | 待确认语法 |

---

## 子矩阵 9：类型转换

> 覆盖归属：`AngelscriptCoverageIntExpressionTests.cpp`。

| 转换 | 写法示例 | 状态 | 备注 |
|------|------|:---:|------|
| 隐式提升 `int→int64` | `int64 Y = X;` | ✅ | 宽化 |
| 显式截断 `int64→int` | `int Y = int(L);` | ✅ | 窄化 |
| 有符号↔无符号 `int↔uint` | `uint U = uint(I);` | ✅ | |
| 整型→浮点 `int→float/double` | `double D = X;` | ✅ | 隐式 |
| 浮点→整型 `float/double→int` | `int X = int(D);` | ✅ | 显式截断 |
| 整型↔枚举 | `int(E)` / `EEnum(I)` | ✅ | 双向转换 + round-trip |
| 不同宽度互转 | `int8(I)` / `int64(b)` | ✅ | 已覆盖 `int→int8` |

---

## 子矩阵 10：跨类型运算符重载（混合类型算术）

> 覆盖归属：`AngelscriptCoverageIntExpressionTests.cpp` - `MixedTypeArithmetic` 方法。

| 运算类型 | 示例 | 结果类型 | 状态 | 备注 |
|------|------|:-------:|:---:|------|
| int + int64 | `int(100) + int64(10000000000)` | int64 | ✅ | 提升到较宽类型 |
| int * int64 | `int(2) * int64(5000000000)` | int64 | ✅ | 提升到较宽类型 |
| int + uint | `int(50) + uint(100)` | int/uint | ✅ | 取决于具体值 |
| int8 + int | `int8(10) + int(32)` | int | ✅ | 提升到 int |
| int16 * int | `int16(100) * int(5)` | int | ✅ | 提升到 int |
| uint + uint64 | `uint(1000000000) + uint64(10000000000)` | uint64 | ✅ | 提升到较宽类型 |
| int < int64 | `int(100) < int64(10000000000)` | bool | ✅ | 比较运算 |
| uint > int | `uint(100) > int(50)` | bool | ✅ | 有符号/无符号比较 |
| int8 + int64 | `int8(42) + int64(9000000000)` | int64 | ✅ | 左操作数提升 |
| int64 + int8 | `int64(9000000000) + int8(42)` | int64 | ✅ | 右操作数提升 |
| signed + unsigned | `int(-50) + uint(100)` | 需显式转换 | ✅ | 有符号/无符号混合 |

---

## 子矩阵 11：运算符优先级与结合性

> 覆盖归属：`AngelscriptCoverageIntExpressionTests.cpp` - `OperatorPrecedenceAndAssociativity` 方法。

| 优先级规则 | 示例 | 期望结果 | 状态 | 备注 |
|------|------|:-------:|:---:|------|
| * before + | `2 + 3 * 4` | 14 | ✅ | 乘法优先 |
| / before - | `20 - 10 / 2` | 15 | ✅ | 除法优先 |
| () override | `(2 + 3) * 4` | 20 | ✅ | 括号最高优先级 |
| left-to-right / | `100 / 5 / 2` | 10 | ✅ | 左结合 |
| & before < | `(5 & 3) < 4` | true | ✅ | 位运算先于比较 |
| << before + | `(1 << 3) + 2` | 10 | ✅ | 移位先于加法 |
| > before && | `(5 > 3) && (2 < 4)` | true | ✅ | 比较先于逻辑 |
| 复杂表达式 | `2 + 3 * 4 - 10 / 2` | 9 | ✅ | 多运算符组合 |
| unary - 优先级 | `-5 * 3` | -15 | ✅ | 一元负先于乘法 |
| ++x in expr | `(++x) * 2` (x=5) | 12 | ✅ | 前缀自增先求值 |
| x++ in expr | `(x++) * 2` (x=5) | 10 | ✅ | 后缀自增后求值 |

---

## 子矩阵 12：int 与 UE 数学类型的跨类型运算

> 覆盖归属：`AngelscriptCoverageIntExpressionTests.cpp` - `IntWithUEMathTypes` 方法。

| UE 类型 | 运算符 | 示例 | 状态 | 备注 |
|---------|--------|------|:---:|------|
| **FVector** | `*` | `FVector(1,2,3) * 2` | ✅ | 标量乘法 |
| FVector | `*` (交换律) | `2 * FVector(1,2,3)` | ✅ | int 在左侧 |
| FVector | `/` | `FVector(10,20,30) / 2` | ✅ | 标量除法 |
| FVector | `[]` | `FVector(1,2,3)[1]` | ✅ | 索引访问（返回 float） |
| **FVector2D** | `*` | `FVector2D(3,4) * 5` | ✅ | 2D 标量乘法 |
| **FRotator** | `*` | `FRotator(10,20,30) * 2` | ✅ | 欧拉角缩放 |
| **FLinearColor** | `*` | `FLinearColor(0.5,0.5,0.5,1) * 2` | ✅ | 颜色缩放 |
| **FBox** | `+` | `FBox(...) + FVector(5,5,5)` | ✅ | 包围盒扩展 |
| **FIntVector** | `+` | `FIntVector(1,2,3) + FIntVector(4,5,6)` | ✅ | 整数向量加法 |
| FIntVector | `*` | `FIntVector(2,3,4) * 3` | ✅ | 整数标量乘法 |
| **FIntPoint** | `+` | `FIntPoint(10,20) + FIntPoint(5,15)` | ✅ | 2D 整数向量 |
| FIntPoint | 分量访问 | `FIntPoint(100,200).X` | ✅ | 直接访问 X/Y |
| FVector | 分量比较 | `int(v.X) == 5` | ✅ | 与 int 比较 |

### 覆盖的 UE 类型（7个）
- **FVector** - 3D 浮点向量（最常用）
- **FVector2D** - 2D 浮点向量
- **FRotator** - 欧拉角旋转
- **FLinearColor** - 线性颜色
- **FBox** - AABB 包围盒
- **FIntVector** - 3D 整数向量
- **FIntPoint** - 2D 整数向量

### 覆盖的运算类型
- ✅ 标量乘法/除法（FVector * int, FVector / int）
- ✅ 交换律（int * FVector）
- ✅ 索引运算符（FVector[int]）
- ✅ 向量加法（FIntVector + FIntVector）
- ✅ 包围盒运算（FBox + FVector）
- ✅ 分量访问与比较

---

## 当前 `TEST_METHOD` 清单（已实现）

### `AngelscriptCoverageIntPropertyTests.cpp`（Pattern D）

| 方法 | 断言要点 |
|------|------|
| `IntFamilyDeclarationDefaults` | 8 种整型声明默认值经对应 `FProperty` 读回 |
| `IntFamilyWriteRoundTrip` | 8 种整型 `SetByPath` 写入 + 读回，含负数与 > int32 无符号值 |
| `IntFamilyBoundaryValues` | 各宽度 `TNumericLimits<T>::Min()/Max()` 边界 |
| `IntContainerProperties` | `TArray<int/int64/uint8>` + `TMap<int,int>` / `TMap<int,FString>` |
| `IntContainerPropertiesExtended` | `TArray<int8/int16/uint16/uint/uint64>` + `TMap<FString,int>` + `TSet<int>` |
| `IntPropertySpecifierFlags` | 完整说明符排列：Edit/Visible/Blueprint 访问 + `Transient/Config/SaveGame/AdvancedDisplay/Interp/ExposeOnSpawn` + `meta(Clamp/UI/EditCondition/Category)` + 组合 → `CPF_*` 与 meta（24+ 检查项） |

### `AngelscriptCoverageIntExpressionTests.cpp`（Pattern B/F，全局函数 round-trip）

| 方法 | 断言要点 |
|------|------|
| `LocalDeclarations` | 局部默认/延迟初始化、局部 `const`、`auto`（int / int64）+ **全部 8 种宽度** |
| `GlobalConstDeclarations` | 8 种整型 **全局 `const`**（可变全局被本 fork 禁止，const 是唯一合法形式） |
| `ArithmeticOperators` | `+ - * / %` 与一元负 |
| `BitwiseAndShiftOperators` | `& \| ^ ~ << >> >>>`（含算术右移） |
| `ComparisonOperators` | `== != < <= > >=`（返回 bool） |
| `CompoundAssignmentOperators` | `+= -= *= /= %= &= \|= ^= <<= >>=` 及前/后缀 `++ --` |
| `IntegerLiterals` | 十/十六/二/八进制、int64 提升、uint 范围 |
| `IntegerConversions` | 宽化/截断/有符号↔无符号/int↔double/int→int8/int↔enum |
| `ClassMembersNonProperty` | **类成员（无 UPROPERTY）** - 脚本内直接访问（int / int64 / uint） |
| `MixedTypeArithmetic` | **跨类型运算** - int+int64/int+uint/int8+int/左右操作数类型提升 |
| `IntWithUEMathTypes` | **int 与 UE 数学类型** - FVector*int/FIntVector/FIntPoint/FLinearColor 等 ⭐ |
| `OperatorPrecedenceAndAssociativity` | **运算符优先级与结合性** - 复杂表达式求值顺序 |

### `AngelscriptCoverageIntFunctionTests.cpp`（Pattern B/C，函数调用）

| 方法 | 断言要点 |
|------|------|
| `FunctionParametersValue` | 8 种整型值传递参数 |
| `FunctionParametersIn` | `&in` 参数（int / int64 / uint） |
| `FunctionParametersOut` | `&out` 参数（int / int64 / uint）+ 多返回值 |
| `FunctionParametersInOut` | `&inout` 参数（int / int64 / uint） |
| `FunctionReturnValues` | 8 种整型返回值 |
| `FunctionDefaultParameters` | 默认参数（int / int64 / uint）+ 链式默认 |
| `FunctionOverloading` | 按宽度重载（int / int64 / uint） |
| `UFunctionParametersAndReturn` | UFUNCTION 参数/返回（int / int64 / uint）+ `&out` |

---

## 待补清单（= 各矩阵中的 ⬜，按文件分组）

### A. `AngelscriptCoverageIntPropertyTests.cpp`（扩充现有）
1. 说明符排列已在 `int` 上覆盖齐全（含组合）；剩余仅「铺到其它 7 种宽度」的代表性抽样。
2. 复制：`Replicated` + `ReplicatedUsing` 归 `Networking` 主题（需 PIE；本 fork 这两个不是合法属性说明符）。
3. 容器补全：其余宽度 `TArray`、`TMap<FString,int>`、`TSet<int>`、嵌套容器。
4. 嵌套：AS `USTRUCT` 内 int 成员的嵌套路径读写。

### B. `AngelscriptCoverageIntExpressionTests.cpp`（已建，待铺开）
5. 声明上下文：局部/局部 const/全局 const/`auto` 已覆盖 ✅；**无 UPROPERTY 类成员**仍待补（需类实例，归 Property/Function 文件）。
6. 运算符目前仅 `int`(int32) 列；其余宽度待铺开，移位补 `>>>`（子矩阵 7）。
7. 字面量补数字分隔语法确认（子矩阵 8）。
8. 类型转换补 整型↔枚举、反向窄宽互转（子矩阵 9）。

### C. `AngelscriptCoverageIntFunctionTests.cpp`（新建）
9. 函数参数（值/`&in`/`&out`/`&inout`）、返回、默认参数、多返回、重载（子矩阵 6）。

---

## 如何把本矩阵复用到其它类型

1. 复制本文件为 `Coverage_<Type>.md`。
2. 改「子矩阵 1」为该类型族的 `FProperty` 映射（权威来源 `Bind_*.cpp`）。
3. 改各子矩阵列头为该类型族成员；删掉不适用轴（标 🚫）。
4. 删/改与该类型无关的说明符、容器、运算符行（如 `bool` 无算术、`FString` 无位运算）。
5. 新建对应 `AngelscriptCoverage<Type>PropertyTests.cpp`（+ 必要时 Expression / Function 文件），方法命名沿用 `<Type>Family...` 结构。










