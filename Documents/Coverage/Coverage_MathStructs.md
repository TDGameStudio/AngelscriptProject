# AngelScript 数学结构全覆盖矩阵

> 本文覆盖 AngelScript 中 **UE 内建数学结构**的所有用法。
> 包括 FVector、FRotator、FTransform、FQuat 等游戏开发核心类型。

## 对应测试文件

| 用法分组 | 测试文件 | 状态 |
|---------|---------|------|
| FVector (Property/Expression/Function) | `AngelscriptTest/Coverage/AngelscriptCoverageFVectorPropertyTests.cpp` + Expression + Function | ✅ 已完成 |
| FRotator (Property/Expression/Function) | `AngelscriptTest/Coverage/AngelscriptCoverageFRotatorPropertyTests.cpp` + Expression + Function | ✅ 已完成 |
| FTransform (Property/Expression/Function) | `AngelscriptTest/Coverage/AngelscriptCoverageFTransformPropertyTests.cpp` + Expression + Function | ✅ 已完成 |
| FQuat (Property/Expression/Function) | `AngelscriptTest/Coverage/AngelscriptCoverageFQuatPropertyTests.cpp` + Expression + Function | ✅ 已完成 |
| FVector2D (Property/Expression/Function) | `AngelscriptTest/Coverage/AngelscriptCoverageFVector2DPropertyTests.cpp` + Expression + Function | ✅ 已完成 |
| FLinearColor (Property/Expression/Function) | `AngelscriptTest/Coverage/AngelscriptCoverageFLinearColorPropertyTests.cpp` + Expression + Function | ✅ 已完成 |

✅ 所有主要数学结构类型已全面覆盖（Property/Expression/Function 三个维度）

## 图例

- `✅ 已覆盖` ｜ `🟡 部分覆盖` ｜ `⬜ 待写` ｜ `🚫 不适用/不支持`

---

## 子矩阵 1：Vector 家族

### 1.1 Vector 类型清单

| 类型 | 维度 | 元素类型 | 状态 | 典型用途 |
|------|------|---------|------|---------|
| `FVector` | 3D | float | ✅ | 位置、方向、速度 |
| `FVector2D` | 2D | float | ✅ | UI 坐标、2D 位置 |
| `FVector4` | 4D | float | ⬜ | 颜色（带 alpha）、齐次坐标 |
| `FIntPoint` | 2D | int32 | ⬜ | 整数坐标（纹理、屏幕） |
| `FIntVector` | 3D | int32 | ⬜ | 体素坐标、网格索引 |

### 1.2 FVector 构造和访问

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 默认构造 | `FVector V;` | ✅ | (0, 0, 0) |
| 三参数构造 | `FVector V(1.0f, 2.0f, 3.0f);` | ✅ | |
| 单参数构造 | `FVector V(5.0f);` | ✅ | (5, 5, 5) |
| 成员访问 | `V.X` / `V.Y` / `V.Z` | ✅ | |
| 索引访问 | `V[0]` / `V[1]` / `V[2]` | ✅ | |
| 预定义常量 | `FVector::ZeroVector` / `UpVector` / `ForwardVector` | ✅ | |

### 1.3 FVector 运算符

| 运算符 | 写法 | 状态 | 说明 |
|-------|------|------|------|
| 加法 | `V1 + V2` | ✅ | 分量相加 |
| 减法 | `V1 - V2` | ✅ | 分量相减 |
| 标量乘法 | `V * 2.0f` / `2.0f * V` | ✅ | 缩放 |
| 标量除法 | `V / 2.0f` | ✅ | |
| 点乘 | `V1 \| V2` 或 `FVector::DotProduct(V1, V2)` | ✅ | 返回 float |
| 叉乘 | `V1 ^ V2` 或 `FVector::CrossProduct(V1, V2)` | ✅ | 返回 FVector |
| 一元负 | `-V` | ✅ | 取反 |
| 复合赋值 | `+=` / `-=` / `*=` / `/=` | ✅ | |
| 比较 | `==` / `!=` | ✅ | 精度比较 |

### 1.4 FVector 方法

