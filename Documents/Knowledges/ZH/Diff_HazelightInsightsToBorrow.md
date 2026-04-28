# Hazelight 引擎中可借鉴的设计点

> 对照路径：`AgentConfig.ini` 中 `References.HazelightAngelscriptEngineRoot`（默认 `K:\UnrealEngine\UEAS`），核心位于 `Engine/Plugins/Angelscript/Source/AngelscriptCode/`。
>
> 本文档**仅汇总值得借鉴的设计点**，不重复 `Diff_HazelightDefaultStatement.md` 中已记录的细节差异。可执行任务统一收敛到 `Documents/Plans/Plan_*HazelightParity.md`。

---

## 一、总体评估

经过对预处理器、Bind 框架、AS 内核、热重载、StaticJIT、Testing、ClassGenerator 等核心子系统的横向对比：

- **当前项目在多数维度已与 Hazelight 持平或领先**：模块拆分更清晰、Bind 数量更多（+13 个，含 GAS / EnhancedInput / SystemTimers）、Test 基础设施更完善、新增了 BlueprintImpact / Dump / CodeCoverage / 报错诊断等独有子系统。
- **真正值得借鉴的差距集中在三个方向**：
  1. **AS 编译期安全检查**（trait 类）— Hazelight 用编译期错误防住运行期崩溃
  2. **UE 标准 Meta 自动转译**— Hazelight 把若干 UE 标准 meta 直接桥接到 AS trait
  3. **几个"小而美"的 API 入口** — 个别 helper 类型/接口设计精良，可直接搬过来

下面分类详述。

---

## 二、AS 编译期安全检查（高价值，建议补足）

这一类借鉴**不依赖修改 UE 引擎核心**，纯粹是 AS 内核的 trait 与 token 移植。受益是把"运行期崩溃 / 行为未定义"提升到"编译期报错"。

### 2.1 `unsafe_during_construction` + `UnsafeDuringActorConstruction` Meta 自动转译

| 维度 | Hazelight | 当前项目 |
|------|-----------|---------|
| AS Token | `UNSAFE_DURING_CONSTRUCTION_TOKEN = "unsafe_during_construction"` | ✅ 已补足 |
| AS Trait | `asTRAIT_UNSAFE_DURING_CONSTRUCTION` | ✅ 已补足（使用当前 fork 空闲 bit，未复用 Hazelight `0x1000000`） |
| 编译期检查 | `as_compiler.cpp` 在 `__InitDefaults` / 构造函数调用点报错 | ✅ 已补足 |
| **UE Meta 自动桥接** | `Function->HasMetaData("UnsafeDuringActorConstruction")` → 自动 SetTrait | ✅ 已补足 |

**为什么值得借鉴**：UE 引擎本身有大量 UFUNCTION 标注了 `meta = (UnsafeDuringActorConstruction = "true")`，例如所有访问 World、其他 Actor、物理系统的函数。Hazelight 让这些函数**在 AS 中被自动识别为不可在 default / 构造期调用**，用户写错时立刻收到编译期错误：

```
Function GetWorld is unsafe during construction and cannot be called from defaults
```

而当前项目只能在运行时触发崩溃或获取空指针。这是一个**对用户体验影响很大但实现成本很低**的差距。

### 2.2 `defaults` 修饰符（语言一致性）

```cpp
// 配套的另一个 trait：
const char * const DEFAULTS_TOKEN = "defaults";
```

标记函数**只能在 default 语句中调用**。配合上面的 `unsafe_during_construction`，形成完整的"构造期安全约束体系"。

### 2.3 `accept_temporary_this` Meta 自动转译

| 维度 | Hazelight | 当前项目 |
|------|-----------|---------|
| AS Token `ACCEPT_TEMPORARY_TOKEN` | ✅ | ✅（解析器层已有） |
| **UE Meta 自动桥接** `ScriptAllowTemporaryThis` → `accept_temporary_this` | ✅ `Helper_FunctionSignature.h:350` | ✅ 已补足 |

源码对照（Hazelight）：

```cpp
if (Function->HasMetaData(NAME_ScriptAllowTemporaryThis))
    Declaration += TEXT(" accept_temporary_this");
```

