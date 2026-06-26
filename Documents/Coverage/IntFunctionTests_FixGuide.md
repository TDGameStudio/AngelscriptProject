# AngelscriptCoverageIntFunctionTests.cpp 修复指南

## 需要修复的 API 调用

### 1. FASGlobalFunctionInvoker - &out 参数

**错误代码：**
```cpp
Invoker.AddOutArg(&OutValue);
```

**正确代码：**
```cpp
Invoker.AddArgRef(OutValue);  // 不要取地址，直接传引用
```

### 2. FASGlobalFunctionInvoker - &inout 参数

**错误代码：**
```cpp
Invoker.AddInOutArg(&Value);
```

**正确代码：**
```cpp
Invoker.AddArgRef(Value);  // 不要取地址，直接传引用
```

### 3. FFunctionInvoker - 普通参数

**错误代码：**
```cpp
Invoker.SetArg(TEXT("a"), 20);
Invoker.SetArg(TEXT("b"), 22);
```

**正确代码：**
```cpp
Invoker.AddParam(20);  // 按声明顺序，不需要名字
Invoker.AddParam(22);
```

### 4. FFunctionInvoker - &out 参数

**错误代码：**
```cpp
Invoker.SetOutArg(TEXT("result"), &OutValue);
Invoker.Call();
```

**正确代码：**
```cpp
int32 OutValue = 0;
Invoker.AddParam(0);  // 先添加一个占位值
Invoker.Call();
Invoker.ReadParamAfterCall(0, OutValue);  // Call后读取
```

## 完整修复示例

### FunctionParametersOut 方法

**修复前：**
```cpp
{
    FASGlobalFunctionInvoker Invoker(*TestRunner, Engine, *Module, TEXT("void WriteInt(int&out)"));
    int32 OutValue = 0;
    Invoker.AddOutArg(&OutValue);  // ❌ 错误
    Invoker.Call();
    TestRunner->TestEqual(TEXT("int &out parameter writes value"), OutValue, 42);
}
```

**修复后：**
```cpp
{
    FASGlobalFunctionInvoker Invoker(*TestRunner, Engine, *Module, TEXT("void WriteInt(int&out)"));
    int32 OutValue = 0;
    Invoker.AddArgRef(OutValue);  // ✅ 正确
    Invoker.Call();
    TestRunner->TestEqual(TEXT("int &out parameter writes value"), OutValue, 42);
}
```

### FunctionParametersInOut 方法

**修复前：**
```cpp
{
    FASGlobalFunctionInvoker Invoker(*TestRunner, Engine, *Module, TEXT("void DoubleInt(int&inout)"));
    int32 Value = 21;
    Invoker.AddInOutArg(&Value);  // ❌ 错误
    Invoker.Call();
    TestRunner->TestEqual(TEXT("int &inout parameter modifies in place"), Value, 42);
}
```

**修复后：**
```cpp
{
    FASGlobalFunctionInvoker Invoker(*TestRunner, Engine, *Module, TEXT("void DoubleInt(int&inout)"));
    int32 Value = 21;
    Invoker.AddArgRef(Value);  // ✅ 正确
    Invoker.Call();
    TestRunner->TestEqual(TEXT("int &inout parameter modifies in place"), Value, 42);
}
```

### UFunctionParametersAndReturn 方法

**修复前：**
```cpp
{
    FFunctionInvoker Invoker(*TestRunner, Actor, TEXT("AddInts"));
    Invoker.SetArg(TEXT("a"), 20);  // ❌ 错误
    Invoker.SetArg(TEXT("b"), 22);  // ❌ 错误
    const int32 Result = Invoker.CallAndReturn<int32>();
    TestRunner->TestEqual(TEXT("UFUNCTION int parameters and return"), Result, 42);
}
```

**修复后：**
```cpp
{
    FFunctionInvoker Invoker(*TestRunner, Actor, TEXT("AddInts"));
    Invoker.AddParam(20);  // ✅ 正确
    Invoker.AddParam(22);  // ✅ 正确
    const int32 Result = Invoker.CallAndReturn<int32>();
    TestRunner->TestEqual(TEXT("UFUNCTION int parameters and return"), Result, 42);
}
```

**带 &out 参数的修复：**
```cpp
{
    FFunctionInvoker Invoker(*TestRunner, Actor, TEXT("WriteOut"));
    int32 OutValue = 0;
    Invoker.AddParam(0);  // ✅ 先添加占位值
    Invoker.Call();
    Invoker.ReadParamAfterCall(0, OutValue);  // ✅ Call后读取
    TestRunner->TestEqual(TEXT("UFUNCTION int &out parameter"), OutValue, 999);
}
```

## 全文搜索替换规则

1. 查找：`AddOutArg\(&(\w+)\)` → 替换：`AddArgRef($1)`
2. 查找：`AddInOutArg\(&(\w+)\)` → 替换：`AddArgRef($1)`
3. `SetArg(TEXT("a"), ...)` → `AddParam(...)`（手动，需按顺序）
4. `SetOutArg` → 需要改为 `AddParam` + `ReadParamAfterCall` 组合

## 注意事项

- `AddArgRef` 传引用，不要用 `&` 取地址
- `FFunctionInvoker::AddParam` 按参数声明顺序调用，不需要参数名
- `&out` 参数需要先 `AddParam` 占位，`Call()` 后用 `ReadParamAfterCall` 读取
- 参数索引从 0 开始

执行这些修复后应该可以编译通过！
