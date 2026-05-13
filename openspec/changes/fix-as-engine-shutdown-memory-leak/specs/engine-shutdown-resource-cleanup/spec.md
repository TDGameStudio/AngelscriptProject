## ADDED Requirements

### Requirement: UObject Root References Released on Shutdown

AngelscriptEngine Shutdown MUST remove all owned UASClass/UASStruct/UDelegateFunction/UUserDefinedEnum from GC root set.

#### Scenario: UASClass RemoveFromRoot on Shutdown

- **Given** 一个已完成 Init + Bind + Compile 的 FAngelscriptEngine 实例
- **When** 调用 `Shutdown()` 并持有 owned engine
- **Then** 所有 `OwnerScriptEngine == Engine` 的 UASClass 对象不再是 GC root（`IsRooted() == false`）

#### Scenario: UASStruct RemoveFromRoot on Shutdown

- **Given** 同上
- **When** Shutdown
- **Then** 所有引擎 owned 的 UASStruct 对象不再是 GC root

#### Scenario: UDelegateFunction RemoveFromRoot on Shutdown

- **Given** 同上
- **When** Shutdown
- **Then** 所有引擎 owned Package 内的 UDelegateFunction 对象不再是 GC root

#### Scenario: UUserDefinedEnum RemoveFromRoot on Shutdown

- **Given** 同上
- **When** Shutdown
- **Then** 所有引擎 owned Package 内的 UUserDefinedEnum 对象不再是 GC root

### Requirement: Global Static Containers Cleared on Shutdown

AngelscriptEngine Shutdown MUST clear all global static containers that hold engine-scoped references to prevent dangling pointers.

#### Scenario: GBlueprintEventsByScriptName Cleared on Shutdown

- **Given** 引擎已完成 bind（`Bind_BlueprintEvent` 已填充全局 map）
- **When** Shutdown
- **Then** `GBlueprintEventsByScriptName` 为空

#### Scenario: AngelscriptGameplayTagsLookup Cleared on Shutdown

- **Given** 引擎已注册 gameplay tags
- **When** Shutdown
- **Then** `AngelscriptGameplayTagsLookup` 为空

### Requirement: Multi-Cycle Memory Stability

Multiple consecutive engine lifecycles MUST NOT cause unbounded memory growth from retained UObject roots.

#### Scenario: Multi-Cycle Memory Growth Bounded

- **Given** 连续执行 N 次 (N >= 3) 完整的 Init → Shutdown 周期
- **When** 每次 Shutdown 后观察进程内存
- **Then** 每周期内存增长不超过首次周期增长的 2 倍（排除 FName 累积）

## Testing Requirements

- **Target test layer**: Runtime CppTests / GC theme
- **Automation prefix**: `Angelscript.TestModule.GC.EngineShutdownCleanup.*`
- **Recommended harness**: 直接 `FAngelscriptEngine` Init/Shutdown
- **Verification**: `Tools\RunTests.ps1 -Group GC`
