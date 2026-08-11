# Cache Pack、StaticJIT 与 UE Live Coding 设计说明

> 状态：非规范性说明文档。本文记录 2026-08-09 围绕 Cache V2
> 物理文件数量、aggregate Pack、SQLite 取舍、StaticJIT 稳定化及 UE Live
> Coding 增量 DLL 的讨论结论。若本文与冻结 spec、wire 或 `design.md`
> 冲突，以规范性文档为准。

## 1. 结论摘要

当前方向保持不变：

1. Cache V2 V1 使用领域专用的不可变文件/CAS Store、aggregate Pack、完整
   Generation Manifest 和原子指针；不采用一函数一文件，也不把所有 payload
   存入 SQLite。
2. `N` 个 aggregate Pack 不是预先配置的固定文件数。`N` 是把当前需要写入
   的 canonical Record 按确定性顺序、目标大小和硬限制聚合后的结果；小缓存
   可以只有一个 Pack。
3. Pack 可以承载一批新 Record，但它不是需要按时间顺序回放的差分补丁。
   每个 Manifest 都描述一份完整逻辑 Generation，并可直接引用多个新旧 Pack。
4. aggregate Pack 与 UE Live Coding Patch DLL 只在“旧产物不原地修改、生成新
   产物、验证完成后切换、无人引用后回收”这一生命周期模式上相似；Pack
   本身不是 DLL，也不包含机器码、函数指针或 Native 路由。
5. 真正对应“增量生成 DLL”的是兄弟变更
   `refactor-as-static-jit-external-module`：变化函数生成确定性的 StaticJIT
   C++ slice，经 Live Coding 编译/链接成为补丁 DLL，验证新 Provider 后才
   原子刷新 Native/VM route snapshot。
6. Cache V2 能为 StaticJIT 提供稳定函数身份和执行内容身份，从而让 StaticJIT
   按函数精确匹配、局部失效并安全回退 VM；Pack/Manifest/Generation 的物理
   状态不参与 Native Entry 身份。
7. StaticJIT 的稳定性不能只靠 Cache Hash。它还需要版本化 Provider ABI、
   `NativeEnvironmentFingerprint`、逐 Entry 的 `EntryAbiHash`、Engine-owned
   immutable routes、在途调用生命周期和热重载 profile 的跨函数路由。
8. 文件/CAS 与 SQLite 的最终选择不决定 StaticJIT 是否稳定。StaticJIT 只消费
  共享的稳定语义身份；Cache 后端、Pack target 或 compaction 变化不得改变
   Native route eligibility。

## 2. aggregate Pack 是什么

Cache V2 的逻辑层包含 SourceIndex、ModuleInterface、TypeSchema、ModuleState、
FunctionBody、DebugSidecar 和 ModuleSnapshot 等独立、内容寻址的 Record。

逻辑 Record 不等于磁盘文件。多个 Record 的 canonical semantic payload 会被
聚合到同一个 `.aspack`：

```text
逻辑记录：

Record A
Record B
Record C
Record D
Record E
Record F

物理文件：

Pack 01
├── Record A payload
├── Record B payload
├── Record C payload
└── Record D payload

Pack 02
├── Record E payload
└── Record F payload

Manifest
├── Record A -> Pack 01 / offset / sizes / codec / checksum
├── Record B -> Pack 01 / offset / sizes / codec / checksum
├── Record C -> Pack 01 / offset / sizes / codec / checksum
├── Record D -> Pack 01 / offset / sizes / codec / checksum
├── Record E -> Pack 02 / offset / sizes / codec / checksum
└── Record F -> Pack 02 / offset / sizes / codec / checksum
```

`RecordId` 表示 Record 的规范语义内容；`PackId` 是整个最终物理 Pack 文件的
BLAKE3-256。相同 Record 可以因物理聚合、压缩或位置不同出现在不同 Pack 中，
其 `RecordId` 不变，但 `PackId` 可以不同。

## 3. 为什么是 N 个 Pack，而不是固定一个 Pack

`N` 是结果，不是配置常量。生产 Writer 对待写 Record 执行以下确定性过程：

