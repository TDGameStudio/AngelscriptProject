# AngelScript `FVector` 全覆盖矩阵

> 本文是「按类型」的细粒度全覆盖矩阵，覆盖**FVector 在 AngelScript 中的所有用法**：
> 声明 / 全局 / 局部 / UPROPERTY / 函数参数 / 返回值 / 运算符 / 构造 / 方法 / 转换 / 容器 等。
> 基于已有样板，简化为 FVector 特性。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|------|------|:---:|
| UPROPERTY 属性用法 | `AngelscriptTest/Coverage/AngelscriptCoverageFVectorPropertyTests.cpp` | 待建 |
| 声明 / 运算符 / 构造 / 方法 | `AngelscriptTest/Coverage/AngelscriptCoverageFVectorExpressionTests.cpp` | 待建 |
| 函数参数 / 返回 / 默认参数 | `AngelscriptTest/Coverage/AngelscriptCoverageFVectorFunctionTests.cpp` | 待建 |

- Automation 前缀：`Angelscript.TestModule.Coverage.FVector*`
- 运行命令：`Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FVector" -Label coverage-fvector -TimeoutMs 1200000`

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：FVector 类型 → UE `FProperty` 映射（权威）

> 权威来源：`Plugins/Angelscript/Source/AngelscriptRuntime/Binds/Bind_FVector.cpp`

| AS 类型 | C++ NativeType | UE `FProperty` | 大小 | 用途 |
|------|------|------|:---:|------|
| `FVector` | `FVector` (double) | `FStructProperty` | 24 bytes | 3D 向量（UE5，double精度）|
| `FVector3f` | `FVector3f` (float) | `FStructProperty` | 12 bytes | 3D 向量（float精度）|
| `FVector2D` | `FVector2D` (double) | `FStructProperty` | 16 bytes | 2D 向量 |
| `FVector4` | `FVector4` (double) | `FStructProperty` | 32 bytes | 4D 向量 |

> UE5 中 FVector 默认使用 double 精度。

---

## 子矩阵 2：声明上下文 × FVector

| 声明上下文 | 写法示例 | `FVector` | 备注 |
|------|------|:---:|------|
| 局部变量（无默认值） | `FVector V;` | ⬜ | 默认 (0,0,0) |
| 局部变量（默认值） | `FVector V = FVector(1,2,3);` | ⬜ | |
| 局部 `const` | `const FVector V = FVector(1,0,0);` | ⬜ | |
| 全局 `const` | `const FVector G = FVector::ZeroVector;` | ⬜ | |
| 全局可变 | `FVector G = FVector::ZeroVector;` | 🚫 | 本 fork 禁止 |
| 类成员（无 UPROPERTY） | `FVector V;` | ⬜ | |
| 类成员 `UPROPERTY()` | `UPROPERTY() FVector V;` | ⬜ | |

---

## 子矩阵 3：UPROPERTY 属性用法 × FVector

> 覆盖归属：`AngelscriptCoverageFVectorPropertyTests.cpp`。

| 属性用法 | `FVector` | 覆盖方法 |
|------|:---:|------|
| 声明默认值读回 | ⬜ | — |
| 写回环（C++→属性→C++） | ⬜ | — |
| 零向量 | ⬜ | — |
| 单位向量 | ⬜ | — |
| 负值向量 | ⬜ | — |
| 大值向量 | ⬜ | — |
| `UPROPERTY` + 说明符 | ⬜ | — |
| `TArray<FVector>` | ⬜ | — |
| `TMap<*, FVector>` 值 | ⬜ | — |
| `TSet<FVector>` | ⬜ | 可能需要 Hash |

---

## 子矩阵 4：构造函数

> 覆盖归属：`AngelscriptCoverageFVectorExpressionTests.cpp`。

| 构造方式 | 语法 | 状态 | 备注 |
|------|------|:---:|------|
| 默认构造 | `FVector()` | ⬜ | (0,0,0) |
| 三参数构造 | `FVector(1, 2, 3)` | ⬜ | (x,y,z) |
| 单值构造 | `FVector(5)` | ⬜ | (5,5,5) |
| 常量向量 | `FVector::ZeroVector` | ⬜ | (0,0,0) |
| 常量向量 | `FVector::OneVector` | ⬜ | (1,1,1) |
| 常量向量 | `FVector::UpVector` | ⬜ | (0,0,1) |
| 常量向量 | `FVector::ForwardVector` | ⬜ | (1,0,0) |
| 常量向量 | `FVector::RightVector` | ⬜ | (0,1,0) |

---

## 子矩阵 5：运算符 × FVector

> 覆盖归属：`AngelscriptCoverageFVectorExpressionTests.cpp`。

| 运算符组 | 符号 | `FVector` | 结果类型 | 备注 |
|------|------|:---:|:------:|------|
| 加法 | `+` | ⬜ | FVector | 向量加法 |
| 减法 | `-` | ⬜ | FVector | 向量减法 |
| 标量乘法 | `*` | ⬜ | FVector | v * scalar |
| 标量除法 | `/` | ⬜ | FVector | v / scalar |
| 向量点乘 | `\|` | ⬜ | double | Dot product |
| 向量叉乘 | `^` | ⬜ | FVector | Cross product |
| 负号 | `-v` | ⬜ | FVector | 取反 |
| 复合赋值 | `+=, -=, *=, /=` | ⬜ | FVector& | |
| 相等 | `==` | ⬜ | bool | |
| 不等 | `!=` | ⬜ | bool | |