当前项目已补足 `Helper_FunctionSignature.h` 中"读 UE meta → 自动追加修饰符"的桥接逻辑。`accept_temporary_this` 的追加位置在返回值相关 `no_discard` / `allow_discard` 逻辑之外，因此无返回值函数也可以通过 UFUNCTION meta 启用。

---

## 三、UE 标准 Meta → AS Trait 自动桥接（设计模式可借鉴）

Hazelight 一个反复出现的优雅设计是：**让 UE 引擎已经存在的标准 meta 直接驱动 AS 行为，不发明新约定**。除了上面 §2 的几个，这种模式还应用在：

| UE 标准 Meta | Hazelight 自动桥接到 AS |
|-------------|------------------------|
| `DeprecatedFunction` + `DeprecationMessage` | `asTRAIT_DEPRECATED` + `deprecationMessage`（AS 编译器警告） |
| `UnsafeDuringActorConstruction` | `asTRAIT_UNSAFE_DURING_CONSTRUCTION`（AS 编译器报错） |
| `ScriptAllowTemporaryThis` | `accept_temporary_this` 修饰符 |
| `ScriptNoDiscard` / `ScriptAllowDiscard` | `no_discard` / `allow_discard` 修饰符 |
| `BlueprintProtected` | AS 访问控制 |

**当前项目已实现**：`Deprecated*`、`ScriptNoDiscard`、`ScriptAllowDiscard`、`BlueprintProtected`。

**当前项目状态**：`UnsafeDuringActorConstruction`、`ScriptAllowTemporaryThis` 已完成桥接。

**借鉴价值**：
- 这种**单向数据流**（UE Meta → AS）让用户**只用 UE 习惯的写法**就能享受 AS 编译期检查，零学习成本
- 当前项目可以在 `Helper_FunctionSignature.h` 现有的 `static const FName NAME_*` 列表中扩展，桥接逻辑都是 5~10 行代码
- 还可以扩展到更多 UE meta：例如 `BlueprintAuthorityOnly`、`BlueprintCosmetic`、`CallInEditor` 等

---

## 四、`asTRAIT_USES_WORLDCONTEXT` 用法值得对齐复核

虽然两边都有这个 trait，但 Hazelight 在 `Helper_FunctionSignature.h:447` 的处理逻辑略有不同：

```cpp
// Hazelight
ScriptFunction->hiddenArgumentDefault = "__WorldContext";   // 不带括号（变量引用）
if (!Function->HasMetaData(NAME_OptionalWorldContext) && !Function->HasMetaData(NAME_CallableWithoutWorldContext))
    ScriptFunction->traits.SetTrait(asTRAIT_USES_WORLDCONTEXT, true);
```

我们项目用 `"__WorldContext()"`（带括号，函数调用）— 之前 `Diff_HazelightDefaultStatement.md` §二.差异① 已经记录这是有意设计改进，**不需要回退**。

**借鉴角度**：但我们应该**核对 trait 用法本身**——例如 `asTRAIT_USES_WORLDCONTEXT` 在 AS 内核哪些路径上被消费？是否也参与了某种编译期校验？这块需要和 §二的 trait 补足一起调研。

---

## 五、几个"小而美"的具体设计

### 5.1 错误消息中包含函数名

Hazelight 在 `as_compiler.cpp` 的 trait 检查报错里会带上函数名：

```cpp
asCString msg;
msg.Format("Function %s is unsafe during construction and cannot be called from defaults",
    descr->name.AddressOf());
Error(msg, ctx->exprNode);
```

这是个很小的细节但用户体验显著。当前项目的报错系统（`Arch_ErrorDiagnostics.md`）可以复核同类错误是否都有"携带上下文标识符"的习惯。

### 5.2 `IntegrationTestTerminator` / `LatentAutomationCommandClientExecutor`

两边都有这两个测试基础设施类。值得对照看 Hazelight 在网络/集成测试场景下的边界条件处理逻辑：

| 文件 | 用途 |
|------|------|
| `Testing/IntegrationTestTerminator.cpp` | 集成测试终止/清理 |
| `Testing/LatentAutomationCommandClientExecutor.cpp` | 客户端 Latent 命令执行 |
| `Testing/Network/` | 网络相关测试 helper |

我们项目都已有，但 Hazelight 多一些经过实战的边界 case 处理可能值得 diff。

