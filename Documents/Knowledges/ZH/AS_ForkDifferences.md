# AS_ForkDifferences — Fork 差异清单

> **所属模块**: AS_（AngelScript 引擎内核族）
> **关注层面**: 所有 `[UE++]...[UE--]` 标记的修改分类汇总与设计动机
> **关键源码**: `ThirdParty/angelscript/source/` 全部文件（89 个文件中 ~27 处标记修改）
> **关联文档**:
> 所有 `AS_*.md` 文档 — 各子系统中的 Fork 修改已分别标注
> · `Documents/Guides/AngelscriptForkStrategy.md` — Fork 策略指南
> · `AGENTS.md` — 基版本说明（AS 2.33 + 选择性 2.38 兼容）

---

## 概览

本 Fork 基于 AngelScript **2.33**，通过选择性吸收 2.38 改进和大量 UE 适配修改形成当前版本。所有对原版源码的修改都用 `[UE++]...[UE--]` 注释标记。本文汇总这些修改，按动机分类，为后续的选择性升级和维护提供参考。

---

## 修改分类汇总

### 1. 导出宏重命名（8 处）

**动机**: 将导出宏从原版统一为 `ANGELSCRIPTRUNTIME_API`，匹配 UE Runtime 模块命名。

| 文件 | 类 |
|------|-----|
| `as_scriptengine.h` L64 | `asCScriptEngine` |
| `as_context.h` L60 | `asCContext` |
| `as_objecttype.h` L102 | `asCObjectType` |
| `as_typeinfo.h` L64 | `asCTypeInfo` |
| `as_datatype.h` L61 | `asCDataType` |
| `as_parser.h` L51 | `asCParser` |
| `as_compiler.h` L237 | `asCCompiler` |
| `as_builder.h` L147 | `asCBuilder` |
| `as_bytecode.h` L61 | `asCByteCode` |
| `as_gc.h` L54 | `asCGarbageCollector` |
| `as_generic.h` L50 | `asCGeneric` |
| `as_memory.h` L94 | `asCMemoryMgr` |
| `as_property.h` L129 | `asCGlobalProperty` |
| `as_restore.h` L49 | `asCReader` |
| `as_scriptnode.h` L110 | `asCScriptNode` |
| `as_scriptobject.h` L50 | `asCScriptObject` |
| `as_tokenizer.h` L51 | `asCTokenizer` |
| `as_config.h` L1255-1259 | 默认宏定义 |

### 2. 类型系统拓宽（3 处）

**动机**: 保留 APV2 私有高位标志位。

| 文件 | 修改 | 说明 |
|------|------|------|
| `as_scriptengine.h` L104 | `RegisterObjectType` flags: `asDWORD` → `asQWORD` | 参数拓宽 |
| `as_scriptengine.cpp` L1786 | 同上实现 | 配套修改 |
| `as_typeinfo.h` L172 | `flags` 字段: `asDWORD` → `asQWORD` | 存储拓宽 |

### 3. 语法扩展（5 处）

**动机**: 支持 UE 游戏开发所需的语法特性。

| 文件 | 修改 | 说明 |
|------|------|------|
| `as_tokendef.h` L185-346 | 新增 `ttForeach`, `ttFallthrough`, `ttStruct`, `ttLocal`, `ttAccess`, `ttUnresolvedObject` Token + 大量上下文关键字 | 关键字扩展 |
| `as_parser.cpp` L4740-4859 | `ParseForeach()` / `ParseForeachVariable()` | foreach 语法解析 |
| `as_compiler.cpp` L5611 | `CompileForeachStatement()` | foreach 编译（降级为 opFor* 调用） |
| `as_parser.cpp` L3217-3230 | `IsFuncDecl` 扩展方法修饰符识别 | 支持 12+ 个 UE 修饰符 |
| `as_builder.cpp` L2269 | 允许无 UE shadow metadata 的纯脚本类 | 兼容纯 AS 类 |

### 4. 内存管理适配（3 处）

**动机**: 使用 UE 的 `FMemory::Malloc`/`Free` 替代标准 C 分配器。

| 文件 | 修改 |
|------|------|
| `as_memory.h` L73-77 | `asNEW`/`asDELETE` 宏使用 `FMemory::Malloc`/`Free` |
| `as_memory.cpp` L185-205 | 内存池清理/分配使用 FMemory |
| `as_scriptnode.cpp` L61 | `CreateCopy` 使用 `FMemStackBase` |

### 5. 对象类型扩展（6 处）

**动机**: 支持 UE 类型遮蔽（shadow type）、APV2 属性/方法接口。

| 文件 | 修改 | 说明 |
|------|------|------|
| `as_objecttype.h` L121-127 | `GetMethodByIndex/Name/Decl` 增加 `getVirtual` 重载 | 2.38 兼容 |
| `as_objecttype.h` L130-132 | `GetProperty` 增加 `outIsConst` 参数 | 2.38 兼容 |
| `as_objecttype.h` L150-152 | `AddPropertyToClass` 增加 `isInherited` 参数 | 属性所有权 |
| `as_objecttype.h` L170 | `shadowType` 成员 | UE 类型遮蔽 |
| `as_objecttype.cpp` L636 | `AddPropertyToClass` 带 `isInherited` 实现 | 属性所有权 |
| `as_module.h` L78-90 | `asModuleReferenceUpdateMap` 结构 | 热重载引用更新 |

### 6. 安全性增强（2 处）

