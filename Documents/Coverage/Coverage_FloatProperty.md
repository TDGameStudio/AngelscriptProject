# AngelScript `float`/`double` 全覆盖矩阵（参考样板 v0.2）

> 本文是「按类型」的细粒度全覆盖矩阵，覆盖**浮点型（float / double）在 AngelScript 中的所有用法**：
> 声明 / 全局 / 局部 / UPROPERTY / 函数参数 / 返回值 / 运算符 / 字面量 / 类型转换 / 容器 等。
> 它是 `Documents/AS_FullCoverageMatrix.md` §1 的下钻展开，复用 `Coverage_IntProperty.md` 样板结构。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|------|------|:---:|
| UPROPERTY 属性用法 | `AngelscriptTest/Coverage/AngelscriptCoverageFloatPropertyTests.cpp` | ⬜ 计划 |
| 声明 / 运算符 / 字面量 / 转换 | `AngelscriptTest/Coverage/AngelscriptCoverageFloatExpressionTests.cpp` | ⬜ 计划 |
| 函数参数 / 返回 / 默认参数 / 重载 | `AngelscriptTest/Coverage/AngelscriptCoverageFloatFunctionTests.cpp` | ⬜ 计划 |

- Automation 前缀：`Angelscript.TestModule.Coverage.Float*`
- 运行（属性部分）：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FloatProperty" -Label coverage-float-property -TimeoutMs 1200000`
- 运行（表达式部分）：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FloatExpression" -Label coverage-float-expression -TimeoutMs 1200000`

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`
- 单元格内 `→方法名` 指向覆盖该格的 `TEST_METHOD`。

---

## 子矩阵 1：float 家族 → UE `FProperty` 映射（权威）

> 权威来源：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Primitives.cpp`
> 这是所有 `VerifyByPath<TProp, T>` 选模板参数的依据。

| AS 类型 | C++ NativeType | UE `FProperty` | 绑定结构体 | 字节宽 | 备注 |
|------|------|------|------|:---:|------|
| `float`  | `float`  | `FFloatProperty`  | `FFloatType`  | 4 | 单精度 |
| `double` | `double` | `FDoubleProperty` | `FDoubleType` | 8 | 双精度 |

> 浮点家族只有两个成员，但需注意精度、特殊值（NaN / Inf）、比较语义。

---

## 子矩阵 2：声明上下文 × float 家族

> 「float/double 出现在哪里」。覆盖归属：UPROPERTY 行 → Property 测试；其余 → Expression/Function 测试。

| 声明上下文 | 写法示例 | `float` | `double` |
|------|------|:---:|:---:|
| 局部变量（无默认值） | `float X;` | ⬜ | ⬜ |
| 局部变量（默认值） | `float X = 1.5f;` | ⬜ | ⬜ |
| 局部 `const` | `const float X = 1.5f;` | ⬜ | ⬜ |
| 全局 `const` | `const float G = 1.0f;` | ⬜ | ⬜ |
| 全局可变 | `float G = 1.0f;` | 🚫 | 🚫 |
| 类成员（无 UPROPERTY，脚本可见） | `float X;` | ⬜ | ⬜ |
| 类成员 `UPROPERTY()` | `UPROPERTY() float X;` | ⬜ | ⬜ |
| `auto` 推导 | `auto X = 1.5f;` / `auto Y = 1.5;` | ⬜ | ⬜ |

> 本 fork 禁止可变模块级全局变量，故「全局可变」行 🚫，只能用 `const` 全局。
> `auto` 推导：`1.5f` 推导为 `float`，`1.5` 推导为 `double`。

---

## 子矩阵 3：UPROPERTY 属性用法 × float 家族

> 覆盖归属：`AngelscriptCoverageFloatPropertyTests.cpp`（计划）。

| 属性用法 | `float` | `double` | 覆盖方法 |
|------|:---:|:---:|------|
| 声明默认值读回 | ⬜ | ⬜ | `FloatFamilyDeclarationDefaults` |
| 写回环（C++→属性→C++） | ⬜ | ⬜ | `FloatFamilyWriteRoundTrip` |
| 特殊值（0.0 / -0.0 / NaN / Inf / -Inf） | ⬜ | ⬜ | `FloatFamilySpecialValues` |
| 精度边界值（min/max/epsilon） | ⬜ | ⬜ | `FloatFamilyBoundaryValues` |
| `UPROPERTY` + 说明符 | ⬜ | ⬜ | `FloatPropertySpecifierFlags`（float 全说明符排列） |
| `TArray<T>` 元素 | ⬜ | ⬜ | `FloatContainerProperties` |
| `TMap<*, T>` 值 | ⬜ | ⬜ | `FloatContainerProperties` |
| `TMap<T, *>` 键 | 🚫 | 🚫 | — |
| `TSet<T>` 元素 | 🚫 | 🚫 | — |
| 复制 `Replicated` | ⬜ | ⬜ | — |
| 复制 `ReplicatedUsing` | ⬜ | ⬜ | — |

