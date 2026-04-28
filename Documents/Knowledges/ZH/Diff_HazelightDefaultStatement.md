# Diff_HazelightDefaultStatement — `default` 语句实现与 Hazelight 引擎的偏离分析

> **所属前缀**: Diff_
> **关注层面**: 当前项目（独立插件）与 Hazelight 引擎集成方案在 `default` 语句实现上的差异比对
> **关联文档**: `Syntax_DefaultStatement.md`（实现原理）、`Plan_DefaultStatementHazelightParity.md`（补足计划）
> **对照路径**: `AgentConfig.ini` 中 `References.HazelightAngelscriptEngineRoot`（默认 `K:\UnrealEngine\UEAS`）
>   - 插件层：`Engine/Plugins/Angelscript/Source/AngelscriptCode/`
>   - AS 内核：`Engine/Plugins/Angelscript/Source/ThirdParty/AngelscriptLibrary/source/`

---

## 一、整体一致的核心机制

下列实现两处**完全一致**或仅有防御性差异，无需补足：

| 模块 | 状态 |
|------|------|
| `ProcessDefaults`（预处理器拼接 `DefaultsCode` 字符串） | 100% 一致；当前项目仅多一处 `if (!Chunk.ClassDesc.IsValid()) return;` 防御性检查 |
| `FDefaultsCode` 结构与 `Chunk.Defaults` 收集 | 完全一致 |
| AS 内核 `as_builder.cpp` 收集 `snClassDefaultStatement` 并调用 `AddInitDefaultsFunction` | 完全一致 |
| `asCCompiler::CompileDefaultStatements` 重新解析为字节码 | 完全一致 |
| `ExecuteDefaultsFunctions` 沿继承链祖→父→子倒序执行 | 完全一致 |
| `BuildFunctionDeclaration` / `LastArgumentWithoutDefault` 算法 | 完全一致 |
| `CPP_Default_<ParamName>` meta 读取与反向写回 | 完全一致 |
| 各 `Bind_*.cpp` 类型转换接口（`UnrealToAngelscript` / `AngelscriptToUnreal`） | 完全一致 |
| `IsDefinitionEquivalent` 不比较 `DefaultValue` 的设计 | 完全一致 |
| 路径 ① 热重载触发 `FullReloadSuggested` 的策略 | 完全一致 |

---

## 二、关键设计差异

### 差异 ① — `__WorldContext` 暴露方式：变量 vs 函数

| 实现层 | Hazelight | 当前项目 |
|-------|-----------|---------|
| AS 全局符号 | `BindGlobalVariable("UObject __WorldContext", &FAngelscriptManager::CurrentWorldContext)` | `BindGlobalFunction("UObject __WorldContext()", []() -> UObject* { return FAngelscriptEngine::TryGetCurrentWorldContextObject(); })` |
| `ArgumentDefaults[i]` 注入值 | `"__WorldContext"`（变量引用） | `"__WorldContext()"`（函数调用，带括号） |
| `hiddenArgumentDefault` 写入值 | `"__WorldContext"` | `"__WorldContext()"` |
| 涉及源码 | `Bind_UWorld.cpp:34`、`Helper_FunctionSignature.h:233/445` | `Bind_UWorld.cpp:34`、`Helper_FunctionSignature.h:284/513` |

**意图分析**：当前项目把 WorldContext 从全局变量改为全局函数，可能是为了：
- 避免 Hazelight 直接暴露 `FAngelscriptManager::CurrentWorldContext` 这种全局 mutable 状态指针
- 让线程安全 / 上下文切换由 `TryGetCurrentWorldContextObject()` 内部统一管理
- 支持失败时返回 `nullptr` 而不是裸指针

**结论**：脚本侧不可见，文档与实际行为一致，**不打算追平**。

---

### 差异 ② — `AngelscriptPropertyFlags` 扩展位（**当前项目采用插件化替代**）