| 方法分组 | 方法名 | 状态 | 说明 |
|---------|--------|------|------|
| 长度 | `Size()` / `SizeSquared()` / `Size2D()` | ⬜ | 向量长度 |
| 归一化 | `Normalize()` / `GetSafeNormal()` / `IsNormalized()` | ⬜ | 单位向量 |
| 距离 | `Distance(V1, V2)` / `DistSquared()` / `Dist2D()` | ⬜ | 两点距离 |
| 插值 | `Lerp(A, B, Alpha)` / `Slerp(A, B, Alpha)` | ⬜ | 线性/球面插值 |
| 限制 | `ClampSize(Min, Max)` / `GetClampedToSize(...)` | ⬜ | 限制长度 |
| 投影 | `ProjectOnTo(V)` / `ProjectOnToNormal(V)` | ⬜ | 投影到向量 |
| 分量 | `GetComponentForAxis(EAxis)` / `SetComponentForAxis(...)` | ⬜ | 按轴访问 |
| 旋转 | `RotateAngleAxis(Angle, Axis)` | ⬜ | 绕轴旋转 |
| 判断 | `IsNearlyZero()` / `IsZero()` / `IsUnit()` | ⬜ | 状态检查 |
| 转换 | `ToRotator()` / `Rotation()` | ⬜ | 转为 Rotator |

---

## 子矩阵 2：FRotator（欧拉角）

### 2.1 FRotator 构造和访问

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 默认构造 | `FRotator R;` | ✅ | (0, 0, 0) |
| 三参数构造 | `FRotator R(Pitch, Yaw, Roll);` | ✅ | 角度（度） |
| 成员访问 | `R.Pitch` / `R.Yaw` / `R.Roll` | ✅ | |
| 预定义常量 | `FRotator::ZeroRotator` | ✅ | |

### 2.2 FRotator 运算符和方法

| 运算符/方法 | 写法 | 状态 | 说明 |
|-----------|------|------|------|
| 加法/减法 | `R1 + R2` / `R1 - R2` | ✅ | 旋转叠加 |
| 标量乘法 | `R * 2.0f` | ✅ | 缩放角度 |
| 一元负 | `-R` | ✅ | 反向旋转 |
| 比较 | `==` / `!=` / `Equals(R, Tolerance)` | ✅ | |
| 归一化 | `Normalize()` / `GetNormalized()` | ✅ | 角度归一化到 [-180, 180] |
| 限制 | `Clamp()` / `GetClamped()` | ✅ | |
| 转换 | `Vector()` / `Euler()` / `Quaternion()` | ✅ | 转为方向向量/FQuat |
| 旋转向量 | `RotateVector(V)` / `UnrotateVector(V)` | ✅ | 应用旋转 |
| 插值 | `Lerp(A, B, Alpha)` | ✅ | 线性插值 |

---

## 子矩阵 3：FQuat（四元数）

### 3.1 FQuat 构造和访问

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 默认构造 | `FQuat Q;` | ✅ | 单位四元数 |
| 四参数构造 | `FQuat Q(X, Y, Z, W);` | ✅ | |
| 从 Rotator | `FQuat Q(Rotator);` | ✅ | |
| 从轴角 | `FQuat(Axis, AngleRad);` | ✅ | |
| 成员访问 | `Q.X` / `Q.Y` / `Q.Z` / `Q.W` | ✅ | |
| 预定义常量 | `FQuat::Identity` | ✅ | |

### 3.2 FQuat 运算符和方法

| 运算符/方法 | 写法 | 状态 | 说明 |
|-----------|------|------|------|
| 乘法 | `Q1 * Q2` | ✅ | 旋转组合 |
| 旋转向量 | `Q.RotateVector(V)` / `Q * V` | ✅ | |
| 逆 | `Q.Inverse()` | ✅ | 反向旋转 |
| 归一化 | `Q.Normalize()` / `Q.GetNormalized()` | ✅ | |
| 插值 | `Slerp(Q1, Q2, Alpha)` / `FastLerp(...)` | ✅ | 球面线性插值 |
| 转换 | `Rotator()` / `Euler()` / `GetAxisX/Y/Z()` | ✅ | 转为 FRotator/轴 |
| 判断 | `IsIdentity()` / `IsNormalized()` | ✅ | |

---

## 子矩阵 4：FTransform（变换）

