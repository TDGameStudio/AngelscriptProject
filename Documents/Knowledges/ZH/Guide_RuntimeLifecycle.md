# Guide_RuntimeLifecycle — 脚本引擎初始化、编译、执行全流程（用户视角）

> **所属前缀**: Guide_（实践指南族）
> **适用读者**: 已经会写一两个 `.as` 脚本、想搞清楚"我的代码到底在什么时候被加载/编译/执行"的脚本作者；不面向插件维护者。
> **前置知识**: 看完 `Documents/Knowledges/ZH/Guide_QuickStart.md` 的 16 个案例，能跑通 BeginPlay / Tick；了解 UE 的 Actor / Subsystem 生命周期基本概念。
> **关联 Knowledges**:
> `Documents/Knowledges/ZH/Guide_QuickStart.md` —— 第一个 .as 脚本与示例索引
> · `Documents/Knowledges/ZH/Guide_SyntaxFeatures.md` —— AS 语法特色速览
> · `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md` —— 维护者视角的引擎生命周期编排（深入阅读）
> · `Documents/Knowledges/ZH/RT_HotReload.md` —— SoftReload / FullReload 决策细节（深入阅读）
> · `Documents/Knowledges/ZH/Type_Preprocessor.md` —— 预处理器与 `#include` / `import` 规则
> · `Documents/Knowledges/ZH/Type_ClassGeneration.md` —— 脚本类如何变成 UClass

---

## 概览

本文聚焦一个核心问题：**作为 .as 脚本的作者，我写的代码究竟在什么时刻被加载、编译和执行？我能在哪些回调点插入逻辑？编译挂了我怎么知道？保存文件后引擎做了什么？**

`Guide_QuickStart.md` 教你怎么写第一个 Actor；本文回答的是"它放在那里，会怎么被'活'起来"——也就是把"打开编辑器 → 我的 BeginPlay 被调用 → 我修改代码 → 保存即生效"这一串看不见的脉络可视化。

```text
                  你写的 .as 文件，从磁盘到运行的四段旅程

  ┌──────────────────────────────────────────────────────────────────────┐
  │ ① 引擎启动期（每次开编辑器/进游戏 1 次）                              │
  │   UE 启动 → Angelscript 插件被装载 → 扫描所有 ScriptRoot 下 *.as     │
  │   → 全量预处理 + 编译 + 生成 UClass → 你的类出现在 ContentBrowser    │
  │   完成时机：编辑器主界面出现之前                                      │
  └────────────────────────────────┬─────────────────────────────────────┘
                                   ▼
  ┌──────────────────────────────────────────────────────────────────────┐
  │ ② 关卡 / Actor 生成期（每次打开关卡或 Spawn 1 次）                    │
  │   关卡加载 → 关卡里的 Actor 实例被构造 → ConstructionScript 触发     │
  │   → 编辑器视图里看得到，但 Tick 还没启动                              │
  └────────────────────────────────┬─────────────────────────────────────┘
                                   ▼
  ┌──────────────────────────────────────────────────────────────────────┐
  │ ③ Play 期（点击 Play / 进入 PIE / 启动游戏后）                        │
  │   World 进入 BeginPlay → 你的 BeginPlay() 被调用 → 进入 Tick 循环    │
  │   → Tick(DeltaTime) 每帧调用 → EndPlay 在退出 PIE / 销毁时调用       │
  └────────────────────────────────┬─────────────────────────────────────┘
                                   ▼
  ┌──────────────────────────────────────────────────────────────────────┐
  │ ④ 热重载期（任何时候你按 Ctrl+S 保存 .as 文件）                       │
  │   文件变更被监听 → 100ms 内合并批量改动 → 重新编译变更的模块         │
  │   → 软重载（SoftReload）=函数体变化，立即生效，PIE 不打断           │
  │   → 硬重载（FullReload）=结构变化（增删 UPROPERTY 等），需退出 PIE   │
  └──────────────────────────────────────────────────────────────────────┘
```

后续章节按 **ScriptRoot / 启动期 / 关卡期 / Play 期 / Hot Reload / PIE 与主编辑器 / Cooked / 调试与排错 / 速查** 的顺序展开。

---

## 一、ScriptRoot：你的 .as 放在哪、何时被扫描

### 1.1 ScriptRoot 是什么

引擎启动时，会从一组**ScriptRoot 目录**里递归找所有 `.as` 文件。**只要 .as 落在 ScriptRoot 下，就会被自动发现并编译，不需要任何手动注册**。

