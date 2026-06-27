# AngelScript Coverage 测试 API 使用指南

> 基于实际编译错误总结的正确 API 用法

## 🎯 FASGlobalFunctionInvoker API 使用规则

### 1. 原始类型（Primitive Types）✅

**支持的类型：** `bool`, `int32`, `int64`, `uint32`, `uint64`, `float`, `double`

**使用方法：**
```cpp
// 添加参数
Invoker.AddArg(42);           // int32
Invoker.AddArg(true);         // bool
Invoker.AddArg(3.14f);        // float

// 获取返回值
int32 Result = Invoker.ExecuteAndGet<int32>(0);
bool Result = Invoker.ExecuteAndGet<bool>(false);
float Result = Invoker.ExecuteAndGet<float>(0.0f);
```

---

### 2. 复杂类型（Complex Types）⚠️

**支持的类型：** `FString`, `FName`, `FText`, `FVector`, `FRotator`, 等

**错误写法：** ❌
```cpp
// 这些都会导致编译错误！
Invoker.AddArg(FString(TEXT("Hello")));           // ❌ 不支持
Invoker.AddArg(FName(TEXT("Test")));              // ❌ 不支持
const FString Result = Invoker.ExecuteAndGet<FString>(FString());  // ❌ 不支持
```

**正确写法：** ✅
```cpp
// 添加参数 - 使用 AddArgRef
FString InputString = TEXT("Hello");
Invoker.AddArgRef(InputString);

FName InputName = TEXT("Test");
Invoker.AddArgRef(InputName);

// 获取返回值 - 使用 ExecuteAndExtractStruct
FString Result;
ASSERT_THAT(IsTrue(Invoker.ExecuteAndExtractStruct(Result)));

FName Result;
ASSERT_THAT(IsTrue(Invoker.ExecuteAndExtractStruct(Result)));
```

---

### 3. &out 参数（Output Parameters）✅

**所有类型都使用 AddArgRef：**
```cpp
// 原始类型
int32 OutValue = 0;
Invoker.AddArgRef(OutValue);

// 复杂类型
FString OutString;
Invoker.AddArgRef(OutString);

// 执行后，OutValue 和 OutString 会被修改
Invoker.Execute();
```

---

### 4. &in 和 &inout 参数 ✅

**与 &out 相同，都使用 AddArgRef：**
```cpp
// &in
FString InputString = TEXT("Test");
Invoker.AddArgRef(InputString);

// &inout
FString InOutString = TEXT("Original");
Invoker.AddArgRef(InOutString);
Invoker.Execute();
// InOutString 现在可能被修改
```

---

## 📝 完整示例

### 示例1：原始类型函数
```cpp
// AngelScript 函数：
// int Add(int a, int b) { return a + b; }

FASGlobalFunctionInvoker Invoker(*TestRunner, Engine, *Module, TEXT("int Add(int, int)"));
Invoker.AddArg(10).AddArg(20);
int32 Result = Invoker.ExecuteAndGet<int32>(0);
// Result == 30
```

### 示例2：FString 值参数
```cpp
// AngelScript 函数：
// FString Greet(FString name) { return "Hello " + name; }

FASGlobalFunctionInvoker Invoker(*TestRunner, Engine, *Module, TEXT("FString Greet(FString)"));
FString InputName = TEXT("World");
Invoker.AddArgRef(InputName);
FString Result;
ASSERT_THAT(IsTrue(Invoker.ExecuteAndExtractStruct(Result)));
// Result == "Hello World"
```

### 示例3：FString &out 参数
```cpp
// AngelScript 函数：
// void GetMessage(FString&out msg) { msg = "Output"; }

FASGlobalFunctionInvoker Invoker(*TestRunner, Engine, *Module, TEXT("void GetMessage(FString&out)"));
FString OutMessage;
Invoker.AddArgRef(OutMessage);
Invoker.Execute();
// OutMessage == "Output"
```

### 示例4：混合参数
```cpp
// AngelScript 函数：
// FString Format(int num, FString text) { return FString::Printf("{0}: {1}", num, text); }

FASGlobalFunctionInvoker Invoker(*TestRunner, Engine, *Module, TEXT("FString Format(int, FString)"));
FString InputText = TEXT("Items");
Invoker.AddArg(42).AddArgRef(InputText);
FString Result;
ASSERT_THAT(IsTrue(Invoker.ExecuteAndExtractStruct(Result)));
// Result == "42: Items"
```

---

## 🔧 辅助函数模式