### 4.1 FTransform 构造和访问

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 默认构造 | `FTransform T;` | ⬜ | 单位变换 |
| 完整构造 | `FTransform T(Rotation, Location, Scale);` | ⬜ | |
| 仅位置 | `FTransform T(Location);` | ⬜ | |
| 成员访问 | `T.Location` / `T.Rotation` / `T.Scale3D` | ⬜ | FVector/FQuat/FVector |
| 预定义常量 | `FTransform::Identity` | ⬜ | |

### 4.2 FTransform 运算符和方法

| 运算符/方法 | 写法 | 状态 | 说明 |
|-----------|------|------|------|
| 组合 | `T1 * T2` | ⬜ | 变换组合（先 T2 后 T1） |
| 变换点 | `T.TransformPosition(V)` | ⬜ | 应用变换到点 |
| 变换向量 | `T.TransformVector(V)` | ⬜ | 仅旋转和缩放 |
| 逆变换 | `T.Inverse()` / `T.InverseTransformPosition(V)` | ⬜ | |
| 插值 | `Lerp(A, B, Alpha)` / `LerpTranslationScale3D(...)` | ⬜ | |
| 混合 | `Blend(T1, T2, Weight)` | ⬜ | 加权混合 |
| 转换 | `ToMatrixWithScale()` / `ToMatrixNoScale()` | ⬜ | 转为矩阵 |
| 判断 | `Equals(T, Tolerance)` / `EqualsNoScale(T)` | ⬜ | |

---

## 子矩阵 5：FLinearColor 和 FColor

### 5.1 FLinearColor（线性空间颜色）

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 构造 | `FLinearColor C(R, G, B, A);` | ⬜ | 值域 [0, 1] |
| 成员访问 | `C.R` / `C.G` / `C.B` / `C.A` | ⬜ | |
| 预定义颜色 | `FLinearColor::White` / `Red` / `Black` 等 | ⬜ | |
| 运算符 | `+` / `-` / `*` / `/` | ⬜ | 分量运算 |
| 方法 | `ToFColor(bool sRGB)` / `Desaturate(float)` | ⬜ | |

### 5.2 FColor（8 位颜色）

| 特性 | 写法 | 状态 | 说明 |
|------|------|------|------|
| 构造 | `FColor C(R, G, B, A);` | ⬜ | 值域 [0, 255] |
| 成员访问 | `C.R` / `C.G` / `C.B` / `C.A` | ⬜ | uint8 |
| 预定义颜色 | `FColor::White` / `Red` / `Black` 等 | ⬜ | |
| 转换 | `ReinterpretAsLinear()` | ⬜ | 转为 FLinearColor |

---

## 子矩阵 6：其他数学结构

### 6.1 FMatrix（4x4 矩阵）

| 特性 | 状态 | 说明 |
|------|------|------|
| 构造 | ⬜ | 单位矩阵 / 从 Transform |
| 运算 | ⬜ | 矩阵乘法 / 逆 / 转置 |
| 变换 | ⬜ | TransformPosition / TransformVector |

### 6.2 FBox（AABB 包围盒）

| 特性 | 状态 | 说明 |
|------|------|------|
| 构造 | ⬜ | Min/Max / 点数组 |
| 操作 | ⬜ | IsInside / ExpandBy / GetCenter / GetExtent |

### 6.3 FBox2D（2D 包围盒）

| 特性 | 状态 | 说明 |
|------|------|------|
| 构造 | ⬜ | Min/Max |
| 操作 | ⬜ | IsInside / Intersect |

### 6.4 FPlane（平面）

| 特性 | 状态 | 说明 |
|------|------|------|
| 构造 | ⬜ | 三点 / 法线+距离 |
| 操作 | ⬜ | PlaneDot / Normalize |

---

## 子矩阵 7：数学结构的用法场景

### 7.1 作为类型使用

| 用法 | 状态 | 验证点 |
|------|------|--------|
| 局部变量 | ⬜ | `FVector V;` |
| UPROPERTY 成员 | ⬜ | `UPROPERTY() FVector Location;` |
| 函数参数（值） | ⬜ | `void F(FVector V)` |
| 函数参数（引用） | ⬜ | `void F(const FVector&in V)` |
| 函数返回值 | ⬜ | `FVector GetLocation()` |
| 容器元素 | ⬜ | `TArray<FVector>` |
| Map 值 | ⬜ | `TMap<int, FVector>` |

### 7.2 配合 UPROPERTY meta