1. 重新计算并验证每个 `RecordId` 和 `RawChecksum`；
2. 按完整 `RecordId` 排序；
3. 折叠内容完全相同的重复 Record，拒绝同 ID 不同内容；
4. 移除已经位于可复用合法 Pack location 的 Record；
5. 对剩余 Record 独立应用规范化存储压缩策略；
6. 按确定性顺序贪心追加到当前 Pack；
7. 若继续追加会超过目标 raw payload、最大索引条目或最大物理 Pack 大小，
   则封闭当前 Pack并创建下一个；
8. 大于 grouping target 但未超过硬上限的单 Record 独占一个 Pack；
9. 永不产生空 Pack。

V1 的默认 grouping policy 为：

```text
TargetRawBytesPerPack          =  64 MiB
MaxCanonicalRecordPayloadBytes = 64 MiB
MaxStoredRecordBytes           = 64 MiB
MaxPackBytes                   = 128 MiB
MaxPackIndexEntries            = 262,144
MaxGenerationPacks             = 4,096
```

其中 `64 MiB` target 统计 canonical uncompressed semantic payload，不统计
Record envelope。`MaxGenerationPacks=4096` 是资源/恶意输入安全上限，不是正常
目标文件数。

第一份全量 Generation 的 Pack 数可粗略理解为：

```text
N ≈ ceil(待聚合 canonical payload / 64 MiB)
```

但真实结果还受单 Record 大小、索引条目数、物理文件上限、重复内容和已存在
Pack 复用影响。例如 18 MiB payload 可以只有一个 Pack；150 MiB payload 通常
形成约三个 Pack。

## 4. 为什么不只用一个巨大 Pack

Pack 是不可变、按完整文件内容寻址的：

```text
PackId = BLAKE3_256(CompleteFinalPackBytes)
```

如果所有缓存只有一个 500 MiB Pack，修改一个 20 KiB FunctionBody 也会改变
最终文件字节和 `PackId`。Writer 必须重新组装、写出、校验并发布整个 500 MiB
对象，同时在旧 Reader 退出前保留旧文件。这会产生很高的写放大、峰值磁盘
和发布延迟。

有界 Pack 允许新 Generation 复用未变化 Pack，只为新 Record 写新 Pack：

```text
Generation N
├── Pack A
├── Pack B
└── Pack C

修改少量函数后：

Generation N+1
├── 继续引用 Pack A 中的可达 Record
├── 继续引用 Pack B 中的可达 Record
├── 继续引用 Pack C 中的可达 Record
└── 新增 Pack D，容纳变化后的 Record
```

有界 Pack 还限制单次文件读取、完整性校验、解压、内存分配和并行任务的资源
规模。

## 5. 为什么也不使用一函数一文件

一 Record 一文件能够把单次写入缩到最小，但会把项目中的函数、类型、模块
状态和调试记录放大为大量小文件，带来 NTFS metadata、目录枚举、文件句柄、
open/close、杀毒扫描、复制、同步、备份和清理成本。

三种方案的主要取舍为：

| 物理方案 | 文件数 | 小修改写放大 | 启动/元数据成本 |
|---|---:|---:|---:|
| 单一巨大 Pack | 最少 | 最大 | 少量 open，但单对象很大 |
| 一 Record 一文件 | 最大 | 最小 | 大量文件与 metadata 操作 |
| 有界 aggregate Pack | 有界且较少 | 可控 | 顺序读取和随机定位均可控 |

aggregate Pack 是两个极端之间的折中，不是为了人为增加文件数量。

## 6. 增量发布后 Pack 数为什么可能暂时增加

旧 Pack 不能原地修改，因为它可能仍被当前 Reader、`Previous` Generation、
`PendingColdStart`、崩溃恢复或另一个 Engine/进程引用。连续热重载可能形成：

```text
Generation 1 -> Pack A, Pack B
Generation 2 -> 复用 A/B + 新 Pack C
Generation 3 -> 复用 A/B/C 中的可达记录 + 新 Pack D
```

因此当前 Manifest 的可达 Record 可能分散在多个新旧 Pack 中；`Packs/` 目录
中的物理文件数也可能大于当前 Manifest 实际引用数，因为 `Previous`、
`PendingColdStart`、在途 Reader、延迟删除和崩溃孤儿可能暂时保留文件。

这不是永久 Patch 链。显式 compaction 会：

1. 从保留的 Current/Previous/Pending roots 重新标记可达 Record；
2. 以当前 source/profile 再验证候选；
3. 将当前可达内容重新确定性聚合；
4. 发布新的完整 Generation；
5. 在旧 Reader 释放后清理不再被任何保留 root 引用的 Pack。