> `TMap` 键和 `TSet` 不支持浮点（哈希/相等语义不稳定），标 🚫。

---

## 子矩阵 4：UPROPERTY 说明符 × float（细化）

> 基于 int 样板，但 float 特有 meta：`ClampMin/ClampMax` / `UIMin/UIMax` / `Units` 更常用。
> 基线：每个 UPROPERTY 默认 `EditAnywhere` + `BlueprintReadWrite`，未显式覆盖则带 `CPF_Edit` + `CPF_BlueprintVisible`。

| 说明符 / meta | 期望结果 | 状态 | 覆盖方法 |
|------|------|:---:|------|
| `EditAnywhere` | `CPF_Edit`，不禁 instance/template | ⬜ | `FloatPropertySpecifierFlags` |
| `EditDefaultsOnly` | `CPF_Edit` + `CPF_DisableEditOnInstance` | ⬜ | 同上 |
| `EditInstanceOnly` | `CPF_Edit` + `CPF_DisableEditOnTemplate` | ⬜ | 同上 |
| `NotEditable` | 清除 `CPF_Edit` | ⬜ | 同上 |
| `EditConst` | `CPF_Edit` + `CPF_EditConst` | ⬜ | 同上 |
| `VisibleAnywhere` | `CPF_Edit` + `CPF_EditConst`（fork 语义） | ⬜ | 同上 |
| `BlueprintReadWrite` | `CPF_BlueprintVisible`，非只读 | ⬜ | 同上 |
| `BlueprintReadOnly` | `CPF_BlueprintVisible` + `CPF_BlueprintReadOnly` | ⬜ | 同上 |
| `Transient` | `CPF_Transient` | ⬜ | 同上 |
| `meta=(ClampMin="0.0", ClampMax="1.0")` | meta 回读（WITH_EDITOR） | ⬜ | 同上 |
| `meta=(UIMin="0.0", UIMax="100.0")` | meta 回读 | ⬜ | 同上 |
| `meta=(Units="Degrees")` | meta 回读 | ⬜ | 同上 |
| `meta=(Units="Centimeters")` | meta 回读 | ⬜ | 同上 |
| `Category="..."` | meta `Category` | ⬜ | 同上 |
| 组合 `EditAnywhere+ClampMin+ClampMax` | `CPF_Edit` + meta clamp | ⬜ | 同上 |

> float 特有关注：`Units` meta（Degrees / Radians / Centimeters / Meters / Seconds 等）。

---

## 子矩阵 5：容器形态 × float（细化）

| 容器形态 | 状态 | 覆盖方法 | 备注 |
|------|:---:|------|------|
| `TArray<float>` | ⬜ | `FloatContainerProperties` | 长度 + 索引读 |
| `TArray<double>` | ⬜ | 同上 | 索引读 |
| `TMap<int, float>` | ⬜ | 同上 | float 作值 |
| `TMap<FString, double>` | ⬜ | 同上 | double 作值 |
| `TMap<float, *>` | 🚫 | — | 浮点不可哈希 |
| `TSet<float>` | 🚫 | — | 浮点不可哈希 |
| `TArray<TArray<float>>` 嵌套 | ⬜ | — | 路径解析器有限制 |

---

## 子矩阵 6：函数用法 × float 家族

> 覆盖归属：`AngelscriptCoverageFloatFunctionTests.cpp`（计划）。
> 全局自由函数走 `FASGlobalFunctionInvoker`（Pattern B）；UFUNCTION 走 `FFunctionInvoker`（Pattern C）。

| 函数用法 | 写法示例 | `float` | `double` | 覆盖方法 |
|------|------|:---:|:---:|------|
| 参数（值传递） | `void F(float X)` | ⬜ | ⬜ | `FunctionParametersValue` |
| 参数 `const&in` | `void F(const float&in X)` | ⬜ | ⬜ | `FunctionParametersIn` |
| 参数 `&out` | `void F(float&out X)` | ⬜ | ⬜ | `FunctionParametersOut` |
| 参数 `&inout` | `void F(float&inout X)` | ⬜ | ⬜ | `FunctionParametersInOut` |
| 返回值 | `float F()` | ⬜ | ⬜ | `FunctionReturnValues` |
| 默认参数 | `void F(float X = 1.5f)` | ⬜ | ⬜ | `FunctionDefaultParameters` |
| 多返回（`&out`） | `void F(float&out A, float&out B)` | ⬜ | ⬜ | `FunctionParametersOut` |
| 重载（按精度） | `F(float)` vs `F(double)` | ⬜ | ⬜ | `FunctionOverloading` |
| UFUNCTION 参数/返回 | `UFUNCTION() float F(float)` | ⬜ | ⬜ | `UFunctionParametersAndReturn` |