| ScriptRoot | 路径 | 说明 |
|------|------|------|
| 项目根 | `<Project>/Script/` | 99% 的 game 端脚本都放这里 |
| 引擎根（可选） | `<Engine>/Script/` | 仅在引擎本身想自带脚本时才有 |
| 插件根 | `Plugins/<Any>/Script/` | 任何插件如果带 `Script/` 都会被一并扫到 |

本项目的 `Script/` 目录布局已经在 `Guide_QuickStart.md` 给过；本文只强调"ScriptRoot = 引擎搜索 .as 的入口集合"。

### 1.2 何时被扫描

ScriptRoot 在**引擎启动一次性扫描**——具体时机是 §三 的"InitialCompile"阶段。也就是说：

- 你启动编辑器**之前**新增的 `.as` 文件，启动后会自动被发现
- 启动**之后**新增的 `.as` 文件，会通过文件监听走 Hot Reload 进来（详见 §六）
- **不需要重启编辑器**就能看到新加的脚本

### 1.3 一个常见误区：把 .as 放错地方

下面这些位置**不是** ScriptRoot，引擎不会扫描：

```text
错误位置                                 正确位置
────────────────────────────────────     ────────────────────────────
<Project>/Source/MyScripts/Foo.as   ❌   <Project>/Script/Foo.as       ✓
<Project>/Content/Scripts/Foo.as    ❌   <Project>/Script/Foo.as       ✓
任意桌面 / 临时目录                  ❌   ScriptRoot 之内              ✓
```

如果你写了一个 `.as` 文件但 ContentBrowser 里根本看不到对应类，第一件事是**确认它是否落在某个 ScriptRoot 下**。

---

## 二、`#include` vs `import`：脚本之间怎么互相引用

ScriptRoot 内部的 .as 文件之间默认**互不可见**——AngelScript 不会自动把所有同目录文件 union 到一起。如果你的 `WeaponBase.as` 想被 `Pistol.as` 继承或引用，要看模块装载策略：

```angelscript
// Pistol.as
#include "WeaponBase.as"        // 文本性 #include，把另一个文件嵌入到当前编译单元

class APistol : AWeaponBase     // 这下就能继承了
{
    UPROPERTY()
    int Ammo = 12;
};
```

```angelscript
// 或者用 import（默认推荐，由预处理器/编译器解析依赖）
import WeaponBase;

class ARifle : AWeaponBase
{
    UPROPERTY()
    int Ammo = 30;
};
```

两条路径的差别在内部链路上很大（`#include` 走预处理器文本展开、`import` 走显式模块依赖图），**对用户来说的实用差别**：

- `#include` 永远有效，不挑模块装载模式
- `import` 写起来更简洁，但要求另一个文件确实是一个独立模块（即不依赖 `#include` 注入的代码段）

详细规则见 `Type_Preprocessor.md` §五；日常脚本写 `import ModuleName;` 就好。

---

## 三、引擎启动期：你的 .as 在主菜单出现之前发生了什么

引擎从启动到主界面的几秒钟里，与 .as 作者强相关的有 4 个阶段：

```text
你看到 UE 启动画面 ──► 引擎主菜单出现 ──► 编辑器可用
        │                                          ▲
        │                                          │
        ▼                                          │
   Angelscript 插件装载 → Bootstrap → InitialCompile (★ 一次性大事件)
                                          │
                                          ▼
                                  你的 .as 全部被扫描、预处理、编译
                                  你声明的所有 class : AActor 全都注册到反射系统
```

### 3.1 InitialCompile：一次性大事件

`InitialCompile` 是**整个进程内只跑一次**的全量编译。它扫描所有 ScriptRoot 下的 `.as`，按依赖顺序统一编译——没有"按需加载"模式。

对用户的可观测影响：

- **首次启动稍慢**：脚本越多越慢。150 个 .as 一般在 2-4 秒之间，全部由 InitialCompile 占去
- **编译错误会在这里集中爆出**：见 §八
- **完成后，所有脚本类对反射系统可见**：ContentBrowser、Place Actors、Blueprint 父类列表里都能搜到

### 3.2 我能在 InitialCompile 之前 / 之后插入回调吗？

**能**，但这是非常进阶的需求，普通脚本作者用不到。

```angelscript
// 方式 1：声明全局函数 + UFUNCTION，在初始编译完成后被广播
UFUNCTION(ScriptCallable)
void OnAngelscriptInitialized()
{
    Log("All scripts compiled and ready.");
}
```