### 通用 ExpectGlobalReturn 辅助函数

**正确实现：**
```cpp
template <typename T>
void ExpectGlobalReturn(FAngelscriptEngine& Engine, asIScriptModule* Module, 
                       const TCHAR* Declaration, const T& Expected, const TCHAR* Message)
{
    FASGlobalFunctionInvoker Invoker(*TestRunner, Engine, *Module, Declaration);
    T Result{};
    
    // 根据类型选择正确的 API
    if constexpr (std::is_same_v<T, bool>
        || std::is_same_v<T, int32>
        || std::is_same_v<T, int64>
        || std::is_same_v<T, uint32>
        || std::is_same_v<T, uint64>
        || std::is_same_v<T, float>
        || std::is_same_v<T, double>)
    {
        // 原始类型
        Result = Invoker.ExecuteAndGet<T>(T{});
    }
    else
    {
        // 复杂类型（FString, FName, FVector, 等）
        ASSERT_THAT(IsTrue(Invoker.ExecuteAndExtractStruct(Result)));
    }
    
    TestRunner->TestEqual(Message, Result, Expected);
}
```

**使用：**
```cpp
// 原始类型
ExpectGlobalReturn<int32>(Engine, Module, TEXT("int GetValue()"), 42, TEXT("GetValue"));

// 复杂类型
ExpectGlobalReturn<FString>(Engine, Module, TEXT("FString GetName()"), FString(TEXT("Test")), TEXT("GetName"));
```

---

## ⚠️ 常见错误

### 错误1：直接传递临时对象
```cpp
// ❌ 错误
Invoker.AddArg(FString(TEXT("Hello")));

// ✅ 正确
FString Input = TEXT("Hello");
Invoker.AddArgRef(Input);
```

### 错误2：使用错误的返回值获取方法
```cpp
// ❌ 错误
FString Result = Invoker.ExecuteAndGet<FString>(FString());

// ✅ 正确
FString Result;
Invoker.ExecuteAndExtractStruct(Result);
```

### 错误3：链式调用时类型混合
```cpp
// ❌ 错误
Invoker.AddArg(10).AddArg(FString(TEXT("Test")));

// ✅ 正确
FString Arg2 = TEXT("Test");
Invoker.AddArg(10).AddArgRef(Arg2);
```

---

## 📊 API 对照表

| 操作 | 原始类型 | 复杂类型 |
|------|---------|---------|
| 添加参数 | `AddArg(value)` | `AddArgRef(variable)` |
| &out 参数 | `AddArgRef(variable)` | `AddArgRef(variable)` |
| &in 参数 | `AddArgRef(variable)` | `AddArgRef(variable)` |
| &inout 参数 | `AddArgRef(variable)` | `AddArgRef(variable)` |
| 获取返回值 | `ExecuteAndGet<T>(default)` | `ExecuteAndExtractStruct(result)` |
| void 返回 | `Execute()` | `Execute()` |

---

## 🎯 类型分类

### 原始类型（使用 AddArg + ExecuteAndGet）
- `bool`
- `int8`, `int16`, `int32`, `int64`
- `uint8`, `uint16`, `uint32`, `uint64`
- `float`, `double`

### 复杂类型（使用 AddArgRef + ExecuteAndExtractStruct）
- `FString`, `FName`, `FText`
- `FVector`, `FVector2D`, `FVector4`
- `FRotator`, `FQuat`, `FTransform`
- `FLinearColor`, `FColor`
- `FBox`, `FIntVector`, `FIntPoint`
- 其他 UE 结构体

---

## 💡 最佳实践

1. **声明局部变量** - 不要传递临时对象
2. **使用 constexpr if** - 在辅助函数中区分类型
3. **检查返回值** - ExecuteAndExtractStruct 返回 bool
4. **链式调用** - AddArg 和 AddArgRef 都返回 this，可以链式调用
5. **一致性** - 同一个项目使用统一的辅助函数

---

## 📚 参考

**模板文件：**
- `Plugins/Angelscript/Source/AngelscriptTest/Template/Template_CQTest.cpp`

**实际示例：**
- `AngelscriptCoverageIntFunctionTests.cpp` - 原始类型示例
- `AngelscriptCoverageFStringFunctionTests.cpp` - 复杂类型示例

**API 定义：**
- `Plugins/Angelscript/Source/AngelscriptTest/Shared/AngelscriptTestExecute.h`

---

**记住：原始类型用 AddArg，复杂类型用 AddArgRef！** ✅





