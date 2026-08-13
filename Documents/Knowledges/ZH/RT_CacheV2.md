# Cache V2：存储、改动识别、依赖与测试思路

> 整理自 2026-08-13 围绕新版增量 Cache 的几轮讨论。
> 操作与排障以 `Documents/Guides/AngelscriptCacheV2_ZH.md` 为准。
> 规范与变更分类以归档 OpenSpec `openspec/changes/archive/2026-08-11-refactor-as-incremental-function-cache/` 为准。
> 测试树结构问题见 `Documents/Guides/CacheV2TestReview_20260813.md`。

本文先给通俗总览，再写测试分层、改动分类、磁盘/字节码、互相依赖、自动 import、强制重编、启动编挂和冷/热启动怎么量。

---

## 0. 通俗总览

把它想成一套 **脚本编译结果的智能仓库**，目的只有一个：下次启动或热更时少编一点，又绝对不能拿错过期的代码去跑。

AngelScript 从 `.as` 编到能跑，要预处理、解析、生成类型、编函数。项目一大，全编会很慢。旧办法是打成 **一个大包裹** `PrecompiledScript.Cache`：声明、类型、全局、所有函数的字节码搅在一起。改一个 `Tick`，整包都很难只留下其余部分。新 Cache 换成 **仓库**：货按种类分开放，改了哪包只换哪包；没改的继续用货架上原来那一段。

最高原则：**磁盘上的 `.as` 永远是对的。** 缓存对不上就重编或启动失败，绝不为了“能开游戏”去跑另一份旧源码编出来的东西。旧整包启动时已经不再打开。

### 仓库地址

实现代码在 `Plugins/Angelscript/Source/AngelscriptRuntime/Cache/`。真正的货在：

```text
Saved/Angelscript/CacheV2/
    <CompatibilityHash>/      哪种机芯（格式 / 引擎 / 平台）
        <ContextHash>/        哪种片库设定（Editor/Shipping、自动 import…）
            Current.ascurrent           门口小牌子：现在用哪一代
            Previous / Pending…         必要时的上一份、PIE 冷启动候选
            Generations/某代.asmanifest 这一代的目录（单号 → 货在哪袋）
            Packs/某袋.aspack           很多货挤在一个袋子里
```

- **CompatibilityHash**：换了会读错的东西——文件格式版本、字节码编解码、UE 版本、平台、指针宽度。
- **ContextHash**：格式能读，但编译环境不同——Editor 还是游戏、Development 还是 Shipping、自动 import、`#if` 开关、脚本挂载。
- 改 `.as` **不会换这两层目录**。天天开同一个编辑器，通常就一棵树。热更换的是树里面的 Manifest / Pack / Current 指针。

袋子里不是“一个函数一个文件”，而是很多逻辑货挤在少量 `.aspack` 里。目录（Manifest）靠快递单号 **RecordId** 找到某一段。

### 七种货

| 货 | 人话 |
|----|------|
| SourceIndex | 进货清单：发现了哪些 `.as`、原始文件指纹、include 关系 |
| ModuleInterface | 这个模块对外怎么打招呼：有哪些函数/类型、签名是什么 |
| TypeSchema | 一个类型长什么样：继承、属性、内存布局 |
| ModuleState | 这个模块的全局变量和初始化（整份一起，不能拆开用一半） |
| FunctionBody | 一个函数真正能跑的那包（字节码 + 它用过谁） |
| DebugSidecar | 这个函数的行号，和能不能跑分开存，Shipping 可以没有 |
| ModuleSnapshot | 购物小票：这个模块是由上面哪些货组装成的 |

记货、复用可以很细（按函数、按类型）。端给引擎用必须整模块一起上：不能新类型 + 旧全局 + 一半新函数混成正在跑的模块。函数的字节码就在 FunctionBody 那包货里。

### 快递单号 RecordId

每一包已验证的货有一个单号：这是哪种货 + 这包内容的指纹。

- **找货**：Manifest 拿单号去对应 Pack 的某一段取货。
- **判断能不能复用**：热更后再算一遍。和上一代一样 → 继续用旧 Pack 里那一段；不一样 → 新写一包，目录改挂新单号。
- **别存两份一样的**：内容相同则单号相同。

`Tick` 还叫 `Tick`（名字没变），实现改了 → 这包货的单号换了。没改的 `Jump` 单号照旧。`CompatibilityHash` / `ContextHash` 是进哪栋仓库；`RecordId` 是这栋仓库里这一包货的单号。

### 改脚本之后怎么知道编谁

不靠文件名猜测，也不靠文本逐行 diff。

1. 先看进货清单：哪些 `.as` 的原始字节变了。没变且环境也对 → 整仓热启动，预处理/解析/编译都可以是零。
2. 变了的模块重新看一遍语义。
3. 按改动类型决定动哪几包货：只改函数体通常只换那一个 FunctionBody；改签名还要动对外说明书和按旧签名调用的人；改属性动类型说明书以及真正摸过这块布局的函数；改全局则整份模块全局状态重做；只加注释则清单变了，要重新看一遍证明语义没变，能跑的那包往往还能用。
4. **相关代码**不是“import 过这个文件的全部作废”，而是上次编译记下的边：这个函数当时用过谁、当时对方的布局/调用约定指纹是什么。边对不上的才重编。

自动 import 下源码里往往没有 `import` 行。编译器用到哪个别的模块的名字，就记一条边。普通调用默认只依赖对方的签名，不依赖对方函数体。

### 什么时候写盘

不是关编辑器再偷偷全编一遍。启动编过或保存热更成功，当时就把能用的结果冻成货，后台装袋、换门口的 Current 牌子。关机最多再等几秒，把已经冻好、正在写的那笔写完，不再扫描、不再编译。