更常见的做法：**不要在 InitialCompile 期间假定任何 UE 状态**。这一阶段下面这些都**还不能用**：

| 想用的能力 | InitialCompile 期间能不能用 |
|------|------|
| `GEngine` 是否存在 | Editor 模式下**否**；Game 模式下也不一定 |
| `GetWorld()` | **否**（World 还没构造） |
| `GetGameInstance()` | **否** |
| 全局 `UPROPERTY` 默认值赋值 | 可以，但只能用字面量、不能调引擎 API |
| `default Foo = X` 等声明式默认值 | 可以 |

如果你**真的**需要在引擎刚启好、第一帧之前做什么，应该用 `UScriptEngineSubsystem::Initialize()`（§五.4）而不是塞在脚本顶层。

### 3.3 启动期的可观测痕迹

打开 **Output Log** 切到 LogAngelscript：

```
LogAngelscript: [RuntimeStartup] StartupModule.
LogAngelscript: [RuntimeStartup] InitializeAngelscript begin.
LogAngelscript: [EngineSubsystemStartup] Created owned primary engine=0x...
LogAngelscript: Bind* (~144 个 Bind_*.cpp 自动绑定 UE API)
LogAngelscript: Compiled 153 modules in 2.41s
LogAngelscript: InitialCompile finished.
```

最后一行 `InitialCompile finished` 是**所有 .as 已就绪的标志**。在它之前，你的脚本类即使在反射系统里也尚未完成。

> **深入阅读**：`Arch_RuntimeLifecycle.md` §四 给出了 12 个里程碑（`M1..M12`）。普通用户记住"InitialCompile 是大头"即可。

---

## 四、关卡 / Actor 生成期：从 ConstructionScript 到 BeginPlay

### 4.1 标准 Actor 生命周期回调三件套

打开 `Script/Game/Example_Actor.as` 看的是最简版：

```angelscript
// ========================================================================
// 文件: Script/Game/Example_Actor.as（节选）
// 角色: 标准 Actor 三件套示例
// ========================================================================
class AExampleActorType : AActor
{
    UPROPERTY()
    int ExampleValue = 15;

    // ConstructionScript：编辑器中放置/修改属性时即时执行（运行期不再调）
    UFUNCTION()
    void ConstructionScript()
    {
        // 在此根据 ExampleValue 动态创建组件或调整布局
    }

    // BeginPlay：World 进入 Play 状态后被调用一次（PIE 开始 / 关卡加载完毕）
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // 这里 GetWorld() 一定可用
        Log("BeginPlay: world is ready, GetWorld() available.");
    }

    // Tick：每帧调用，DeltaSeconds 是这一帧的时长
    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaSeconds) { /* ... */ }

    // EndPlay：Actor 被销毁 / PIE 退出 / 关卡卸载时调用
    UFUNCTION(BlueprintOverride)
    void EndPlay(EEndPlayReason Reason)
    {
        Log("EndPlay: cleaning up timers / handles.");
    }
};
```

### 4.2 时序关系

```text
  关卡打开
     │
     ├─► 引擎构造 Actor 实例（CDO 复制）
     │
     ├─► (编辑器中或运行时) ConstructionScript() 运行
     │      ⚠ 此处 GetWorld() 可能返回 nullptr 或 Editor world
     │
     ├─► 进入 PIE / 关卡 BeginPlay
     │
     ├─► 你的 BeginPlay() 被调用一次
     │      ✓ GetWorld() 可用
     │      ✓ GetGameInstance() 可用
     │      ✓ GetGameMode() 可用（仅 Server / Standalone）
     │
     ├─► 进入 Tick 循环
     │      Tick(DeltaSeconds) 每帧调用
     │      ⚠ 不要在这里 new 大对象 / 触发 Reload；做轻量逻辑
     │
     └─► EndPlay(Reason) 在退出 PIE / Actor 销毁时调用一次
            ⚠ 这里要做"取消定时器、断开委托"等收尾
```

### 4.3 GetWorld() / GetGameInstance() 什么时候才能用

```angelscript
class AMyActor : AActor
{
    // 顶层默认值 / default 语句
    UPROPERTY()
    float Foo = 100.0;
    default Foo = 100.0;
    // ↑ ⚠ 此时 GetWorld() 还根本不存在，不要在这里调任何引擎 API

    UFUNCTION()
    void ConstructionScript()
    {
        // GetWorld() 可能返回 Editor world，不要假设是游戏 world
        UWorld World = GetWorld();
        if (World != nullptr && World.IsGameWorld())
        {
            // 仅在运行时分支才安全
        }
    }

    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // ★ 这里所有 UE 状态都可用
        UWorld World = GetWorld();                    // ✓
        UGameInstance GI = GetGameInstance();         // ✓
        AGameModeBase GM = GetGameMode();             // ✓ 仅 Server
        APlayerController PC = GetWorld().GetFirstPlayerController();  // ✓
    }
};
```