| meta 键 | 写法 | 状态 | 说明 |
|---------|------|------|------|
| MakeEditWidget | `UPROPERTY(meta=(MakeEditWidget)) FVector Point;` | ⬜ | 3D 编辑器控件 |
| ClampMin/ClampMax | `UPROPERTY(meta=(ClampMin="0")) FVector V;` | ⬜ | 限制范围 |

---

## 子矩阵 8：Math 命名空间函数

### 8.1 通用数学函数

| 函数分组 | 函数名 | 状态 | 说明 |
|---------|--------|------|------|
| 三角函数 | `Sin/Cos/Tan/Asin/Acos/Atan/Atan2` | ⬜ | 弧度制 |
| 幂和根 | `Pow/Sqrt/Exp/Log/Log2` | ⬜ | |
| 取整 | `Floor/Ceil/Round/Trunc` | ⬜ | |
| 绝对值 | `Abs/Sign` | ⬜ | |
| 最值 | `Min/Max/Clamp` | ⬜ | |
| 插值 | `Lerp/Smoothstep/InterpEaseIn/Out` | ⬜ | |
| 随机 | `FRand/RandRange/RandBool` | ⬜ | |

### 8.2 Vector 特化函数

| 函数 | 状态 | 说明 |
|------|------|------|
| `Math::VectorLength(V)` | ⬜ | 向量长度 |
| `Math::DotProduct(V1, V2)` | ⬜ | 点乘 |
| `Math::CrossProduct(V1, V2)` | ⬜ | 叉乘 |
| `Math::VectorNormalize(V)` | ⬜ | 归一化 |

---

## 计划测试方法清单

### AngelscriptCoverageVectorTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `VectorConstruction` | 默认/参数构造、预定义常量 |
| `VectorAccess` | 成员访问 X/Y/Z、索引访问 |
| `VectorArithmetic` | +/-/*//、一元负 |
| `VectorProducts` | 点乘、叉乘 |
| `VectorMethods` | Size/Normalize/Distance/Lerp/Project |
| `VectorComparison` | ==/!=/IsNearlyZero |
| `Vector2DAndVector4` | FVector2D/FVector4 基础 |
| `IntVectors` | FIntPoint/FIntVector |

### AngelscriptCoverageRotationTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `RotatorConstruction` | Pitch/Yaw/Roll 构造 |
| `RotatorOperations` | +/-/*、归一化、限制 |
| `RotatorConversion` | Vector/Quaternion/Euler 转换 |
| `RotatorRotateVector` | 旋转向量 |
| `QuatConstruction` | 各种构造方式 |
| `QuatOperations` | *、Inverse、归一化 |
| `QuatSlerp` | 球面插值 |
| `QuatRotateVector` | 旋转向量 |

### AngelscriptCoverageTransformTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `TransformConstruction` | Location/Rotation/Scale 构造 |
| `TransformComposition` | 变换组合 * |
| `TransformPoint` | TransformPosition/Vector |
| `TransformInverse` | 逆变换 |
| `TransformInterpolation` | Lerp/Blend |
| `TransformConversion` | ToMatrix |

### AngelscriptCoverageMathMiscTests.cpp

| 方法 | 覆盖内容 |
|------|---------|
| `LinearColorOperations` | 构造/运算/转换 |
| `FColorOperations` | 构造/转换 |
| `BoxOperations` | FBox/FBox2D |
| `MathFunctions` | Math:: 命名空间函数 |

---

## 待补充清单（按优先级）

### 🔴 高优先级

1. **FVector 核心**（构造/运算/方法）
2. **FRotator 和 FQuat**（旋转表示和转换）
3. **FTransform**（完整变换）

### 🟡 中优先级

4. **FLinearColor 和 FColor**
5. **Vector2D/Vector4/IntVector**
6. **Math 命名空间函数**

### 🟢 低优先级

7. **FMatrix/FBox/FPlane**（高级数学结构）

---

## 总结

数学结构是游戏开发的**绝对核心**，几乎所有游戏逻辑都会用到：
- 位置、速度、加速度 → FVector
- 角色朝向、相机旋转 → FRotator/FQuat
- 物体变换、父子关系 → FTransform
- UI 颜色、材质参数 → FLinearColor

**估计工作量**：4 个测试文件，约 30-40 个测试方法
**优先级**：🔴🔴🔴 极高（应在 UCLASS 之前或同时进行）