```text
旧: 一个大纸箱，什么都塞进去。掏一件容易把整箱打翻。

新: 仓库。货分种类、有单号、可以按包换。
    门口一块小牌告诉你现在用哪一代目录。
    换机芯（引擎/格式）或换片库设定（Editor/Shipping）就另开一栋库，避免拿错货。
```

文件比“一个 .cache”多，是因为要增量、要崩溃时不写坏正在读的袋子。日常真正干活的往往就是一块牌子 + 一份目录 + 一两个袋子；变多通常是热更堆了旧代，或换过环境留下了另一栋隔间。

一句话：**Cache 是按“货”而不是按“整个脚本工程”存的编译结果仓库；改脚本换的是相关货的单号，不是仓库地址；对不上就重进货，绝不拿过期货充数。**

### 过程案例

下面用同一个小工程走五遍。假设只有两个脚本：

```text
Combat.as                         Damage.as
  void Tick() {                     class UDamageSet
      ApplyDamage(Health);            UPROPERTY() int Armor;
      Health.Armor += 1;            }
  }                                 void ApplyDamage(UHealthSet H) { ... }
  void Jump() { ... }               （自动 import，Combat 没写 import 行）
```

目录始终是同一棵 `compatX/ctxEditorDev/`（没换引擎、没换 Shipping）。变的是树里面的货。

#### 案例 A — 第一次启动（冷仓）

盘上没有能对上的 Cache。

```text
算 compat / ctx  →  走进（或新建）那棵目录
看 Current 牌子  →  没有, 或 SourceIndex 对不上现在的 .as
        │
        ▼
整份源码正常编一遍（预处理 / 解析 / 编函数）
        │
        ▼
冻成货:
  SourceIndex          进货清单（两个文件的原始指纹）
  ModuleInterface ×2
  TypeSchema(UDamageSet, …)
  ModuleState ×2
  FunctionBody Tick / Jump / ApplyDamage
  ModuleSnapshot Combat / Damage
        │
        ▼
后台装进 Pack1, 写 Manifest0
门口牌子 Current → Manifest0
```

原理：没有可复用的货，只能现编现入库。下次启动要比的就是这份清单和这些单号。

#### 案例 B — 什么都没改，再开一次（热启动）

`.as` 一个字节没动，Editor/设定也没换。

```text
还是 compatX / ctxEditorDev     ← 目录没换
读 Current → Manifest0
比进货清单 SourceIndex
        │
        两个文件原始 Hash 一样
        include / 选项一样
        │
        ▼
整仓 restore: 预处理=0 解析=0 编译=0
从 Pack1 按单号取出 FunctionBody, 在新引擎里重建 FunctionId
```

原理：清单对得上就整仓信任这一代，不再问“Tick 改没改”。这是最快的路径。

#### 案例 C — 只改 Tick 函数体

`Tick` 里把 `+ 1` 改成 `+ 2`。`Jump`、`ApplyDamage`、类型、签名都没动。

```text
目录还是同一棵
SourceIndex 对不上     ← Combat.as 原始字节变了
        │
        ▼
只把受影响模块重新 Parse（Combat；Damage 文件没变）
        │
        ▼
比各包单号:
  Tick          源变了 → FunctionBody 新单号, 只重编 Tick
  Jump          单号一样 → 继续用 Pack1 里那一段
  ApplyDamage   Combat 只依赖它的签名, 签名没变 → Hit
  TypeSchema    没动 → Hit
  ModuleState   没动 → Hit
        │
        ▼
新写 FunctionBody_Tick'
重写 Combat 的 ModuleSnapshot（小票改挂新 Tick）
新 SourceIndex + Manifest1
Pack2 里往往只有这几包新货
Current → Manifest1
Manifest1 里 Jump 仍指向 Pack1 旧段
```

原理：文件变了只说明“Combat 要重新看”，不是“Combat 里所有函数重编”。调用方默认只认签名，所以 `ApplyDamage` 实现没改、签名没改，不用动。

#### 案例 D — 改 ApplyDamage 的参数（签名变了）

`void ApplyDamage(UHealthSet H)` 改成还多一个 `int Amount`。

```text
Damage.as 原始字节变了 → SourceIndex miss
        │
        ▼
Parse Damage, 再顺着边看 Combat
        │
        ▼
ApplyDamage 的 StableFunctionKey / 签名变了
  Damage.ModuleInterface     新单号
  ApplyDamage FunctionBody   新单号（新签名就是新身份）
        │
Combat.Tick 边上记着:
  用过 ApplyDamage, 当时 ExpectedAbi = 旧签名
  现在对不上 → Tick 也 Miss, 重编
Jump 没调用 ApplyDamage → Hit
        │
        ▼
先重编 Damage, 把新货 overlay 回去
再发现 Combat.Tick 要对新签名, 再编 Tick
拼新 Snapshot, Manifest2, Current 换代
```

原理：相关不是“谁 import 了 Damage.as”，而是 Tick **上次记下的边**。自动 import 下 Combat 源码里没有 `import`，照样能被拉进来。只改 `ApplyDamage` **函数体、签名不变** 时，这条边还对得上，Tick 不用重编——那是案例 C 的镜像。

#### 案例 E — 只加了一行注释

`Combat.as` 顶部加 `// tmp`。

```text
SourceIndex miss          原始 Hash 变了, 必须重新看
重新 Preprocess / Parse
        │
canonical 语义没变
  Tick / Jump FunctionBody   单号仍一样 → Hit
  TypeSchema / ModuleState   Hit
  DebugSidecar               行号可能变了 → 只换行号包
        │
        ▼
新清单 + 可能新的 DebugSidecar
能跑的那包继续用 Pack 里旧段
```