### 4.4 Component 的生命周期

`UActorComponent` / `USceneComponent` 子类的生命周期与 Actor **基本对齐**，但有两个细节：

```angelscript
class UMyComponent : UActorComponent
{
    UFUNCTION(BlueprintOverride)
    void BeginPlay()
    {
        // 默认 Component 不开 Tick，要主动开
        SetComponentTickEnabled(true);

        // GetOwner() 在这里一定可用
        AActor Owner = GetOwner();
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime) { /* ... */ }
};
```

**两个常见坑**：

1. `UActorComponent` **默认不会 Tick**，要在 `BeginPlay` 里 `SetComponentTickEnabled(true)`
2. `Component.BeginPlay` **比所属 Actor 的 BeginPlay 略晚**——如果 Component 想在 Owner 的 BeginPlay 之前做什么，那个时机不存在；改用 `UFUNCTION(BlueprintOverride) void OnRegister()` 等

详细的 .as 例子见 `Guide_QuickStart.md` 案例 3。

---

## 五、Subsystem 生命周期：与 Actor 完全不同的两条线

Subsystem 是**引擎自动管理的单例**，生命周期独立于任何 Actor。你不 new 它，不 destroy 它，引擎按 Outer 类型自动构造。

### 5.1 四类 Subsystem 的存活周期

```text
基类                              何时 Initialize          何时 Deinitialize
──────────────────────────        ────────────────         ─────────────────
UScriptEngineSubsystem            引擎启动                  引擎退出
                                  （★ 比 Actor BeginPlay 早）

UScriptGameInstanceSubsystem      GameInstance 启动          GameInstance 销毁
                                  （PIE 开启 / 进游戏）       （退出 PIE / 关游戏）

UScriptWorldSubsystem             World 加载                 World 卸载
                                  （比 Actor BeginPlay 略早） （EndPlay 之后）

UScriptLocalPlayerSubsystem       LocalPlayer 创建            LocalPlayer 销毁
```

### 5.2 标准模板

`Script/Examples/Extended/Example_SubsystemLifecycle.as` 是教科书式范例：

```angelscript
// ========================================================================
// 文件: Script/Examples/Extended/Example_SubsystemLifecycle.as（节选）
// ========================================================================
UCLASS()
class UExampleWorldTracker : UScriptWorldSubsystem
{
    UPROPERTY(BlueprintReadOnly, Category = "Example")
    int TickCount = 0;

    // ★ Initialize 比 World 中所有 Actor 的 BeginPlay 都早
    UFUNCTION(BlueprintOverride)
    void Initialize()
    {
        Log("Subsystem: Initialized");
    }

    // ★ Deinitialize 比 World 中所有 Actor 的 EndPlay 都晚（=兜底清理）
    UFUNCTION(BlueprintOverride)
    void Deinitialize()
    {
        Log("Subsystem: Deinitialized");
    }

    UFUNCTION(BlueprintOverride)
    void Tick(float DeltaTime) { TickCount += 1; }
};
```

### 5.3 何时用 Subsystem 而不是 Actor

```text
需求                                    用什么
─────────────────────────────────       ─────────────────────────────
关卡里的具体物体（怪物、捡拾品、平台）    Actor
跨关卡持久数据（玩家进度、成就）          UScriptGameInstanceSubsystem
关卡级管理器（计分、AI 调度）             UScriptWorldSubsystem
本地玩家数据（输入设置、UI 偏好）         UScriptLocalPlayerSubsystem
全局工具 / 编辑器扩展                    UScriptEngineSubsystem
```

> **注意**：脚本编写的 Subsystem 必须用 `UCLASS()` 显式声明（看上面例子第一行），普通 Actor 类不需要。

---

## 六、Hot Reload：保存 .as 文件后发生了什么

Hot Reload 是 AngelScript 的杀手特性。理解它**对你能否高效迭代非常关键**。

### 6.1 时间线