compaction 不在启动关键路径自动执行。历史不可达 Pack 是空间成本，不是正确
性失败。

## 7. Pack 不是顺序回放的差分补丁链

虽然新增 Pack 常常只包含本次新增或改变的 Record，但 Loader 不执行：

```text
加载 Pack A
    -> 应用 Pack B 差分
        -> 应用 Pack C 差分
```

每个 Generation Manifest 都是一份完整逻辑快照索引：

```text
Manifest Generation 3
├── Function X -> Pack A / offset ...
├── Function Y -> Pack C / offset ...
├── Type Z     -> Pack B / offset ...
└── Module M   -> Pack C / offset ...
```

Loader 从选中的 Manifest 直接定位完整可达图，不需要从第一代开始回放历史。
因此启动时间不会因发布过多少代而线性增长。物理 Pack 可跨 Generation 共享，
但逻辑 Generation 始终是完整、原子选择的。

## 8. 与 UE Live Coding Patch DLL 的相似和不同

两者相似的只是生命周期模式：

```text
旧产物保持不可变
    -> 为变化内容生成新产物
        -> 完整验证
            -> 在安全点发布新视图
                -> 无人引用后回收旧产物
```

承载内容和运行机制不同：

| Cache aggregate Pack | Live Coding Patch DLL |
|---|---|
| 缓存数据文件 | 可执行机器代码模块 |
| 存储 semantic Record payload | 存储编译后的函数、符号和重定位信息 |
| 由 Manifest 按 `PackId + offset` 定位 | 由模块装载/Live Coding 机制链接和重定向 |
| 不允许函数指针、UObject、vtable 或 numeric FunctionId | 包含可执行地址和 Native 符号 |
| 可以跨进程重启复用 | 用于当前构建/运行的 Native 模块更新 |
| 物理重组不改变语义 `RecordId` | 编译或 ABI 变化可能改变 Native Entry |
| 失败时重新编译/恢复 VM artifact | Patch 失败时不发布新的 Native route |

因此：

```text
aggregate Pack
≈ 缓存数据层的不可变增量分片

StaticJIT slice + Live Coding Patch DLL
≈ 可执行代码层的增量生成、编译和加载
```

## 9. Cache V2 与 StaticJIT 的完整分层

一次 `.as` 函数体修改的目标流程为：

```text
编辑 B.as
    |
    v
当前 AS 编译/恢复成功
    |
    +---------------- Cache V2 ----------------+
    |                                           |
    |  生成 B 的新 FunctionBody Record          |
    |      -> 写入新 aggregate Pack             |
    |      -> 发布完整 Manifest/Generation      |
    |      -> VM 立即拥有当前正确实现            |
    |                                           |
    +---------------- StaticJIT ----------------+
                                                |
       旧 B Native Entry 的 ContentHash 失配    |
           -> B 暂时走当前 VM                   |
           -> 显式 Generate/Refresh             |
           -> 生成变化的 StaticJIT C++ slice    |
           -> Live Coding 编译 Patch DLL        |
           -> 新 Provider 注册                  |
           -> 精确 Hash/ABI 校验                 |
           -> 安全点发布新 route snapshot       |
           -> B 重新切回 Native                 |
```

如果生成、编译、Patch 或 Provider 验证失败，受影响函数继续走 VM；已匹配的其他
Native Entry 与 Cache V2 都不失效。

## 10. Cache V2 如何帮助 StaticJIT 稳定

旧 StaticJIT 依赖进程内 `uint32 FunctionId`、process-global `FJITDatabase` 和
whole-cache random `DataGuid`。这些值会随进程、注册顺序和整包生成变化，不适合
跨重启或按函数判断 Native 产物。

Cache V2 建立的共享身份层提供：

```text
StableFunctionKey
FunctionContentHash
ArtifactProfileKey
```

StaticJIT Provider 在此基础上增加 Native 专用坐标，逐函数精确匹配：

```text
StableFunctionKey
+ FunctionContentHash selected by provider profile
+ EntryAbiHash
+ NativeEnvironmentFingerprint
```

含义如下：

