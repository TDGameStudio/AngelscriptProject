# SourceHistory：用注释标记收齐带 reload 的 AS 测试

## 已定结论

不需要 `.reload.as` 这种特殊后缀。

有 reload 的测试就是一份普通 `.as`。用规范化注释标记描述版本树；**diff 由注释生成**；导入 C++ 时把生成的 diff 带进代码库。识别靠文件头 `@Harness SourceHistory`。

```
.as 正文              = @version root（合法程序）
注释里的 @change      = 某一版完整源码（可以非法）
工具 unified_diff     = 父 → 子的边（导入 C++ 的交换格式）
C++                   = 只存 root 正文 + 各标签的生成 diff
                        用到哪一版就 apply 哪张 diff
静态检查              = 按标签抽出每一版，按 @expect 编过 / 编不过
```

C++ 不要再手写第二份 `ASTEST_AS`，也不要手写 `@@` hunk。auditor 看见 `@Harness SourceHistory` 就走树检查，不走 Function / UClass inventory。

示例：

- `TestSource/HotReload/AddModifyLookupFlow.as` — `root` → `body-update`（soft，编过）
- `TestSource/HotReload/FailureKeepsOldCodeAndDiagnostics.as` — `root` → `broken-type`（soft，编不过，last-good）

---

## 1. 为什么不用 `.reload.as`

特殊后缀只是为了躲开普通 inventory。真正常用的是标记：

- Function / UClass / Reject 已经在用 `@Theme` `@Kind` `@Covers`
- Reload 只是同一套标记多了 `@version` `@parent` `@change`
- auditor 看见 `@Harness SourceHistory` 就走树检查，和文件叫什么无关

手写 `@@ -4,6 +4,6 @@` 容易在空格/Tab 上翻车。注释里放 **下一版完整源码**（或以后的 span 替换），diff 由工具算出来，apply 失败就是生成器的 bug，不是语料写错 hunk。

---

## 2. 一份 `.as` 里有什么

```
AddModifyLookupFlow.as
├── 开篇 /** */     文件级标记（含 @Harness SourceHistory）
├── 根版本 AS 正文   合法程序，标签固定 root
└── 收尾 /* */      版本树：@version / @parent / @change / @expect …
```

磁盘上每个场景仍是 **一个** `.as`。不要 `Before.as` + `After.as`，也不要 sidecar。

非法版本（`MissingType`）不能当文件正文，只出现在某个节点的 `@change` 里。正文始终是能编过的 root。

---

## 3. 封闭标记表

表外 `@名字` 视为错误。

### 文件头 `/** */`

`@Theme` `@Subject` `@Harness`（必须 `SourceHistory`）`@Tag` `@Module` `@Identity` `@Tree`（可选，默认 `@Tag` 末段）`@Provenance`（可重复）

`@Tag` 末段 = 文件名去掉 `.as`。跨文件依赖用 `@Tree@version`。

### 收尾版本树 `/* */`

| 标记 | 谁需要 | 含义 |
|---|---|---|
| `@version <tag>` | 每个节点 | 提取键，文件内唯一。`root` 保留给正文 |
| `@parent <tag>` | 非根 | 父版本 |
| `@compile` | 每个节点 | `Initial` / `SoftReloadOnly` / `FullReload` / `Analyze` / `NoChange` / `Delete` |
| `@expect` | 每个节点 | `compile-ok` 或 `compile-fail "<片段>"` |
| `@change` … `@end` | 非根 | **子版本的完整源码**（可非法）。用来生成 diff，不是手写 hunk |
| `@retain` `@oracle` `@onto failed` | 可选 | 过渡预言 / 叠在失败产物上 |
| `@depends <Tree>@<version>` | 可选 | 可重复。另一棵树须先处于该 version（不合并源码） |
| `@path <name>` 后接步骤 | 可选 | 一次测序：`<Tree>@<version>` 列表，可跨树 |

同一文件内的源码变化是 **单父树**（可分支，不是只能一条链）。多模块场景是 **多棵树**，用标签互相依赖，见第 8 节。

---

## 4. 注释 → 生成 diff → 导入 C++

对每个非根节点：