```text
[T=0.0s] 你按 Ctrl+S 保存 MyActor.as
            │
            ▼ DirectoryWatcher 监听到磁盘变化
[T=0.001s] 文件路径被 push 到 Engine.FileChangesDetectedForReload 队列
            │
            ▼ 等待主线程 Tick 消费
[T≤0.1s]   FAngelscriptEngine::Tick 看到队列非空，进入 CheckForHotReload
            │
            ├─► 200ms 重命名窗口：把删除事件与新增事件配对（避免误判）
            │
            ▼
[T≈0.2s]   PerformHotReload 启动
            │
            ├─► ① 反向依赖闭包：找出所有依赖 MyActor.as 的模块
            ├─► ② 重新预处理这批文件
            ├─► ③ 重新编译这批模块（AS 编译器）
            ├─► ④ ClassGenerator 决策：SoftReload 还是 FullReload？
            ▼
[T≈0.3s]   ★ 替换 UClass，旧 actor 实例被替换 / 重新实例化
[T≈0.4s]   Output Log 出现 "Hot reload completed" / 错误信息
```

整个链路**通常在 0.5 秒内完成**。

### 6.2 SoftReload vs FullReload：什么改动触发哪种

这是用户必须建立的心智模型。**SoftReload 是不打扰的，FullReload 会重新实例化对象**。

| 你的改动                                | 触发哪种                  | 用户感知 |
|----------------------------------------|---------------------------|----------|
| 改函数体（逻辑、算法）                  | **SoftReload**            | 即时生效，PIE 不打断 |
| 改变量初值字面量（如 `Speed = 200`）    | **SoftReload**            | 即时生效 |
| 添加私有方法（无 `UFUNCTION`）          | **SoftReload**            | 即时生效 |
| 添加 / 删除 `UPROPERTY()`               | **FullReload**            | PIE 中拒绝；要先停 PIE |
| 添加 / 删除 `UFUNCTION()`               | **FullReload**            | PIE 中拒绝 |
| 改变量类型 / 改函数签名                 | **FullReload**            | PIE 中拒绝 |
| 添加新 class / 新 enum / 新 delegate    | **FullReload**            | PIE 中拒绝 |
| 改 `default Foo = X` 默认值（多数情况） | SoftReload / FullReload   | 取决于是否影响 CDO |
| 改父类 / interface 列表                  | **FullReload**            | PIE 中拒绝 |

**记忆口诀**：函数体改 = Soft，结构改 = Full。

### 6.3 PIE 里改了 UPROPERTY 怎么办

**短答**：不能立即生效。

**详答**：引擎的处理是：

1. 看到改动需要 FullReload
2. PIE 期间禁止 FullReload（避免破坏运行中的对象图）
3. **挂起这次变更**，旧代码继续跑
4. 你**退出 PIE 后**，下一帧自动跑挂起的 FullReload，新代码就生效了
5. Output Log 会有提示：`Performing a Soft Reload during PIE... A Full Reload will be queued for after PIE ends.`

所以**最佳实践**：

- 在 PIE 中迭代游戏行为 → 改函数体（SoftReload，瞬间生效）
- 要加新字段 / 改类型 → 先停 PIE，改完再 Play

### 6.4 编译失败时的"安全网"

如果你保存的 .as 有语法错误：

```text
你保存了一个语法错误的版本
        ▼
预处理器 / 编译器报错，PerformHotReload 返回 false
        ▼
★ 旧版 UClass 与旧版字节码继续被使用（不会让运行中游戏崩）
        ▼
错误打到 Output Log（详见 §八）
        ▼
你修好语法 → 再保存 → 这次成功 → 自动应用新版
```

**关键保证**：编译失败时，**绝不会**让你的 PIE 进入"半新半旧"状态。要么整批生效，要么整批回滚。

> **深入阅读**：`RT_HotReload.md` 详细讲了反向依赖闭包、`PreviouslyFailedReloadFiles` 的重试机制、`QueuedFullReloadFiles` 的 PIE 推迟队列等内部机制。

---

## 七、PIE 与编辑器主进程：一个引擎实例还是两个？

这是 .as 用户最容易混淆的点之一。

### 7.1 默认情况：一个 FAngelscriptEngine，两个驱动者

```text
            进程内 FAngelscriptEngine (PrimaryEngine) — 全局唯一
                              │
              ┌───────────────┴────────────────┐
              ▼                                ▼
        编辑器主线程                       PIE / Game 世界
        - ContentBrowser 看到的类         - BeginPlay / Tick / EndPlay
        - 蓝图编译器看到的脚本父类         - GetWorld() / GetGameInstance()
        - ConstructionScript 用这条线      - 所有运行时事件
```

