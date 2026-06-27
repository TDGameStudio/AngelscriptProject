# AngelScript `bool` 全覆盖矩阵（参考样板 v0.2）

> 本文是「按类型」的细粒度全覆盖矩阵，覆盖**布尔型（bool）在 AngelScript 中的所有用法**：
> 声明 / 全局 / 局部 / UPROPERTY / 函数参数 / 返回值 / 运算符 / 字面量 / 类型转换 / 容器 等。
> 它是 `Documents/AS_FullCoverageMatrix.md` §1 的下钻展开，复用 `Coverage_IntProperty.md` 样板结构。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|------|------|:---:|
| UPROPERTY 属性用法 | `AngelscriptTest/Coverage/AngelscriptCoverageBoolPropertyTests.cpp` | ⬜ 计划 |
| 声明 / 运算符 / 字面量 / 转换 | `AngelscriptTest/Coverage/AngelscriptCoverageBoolExpressionTests.cpp` | ⬜ 计划 |
| 函数参数 / 返回 / 默认参数 / 重载 | `AngelscriptTest/Coverage/AngelscriptCoverageBoolFunctionTests.cpp` | ⬜ 计划 |

- Automation 前缀：`Angelscript.TestModule.Coverage.Bool*`
- 运行（属性部分）：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.BoolProperty" -Label coverage-bool-property -TimeoutMs 1200000`
- 运行（表达式部分）：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.BoolExpression" -Label coverage-bool-expression -TimeoutMs 1200000`

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`
- 单元格内 `→方法名` 指向覆盖该格的 `TEST_METHOD`。

---

## 子矩阵 1：bool → UE `FProperty` 映射（权威）

> 权威来源：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_Primitives.cpp`
> 这是所有 `VerifyByPath<TProp, T>` 选模板参数的依据。

| AS 类型 | C++ NativeType | UE `FProperty` | 绑定结构体 | 字节宽 | 备注 |
|------|------|------|------|:---:|------|
| `bool` | `bool` | `FBoolProperty` | `FBoolType` | 1 | 单字节布尔 |

> 注意：UE 的 `FBoolProperty` 有字段偏移和字节掩码的特殊处理（bitfield packing），但 AS 绑定使用完整字节。

---

## 子矩阵 2：声明上下文 × bool

> 「bool 出现在哪里」。覆盖归属：UPROPERTY 行 → Property 测试；其余 → Expression/Function 测试。

| 声明上下文 | 写法示例 | `bool` |
|------|------|:---:|
| 局部变量（无默认值） | `bool B;` | ⬜ |
| 局部变量（默认值） | `bool B = true;` | ⬜ |
| 局部 `const` | `const bool B = false;` | ⬜ |
| 全局 `const` | `const bool G = true;` | ⬜ |
| 全局可变 | `bool G = true;` | 🚫 |
| 类成员（无 UPROPERTY，脚本可见） | `bool B;` | ⬜ |
| 类成员 `UPROPERTY()` | `UPROPERTY() bool B;` | ⬜ |
| `auto` 推导 | `auto B = true;` | ⬜ |

> 本 fork 禁止可变模块级全局变量，故「全局可变」行 🚫，只能用 `const` 全局。

---

## 子矩阵 3：UPROPERTY 属性用法 × bool

> 覆盖归属：`AngelscriptCoverageBoolPropertyTests.cpp`（计划）。

| 属性用法 | `bool` | 覆盖方法 |
|------|:---:|------|
| 声明默认值读回（true / false） | ⬜ | `BoolDeclarationDefaults` |
| 写回环（C++→属性→C++） | ⬜ | `BoolWriteRoundTrip` |
| `UPROPERTY` + 说明符 | ⬜ | `BoolPropertySpecifierFlags` |
| `TArray<bool>` 元素 | ⬜ | `BoolContainerProperties` |
| `TMap<*, bool>` 值 | ⬜ | `BoolContainerProperties` |
| `TMap<bool, *>` 键 | ⬜ | `BoolContainerProperties` |
| `TSet<bool>` 元素 | ⬜ | `BoolContainerProperties` |
| 复制 `Replicated` | ⬜ | — |
| 复制 `ReplicatedUsing` | ⬜ | — |
| Bitfield / `meta=(Bitmask)` | 🚫 | — |

> bool 作为哈希键是合法的（只有两个值），可用于 `TMap<bool, *>` 和 `TSet<bool>`。
> UE 原生支持 bitfield bool（`uint8 bFlag:1`），但 AS 绑定不暴露 bitfield 语法，标 🚫。

---

## 子矩阵 4：UPROPERTY 说明符 × bool（细化）

