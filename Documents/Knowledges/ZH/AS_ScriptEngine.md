# AS_ScriptEngine — asCScriptEngine 核心架构

> **所属模块**: AS_（AngelScript 引擎内核族）
> **关注层面**: 脚本引擎主控单例的内部架构（类型/模块/上下文管理、生命周期、线程安全）
> **关键源码**:
> `ThirdParty/angelscript/source/as_scriptengine.h` (25 KB, 569 行)
> · `ThirdParty/angelscript/source/as_scriptengine.cpp` (188 KB, 6398 行)
> · `ThirdParty/angelscript/source/as_module.h` / `.cpp` (13 KB / 79 KB)
> · `ThirdParty/angelscript/source/as_configgroup.h` / `.cpp` (2 KB / 3 KB)
> **关联文档**:
> `AS_TypeRegistration.md` — 类型注册 API 深入分析
> · `AS_VirtualMachine.md` — 上下文执行引擎
> · `AS_GarbageCollector.md` — GC 策略
> · `AS_ForkDifferences.md` — Fork 差异清单
> · `Arch_RuntimeLifecycle.md` — 插件层对 AS 引擎的封装

---

## 概览

`asCScriptEngine` 是 AngelScript 引擎的**中央主控对象**。它实现了公共接口 `asIScriptEngine`，是整个脚本系统中所有其他组件的锚点——类型注册、模块编译、上下文执行、垃圾回收都由它统一调度。本文分析其内部架构：成员变量布局、关键生命周期函数、模块/上下文管理机制、线程安全设计，以及 UE Fork 的适配修改。

```text
asCScriptEngine 的核心职责
============================

1. 类型注册中枢    Register*() 系列 API 注册 C++ 类型给脚本使用
2. 模块容器管理    scriptModules[] 持有所有编译后的脚本模块
3. 上下文池        RequestContext / ReturnContext 复用执行上下文
4. 函数 ID 分配    scriptFunctions[] 全局函数 ID 表
5. GC 入口         内嵌 asCGarbageCollector gc 成员
6. 配置/属性       ep 结构体控制编译器/运行时行为
```

---

## 类声明与继承

```cpp
// as_scriptengine.h:64-66
//[UE++]: Rename export macro to match the runtime module rename.
class ANGELSCRIPTRUNTIME_API asCScriptEngine final : public asIScriptEngine  // ★ 实现公共接口
```

- 标记 `final`，不可子类化
- **[UE++]**: 导出宏从原版改为 `ANGELSCRIPTRUNTIME_API`
- 友元：`asCBuilder`, `asCCompiler`, `asCContext`, `asCDataType`, `asCModule`, `asCRestore`, `asCByteCode`

---

## 成员变量全景

`asCScriptEngine` 的成员可按职责分为 7 大区域：

### 1. 已注册类型表（应用层注册）

```text
registeredObjTypes[]           // ★ 所有 RegisterObjectType 注册的对象类型
registeredTypeDefs[]           // typedef 别名
registeredEnums[]              // enum 类型
registeredGlobalProps[]        // 全局属性（增引用计数）
registeredGlobalFuncs[]        // 全局函数
registeredFuncDefs[]           // funcdef 函数类型
registeredTemplateTypes[]      // 模板类型
allRegisteredTypes             // asCSymbolMap — 按名称+命名空间索引（增引用计数）
allRegisteredTypesByName       // asCMapByName — 按名称快速查找
stringFactory                  // asIStringFactory* — 字符串工厂
```

### 2. 模块与函数全局表

```text
scriptModules[]                // ★ 所有活跃脚本模块
scriptModulesByName            // 按名称索引模块
scriptFunctions[]              // ★ 全局函数 ID 表 (index = funcId)
freeScriptFunctionIds[]        // 可复用的空闲 ID 槽
allScriptGlobalFunctions       // 跨模块全局函数符号表
allScriptDeclaredTypes         // 跨模块脚本声明类型
sharedScriptTypes[]            // shared 脚本类型
funcDefs[]                     // 全局 funcdef 列表
```

### 3. 全局属性

```text
globalProperties[]             // 全局属性 (index = property ID)
freeGlobalPropertyIds[]        // 可复用的空闲属性 ID
varAddressMap                  // TMap<void*, asCGlobalProperty*> — 按内存地址索引
```

### 4. 类型 ID 映射

