# TestFramework 语料指南

现在处于 **攒语料** 阶段：先把 `TestSource/TestFramework/` 写对、写齐，**先不必跑通** CQTest / ScriptTests。这份文件约定怎么写，以及以后这些 `.as` 怎么进 C++ 测试。

只有这里允许 `UAngelscriptTestSuite`、`FAngelscriptTest`、`ULatentAutomationCommand`。

---

## 1. 两类文件

| 类 | 目录 | 目的 | 密度 |
|---|---|---|---|
| **协议** | `Discovery/` `Lifecycle/` `Assertions/` `Commands/` `World/` `Automation/` `HotReload/` `SelfHosted/` | 测框架接口和 helper | 按协议缝补，payload 可以是 `1+1` |
| **用法** | `Usage/Math/` `Usage/Containers/` `Usage/Object/` … | 示范怎么用 Suite 测真实 API，给 runner 攒可跑脚本 | 每个题材几份短文件，对照 TestSource 正例选题，**不是** TestSource 矩阵 |

用法语料参考 TestSource 已有案例 **选题**，手写成 `Assert*` Suite。不要从 `Observe_*` 生成，不要 1:1，不要 Reject / SourceHistory / Bindings 观察。

---

## 2. 怎么写（攒语料时就按这个）

### 2.1 路径和名字

```
TestFramework/<协议目录>/Test_<Name>.as          现有协议文件可保持 Test_ 前缀
TestFramework/Usage/<题材>/<Name>.as            新用法语料不要 Test_ 前缀
```

- 一个文件一个主 Suite（可另有 payload `UCLASS` / helper）
- 类名：`U` + 题材 + `ScriptTests`，文件内唯一
- Leaf：`UFUNCTION(meta=(AngelscriptTest))` + `void()`，名字说结果（`AddThenNumIsOne`），不要 `TEST_`
- 未标记方法只当 helper，不会被发现

### 2.2 文件头

协议文件沿用现有 `// Framework contract:` 块（C++ oracle 还要靠那些「Expected observations」）。

用法文件用块注释标记，和主题语料同一家族，但 **Harness 是 SuiteUsage**：

```
/**
 * TArray Add then Num.
 *
 * @Theme TestFramework.Usage.Containers
 * @Subject TArray.Add
 * @Harness SuiteUsage
 * @Tag TestFramework.Usage.Containers.ArrayAddAndNum
 * @Provenance TestSource/Containers/TArray/Function/…   （对照哪道观察题，可多行）
 */
```

`@Tag` 末段 = 文件名。不要 `@Kind Observe`，不要 `namespace XxxTest`。

### 2.3 Suite 骨架

```angelscript
UCLASS(meta=(AngelscriptTestFlags="EditorContext;EngineFilter"))
class UArrayAddAndNumScriptTests : UAngelscriptTestSuite
{
	TArray<int> Values;

	UFUNCTION(BlueprintOverride)
	void BeforeEach()
	{
		Values.Empty();
	}

	UFUNCTION(meta=(AngelscriptTest))
	void AddThenNumIsOne()
	{
		Values.Add(7);
		AssertEquals(1, Values.Num());
		AssertEquals(7, Values[0]);
	}
}
```

- 断言用 Suite 上的 `Assert*` / `Fail` / `ExpectError*`，不要 `Observe_*`
- World 用 `FAngelscriptTest::CreateTestWorld` / `SpawnActor` / `DestroyTestWorld`，用完显式拆
- 异步用 `FAngelscriptTest::Commands().Do/Then/Until/WaitDelay`，回调是 **本 Suite 上的方法名**（`FName`），没有 lambda
- 需要失败叶时（只在 **协议** 目录）：单独一个 `void Fail…()` leaf，C++ 用 Probe 接诊断；**用法** 目录默认全是通过叶
- 不要测试用 `namespace`；不要把 SourceHistory 的 `@change` 写进 Suite 正文

### 2.4 用法选题（对照 TestSource，从简）