> 基线：每个 UPROPERTY 默认 `EditAnywhere` + `BlueprintReadWrite`。
> bool 特有关注：`meta=(InlineEditConditionToggle)` / `meta=(EditCondition=...)` 的条件绑定。

| 说明符 / meta | 期望结果 | 状态 | 覆盖方法 |
|------|------|:---:|------|
| `EditAnywhere` | `CPF_Edit`，不禁 instance/template | ⬜ | `BoolPropertySpecifierFlags` |
| `EditDefaultsOnly` | `CPF_Edit` + `CPF_DisableEditOnInstance` | ⬜ | 同上 |
| `EditInstanceOnly` | `CPF_Edit` + `CPF_DisableEditOnTemplate` | ⬜ | 同上 |
| `NotEditable` | 清除 `CPF_Edit` | ⬜ | 同上 |
| `EditConst` | `CPF_Edit` + `CPF_EditConst` | ⬜ | 同上 |
| `VisibleAnywhere` | `CPF_Edit` + `CPF_EditConst`（fork 语义） | ⬜ | 同上 |
| `BlueprintReadWrite` | `CPF_BlueprintVisible`，非只读 | ⬜ | 同上 |
| `BlueprintReadOnly` | `CPF_BlueprintVisible` + `CPF_BlueprintReadOnly` | ⬜ | 同上 |
| `Transient` | `CPF_Transient` | ⬜ | 同上 |
| `Config` | `CPF_Config` | ⬜ | 同上 |
| `SaveGame` | `CPF_SaveGame` | ⬜ | 同上 |
| `meta=(InlineEditConditionToggle)` | meta 回读（WITH_EDITOR） | ⬜ | 同上 |
| `meta=(EditCondition="bOtherBool")` | meta 回读 | ⬜ | 同上 |
| `meta=(DisplayName="Enable Feature")` | meta 回读 | ⬜ | 同上 |
| `Category="..."` | meta `Category` | ⬜ | 同上 |
| 组合 `EditAnywhere+BlueprintReadOnly` | `CPF_Edit`+`BlueprintVisible`+`BlueprintReadOnly` | ⬜ | 同上 |

> bool 最常用场景：作为 `EditCondition` 的条件变量（搭配 `InlineEditConditionToggle`）。

---

## 子矩阵 5：容器形态 × bool（细化）

| 容器形态 | 状态 | 覆盖方法 | 备注 |
|------|:---:|------|------|
| `TArray<bool>` | ⬜ | `BoolContainerProperties` | 长度 + 索引读 |
| `TMap<bool, int>` | ⬜ | 同上 | bool 作键（合法） |
| `TMap<int, bool>` | ⬜ | 同上 | bool 作值 |
| `TMap<FString, bool>` | ⬜ | 同上 | bool 作值 |
| `TSet<bool>` | ⬜ | 同上 | 只有两个元素：{false} / {true} / {} |
| `TArray<TArray<bool>>` 嵌套 | ⬜ | — | 路径解析器有限制 |

> `TSet<bool>` 合法但实用价值低（最多两个元素）。

---

## 子矩阵 6：函数用法 × bool

> 覆盖归属：`AngelscriptCoverageBoolFunctionTests.cpp`（计划）。
> 全局自由函数走 `FASGlobalFunctionInvoker`（Pattern B）；UFUNCTION 走 `FFunctionInvoker`（Pattern C）。

| 函数用法 | 写法示例 | `bool` | 覆盖方法 |
|------|------|:---:|------|
| 参数（值传递） | `void F(bool B)` | ✅ | `FunctionParametersValue` |
| 参数 `&in` | `void F(bool&in B)` | ✅ | `FunctionParametersIn` |
| 参数 `&out` | `void F(bool&out B)` | ✅ | `FunctionParametersOut` |
| 参数 `&inout` | `void F(bool&inout B)` | ✅ | `FunctionParametersInOut` |
| 返回值 | `bool F()` | ⬜ | `FunctionReturnValues` |
| 默认参数 | `void F(bool B = true)` | ⬜ | `FunctionDefaultParameters` |
| 多返回（`&out`） | `void F(bool&out A, bool&out B)` | ⬜ | `FunctionParametersOut` |
| 重载（bool 参数） | `F(bool)` vs `F(int)` | ⬜ | `FunctionOverloading` |
| UFUNCTION 参数/返回 | `UFUNCTION() bool F(bool)` | ⬜ | `UFunctionParametersAndReturn` |

---

## 子矩阵 7：运算符 × bool

> 覆盖归属：`AngelscriptCoverageBoolExpressionTests.cpp`（计划）。