也就是说：**你的 .as 类只编译一次，PIE 与主编辑器共用同一份编译结果**。这意味着：

- 在 PIE 中保存 `.as` 与在主编辑器中保存效果**相同**（都触发 Hot Reload）
- PIE 里改了 .as 的 SoftReload 内容，下次再开 PIE 也生效——它就是同一个 UClass
- "PIE 关掉之后行为变了"几乎一定是 FullReload 已经被 queue 上、PIE 退出时被 flush 了

### 7.2 PIE 期间谁在 Tick 引擎

简短回答：**PIE 在跑时，由 PIE 的 GameInstance 驱动 Tick；PIE 结束后，编辑器主进程恢复驱动**。这是为了避免重复 Tick。

对用户的实际影响——基本没有。你的 `Tick(DeltaTime)` 在 PIE 中和独立游戏中**行为一致**，DeltaTime 也是真实帧时长。

### 7.3 多 PIE（PIE with Multiplayer）

如果你开了"PIE with N clients"模拟联机：

- 仍然只有一个 `FAngelscriptEngine`
- 多个 World 共享同一份 UClass
- 你的 .as 类**会被多次实例化**——一个 Server World 一份 Actor，每个 Client World 又一份
- `BeginPlay` 在每个 World 都会被调一次

判断"我这次 BeginPlay 是 Server 还是 Client"：

```angelscript
UFUNCTION(BlueprintOverride)
void BeginPlay()
{
    if (HasAuthority())
        Log("On server");
    else
        Log("On client");
}
```

---

## 八、编译错误怎么发现：Output Log + Source Navigation

### 8.1 哪里看错误

打开编辑器顶部菜单 `Window → Output Log`，过滤栏选 `LogAngelscript`：

```
LogAngelscript: Error: Script/MyFolder/Foo.as:23:5: 'Bar' is not declared
LogAngelscript: Error: Script/MyFolder/Foo.as:42:1: ; expected
LogAngelscript: Error: Script/MyFolder/Foo.as: hot reload failed in preprocessing.
```

格式恒定：`<相对路径>:<行号>:<列号>: <消息>`。

### 8.2 双击直接跳转到出错位置

UE 编辑器中点击 Output Log 里的错误条目（或在 Message Log 中）会触发 **SourceNavigation**——自动用你配置的外部编辑器（默认 VS Code）打开 .as 并跳到具体行列。

如果跳转不工作：

1. 确认 VS Code 已安装 `Unreal Angelscript` 扩展
2. 确认 `Tools → Open Angelscript workspace` 能正常工作
3. 重启编辑器再试

### 8.3 InitialCompile 里的错误

启动期编译错误**会让相应的 .as 类不出现在 ContentBrowser 里**——也就是"我的脚本类好像不存在"通常就是它没编过。第一时间查 Output Log。

错误日志里两条最常见：

```text
"unexpected token '<some keyword>'"
    → 语法错（少分号、括号不匹配、关键字拼错）

"<TypeName>' is not declared"
    → 引用了未声明的类型（缺 import、错拼类名）
```

修好之后再保存，引擎会自动 Hot Reload，错误日志会消失。

### 8.4 编译失败时的一个安全保证

InitialCompile 失败的脚本类**不会污染**已经成功编译的脚本类。也就是说，你写错了 `Foo.as`，`Bar.as` 与其他依赖链外的脚本仍然正常加载、正常工作。详见 `Arch_ErrorDiagnostics.md`（深入）。

---

## 九、Cooked Build：发布版的"PrecompiledData"

打包后的发布版本（Shipping / Cooked）里**没有 AS 编译器**——所有 .as 在 Cook 阶段已经被预编译成 `PrecompiledData` 二进制资源，运行时只是反序列化。

对用户的影响：

| 项目                               | Editor / DevelopmentEditor | Cooked Game |
|------------------------------------|----------------------------|-------------|
| 启动时编译 .as                      | ✓ 每次启动都编译           | ✗ 直接加载预编译数据 |
| Hot Reload                         | ✓ 全功能                    | ✗ 不可用 |
| `bScriptDevelopmentMode`           | true                        | false |
| 文件监听 / DirectoryWatcher        | ✓ 启动                      | ✗ 不启动 |
| 启动耗时                            | 慢（数秒）                  | **极快**（毫秒级） |

**结论**：Cooked 版的玩家不会感知到 .as 这一层——它表现得像 native code 一样快。

但这也意味着：**你不能在 Cooked 客户端上"修复线上 bug"靠改 .as**。要走正常的 patch 流程。