### 5.3 `AngelscriptCodeCoverageTests.cpp` 的覆盖率自身测试

Hazelight 的 `Tests/` 目录下只有一个文件 `AngelscriptCodeCoverageTests.cpp`——这是一个**非常窄的关注点**：用 AS 测试 AS 代码覆盖率系统本身。

```
K:\...\AngelscriptCode\Private\Tests\AngelscriptCodeCoverageTests.cpp
```

我们项目有完整的 `Tests/` + `AngelscriptTest` 模块，但**专门给 CodeCoverage 写的"自测试"是否覆盖完整**值得回头核对 — 这是覆盖率系统本身可信度的最后一道屏障。

---

## 六、**当前项目领先 Hazelight 的部分**（不应回退）

为了完整性，记录我们已经做得更好的部分，避免后续重构误判：

| 项目 | 当前项目 | Hazelight |
|------|---------|-----------|
| Bind 数量 | 124 | 111 |
| GAS / EnhancedInput / SystemTimers Bind | ✅ 独立 Bind 文件 | ❌ 缺失 |
| Dump 子系统（State Dump + 27+ CSV 表） | ✅ | ❌ |
| BlueprintImpact Commandlet | ✅ | ❌ |
| 报错诊断专题（`Arch_ErrorDiagnostics`） | ✅ 规划中 | ❌ |
| `AngelscriptBindExecutionObservation` | ✅ 测试观测器 | ❌ |
| `AngelscriptUhtOverloadCoverageTypes` | ✅ UHT 重载覆盖类型 | ❌ |
| `FAngelscriptEngine::TryGetStaticName` 安全封装 | ✅ | ❌ 直接 `StaticNames[]` 索引 |
| `__WorldContext()` 函数化封装 | ✅ | ❌ 全局变量裸暴露 |
| `FAngelscriptManager` / `FAngelscriptEngine` 合并 | ✅ 单一聚合点 | ❌ 拆分两层 |

---

## 七、借鉴优先级与执行规划

| 优先级 | 借鉴项 | 实施难度 | 收益 | 落地路径 |
|--------|--------|---------|------|---------|
| **高** | `UnsafeDuringActorConstruction` Meta → `asTRAIT_UNSAFE_DURING_CONSTRUCTION` 完整桥接 | 中（AS 内核 4 处 + Helper_FunctionSignature.h 1 处） | 高（防住大量 UE 标准 API 误用） | 已完成 |
| **高** | `defaults` 修饰符 token + trait | 中（与上同时移植，配套出现） | 中（语言一致性） | 同上 |
| **中** | `ScriptAllowTemporaryThis` Meta → `accept_temporary_this` 自动追加 | 低（`Helper_FunctionSignature.h` 加 3 行） | 中 | 已完成 |
| **中** | 扩展更多 UE Meta → AS Trait 桥接（`BlueprintAuthorityOnly` / `BlueprintCosmetic` / `CallInEditor` 等） | 低 | 中 | **新建独立 Plan**（建议） |
| **中** | 错误消息携带函数名/上下文标识符的统一审计 | 低 | 中 | 纳入 `Arch_ErrorDiagnostics` 写作 |
| **低** | CodeCoverage 自测试用例对齐 | 低 | 低 | `Test_TopicClusters.md` 中标记 |
| **信息** | `IntegrationTestTerminator` 等测试基础设施边界 case 复核 | 低 | 低 | Diff 单文件比对，按需吸收 |

---

## 八、关联文档

- `Documents/Knowledges/ZH/Diff_HazelightDefaultStatement.md` — default 语句的细化差异
- `Documents/Plans/Plan_DefaultStatementHazelightParity.md` — default 相关补足执行计划
- `Documents/Guides/AngelscriptForkStrategy.md` — Fork 策略与选择性吸收原则
- `Documents/Knowledges/ZH/AS_ForkDifferences.md` — AS 内核 Fork 差异清单（待写）
- `Reference/README.md` — 外部参考仓库索引

---

## 九、修订记录

| 版本 | 日期 | 内容 |
|------|------|------|
| v1.0 | 2026-04-28 | 首版：基于 default 语句对比扩展到全插件视角，识别 7 项可借鉴点 |
