# UE Math Types Coverage 计划

> 基于 Angelscript 绑定的 UE 数学类型的完整覆盖测试计划

## 📋 UE 绑定的数学类型清单

### 核心向量类型
| 类型 | 绑定文件 | 维度 | 优先级 |
|------|---------|:----:|:-----:|
| `FVector` | Bind_FVector.cpp | 3D (X,Y,Z) | **P0** |
| `FVector2D` | Bind_FVector2D.cpp | 2D (X,Y) | **P0** |
| `FVector4` | Bind_FVector4.cpp | 4D (X,Y,Z,W) | P1 |
| `FIntVector` | Bind_FIntVector.cpp | 3D int | P1 |
| `FIntPoint` | Bind_FIntPoint.cpp | 2D int | P2 |

### 旋转与变换
| 类型 | 绑定文件 | 用途 | 优先级 |
|------|---------|------|:-----:|
| `FRotator` | Bind_FRotator.cpp | 欧拉角旋转 | **P0** |
| `FQuat` | Bind_FQuat.cpp | 四元数旋转 | **P0** |
| `FTransform` | Bind_FTransform.cpp | 位置+旋转+缩放 | **P0** |
| `FMatrix` | Bind_FMatrix.cpp | 4x4矩阵 | P1 |

### 几何与边界
| 类型 | 绑定文件 | 用途 | 优先级 |
|------|---------|------|:-----:|
| `FBox` | Bind_FBox.cpp | AABB 包围盒 | **P0** |
| `FBox2D` | Bind_FBox2D.cpp | 2D AABB | P1 |
| `FSphere` | Bind_FSphere.cpp | 包围球 | P1 |
| `FPlane` | Bind_FPlane.cpp | 平面方程 | P2 |
| `FBoxSphereBounds` | Bind_FBoxSphereBounds.cpp | 盒+球组合 | P2 |

### 颜色
| 类型 | 绑定文件 | 用途 | 优先级 |
|------|---------|------|:-----:|
| `FLinearColor` | Bind_FLinearColor.cpp | 线性颜色空间 | **P0** |
| `FColor` | Bind_FColor.cpp | RGBA (0-255) | P1 |

### 其他数学类型
| 类型 | 绑定文件 | 用途 | 优先级 |
|------|---------|------|:-----:|
| `FVector_NetQuantize` | Bind_FVector.cpp | 网络压缩向量 | P2 |
| `FVector_NetQuantize10` | Bind_FVector.cpp | 网络压缩 (10位) | P2 |
| `FVector_NetQuantize100` | Bind_FVector.cpp | 网络压缩 (100倍) | P2 |
| `FRandomStream` | Bind_FRandomStream.cpp | 随机数流 | P2 |

---

## 🎯 P0 优先级类型（立即实现）

### 1. FVector
**运算符覆盖：**
- ✅ `opAdd` - FVector + FVector
- ✅ `opSub` - FVector - FVector
- ✅ `opMul` - FVector * FVector（逐分量）
- ✅ `opMul` - FVector * float（标量）
- ✅ `opDiv` - FVector / FVector
- ✅ `opDiv` - FVector / float
- ✅ `opNeg` - -FVector
- ✅ `opMulAssign`, `opDivAssign`, `opAddAssign`, `opSubAssign`
- ✅ `opIndex` - FVector[0/1/2]
- ✅ `opEquals` - ==

**重要方法：**
- Size(), SizeSquared(), Length()
- Normalize(), GetSafeNormal()
- Dot(), Cross()
- Distance(), DistSquared()
- IsNearlyZero(), IsZero()

**常量：**
- ZeroVector, UpVector, ForwardVector, RightVector

### 2. FVector2D
**运算符覆盖：**
- `opAdd`, `opSub`, `opMul`, `opDiv`
- `opNeg`
- `opMulAssign`, `opDivAssign`, `opAddAssign`, `opSubAssign`
- `opEquals`

**重要方法：**
- Size(), SizeSquared()
- Normalize(), GetSafeNormal()
- Dot()

### 3. FRotator
**运算符覆盖：**
- `opAdd`, `opSub` - 欧拉角相加/相减
- `opEquals`

**重要方法：**
- Clamp(), Normalize()
- GetInverse()
- RotateVector(), UnrotateVector()
- Vector(), Quaternion()

### 4. FQuat
**运算符覆盖：**
- `opMul` - 四元数乘法（旋转组合）
- `opMulAssign`
- `opEquals`

**重要方法：**
- RotateVector()
- Inverse()
- GetAxisX(), GetAxisY(), GetAxisZ()
- Normalize()

### 5. FTransform
**运算符覆盖：**
- `opMul` - Transform * Transform（变换组合）
- `opEquals`

**重要方法：**
- TransformPosition(), TransformVector(), TransformRotation()
- InverseTransformPosition(), InverseTransformVector()
- GetLocation(), GetRotation(), GetScale3D()
- Inverse()

### 6. FBox
**运算符覆盖：**
- `opAdd` - Box + FVector（扩展）
- `opAddAssign`
- `opEquals`

**重要方法：**
- IsInside(), IsInsideXY()
- GetCenter(), GetExtent(), GetSize()
- ExpandBy(), ShiftBy()
- Overlaps(), Intersect()

### 7. FLinearColor
**运算符覆盖：**
- `opAdd`, `opSub`, `opMul`, `opDiv`
- `opMulAssign`, `opDivAssign`, `opAddAssign`, `opSubAssign`
- `opEquals`

**重要方法：**
- Clamp()
- ToFColor(), FromSRGBColor()
- Desaturate()

---

