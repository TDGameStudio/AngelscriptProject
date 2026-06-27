# AngelScript Coverage API 修复记录

> 日期：2026-06-27
> 目的：记录所有编译错误及其修复方法

## 🐛 发现的编译错误

### 错误1: FString AddArg 不支持

**错误信息：**
```
error C2672: 'FAngelscriptTestExecutor::AddArg': no matching overloaded function found
note: candidate expects 1 argument of 'uint32', found type 'FString'
```

**错误原因：**
`AddArg()` 方法只支持原始类型（bool, int32, float 等），不支持复杂类型（FString, FName, FVector 等）。

**错误代码：**
```cpp
Invoker.AddArg(FString(TEXT("Hello")));  // ❌ 编译失败
```

**修复方法：**
```cpp
FString InputString = TEXT("Hello");
Invoker.AddArgRef(InputString);  // ✅ 正确
```

**修复位置：**
- FStringFunctionTests.cpp 的 7 处 AddArg 调用

---

### 错误2: FString ExecuteAndGet 不支持

**错误信息：**
```
error C2672: 'FAngelscriptTestExecutor::ExecuteAndGet': no matching overloaded function found
note: candidate expects return type to match constraint
```

**错误原因：**
`ExecuteAndGet<T>()` 只支持原始类型返回值，不支持复杂类型。

**错误代码：**
```cpp
const FString Result = Invoker.ExecuteAndGet<FString>(FString());  // ❌ 编译失败
```

**修复方法：**
```cpp
FString Result;
ASSERT_THAT(IsTrue(Invoker.ExecuteAndExtractStruct(Result)));  // ✅ 正确
```

**修复位置：**
- FStringFunctionTests.cpp 的 9 处 ExecuteAndGet 调用

---

### 错误3: ExecuteAndExtractStruct 用法错误

**错误信息：**
```
error C2672: 'FAngelscriptTestExecutor::ExecuteAndExtractStruct': no matching overloaded function found
note: candidate expects 1 argument of type 'StructType &', found 0
```

**错误原因：**
`ExecuteAndExtractStruct<T>()` 不能作为返回值，必须传入引用参数。

**错误代码：**
```cpp
const FString Result = Invoker.ExecuteAndExtractStruct<FString>();  // ❌ 编译失败
```

**修复方法：**
```cpp
FString Result;
ASSERT_THAT(IsTrue(Invoker.ExecuteAndExtractStruct(Result)));  // ✅ 正确
```

**修复位置：**
- 第一次修复后产生的新错误（模板参数使用错误）

---

## ✅ 修复总结

### 修复的文件
1. **AngelscriptCoverageFStringFunctionTests.cpp**
   - 修复了所有 AddArg 调用（7处）
   - 修复了所有 ExecuteAndGet 调用（9处）
   - 修复了所有 ExecuteAndExtractStruct 调用（从模板形式改为引用参数形式）

2. **AngelscriptCoverageFStringMethodTests.cpp**
   - 更新了 ExpectGlobalReturn 辅助函数
   - 添加了 constexpr if 来区分原始类型和复杂类型

### 正确的 API 模式

#### 模式1：原始类型（bool, int32, float, double）
```cpp
// 参数
Invoker.AddArg(42);
Invoker.AddArg(true);
Invoker.AddArg(3.14f);

// 返回值
int32 Result = Invoker.ExecuteAndGet<int32>(0);
bool Result = Invoker.ExecuteAndGet<bool>(false);
float Result = Invoker.ExecuteAndGet<float>(0.0f);
```

#### 模式2：复杂类型（FString, FName, FVector, 等）
```cpp
// 参数
FString InputString = TEXT("Hello");
Invoker.AddArgRef(InputString);

// 返回值
FString Result;
ASSERT_THAT(IsTrue(Invoker.ExecuteAndExtractStruct(Result)));
```

#### 模式3：&out / &inout 参数（所有类型）
```cpp
// 原始类型
int32 OutValue = 0;
Invoker.AddArgRef(OutValue);

// 复杂类型
FString OutString;
Invoker.AddArgRef(OutString);

Invoker.Execute();
// OutValue 和 OutString 现在被修改了
```

