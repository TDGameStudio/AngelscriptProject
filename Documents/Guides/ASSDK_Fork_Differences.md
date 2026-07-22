# Unreal Angelscript Fork 关键差异发现

> 本文档记录在集成 AS SDK 官方测试到 Unreal Angelscript fork 过程中发现的关键差异。
> 这些差异影响测试编写和功能使用，需要特别注意。

## 1. 全局变量约束

### 发现
此 fork 要求所有脚本层全局变量必须是 `const`。

### 原始 AngelScript 行为
```angelscript
int GlobalVar = 42;           // 合法：可变全局变量
void ModifyGlobal() {
    GlobalVar++;              // 合法：修改全局变量
}
```

### 此 Fork 行为
```angelscript
int GlobalVar = 42;           // 编译错误！
// Error: Global variable 'GlobalVar' must be const. Mutable global variables are not supported.

const int GlobalVar = 42;     // 正确：必须是 const
```

### 影响范围
- 所有使用可变全局变量的上游测试需要改写
- 状态管理必须使用类成员变量或本地变量
- 模块间共享状态需要使用其他机制

### 迁移策略
```angelscript
// 原始代码
int Counter = 0;
void Increment() { Counter++; }

// 改写方案 1：使用类
class Counter {
    int Value = 0;
    void Increment() { Value++; }
}

// 改写方案 2：使用函数局部静态（如果 fork 支持）
// 或改用原生端状态管理
```

---

## 2. 脚本类实例化限制

### 发现
在隔离引擎上下文（非 UE 编辑器环境）中，脚本类实例化可能导致执行异常。

### 问题表现
```angelscript
class MyClass {
    int Value = 0;
    void Method() { Value++; }
}

bool Entry() {
    MyClass obj;              // 可能导致 asEXECUTION_EXCEPTION
    obj.Method();
    return true;
}
```

### 风险场景
- 单元测试中直接实例化脚本类
- 在 `CreateNativeEngine()` 创建的独立引擎中运行
- 不依赖 `FAngelscriptEngine` 的测试上下文

### 安全策略
1. **Compile-only 测试**：只验证编译通过，不执行
2. **避免脚本类实例化**：使用原生注册的类型或纯函数测试
3. **在 UE 上下文测试**：需要完整引擎环境时使用 UE 编辑器测试

### 测试代码模式
```cpp
// 安全：compile-only 测试
asIScriptModule* Module = BuildNativeModule(ScriptEngine, "Test",
    "class MyClass { int Value = 0; } \n"
    "bool Entry() { return true; } \n");
TestNotNull("Should compile", Module);
asIScriptFunction* Func = GetNativeFunctionByDecl(Module, "bool Entry()");
TestNotNull("Should have entry", Func);
// 不执行！

// 安全：使用纯函数
asIScriptModule* Module = BuildNativeModule(ScriptEngine, "Test",
    "int Compute(int N) { int Result = 0; for(int i=1; i<=N; i++) Result += i; return Result; } \n"
    "bool Entry() { return Compute(10) == 55; } \n");
// 执行是安全的
```

---

## 3. Handle/指针语法差异

### 发现
此 fork 不支持 vanilla AngelScript 的 `@` 指针/句柄语法。

### 原始 AngelScript 行为
```angelscript
// 显式句柄声明
MyClass@ obj = @CreateMyClass();

// 句柄传递
void PassHandle(MyClass@ obj) { }

// 自动句柄
void AutoHandle(MyClass@+ obj) { }  // 自动 AddRef
```

### 此 Fork 行为
```angelscript
// 对象引用是自动的，无需 @ 语法
MyClass obj;                   // 直接声明，引用语义
obj = CreateMyClass();         // 自动管理

// 函数参数
void PassObject(MyClass obj) { }  // 隐式引用传递
```

### 原生注册差异

#### 原始 AngelScript
```cpp
// 注册句柄工厂
int r = engine->RegisterObjectBehaviour("MyRefType", asBEHAVE_FACTORY, 
    "MyRefType@ f()", asFUNCTION(FactoryFunc), asCALL_CDECL);
```

#### 此 Fork 尝试（失败）
```cpp
// 尝试注册句柄工厂 - 返回 -10 (asINVALID_DECLARATION)
int r = engine->RegisterObjectBehaviour("MyRefType", asBEHAVE_FACTORY,
    "MyRefType@ f()", ...);  // r = -10
```

### 影响的测试
- `test_objhandle.cpp` 系列
- `test_autohandle.cpp`
- `test_implicithandle.cpp`
- `test_objzerosize.cpp`

### 迁移策略
1. **跳过句柄测试**：此 fork 的对象生命周期管理与 vanilla AS 不同
2. **使用 asOBJ_NOCOUNT**：注册无需引用计数的类型
3. **依赖 UE 反射**：让框架自动处理对象引用

---

## 4. Interface 关键字限制

### 发现
`interface` 关键字在脚本层不被识别。

### 原始 AngelScript 行为
```angelscript
interface IMovable {
    void Move(float Delta);
}

class Player : IMovable {
    void Move(float Delta) { /* ... */ }
}
```

### 此 Fork 行为
```angelscript
// 脚本层 interface 关键字不被支持
interface IMovable { }    // 语法错误！

// 只能在原生端注册接口
// engine->RegisterInterface("IMovable");
```

