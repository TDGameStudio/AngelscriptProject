## Context

当前工作区已经发生关键命名/层级变化：

```cpp
class UAngelscriptSubsystem : public UEngineSubsystem, public FTickableGameObject
```

也就是说，`UAngelscriptSubsystem` 现在是 engine 级 subsystem，并且保留了原 `UAngelscriptEngineSubsystem` 的 owner 逻辑：

```text
UAngelscriptSubsystem
  - OwnedEngine
  - PrimaryEngine
  - EnsurePrimaryEngineInitialized()
  - ReleasePrimaryEngine()
  - Get()
  - editor/commandlet bootstrap gate
```

同时，native runtime 管理类曾经仍然存在于 `UAngelscriptSubsystem` 的 game-instance 级实现中，并且能 own engine：

```text
UAngelscriptSubsystem as UGameInstanceSubsystem
  - OwnedEngine
  - PrimaryEngine
  - GetCurrent()
  - HasAnyTickOwner()
  - if no current engine, create and initialize OwnedEngine
  - tick PrimaryEngine while game instance is alive
```

这造成的主要架构问题是：`FAngelscriptEngine` 的权威 owner 不唯一。`UAngelscriptSubsystem` 的名字和继承层级已经表达“engine 级主入口”，但旧 game-instance 级实现仍然能创建、push、tick、shutdown 另一个 engine。

## Goals / Non-Goals

**Goals:**

- 明确 `UAngelscriptSubsystem` 是 engine 级主 subsystem，也是 `FAngelscriptEngine` 的唯一权威 owner。
- 删除 native `UAngelscriptGameInstanceSubsystem`。
- 让 `FAngelscriptEngine::TryGetCurrentEngine()` 优先从 `UAngelscriptSubsystem` 获取当前 engine，而不是依赖 game-instance ambient lookup。
- 保留 `UScriptGameInstanceSubsystem`，它是脚本继承用的 `UGameInstanceSubsystem` 基类，不是本次删除目标。
- 保持 editor、commandlet、PIE/runtime、automation test 的初始化和关闭路径可验证。

**Non-Goals:**

- 不引入 `FAngelscriptExecutionContext`。
- 不恢复 `UAngelscriptEngineSubsystem` 旧类名。
- 不把 coverage/debug/StaticJIT/crash snapshot 迁回全局查找；这些仍应走 engine extension 或明确 owner。
- 不一次性迁移所有 `FAngelscriptEngine::Get()` 调用点。

## Current Ownership Problem

当前代码中两个 subsystem 的职责重叠点如下：

| 责任 | `UAngelscriptSubsystem` | `UAngelscriptGameInstanceSubsystem` |
|---|---|---|
| 持有 `OwnedEngine` | 是 | 是 |
| 暴露 `PrimaryEngine` | 是 | 是 |
| 初始化 engine | 是 | 是 |
| shutdown engine | 是 | 是 |
| push/pop current engine stack | 是 | 是 |
| tick engine | 是 | 是 |
| UE 生命周期 | `UEngineSubsystem` | `UGameInstanceSubsystem` |

如果目标是把 AS runtime 做成插件级可复用 runtime，那么 engine 级 subsystem 应该是唯一权威 owner。native `UAngelscriptGameInstanceSubsystem` 没有脚本继承职责，脚本继承能力由 `UScriptGameInstanceSubsystem` 提供。

## Decisions

### Decision 1: `UAngelscriptSubsystem` 是权威 owner

`UAngelscriptSubsystem` 保留 engine-level owner 字段和生命周期：

```cpp
UPROPERTY()
FAngelscriptEngine OwnedEngine;

FAngelscriptEngine* PrimaryEngine = nullptr;
```

主获取入口为：

```cpp
UAngelscriptSubsystem::Get()->GetEngine()
```

理由：这和类名、`UEngineSubsystem` 生命周期、插件级 extension registry、coverage/debug/static-jit/crash snapshot 的 engine-attached 模型一致。

### Decision 2: 删除 native `UAngelscriptGameInstanceSubsystem`

`UAngelscriptGameInstanceSubsystem` 是 runtime 管理类，不是脚本继承基类。脚本继承 game-instance subsystem 的入口是：

```cpp
class UScriptGameInstanceSubsystem : public UGameInstanceSubsystem, public FTickableGameObject
```

因此 `UAngelscriptGameInstanceSubsystem` 应删除，而不是降级保留。删除时一并移除这些 owner 状态：

```cpp
OwnedEngine
PrimaryEngine
bOwnsPrimaryEngine
bInitialized
ActiveTickOwners
```

对应的 binding/test 里如果只是验证 native `UAngelscriptGameInstanceSubsystem` 可获取，需要删除或改成验证 `UScriptGameInstanceSubsystem` 的脚本继承行为。

### Decision 3: `TryGetCurrentEngine()` 从 engine subsystem 解析