| 运算符组 | 符号 | `bool` | 备注 |
|------|------|:---:|------|
| 逻辑与 | `&&` | ⬜ | 短路求值 |
| 逻辑或 | `\|\|` | ⬜ | 短路求值 |
| 逻辑非 | `!` | ⬜ | 一元运算 |
| 比较 | `== !=` | ⬜ | |
| 比较 | `< <= > >=` | 🚫 | bool 无序比较 |
| 算术 | `+ - * /` | 🚫 | bool 无算术 |
| 位运算 | `& \| ^` | ⬜ | bool 位运算等价逻辑运算（但非短路） |
| 位取反 | `~` | 🚫 | 用 `!` 代替 |
| 复合赋值 | `&&= \|\|=` | 🚫 | AS 不支持（C++17 特性） |
| 复合赋值 | `&= \|= ^=` | ⬜ | 位运算复合赋值 |
| 自增减 | `++ --` | 🚫 | bool 无自增减 |
| 三元 | `B ? A : C` | ⬜ | bool 作条件 |

> bool 支持位运算 `& | ^`（非短路），但通常用逻辑运算 `&& || !`（短路）。
> bool 无 `< <= > >=` 序比较、无算术、无自增减。

---

## 子矩阵 8：字面量形式

> 覆盖归属：`AngelscriptCoverageBoolExpressionTests.cpp`（计划）。

| 字面量形式 | 写法示例 | 状态 | 备注 |
|------|------|:---:|------|
| `true` | `bool B = true;` | ⬜ | |
| `false` | `bool B = false;` | ⬜ | |
| 大小写 | `True` / `TRUE` / `False` / `FALSE` | 🚫 | AS 只识别小写 `true`/`false` |

---

## 子矩阵 9：类型转换

> 覆盖归属：`AngelscriptCoverageBoolExpressionTests.cpp`（计划）。

| 转换 | 写法示例 | 状态 | 备注 |
|------|------|:---:|------|
| 整型→bool | `bool B = int(1);` / `if (X) ...` | ⬜ | 0→false, 非0→true |
| bool→整型 | `int I = int(B);` | ⬜ | false→0, true→1 |
| 浮点→bool | `bool B = (F != 0.0f);` | ⬜ | 显式比较 |
| bool→浮点 | `float F = float(B);` | ⬜ | false→0.0, true→1.0 |
| 指针/handle→bool | `if (Obj) ...` / `if (Obj != nullptr)` | ⬜ | null→false, 非null→true |
| bool→字符串 | `FString S = B ? "true" : "false";` | ⬜ | 无隐式转换，需手动 |

> AS 允许整型隐式转 bool（条件表达式），但 bool→整型需显式 `int()`。

---

## 子矩阵 10：bool 特有用法

> bool 类型特有场景：条件表达式 / 短路求值 / EditCondition。

| 特有用法 | 写法示例 | 状态 | 备注 |
|------|------|:---:|------|
| `if` 条件 | `if (B) { ... }` | ⬜ | |
| `while` / `do-while` 条件 | `while (B) { ... }` | ⬜ | |
| `for` 条件 | `for (int I=0; B; I++)` | ⬜ | |
| 三元条件 | `X = B ? A : C;` | ⬜ | |
| 短路求值 `&&` | `B1 && F()` — F() 不调用 if B1=false | ⬜ | |
| 短路求值 `\|\|` | `B1 \|\| F()` — F() 不调用 if B1=true | ⬜ | |
| `EditCondition` meta | `UPROPERTY(meta=(EditCondition="bEnable"))` | ⬜ | 控制其它属性可编辑性 |
| `InlineEditConditionToggle` meta | `UPROPERTY(meta=(InlineEditConditionToggle))` | ⬜ | 显示为复选框 |
| 函数返回 bool 作条件 | `if (IsValid()) { ... }` | ⬜ | |
| 布尔数组的模式匹配 | `TArray<bool> Flags;` 位模式 | ⬜ | |

---

## 计划 `TEST_METHOD` 清单（待实现）

### `AngelscriptCoverageBoolPropertyTests.cpp`（Pattern D）

| 方法 | 断言要点 |
|------|------|
| `BoolDeclarationDefaults` | bool 声明默认值（true / false）经 `FBoolProperty` 读回 |
| `BoolWriteRoundTrip` | `SetByPath` 写入 + 读回（true / false） |
| `BoolContainerProperties` | `TArray<bool>` + `TMap<bool,int>` / `TMap<int,bool>` / `TSet<bool>` |
| `BoolPropertySpecifierFlags` | Edit/Visible/Blueprint 访问 + `InlineEditConditionToggle/EditCondition/DisplayName/Category` → `CPF_*` 与 meta |