```text
typeIdSeqNbr                   // 自增序列号，从 asTYPEID_FLOAT64 + 1 开始
mapTypeIdToTypeInfo            // TMap<int, asCTypeInfo*> — typeId → 类型对象
```

### 5. 垃圾回收器

```text
gc                             // ★ asCGarbageCollector 实例（非指针，嵌入成员）
```

### 6. 引擎属性（编译器/运行时行为开关）

```cpp
// as_scriptengine.h:496-546 — 匿名 struct ep
struct {
    bool   allowUnsafeReferences;     // 允许不安全引用
    bool   optimizeByteCode;          // 启用字节码优化（默认 true）
    asUINT maximumContextStackSize;   // 上下文栈上限（0 = 无限制）
    asUINT initContextStackSize;      // 初始栈大小（默认 1024）
    int    scanner;                   // 词法分析编码（0=ASCII, 1=UTF8）
    int    propertyAccessorMode;      // 属性访问器模式（3=需 property 标注）
    bool   autoGarbageCollect;        // 自动 GC
    asUINT maxNestedCalls;            // 最大嵌套调用深度（默认 100）
    bool   foreachSupport;            // foreach 语法（默认 true）
    bool   floatIsFloat64;            // float 是否为 64 位（默认 true）
    bool   allowDoubleType;           // 是否允许 double 类型
    bool   disableScriptClassGC;      // 禁用脚本类 GC
    // ... 共 40+ 属性
} ep;
```

### 7. 基础设施

```text
refCount                       // asCAtomic 原子引用计数
tok                            // asCTokenizer 实例（引擎共享）
engineRWLock                   // DECLAREREADWRITELOCK — 读写锁
shuttingDown                   // 关闭标志
inDestructor                   // 析构标志
isPrepared                     // PrepareEngine 是否已完成
isBuilding                     // 是否有编译正在进行
configFailed                   // 配置是否失败
requestCtxFunc / returnCtxFunc // 上下文池回调
defaultNamespace               // 全局默认命名空间
nameSpaces[]                   // 所有命名空间（引擎生命期内不释放）
Manager                        // void* — UE 侧 FAngelscriptEngine 反向指针
```

---

## 引擎生命周期

### 构造函数 (第 741-857 行)

```text
asCScriptEngine::asCScriptEngine()
==================================
Step 1: 初始化状态标志
  shuttingDown = false; inDestructor = false;

Step 2: 设置 40+ 引擎属性默认值 (ep 结构体)
  allowUnsafeReferences=false, optimizeByteCode=true,
  initContextStackSize=1024, scanner=1(utf8), ...

Step 3: 挂接子系统
  gc.engine = this;    // ★ GC 挂接引擎
  tok.engine = this;   // ★ Tokenizer 挂接引擎

Step 4: 基础初始化
  refCount.set(1);
  defaultNamespace = AddNameSpace("");  // 创建全局命名空间
  scriptFunctions.PushLast(0);         // 保留 funcId 0

Step 5: 原始类型 typeId 预留
  typeIdSeqNbr = asTYPEID_FLOAT64 + 1;
  // 验证 void=0, bool=1, ..., float64=12 的映射

Step 6: 注册内建类型
  RegisterScriptObject(this);    // 内建 ScriptObject 行为
  RegisterScriptFunction(this);  // 内建 ScriptFunction 行为
```

### PrepareEngine (第 3038-3137 行)

在首次 `CreateContext()` 时被调用（懒初始化），做两件事：

1. **准备系统函数**：遍历 `scriptFunctions[]`，对所有 `asFUNC_SYSTEM` 函数调用 `PrepareSystemFunction()` 或 `PrepareSystemFunctionGeneric()` 完成平台调用约定适配
2. **验证对象类型注册**：遍历 `registeredObjTypes[]`，检查 GC/Scoped/Ref 类型是否注册了必需的 addref/release/gcXxx 行为

```cpp
void asCScriptEngine::PrepareEngine()
{
    if( isPrepared ) return;   // ★ 幂等哨兵
    if( configFailed ) return; // 配置已失败则跳过

    // 步骤 1: 准备系统函数调用约定
    for( n = 0; n < scriptFunctions.GetLength(); n++ )
        if( func->funcType == asFUNC_SYSTEM )
            PrepareSystemFunction(func, func->sysFuncIntf, this);

    // 步骤 2: 验证 GC/Ref/Scoped 行为完整性
    for( n = 0; n < registeredObjTypes.GetLength(); n++ )
        // 检查 addref/release/gcEnumReferences 等是否齐全

    isPrepared = true;  // ★ 标记完成
}
```