每个 Usage 题材先 1～3 个文件就够，例如：

| 目录 | 对照 | Suite 里写什么 |
|---|---|---|
| `Usage/Math/` | `TestSource/Math` 与 Bindings/FMath 正例 | 见下表 |

`Usage/Math/` 现有文件：

- `ScalarAbsMinMax.as` — `Math::Abs` / `Min` / `Max` / `Max3` / `Clamp`
- `VectorConstruction.as` — 默认、三分量、broadcast、轴向常量
- `VectorArithmetic.as` — 加减乘除、`==` / `!=`
- `VectorDotCrossAndSize.as` — Dot / Cross / Size
- `Vector2DConstructionAndDot.as` — 构造、正交 Dot
- `RotatorConstructionAndAdd.as` — 构造、加法
- `QuatIdentity.as` — Identity / IsNormalized / IsIdentity
- `TransformLocation.as` — Identity、GetLocation、TransformPosition
- `LinearColorConstruction.as` — 默认黑不透明、四分量、White
| `Usage/Containers/` | `TestSource/Containers` 最普通正例 | 见下表 |

`Usage/Containers/` 现有文件：

- `ArrayAddAndNum.as` — Add / Num / `[]` / Contains / FindIndex
- `ArrayInsertAndRemove.as` — Insert / Remove / RemoveAt
- `ArrayAppendAndEmpty.as` — Append / Empty / AddUnique / Last
- `MapAddAndFind.as` — Add / 覆盖 / Find
- `MapRemoveAndFindOrAdd.as` — Remove / FindOrAdd
- `MapGetKeys.as` — GetKeys 成员，不比顺序
- `SetAddAndContains.as` — Add / 重复 / Contains
- `SetRemoveAndAppend.as` — Remove / Append(TArray)
- `OptionalSetAndGet.as` — Set / IsSet / GetValue / Reset
- `OptionalGetFallback.as` — Get(fallback)
- `SubclassOfTypeCheck.as` — assign / IsValid / IsChildOf
- `WeakObjectPtrAssign.as` — SpawnObject 后 IsValid / 赋空
| `Usage/Object/` | 不必对照容器矩阵 | `SpawnObject` + `AssertNotNull` |
| `Usage/World/` | 仅当要示范 Actor | 一个 Spawn + BeginPlay，测完 Destroy |

同一 API 的边界、Reject、容器套容器留给 TestSource。

### 2.5 协议目录补文件时

继续写「框架合同」：测的是发现条数、fail-fast、LIFO cleanup，不是 FVector。C++ 头注释里的 `C++ oracle required:` 必须能对上以后的 CQTest 断言。热更协议可与 `ReloadHistory.md` 对齐（last-good 用版本树），但 **Usage 不要写 reload 版本树**。

---

## 3. 以后怎么导入 C++ 测

这些文件 **不在** `Script/` 下，编辑器不会当游戏脚本自动发现成 `Angelscript.ScriptTests`。导入方式是：C++ CQTest **读磁盘文本 → 编译进隔离模块 → registry → runner**。和现在 `AngelscriptScriptTest*Tests.cpp` 里 `ASTEST_AS` 同一条链，只是字符串改成文件内容。

现有链（内联）：

```
ASTEST_AS(R"AS( ... suite ... )AS")
  → FScopedAngelscriptModule(Engine, ModuleName, Source)
  → FAngelscriptScriptTestRegistry::Rebuild / BuildSnapshot
  → FAngelscriptScriptTestRunner::Start(DescriptorId, *TestRunner)
  → 断言 Context->IsComplete() / 失败条目 / 诊断
```

导入后：

```
FString Source = LoadTestSourceFile("TestFramework/Usage/Containers/ArrayAddAndNum.as");
  → 同一套 Module + Registry + Start
```

`LoadTestSourceFile` 读 `TestSource/` 相对路径，UTF-8。模块名用稳定逻辑名（例如 `TestFramework.Usage.Containers.ArrayAddAndNum`），不要每次随机，方便热更协议测试。