---

## 十、调试入门：断点、调用栈、DumpEngineState

### 10.1 设置断点

VS Code 安装 `Unreal Angelscript` 扩展后，在任意 .as 行号槽点击即可设置断点。前提：

- 已在 `Tools → Open Angelscript workspace` 打开过
- DebugServer 已启动（启动 Editor 时自动）

断点命中后：

```text
VS Code 调试侧栏可见：
  - 当前调用栈（Angelscript + 进入它的 C++ 帧）
  - 局部变量与 this 指针
  - "Continue / Step over / Step into / Step out"
  - 表达式求值（Watch 面板）
```

详细工作流见 `Guide_Debugging.md`（深入）。

### 10.2 控制台诊断命令

编辑器命令行（`~`）输入：

```
as.DumpEngineState
```

会把当前 AS 引擎的全部"可观测状态"dump 到一组 CSV 文件——脚本类清单、模块依赖图、热重载历史、绑定数据库等。诊断卡死、对象泄漏、热重载失败时非常有用。

详见 `Guide_DumpDiagnostics.md`（深入）与 `RT_StateDump.md`（机制）。

### 10.3 不打开调试器也能粗略看

在脚本里随手加一行 `Log` 或 `Print`：

```angelscript
UFUNCTION(BlueprintOverride)
void BeginPlay()
{
    Log(f"[BeginPlay] Self={this}, World={GetWorld()}");
}
```

- `Log("...")` → Output Log（持久化）
- `Print("...")` → 屏幕浮层 + Output Log（短期可见）

f-string（`f"..."`）支持嵌入任何变量，详见 `Guide_QuickStart.md` 案例 15。

---

## 十一、用户视角避坑清单

下面这些是 .as 作者最常踩的坑，集中收口在这里：

1. **把 .as 放错位置**：必须在 ScriptRoot（项目根 `Script/`）下；放 `Source/` 或 `Content/` 都不会被发现。
2. **在脚本顶层 / 默认值里调 `GetWorld()`**：那个时间点 World 还不存在。所有引擎 API 调用要放在 `BeginPlay` 或更晚。
3. **Component 不会自动 Tick**：要在它的 `BeginPlay` 里 `SetComponentTickEnabled(true)`。
4. **PIE 中改了 UPROPERTY，看似没生效**：那是 FullReload 被挂起；停 PIE 后下一帧自动应用。
5. **`EndPlay` 不写收尾**：定时器 / 委托绑定不取消会引起内存泄漏或回调到已销毁对象。
6. **修改 .as 后 ContentBrowser 没看到新类**：去 Output Log 看编译错误——基本一定是预处理 / 编译失败导致该 .as 没被注册。
7. **`#include` 与 `import` 混用**：除非确实需要文本嵌入，否则一律用 `import`。
8. **保存时引擎卡 1-2 秒**：FullReload 的正常表现；重型 reload 会带 SlowTask 进度条，不是死锁。
9. **Subsystem 的 `Initialize` 与 Actor 的 `BeginPlay` 谁先**：Subsystem 永远早于其 Outer World 中的 Actor。
10. **Cooked 版没有 Hot Reload**：在 Editor 里 Hot Reload 工作 ≠ 上线后还能 Hot Reload。

---

## 附录 A：四阶段时序速查

```text
═══════════════════════════════════════════════════════════════════
阶段 1 ── 引擎启动期（一次性）
─────────────────────────────────────────────────────────────────
模块装载（PostDefault） → Bootstrap → InitialCompile
你能依赖：               基本不能依赖任何 UE 状态
你能插入回调：            UScriptEngineSubsystem::Initialize（最早可用点）

═══════════════════════════════════════════════════════════════════
阶段 2 ── 关卡 / Actor 生成期（每次开关卡或 Spawn 1 次）
─────────────────────────────────────────────────────────────────
ConstructionScript → 反射元数据填充
你能依赖：               UPROPERTY 默认值，编辑器属性
你能插入回调：            ConstructionScript（编辑器即时执行）
⚠ GetWorld() 这里仍可能不可靠

═══════════════════════════════════════════════════════════════════
阶段 3 ── Play 期（PIE / 关卡）
─────────────────────────────────────────────────────────────────
[Subsystem.Initialize] → [Actor.BeginPlay] → [Tick 循环] → [Actor.EndPlay] → [Subsystem.Deinitialize]
你能依赖：               一切——GetWorld / GetGameInstance / GetGameMode
你能插入回调：            BeginPlay / Tick / EndPlay / OnRep_X / 各类 Overlap 等

═══════════════════════════════════════════════════════════════════
阶段 4 ── 热重载期（任意时刻 Ctrl+S）
─────────────────────────────────────────────────────────────────
DirectoryWatcher → CheckForHotReload → PerformHotReload → SwapInModules
你能依赖：               旧版状态保留至新版替换完成
你能插入回调：            一般无需用户介入；进阶可监听 OnClassReload 等
═══════════════════════════════════════════════════════════════════
```