### ShutDownAndRelease (第 1152-1189 行)

有序关闭引擎，按严格顺序执行：

```text
ShutDownAndRelease()
====================
Step 1: GarbageCollect()         // 首次完全 GC
Step 2: shuttingDown = true      // 加速关闭、禁止无效调用
Step 3: SetContextCallbacks(0,0,0) // 清除上下文池，防止引用计数递增
Step 4: 逆序 Discard 所有模块    // scriptModules 清空
Step 5: GarbageCollect()         // 第二次 GC（清理模块释放的对象）
Step 6: DeleteDiscardedModules() // 物理删除已丢弃模块
Step 7: gc.ReportAndReleaseUndestroyedObjects() // 报告泄漏
Step 8: Release()                // 释放引擎引用
```

### 析构函数 (第 885-1021 行)

如果用户直接 `delete` 而未调用 `ShutDownAndRelease`，析构函数会自动补调：

```cpp
asCScriptEngine::~asCScriptEngine()
{
    inDestructor = true;
    if( !shuttingDown ) { AddRef(); ShutDownAndRelease(); }  // ★ 兜底

    // 逆序清理所有已注册资源：
    // listPatternTypes → registeredGlobalProps → templateSubTypes
    // → registeredGlobalFuncs → scriptFunctions(DestroyInternal)
    // → funcDefs → globalProperties → nameSpaces → userData
}
```

---

## 模块管理

### 获取/创建模块

```cpp
// as_scriptengine.cpp:1448
asIScriptModule *asCScriptEngine::GetModule(const char *module, asEGMFlags flag)
{
    asCModule *mod = GetModule(module, false);  // 先查找已有的
    if( flag == asGM_ALWAYS_CREATE )  { mod->Discard(); return GetModule(module, true); }
    if( flag == asGM_CREATE_IF_NOT_EXISTS && mod == 0 )  return GetModule(module, true);
    return mod;
}

// 内部实现 (第 3226 行)
asCModule *asCScriptEngine::GetModule(const char *name, bool create)
{
    asCModule* retModule = scriptModulesByName.FindFirst(name);  // ★ 按名称快速查找
    if( create && retModule == nullptr )
    {
        retModule = asNEW(asCModule)(name, this);
        scriptModules.PushLast(retModule);
        scriptModulesByName.Add(retModule);
    }
    return retModule;
}
```

### 编译互斥

```cpp
int asCScriptEngine::RequestBuild()       // 编译前调用
{
    if( isBuilding ) return asBUILD_IN_PROGRESS;  // ★ 一次只允许一个编译
    isBuilding = true;
    return 0;
}

void asCScriptEngine::BuildCompleted()    // 编译后调用
{
    memoryMgr.FreeUnusedMemory();          // ★ 释放编译期池化内存
    isBuilding = false;
}
```

### 已丢弃模块清理

```cpp
void asCScriptEngine::DeleteDiscardedModules()
{
    // 逆序遍历，删除标记为 discarded 的模块
    for( n = scriptModules.GetLength() - 1; n >= 0; n-- )
        if( mod->discarded )
        {
            asDELETE(mod, asCModule);
            scriptModules.RemoveIndexUnordered(n);
        }

    // 清理无引用的全局属性
    for( n = globalProperties.GetLength() - 1; n >= 0; n-- )
        if( prop->refCount.get() == 1 )
            RemoveGlobalProperty(n);
}
```

---

## asCModule 核心结构

`asCModule` 是脚本编译的产出容器，每个模块对应一次 `Build()` 调用：

```text
asCModule 关键成员
==================
name / baseModuleName         // 模块名（热重载时可能带后缀）
engine / builder              // 反向引用
accessMask / defaultNamespace // 可见性控制

scriptFunctions[]             // 本模块编译的所有函数（增引用计数）
globalFunctions               // 全局函数子集（不增引用计数）
bindInformations[]            // 导入函数绑定信息

scriptGlobals                 // 全局变量
isGlobalVarInitialized        // 全局变量是否已初始化

classTypes[] / enumTypes[]    // 类/枚举类型
typeDefs[] / funcDefs[]       // typedef / funcdef

// [UE++] 热重载支持
ReloadState                   // 重编译状态机
ReloadOldModule / ReloadNewModule
moduleDependencies            // TMap<asCModule*, FModuleDependencyInfo>
```