原理：注释也会让“进货清单”对不上，所以不能走案例 B 的零工作热启动；但看完语义后，执行袋往往还能用。

#### 六条对照

```text
A 冷启动     没货, 全编, 建仓库
B 再开不变   清单对上, 零编译
C 改函数体   清单变, 只换那一包; 调用方通常不动
D 改签名     说明书变, 边上记过旧签名的人一起重编
E 只改注释   清单变, 必须再看一眼; 能跑的货常常还能用
F 关着改坏   触发重编但编挂: 不激活旧 Cache, 不换牌子

全程不变: CompatibilityHash / ContextHash
会变的:   SourceIndex、相关 RecordId、GenerationId（这一代目录）
```

#### 案例 F — 关着编辑器改坏了 `.as`，再开

盘上有上一回成功的 Current，但磁盘源码已经编不过。

```text
ExactStartup 比 SourceIndex
        │
        对不上现在的 .as     ← 触发重编, 不是整仓 restore
        │
        ▼
按现在的源码预处理 / 解析 / 编函数
        │
        编不过
        │
        ▼
不激活任何脚本模块
不换 Current 牌子          ← 旧 Manifest/Pack 仍在盘上, 但没装进引擎
不发布新一代
        │
   ┌────┴────┐
编辑器      打包 / -unattended / commandlet
弹窗卡住    立刻退出, 状态码 3
修完保存
再 FullReload
编过了才冻货、换牌子
```

原理：Current 对的是**上一份**源码。新源码编不过，绝不能拿旧货冒充当前工程。热更失败是「内存里已有 last-good，继续跑旧模块」；启动第一次就编挂，内存是空的，旧 Cache 只是门口没摘的牌子。

---

## 1. 一句话原则

`.as` 源码始终是正确性权威。缓存按函数、类型、模块状态等语义记录细粒度复用，但模块恢复与激活保持原子。磁盘上不原地改一个巨大的 `.cache`，而是发布由不可变 Pack、Manifest 和原子 generation 指针组成的新一代。

旧 `PrecompiledScript.Cache` 引擎启动已不再打开。没有 reader、migration、dual-write，V2 失败也不会退回 V1。

---

## 2. 测试思路

Cache 测试不是“编译一段脚本再看绿没绿”，而是把 Cache V2 当成**会落盘、必须跨进程复现的二进制契约**。

### 2.1 证据层级不能互相替代

| 层级 | 只能证明什么 |
|------|----------------|
| 单文件编译 | 声明/语法在 |
| 模块链接 | 符号在 |
| 聚焦 Automation | 这一条命名行为 |
| 集成 | 真的走生产 compile / restore / publish |
| PIE / 真包 | 环境行为 |

TypeSchema 矩阵绿了，不代表热启动能命中。`ColdGeneration` 绿了，也不代表 Shipping 第二次启动能复用。真进程验收是独立的 `CachePackage` suite，不进官方 `All`。

实现顺序：有界 RED → TU 能编能链 → 冻结 SHA/字节/行形 → 独立 review → GREEN → 再补聚焦行为和集成。因此会有大量 exact offset / golden / captured coordinate：它们是被审核冻结的权威，不是普通回归样例。

### 2.2 按 Cache 自己的层拆

```text
身份 / 规范 wire
    → Budget / 候选所有权
    → 七种 record 的解码工厂
    → TypeSchema / 布局
    → 模块图
    → Manifest / Pack
    → Store 事务（Current / Previous / Pending）
    → 源码失效分类（body / 签名 / 类型 / 全局）
    → 编译器挂接与复用
    → 引擎 / 编辑器 / PIE 生命周期
    → StaticJIT 桥（JIT 挂了不能让 Cache 变合法）
```

失败时应能看出坏在哪一层。普通 suite 不应带上真包成本。

### 2.3 两类测试

**A. 无引擎的格式权威**（占行数大头）

TypeSchema、SourceInterface、ManifestPack、Archive envelope/primitive、RemainingRecord 坐标、Budget。通常不编译 `.as`，手搓 DTO / 原始字节，锁枚举数值、字段顺序、截断/别名/checksum、分配时间线。observer 打开或关掉，产出字节和 Budget 必须一样。

**B. 有引擎的契约测试**

典型是两个 IsolatedFull 引擎：

1. Producer 编译权威 `.as` → `CleanCapture` 收成无指针 record
2. 写入隔离 `Saved/Automation/.../Guid` 根
3. 销毁 Producer（不依赖进程内指针）
4. Consumer 新引擎 `Validate` + `Restore`
5. 断言能执行，或 miss / 回滚后模块数不变

主路径：冷生成、精确热启动、增量、PIE 的 `PendingColdStart`、失败保住 last-good。`CleanOracleMutation` 是失效分类写得最清楚的一组。

允许窄 seam 观察内部不变量（分配、offset），但禁止第二套 decoder。每个 seam 要自证：observer 在/不在结果相同；Shipping 构建没有这些符号。

### 2.4 目录为什么显得乱

设计意图清晰，落地变成「一个 OpenSpec slice = 一个新 TU = 一份克隆夹具」。`AngelscriptTest/Cache/` 现约 103 个平铺 `.cpp`、0 个头文件、约 540+ 个 `TEST_METHOD`。计划中的共享 pack/options/工程根 helper 没抽。

读产品契约优先看：`ColdGeneration`、`ExactWarmStartup` / `ProductionWarmStartup`、`CleanOracleMutation`、`FreshEngineRestore`（Rollback 文件目前误挂同一前缀）、`EditorLifecycle` / `PIE`。真包走 `CachePackage`。TypeSchema 那 1.6 万行是 pack 兼容权威，不是“改一行脚本后能不能热启动”。

