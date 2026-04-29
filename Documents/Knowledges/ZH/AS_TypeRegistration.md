# AS_TypeRegistration — 类型注册 API

> **所属模块**: AS_（AngelScript 引擎内核族）
> **关注层面**: C++ 类型如何通过 Register* API 注册到脚本引擎，三层类型体系的内部结构
> **关键源码**:
> `ThirdParty/angelscript/source/as_scriptengine.cpp` (188 KB) — Register* 系列实现
> · `ThirdParty/angelscript/source/as_objecttype.h` / `.cpp` (12 KB / 22 KB) — asCObjectType
> · `ThirdParty/angelscript/source/as_typeinfo.h` / `.cpp` (9 KB / 11 KB) — asCTypeInfo 基类
> · `ThirdParty/angelscript/source/as_datatype.h` / `.cpp` (7 KB / 21 KB) — asCDataType
> **关联文档**:
> `AS_ScriptEngine.md` — 引擎成员变量中的注册表布局
> · `AS_ObjectLifecycle.md` — 行为表（asSTypeBehaviour）与对象生命周期
> · `AS_CallingConventions.md` — 调用约定检测

---

## 概览

AngelScript 的类型注册是**应用层驱动的单向流程**：宿主 C++ 代码调用 `RegisterObjectType/Method/Behaviour` 等 API，将类型信息注入引擎，供脚本编译和执行时使用。本文分析注册 API 的内部实现——验证逻辑、类型对象创建、函数声明解析、以及 `asCTypeInfo` / `asCObjectType` / `asCDataType` 三层类型体系。

---

## 三层类型体系

```text
asCDataType                    // 编译期类型表示（值语义，轻量）
  ├── tokenType (eTokenType)   // 原始类型 token (ttInt, ttFloat32, ...)
  ├── typeInfo  (asCTypeInfo*) // 指向类型对象（引用类型时非空）
  ├── isReference/isReadOnly/isObjectHandle  // 修饰符位域
  └── 工厂方法: CreatePrimitive/CreateType/CreateObjectHandle/CreateNullHandle

asCTypeInfo                    // 类型信息基类（引用计数）
  ├── name / nameSpace / size / flags / typeId
  ├── externalRefCount / internalRefCount
  ├── engine / module           // 所属引擎和模块
  └── 子类: asCObjectType / asCEnumType / asCTypedefType / asCFuncdefType

asCObjectType : asCTypeInfo    // 对象类型（最完整的类型描述）
  ├── properties[]  / propertyTable    // 属性列表
  ├── methods[]     / methodTable      // 方法列表（按名称索引）
  ├── interfaces[]  / interfaceVFTOffsets  // 接口列表
  ├── virtualFunctionTable[]           // 虚函数表
  ├── derivedFrom   / shadowType       // 继承链 / UE 类型遮蔽
  ├── beh (asSTypeBehaviour)           // ★ 行为表
  ├── templateSubTypes[] / templateBaseType  // 模板支持
  └── accessSpecifiers[]               // UE access 修饰符
```

---

## RegisterObjectType (行 1786-2044)

最核心的类型注册 API。内部流程：

```text
RegisterObjectType(name, byteSize, flags)
==========================================
Step 1: isPrepared = false  // ★ 强制重新 PrepareEngine

Step 2: 验证 flags（REF vs VALUE 互斥检查）
  REF:   可选 GC/NOHANDLE/SCOPED/TEMPLATE/NOCOUNT/IMPLICIT_HANDLE
  VALUE: 可选 POD/APP_CLASS/APP_PRIMITIVE/APP_FLOAT/APP_ARRAY/TEMPLATE
  互斥: GC+NOHANDLE/SCOPED 不能同时设置

Step 3: Value 类型必须有 byteSize > 0

Step 4: 名称验证
  - 不能是保留关键字（通过 tok.GetToken 验证）
  - 不能与已有类型冲突（GetRegisteredType / CheckNameConflict）

Step 5: 区分模板 vs 非模板
  模板: ParseTemplateDecl 解析 <T> 声明，创建子类型占位符
  非模板: 尝试 ParseDataType 判断是否为模板特化

Step 6: 创建 asCObjectType 对象，设置 name/namespace/size/flags

Step 7: 写入注册表
  allRegisteredTypes.Add(type)        // 按命名空间索引
  allRegisteredTypesByName.Add(type)  // 按名称索引
  registeredObjTypes.PushLast(type)   // 线性列表
```

**[UE++]**: flags 参数从 `asDWORD` 拓宽为 `asQWORD`，保留 APV2 私有高位标志。

---

## RegisterObjectMethod (行 2691-2843)