### `AngelscriptCoverageBoolExpressionTests.cpp`（Pattern B/F）

| 方法 | 断言要点 |
|------|------|
| `LocalDeclarations` | 局部默认/延迟初始化、局部 `const`、`auto` |
| `GlobalConstDeclarations` | bool **全局 `const`** |
| `LogicalOperators` | `&& \|\| !` + 短路求值验证 |
| `BitwiseOperators` | `& \| ^`（非短路）+ `&= \|= ^=` |
| `ComparisonOperators` | `== !=` |
| `BoolLiterals` | `true` / `false` |
| `BoolConversions` | int↔bool / float↔bool / handle↔bool |
| `BoolInControlFlow` | `if` / `while` / `for` / 三元条件 |
| `ShortCircuitEvaluation` | `&&` / `\|\|` 短路行为（副作用验证） |

### `AngelscriptCoverageBoolFunctionTests.cpp`（Pattern B/C）

| 方法 | 断言要点 |
|------|------|
| `FunctionParametersValue` | bool 值传递参数 |
| `FunctionParametersIn` | `&in` 参数 |
| `FunctionParametersOut` | `&out` 参数 + 多返回值 |
| `FunctionParametersInOut` | `&inout` 参数 |
| `FunctionReturnValues` | bool 返回值 |
| `FunctionDefaultParameters` | 默认参数（`true` / `false`） |
| `FunctionOverloading` | 按类型重载（bool vs int） |
| `UFunctionParametersAndReturn` | UFUNCTION 参数/返回 + `&out` |

---

## 待补清单（= 各矩阵中的 ⬜，按优先级）

### A. 核心属性用法（`BoolPropertyTests.cpp`）
1. 声明默认值 + 写回环。
2. 说明符完整排列（Edit/Visible/Blueprint + InlineEditConditionToggle/EditCondition）。
3. 容器（`TArray<bool>` / `TMap` / `TSet`）。

### B. 表达式与运算（`BoolExpressionTests.cpp`）
4. 局部/全局 const 声明。
5. 逻辑运算符（`&& || !`）+ 短路求值验证。
6. 位运算（`& | ^` + 复合赋值）。
7. 比较运算符（`== !=`）。
8. 字面量（`true` / `false`）。
9. 类型转换（int↔bool / float↔bool / handle↔bool）。
10. 控制流（`if` / `while` / `for` / 三元）。

### C. 函数用法（`BoolFunctionTests.cpp`）
11. 参数（值 / `&in` / `&out` / `&inout`）、返回、默认参数、重载。

---

## 与 int/float 样板的差异点

| 差异维度 | int | float | bool | 说明 |
|------|-----|-------|------|------|
| 值域 | 2^n 个值 | 连续域 + 特殊值 | 2 个值（true / false） | bool 最简单 |
| 算术运算 | `+ - * / %` 等 | `+ - * /`（无 `%`） | 🚫 无 | |
| 位运算 | `& \| ^ ~ << >>` | 🚫 无 | `& \| ^`（等价逻辑，非短路） | |
| 逻辑运算 | 🚫 无 | 🚫 无 | `&& \|\| !`（短路） | bool 专属 |
| 序比较 | `< <= > >=` | `< <= > >=` | 🚫 无 | bool 只有 `== !=` |
| 自增减 | `++ --` | `++ --` | 🚫 无 | |
| 哈希/相等 | 稳定 | 不稳定 | 稳定 | bool 可作 TMap 键和 TSet 元素 |
| 字面量 | 十/十六/二/八进制 | 十进制 / 科学计数 + `f` 后缀 | `true` / `false` | |
| 特殊值 | 无 | NaN / Inf | 无 | |
| 隐式转条件 | 0/非0 | 0.0/非0.0 | 直接 | |
| 特有 meta | Clamp/UI | Clamp/UI/Units | InlineEditConditionToggle | |
| 短路求值 | n/a | n/a | `&&` / `\|\|` | bool 核心特性 |

---

## 如何把本矩阵复用到其它类型

1. 复制本文件为 `Coverage_<Type>.md`。
2. 改「子矩阵 1」为该类型族的 `FProperty` 映射（权威来源 `Bind_*.cpp`）。
3. 改各子矩阵列头为该类型族成员；删掉不适用轴（如本文删除算术/序比较/自增减，添加逻辑运算/短路求值）。
4. 添加类型特有子矩阵（如本文的「子矩阵 10：bool 特有用法」）。
5. 新建对应 `AngelscriptCoverage<Type>PropertyTests.cpp`，方法命名沿用 `<Type>...` 结构。