---

## 附录 B：常见问题 FAQ

**Q1：我新建了一个 `.as` 文件，编辑器里完全没反应？**
A：先确认它在 `Script/` 之下；再确认 Output Log 里没编译错误；再看 ContentBrowser 是否需要刷新（`F5`）。

**Q2：在 PIE 里改 .as，函数体改了立即生效，但加了一个 `UPROPERTY` 就不生效？**
A：那是 FullReload 被 PIE 挂起，详见 §六.3。停 PIE 即可。

**Q3：`BeginPlay` 跟 `Initialize`（Subsystem）哪个先调？**
A：Subsystem.Initialize 永远早于同 World 中所有 Actor 的 BeginPlay。

**Q4：编辑器主线程里我的 Actor `Tick` 居然在跑？**
A：默认编辑器中 Actor 不 Tick，但 `Tick(DeltaSeconds)` 中如果你检查了 `if (!HasActorBegunPlay()) return;` 就能避免误执行。也可以用 `default PrimaryActorTick.bCanEverTick = true;` 与 `PrimaryActorTick.bStartWithTickEnabled = false;` 配合 `SetActorTickEnabled` 精细控制。

**Q5：保存 .as 后 Output Log 显示 "Performing a Soft Reload during PIE" 是错误吗？**
A：不是错误，是警告——意思是"这个改动按理需要 FullReload，但你在 PIE 里，我先做了 Soft，等你停 PIE 再 Full"。退出 PIE 即可。

**Q6：我能在脚本里检测"现在是 InitialCompile 还是 Hot Reload"吗？**
A：不能直接检测，普通脚本作者也不应该关心；进阶用户可以通过 `UScriptEngineSubsystem` 的回调（其 `Initialize` 在首次启动跑、Hot Reload 不再触发）做近似判定。

**Q7：Cooked Build 里 `bScriptDevelopmentMode` 是什么？**
A：Editor / Development 配置下 `bScriptDevelopmentMode == true`（启动 Hot Reload / 文件监听 / DebugServer），Cooked Shipping 里它 `== false`（这一切都不启动）。这是为了发布版能极快启动。

---

## 小结

- **四段式生命周期**：引擎启动期、关卡生成期、Play 期、Hot Reload 期。每段你能做什么、不能做什么完全不同——`BeginPlay` 之前不要碰任何 UE 状态。
- **ScriptRoot = 自动发现**：`.as` 必须落在 `Script/` 等 ScriptRoot 之下才能被引擎扫到；不需要手动注册。
- **Hot Reload 是核心工作流**：函数体改动 = SoftReload（即时）；结构改动 = FullReload（PIE 中挂起，停 PIE 后生效）。
- **PIE 与主编辑器共用一个 FAngelscriptEngine**：你的脚本类只编译一次，两边看到的是同一份 UClass。
- **Cooked Build 里没有这一切**：发布版用 PrecompiledData 静态加载，启动毫秒级、无 Hot Reload、无文件监听。
- **诊断三板斧**：Output Log 查编译错误（`LogAngelscript`）+ VS Code 设断点（DebugServer）+ `as.DumpEngineState` 控制台命令。

---

## 下一步

- **维护者视角的引擎生命周期编排** → `Documents/Knowledges/ZH/Arch_RuntimeLifecycle.md`（细化 Subsystem 让位、Initialize 12 个里程碑）
- **Hot Reload 内部机制** → `Documents/Knowledges/ZH/RT_HotReload.md`（SoftReload / FullReload 决策表，反向依赖闭包，失败回滚）
- **预处理器与 import / #include** → `Documents/Knowledges/ZH/Type_Preprocessor.md`
- **远程调试工作流** → `Documents/Knowledges/ZH/Guide_Debugging.md`
- **Dump 诊断** → `Documents/Knowledges/ZH/Guide_DumpDiagnostics.md` + `Documents/Knowledges/ZH/RT_StateDump.md`
- **子系统使用指南** → `Documents/Knowledges/ZH/Guide_SubsystemUsage.md`