```
child  = 该节点 @change 文本
parent = extract(@parent)
diff   = unified_diff(parent, child)     ← 生成物
assert apply(parent, diff) == child      ← 契约：生成的 diff 必须能打回去
```

`extract(root)` 就是文件正文。`extract(tag)` 就是该节点 `@change`。

生成的 diff 是给代码库和 C++ 的交换格式，例如：

```
TestSource/Generation/ReloadDiffs/AddModifyLookupFlow/body-update.diff
```

或编进 C++：

```
FString Root = ExtractReloadVersion(TEXT("AddModifyLookupFlow"), TEXT("root"));
FString Next = ApplyReloadDiff(Root, GeneratedDiff("AddModifyLookupFlow", "body-update"));
```

C++ **不要**手写第二份 `ASTEST_AS` 正文，也不要手写 hunk。它只保存：根源码（或从 `.as` 读正文）+ 各标签的生成 diff。需要哪一版就 `apply` 哪张 diff。

整树静态检查：每个 `@version` 抽出源码，按 `@expect` 编一次（ok 必须过，fail 必须不过且诊断匹配）。行为（实例还活、`GetValue==5`）仍是 C++ `@oracle`。

---

## 5. 和「测序」的关系

每个带 reload 的测试场景 = 一份 SourceHistory `.as`。注释是集合索引，生成的 diff 是版本之间的边。导入 C++ 时把这些边带进测试模块，按标签取版本，按 `@compile` 选 Soft/Full，按 `@path`（若有）决定回放顺序。

不要把 Observe `UFUNCTION` 写进版本源码。不要用 `#if VERSION`。不要改磁盘 `Script/` 来模拟 reload。

---

## 6. 示例（AddModifyLookupFlow）

正文只保留 root。下一版写在 `@change` 里，diff 不手写：

```angelscript
/**
 * @Theme HotReload
 * @Subject HotReload.FunctionBody
 * @Harness SourceHistory
 * @Tag HotReload.FunctionBody.AddModifyLookupFlow
 * @Module HotReloadModifyLookupFlow.as
 * @Identity UHotReloadModifyLookupFlow
 */

UCLASS()
class UHotReloadModifyLookupFlow : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 1;
	}
}

/*
@version root
@compile Initial
@expect compile-ok

@version body-update
@parent root
@compile SoftReloadOnly
@expect compile-ok
@oracle execute UHotReloadModifyLookupFlow.GetValue == 2
@change
UCLASS()
class UHotReloadModifyLookupFlow : UObject
{
	UFUNCTION()
	int GetValue()
	{
		return 2;
	}
}
@end
*/
```

工具对 `root` 与 `body-update` 的 `@change` 做 `unified_diff`，并断言 `apply(root, diff) == body-update`。C++ 侧：

```
Root = 读该 .as 的正文
Next = ApplyReloadDiff(Root, GeneratedDiff("AddModifyLookupFlow", "body-update"))
Compile(Root) / SoftReloadOnly(Next)
```

失败 last-good 同理：`FailureKeepsOldCodeAndDiagnostics.as` 的 `@version broken-type` 在 `@change` 里放 `MissingType` 源码，`@expect compile-fail "MissingType"`，`@oracle` 仍是 `GetValue == 5`。生成的 diff 照样导入 C++，只是 compile 预期为失败并滚回 root。

---

## 7. 不要做的

- 不要发明 `.reload.as` 后缀（已否决）
- 不要表外 `@` 标记
- 不要用 `#if VERSION` 把多版叠进真源码
- 不要在 root 正文或 `@change` 里加测试用 `namespace` / `Observe_*`
- 不要 sidecar、不要并列 `Before.as` / `After.as`
- 不要用 git 仓库当版本树
- 不要为模拟 reload 去改磁盘 `Script/`
- 不要给同一 `@version` 写两个 `@parent`（一份源码不能同时打两份 diff）
- 不要把两个无关模块的源码塞进同一个 `.as` 正文充「双树」

---

## 8. 树的形态：不只有线性

两个示例都是 `root → 一子`，容易看成只能线性。约定从一开始就是 **树**，还可以是 **林**。