---

## 3. 改动怎么识别

不靠文本行 diff，也不靠文件名/正则猜“这是类改动还是函数改动”。分两阶段：

1. Source Scan 比较可直接发现的输入，用上一代持久化的 Include/Generated/Preprocess candidate 缩小受影响模块。
2. 受影响模块重新 Parse，按 `StableFunctionKey`、`FunctionInputDigest` 和语义 RecordId 决定 Hit 还是 Compile。

### 3.1 总流程

```text
当前磁盘上的 .as / include / define / options / mount
                    |
                    v
        +---------------------------+
        | Stage 0  Direct Inventory |
        | 原始字节 Hash             |
        | Mount / Provider / Options|
        | Source -> Module          |
        | 上一代 Include/Generated  |
        | candidate 依赖            |
        +---------------------------+
                    |
         全部精确匹配? ----是----> SourceIndex Hit
                    |                    |
                    否                   v
                    |         零 Preprocess / 零 Parse / 零 Compile
                    v
        +---------------------------+
        | Stage 1  Preprocess       |   仅 candidate miss 才跑
        | 找出消费者闭包            |   消费者文件字节可以没变
        +---------------------------+
                    |
                    v
        +---------------------------+
        | Stage 2  Parse / 声明     |
        | ModuleInterface           |
        | TypeSchema / ModuleState  |
        +---------------------------+
                    |
                    v
        +---------------------------+
        | Stage 3  语义分类         |
        | 比 RecordId / Key / Digest|
        | 不比文本行                |
        +---------------------------+
                    |
                    v
        +---------------------------+
        | Stage 4  依赖传播         |
        | 上次 compile 记下的       |
        | 实际依赖 fingerprint      |
        +---------------------------+
                    |
                    v
              失效闭包并集 → Hit 复用 / Miss 重编
              模块原子激活，发新 generation
```

四层粒度：

```text
发现变化     =  源码文件 / include / options
重新解析     =  受影响 Module
复用 / 重编  =  Interface / TypeSchema / ModuleState / FunctionBody / DebugSidecar
对外激活     =  整个 ModuleSnapshot（原子）
```

一个 `.as` 通常对应一个 Module。文件变了会重新 Parse，但没变且依赖仍成立的函数会直接 Hit。

### 3.2 分类树（不是互斥）

一个文件可以同时改 property、函数体和 global，最终失效集合是所有闭包的并集。

```text
受影响 Module 已重新 Parse
            |
            v
   声明 / 签名 / Owner / Qualifier 变了?
            +-- 是 --> ModuleInterface / Owner TypeSchema / caller 闭包 Miss
            v
   Property / 基类 / 接口 / 布局 / 反射 变了?
            +-- 是 --> TypeSchema / 结构依赖 / 摸到该布局的 FunctionBody Miss
            v
   Global / 常量 / initializer / 顺序 变了?
            +-- 是 --> 整份 ModuleState Miss + hard-value 消费者
            v
   StableFunctionKey 相同, 但函数 canonical AST 变了?
            +-- 是 --> 仅该 FunctionBody Miss
            v
   函数源码没变, 但它记下的 ABI / 布局 / 值依赖变了?
            +-- 是 --> 该 FunctionBody 安全 Miss（相关代码可在别的文件）
            v
   只是行号 / debug 映射变了?
            +-- 是 --> 通常只 DebugSidecar Miss
```

函数身份分层，避免“改个 Category 就当成新函数”：

```text
StableFunctionKey   这个逻辑函数是谁（名 / owner / 种类 / 签名 / qualifier）
SignatureHash       调用形状 + 声明/反射调用语义
TraitsHash          声明 trait、反射 flag、metadata
FunctionContentHash 可执行语义
EntryAbiHash        StaticJIT Native 入口契约
```

- 只改函数体 → Key 不变，Content 变 → 只重编这个 FunctionBody
- 只改 `Category` / `DisplayName` → Key 不变，重建声明/UFunction，函数体常可复用
- 改 `Server` / override → Key 常不变，但调用语义变 → 函数体和 JIT route 也失效
- 改名 / 换 owner / 换函数种类 → 新 Key

### 3.3 “相关源码”三条边

```text
                    +------------------+
                    |  被改的输入       |
                    +--------+---------+
                      /       |       \
                     v        v        v
           Include/Define   语义 Record   环境 Binding
           图               身份变化      ABI fingerprint
                     \        |        /
                      +-------+-------+
                              v
              上一次 compile 记下的实际依赖
              未改源码的 caller 也可以安全 miss
```

1. **预处理相关**：`A.as` 改了 include/define。`B.as` 自己没改，SourceIndex 图把它拉进闭包，重新 Parse 后再按语义分类。
2. **声明/结构相关**：类型加了 property。真正读过这块布局的函数靠上次记下的依赖 miss。
3. **环境相关**：不用整张 binding 表面总哈希。记录只存实际用到的符号 fingerprint。

只改 `Tick` 函数体：该 FunctionBody Miss，同模块其它函数 / TypeSchema / ModuleState Hit，新 Manifest 继续引用未变 Pack。

只加注释：SourceIndex Miss，必须重新 Parse 证明语义没变；执行袋和类型常仍可 Hit，行号变了则 DebugSidecar Miss。

---

## 4. 磁盘存什么，字节码在哪

### 4.1 源码目录 vs 产物目录

`Plugins/Angelscript/Source/AngelscriptRuntime/Cache/` 是**实现代码**，不存放用户脚本产物。真正的字节码在工程：