- `StableFunctionKey`：稳定识别逻辑函数声明和 owner；
- `FunctionContentHash`：标识当前可执行语义，不是编译前 Cache lookup 摘要；
- `ArtifactProfileKey`：区分兼容性、上下文、调试/执行等 artifact profile；
- `EntryAbiHash`：覆盖该 Native Entry 实际依赖的调用约定、类型布局、绑定符号
  和 bridge/layout；
- `NativeEnvironmentFingerprint`：覆盖平台、架构、target/config、UE build、
  Unreal AngelScript fork ABI、StaticJIT generator、compiler/toolchain 和优化/
  调试环境。

所有权必须保持分离：

```text
Cache V2 owns:                     StaticJIT owns:

source authority                  Provider ABI/catalog
FunctionInputDigest               NativeEnvironmentFingerprint
Record/Pack/Manifest              EntryAbiHash
Generation publication            ProviderGeneration
Current/Previous/Pending          engine-owned route snapshot
retention/compaction              Native/VM selection
```

`Cache GenerationId` 与 `StaticJIT ProviderGeneration` 是不同身份域。Cache
物理 repack、压缩、Pack target 调整、指针轮换或 compaction 不得刷新 Native
route；Provider 到达/离开或 Live Coding 失败也不得让有效 Cache Record 失效。

## 11. StaticJIT 仍需独立关闭的稳定性条件

共享身份是必要地基，但不足以单独证明 StaticJIT 稳定。兄弟变更仍需完成：

1. 版本化、带 `StructSize`/`AbiVersion` 的 Provider ABI；
2. Provider catalog 与完整 256-bit 身份比较；
3. 每个 Engine 在成功 AS 编译/恢复后建立临时
   `StableFunctionKey -> current function/FunctionId` 映射，且永不序列化；
4. 离线完整验证并在 Engine compile/safe-point lock 下原子发布 immutable
   route snapshot；
5. 在途调用继续持有旧 snapshot/Provider，直到调用释放，避免卸载后悬空；
6. Provider 缺失、卸载、内容失配、ABI 失配和 Live Coding 失败时逐函数回退
   当前 VM；
7. UASFunction 等热重载包装不得长期缓存过期 JIT entry pointer；
8. 确定性 C++ slice/bucket 生成和 byte-different-only 文件写入；
9. Editor/PIE、多个 AS Engine、virtual dispatch、异常、引用/对象返回和线程场景
   的 VM/Native parity 测试。

## 12. 热重载 Native caller 不能直连旧 callee

最危险的情况是 A 的内容未变并继续使用旧 Native Entry，但 A 的机器码直接
调用已经变化的旧 `B_v1` symbol：

```text
Native A_v1
    -> direct call Native B_v1

B 已经修改并成为 B_v2
```

即使 Runtime 已经把当前 B 路由回 VM，A 仍可能绕过 route 执行旧 B。故
hot-reloadable profile 的 script-to-script 调用必须通过 callee 的 stable key 和
当前 Engine route：

```text
Native A
    -> InvokeCurrentRoute(StableFunctionKey(B))
        -> exact Native B if matched
        -> otherwise current VM B
```

virtual/override resolution 必须先完成，再选择 Native 或 VM。Cooked immutable
profile 只有在完整 provider artifact-set digest 与 environment fingerprint 全量
匹配时，才可恢复 Native-to-Native direct call；不允许混入不完整、可能指向旧
符号的 direct-call 集合。

## 13. StaticJIT slice 为什么也应分成 N 个固定 bucket

如果所有生成代码都放进一个巨型 `.cpp`，修改一个函数也可能重新编译整个翻译
单元。兄弟 StaticJIT 设计采用固定 project-module buckets：

```text
ReadLE64(StableFunctionKey.Bytes[0..7]) mod BucketCount
```

当前默认 bucket count 为 32。bucket `.cpp` 在 scaffold 时一次创建，活动 Live
Coding 会话不增删翻译单元；函数内容以 content-addressed slice 更新，生成器只
替换 byte-different 文件。

Pack 与 StaticJIT bucket 不能共用分组策略：

- Cache Pack 按完整 `RecordId` 排序、payload target 和物理上限聚合，优化磁盘
  写放大、读取、压缩和 compaction；
- StaticJIT bucket 按 `StableFunctionKey` 稳定映射，优化翻译单元稳定性、编译
  时间和 Live Coding 变更范围。

它们共享“有界增量分片”思想，但身份、内容和目标不同。