---

## 子矩阵 7：运算符 × float 家族

> 覆盖归属：`AngelscriptCoverageFloatExpressionTests.cpp`（计划）。

| 运算符组 | 符号 | `float` | `double` | 备注 |
|------|------|:---:|:---:|------|
| 算术 | `+ - * /` | ⬜ | ⬜ | 无 `%`（浮点取模） |
| 一元负 | `-x` | ⬜ | ⬜ | |
| 比较 | `== != < <= > >=` | ✅ | ✅ | 需注意浮点精度比较 |
| 位运算 | `& \| ^ ~` | 🚫 | 🚫 | 浮点无位运算 |
| 移位 | `<< >>` | 🚫 | 🚫 | 浮点无移位 |
| 复合赋值 | `+= -= *= /=` | ⬜ | ⬜ | |
| 自增减（前/后缀） | `++x x++ --x x--` | ⬜ | ⬜ | |
| 三元 | `X > 0.0f ? A : B` | ⬜ | ⬜ | |

> 浮点无位运算和移位，标 🚫。
> 浮点无 `%` 运算符（取模），需用 `Math::Fmod`。

---

## 子矩阵 8：字面量形式

> 覆盖归属：`AngelscriptCoverageFloatExpressionTests.cpp`（计划）。

| 字面量形式 | 写法示例 | 状态 | 备注 |
|------|------|:---:|------|
| 十进制浮点（float） | `1.5f` | ⬜ | `f` 后缀 |
| 十进制浮点（double） | `1.5` / `1.5d` | ⬜ | 无后缀默认 double |
| 科学计数（float） | `1.5e3f` / `1e-2f` | ⬜ | |
| 科学计数（double） | `1.5e3` / `1e-2` | ⬜ | |
| 负字面量 | `-1.5f` | ✅ | 由一元负 + 字面量组合 |
| 特殊值字面量 | 需通过 API | ✅ | `Math::NaN` / `Math::Inf` |
| 整数提升到浮点 | `1` → `1.0` | ⬜ | 隐式转换场景 |
| 十六进制浮点 | `0x1.8p3` | 🚫 | AS 不支持（C++11 特性） |

---

## 子矩阵 9：类型转换

> 覆盖归属：`AngelscriptCoverageFloatExpressionTests.cpp`（计划）。

| 转换 | 写法示例 | 状态 | 备注 |
|------|------|:---:|------|
| 隐式提升 `float→double` | `double Y = X;` | ✅ | 宽化 |
| 显式截断 `double→float` | `float Y = float(D);` | ✅ | 窄化，精度损失 |
| 整型→浮点 `int→float/double` | `float F = I;` | ⬜ | 隐式 |
| 浮点→整型 `float/double→int` | `int I = int(F);` | ✅ | 显式截断 |
| 浮点↔枚举 | 🚫 | 🚫 | 无直接语义 |
| 精度损失验证 | `double→float` 超精度 | ⬜ | 边界用例 |

---

## 子矩阵 10：浮点特殊值与比较

> 浮点特有关注点：NaN / Inf / -0.0 / 精度比较。

| 特殊值用法 | 写法示例 | 状态 | 备注 |
|------|------|:---:|------|
| NaN 生成 | `Math::NaN` 或 `0.0f / 0.0f` | ✅ | |
| NaN 检测 | `Math::IsNaN(X)` | ✅ | `X == NaN` 永远 false |
| Inf 生成 | `Math::Inf` 或 `1.0f / 0.0f` | ✅ | |
| -Inf | `-Math::Inf` | ✅ | |
| Inf 检测 | `Math::IsFinite(X)` | ✅ | |
| -0.0 vs 0.0 | `X == -0.0f` | ✅ | 比较结果相等，但符号位不同 |
| 精度比较 | `Math::IsNearlyEqual(A, B, Tolerance)` | ✅ | 浮点不应直接 `==` |
| 精度边界 | `FLT_EPSILON` / `DBL_EPSILON` | ⬜ | 最小可区分差 |

---

## 计划 `TEST_METHOD` 清单（待实现）

### `AngelscriptCoverageFloatPropertyTests.cpp`（Pattern D）