```text
<Project>/Saved/Angelscript/CacheV2/
    <CompatibilityHash>/          插件/VM/wire 兼容代
        <ContextHash>/            Editor vs Shipping, debug sidecar 等
            Current.ascurrent     小指针: 指向哪份 Manifest
            Previous.ascurrent
            PendingColdStart.ascurrent
            Generations/<GenerationId>.asmanifest
            Packs/<PackId>.aspack
```

`.as` 源码不进 Cache。权威源仍是 `Script/` 等 loose 文件。

可用 `-as-cache-root=` 覆盖根目录。测试用 `Saved/Automation/AngelscriptCache*/<Guid>`。

### 4.2 Runtime `Cache/` 源文件职责

```text
身份 / 类型
    Types.h                    七种 RecordKind, RecordId, 读限制
    StableSymbolIdentity.*     当前 Engine 符号 -> 稳定 Key
    Environment*.*             环境 ABI / Profile / Context 哈希

编解码
    Archive.*                  信封, RecordId, 公共 primitive
    SemanticRecords.*          SourceIndex / ModuleInterface DTO
    TypeSchema.*               类型/布局/反射权威
    RemainingRecordTypes.h     ModuleState / FunctionBody / DebugSidecar / Snapshot
    RemainingRecords.cpp       上面四种序列化
    DecodedRecord.*            唯一的七种 record 工厂
    FunctionArtifactCodec.*    VM 字节码 / debug 的不透明 payload
    Private/*Codec.h           内部 wire

物理存储
    ManifestPack.*             record → Pack + Manifest
    Store.*                    根目录, 读写 generation
    StoreLock / Pointer /
    Compaction / AtomicFileOps 锁, Current 指针, 回收, 原子换文件

发现 / 捕获
    SourceDiscovery.*          找 .as
    SourcePlanner.*            直接输入 + 第一层 digest
    CurrentModuleAuthority.*   编译前的声明/布局权威
    CleanCapture.*             编译成功 → 无指针 record
    CompilerBridge.*           restore 挂钩, 依赖 canonicalize
    CompileReuse.*             同一趟编译里 Hit 复用 / Miss 重编

命中 / 生命周期
    SemanticDiff.*             新旧 RecordId
    DependencyPropagation.*    按实际依赖拉下一波重编模块
    IncrementalGeneration.*    拼下一代 Manifest
    ExactStartup.*             源未变: 零前端 restore
    Restore.*                  新引擎上物化/激活 Snapshot
    ModuleGraph.cpp            Snapshot 图合法性
    Service.*                  每引擎 Current/Previous/Pending
    Settings.* / RuntimeReload 项目设置, 打包热更

诊断
    Diagnostics* / ConsoleCommands / DecisionTrace
```

流水线：

```text
.as 发现          SourceDiscovery / Planner
    → 编译成功捕获  CleanCapture + CurrentModuleAuthority
    → 函数 VM 产物  FunctionArtifactCodec → FunctionBody.CanonicalExecutionPayload
    → 打成磁盘      ManifestPack + Store
    → 下次启动      ExactStartup 或 SemanticDiff + Propagation + CompileReuse + Restore
    → 激活          Service 换 Current 指针
```

### 4.3 七种逻辑记录

| 记录 | 内容 | 常见失效 |
|------|------|----------|
| `SourceIndex` | mount、文件、原始 Hash、include/generated、options | 源码或预处理输入变 |
| `ModuleInterface` | 声明、import、签名、对外 ABI | 声明/签名/owner/import route 变 |
| `TypeSchema` | 一个类型的继承/属性/布局/反射 | 结构、布局、反射、enum 变 |
| `ModuleState` | 全局、常量、initializer、顺序（原子） | 任一 global/init/order 变 |
| `FunctionBody` | 稳定函数身份、依赖边、VM 执行袋 | 函数逻辑或实际依赖指纹变 |
| `DebugSidecar` | 行号/源映射 | 行映射变；Shipping 可省略 |
| `ModuleSnapshot` | 该模块引用了上面哪些 record | 任一必需组成变 |

逻辑 record ≠ 磁盘文件。多条 payload 挤进少量 Pack（目标约 64MiB），Manifest 当目录。

```text
                    Manifest
                       |
         +-------------+--------------+
         |                            |
   SourceIndex                   每个模块一个
                                 ModuleSnapshot
                                      |
           +------------+------+------+------+------------+
           |            |      |             |            |
    ModuleInterface  TypeSchema*  ModuleState  FunctionBody*  DebugSidecar?
```

取舍：持久化尽量细；组装/激活必须整模块原子。不能把新 TypeSchema + 旧 ModuleState + 一半新函数暴露给 Engine。

### 4.4 字节码具体在哪

不在 `.cpp` 里，也不再整包 `PrecompiledScript.Cache`。

```text
asCScriptFunction (进程内 bytecode / 栈 / 符号表)
        |
        | FunctionArtifactCodec::EncodeExecutionArtifact
        | ExecutionCodecVersion = 6
        | 重定位改成 StableKey, 去掉指针和 numeric FunctionId
        v
FunctionBody
    Identity / SourceDigest / InputDigest
    ActualDependencies[]
    CanonicalExecutionPayload[]   ← 字节码在这里
    DebugSidecar?                 行号另存
        |
        v
Packs/<PackId>.aspack  某一段 offset..length
        ^
        |
Manifest: RecordId(FunctionBody, ContentHash) → Pack / offset / codec
```

Debug 在 `DebugSidecar.CanonicalDebugPayload`。每次启动按稳定符号重定位到**当前** Engine 的 FunctionId，不写回旧指针。

只改 `Tick`：新 Manifest 里 `Jump` 仍指向旧 Pack 同一段；只新写 `FunctionBody_Tick`。旧 Pack 没人引用后再 compaction。

离线查看：

