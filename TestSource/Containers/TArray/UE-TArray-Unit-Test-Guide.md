# UE TArray 单元测试与用例设计指南

本文整理自一次完整讨论：从「有没有生成单元测试的 skill」到「UE 里如何测 TArray」，以及负向用例命名、LLT 骨架、基础用例树、扩展压力测试、Advance / RoundTrip 设计。

---

## 1. 有没有「生成单元测试」的 skill

当前会话内置 skill **没有**专门的「生成单元测试」包。

### 1.1 现成相关能力

**内置 / 官方**

- 无 `unit-test` / `generate-tests` 这类 bundled skill
- 官方 marketplace 有 **superpowers** plugin，偏 TDD、系统化调试、工程流程，不是「读代码直接吐测试文件」
- 有 **skill-creator**（自己写）和 **skill-installer**（从 GitHub 安装）

**社区现成 skill**

- [clear-solutions / mavka-ai unit-tests-skills](https://github.com/clear-solutions/unit-tests-skills)：`generate-test-cases`（只列用例）+ `generate-tests`（生成测试代码）。Java / JUnit 5 / Mockito / AssertJ 最完整
- [CuriousLearner/devkit 的 test-generator](https://github.com/CuriousLearner/devkit/blob/main/skills/test-generator/SKILL.md)：按项目框架生成，覆盖 Jest / pytest / Go / JUnit 等
- 各类 Claude 风格 `writing-unit-tests` / `unit-test-generator`：把命名、AAA、mock 策略、覆盖率写进 `SKILL.md`

多数时候不需要 skill：把源文件、框架和约定直接交给模型即可。Skill 真正有用的是固化仓库规矩：

- 测试文件放哪
- 命名格式
- mock 边界
- 必须覆盖的错误路径
- runner 和断言库

---

## 2. 这些单元测试 skill 的提示思路

表面都在「写单测」，底层在解三个不同问题：

1. 已经有实现了，怎么把测试补齐（生成器）
2. 这个仓库到底允许怎么测（约定编码器）
3. 还没写实现时，怎么用测试把行为钉死（TDD 闸门）

### 2.1 四类思路

#### A. 覆盖率生成器

代表：CuriousLearner `test-generator`、Jeremy Longshore `generating-unit-tests`。

流水线：

1. 扫签名、返回值、分支、副作用、外部依赖
2. 探测项目框架
3. 按清单生成：happy path、边界、错误、mock、异步
4. 模仿已有测试的文件名、目录、断言风格

默认假设：**现有实现是对的，测试负责锁住现状。**

代价：容易写成实现镜像。代码里有 `if` 就补一条，集合 1/2/3 个元素测三次，覆盖率好看，行为并不更清楚。

#### B. 分支精炼生成器

代表：`unit-tests-skills` 的 `generate-test-cases` + `generate-tests`。

特点：

- 先只输出 Given / When / Then / Code branch，禁止先写测试代码
- 等人确认后再生成
- 生成后编译、跑测试；测不过就改测试，**禁止改生产代码**

选用例的三问：

1. 会不会走进另一条分支？
2. 会不会产生另一种可观察结果？
3. 代码里有没有显式检查这个条件？

三问都否就排除。会丢掉：

- 同一结果的重复场景
- 没有 size 逻辑时的 1/2/3 个元素
- 代码没处理的 Unicode / 超大 payload
- 参数不是 `@Nullable` 时的 null
- 同一异常类型测多次

命名：`{method}_{state}_{outcome}`。质量标准 4C：Clarity、Completeness、Conciseness、Resilience。

这是**表征测试（characterization）**：把现有行为当 oracle。

#### C. 仓库约定编码器

代表：localskills 的 `writing-unit-tests` 范例。

几乎不讲「如何分析代码」，而是把易漂移的局部规则写成死命令：框架、目录、describe 粒度、必须覆盖的路径、mock 只允许在系统边界、结束前跑覆盖率脚本。

假设：模型已经会写测试；毁掉代码库的是风格漂移和过度 mock。

#### D. TDD 过程闸门

代表：obra/superpowers 的 `test-driven-development`。

铁律：没有先失败的测试，就不许写生产代码。流程 Red → 确认失败原因对 → 最少代码变绿 → 重构。

好测试要能说出「生产代码怎样改才会让它挂」；期望值必须手算 / 字面量；mock 不配拥有断言。

### 2.2 提示词真正分叉的四件事

| 维度 | 覆盖率生成器 | unit-tests-skills | 仓库约定 skill | Superpowers TDD |
|---|---|---|---|---|
| 测试相对代码的时间 | 代码已存在 | 代码已存在 | 代码已存在或修 bug | 代码还不存在 |
| 用例从哪来 | 签名 + 常见边界清单 | 代码分支 + INCLUDE/EXCLUDE | 本仓库清单 | 下一个要钉死的行为 |
| mock | 外部依赖都 mock | 只核对应参数 | 只 mock 系统边界 | 尽量不 mock |
| 完成标准 | 覆盖率 / public 方法测完 | 编译过、测试绿、用户点头 | 约定满足 + 覆盖率脚本 | 先红后绿，能说出抓住什么 bug |
| 和生产代码的关系 | 锁住现状 | 锁住现状，不改 prod | 按仓库政策补洞 | 测试驱动实现 |

### 2.3 它们共享的骨架

高质量 skill 都在防止模型用默认本能写测试。默认本能一般是：

- 只写 happy path
- 测试名写成 `works correctly`
- mock 一切，再断言 mock 被调用
- 用被测函数自己算 expected
- 为了覆盖率制造无区别用例
- 写完不跑

几乎都会强制：行为名、AAA 或 Given-When-Then、错误路径不能缺、一个测试一个场景、测可观察行为、写完要跑。

### 2.4 skill 提示一般怎么写

三层结构：

1. **Frontmatter description（触发层）**：做什么 + 什么时候用 + 触发词
2. **Body workflow（步骤层）**：读代码 → 列用例 / 生成 → 对齐约定 → 跑测试
3. **Constraints（禁令层）**：这才是 skill 的价值

典型正文骨架：

```markdown
# Generate unit tests

When invoked:

1. Read the target source and its neighbors. Detect the test framework and existing test layout.
2. List test cases before writing code. For each case record Given, When, Then, and which branch it covers.
3. Cover happy-path, sad-path, and boundaries that the code actually implements.
4. Skip duplicates that produce the same observable result.
5. Write tests next to existing conventions. Name them `{action}_when_{condition}_{outcome}`.
6. Mock only at system boundaries. Never mock the unit under test. Do not assert on mock calls unless the call is the behavior.
7. Run the new tests. If they fail, fix the tests unless the user asked to change production behavior.

Do not:
- Generate tests for private methods directly
- Invent speculative cases the code does not handle
- Use names like testInvalid or negativeTest
- Change production code to make tests pass
```

生成器和 TDD 不要写进同一份 skill，两种时序会打架。

一套比较稳的折中提示：

1. 先根据分支列出用例，不先写代码
2. 只保留「不同分支或不同可观察结果」的用例
3. mock 停在 I/O 边界，不断言 mock 本身
4. expected 用手算字面量
5. 跑测试；失败先怀疑测试，除非明确要改生产行为

---

## 3. 负向测试怎么命名

核心不是标「这是 negative」，而是把 **坏输入 / 坏状态 + 可观察失败结果** 写进名字里。

### 3.1 三种常见格式

**`{方法}_{条件}_{结果}`**

```text
createOrder_emptyItems_throwsValidationException
createOrder_negativeQuantity_throwsIllegalArgument
getUser_unknownId_returns404
login_wrongPassword_returns401
withdraw_insufficientFunds_throwsInsufficientFunds
parseDate_malformedString_throwsParseException
```

**`should...When...`**

```text
shouldThrowWhenEmailIsBlank
shouldReturn401WhenTokenIsExpired
shouldRejectOrderWhenTotalIsNegative
shouldNotSaveWhenValidationFails
```

**行为句子（Jest / Vitest / RSpec）**

```text
it("rejects invoices with a negative total")
it("returns 404 when the user does not exist")
it("throws when the payload is missing orderId")
it("does not charge the card when inventory is empty")
it("handles empty line items (#482)")
```

### 3.2 负向测试该强调什么

| 块 | 写什么 | 少写什么 |
|---|---|---|
| When / Given | 哪个输入或状态不合法 | `invalidInput`、`badData`、`errorCase` |
| Then | 拒绝、抛错、返回哪个错误码 | `fails`、`doesNotWork`、`negativeTest` |

```text
❌ testCreateOrderNegative
❌ createOrder_invalid_fails
❌ shouldHandleError

✅ createOrder_missingCustomerId_throwsValidationException
✅ shouldReturn403WhenUserLacksPermission
✅ it("does not publish when the article has no title")
```

「负向」是分类，不是测试名的一部分。

### 3.3 惯用词

- 校验失败：`invalid` / `blank` / `malformed` / `outOfRange` + `throws` / `rejects`
- 找不到：`unknownId` / `notFound` + `returns404`
- 权限：`unauthenticated` / `forbidden` / `lacksPermission` + `returns401/403`
- 状态不允许：`alreadyClosed` / `expired` / `insufficient` + `throwsXxx`
- 副作用不该发生：`doesNotCharge` / `doesNotPersist` / `doesNotNotify`

有些负向测试的断言不是「抛了错」，而是「主流程失败且副作用没发生」。

### 3.4 和正向成对

```text
calculateDiscount_validCoupon_returnsReducedPrice
calculateDiscount_expiredCoupon_throwsExpiredCoupon
calculateDiscount_couponForOtherUser_throwsForbidden
```

正向用业务结果，负向用 **具体拒绝原因**，不要正向叫 `success`、负向叫 `failure`。

实用约定：

- 一个负向测试只钉一种失败
- HTTP 不要把 400/401/403 揉进同一个 `returnsError`
- 异常名能写就写，`throwsException` 太空
- 参数化时用例名仍要带条件和结果，不要只剩 `#1`

---

## 4. 负向测试的英文目录名

不要用 `negative-tests` 一种死名。按路径分，不要贴「负向」标签。

### 4.1 推荐目录

```text
tests/
  happy-path/
  sad-path/
  edge-cases/
```

| 目录 | 放什么 |
|---|---|
| `happy-path/` | 正常成功 |
| `sad-path/` 或 `error-path/` | 校验失败、抛错、4xx/5xx、权限拒绝 |
| `edge-cases/` | 空值、边界、极值（不一定是失败） |

或按失败原因再拆：

```text
tests/
  validation/
  not-found/
  authorization/
  conflict/
```

文件名跟源码走，不在文件名里写 negative：

```text
sad-path/create-order.test.ts
sad-path/test_create_order.py
sad-path/CreateOrderTests.java
```

### 4.2 分类名的英文叫法

- 最正式：`Negative tests` / `Negative test cases`
- 开发里更常用：`Sad path`（相对 `Happy path`）
- 更精确：`Error-path tests`、`Failure cases`、`Rejection tests`

不建议：`negative/`（易理解成负数测试）、`bad/`、`fail/`、`unhappy-path/`（不如 `sad-path` 通行）、用 `edge-cases/` 当负向目录。

成对目录写成 `happy-path/` 和 `sad-path/`，不要写成 `positive/` 和 `negative/`。

---

## 5. 符合 UE / 欧美习惯的命名方案

按 **Happy Path / Sad Path** 定，不用 `negative` 当目录名。

### 5.1 目录

```text
tests/
  happy-path/
  sad-path/
  edge-cases/
```

### 5.2 用例名

```text
{action}_when_{invalidCondition}_{expectedOutcome}
```

Sad path 动词用 `rejects` / `throws` / `returns` / `does_not_*`，条件写具体原因。

```text
createOrder_when_itemsEmpty_throwsValidationException
createOrder_when_quantityNegative_throwsIllegalArgument
getUser_when_idUnknown_returns404
login_when_passwordWrong_returns401
withdraw_when_fundsInsufficient_throwsInsufficientFunds
publishArticle_when_titleMissing_doesNotPersist
```

Jest / Vitest：

```text
it("rejects createOrder when items are empty")
it("returns 404 when user id is unknown")
it("does not persist when title is missing")
```

不要用：`negative/`、`positive/`、`bad-cases/`、`fail-tests/`、`testCreateOrderNegative`、`invalidInput_fails`。

成对文件：

```text
happy-path/create-order.test.ts
sad-path/create-order.test.ts
```

---

## 6. 在 UE 里测 TArray 应该怎么做

### 6.1 先说结论

**不要把引擎自带的 `TArray` 当业务代码重测一遍。** Epic 已在 Core 里测过。要测的是「你们怎么用 TArray」，或包在 TArray 上面的那层 API。

`TArray` 不依赖 `UObject`、不需要 World，最合适的是 **Low-Level Tests（Catch2）**，不要开 Editor 跑 Automation。

### 6.2 该测什么

按包装函数测，不按 TArray 全部 API 测。例如业务是「往库存里加物品」：

```cpp
void AddUniqueItem(TArray<FName>& Items, FName ItemId);
```

这时测的是 `AddUniqueItem`，不是 `TArray::Add`。

只有这些情况才值得直接写 TArray 用例：

- 自定义 Allocator / 元素类型（带析构、不可平凡搬迁）
- 封装了 `RemoveAt` / `Find` / `FilterByPredicate` 的工具函数
- 要锁定容易踩坑的约定，比如「找不到返回 `INDEX_NONE`」

### 6.3 框架怎么选

| 场景 | 用什么 |
|---|---|
| 纯 `TArray` / `TMap` / 工具函数 | Low-Level Tests + `TEST_CASE` |
| 要 `NewObject`、子系统 | Automation Test 或带 UObject 初始化的 LLT |
| 关卡、Actor、物理 | Functional Test，别用来测容器 |

### 6.4 UE 命名习惯

Automation 用点分层；LLT 用 `::` 分层，tags 放括号里。

```text
YourGame.Unit.Containers.TArray.Add_WhenEmpty_IncreasesNum
YourGame.Unit.Inventory.AddUniqueItem_WhenDuplicate_DoesNotAdd
```

```cpp
TEST_CASE("YourGame::Unit::Containers::TArray::Add_WhenEmpty_IncreasesNum", "[unit][containers][happy-path]")
TEST_CASE("YourGame::Unit::Containers::TArray::RemoveAt_WhenIndexInvalid_DoesNotChangeNum", "[unit][containers][sad-path]")
```

文件位置示例：

```text
Source/YourGame/Tests/Containers/TArrayTests.cpp
Source/Programs/YourGameTests/Private/Containers/TArrayTests.cpp
```

### 6.5 断言习惯

- 关键不变量用 `REQUIRE`（失败就停）
- 附加检查用 `CHECK`
- 找不到用 `INDEX_NONE`，不要写 `-1`
- 先查 `IsValidIndex`，再下标访问
- 越界访问在非 Shipping 会 `RangeCheck`，不要写成「期望 crash」

### 6.6 用例怎么切

按可观察结果切，不要按「每个 API 一条」铺。

**Happy path**

- 空数组 `Add` 后 `Num()==1`
- `Emplace` 构造非 POD 元素
- `Find` 找到第一个匹配
- `RemoveAt` 后后面的元素前移
- `Reserve` 后 `Add` 不改变已有元素

**Sad path**

- `Find` 不存在 → `INDEX_NONE`
- `IsValidIndex(-1)` / `IsValidIndex(Num())` → false
- 对空数组 `RemoveSingle` 不崩溃、`Num()` 仍为 0
- 重复 `AddUnique` 不增加 `Num()`

**不要测的**

- 内部 Allocator 怎么 realloc
- `GetSlack()` 的具体数字
- `operator[]` 越界会不会 check
- Epic 已经保证的平凡行为

### 6.7 包装函数才是正路

```cpp
bool TryRemoveItem(TArray<FName>& Items, FName ItemId)
{
	const int32 Index = Items.Find(ItemId);
	if (!Items.IsValidIndex(Index))
	{
		return false;
	}
	Items.RemoveAt(Index);
	return true;
}
```

```text
TryRemoveItem_WhenExists_RemovesAndReturnsTrue
TryRemoveItem_WhenMissing_ReturnsFalseAndLeavesArrayUnchanged
TryRemoveItem_WhenEmpty_ReturnsFalse
```

TArray 只是夹具，断言打在 **返回值 + 数组内容** 上。

### 6.8 怎么跑

LLT：

```bash
YourGameTests.exe -# [unit][containers] --extra-args -stdout
```

Automation：

```bash
UnrealEditor-Cmd.exe YourGame.uproject -NullRHI -Unattended -ExecCmds="Automation RunTests YourGame.Unit.Containers"
```

最小落地步骤：

1. 先写包装函数的测试，不直接测引擎 TArray
2. 用 LLT，`YourGame::Unit::...` 命名
3. sad path 只测 `INDEX_NONE`、`IsValidIndex`、`Num()` 不变、返回 false
4. 不要测越界下标和 slack

---

## 7. LLT 骨架是什么

**LLT 骨架** = Unreal **Low-Level Tests** 的一份最小可编译模板。
「骨架」= 先把文件、头文件、`TEST_CASE` 壳子搭好，再填断言。

### 7.1 LLT 是什么

UE5 的 Low-Level Tests，底层是 Catch2。特点：

- 不启动 Editor
- 不加载关卡
- 很适合测 `TArray`、纯函数、不依赖 `UObject` 的逻辑

相对的是 Automation Test（`IMPLEMENT_SIMPLE_AUTOMATION_TEST`），要挂引擎，更重。

### 7.2 骨架

```cpp
#include "CoreMinimal.h"   // UE 基础类型
#include "TestHarness.h"   // LLT / Catch2 入口
#include "Containers/Array.h"

TEST_CASE("项目::分层::对象::行为", "[unit][标签]")
{
	SECTION("When条件_Expected结果")
	{
		// Arrange 准备数据
		// Act     调函数
		// Assert  REQUIRE / CHECK
	}
}
```

| 部分 | 作用 |
|---|---|
| `#include "TestHarness.h"` | 引入 `TEST_CASE`、`SECTION`、`REQUIRE`、`CHECK` |
| `TEST_CASE("...", "[tags]")` | 一条可被过滤运行的测试 |
| `SECTION("...")` | 同一组准备下的子场景 |
| `REQUIRE` | 失败就停 |
| `CHECK` | 失败继续做后面的检查 |

LLT 骨架不是引擎里的特殊类型，只是开工模板。

### 7.3 和 Automation 骨架的区别

```cpp
IMPLEMENT_SIMPLE_AUTOMATION_TEST(
	FMyTest,
	"YourGame.Unit.Containers.TArray.Add_WhenEmpty_IncreasesNum",
	EAutomationTestFlags::ApplicationContextMask | EAutomationTestFlags::SmokeFilter)

bool FMyTest::RunTest(const FString& Parameters)
{
	TestEqual(TEXT("Num"), Array.Num(), 1);
	return true;
}
```

测 TArray 用 LLT 骨架即可。

要跑起来通常还要：

1. 一个 LLT 测试 Target（或项目里打开 Low-Level Tests）
2. 测试模块 `Build.cs` 依赖 `Core` 和测试相关模块
3. 用测试可执行文件按 tag 过滤运行

### 7.4 一份可直接用的 LLT 示例

```cpp
#include "CoreMinimal.h"
#include "TestHarness.h"
#include "Containers/Array.h"

TEST_CASE("YourGame::Unit::Containers::TArray::Add", "[unit][containers]")
{
	SECTION("WhenEmpty_IncreasesNumAndStoresValue")
	{
		TArray<int32> Values;

		const int32 Index = Values.Add(7);

		REQUIRE(Values.Num() == 1);
		CHECK(Index == 0);
		CHECK(Values[0] == 7);
		CHECK(Values.IsValidIndex(Index));
	}

	SECTION("WhenAlreadyHasItems_AppendsAtEnd")
	{
		TArray<int32> Values{ 1, 2 };

		Values.Add(3);

		REQUIRE(Values.Num() == 3);
		CHECK(Values.Last() == 3);
	}
}

TEST_CASE("YourGame::Unit::Containers::TArray::Find", "[unit][containers]")
{
	SECTION("WhenValueExists_ReturnsFirstIndex")
	{
		TArray<FString> Names{ TEXT("A"), TEXT("B"), TEXT("B") };

		CHECK(Names.Find(TEXT("B")) == 1);
	}

	SECTION("WhenValueMissing_ReturnsIndexNone")
	{
		TArray<FString> Names{ TEXT("A") };

		CHECK(Names.Find(TEXT("Z")) == INDEX_NONE);
		CHECK_FALSE(Names.IsValidIndex(Names.Find(TEXT("Z"))));
	}
}

TEST_CASE("YourGame::Unit::Containers::TArray::RemoveAt", "[unit][containers]")
{
	SECTION("WhenIndexValid_RemovesAndShifts")
	{
		TArray<int32> Values{ 10, 20, 30 };

		Values.RemoveAt(1);

		REQUIRE(Values.Num() == 2);
		CHECK(Values[0] == 10);
		CHECK(Values[1] == 30);
	}

	SECTION("WhenIndexInvalid_IsValidIndexIsFalse")
	{
		TArray<int32> Values{ 10 };

		CHECK_FALSE(Values.IsValidIndex(1));
		CHECK_FALSE(Values.IsValidIndex(-1));
		CHECK(Values.Num() == 1);
	}
}
```

---

## 8. TArray 基础用例树（带中文注释）

按 **操作 → 路径 → 用例名**。名字：`{Action}_When{Condition}_{Outcome}`。

```text
TArray
├─ Ctor                              // 怎么造出数组
│  ├─ happy-path
│  │  ├─ DefaultCtor_WhenCalled_IsEmpty
│  │  │  // 默认构造：空数组，Num()==0，IsEmpty()==true
│  │  ├─ Init_WhenCountPositive_FillsWithValue
│  │  │  // Init(值, N)：得到 N 个相同元素
│  │  ├─ InitializerList_WhenGivenValues_PreservesOrder
│  │  │  // {1,2,3} 构造后顺序不能乱
│  │  ├─ CopyCtor_WhenSourceHasItems_CopiesValuesAndNum
│  │  │  // 拷贝构造：内容和长度都一样，且互不影响
│  │  └─ MoveCtor_WhenSourceHasItems_MovesValuesAndLeavesSourceEmpty
│  │     // 移动构造：新数组拿到数据，源数组应被掏空
│  ├─ sad-path
│  │  └─ Init_WhenCountZero_RemainsEmpty
│  │     // Init(..., 0) 不能凭空变出元素
│  └─ edge-cases
│     ├─ CopyCtor_WhenSourceEmpty_ResultsEmpty
│     │  // 拷贝空数组，结果还是空
│     └─ MoveCtor_WhenSourceEmpty_BothEmpty
│        // 移动空数组，两边都空，不能崩
│
├─ Add                               // 往尾部加
│  ├─ happy-path
│  │  ├─ Add_WhenEmpty_IncreasesNumAndStoresValue
│  │  │  // 空数组 Add(x)：Num 变 1，[0]==x，返回下标 0
│  │  ├─ Add_WhenAlreadyHasItems_AppendsAtEnd
│  │  │  // 已有元素时，新值必须接在 Last()
│  │  ├─ Add_WhenCalledTwice_ReturnsIncreasingIndex
│  │  │  // 连续 Add，返回下标应是 0,1,2...
│  │  ├─ Emplace_WhenNonPodType_ConstructsInPlace
│  │  │  // FString 这类类型用 Emplace，在数组里直接构造
│  │  └─ AddDefaulted_WhenCalled_AppendsDefaultElement
│  │     // 追加一个默认值（int 为 0，结构体走默认构造）
│  ├─ sad-path
│  │  └─ AddUnique_WhenValueAlreadyExists_DoesNotIncreaseNum
│  │     // 已有相同值时 AddUnique 不得再加一条
│  └─ edge-cases
│     ├─ AddUnique_WhenEmpty_AddsAndReturnsIndex0
│     │  // 空数组上 AddUnique 应能加进去
│     └─ AddDefaulted_WhenEmpty_NumIsOne
│        // 空数组 AddDefaulted 后长度是 1
│
├─ Insert                            // 往中间插
│  ├─ happy-path
│  │  ├─ Insert_WhenIndexZero_PrependsValue
│  │  │  // 插到 0：新元素变成队头，旧元素后移
│  │  ├─ Insert_WhenIndexMiddle_ShiftsTailRight
│  │  │  // 插到中间：后面的元素整体右移，不能覆盖丢数据
│  │  └─ Insert_WhenIndexNum_AppendsLikeAdd
│  │     // 插到 Num() 位置，效果等于 Add
│  └─ sad-path
│     └─ IsValidInsertIndex_WhenIndexGreaterThanNum_IsFalse
│        // 插入点只能是 0..Num()。大于 Num() 不是合法插入位
│        // 不要写「越界 Insert 必崩」，Shipping 和 Debug 行为不同
│
├─ Append                            // 拼另一个数组
│  ├─ happy-path
│  │  ├─ Append_WhenOtherHasItems_ConcatenatesInOrder
│  │  │  // A={1,2} Append {3,4} => {1,2,3,4}
│  │  └─ Append_WhenSelfHasItems_KeepsOriginalPrefix
│  │     // 原有前缀必须原样保留
│  ├─ sad-path
│  │  └─ Append_WhenOtherEmpty_LeavesArrayUnchanged
│  │     // 追加空数组，A 的 Num 和内容都不能变
│  └─ edge-cases
│     └─ Append_WhenSelfEmpty_EqualsOther
│        // 空数组追加 B，结果应等于 B
│
├─ Access                            // 按下标取元素
│  ├─ happy-path
│  │  ├─ Subscript_WhenIndexValid_ReturnsElement
│  │  │  // 合法下标 arr[i] 就是第 i 个元素
│  │  ├─ Last_WhenNotEmpty_ReturnsLastElement
│  │  │  // Last() 等于 arr[Num()-1]
│  │  └─ GetData_WhenNotEmpty_PointsToFirstElement
│  │     // GetData()[0] 等于 arr[0]，给 C API / memcpy 用
│  ├─ sad-path
│  │  ├─ IsValidIndex_WhenIndexNegative_ReturnsFalse
│  │  │  // -1 永远非法，业务里常拿 Find 失败的 INDEX_NONE 来查
│  │  ├─ IsValidIndex_WhenIndexEqualsNum_ReturnsFalse
│  │  │  // 下标范围是 [0, Num)。Num() 本身越界
│  │  └─ IsValidIndex_WhenArrayEmpty_ReturnsFalseForZero
│  │     // 空数组连 0 都非法，不能写 if (arr[0])
│  └─ edge-cases
│     └─ Last_WhenOffsetZero_EqualsSubscriptNumMinusOne
│        // Last(0) 就是最后一个；确认和 [Num()-1] 一致
│
├─ Query                             // 查长度、是否包含、找下标
│  ├─ happy-path
│  │  ├─ Num_WhenHasItems_EqualsElementCount
│  │  │  // Num() 等于当前元素个数，不是容量 Max()
│  │  ├─ IsEmpty_WhenHasItems_ReturnsFalse
│  │  ├─ Contains_WhenValueExists_ReturnsTrue
│  │  ├─ Find_WhenValueExists_ReturnsFirstIndex
│  │  │  // 有重复时 Find 返回第一次出现的位置
│  │  └─ FindLast_WhenDuplicatesExist_ReturnsLastIndex
│  ├─ sad-path
│  │  ├─ IsEmpty_WhenDefaultConstructed_ReturnsTrue
│  │  ├─ Contains_WhenValueMissing_ReturnsFalse
│  │  ├─ Find_WhenValueMissing_ReturnsIndexNone
│  │  │  // 找不到必须是 INDEX_NONE，不要自己定义魔法数
│  │  ├─ FindLast_WhenValueMissing_ReturnsIndexNone
│  │  └─ Contains_WhenArrayEmpty_ReturnsFalse
│  └─ edge-cases
│     ├─ Find_WhenDuplicatesExist_ReturnsFirstIndexOnly
│     └─ Num_WhenEmpty_ReturnsZero
│
├─ Predicate                         // 用条件找，不是用等于
│  ├─ happy-path
│  │  ├─ ContainsByPredicate_WhenMatchExists_ReturnsTrue
│  │  ├─ IndexOfByPredicate_WhenMatchExists_ReturnsFirstIndex
│  │  └─ FilterByPredicate_WhenSomeMatch_ReturnsOnlyMatches
│  │     // 过滤后只留下符合条件的，原数组通常不变（返回新数组）
│  ├─ sad-path
│  │  ├─ ContainsByPredicate_WhenNoMatch_ReturnsFalse
│  │  ├─ IndexOfByPredicate_WhenNoMatch_ReturnsIndexNone
│  │  └─ FilterByPredicate_WhenNoMatch_ReturnsEmptyArray
│  └─ edge-cases
│     └─ FilterByPredicate_WhenSourceEmpty_ReturnsEmptyArray
│
├─ Remove                            // 删元素
│  ├─ happy-path
│  │  ├─ Remove_WhenValueExists_RemovesAllMatchesAndReturnsCount
│  │  │  // Remove(x) 删掉所有 x，返回删了几个，后面元素前移
│  │  ├─ RemoveSingle_WhenValueExists_RemovesFirstOnly
│  │  ├─ RemoveAt_WhenIndexValid_RemovesAndShiftsTailLeft
│  │  │  // 按下标删，后面元素补上来，顺序保持
│  │  ├─ RemoveAtSwap_WhenIndexValid_RemovesAndDoesNotPreserveOrder
│  │  │  // 用末尾元素填洞，更快，但顺序会乱
│  │  └─ Pop_WhenNotEmpty_ReturnsLastAndDecreasesNum
│  ├─ sad-path
│  │  ├─ Remove_WhenValueMissing_ReturnsZeroAndLeavesArrayUnchanged
│  │  ├─ RemoveSingle_WhenValueMissing_ReturnsFalseAndLeavesArrayUnchanged
│  │  ├─ Remove_WhenArrayEmpty_ReturnsZero
│  │  └─ RemoveAll_WhenNoMatch_LeavesArrayUnchanged
│  └─ edge-cases
│     ├─ RemoveAt_WhenLastIndex_OnlyDropsLast
│     ├─ RemoveSingle_WhenDuplicatesExist_KeepsRemainingMatches
│     └─ RemoveAtSwap_WhenLastIndex_EqualsRemoveAt
│
├─ Clear                             // 整表清空
│  ├─ happy-path
│  │  ├─ Empty_WhenHasItems_NumBecomesZero
│  │  │  // Empty() 后 Num==0，元素析构掉
│  │  └─ Reset_WhenHasItems_NumBecomesZero
│  │     // Reset() 也把 Num 置 0，但更可能保留已分配内存
│  ├─ sad-path
│  │  ├─ Empty_WhenAlreadyEmpty_RemainsEmpty
│  │  └─ Reset_WhenAlreadyEmpty_RemainsEmpty
│  └─ edge-cases
│     └─ Empty_WhenCalled_IsEmptyReturnsTrue
│
├─ Capacity                          // 容量，不是元素内容
│  ├─ happy-path
│  │  ├─ Reserve_WhenCapacityGrows_KeepsExistingValues
│  │  ├─ SetNum_WhenGrowing_IncreasesNum
│  │  └─ SetNum_WhenShrinking_DropsTail
│  ├─ sad-path
│  │  └─ SetNum_WhenZero_BecomesEmpty
│  └─ edge-cases
│     ├─ Reserve_WhenNewMaxLessThanNum_DoesNotShrinkNum
│     └─ Shrink_WhenHasSlack_DoesNotChangeValues
│
├─ Order                             // 排序 / 堆
│  ├─ happy-path
│  │  ├─ Sort_WhenUnsorted_OrdersAscending
│  │  ├─ HeapPush_WhenCalled_IncreasesNum
│  │  └─ HeapPop_WhenNotEmpty_RemovesRoot
│  └─ edge-cases
│     ├─ Sort_WhenAlreadySorted_KeepsOrder
│     └─ Sort_WhenEmpty_RemainsEmpty
│
└─ Assign                            // 赋值
   ├─ happy-path
   │  ├─ CopyAssign_WhenOtherHasItems_ReplacesContents
   │  └─ MoveAssign_WhenOtherHasItems_TakesOwnership
   ├─ sad-path
   │  └─ CopyAssign_WhenOtherEmpty_BecomesEmpty
   └─ edge-cases
      └─ CopyAssign_WhenSelfAssign_LeavesValuesUnchanged
```

### 8.1 英文结果对照

| 英文结果 | 中文含义 |
|---|---|
| `IncreasesNum` | 长度加 1 |
| `LeavesArrayUnchanged` | 内容和长度都不变 |
| `ReturnsIndexNone` | 返回 `INDEX_NONE`（找不到） |
| `ReturnsFalse` | 没做成 / 不包含 / 下标非法 |
| `ShiftsTailLeft/Right` | 后面的元素往前或往后挪，顺序还在 |
| `DoesNotPreserveOrder` | 用交换删除，快，但顺序乱了 |

### 8.2 业务里最值得先写的 8 条

1. `Find_WhenValueMissing_ReturnsIndexNone` — 找不到不是 0
2. `IsValidIndex_WhenIndexEqualsNum_ReturnsFalse` — 不能用 `Num()` 当下标
3. `IsValidIndex_WhenIndexNegative_ReturnsFalse` — `INDEX_NONE` 不能拿去 `arr[Index]`
4. `AddUnique_WhenValueAlreadyExists_DoesNotIncreaseNum` — 去重失败会重复刷道具
5. `Remove_WhenValueMissing_ReturnsZeroAndLeavesArrayUnchanged` — 删不存在的东西不能误伤
6. `RemoveSingle_WhenDuplicatesExist_KeepsRemainingMatches` — 只删一个还是全删
7. `RemoveAtSwap_WhenIndexValid_RemovesAndDoesNotPreserveOrder` — 用了 Swap 版就别再假设顺序
8. `Empty_WhenHasItems_NumBecomesZero` — 清空后循环不应再进元素

叶子可直接变成：

```text
YourGame.Unit.Containers.TArray.Find_WhenValueMissing_ReturnsIndexNone
```

或 LLT：

```cpp
TEST_CASE("YourGame::Unit::Containers::TArray::Find_WhenValueMissing_ReturnsIndexNone", "[unit][tarray][sad-path]")
```

---

## 9. TArray 扩展测试（压力、内存、并发、性能）

前面是正确性。扩展测试换维度：规模、内存、元素类型、别名、并发、性能。

TArray 不是线程安全的，扩容会让指针 / 引用 / 迭代器失效。

```text
TArray.Extended
├─ Stress                         // 反复折腾，看会不会烂掉
│  ├─ GrowShrink_WhenAddRemoveManyTimes_NumMatchesLiveCount
│  │  // 循环 Add / RemoveAt 几千次，最终 Num 必须等于还活着的元素个数
│  ├─ Realloc_WhenExceedsCapacity_ValuesRemainIntact
│  │  // 不 Reserve，一路 Add 逼它扩容，旧元素一个都不能变
│  ├─ Churn_WhenRemoveAtSwapThenAdd_DoesNotCorruptExisting
│  │  // 乱序删 + 再加，常见于子弹/伤害数字对象池
│  ├─ EmptyThenRefill_WhenRepeated_DoesNotLeakOrStaleNum
│  └─ FilterThenRemove_WhenLargeSet_ResultOnlyContainsMatches
│
├─ CapacityPressure               // 容量和内存，不只看 Num
│  ├─ Reserve_WhenNKnownAhead_AvoidsReallocAndKeepsPointersStable
│  │  // 先 Reserve(N) 再 Add N 个：GetData() 地址应保持不变
│  ├─ NoReserve_WhenGrowsPastMax_GetDataPointerChanges
│  │  // 对照：不 Reserve 时扩容后旧指针失效（文档行为，不是 bug）
│  ├─ Reset_WhenHasSlack_NumZeroButMaxMayRemain
│  ├─ Empty_WhenCalled_ReleasesOrReadyForReuse
│  └─ Shrink_WhenSlackLarge_DoesNotChangeValues
│
├─ ElementTypes                   // 换元素类型，很多 bug 只在非 int 上出现
│  ├─ FString_WhenAddEmplaceCopyMove_NoDanglingOrEmptySurprise
│  ├─ TSharedPtr_WhenRemove_RefCountDrops
│  ├─ UObjectPtr_WhenArrayReset_DoesNotUObjectDestroy
│  │  // TArray<UObject*> 只持裸指针，Reset 不会 Destroy 对象
│  ├─ TWeakObjectPtr_WhenSourceDestroyed_IsStale
│  ├─ StructWithCtorDtor_WhenRealloc_CtorDtorBalance
│  │  // 自计数结构体，扩容/删除后构造次数==析构次数
│  └─ TInlineAllocator16_WhenExceedsInline_SpillsToHeapAndKeepsValues
│
├─ AliasAndLifetime
│  ├─ ElementPtr_WhenArrayGrows_BecomesDangling
│  ├─ RangeFor_WhenAddDuringIteration_IsUnsafe
│  ├─ RemoveAt_WhenIteratingForward_SkipsNextElement
│  │  // 正向边遍历边 RemoveAt 会漏元素；应倒序删或用 RemoveAll
│  ├─ SelfAppend_WhenAppendSelf_DoesNotInfiniteOrCorrupt
│  └─ View_WhenSourceEmptied_DoesNotOutliveSource
│
├─ IndexSafety
│  ├─ FindThenSubscript_WhenMissing_MustCheckIsValidIndex
│  ├─ LoopToNum_WhenNumChangesInside_DoesNotOverrun
│  └─ Pop_WhenEmpty_IsGuardedByCaller
│
├─ Concurrency                    // TArray 不是线程安全容器
│  ├─ ConcurrentAdd_WhenTwoThreads_IsNotSupported
│  │  // 不要写成「期望成功」。应文档化：必须在 GameThread，或外层加锁
│  ├─ ReadWhileWrite_WhenNoLock_IsDataRace
│  └─ GameThreadOnly_WhenCalledFromWorker_FailsGuard
│
├─ Performance
│  ├─ Add_WhenN100k_WithoutReserve_SlowerThanWithReserve
│  ├─ RemoveAt_WhenHeadOfLargeArray_IsLinearTime
│  ├─ RemoveAtSwap_WhenHeadOfLargeArray_IsFasterThanRemoveAt
│  ├─ Find_WhenLinearScanOnLargeArray_CostGrowsWithNum
│  └─ Contains_WhenCalledInTightLoop_CopiesOrScansTooMuch
│
└─ Soak                           // 长时间挂机，适合 Gauntlet
   ├─ ObjectPool_WhenAcquireRelease1MTimes_NumNeverDrifts
   ├─ InventoryChurn_WhenPlaySessionLength_NoGrowthLeak
   └─ ReplayBuffer_WhenRingWraps_CountBoundedByCapacity
```

### 9.1 哪些值得写

值得写成自动化：

- 扩容后旧元素还在
- `Reserve` 后 `GetData()` 稳定，不 Reserve 则失效
- 带析构的结构体：构造/析构次数平衡
- `TArray<TSharedPtr<T>>` 删除后引用计数下降
- 包装函数：`Find` 失败不得下标访问
- 正向遍历中删除会漏元素
- `RemoveAt` vs `RemoveAtSwap` 的顺序差异
- 对象池 1e5 次申请释放，`Num` 不漂

不要当单元测试硬断言：

- 「Add 10 万个必须 < 3ms」——放到单独 Performance Filter
- 越界 `Arr[-1]` 必崩
- 两线程同时 `Add` 期望某种交错结果
- `Max()`、`GetSlack()` 的具体数字

### 9.2 压力测试写法

```cpp
TEST_CASE("YourGame::Unit::Containers::TArray::Realloc_WhenExceedsCapacity_ValuesRemainIntact", "[unit][tarray][stress]")
{
	TArray<int32> Values;
	for (int32 i = 0; i < 10000; ++i)
	{
		Values.Add(i);
	}

	REQUIRE(Values.Num() == 10000);
	for (int32 i = 0; i < Values.Num(); ++i)
	{
		CHECK(Values[i] == i);
	}
}
```

性能不要和正确性混在一个 `[unit]` 里：

```text
[perf][tarray]
YourGame.Perf.Containers.TArray.Add_WhenN100k_WithoutReserve
```

长时 Soak 走 **Gauntlet**，不要塞进每次编译的 LLT。

### 9.3 元素类型矩阵

```text
int32                 // POD
FString               // 堆字符串
FName                 // 游戏里最常见
TSharedPtr<FFoo>      // 所有权
UObject*              // 不拥有，Reset 不会 Destroy
TWeakObjectPtr<UFoo>  // 源对象销毁后应变 stale
FMyCountedStruct      // 自统计 ctor/dtor
TInlineAllocator<16>  // 小数组优化
```

高价值扩展用例：

```text
CountedStruct_WhenReallocAndRemove_CtorMinusDtorEqualsNum
```

扩容、`RemoveAt`、`Empty` 之后：`构造次数 - 析构次数 == Num()`。

落地顺序：

1. 指针失效 + `INDEX_NONE` 下标（防崩溃）
2. 扩容保内容 + ctor/dtor 平衡（防静默损坏）
3. `RemoveAt` / `RemoveAtSwap` / 遍历中删除（防逻辑错）
4. `Reserve` vs 不 `Reserve` 的性能对照（单独 `[perf]`）
5. 对象池 / 库存 churn 的 Soak（Gauntlet）

---

## 10. TArrayAdvanceTest：四类可验证协议

把 Advance 做成一套可验证协议，不要再堆 `Add`/`Find` 单点。四类夹具分开，方便对结果、做回放、做差分。

| 类型 | 你提供什么 | 断言打在哪 | 适合验证什么 |
|---|---|---|---|
| **PureInput** | 只有入参数组 / 操作序列 | 不变量、拒绝条件 | 任意输入都不能把容器打坏 |
| **PureOutput** | 没有业务入参，或只有生成规则 | 生成出来的数组本身 | 工厂、填充、快照 |
| **InputOutput** | 入参数组 + 期望数组 | `Actual == Expected` | 表驱动、回归、黄金数据 |
| **RoundTrip** | 入参 A → 变换 → 逆变换 | 回到 A，或回到约定的规范形 | 序列化、拷贝、栈、切片还原 |

`==` 对 TArray 是逐元素比较。

```text
TArrayAdvanceTest
├─ PureInput
├─ PureOutput
├─ InputOutput
└─ RoundTrip
```

### 10.1 PureInput：只扔输入，查不变量

```text
PureInput
├─ Invariants_WhenAnyArray
│  ├─ Num_IsNonNegative
│  ├─ IsEmpty_IffNumIsZero
│  ├─ IsValidIndex_IffInHalfOpenRange
│  │  // 0 <= i < Num() 真；i<0 或 i==Num() 假
│  ├─ Contains_IffFindNotIndexNone
│  ├─ LastIndex_WhenNotEmpty_IsNumMinusOne
│  └─ GetDataNull_IffEmptyOrNoAllocation
│
├─ Reject_WhenInputIllegal
│  ├─ FindResult_WhenMissing_IsIndexNone
│  ├─ IsValidIndex_WhenIndexNone_IsFalse
│  └─ GuardedAccess_WhenIndexInvalid_DoesNotRead
│
└─ Sequence_WhenRandomOpsKeepInvariants
   ├─ MixAddRemoveInsert_WhenSeededRandom_InvariantsHold
   ├─ RemoveAt_WhenIndexAlwaysChecked_NumEqualsLiveCount
   └─ Empty_WhenCalledAnytime_ThenIsEmpty
```

高复杂度用**种子随机操作流**（可复现）：

```text
输入: Seed=20260826, Ops=1000, 操作集={Add, Insert, RemoveAt, RemoveAtSwap, Pop, AddUnique}
验证: 每一步后跑全部不变量
复现: 只报 Seed + 失败步号
```

### 10.2 PureOutput：只验生成物

```text
PureOutput
├─ Fill
│  ├─ Init_WhenValueAndCount_ProducesNCopies
│  ├─ Sequence_WhenMake0ToN_ProducesContiguousInts
│  ├─ RepeatAppend_WhenPatternAB_ProducesABAB
│  └─ Defaulted_WhenAddDefaultedN_ProducesNDefaultElements
│
├─ Snapshot
│  ├─ Builder_WhenFixedRecipe_MatchesGoldenArray
│  └─ Nested_WhenBuildMatrix3x3_RowsHaveLength3
│
└─ CapacityShape
   ├─ ReserveNThenAddN_WhenFresh_NumEqualsN
   └─ SetNumGrow_WhenFromEmpty_NumEqualsRequested
```

```text
MakeSequence(5)  =>  {0,1,2,3,4}
```

先证明夹具可信，后面 RoundTrip 才有意义。

### 10.3 InputOutput：入参 + 黄金输出

表驱动。每一行是 `In + Op + Out`，失败时直接 diff 两个数组。

```text
InputOutput
├─ Transform
│  ├─ RemoveValue_WhenDuplicates_RemovesAllMatches
│  │  // In:{1,2,1,3,1} Remove(1) Out:{2,3}
│  ├─ RemoveSingle_WhenDuplicates_RemovesFirstOnly
│  │  // In:{1,2,1} RemoveSingle(1) Out:{2,1}
│  ├─ RemoveAt_WhenMiddle_ShiftsTail
│  │  // In:{a,b,c,d} RemoveAt(1) Out:{a,c,d}
│  ├─ RemoveAtSwap_WhenMiddle_SwapsWithLast
│  │  // In:{a,b,c,d} RemoveAtSwap(1) Out:{a,d,c}
│  ├─ Insert_WhenIndex1_ShiftsRight
│  │  // In:{a,c} Insert(1,b) Out:{a,b,c}
│  ├─ AddUnique_WhenExists_Unchanged
│  │  // In:{a,b} AddUnique(a) Out:{a,b}
│  ├─ FilterEven_WhenMixed_KeepsEvens
│  │  // In:{1,2,3,4} Out:{2,4}
│  └─ Sort_WhenUnsorted_Ascending
│     // In:{3,1,2} Out:{1,2,3}
│
├─ Nested
│  ├─ Flatten_WhenJagged_ConcatenatesRows
│  │  // In:{{1,2},{3},{4,5}} Out:{1,2,3,4,5}
│  └─ RemoveEmptyRows_WhenJagged_DropsEmptyInner
│     // In:{{1},{},{2,3}} Out:{{1},{2,3}}
│
└─ TableCases
   └─ EachRow_WhenGivenCsvOrCppTable_ActualEqualsExpected
```

期望数组必须手写或用独立慢实现，不要用被测代码算 expected：

```cpp
struct FArrayIOCase
{
	const TCHAR* Name;
	TArray<int32> Input;
	TArray<int32> Expected;
};

static const FArrayIOCase RemoveAllOnes[] = {
	{ TEXT("empty"),           {},            {} },
	{ TEXT("no_match"),        {2,3},         {2,3} },
	{ TEXT("all_match"),       {1,1,1},       {} },
	{ TEXT("duplicates_mid"),  {1,2,1,3,1},   {2,3} },
};
```

### 10.4 RoundTrip：去一趟再回来

每条都要写清 **什么算「回来」**。

```text
RoundTrip
├─ Copy
│  ├─ CopyCtor_WhenAny_EqualsSourceAndIndependent
│  ├─ CopyAssign_WhenAny_EqualsSource
│  └─ CopyThenMutateCopy_WhenAddToCopy_SourceUnchanged
│
├─ Move
│  ├─ MoveCtorThenMoveBack_WhenViaTemp_RestoresValues
│  └─ MoveAssignThenMoveBack_WhenViaTemp_RestoresValues
│
├─ Stack
│  ├─ PushThenPop_WhenNTimes_RestoresOriginal
│  └─ PopThenPushSame_WhenNotEmpty_RestoresLast
│
├─ Slice
│  ├─ AppendThenRemoveRange_WhenSuffix_RestoresOriginal
│  │  // A2=A; A2.Append(B); A2.RemoveAt(A.Num(), B.Num()); A2==A
│  ├─ InsertThenRemoveAt_WhenSameIndex_RestoresOriginal
│  └─ ResetThenAppendOriginal_WhenViaSnapshot_RestoresOriginal
│
├─ Archive
│  ├─ NetSerialize_WhenIntArray_LoadsEqualSaves
│  ├─ FBufferArchive_WhenFStringArray_LoadsEqualSaves
│  ├─ FBufferArchive_WhenNestedArray_LoadsEqualSaves
│  └─ FBufferArchive_WhenEmpty_LoadsEmpty
│
├─ View
│  ├─ ArrayToViewToArray_WhenCopyConstruct_EqualsSource
│  └─ ViewMutateDoesNotOwn_WhenSourceCopiedFirst_SourceStable
│
├─ Order
│  ├─ SortThenSort_WhenStableOrInt_Idempotent
│  │  // Sort(Sort(A)) == Sort(A)，不是回到原顺序
│  └─ ShuffleThenSort_WhenInts_EqualsSortedOriginal
│     // Sort(Shuffle(A)) == Sort(A)
│
└─ NotRoundTrip_Documented
   ├─ AddUnique_WhenDuplicates_LosesDuplicates
   ├─ RemoveAtSwap_WhenMiddle_LosesOriginalOrder
   └─ Filter_WhenPredicateDrops_LosesRemovedItems
```

RoundTrip 硬规则：

1. 先留 `Original = Source` 的拷贝，再变 `Actual`
2. 逆操作后 `Actual == Original`
3. 失败时打印 `Seed / Original / Mid / Actual`
4. 不能逆的操作不要塞进 RoundTrip

示例：

```cpp
TEST_CASE("YourGame::Advance::TArray::RoundTrip::AppendThenRemoveRange_WhenSuffix_RestoresOriginal", "[advance][tarray][round-trip]")
{
	const TArray<int32> Original = { 10, 20, 30 };
	const TArray<int32> Suffix   = { 40, 50 };

	TArray<int32> Actual = Original;
	Actual.Append(Suffix);
	REQUIRE(Actual == TArray<int32>{ 10, 20, 30, 40, 50 });

	Actual.RemoveAt(Original.Num(), Suffix.Num());
	CHECK(Actual == Original);
}
```

存档 RoundTrip：

```cpp
TArray<FString> Original = { TEXT("a"), TEXT("b"), TEXT("") };

FBufferArchive SaveAr;
SaveAr << Original;

TArray<FString> Loaded;
FMemoryReader LoadAr(SaveAr);
LoadAr << Loaded;

CHECK(Loaded == Original);
```

### 10.5 高复杂度组合

```text
AdvanceScenarios
├─ NestedMatrix_RoundTrip
│  // TArray<TArray<int32>> 存档再读回，行列值和 jagged 形状都要一样
│
├─ StructWithInnerArray_RoundTrip
│  // struct FBag { FName Id; TArray<int32> Stacks; }
│
├─ ObjectPoolLike_InputOutputAndInvariant
│  // Acquire/Release 序列；0 <= 存活数 <= Capacity，无重复租约
│
├─ InventoryChurn_RoundTripViaSnapshot
│
├─ PartitionRebuild_RoundTrip
│  // 若只保证多重集合：Sort(Rebuild)==Sort(Original)
│
├─ IdempotentOps_PureInput
│  // Empty(Empty(A)) 仍空
│  // AddUnique(AddUnique(A,x),x) == AddUnique(A,x)
│  // Sort(Sort(A)) == Sort(A)
│
└─ Differential_InputOutput
   // 手写期望变换 vs TArray API，两边输出必须相等
```

### 10.6 建议命名与标签

```text
YourGame.Advance.TArray.PureInput.Invariants_WhenSeededRandomOps_Hold
YourGame.Advance.TArray.PureOutput.Sequence_WhenMake0ToN_ProducesContiguousInts
YourGame.Advance.TArray.InputOutput.Remove_WhenDuplicates_RemovesAllMatches
YourGame.Advance.TArray.RoundTrip.Archive_WhenFStringArray_LoadsEqualSaves
YourGame.Advance.TArray.RoundTrip.AppendThenRemoveRange_WhenSuffix_RestoresOriginal
YourGame.Advance.TArray.RoundTrip.ShuffleThenSort_WhenInts_EqualsSortedOriginal
YourGame.Advance.TArray.Advance.NestedMatrix_WhenArchived_LoadsEqualSaves
YourGame.Advance.TArray.NotRoundTrip.RemoveAtSwap_WhenMiddle_LosesOriginalOrder
```

```text
[advance][tarray][pure-input]
[advance][tarray][pure-output]
[advance][tarray][io]
[advance][tarray][round-trip]
```

先做这 8 条：

1. `Invariants_WhenSeededRandomOps_Hold`（PureInput）
2. `Sequence_WhenMake0ToN_ProducesContiguousInts`（PureOutput）
3. `Remove_WhenDuplicates_RemovesAllMatches`（InputOutput）
4. `RemoveAtSwap_WhenMiddle_SwapsWithLast`（InputOutput）
5. `AppendThenRemoveRange_WhenSuffix_RestoresOriginal`（RoundTrip）
6. `Archive_WhenFStringArray_LoadsEqualSaves`（RoundTrip）
7. `NestedMatrix_WhenArchived_LoadsEqualSaves`（复杂 RoundTrip）
8. `ShuffleThenSort_WhenInts_EqualsSortedOriginal`（规范形 RoundTrip）

第 1 条失败看 Seed；第 3/4 条失败 diff In/Out；第 5/6/7 条失败 dump Original vs Loaded。

---

## 11. 更复杂的测试情况

再加一批「多步 + 中间态 + 回滚/对照」场景。

```text
TArrayAdvanceTest.Complex
├─ TransactionRollback
├─ ReplayLog
├─ NestedJagged
├─ StructOfArrays
├─ RotateAndWindow
├─ MergeDiff
├─ IndexSidecar
├─ PointerLifetime
└─ CrossContainer
```

### 11.1 事务回滚

模拟「先改数组，失败则回到快照」。背包、技能栏最常见。

```text
TransactionRollback
├─ Commit_WhenAllOpsValid_KeepsFinalArray
│  // In: {A,B}  Op: Add(C), RemoveSingle(A)  Out: {B,C}
├─ Rollback_WhenMidOpIllegal_RestoresSnapshot
│  // Snapshot={A,B}
│  // Add(C) 成功，再 RemoveAt(99) 被守卫拒绝
│  // Out 必须回到 {A,B}，不能停在 {A,B,C}
└─ NestedRollback_WhenInnerFails_OuterAlsoRestored
```

工作副本和快照必须是深拷贝。

### 11.2 操作日志回放

```text
ReplayLog
├─ Replay_WhenSameSeedTwice_ProducesSameArray
├─ Replay_WhenLogArchived_LoadsAndReplaysEqual
└─ Replay_WhenPartialLog_MatchesPrefixState
```

```text
Op: Add(7) | Insert(0,3) | RemoveAt(1) | AddUnique(7) | Empty | Append({1,2})
```

随机压力测试失败时，用日志当最小复现。

### 11.3 锯齿矩阵

```text
NestedJagged
├─ FlattenRoundTrip_WhenKeepRowBreaks_RestoresShape
│  // 展平同时记下每行长度 {2,0,3}，再按长度切回
├─ DeleteEmptyRows_ThenRestoreByMask_RoundTrip
├─ Archive_WhenJaggedHasEmptyInner_LoadsEqualSaves
│  // {{1,2}, {}, {3}} 存档，空内层不能丢
└─ Transpose_WhenRectangular_ThenTransposeAgain_Restores
   // 仅矩形：T(T(M)) == M；锯齿矩阵标 NotRoundTrip
```

`Flatten` 必须带 **shape sidecar**，否则回不去。

### 11.4 结构体套数组

```cpp
struct FSlot
{
	FName ItemId;
	int32 Count;
	TArray<FName> Gems;
};
TArray<FSlot> Loadout;
```

```text
StructOfArrays
├─ Archive_WhenSlotsContainEmptyGems_LoadsEqualSaves
├─ RemoveSlot_WhenMiddle_DoesNotStealNextSlotGems
│  // In: [剑{红}, 盾{}, 弓{蓝,绿}] RemoveAt(1)
│  // Out: [剑{红}, 弓{蓝,绿}]
├─ DuplicateSlot_WhenCopyStruct_InnerArrayIndependent
└─ SortByItemId_WhenCountsDiffer_GemsStayWithOwner
```

专门抓浅拷贝 / 内层数组串台。

### 11.5 旋转、滑窗、环形缓冲

```text
RotateAndWindow
├─ RotateLeftK_ThenRotateRightK_Restores
├─ Rotate_WhenKGreaterThanNum_EquivalentToKModNum
├─ SlidingWindowSum_WhenWindow3_MatchesManualTable
│  // In:{1,2,3,4,5} Window=3 Out:{6,9,12}
└─ RingBuffer_WhenPushExceedsCap_OverwritesOldest_CountBounded
   // Cap=4，推入 10 个，Num<=4，内容是最后 4 个
```

### 11.6 合并与差分

```text
MergeDiff
├─ MergeSorted_WhenTwoAscending_ProducesAscending
│  // InA:{1,3,5} InB:{2,3,8} Out:{1,2,3,3,5,8}
├─ Diff_WhenFromAToB_PatchThenApply_RestoresB
│  // A 应用补丁后 == B
├─ UniqueStable_WhenDuplicates_KeepsFirstOrder
│  // In:{b,a,b,c,a} Out:{b,a,c}
└─ Intersect_WhenOrderFromLeft_KeepsLeftOrder
   // InA:{a,b,c,d} InB:{c,a,x} Out:{a,c}
```

### 11.7 旁路下标表

数组本体 + 一张并行的 Index/Id 表，两边必须一起变。

```text
IndexSidecar
├─ Add_WhenNewItem_AppendsValueAndIndex
├─ RemoveAt_WhenMiddle_BothTablesDropSameIndex
├─ Compact_WhenHasHoles_RemapsSidecarIds
└─ Lookup_WhenIdMissing_ReturnsIndexNone_NoSubscript
```

```text
Invariant:
Values.Num() == Ids.Num()
Ids 无重复
Find(Id) 要么 INDEX_NONE，要么 Values[Index] 是对应项
```

接近实体列表、组件存储。

### 11.8 指针寿命

```text
PointerLifetime
├─ HeldElementPtr_WhenGrowPastMax_MustNotBeDereferenced
│  // 记录 Grow 前 GetData()，Grow 后只允许比较地址是否变化
│  // 禁止解引用旧指针当断言
├─ MidAlgorithm_WhenInsertDuringIndexLoop_NeedsRecheckNum
└─ View_WhenSourceReset_IsNotRoundTrip
```

验证的是规范，不是「旧指针还能读到值」。

### 11.9 跨容器往返

```text
CrossContainer
├─ ArrayToSetToArray_WhenNoDup_SortEqualsOriginalSorted
├─ ArrayToSetToArray_WhenHasDup_LosesDuplicates_NotRoundTrip
├─ ArrayToMapById_ThenValues_RestoresUniqueIds
└─ KeysFromMap_WhenInsertedInOrder_MayNotPreserveArrayOrder
```

能回的是**多重集合 / 集合**，不是原顺序。

### 11.10 三条最值得先写的复杂剧本

**剧本 A：存档往返 + 空内层**

```text
Given:  Loadout = [
          {Sword, 1, [Red]},
          {Shield, 1, []},
          {Bow, 2, [Blue, Green]}
        ]
When:   FBufferArchive << Loadout; 再读到 Loaded
Then:   Loaded == Loadout
        Loaded[1].Gems.Num() == 0
        Loaded[2].Gems[1] == Green
```

**剧本 B：事务失败回滚**

```text
Given:  Snapshot = {10, 20, 30}
When:   Working.Add(40)                 // 成功
        TryRemoveAt(Working, 99)        // 非法，失败
        失败则 Working = Snapshot
Then:   Working == {10, 20, 30}
        Snapshot 仍是 {10, 20, 30}
```

**剧本 C：差量同步**

```text
Given:  A = {1, 2, 2, 3}
        B = {2, 3, 4}
When:   Patch = Diff(A, B)
        C = Apply(A, Patch)
Then:   C == B
And:    Apply(A, Diff(A, A)) == A
```

复杂用例只是把这些断言嵌进：多步操作、快照 / 日志、内层容器、逆操作或补丁。

```text
CHECK(Actual == Expected);
CHECK(Values.Num() == Ids.Num());
CHECK(Find(Id) == INDEX_NONE || IsValidIndex(Find(Id)));
```

先落地剧本 A/B/C，再补 Jagged Flatten、RingBuffer、Sidecar。这三条覆盖存档、失败恢复、网络差分。

---

## 12. 总落地顺序

1. 定命名：`happy-path` / `sad-path` / `edge-cases`，用例名 `{Action}_When{Condition}_{Outcome}`
2. 用 LLT 骨架，先写包装函数和基础 8 条
3. 补 Query / Remove / Add 三支正确性
4. 补扩容保内容、ctor/dtor 平衡、`INDEX_NONE` 守卫
5. 立 Advance 四类协议，先做第 10.6 节那 8 条
6. 再写复杂剧本 A/B/C
7. 性能单独 `[perf]`，Soak 走 Gauntlet

---

## 13. 参考链接

- unit-tests-skills：<https://github.com/clear-solutions/unit-tests-skills>
- CuriousLearner test-generator：<https://github.com/CuriousLearner/devkit/blob/main/skills/test-generator/SKILL.md>
- Superpowers TDD：<https://github.com/obra/superpowers/blob/main/skills/test-driven-development/SKILL.md>
- UE Low-Level Tests 写法：<https://docs.unrealengine.com/5.3/en-US/write-low-level-tests-in-unreal-engine/>
- UE 构建与运行 LLT：<https://dev.epicgames.com/documentation/en-us/unreal-engine/build-and-run-low-level-tests-in-unreal-engine>
- UE TArray 文档：<https://dev.epicgames.com/documentation/unreal-engine/array-containers-in-unreal-engine>