### 3.1 用法语料（Usage）——当「能跑过的脚本测试」

C++ 几乎不做业务断言（`Num==1` 已经在 AS 里 `AssertEquals` 了）。CQTest 只验证 **框架把这叶跑完且通过**：

1. 文件编过（`ModuleScope.IsValid()`）
2. Snapshot 里 leaf 数 = 文件中 `meta=(AngelscriptTest)` 方法数
3. 每个 leaf `Start` 后 `IsComplete()` 且宿主 `TestRunner` 没有失败条目
4. 需要 World 的叶结束后 `GetTestWorld()` 为空（Destroy 或 runner 清理）

一个 Usage 文件可以对应一个 `TEST_METHOD`，或一个扫描 `Usage/**/*.as` 的方法里循环（攒语料阶段不必写扫描器）。

### 3.2 协议语料（Discovery / Assertions / …）——当「给 oracle 的夹具」

AS 里的 `AssertEquals(1+1)` **不是** 协议结论。C++ 继续当 oracle，例如：

- Discovery：编过之后 `Snapshot->Tests.Num()`、Id、不出现 abstract/unmarked
- 失败叶：`FAngelscriptScriptTestProbe` 接住内部失败，查诊断条数、自定义原文、源文件行号、失败后同叶后续语句不跑
- Lifecycle：两次 `Start` 各是新实例；`AfterEach` 在 Assert 失败后仍跑
- Commands：FIFO / cleanup LIFO / WaitDelay 不推进 World
- HotReload：对同一逻辑模块再 `CompileAnnotatedModuleFromMemory` 第二版源码（以后可换成 SourceHistory 抽出的 diff）

协议文件头里 `C++ oracle required:` 就是导入时要写的那些 `ASSERT_THAT`。

### 3.3 和 `Angelscript.ScriptTests` 的关系

| 入口 | 何时用 |
|---|---|
| CQTest 读 `TestSource/TestFramework` | **主回归**（隔离模块、可测失败叶、不污染 `Script/`） |
| `Angelscript.ScriptTests.*` | 仅当文件被编进引擎脚本图（例如以后同步到 `Script/Tests` 或单独 mount）。Usage 若要给用户当范例，可再拷一份到 `Script/Tests`，权威仍在 TestSource |

攒语料阶段 **不要** 为了「能在 Session Frontend 里点到」去改 `Script/`。先把 `.as` 写在 TestFramework 下即可。

### 3.4 C++ 侧建议的测试划分（以后再写 cpp）

```
Angelscript.TestModule.Testing.ScriptTestFramework.Usage
    每个 Usage 文件：编译 + 全 leaf Start 通过

Angelscript.TestModule.Testing.ScriptTestFramework.Discovery|Lifecycle|…
    现有 cpp 改为 LoadTestSourceFile，删掉 ASTEST_AS 里那份 Suite 正文
```

Usage 的通过/失败已经由 Suite 断言决定；C++ 只报「哪一个 TestSource 文件的哪一个 leaf 没跑完」。协议测试仍由 C++ 数诊断、数 leaf。

---

## 4. 落地顺序（语料现在就可以写）

1. **现在**：按第 2 节往 `Usage/Math`、`Usage/Containers` 丢短 Suite；协议目录继续补接口缝。不跑 All。
2. **下一步**：C++ 加 `LoadTestSourceFile` + 一个 Usage 文件的 `Start` 全通过。
3. **再下一步**：协议 cpp 改为读盘，去掉内联拷贝。
4. 不把 TestSource 主题矩阵生成进 TestFramework。

---

## 5. 不要做的

- 不要 `Observe_*`、不要 Reject 当 Suite leaf
- 不要 Usage 里写 SourceHistory `@change` 树
- 不要 Python 从 TestSource 生成 Suite 正文
- 不要为了示范去测 `MissingType` 那种故意非法程序（那是主题 Reject / Reload last-good）
- 不要假定 TestSource 路径会被 `Angelscript.ScriptTests` 自动发现