```powershell
python Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py `
    Saved/Angelscript/CacheV2 --json --generation Current
```

编辑器：`as.Cache.Status` / `as.Cache.Explain`。

---

## 5. 互相依赖时谁重编、谁复用

不是把互相依赖的几个 `.as` 揉成一块再一起丢。落盘的是记录图：每条记录有身份，边上带着“我当时看见的对方是谁、ABI/布局/值指纹是什么”。

### 5.1 边上记什么

冷编译成功时记下**真正摸过的**东西：

```text
FunctionBody Tick
├── StableFunctionKey
├── FunctionSourceDigest
├── FunctionInputDigest = H(源, 按序当前依赖指纹)
└── ActualDependencies[]
      ├── Kind = PropertyLayout / Signature / ValueLayout / ...
      ├── Target = 对方 StableKey
      └── ExpectedAbi / ExpectedContentOrValue
```

种类有限：`Import`、`Declaration`、`Signature`、`Inheritance`、`ValueLayout`、`PropertyLayout`、`GlobalStorage`、`HardValue`、`Initializer`、`CompileOption`、`EnvironmentAbi`、`FunctionContent`。

```text
源没变, Health 布局变了     → InputDigest 变 → 这条 FunctionBody Miss
源没变, 无关类型多了字段    → 不在边上       → Hit
```

普通脚本调用默认只依赖 **callee 的声明/调用 ABI**，不依赖它的函数体。只改 `Bar` 实现，调用方 `Foo` 继续 Hit。除非做过 inline / 常量折叠 / 硬值嵌入，那时会多一条 `FunctionContent` 或 `HardValue` 边。

### 5.2 失效之后怎么走

```text
1. 谁自己的 RecordId 变了
2. 谁的边 Expected != 当前权威
3. PlanDependentRecompileWave 输出下一波必须 forced-clean 的模块
   （它自己不编译、不改 Engine）
4. overlay 新 record, 再 plan, 直到 wave 空
5. 不能证明安全 → 保守 safe miss
6. 重装 ModuleSnapshot, 发 generation N+1
   新 Manifest 继续指向没变的旧 Pack 条目
```

`ModuleState` 是原子的：任一 global/init/order 变，整份状态失效，不能单独激活某个旧 initializer。

### 5.3 两种互相引用

**同模块两个 UCLASS 互指**（句柄，不是按值嵌套）：

```text
TypeSchema_Left   property Right → Key(Right), handle ABI
TypeSchema_Right  property Left  → Key(Left)
FunctionBody ReadRightValue      → 依赖 Right.Value 的 PropertyLayout

只给 Right 加一个无关 UPROPERTY:
    TypeSchema_Right     Miss
    TypeSchema_Left      通常仍 Hit（存的是对象引用）
    ModuleSnapshot       仍要重装（激活原子）
    Left 的 TypeSchema 字节可以继续引用旧 Pack
```

若是 **USTRUCT 按值嵌进去**，B 的大小/偏移进了 A 的 TypeSchema，B 改布局则 A 也 Miss。Restore 互指类型时先建两边骨架，再填 property。

**跨模块互相调用**：

```text
只改 B.Bar 函数体, 签名不变
    B.Bar Body Miss
    A.Foo Hit

改 B.Bar 参数
    B.ModuleInterface Miss
    A.Foo 的 Signature 边对不上 → A.Foo Miss
    wave: 先编 B, overlay, 再发现 A
    A 里没碰到 Bar 的函数仍可 Hit
```

循环不会死循环：每波只拉当前对不上的模块，overlay 后再比。

---

## 6. 自动 import 下怎么找模块依赖

默认 `UAngelscriptSettings::bAutomaticImports = true`。显式 `import Foo;` 会被擦掉并可警告，**不驱动编译顺序，也不应作为 Cache 的主依赖表**。

### 6.1 编译时怎么发现

```text
Combat.as 里写了 ApplyDamage / Health.Armor
源码没有 import

asEP_AUTOMATIC_IMPORTS = 1
        |
        v
builder 查名字不看「本模块 import 了谁」
        |
        +-- GetType / DoesTypeExist
        |     → engine->allScriptDeclaredTypes
        +-- GetFunctionDescriptions
              → engine->allScriptGlobalFunctions
        |
        v
符号属于别的 asCModule 时
        |
        +-- MarkDependency                 普通引用
        +-- MarkStructuralDependency       类型/布局/继承
        +-- MarkHardValueDependency        常量/enum 硬值
        |
        v
Combat.ScriptModule->moduleDependencies
    DamageModule → { structural? hard-value? 首次行列号 }
```

| 模式 | 行为 |
|------|------|
| 手动 | 按 import 行排序；`ModuleDesc.ImportedModules` 驱动 Stage1 与热更反向图 |
| 自动（默认） | 不重排文件；依赖 = 编译时 `Mark*` 写入的 `moduleDependencies` |

热更：自动模式会固定点扫谁的 `moduleDependencies` 指向已标记模块。开了 `GAngelscriptRecompileAvoidance` 时先只编改过的文件，再按边上的 structural / hard-value 决定要不要拉其它模块；普通调用边往往只更新引用。

### 6.2 Cache 怎么记

`AutomaticImports=true/false` 是 Profile 编译选项。开关一切，整份 Cache namespace 换代。

跨模块关系主要落在 record 的 `ActualDependencies`（`Signature` / `PropertyLayout` / `ValueLayout` / `HardValue` / `Declaration`…），不是 `ModuleInterface.Imports[]`。后者对应显式 import 声明；自动模式下这些声明本来就被忽略。

```text
不能靠扫源码里的 import 行
        |
        v