| 标志 | Hazelight | 当前项目 |
|------|-----------|---------|
| `APF_RuntimeGenerated` | ✅ `AddFunctionArgument` 中 `NewProperty->AngelscriptPropertyFlags \|= APF_RuntimeGenerated` | ✅ 通过 `IsAngelscriptGenerated(const FProperty*)` 查询替代 |
| `APF_WorldContext` | ✅ `AddFunctionArgument` 中给 WorldContext 隐式参数打 `APF_WorldContext` | ✅ 通过 `IsAngelscriptWorldContextProperty(const FProperty*)` 查询替代 |
| `AngelscriptPropertyFlags` 字段本身 | ✅ Hazelight 在 UE 引擎 `FProperty` 中加入新字段 | ❌ 当前项目无法修改引擎核心 |

**根因**：Hazelight 是**引擎集成**方案，可以直接给 `FProperty` 加字段；当前项目目标是**独立插件**，无法修改 `Engine/Source/Runtime/CoreUObject/Public/UObject/UnrealType.h`。这是**架构性差异**，无法平移补足，只能用其他机制（如外挂 TMap、UProperty meta）替代。

**潜在影响**：
- 失去了"该 FProperty 是 AS 运行时生成的"快速判断能力，调用方只能通过 outer 类型 `Cast<UASFunction>` 间接判断
- WorldContext 参数失去了快速识别标志，目前依赖 `Function->GetMetaData(NAME_Signature_WorldContext)` 反复查询

**结论**：架构性差异，**不能直接平移**，需要走替代方案。详见 `Plan_DefaultStatementHazelightParity.md` 阶段 P2。

---

### 差异 ③ — AS 内核两个 default 安全 trait（**已补足**）

Hazelight 在 `as_tokendef.h` 中定义、在 `as_parser.cpp` / `as_builder.cpp` / `as_compiler.cpp` 中使用的两个修饰符：

| Trait | Token | 用途 | 当前项目 |
|-------|-------|------|---------|
| `asTRAIT_UNSAFE_DURING_CONSTRUCTION` | `unsafe_during_construction` | 标记函数在 `__InitDefaults` / 构造函数中调用是不安全的，AS 编译器会在调用点报 `Function ... is unsafe during construction and cannot be called from defaults` | ✅ 已补足 |
| `asTRAIT_DEFAULTS_ONLY` | `defaults` | 标记函数**只能**在 `default` 语句 / default-access 上下文中调用 | ✅ 已补足 |

源码对照（`as_compiler.cpp`）：

```cpp
// Hazelight 在每个函数调用编译时检查
if ((m_isInitDefaults || ((m_isConstructor || m_isDefaultConstructor)
        && (outFunc->objectType->GetFlags() & asOBJ_REF)))
    && descr->traits.GetTrait(asTRAIT_UNSAFE_DURING_CONSTRUCTION))
{
    asCString msg;
    msg.Format("Function %s is unsafe during construction and cannot be called from defaults",
        descr->name.AddressOf());
    Error(msg, ctx->exprNode);
}
```

**潜在影响**：
- 用户在 `default` 语句或构造函数中调用了不安全的 API（如某些访问 World 的函数）时，**Hazelight 会编译期报错**，当前项目**只会运行时崩溃或行为未定义**
- 用户无法用 `defaults` 修饰符显式标注"此函数只在 default 上下文使用"

**结论**：已按 Hazelight 语义补足。注意当前 fork 已将 `0x1000000` 用于 `asTRAIT_EXPLICIT`，因此 `asTRAIT_UNSAFE_DURING_CONSTRUCTION` 使用新的空闲 bit，未直接复用 Hazelight 位值。

---

### 差异 ④ — `CallableWithoutWorldContext` 新 meta（**当前项目独有**）

| Meta | Hazelight | 当前项目 |
|------|-----------|---------|
| `OptionalWorldContext` | ✅ | ✅ |
| `CallableWithoutWorldContext` | ❌ | ✅ |

源码（`Helper_FunctionSignature.h:515`）：