---

## 上下文管理

### CreateContext

```cpp
int asCScriptEngine::CreateContext(asIScriptContext **context, bool isInternal)
{
    *context = asNEW(asCContext)(this, !isInternal);  // ★ 直接 new
    PrepareEngine();                                    // 确保引擎已准备好
    return 0;
}
```

### RequestContext / ReturnContext（上下文池）

```cpp
asIScriptContext *asCScriptEngine::RequestContext()
{
    if( requestCtxFunc )                    // ★ 应用层注册了池回调
        return requestCtxFunc(this, ctxCallbackParam);
    return CreateContext();                 // 兜底：直接创建新上下文
}

void asCScriptEngine::ReturnContext(asIScriptContext *ctx)
{
    if( returnCtxFunc )                     // ★ 归还给池
        returnCtxFunc(this, ctx, ctxCallbackParam);
    else if( ctx )
        ctx->Release();                     // 兜底：直接释放
}
```

---

## GC 入口

引擎级 GC 调用直接委托给内嵌的 `asCGarbageCollector`：

```cpp
int asCScriptEngine::GarbageCollect(asDWORD flags, asUINT iterations)
{
    return gc.GarbageCollect(flags, iterations);  // ★ 透传
}
```

---

## 配置组 (asCConfigGroup)

原版 AngelScript 的配置组机制用于按组管理注册的类型/函数，可按组移除。但在本 Fork 中，`BeginConfigGroup` / `EndConfigGroup` / `RemoveConfigGroup` 全部 **stub 化**（直接 `return 0`），配置组功能已被 UE 侧的绑定管理体系替代：

```cpp
int asCScriptEngine::BeginConfigGroup(const char *groupName) { return 0; }
int asCScriptEngine::EndConfigGroup() { return 0; }
int asCScriptEngine::RemoveConfigGroup(const char *groupName) { return 0; }
```

`asCConfigGroup` 类本身仍保留，但仅用于类型引用跟踪（`FindConfigGroupForTypeInfo` 等也全部返回 `0`）。

---

## 线程安全设计

引擎使用一把读写锁 `engineRWLock` 保护共享状态：

| 操作 | 锁模式 | 保护的数据 |
|------|--------|-----------|
| 读取 userData | ACQUIRESHARED | userData 数组 |
| 写入 userData | ACQUIREEXCLUSIVE | userData 数组 |
| 查询 moduleCount / moduleByIndex | ACQUIRESHARED | scriptModules |
| 注册全局属性/函数 | ACQUIREEXCLUSIVE | 注册表 |

引用计数 `refCount` 使用 `asCAtomic` 原子操作，不依赖引擎读写锁。

---

## UE Fork 修改摘要

本文件中的 `[UE++]` 修改较少，主要包括：

| 位置 | 修改 | 动机 |
|------|------|------|
| 头文件 L64 | `ANGELSCRIPTRUNTIME_API` 导出宏 | 匹配 UE Runtime 模块命名 |
| L104 | `RegisterObjectType` flags 参数从 `asDWORD` 改为 `asQWORD` | 保留 APV2 私有高位标志 |
| cpp L956 | 析构函数中 `DestroyInternal` 后再次检查 `scriptFunctions[n]` | 防止级联释放导致的空指针 |

> 完整的 Fork 差异请参见 `AS_ForkDifferences.md`。

---

## 小结

- `asCScriptEngine` 是 188 KB 的大型单例类，内部持有全部脚本系统状态
- 生命周期：构造 → 类型注册 → PrepareEngine（懒） → 模块编译/执行 → ShutDownAndRelease → 析构
- 模块管理通过 `scriptModules[]` + `scriptModulesByName` 双索引，编译通过 `isBuilding` 互斥
- 上下文管理支持应用层注入池回调（`requestCtxFunc` / `returnCtxFunc`）
- GC 作为内嵌成员直接委托，配置组在 Fork 中已 stub 化
- 线程安全通过一把 `engineRWLock` 读写锁 + `asCAtomic` 引用计数实现