编译时 Mark*  →  进程内 moduleDependencies   (热更 / recompile avoidance)
捕获进 Cache →  ActualDependencies + StableKey + 指纹
查找相关模块 →  谁的边上 Target 指向变了的 Key, 且 Expected 对不上
```

注意：

- “没写 import 也能用”是预期。没用到的符号不会进边。
- 不要用 `ImportedModules` 理解自动模式的 Cache。
- 一部分 Cache 捕获竖条还不收带显式 import 声明的模块；默认自动模式反而更贴近主路径。测试里常关掉 `AutomaticImports` 做隔离，和产品默认相反。

---

## 7. 强制重编：Cache 和整套 `.as`

没有两条各干各的命令。强制重编 Cache、强制重编整套 AngelScript，走同一条编译入口，差别只是**能不能用 Cache Hit**。这里的「整套 AS」指 `Script/` 里的脚本，不是 C++ / UHT / StaticJIT 二进制。

| 你想干什么 | 现成入口 | 会不会重编 `.as` | 会不会绕过 Cache |
|---|---|---|---|
| 强制重编全部（或一个）模块，不要用旧字节码 | `as.Cache.ForceClean` / `Module=<canonical 名或 64 位 hex>` | 会 | 会（`CachePolicy = ForceClean`） |
| 打包运行时从磁盘 loose `.as` 再扫一遍 | `as.ReloadScripts` | 会（下一帧安全点） | 不会，还能 Hit |
| 编辑器改完 `.as` 保存 | 没有命令，DirectoryWatcher 自动热更 | 会（改过的文件） | 不会，还能 Hit |
| 只把已冻好的结果刷到磁盘 | `as.Cache.Flush` | 不会 | — |
| 清掉不再被 Current 引用的旧 pack | `as.Cache.Compact` | 不会 | — |

`as.Cache.ForceClean` 就是「Cache + 整体 AS」的强制重编：把选中模块（不写 `Module=` 就是当前全部 active 模块）丢进 `FullReload`，函数级 Hit 全部关掉，每个函数重新走 `asCCompiler`。它**不删** `Saved/Angelscript/CacheV2` 里的文件；旧 pack 还在，要清文件另跑 `as.Cache.Compact`。

没有 `as.RecompileAll`，也没有编辑器菜单「Reload All Scripts」。

- 编辑器日常：改 `.as` → 自动热更。想不管 Cache、整包重来，打 `as.Cache.ForceClean`。
- `as.ReloadScripts` 只在打包运行时有效，编辑器里直接 `Disabled`。默认 packaged 模式也是关的。
- `Status` / `Verify` / `Explain` / `Trace` 都不编译。
- C++ 插件、Bind、UHT、StaticJIT 产物是 Unreal 编译 / Live Coding，不是 AS 命令。

实现落点：`AngelscriptCacheConsoleCommands.cpp` 的 `as.Cache.ForceClean` / `as.ReloadScripts`；引擎侧 `FAngelscriptEngine::ForceCleanCacheModules` → `ProcessQueuedHotReload(FullReload)`。

---

## 8. 启动时 Cache 触发重编，但这回编挂了

和案例 F 同一条安全规则，这里补过程细节。

```text
开编辑器 / 开游戏
        │
        ▼
ExactStartup：Current 的 SourceIndex
能不能对上现在磁盘上的 .as + 编译环境
        │
   ┌────┴────┐
  对上        对不上 / 没货 / 损坏
   │          │
整仓 restore   触发重编（可带着旧一代做函数级 Hit）
预处理=0       预处理 + 解析 + 编函数
```

对不上的常见原因：关编辑器之后改过 `.as`、换了 Editor/Shipping、自动 import、`#if`、脚本挂载。改 `.as` **不会换** `compat/ctx` 目录，只是这一代用不了。

重编出错时：

| | 内存里的脚本 | 磁盘 Cache | 进程接着干什么 |
|---|---|---|---|
| 编辑器（有 Slate、非 unattended） | 一个模块都不激活 | Current 不换代 | 弹出编译错误窗，改完保存再 FullReload |
| 打包 / commandlet / `-unattended` / `-ExitOnError` | 同样不激活 | 同样不换代 | 立刻退出，状态码 **3** |
| ExactStartup 已经把引擎改了一半再失败 | 视为脏引擎 | 不换代 | **连重编都不走**（`FatalPartialRestore`） |

冻货、换牌子的前提是 `!bHadCompileErrors`。`CompileModules` 只要有一个模块编挂，整批 `bShouldSwapInModules = false`：启动时一个 `.as` 写错，其它脚本也不会装上。弹窗会把当时扫到的全部脚本先记进 `PreviouslyFailedReloadFiles`，修完保存是整包再编。

和「已经开着再热更失败」不是一回事：

| | 启动第一次就编挂 | 已经跑起来再热更挂 |
|---|---|---|
| 内存 last-good | 没有 | 有，继续跑旧模块 |
| 日志 | 也会打 `Hot reload failed... Keeping all old script code`（启动时「旧代码」其实是空的） | 这句话是对的 |
| Cache Current | 不前进 | 不前进 |
| 编辑器 | 卡住，不修打不开 | 可以继续用旧脚本 |

`FatalPartialRestore` 极少见：restore 已经往空引擎里塞了一部分模块，再发现不能信。日志是 `A candidate partially mutated the fresh Engine; refusing unsafe compile fallback`。这不是源码语法错，是 Cache restore 半截失败。

查是「Cache 逼着重编」还是「源码自己编不过」：启动加 `-as-cache-trace`，看 `StartupSelection` / `StartupRestore` 是 `Miss` 还是 `Rejected`。`Combat.as: Expected ')'` 才是重编失败的真正原因。没有「启动编挂就自动回退上一份 Cache」的命令。