### 替代方案
1. **原生端注册接口**：在 C++ 侧使用 `RegisterInterface()`
2. **抽象类模拟**：使用带有虚方法的抽象类
3. **接口桥接测试**：只测试接口注册，不测试脚本实现

### 测试代码模式
```cpp
// 安全：测试接口注册
int r = engine->RegisterInterface("ITestInterface");
TestTrue("Should register interface", r >= 0);

r = engine->RegisterInterfaceMethod("ITestInterface", "void Method()");
TestTrue("Should register interface method", r >= 0);
```

---

## 5. Mixin 语法差异

### 发现
`mixin class` 不支持，只支持 `mixin` 全局函数。

### 原始 AngelScript 行为
```angelscript
// Mixin 类
mixin class Movable {
    void Move() { /* ... */ }
}

class Player : Movable {
    // 自动获得 Move()
}
```

### 此 Fork 行为
```angelscript
// mixin class 不支持
mixin class Movable { }  // 语法错误！

// 只支持 mixin 全局函数
mixin void MoveCommon() {
    // 共享代码
}

class Player {
    void Move() {
        MoveCommon();  // 显式调用
    }
}
```

### 测试代码模式
```cpp
// 安全：测试 mixin 函数
asIScriptModule* Module = BuildNativeModule(ScriptEngine, "Test",
    "mixin void Helper() { } \n"
    "void Entry() { Helper(); } \n");
TestNotNull("Should compile", Module);
```

---

## 6. 测试编写最佳实践

### 安全模式

#### ✅ 推荐
```angelscript
// 1. const 全局变量
const int MAX_VALUE = 100;

// 2. 纯函数
int Sum(int a, int b) { return a + b; }

// 3. 使用原生类型
void TestNativeType() {
    // 测试原生注册的类型
}
```

#### ❌ 避免
```angelscript
// 1. 可变全局变量
int Counter = 0;  // 编译错误

// 2. 在测试中实例化脚本类
MyClass obj;  // 可能崩溃

// 3. @ 句柄语法
MyClass@ obj;  // 不支持

// 4. 脚本层 interface
interface IFoo { }  // 不支持
```

### Compile-Only 测试模式
用于验证语法、类型系统、编译器行为，但不执行：

```cpp
bool FTest::RunTest(const FString& Parameters) {
    asIScriptEngine* Engine = CreateNativeEngine(&Messages);
    asIScriptModule* Module = BuildNativeModule(Engine, "Test",
        "class MyClass { int Value = 0; } \n"
        "bool Entry() { return true; } \n");
    
    if (!TestNotNull("Should compile", Module)) {
        AddInfo(CollectMessages(Messages));
        return false;
    }
    
    // 只验证函数存在，不执行
    asIScriptFunction* Func = GetNativeFunctionByDecl(Module, "bool Entry()");
    return TestNotNull("Should have entry", Func);
}
```

---

## 7. 版本与兼容性矩阵

| 特性 | Vanilla AS 2.38 | 此 Fork | 状态 |
|------|-----------------|---------|------|
| 可变全局变量 | ✅ | ❌ 必须 const | 差异 |
| `@` 句柄语法 | ✅ | ❌ 自动引用 | 差异 |
| 脚本层 `interface` | ✅ | ❌ 仅原生注册 | 差异 |
| `mixin class` | ✅ | ❌ 仅 mixin 函数 | 差异 |
| 脚本类实例化 | ✅ | ⚠️ 隔离环境不稳定 | 限制 |
| `const` 全局变量 | ✅ | ✅ | 兼容 |
| 原生类型注册 | ✅ | ✅ | 兼容 |
| 函数重载 | ✅ | ✅ | 兼容 |
| 默认参数 | ✅ | ✅ | 兼容 |
| 值类型 | ✅ | ✅ | 兼容 |
| 继承 | ✅ | ✅ | 兼容 |

---

## 8. 跳过的上游测试

以下上游测试因 fork 差异无法直接集成：

| 测试文件 | 原因 | 替代方案 |
|----------|------|----------|
| `test_objhandle.cpp` | `@` 语法不支持 | 跳过 |
| `test_objhandle2.cpp` | `@` 语法不支持 | 跳过 |
| `test_autohandle.cpp` | 自动句柄不支持 | 跳过 |
| `test_implicithandle.cpp` | 隐式句柄不支持 | 跳过 |
| `test_objzerosize.cpp` | 零大小对象句柄不支持 | 跳过 |
| `test_interface.cpp` | 脚本层 interface 不支持 | 改为测试原生注册 |
| `test_mixin.cpp` | `mixin class` 不支持 | 改为测试 mixin 函数 |

---

## 9. 文档更新历史

- **2026-07-23**: 原生核心回归按九个主题重组。独立 raw engine 中脚本对象构造会进入 UE class allocator，不能作为普通执行成功路径；测试改为安全验证编译、类型元数据及明确限制。当前 float64 配置下 double-backed 值类型 native call 的受限异常与可执行整数调用路径分别固定；future 2.38 脚本语义以 Disabled `#as-v238-backport` CQTest 记录。

- **2026-04-03**: 初始创建，记录 P0-P5 集成过程中的发现