```text
RegisterObjectMethod(obj, declaration, funcPointer, callConv, ...)
===================================================================
Step 1: 解析目标类型名 → asCDataType (通过 asCBuilder::ParseDataType)
Step 2: DetectCallingConvention() → asSSystemFunctionInterface
Step 3: isPrepared = false
Step 4: 创建 asCScriptFunction(asFUNC_SYSTEM)
Step 5: bld.ParseFunctionDeclaration() → 解析声明字符串
Step 6: 检查名称冲突 / 重复注册
Step 7: 分配 funcId，添加到 objectType->methods[] 和 methodTable
Step 8: 模板类型额外检查 SetTemplateRestrictions()
Step 9: 识别特殊方法（opAssign → beh.copy）
```

---

## RegisterObjectBehaviour (行 2048-2484)

行为注册是最复杂的注册 API，按行为类型分支处理：

| 行为 | 验证 | 存储位置 |
|------|------|---------|
| `asBEHAVE_CONSTRUCT` | 值类型、返回 void | `beh.constructors[]`，无参→`beh.construct` |
| `asBEHAVE_DESTRUCT` | 值类型、返回 void、无参 | `beh.destruct` |
| `asBEHAVE_FACTORY` | 引用类型、返回 handle | `beh.factories[]`，无参→`beh.factory` |
| `asBEHAVE_LIST_FACTORY` / `LIST_CONSTRUCT` | 1 个 ref 参数 | `beh.listFactory` |
| `asBEHAVE_ADDREF` | 引用类型、返回 void、无参 | `beh.addref` |
| `asBEHAVE_RELEASE` | 同上 | `beh.release` |
| `asBEHAVE_GETREFCOUNT` ~ `RELEASEREFS` | GC 类型 | `beh.gcGetRefCount` 等 |
| `asBEHAVE_TEMPLATE_CALLBACK` | 模板类型 | `beh.templateCallback` |
| `asBEHAVE_GET_WEAKREF_FLAG` | 引用类型 | `beh.getWeakRefFlag` |

每种行为都有严格的返回类型、参数数量、类型标志位验证，注册失败返回描述性错误码。

---

## 其他注册 API

### RegisterObjectProperty (行 1620-1674)

- 解析属性声明字符串 → `asCObjectProperty`
- 验证 byteOffset 在 16 位范围内（VM ADDSi 指令限制）
- 存储到 `objectType->properties[]` 和 `propertyTable`

### RegisterGlobalFunction (行 2846-2930)

- `DetectCallingConvention()` → `asSSystemFunctionInterface`
- `ParseFunctionDeclaration()` 解析声明
- 检查签名重复（`IsSignatureExceptNameAndReturnTypeEqual`）
- 存储到 `registeredGlobalFuncs[]` 和 `registeredGlobalFuncTable`

### RegisterInterface (行 1677-1735)

- 创建 `asCObjectType` with flags `asOBJ_REF | asOBJ_SCRIPT_OBJECT | asOBJ_SHARED`
- size = 0（不可实例化）
- 存储到 `allRegisteredTypes` + `registeredObjTypes`

### RegisterEnum (行 5815-5869)

- 创建 `asCEnumType` with flags `asOBJ_ENUM | asOBJ_SHARED`
- size = 1, alignment = 1
- `RegisterEnumValue()` 添加 `asSEnumValue` 到 `ot->enumValues[]`

### RegisterStringFactory (行 3189-3212)

- 解析数据类型，验证非引用、非 handle
- 设置 `stringType` 和 `stringFactory` 成员
- 所有字符串字面量将被视为 const

---

## 注册通用模式

所有 Register* API 都遵循相同的模式：

1. **`isPrepared = false`** — 强制下次 `CreateContext` 时重新验证
2. **创建临时 `asCBuilder`** — 用于解析声明字符串
3. **`DetectCallingConvention()`** — 检测函数指针的调用约定
4. **名称/类型冲突检查** — `CheckNameConflict` / `GetRegisteredType`
5. **创建函数/类型对象** — 分配 ID，添加到引擎全局表
6. **模板处理** — `SetTemplateRestrictions()` 限制子类型

---

## 小结

- 类型注册是 C++ → AS 的单向管道，所有 API 都在引擎 `asCScriptEngine` 上调用
- 三层类型体系：`asCDataType`（编译期值语义）→ `asCTypeInfo`（引用计数基类）→ `asCObjectType`（完整描述）
- 行为注册（`RegisterObjectBehaviour`）是最复杂的 API，按 12 种行为类型分支验证
- 每次注册都设置 `isPrepared = false`，确保 `PrepareEngine()` 在下次使用时重新验证
- [UE++] flags 拓宽为 `asQWORD`，`shadowType`/`accessSpecifiers` 为 UE 扩展成员