规范：`openspec/specs/as-incremental-script-cache/spec.md` 里 *Loose source is authoritative over stale cache*。实现：`FAngelscriptEngine::InitialCompile()`、`ResolveAngelscriptStartupCompileFailureResponse`。

---

## 9. 冷启动 vs Cache 热启动怎么量

有三层插桩，但没有「编辑器按钮一键对比」。现有数字能比整次启动，还不能干净拆出「省在预处理 / 解析 / 编函数各多少毫秒」。

### 9.1 真进程基准

`Tools/RunAngelscriptCacheBenchmark.ps1` 对已经打好的 loose package 反复拉进程，隔离 Cache 目录。

| 场景 | 在比什么 |
|---|---|
| `cold-no-cache` | 每次空仓，等于正常全编启动 |
| `unchanged-warm` | 源没变，ExactStartup restore |
| `one-body-edit` | Cache 触发部分重编（只改函数体） |
| `type-schema-edit` / `module-state-edit` | 结构 / 全局状态 miss |
| `diagnostics-Disabled/Summary/Verbose` | 诊断本身贵不贵 |
| `pack-4/16/64-serial/parallel` | 装袋策略，不是启动对比 |

默认 1 次预热 + 3 次测量，写出 `Saved/CacheBenchmark/<Label>/<stamp>/`：`Context.json`、`Plan.json`、`Raw.csv`、汇总（`totalMs` 的 min / median / max），以及每轮 session report、`cache_v2_dump`、进程 log。只看计划：加 `-PlanOnly`。

`totalMs` 是**整进程墙钟**（UE 起来 + AS + 退出），不是纯 `InitialCompile`。小工程里引擎启动噪声会盖过 Cache 收益。2026-08-12 V7.7 那组 38 个 `.as` 的 Development fixture：cold median 11093 ms，warm 14055 ms；warm 恢复了 18 个函数，但仍有 4 个 compiled miss + 4 个 `NotCacheable`。**这组数没有证明启动变快**，不能当宣传数据。

### 9.2 单次启动 session JSON

```text
-as-cache-report=<绝对路径.json>
-as-cache-trace
```

起来后也可用 `as.Cache.Status Json=...` / `as.Cache.Trace Dump`。schema-4 里和性能相关的是：

| 字段 | 含义 |
|---|---|
| `functionReuse.restoredFunctionCount` | 从 Cache 装回来的函数 |
| `functionReuse.compiledMissCount` | 这次真正重编的函数 |
| `functionReuse.notCacheableCount` | 根本不能进 Cache |
| `decisionTrace.events[].elapsedMicroseconds` | `StartupSelection` / `StartupRestore` / `LifecycleFlush` |

对比：空仓或换 `-as-cache-root` → `restored=0`；源一字不改再开 → 理想 restore，preprocess/parse/compiler 为 0；改一个函数体再开 → 少量 `compiledMiss`，其余 restored。`as.Cache.Explain` 只解释为什么 miss，不加总耗时。

### 9.3 引擎内计时

`FAngelscriptScopeTimer`（`AS_PRINT_STATS`）会打：

```
load script files from disk took X ms
script compilation total took X ms
script compilation stage1 and stage2 / class layouting / stage3 / stage4
```

ExactStartup 整仓命中时，后面这些编译 timer **不会走**——日志里没有 `script compilation total`，本身就是走了 Cache。

Unreal Insights / `stat Angelscript`：`Angelscript.Compile.Initial`（整次 `InitialCompile`）、`Angelscript.Compile.Modules`。Insights 里两次启动叠在一起，比整进程 `totalMs` 干净。决策事件的微秒只覆盖选代 + restore，不是后面重编函数的开销。

现在**没有**写进 session JSON 的：预处理/解析/每函数各多少毫秒、Editor 启动的自动 A/B（基准脚本只打 packaged 进程）、机器时间 pass threshold。计时只观测；硬断言是语义和退出码。

日常最小对比：两次启动都带 `-as-cache-report`。第一次空仓（或 `as.Cache.ForceClean` 后再关开），第二次不动源码。两份 JSON 对 `restoredFunctionCount` / `compiledMissCount`，Insights 对 `Compile.Initial`。

---

## 10. 对照备忘

```text
存的是 record 图, 不是「互相依赖的源码包」
边 = Kind + StableKey + Expected 指纹
Hit = 自己的源没变, 且每条边的 Expected 仍等于当前权威
Miss = 自己变了, 或某条真实边断了
模块激活必须整份 Snapshot, 但 Snapshot 里可以混旧 Pack 条目和新 record
只改实现, 调用方默认不用动
只改签名/布局/值, 调用方靠边上的指纹被拉进来
wave 是固定点, 不是一次打掉整张 import 图
自动 import 下依赖是「用到谁记谁」, 不是 import 语句
字节码在 FunctionBody.CanonicalExecutionPayload, 物理上在 .aspack 某段
ForceClean = 整套 .as 强制重编且关掉 Hit; ReloadScripts 只打包且还能 Hit
启动编挂不激活旧 Cache, 编辑器弹窗, 打包退 3
冷/热对比用 Benchmark + session functionReuse + Insights Compile.Initial
小 fixture 的 warm 墙钟不能当加速证据
```

相关入口：

- 使用与排障：`Documents/Guides/AngelscriptCacheV2_ZH.md`
- 测试结构审查：`Documents/Guides/CacheV2TestReview_20260813.md`
- 流程与分类原文：`openspec/changes/archive/2026-08-11-refactor-as-incremental-function-cache/cache-v2-flow-and-change-classification.md`
- 离线 dump：`Plugins/Angelscript/Tools/CacheV2Dump/cache_v2_dump.py`
