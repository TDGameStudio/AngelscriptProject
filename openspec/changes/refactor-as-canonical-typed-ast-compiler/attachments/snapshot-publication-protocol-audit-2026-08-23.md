# Retained AST 快照发布与并发租约审计（2026-08-23）

## 结论

已验证的 Public AST V1 快照路径具备“候选完成后发布”的读者安全协议：读者取得
`asIASTSnapshot` 时，在模块锁内完成引用计数获取；发布者只会把已经 `Seal()` 且通过
verifier 的候选快照放入当前槽位；旧快照在锁外释放，且已有 lease 继续拥有它。失败的
重编译不会触碰最后一个成功 generation。

这次审计纠正了旧任务文字中的一个过时前提：当前 `AcquireASTSnapshot()` **不是**裸读
`astSnapshot` 再 `AddRef()`，而是两项操作同处 `astSnapshotLock` 临界区。因此，不存在
该旧描述所担心的“发布线程先释放、读取线程随后 AddRef 已释放对象”的窗口。

```text
Reader                                      Publisher
------                                      ---------
lock(astSnapshotLock)                       build candidate context
  current->AddRef()                         Seal() + Verify()
unlock                                      lock(astSnapshotLock)
traverse immutable lease                       previous = current
                                               current = candidate
                                               previous.current = false
                                            unlock
                                            previous->Release()    // lock 外；已有 lease 仍有效

failed build:
  no PublishCanonicalASTSnapshot()
  => current remains the last successful sealed generation
```

## 代码审计结果

| 协议点 | 已有实现 | 结论 |
| --- | --- | --- |
| Acquire 的 retain 与读取 | `as_module.cpp::AcquireASTSnapshot()` 在 `FScopeLock` 内 `AddRef()` | 安全 |
| 候选构造顺序 | `PublishCanonicalASTSnapshot()` 先 Seal + Verify + allocate candidate，才进入替换锁 | 不发布半成品 |
| 替换及旧 generation | 锁内替换 current、原子标记 previous 非当前，锁外 Release previous | 已有 lease 可继续读 |
| current-generation 位 | `asCASTSnapshot` 使用 `FPlatformAtomics::Interlocked*` | 并发观察稳定 |
| 失败替换 | Build 失败不调用 Publish；成功 generation 保留 | fail closed |
| StaticJIT generation | `FAngelscriptStaticJITGenerationASTLease` 持有 `asIASTSnapshot` 引用 | generation 不借用无主 AST |

`asCModule::GetCanonicalASTContext()` 仍是一个**内部、无 lease 的借用指针**。2026-08-23
的全 Runtime/Editor 搜索确认，生产读取者已经全部走 `AcquireASTSnapshot()`：StaticJIT
generation 以 `FAngelscriptStaticJITGenerationASTLease` 持有 lease，HIR dump 在读取期间
直接持有 `asIASTSnapshot`，而 Cache V2 Sidecar capture 也已迁移到该协议。剩余直接调用
只在单线程的 CanonicalAST 白盒测试中。该 helper 不能作为跨线程或跨发布边界的 API；后续
迁移不得新增生产使用者。它属于内部测试/迁移观察面，不改变 Public V1 的 lease 合约。

## 新增回归

`AngelscriptNativeASTSnapshotAPITests.cpp` 增加
`FailedRebuildKeepsCurrentSnapshotStableForConcurrentAcquires`：

1. 建立并保留 generation A；
2. 后台读线程连续执行 `AcquireASTSnapshot()`、`IsCurrentGeneration()` 和 TranslationUnit
   view 遍历；
3. 主线程用未定义符号触发一次必然失败的 Build；
4. 断言读线程没有见到空、未封存、非当前或部分 view；
5. 断言最终 current generation key 仍等于 A。

它与已有 `AcquireDuringRebuildOnlyReturnsStableLeases`（64 次成功替换与并发获取）及
`RetainRebuildKeepsOldSnapshotLease`（A/B/失败替换的生命周期）一起覆盖成功和失败发布。

## 验证证据

- 编辑器构建：`Saved/Build/cta-snapshot-failed-publish-concurrency-build/20260823_075551_426_03c885be`，成功（4 actions）。
- 模块快照测试：`Saved/Tests/cta-snapshot-failed-publish-concurrency/20260823_075608_253_b93d8ce7`，**9/9 PASS**。

因此 Task 3.7 的并发/生命周期测试要求已满足。R06/Task 13.8 的剩余工作不是重做这套
已经存在的发布原语，而是随着后续 Cache/StaticJIT/默认编译切换继续禁止任何新的生产
raw-context 借用，并在最终 cutover 验证该约束。

## Cache V2 capture 消费者补齐（2026-08-23）

审计发现 `AngelscriptCacheCleanCapture.cpp::TryCaptureCanonicalASTBodySidecar()` 曾经是
最后一个生产 raw-context 消费者：它从 `GetCanonicalASTContext()` 借用 `asCASTContext*` 后
编码 Sidecar。若另一线程在这段编码期间发布新 generation，旧 snapshot 可以被释放，因而
这个借用并不满足发布协议。

实现已改为下面的边界：

```text
Cache clean capture
  AcquireASTSnapshot(V1) ── null => no retained sidecar (正常 absence)
  hold asIASTSnapshot lease
  cast retained implementation snapshot -> GetContext()
  verify sealed + encode V2 sidecar
  Release lease (scope exit)
```

`AngelscriptStandaloneArchitectureTests` 新增可执行源码契约：该 helper 不得再出现
`GetCanonicalASTContext`，并且必须包含 `AcquireASTSnapshot(asAST_API_VERSION_1)`、
`asCASTSnapshot` 和 `GetContext()`。这个测试先在旧实现上红灯，避免将来仅靠代码评审又引入
同类裸借用。

验证：

- 红灯：Standalone 套件中仅 `AngelscriptStandalone.Architecture` 失败，错误为
  `Cache V2 AST sidecar capture must encode through a held V1 AST snapshot lease`；其余 **20/21**
  通过。
- UE 编译：`Saved/Build/cta-cache-sidecar-snapshot-lease-build/20260823_142030_207_634110d9/RunMetadata.json`，成功（受影响 Runtime 分片，4 actions）。
- 绿灯架构/Standalone：`Saved/Tests/cta-cache-sidecar-snapshot-lease-green-background/stdout.log`，**21/21 PASS**。
- Cache 行为：`Saved/Tests/cta-cache-sidecar-snapshot-lease-runtime/20260823_142110_217_5d794923/RunMetadata.json`，`Cache.ASTBodySidecar + Cache.ExactWarmStartup` **16/16 PASS**；ExactWarm 仍捕获 8 条 pointer-free V2 records，并以零 frontend/compiler/store-publication 恢复并执行 `42`。