**动机**: 防止析构期间的级联释放导致空指针。

| 文件 | 修改 |
|------|------|
| `as_scriptengine.cpp` L956-969 | 析构函数中 `DestroyInternal` 后重新检查 `scriptFunctions[n]` |
| `as_builder.cpp` L6936-6992 | 编辑器相关代码的条件访问检查 |

### 7. 模块/热重载支持（3 处）

**动机**: 支持 UE 编辑器中的脚本热重载。

| 文件 | 修改 |
|------|------|
| `as_module.h` L194-195 | `PreClassData` TMap |
| `as_module.h` L239-240 | `baseModuleName` 字段 |
| `as_module.h` L264-315 | `ReloadState` 枚举、引用更新方法、模块依赖图 |

### 8. UE 字节码指令（12 条，201-212）

**动机**: 脚本对象与 UE 对象系统集成。

| 指令 | 用途 |
|------|------|
| `asBC_FinConstruct` (201) | 构造完成通知 |
| `asBC_DestructScript` (202) | 脚本对象析构 |
| `asBC_CopyScript` (203) | 脚本对象拷贝 |
| `asBC_ResolveObjectPtr` (204) | 对象指针解析 |
| `asBC_FreeNullV8` (205) | 空值释放 |
| `asBC_TrackRef` (206) | 引用跟踪 |
| `asBC_UntrackRef` (207) | 取消引用跟踪 |
| `asBC_ValidateRef` (208) | 引用验证 |
| `asBC_CpyVtoR1` (209) | 变量→寄存器 1 字节 |
| `asBC_SaveReturnValue` (210) | 保存返回值 |
| `asBC_CmpPtrNull` (211) | 指针空比较 |
| `asBC_ThrowException` (212) | 抛出异常 |

### 9. VM/Context 扩展（6 处）

**动机**: 支持调试器、蓝图集成、线程安全。

| 文件 | 修改 |
|------|------|
| `as_context.h` L49 | include `AngelscriptEngine.h` |
| `as_context.h` L56-57 | `asLineCallback` / `asStackPopCallback` 类型别名 |
| `as_context.h` L68 | `MovedToNewThread()` |
| `as_context.h` L109 | `SetReturnIntoValue()` |
| `as_context.h` L121-128 | `SetLoopDetectionCallback`, `SetStackPopCallback`, `GetBlueprintCallstackFrame` |
| `as_context.h` L145 | `DebugFramePtr` |

### 10. 配置组 stub 化（1 处）

**动机**: UE 侧绑定管理替代了原版配置组机制。

| 文件 | 修改 |
|------|------|
| `as_scriptengine.cpp` L5457-5477 | `BeginConfigGroup`/`EndConfigGroup`/`RemoveConfigGroup`/`FindConfigGroupFor*` 全部返回 0 |

### 11. 统一 JIT binding 生命周期

**动机**：让运行时 provider 能在函数编译完成后发布 VM、Raw、Parms 和 UserData 的完整入口集合，并让 `asCScriptFunction` 对替换、卸载与销毁期间的释放负责。

| 表面 | 此 fork 的契约 |
|------|----------------|
| 编译器通知 | `asIJITCompiler::OnFunctionReady(asIScriptFunction*)` |
| 入口发布 | `asIScriptFunction::SetJITBinding(const asSJITFunctionBinding&)` |
| 入口读取 | `GetJITBinding()` 返回完整值快照 |
| 释放 | 原发布 owner 收到 `ReleaseFunctionBinding(Function, Binding)`，且每个非空 binding 恰好一次 |
| 生成边界 | StaticJIT 生成器直接观察已编译模块，不交换引擎的 live compiler |
| 版本策略 | 无 `asEP_JIT_INTERFACE_VERSION`；数值 35 保留为空洞，36 以后的既有属性不重排 |

这不是旧 fork V1 的兼容扩展，也不是原样 backport 上游 V2。旧 `CompileFunction` / `ReleaseJITFunction`、公开 `jitFunction*` 字段、上游 `asIJITCompilerV2` / `SetJITFunction` 都不属于当前 ABI，外部 provider 必须针对这一维护分支重新编译。

---

## 修改统计

| 分类 | 修改处数 | 涉及文件数 |
|------|---------|-----------|
| 导出宏重命名 | 18 | 18 |
| 类型系统拓宽 | 3 | 3 |
| 语法扩展 | 5 | 4 |
| 内存管理适配 | 3 | 3 |
| 对象类型扩展 | 6 | 3 |
| 安全性增强 | 2 | 2 |
| 热重载支持 | 3 | 1 |
| 字节码指令 | 12 条新指令 | 1 (angelscript.h) |
| VM/Context 扩展 | 6 | 1 |
| 配置组 stub | 1 | 1 |
| 统一 JIT 生命周期 | 1 组公开契约 | 5 |
| **合计** | **~65+ 处** | **~25 个文件** |

---

## 小结

- 本 Fork 对原版 AS 2.33 源码有 65+ 处修改，分布在 ~25 个文件中
- 最大的修改类别是导出宏统一（18 处）和语法扩展（foreach/struct/修饰符）
- 类型系统拓宽（`asDWORD` → `asQWORD`）影响面最广，涉及注册 API 和存储层
- 12 条新字节码指令专门服务于 UE 脚本对象生命周期
- 所有修改都用 `[UE++]...[UE--]` 标记，便于后续 3-way merge 升级