当前 `FAngelscriptEngine::TryGetCurrentEngine()` 仍会通过 `UAngelscriptGameInstanceSubsystem::GetCurrent()` 查 ambient world。新的解析顺序应为：

```text
1. FAngelscriptEngineContextStack::Peek()
2. UAngelscriptSubsystem::Get()->GetEngine()
3. nullptr
```

### Decision 4: Engine subsystem 在 runtime 也创建

最终策略是移除 editor/commandlet gate：

```cpp
return true;
```

理由：删除 game-instance owner 后，runtime 场景不能再依赖 `UGameInstanceSubsystem` 创建 AS engine。`UAngelscriptSubsystem` 作为插件级 engine owner，必须在 editor、commandlet 和 plain runtime 中都可创建；是否编译脚本、扫描磁盘、加载 editor-only 能力仍由 engine 初始化配置和模块边界控制，不由 subsystem 是否存在控制。

### Decision 5: 测试模块保留 test-only game-instance subsystem fixture

`AngelscriptSubsystemBindingsTests.cpp` 仍需要验证 `USubsystemLibrary::GetGameInstanceSubsystem(UClass)` 的 game-instance helper 路径。删除 native runtime manager 后，测试模块新增：

```cpp
class UAngelscriptTestGameInstanceSubsystem : public UGameInstanceSubsystem
```

这个类型只作为 C++ test fixture 存在，不作为 AS 绑定面。脚本测试通过 `UObject ExpectedGameInstanceSubsystem` 和 `UClass GameInstanceSubsystemClass` 验证 helper 返回值，避免把 test-only C++ 类型暴露成脚本 API。`UScriptGameInstanceSubsystem` 的脚本继承能力继续由 `Angelscript.TestModule.GameInstanceSubsystem` 覆盖。

## Remove GameInstance Subsystem Impact

直接删除 `UAngelscriptGameInstanceSubsystem` 会影响：

- Runtime:
  - `AngelscriptSubsystem.cpp` 里的 `HasAnyTickOwner()` tick gate。
  - `AngelscriptEngine.cpp` 里的 `IsInitialized()` / `TryGetCurrentEngine()` ambient lookup。
  - `AngelscriptRuntimeModule.cpp` include。
  - `AngelscriptEngine.h` friend 声明。
- Tests:
  - `AngelscriptGameInstanceSubsystemRuntimeTests.cpp` 整组测试删除或重写成 engine subsystem runtime tests。
  - `AngelscriptRuntimeModuleTests.cpp` 的 tick owner 测试需要改成 engine subsystem 独占 tick。
  - `AngelscriptEngineIsolationTests.cpp` 和 shared test acquisition helper 需要移除 `HasAnyTickOwner()` 依赖。
  - `AngelscriptSubsystemBindingsTests.cpp` 使用 test-only `UAngelscriptTestGameInstanceSubsystem` fixture 覆盖 game-instance helper 路径。

这说明移除可行，但不是一个纯删文件操作；需要同时重写 tick/current-engine 语义和测试。

## Proposed Migration Shape

```text
Step 1: 确认 UAngelscriptSubsystem 编译通过
Step 2: 修改 UAngelscriptSubsystem runtime 创建策略
Step 3: 让 TryGetCurrentEngine() 从 UAngelscriptSubsystem 获取 engine
Step 4: 删除 UAngelscriptGameInstanceSubsystem
Step 5: 保留并验证 UScriptGameInstanceSubsystem 脚本继承能力
Step 6: 重写测试和 native subsystem binding expectations
```

## Risks / Trade-offs

- **Runtime bootstrap 风险**: 如果 engine subsystem 仍只在 editor/commandlet 创建，删除 game-instance owner 会导致 runtime 无 engine。缓解：先补 runtime creation tests，再移除 game-instance owner。
- **Tick 语义变化**: 当前 game-instance subsystem 会阻止 engine subsystem tick。删除后 tick owner 变成 engine subsystem 单一来源。缓解：改写 tick tests，验证不会 double tick。
- **Subsystem binding 兼容性**: 脚本测试现在能看到 engine subsystem 和 game-instance subsystem 两类。删除 game-instance subsystem 会改变脚本可见 API。缓解：这是 refactor 目标的一部分，需更新 binding tests。
- **PIE 多 GameInstance 行为**: 如果多个 PIE world 共享同一个 engine，需要确认当前 runtime 本来就是全局 engine 模型。缓解：保留或新增 multi-world tests，验证 engine pointer 一致且 tick 不重复。

## Relationship to Archived Execution Context

`openspec/changes/archive/2026-07-07-refactor-as-execution-context/` 是旧方案，目标也是减少 ambient engine access，但它试图先引入通用 execution context。

当前方向更直接：

```text
先统一 engine ownership 到 UAngelscriptSubsystem
再决定是否还需要 execution context
```

因此本 change 不执行 `FAngelscriptExecutionContext`，也不把它作为当前迁移前置条件。