## 📊 测试文件结构（按 int/float 样板）

### FVector Coverage
```
AngelscriptCoverageFVectorPropertyTests.cpp
├── FVectorDeclarationDefaults
├── FVectorWriteRoundTrip
├── FVectorBoundaryValues
├── FVectorContainerProperties (TArray<FVector>, TMap<int, FVector>)
└── FVectorPropertySpecifierFlags

AngelscriptCoverageFVectorExpressionTests.cpp
├── LocalDeclarations
├── GlobalConstDeclarations
├── ArithmeticOperators (Vector+Vector, Vector*scalar, etc.)
├── ComparisonOperators (==)
├── CompoundAssignmentOperators (+=, -=, *=, /=)
├── IndexOperator ([0], [1], [2])
├── MixedTypeArithmetic (FVector * float, FVector * double)
└── ClassMembersNonProperty

AngelscriptCoverageFVectorFunctionTests.cpp
├── FunctionParametersValue
├── FunctionParametersIn
├── FunctionParametersOut
├── FunctionParametersInOut
├── FunctionReturnValues
├── FunctionDefaultParameters
└── UFunctionParametersAndReturn

AngelscriptCoverageFVectorMethodTests.cpp (新增)
├── SizeAndLength (Size(), SizeSquared(), Length())
├── Normalization (Normalize(), GetSafeNormal())
├── DotAndCross (Dot(), Cross())
├── Distance (Distance(), DistSquared())
├── Predicates (IsNearlyZero(), IsZero())
└── Constants (ZeroVector, UpVector, etc.)
```

---

## 🎯 测试矩阵（FVector 示例）

### 子矩阵 1：运算符 × 操作数类型

| 运算符 | FVector × FVector | FVector × float | FVector × double | 状态 |
|--------|:----------------:|:---------------:|:----------------:|:----:|
| `+` | ✅ | 🚫 | 🚫 | - |
| `-` | ✅ | 🚫 | 🚫 | - |
| `*` | ✅ (逐分量) | ✅ | ✅ | - |
| `/` | ✅ (逐分量) | ✅ | ✅ | - |
| `-` (一元) | ✅ | - | - | - |
| `==` | ✅ | - | - | - |
| `[]` | ✅ (索引0/1/2) | - | - | - |

### 子矩阵 2：复合赋值

| 运算符 | FVector | float | double | 状态 |
|--------|:-------:|:-----:|:------:|:----:|
| `+=` | ✅ | 🚫 | 🚫 | - |
| `-=` | ✅ | 🚫 | 🚫 | - |
| `*=` | ✅ | ✅ | ✅ | - |
| `/=` | ✅ | ✅ | ✅ | - |

### 子矩阵 3：方法测试

| 方法组 | 测试点 | 状态 |
|--------|--------|:----:|
| 长度计算 | Size(), SizeSquared(), Length() | ⬜ |
| 归一化 | Normalize(), GetSafeNormal(), IsUnit() | ⬜ |
| 点积/叉积 | Dot(), Cross() | ⬜ |
| 距离 | Distance(), DistSquared() | ⬜ |
| 谓词 | IsNearlyZero(), IsZero(), IsUnit() | ⬜ |
| 投影 | ProjectOnTo(), ProjectOnToNormal() | ⬜ |
| 常量 | ZeroVector, UpVector, ForwardVector, RightVector | ⬜ |

---

## 🚀 实施计划

### Phase 1: FVector（估算3小时）
1. ✅ 创建覆盖矩阵文档 `Coverage_FVectorProperty.md`
2. ⬜ 创建 PropertyTests（1小时）
3. ⬜ 创建 ExpressionTests（1小时）
4. ⬜ 创建 FunctionTests（30分钟）
5. ⬜ 创建 MethodTests（30分钟）- **新类别**

### Phase 2: FVector2D（估算2小时）
- 复用 FVector 结构，简化为2D

### Phase 3: FRotator（估算2.5小时）
- 旋转特有方法
- 欧拉角归一化/裁剪

### Phase 4: FQuat（估算2.5小时）
- 四元数特有运算
- 旋转组合

### Phase 5: FTransform（估算3小时）
- 变换组合
- 正向/逆向变换

### Phase 6: FBox（估算2小时）
- 包围盒运算
- 相交测试

### Phase 7: FLinearColor（估算2小时）
- 颜色运算
- 颜色空间转换

**总估算：约17小时**

---

## 📝 关键差异（vs int/float）

### 1. 新增测试类别：Method Tests
**原因：** Math 类型有大量成员方法需要测试
- int/float 主要是运算符
- Math 类型有 Size(), Normalize(), Dot(), Cross() 等

### 2. 常量测试
- FVector::ZeroVector
- FVector::UpVector
- FRotator::ZeroRotator
- FLinearColor::White

### 3. 精度比较
- FVector: `Equals(Tolerance=0.0001f)`
- FRotator: `Equals(Tolerance=0.0001f)`
- 需要容差比较，类似 float

### 4. 索引运算符
- `FVector[0/1/2]` → X/Y/Z
- 需要测试越界行为

### 5. 跨类型运算
- FVector * float
- FVector * double
- FQuat * FVector

---

## 🎯 立即行动：FVector

创建 4 个测试文件：
1. `AngelscriptCoverageFVectorPropertyTests.cpp`
2. `AngelscriptCoverageFVectorExpressionTests.cpp`
3. `AngelscriptCoverageFVectorFunctionTests.cpp`
4. `AngelscriptCoverageFVectorMethodTests.cpp` ⭐ 新类别

**下一步：开始实现 FVector coverage？**