一份 `.as` 的正文只有一个模块，所以 **一文件 = 一棵源码树**（单父、可扇出）。多模块 = 多份 `.as` = 多棵树。测序用标签把树串起来，而不是把两份程序糊进一个文件。

全局版本地址：`<场景Tag末段>@<version>`，例如 `AddModifyLookupFlow@body-update`。未写场景时，默认本文件。

### 8.1 三种单树形态

**链（linear）** — 必须按顺序叠在同一份源码上：

```
root ──body-update──► flags-update ──signature──► …
```

`@parent` 指向前一版。C++ 按链回放：先 apply `body-update`，再 apply `flags-update`。

**扇出（branch）** — 同一 root 上互不叠的两种改法：

```
          ┌── body-update        SoftReloadOnly
root ─────┤
          └── signature-change   FullReload
```

两个子节点的 `@parent` 都是 `root`。静态检查分别抽 `body-update` 和 `signature-change`，都相对 root 生成 diff。不要为了分支再拆两个几乎相同的 `.as`。

**失败枝（last-good）** — 子节点 `@expect compile-fail`，默认不把失败源码当作后续 `@parent`：

```
root ──broken-type（fail，滚回 root）
```

只有写了 `@onto failed` 的后续节点才叠在失败产物上。

### 8.2 林：多文件、多棵树、标签依赖

跨模块 reload（provider 改了、consumer 的 import 还在）是 **两棵树**，不是一条链上的三个 `@change`。

现有语料 `ProviderSoftReloadRebindsDeclaredImportConsumer` 应对应两份 SourceHistory：

```
HotReloadDependencyProvider.as          树 P
  P@root          SharedValue() return 11
  P@body-update   SharedValue() return 29     @parent P@root

HotReloadDependencyConsumer.as          树 C
  C@root          import SharedValue; Entry()
                  @depends HotReloadDependencyProvider@root
```

测序用 `@path` 点名 **跨树步骤**（顺序就是编译/reload 顺序）：

```
@path provider-rebind
    HotReloadDependencyProvider@root
 -> HotReloadDependencyConsumer@root      @oracle Entry()==11
 -> HotReloadDependencyProvider@body-update
 -> HotReloadDependencyConsumer@root      @oracle Entry()==29
```

consumer 这一版源码没变，变的是它 **依赖的那棵树** 的标签。`@depends` 声明「抽本节点时，对方模块必须已经处于某 version」；`@path` 声明一次 CQTest 怎么走。静态检查仍按树、按节点编；跨树 oracle 归 C++。

`@depends` 可重复。只表达 **模块版本前提**，不把对方源码 merge 进本文件。

### 8.3 文件头补的标记

| 标记 | 必填 | 含义 |
|---|---|---|
| `@Tree` | 否 | 本文件这棵树的短名，默认等于 `@Tag` 末段。给 `@depends` / `@path` 用 |
| `@depends <Tree>@<version>` | 否 | 写在 **版本节点** 上：该节点要成立，另一棵树须先处于该 version |

`@path` 步骤写成 `<Tree>@<version>`。本树可省略 Tree，只写 `@version`。

### 8.4 抽源码时怎么走依赖

```
extract(Tree@version):
    只 apply 该树从 root 到 version 的 @parent 链
    不把 @depends 的对方源码拼进本模块

play(@path):
    按步骤顺序：对每个 Tree@version
        抽出该模块源码
        按该节点 @compile 编进对应模块槽
        跑该步 @oracle
```

同一模块在 path 上连续两个 version，就是一次 reload；不同模块交替，就是依赖方 reload。

### 8.5 明确禁止的「更富」

| 想做的 | 为什么不做 |
|---|---|
| 一个 `@version` 两个 `@parent`（DAG 合并） | 两份 diff 打同一 buffer 无定义，冲突不是 reload 语义 |
| 一个 `.as` 正文里两个 root | 一份正文只能是一个模块的 root |
| 用 `#include` 把 provider 正文嵌进 consumer 树 | 跨树用 `@depends`，保持模块边界 |

要「更丰富」就加 **分支、多树、`@depends`、`@path`**，不要加 merge。