```cpp
if (!Function->HasMetaData(NAME_OptionalWorldContext)
 && !Function->HasMetaData(NAME_CallableWithoutWorldContext))   // ← 当前项目新增
    ScriptFunction->traits.SetTrait(asTRAIT_USES_WORLDCONTEXT, true);
```

**意图**：UE 5.7+ 引入的新约定，比 `OptionalWorldContext` 更严格——后者仍占用 trait 槽位但允许缺省，前者则完全不参与 WorldContext 推断。当前项目走在 Hazelight 前面。

**结论**：当前项目针对 UE 5.7 适配的**正向扩展**，无需调整。

---

### 差异 ⑤ — `AngelscriptManager.cpp` 与 `AngelscriptEngine.cpp` 的拆分

| 项 | Hazelight | 当前项目 |
|----|-----------|---------|
| 顶级 manager 单例 | `FAngelscriptManager`（`AngelscriptManager.h/cpp` 独立文件） | `FAngelscriptEngine`（合并到 `AngelscriptEngine.h/cpp`） |
| `CurrentWorldContext` 全局 | `FAngelscriptManager::CurrentWorldContext`（直接 mutable 全局） | `FAngelscriptEngine::TryGetCurrentWorldContextObject()`（封装函数） |
| `StaticNames` 静态名字表 | `FAngelscriptManager::StaticNames[]` 直接索引 | `FAngelscriptEngine::TryGetStaticName(Index, OutName)` 安全访问 |

**意图**：当前项目把 Manager / Engine 合并以减少类层级；同时把所有全局 mutable 状态封装为受控 API，方便后续做线程隔离或多实例化。

**结论**：纯架构差异，对外行为一致，**不打算追平**。

---

## 三、与上游 AngelScript v2.38 的关系

差异 ③ 中的两个 trait（`unsafe_during_construction` / `defaults`）需要回查 `Reference\angelscript-v2.38.0` 来判断：
- 是 **Hazelight 私有扩展**（→ 补足是产品取舍问题）
- 还是 **已被 AS 上游接收**（→ 应跟进选择性 backport）

参考 `Documents/Guides/AngelscriptForkStrategy.md` 描述的"选择性吸收"策略，这是后续 AS 2.38 backport 需要扫描的清单之一。

---

## 四、差异结论汇总

| 编号 | 差异主题 | 处理决策 | 备注 |
|------|---------|---------|------|
| ① | `__WorldContext` 变量 vs 函数 | 不追平 | 当前项目设计更优 |
| ② | `AngelscriptPropertyFlags` 扩展位 | 已走插件化替代方案 | 通过 `UASFunction` / `UASClass` 查询 API 替代引擎字段 |
| ③ | `unsafe_during_construction` + `defaults` 两个 AS 内核 trait | **已补足** | 见 `Plan_DefaultStatementHazelightParity.md` |
| ④ | `CallableWithoutWorldContext` meta | 当前项目独有 | UE 5.7 适配正向扩展 |
| ⑤ | `FAngelscriptManager` vs `FAngelscriptEngine` 拆分 | 不追平 | 当前项目设计更聚合 |

**总体判断**：核心 default 语义路径（预处理器分块 → AS 内核生成 `__InitDefaults` → 继承链倒序执行）与 Hazelight **完全一致**。差异集中在三类：
1. **架构性差异**（②⑤）：受"独立插件不能改引擎"的约束，不可直接平移
2. **设计改进差异**（①④）：当前项目主动改进，不打算回滚
3. **能力缺失差异**（③）：已通过 Hazelight 语义 backport 补足

---

## 五、关联资源

- 实现原理：`Documents/Knowledges/ZH/Syntax_DefaultStatement.md`
- 补足执行计划：`Documents/Plans/Plan_DefaultStatementHazelightParity.md`
- AS Fork 策略：`Documents/Guides/AngelscriptForkStrategy.md`
- 上游 AS 2.38 参考：`Reference/angelscript-v2.38.0/sdk/angelscript/source/`
- Hazelight 集成参考：`AgentConfig.ini` 中 `References.HazelightAngelscriptEngineRoot`