## 14. Editor、Live Coding 与 packaged 行为

Editor/PIE 中推荐的行为是：

```text
.as 修改
    -> 普通 AS hot reload 保持权威
    -> 变化/缺失 Native Entry 立即回退 VM
    -> 不自动启动 C++ 生成或 Live Coding
    -> 用户显式 Generate/Refresh StaticJIT
    -> 有 Live Coding 时请求编译并等待 PatchComplete
    -> 验证出现更新且精确匹配的 ProviderGeneration
    -> 安全点刷新 routes
```

如果 Live Coding 不可用，生成仍可成功，但新 Native Entry 要等完整 build/restart
后才可用。StaticJIT project module 必须先 scaffold 并至少完成一次完整 Editor/
Game build，才属于活动 target 并可由 Live Coding 后续更新。

packaged end-user 启动不运行 UBT、C++ compiler 或 Live Coding。随包 Provider
精确匹配的函数走 Native；失配或缺失函数走 VM。恢复 Native 需要发布新的构建/
Provider，而不是让终端用户现场生成 DLL。

## 15. 与 SQLite 决策的关系

SQLite 可以提供单文件事务、索引和查询能力，但不负责以下核心正确性：

- stable function/content/profile identity；
- source authority 和精确依赖失效；
- module-atomic activation；
- Native ABI/Provider eligibility；
- Engine-owned route publication；
- Live Coding 失败后的 VM fallback。

把每个 Record 存成 SQLite row 会改变当前 wire/store 形状并引入数据库恢复、WAL、
checkpoint、VACUUM 和 UE wrapper/copy 成本；把整个 Pack 只当一个 BLOB row 则
基本重复现有 Manifest/CAS，并没有解决额外问题。

因此 V1 继续使用普通不可变 aggregate Pack 文件。若未来实测瓶颈明确来自海量
metadata、任意查询或多进程协调，可增加可重建的 SQLite metadata index，或在
保持逻辑/身份层不变的条件下替换 Store backend。不能仅因为目录中有多个 Pack
就改用 SQLite。

## 16. 文件数量的实际预期

缓存文件不是按函数数量增长。一个 namespace 的正常文件形状近似：

```text
Packs/<PackId>.aspack                  一到若干个
Generations/<GenerationId>.asmanifest 少量保留代
Current.ascurrent                      一个
Previous.ascurrent                     一个
PendingColdStart.ascurrent             零或一个有效指针文件
```

例如约 200 MiB canonical payload、64 MiB target 且历史碎片较少时，主要数据
通常是约 3--4 个 Pack，加少量最近增量 Pack 和 Manifest/Pointer。真实数量必须
通过 benchmark 记录，而不能只凭设计目标宣称。

至少应比较 4、16、64 MiB target，并记录：cold store creation、warm restore、
单函数 edit 写入字节/Pack 数、随机 lookup、峰值内存、文件句柄、并发 Reader、
crash injection 和 compaction 成本。

## 17. 当前实现状态与边界

截至本文记录时：

- stable artifact identity baseline 已建立；
- Manifest/aggregate Pack 处于 Approved RED，生产 Pack/Manifest 生成和 Store
  尚未全部实现；
- StaticJIT external module 已有 proposal/design/spec，但不能据此宣称 Provider、
  routes、Live Coding refresh 已经稳定落地；
- 本文记录的是已讨论并与当前设计一致的方向，不是实现完成或性能验证结论。

## 18. 相关权威和调研文档

- Cache V2 架构边界：`design.md`
- Pack/Manifest V1 字节与聚合规则：`manifest-pack-wire-v1.md`
- Store publication、retention 和 compaction：`store-publication-v1.md`
- `.as` 变化、逻辑记录和物理 Pack 流程：
  `cache-v2-flow-and-change-classification.md`
- ccache、sccache、ThinLTO、Bazel/REAPI、UE DDC 与 SQLite 对比：
  `external-cache-design-research.md`
- 上述参考项目的成熟度、可采信边界、不能外推的项目自定义组合，以及高/中/
  未生产验证三档信心：`external-cache-design-research.md` 第 11 节
- StaticJIT Provider、route 与 Live Coding：
  `../refactor-as-static-jit-external-module/design.md`
- StaticJIT 变更目标：
  `../refactor-as-static-jit-external-module/proposal.md`