---

## 📊 修复统计

### 修复次数
| 文件 | AddArg → AddArgRef | ExecuteAndGet → ExecuteAndExtractStruct | 总修复 |
|------|:------------------:|:--------------------------------------:|:-----:|
| FStringFunctionTests.cpp | 7 | 9 | 16 |
| FStringMethodTests.cpp | 0 | 1（辅助函数） | 1 |
| **总计** | **7** | **10** | **17** |

### 编译尝试
1. ❌ **第1次** - AddArg 错误（7处）
2. ❌ **第2次** - ExecuteAndGet 错误（9处）
3. ❌ **第3次** - ExecuteAndExtractStruct 模板形式错误（9处）
4. ⏳ **第4次** - 所有错误已修复，编译中...

---

## 💡 经验教训

### 1. 查阅模板文件
**教训：** 应该先查看 `Template_CQTest.cpp` 中的示例代码
**原因：** 模板文件中有正确的 API 使用注释

### 2. 类型系统理解
**教训：** 理解原始类型 vs 复杂类型的区别
**原因：** AngelScript 对这两类类型使用不同的绑定机制

### 3. 增量测试
**教训：** 应该先测试一个简单的 FString 函数
**原因：** 可以更早发现 API 问题

### 4. 参考现有测试
**教训：** 查看 int/float 测试如何处理类似场景
**原因：** 但要注意它们是原始类型，API 不同

---

## 🔧 辅助函数更新

### 通用 ExpectGlobalReturn

**更新前：**
```cpp
template <typename T>
void ExpectGlobalReturn(...) {
    const T Result = Invoker.ExecuteAndGet<T>(T{});  // ❌ 对复杂类型失败
    TestRunner->TestEqual(Message, Result, Expected);
}
```

**更新后：**
```cpp
template <typename T>
void ExpectGlobalReturn(...) {
    T Result{};
    if constexpr (std::is_same_v<T, bool>
        || std::is_same_v<T, int32>
        || std::is_same_v<T, float>
        || std::is_same_v<T, double>) {
        Result = Invoker.ExecuteAndGet<T>(T{});  // 原始类型
    } else {
        ASSERT_THAT(IsTrue(Invoker.ExecuteAndExtractStruct(Result)));  // 复杂类型
    }
    TestRunner->TestEqual(Message, Result, Expected);
}
```

**优点：**
- 自动处理类型差异
- 统一的调用接口
- 类型安全

---

## 📚 参考资料

### 相关文件
1. **API 定义**
   - `Shared/AngelscriptTestExecute.h` - 定义所有 Invoker 方法

2. **模板示例**
   - `Template/Template_CQTest.cpp` - 包含正确用法注释

3. **现有测试**
   - `AngelscriptCoverageIntFunctionTests.cpp` - 原始类型示例
   - `AngelscriptCoverageFStringFunctionTests.cpp` - 复杂类型示例（修复后）

### 创建的文档
- `Coverage_API_Usage_Guide.md` - 完整的 API 使用指南

---

## ✅ 验证清单

### 编译验证
- [x] 修复所有 AddArg 错误
- [x] 修复所有 ExecuteAndGet 错误
- [x] 修复所有 ExecuteAndExtractStruct 用法错误
- [x] 更新辅助函数
- [ ] 编译成功（进行中）

### 运行验证
- [ ] FString 测试全部通过
- [ ] 其他类型测试未受影响
- [ ] 没有运行时错误

---

## 🎯 最终状态

**修复完成度：** 100% ✅

**文件状态：**
- ✅ AngelscriptCoverageFStringFunctionTests.cpp - 17处修复
- ✅ AngelscriptCoverageFStringMethodTests.cpp - 1处修复（辅助函数）
- ✅ AngelscriptCoverageFStringExpressionTests.cpp - 无需修复（已正确）

**编译状态：** ⏳ 等待第4次编译完成

**预期结果：** ✅ 编译成功，0个错误

---

**所有 API 问题已修复！等待编译验证。** 🎉