---

## 子矩阵 6：FVector 方法（重要）

> 覆盖归属：`AngelscriptCoverageFVectorExpressionTests.cpp`。

| 方法组 | 方法 | 状态 | 备注 |
|--------|------|:----:|------|
| **访问** | `X`, `Y`, `Z` | ⬜ | 成员访问 |
| **长度** | `Length()`, `SquaredLength()` | ⬜ | 向量长度 |
| **归一化** | `GetNormalized()`, `Normalize()` | ⬜ | 单位向量 |
| **距离** | `Distance()`, `DistSquared()` | ⬜ | 两向量距离 |
| **点积** | `Dot()` | ⬜ | 点乘 |
| **叉积** | `Cross()` | ⬜ | 叉乘 |
| **判断** | `IsZero()`, `IsNearlyZero()` | ⬜ | 零判断 |
| **判断** | `IsUnit()` | ⬜ | 单位向量判断 |
| **投影** | `ProjectOnTo()`, `ProjectOnToNormal()` | ⬜ | 向量投影 |
| **插值** | `Lerp()` | ⬜ | 线性插值 |
| **钳制** | `ClampSize()`, `ClampMaxSize()` | ⬜ | 长度限制 |

---

## 子矩阵 7：函数用法 × FVector

> 覆盖归属：`AngelscriptCoverageFVectorFunctionTests.cpp`。

| 函数用法 | 写法示例 | `FVector` | 覆盖方法 |
|------|------|:---:|------|
| 参数（值传递） | `void F(FVector X)` | ⬜ | — |
| 参数 `&in` | `void F(FVector&in X)` | ⬜ | — |
| 参数 `&out` | `void F(FVector&out X)` | ⬜ | — |
| 参数 `&inout` | `void F(FVector&inout X)` | ⬜ | — |
| 返回值 | `FVector F()` | ⬜ | — |
| 默认参数 | `void F(FVector X = FVector::ZeroVector)` | ⬜ | — |
| UFUNCTION 参数/返回 | `UFUNCTION() FVector F(FVector)` | ⬜ | — |

---

## 子矩阵 8：容器 × FVector

> 覆盖归属：`AngelscriptCoverageFVectorPropertyTests.cpp`。

| 容器形态 | 状态 | 备注 |
|------|:---:|------|
| `TArray<FVector>` | ⬜ | 向量数组 |
| `TMap<int, FVector>` | ⬜ | FVector 作值 |
| `TSet<FVector>` | ⬜ | 需要 Hash（可能不支持）|

---

## FVector 特有注意事项

### 1. Double vs Float 精度
- ⚠️ UE5 中 FVector 使用 double 精度
- ✅ FVector3f 是 float 精度版本
- ✅ 测试精度差异

### 2. 常用常量向量
- ✅ ZeroVector (0,0,0)
- ✅ OneVector (1,1,1)
- ✅ UpVector (0,0,1)
- ✅ ForwardVector (1,0,0)
- ✅ RightVector (0,1,0)

### 3. 向量运算
- ✅ 点乘返回 double
- ✅ 叉乘返回 FVector
- ✅ 归一化会修改向量

### 4. 精度比较
- ⚠️ 浮点数相等比较需要容差
- ✅ 使用 `IsNearlyEqual()` 或 `Equals()`
- ✅ 不要直接用 `==`（但运算符支持）

---

## 待实现清单

### A. `AngelscriptCoverageFVectorPropertyTests.cpp`（新建）
1. FVector 声明默认值读回
2. 写回环测试（C++ ↔ FProperty）
3. 特殊值测试（零向量、单位向量、大值）
4. 容器测试（TArray<FVector>）

**估算时间：1小时**

### B. `AngelscriptCoverageFVectorExpressionTests.cpp`（新建）
1. 局部/全局声明
2. 构造函数（8种方式）
3. 运算符（+, -, *, /, |, ^）
4. 方法（Length, Normalize, Dot, Cross, 等）
5. 类成员（无 UPROPERTY）

**估算时间：2小时**

### C. `AngelscriptCoverageFVectorFunctionTests.cpp`（新建）
6. 函数参数（值/&in/&out/&inout）
7. 返回值
8. 默认参数
9. UFUNCTION 测试

**估算时间：1小时**

**总估算：4小时**

---

## 测试运行指令

```powershell
# 运行所有 FVector coverage 测试
Tools\RunTests.ps1 -TestPrefix "Angelscript.TestModule.Coverage.FVector" -Label coverage-fvector -TimeoutMs 1200000
```

---

## 预估工作量

| 任务 | 复杂度 | 估算时间 |
|------|:-----:|---------|
| FVectorPropertyTests | 中等 | 1小时 |
| FVectorExpressionTests | 复杂 | 2小时 |
| FVectorFunctionTests | 简单 | 1小时 |
| 文档更新 | 简单 | 已完成 |
| **总计** | | **约 4 小时** |

> FVector 比基础类型复杂，有丰富的方法和运算符。