| 方法 | 断言要点 |
|------|------|
| `FloatFamilyDeclarationDefaults` | float/double 声明默认值经 `FFloatProperty` / `FDoubleProperty` 读回 |
| `FloatFamilyWriteRoundTrip` | `SetByPath` 写入 + 读回（正/负/小数） |
| `FloatFamilySpecialValues` | NaN / Inf / -Inf / -0.0 写回环（需验证 NaN ≠ NaN） |
| `FloatFamilyBoundaryValues` | `TNumericLimits<float/double>::Min()/Max()/Epsilon()` |
| `FloatContainerProperties` | `TArray<float/double>` + `TMap<int,float>` / `TMap<FString,double>` |
| `FloatPropertySpecifierFlags` | Edit/Visible/Blueprint 访问 + `ClampMin/ClampMax/UIMin/UIMax/Units/Category` → `CPF_*` 与 meta |

### `AngelscriptCoverageFloatExpressionTests.cpp`（Pattern B/F）

| 方法 | 断言要点 |
|------|------|
| `LocalDeclarations` | 局部默认/延迟初始化、局部 `const`、`auto`（float / double） |
| `GlobalConstDeclarations` | float/double **全局 `const`** |
| `ArithmeticOperators` | `+ - * /` 与一元负（无 `%`） |
| `ComparisonOperators` | `== != < <= > >=`（含精度陷阱警告） |
| `CompoundAssignmentOperators` | `+= -= *= /=` 及前/后缀 `++ --` |
| `FloatLiterals` | 十进制 / 科学计数 / `f` 后缀 / 默认 double |
| `FloatConversions` | float↔double / int→float / float→int / 精度损失 |
| `SpecialValuesAndComparison` | NaN / Inf / -Inf / IsNaN / IsFinite / IsNearlyEqual |

### `AngelscriptCoverageFloatFunctionTests.cpp`（Pattern B/C）

| 方法 | 断言要点 |
|------|------|
| `FunctionParametersValue` | float/double 值传递参数 |
| `FunctionParametersIn` | `const&in` 参数 |
| `FunctionParametersOut` | `&out` 参数 + 多返回值 |
| `FunctionParametersInOut` | `&inout` 参数 |
| `FunctionReturnValues` | float/double 返回值 |
| `FunctionDefaultParameters` | 默认参数（含 `f` 后缀字面量） |
| `FunctionOverloading` | 按精度重载（float vs double） |
| `UFunctionParametersAndReturn` | UFUNCTION 参数/返回 + `&out` |

---

## 待补清单（= 各矩阵中的 ⬜，按优先级）

### A. 核心属性用法（`FloatPropertyTests.cpp`）
1. 声明默认值 + 写回环 + 边界值。
2. 特殊值（NaN / Inf）的序列化/反序列化（UPROPERTY 能否保存 NaN？）。
3. 说明符完整排列（Edit/Visible/Blueprint + Clamp/UI/Units）。
4. 容器（`TArray` / `TMap` 值）。

### B. 表达式与运算（`FloatExpressionTests.cpp`）
5. 局部/全局 const 声明。
6. 算术/比较/复合赋值/自增减运算符。
7. 字面量形式（十进制 / 科学计数 / 后缀）。
8. 类型转换（float↔double / int↔float / 精度损失）。
9. 特殊值处理（NaN / Inf / IsNaN / IsNearlyEqual）。

### C. 函数用法（`FloatFunctionTests.cpp`）
10. 参数（值 / `const&in` / `&out` / `&inout`）、返回、默认参数、重载。

---

## 与 int 样板的差异点

| 差异维度 | int | float/double | 说明 |
|------|-----|--------------|------|
| 家族成员数 | 8 种（int8/16/32/64 + uint8/16/32/64） | 2 种（float / double） | 浮点简单得多 |
| 位运算 | 支持 `& \| ^ ~ << >>` | 🚫 不支持 | |
| 取模 `%` | 支持 | 🚫 用 `Math::Fmod` | |
| 特殊值 | 无 | NaN / Inf / -Inf / -0.0 | 浮点特有陷阱 |
| 哈希/相等 | 稳定 | 不稳定 | 浮点不能作 TMap 键或 TSet 元素 |
| 精度比较 | `==` 可靠 | `==` 不可靠，用 `IsNearlyEqual` | |
| 字面量后缀 | 无 | `f`（float）/ 无后缀默认 double | |
| 科学计数 | 🚫 | 支持 `1e3` | |
| `Units` meta | 罕见 | 常用（Degrees / Centimeters 等） | |

---

## 如何把本矩阵复用到其它类型

1. 复制本文件为 `Coverage_<Type>.md`。
2. 改「子矩阵 1」为该类型族的 `FProperty` 映射（权威来源 `Bind_*.cpp`）。
3. 改各子矩阵列头为该类型族成员；删掉不适用轴（如本文删除位运算/取模）。
4. 添加类型特有子矩阵（如本文的「子矩阵 10：浮点特殊值与比较」）。
5. 新建对应 `AngelscriptCoverage<Type>PropertyTests.cpp`，方法命名沿用 `<Type>Family...` 结构。








