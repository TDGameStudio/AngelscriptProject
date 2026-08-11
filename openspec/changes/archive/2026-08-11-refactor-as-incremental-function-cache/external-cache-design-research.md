# External Incremental Cache Research and Storage Decision

Date: 2026-08-09 (Asia/Shanghai)

Change: `refactor-as-incremental-function-cache`

Status: non-normative design research; it does not silently amend frozen wire,
error-code, publication, or lifecycle contracts.

## 中文结论摘要

这轮源码调研的核心结论是：**V1 继续使用面向 Cache V2 语义的不可变
文件/CAS + 聚合 Pack，不把全部 payload 放进 SQLite，也暂时不增加一份
重复 Manifest 职责的 SQLite 索引。**

原因不是 SQLite 不成熟，而是两者解决的问题不同：

- Cache V2 的主要数据是写后不改、按完整内容哈希寻址的记录与 Pack；真正
  可变的只有少量 generation root。最自然的事务就是“内容先落盘，root
  最后原子发布”。
- SQLite 擅长在许多可变行之间提供事务、索引和任意查询。若把 64 MiB Pack
  当 BLOB 存入 SQLite，UE 现有封装读取时会把整个 BLOB 复制到 `TArray`；
  若改为一记录一行，又会推翻已经冻结的 Pack/Manifest 物理模型。
- WAL 让读写可以并行，但仍然只有一个 writer，并新增 WAL、shared-memory
  index 与 checkpoint 生命周期；它并不会消除大块 payload 的持久化和回收
  策略。
- ccache、sccache、LLVM ThinLTO、Bazel CAS 和 UE DDC 的共同方向是：小型
  action/manifest 索引指向不可变结果；依赖候选有界；后端损坏按 miss/rebuild
  处理；内容先发布，逻辑结果/root 最后发布。

这些参考项目本身都是成熟、真实生产使用的系统，但 Cache V2 不是任何一个
系统的直接移植。稳定哈希、内容寻址、manifest/CAS 分离、miss/rebuild、细粒度
失效和可丢弃清理有成熟实践交叉支持；七类 Record、ModuleSnapshot 原子激活、
Current/Previous/PendingColdStart、64 MiB Pack policy 以及 StaticJIT/Live Coding
route 组合仍是本项目自己的领域设计，必须由本项目的 benchmark、fault、并发
和运行时测试证明。

当前设计值得保留的部分包括完整稳定身份、Compatibility/Context/输入/输出
hash 分离、实际语义依赖、声明与布局先于函数体复用、模块原子激活，以及
Current/Previous/PendingColdStart 的生命周期语义。需要避免的是把 Store
继续扩展成自研数据库；V1 Store 应只提供 put-if-absent、validated open/pin、
少量 root compare-and-publish 和启动路径之外的显式 GC/compaction。

如果后续基准证明 Manifest 解析/内存、跨进程元数据查询或 writer 协调确实
成为瓶颈，第一步也应是把 SQLite 用作**可重建索引**，继续把不可变 payload
保留在内容寻址文件中；只有单独的 BLOB/拷贝/WAL/checkpoint/回收基准通过后，
才考虑把 payload 迁入数据库。

## 1. Executive conclusion

The current Cache V2 direction is broadly sound in its semantic boundaries, but
the mature implementations strongly suggest keeping the physical store simpler
than a general-purpose database and keeping cache failure outside the correctness
path.

The recommended V1 decision is:

1. Keep immutable, content-addressed records and aggregate packs as ordinary
   files, with immutable generation manifests and a small atomically published
   root/pointer record.
2. Do **not** put Pack payloads or all logical records into SQLite for V1.
3. Do **not** add SQLite merely as a second copy of the generation-manifest
   index. The manifest already maps a full RecordId to `PackId + offset + sizes +
   codec + checksum`, and V1 has no query workload that justifies a database.
4. Preserve a narrow storage interface so that a SQLite index, a different pack
   policy, or a remote/read-only layer can be evaluated later without leaking SQL
   into compiler, identity, validation, or module-activation code.
5. Borrow the mature systems' semantic pattern: one coarse lookup key points to
   a bounded set of historical dependency/result candidates; immutable result
   bytes live behind content keys; compiler version/configuration and actual
   dependencies are part of eligibility; cache corruption or backend failure is
   a miss/rebuild, not a script-correctness success path.

The main reason is workload shape. Cache V2 has a few mutable roots and many
immutable payloads. SQLite is strongest when an application needs transactions
over frequently changing rows and flexible indexed queries. Cache V2 instead
needs deterministic content identities, sequential or range reads from immutable
payloads, publish-last root switching, and cheap disposal/rebuild.

This conclusion is timely: `status.md` currently records Manifest/Pack as
Approved RED and the content-addressed Store as frozen design only, with no Store
implementation claimed. No production store migration is required to keep the
file/CAS direction.

## 2. Research scope and pinned sources

All external repositories are analysis references only. They are ignored by the
parent repository and must not become Runtime dependencies or automatic network
inputs.

| Priority | Reference | Pinned commit | Local path | Purpose |
|---|---|---|---|---|
| P0 | ccache | `e5731387e9b2ea0b57c36dfef69fcf418190a0c5` (2026-08-07) | `D:/Workspace/AngelscriptProject/Reference/ccache` | Direct-mode manifest, bounded dependency candidates, loose-file store, atomic write and local/remote hierarchy. |
| P0 | sccache | `46e96ab443c52bfd796071fca5500efdcfbc89fb` (2026-08-06) | `D:/Workspace/AngelscriptProject/Reference/sccache` | Modern ccache-style preprocessor manifest, storage abstraction, multilevel backfill, local LRU ownership and cache-error policy. |
| P0 | LLVM ThinLTO | `9bc4fd0fafb58ff1fb50231e39a882a678542dac` (2026-08-09) | `D:/Workspace/AngelscriptProject/Reference/llvm-project` | Module cache-key construction from compiler/config/import/export/global analysis and phase ordering before parallel backend reuse. |
| P0 | Bazel + Remote Execution API | `dc2f3f481a3f94c016237e19e9f946f7bd49cad4` (2026-08-07) | `D:/Workspace/AngelscriptProject/Reference/bazel` | Action Cache versus CAS split, upload referenced blobs before publishing ActionResult, disk CAS atomic writes, corruption reset and cache trimming. |
| P0 | SQLite | `ab5206d096d6ecc5f9ea2586889c07e52e852c23` (2026-08-08) | `D:/Workspace/AngelscriptProject/Reference/sqlite` | Pager/WAL/locking/checkpoint implementation and evidence for the file-store-versus-database decision. |
| P0 | UE 5.8 DDC file store | installed engine source | `C:/Program Files/Epic Games/UE_5.8/Engine/Source/Developer/DerivedDataCache` | Unreal-native content-key/file sharding, temp-write-and-move publication, per-file integrity and maintenance. Architectural reference only; the Developer module is not a packaged Runtime dependency. |
| P1 | UE 5.8 SQLiteCore | SQLite 3.47.1 in the installed engine plugin | `C:/Program Files/Epic Games/UE_5.8/Engine/Plugins/Runtime/Database/SQLiteCore` | Actual UE wrapper/API/dependency behavior that Cache V2 would inherit if it selected SQLite. |

Upstream remotes used for the five cloned repositories:

- `git@github.com:ccache/ccache.git`
- `git@github.com:mozilla/sccache.git`
- `git@github.com:llvm/llvm-project.git`
- `git@github.com:bazelbuild/bazel.git`
- `git@github.com:sqlite/sqlite.git`

LLVM and Bazel were checked out sparsely around the relevant cache paths rather
than imported as full source references.

## 3. What the mature implementations actually do

### 3.1 ccache: bounded manifest plus immutable result

ccache direct mode does not attempt to maintain a permanent semantic dependency
database. It computes a coarse manifest key, then stores several historical
dependency snapshots beneath that key. Each snapshot points to a result key.

Source evidence:

- `Reference/ccache/src/ccache/ccache.cpp:2339-2390` hashes
  preprocessor-affecting environment variables, the input path, and source
  content. The path is deliberately included because identical source bytes in
  different directories can resolve relative includes differently.
- `Reference/ccache/src/ccache/ccache.cpp:2528-2586` includes cache-entry,
  result, and manifest format versions in the key and attempts manifest lookup
  before falling back to preprocessing.
- `Reference/ccache/src/ccache/core/manifest.cpp:32-60` defines a compact
  manifest containing paths, include digest/size/time metadata, and result keys.
- `Reference/ccache/src/ccache/core/manifest.cpp:170-218` checks the newest
  candidate first, caps one manifest at 100 result candidates and 10,000 file
  information entries, and clears the manifest when the bound is exceeded.
- `Reference/ccache/src/ccache/core/manifest.cpp:373-458` treats missing,
  unreadable, size-mismatched, or content-mismatched dependencies as a miss.
  File timestamps are an optional shortcut; content hashing remains the
  conservative path.
- `Reference/ccache/src/ccache/storage/local/localstorage.cpp:503-599` stores
  hash-sharded loose files and uses a temporary file, a content lock, and rename
  for publication.
- `Reference/ccache/src/ccache/storage/storage.cpp:437-468` reads local first,
  falls through to remote, backfills a remote hit into local storage, and writes
  through configured levels.

Lessons for Cache V2:

- A bounded, disposable candidate manifest is enough; it does not need database
  normalization or an indefinitely growing graph.
- Format/schema revision belongs in the eligibility key. Incompatible cache data
  may be invalidated rather than migrated forever.
- A cache result is immutable; the mutable portion is the small mapping from
  current action/source state to result identities.
- The source's logical location is semantic when it affects resolution. Cache V2
  is correct to persist stable mount/provider/logical-path identity rather than
  only raw source bytes.

### 3.2 sccache: the closest two-phase pattern, not proof of function granularity

sccache explicitly states that its preprocessor cache is inspired by ccache
direct-mode manifests:
`Reference/sccache/src/compiler/preprocessor_cache.rs:15-19`.

Its implementation is especially relevant to the planned two-phase shape behind
`direct input/action key + persisted actual dependencies -> validated result`.
The transferable evidence is the pattern and bounded candidate lifecycle. sccache
operates at a compiler request/translation-unit boundary; it does not implement or
prove AngelScript module-internal `StableFunctionKey` selection, semantic
declaration/layout dependencies, VM FunctionBody attachment or StaticJIT routes.

- `preprocessor_cache.rs:42-46` versions the format and uses the same 100
  candidate / 10,000 dependency-entry bounds.
- `preprocessor_cache.rs:88-173` allows multiple results for one source when
  dependencies changed; on pathological growth it clears and starts again.
- `preprocessor_cache.rs:175-218` checks newest candidates first and rejects
  missing or size-mismatched includes before optional stat/content checks.
- `preprocessor_cache.rs:375-438` includes compiler digest, compiler-invocation
  mode, format version, language, arguments, selected environment variables,
  normalized input path, and input content in the direct lookup key.
- The same function disables the fast path when `__TIME__` is found because the
  input is not safely reproducible under the direct-key model.
- `Reference/sccache/src/compiler/c.rs:446-483` attempts the dependency-manifest
  result before preprocessing; `c.rs:524-650` preprocesses on miss, computes the
  final compilation key, and records the new dependency candidate.
- `Reference/sccache/src/cache/cache.rs:75-166` keeps compiler semantics behind
  a storage trait instead of letting a backend define cache correctness.
- `Reference/sccache/src/cache/multilevel.rs:634-742` reads levels in order,
  asynchronously backfills slower-level hits into faster levels, and tolerates
  backend failures according to policy.
- `Reference/sccache/src/lru_disk_cache/mod.rs:134-153` assumes one cache owner
  maintains the local store. `mod.rs:327-365` writes a temporary file and commits
  it into the in-memory LRU only after persistence succeeds.

Lessons for Cache V2:

- The two-phase dependency algorithm is a mature pattern, not an invented one:
  reuse persisted actual dependencies to make an early candidate decision, and
  recapture dependencies after a miss compile. Cache V2 applies that pattern at
  the source/action boundary and, because its product requirements demand it, at
  individual AS builder invocations only after authoritative module declarations
  and layouts exist. The finer granularity remains project-specific and must be
  proved locally.
- Inputs that cannot be fingerprinted safely should make only their scope
  `NotCacheable`; they should not be approximated.
- Cache backends should expose simple byte/result operations. Compiler logic
  should not know whether bytes came from local files, SQLite, a read-only seed,
  or a remote service.
- One process-owned writer with many readers is a valid V1 simplification. A
  general multi-writer database is not required merely because multiple threads
  prepare immutable objects.

### 3.3 LLVM ThinLTO: resolve global facts before cache lookup and parallel codegen

ThinLTO caches module backend results, not individual final function object
files. Its useful lesson is the boundary between global analysis and reusable
backend work.

Source evidence:

- `Reference/llvm-project/llvm/lib/LTO/LTO.cpp:135-210` constructs a cache key
  from compiler version/revision, code-generation configuration, and the current
  module hash.
- `LTO.cpp:212-260` sorts exports and imports deterministically and includes the
  source-module hash, imported GUID, import type, and ResolvedODR state.
- The rest of `computeLTOCacheKey` includes only relevant CFI/type/global summary
  resolutions and profile inputs, rather than blindly hashing every process
  global.
- `Reference/llvm-project/llvm/lib/LTO/ThinLTOCodeGenerator.cpp:1088-1128`
  computes cross-module imports/exports, prevailing symbols, internalization,
  and the maps needed by worker threads before launching parallel backends.
- `ThinLTOCodeGenerator.cpp:1141-1175` creates one cache entry per module and can
  return a cached object before parsing that module for backend work.
- `ThinLTOCodeGenerator.cpp:1177-1206` parses/processes only a miss and then
  writes the output to cache.
- `Reference/llvm-project/llvm/lib/Support/CachePruning.cpp:146-254` throttles
  cache scans with a timestamp file and performs best-effort age/size pruning.

Lessons for Cache V2:

- The current separation of `CompatibilityKey`, `ContextKey`, source/function
  inputs, and actual semantic dependencies is directionally correct.
- Function-body reuse after changed source must not run ahead of authoritative
  declaration/layout/import resolution. Exact snapshot restore may bypass parse;
  changed-module reuse still needs the authoritative summary/declaration phase
  before attaching cached bodies.
- ThinLTO is deliberately conservative: a whole imported-module hash can
  invalidate a backend result. Cache V2's per-aspect dependency fingerprints can
  be more precise, but that extra precision is also a major correctness burden.
  It must be earned by mutation-matrix and clean-versus-cached equivalence tests.
- Deterministic sorting of imports/exports/dependencies before hashing is a
  standard requirement, not optional polish.

### 3.4 Bazel/REAPI: publish referenced content before the action result

Bazel's remote cache makes the mutable/immutable split explicit:

- The Action Cache maps an action digest to an `ActionResult`.
- The CAS stores content addressed by the digest of the content itself.

Source evidence:

- `Reference/bazel/site/en/remote/caching.md:32-40` describes the Action Cache
  and CAS as different data classes.
- `Reference/bazel/third_party/remoteapis/build/bazel/remote/execution/v2/remote_execution.proto:141-200`
  defines Action Cache lookup/update separately from content-addressed blobs and
  requires referenced blobs to remain available when returning an ActionResult.
- `Reference/bazel/src/main/java/com/google/devtools/build/lib/remote/UploadManifest.java:600-645`
  asks which blobs are missing, uploads all missing CAS blobs, waits for them,
  and uploads the ActionResult last. The source comment explicitly says the
  result may fail server-side validation if it becomes visible before referenced
  blobs exist.
- `Reference/bazel/src/main/java/com/google/devtools/build/lib/remote/disk/DiskCacheClient.java:305-337`
  uses two-character hash sharding and writes to a temporary file, fsyncs it, and
  renames it while tolerating concurrent creation of identical content.
- `Reference/bazel/src/main/java/com/google/devtools/build/lib/remote/CombinedCache.java:230-301`
  reads disk before remote and backfills a remote ActionResult into disk.
- `Reference/bazel/src/main/java/com/google/devtools/build/lib/actions/cache/CompactPersistentActionCache.java:461-505`
  deletes an incompatible local cache, quarantines a corrupt cache for analysis,
  and starts fresh. `:679-747` compacts by building a new cache and swapping
  roots; `:1118-1127` decodes a corrupt entry as a special corrupted value.

Lessons for Cache V2:

- Cache V2's immutable packs/manifest first and root pointer last is the correct
  publication order.
- A generation manifest is analogous to an ActionResult: it is a small logical
  result that makes already-present immutable content reachable.
- Unpublished content can be left unreachable and reclaimed later. Crash
  recovery does not need to mutate or roll back immutable pack files.
- `Current`, `Previous`, and `PendingColdStart` should be understood as
  AngelScript activation/lifecycle roots, not as a requirement for a general
  transactional database.

### 3.5 Unreal DDC/Zen: mature derived-data semantics with replaceable backends

The installed UE 5.8 file-system DDC remains a useful native backend
comparison:

- `FileSystemCacheStore.cpp:80-105` builds hash-sharded paths separately for
  cache records and content.
- `FileSystemCacheStore.cpp:2605-2643` appends and validates a BLAKE3 integrity
  hash per stored file.
- `FileSystemCacheStore.cpp:2646-2700` writes to `Temp.<Guid>`, closes and checks
  the written size, then moves it into the final path; a collision is treated as
  a benign content publication race.
- The maintainer scans and removes old cache files; the file store can also be
  read-only.

This does not mean Cache V2 should directly depend on `DerivedDataCache`: that is
a Developer-side subsystem and does not define the required packaged Runtime
activation semantics. It does show that a content-key/file backend is a normal
Unreal design, not an inherently unsafe alternative to SQLite.

However, the current default must be stated accurately. Epic's official
[DDC documentation](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-derived-data-cache-in-unreal-engine)
states that UE 5.4 and newer use a local Zen Storage Server by default. The
legacy local file-system DDC is placed in delete-only transition mode, while
file-system Shared DDC and read-only `.ddp` Pak remain supported. The mature UE
lesson is therefore not "the current engine defaults to ordinary files." It is:

- authoritative assets stay separate from disposable, regenerable derived data;
- cache backends are hierarchical and replaceable;
- file, read-only archive, local service and cloud service backends can coexist;
- backend evolution does not redefine derived-data identity or source authority.

This strengthens the recommendation to keep a narrow Cache V2 Store boundary.
It does not by itself choose file/CAS or SQLite for the V1 workload.

## 4. SQLite findings

SQLite is mature, reliable, public-domain software. The decision against a full
SQLite payload store is workload-specific, not a claim that SQLite is generally
inferior.

### 4.1 What SQLite would solve well

- Atomic transactions and automatic crash recovery are deeply tested. The
  official [Atomic Commit](https://www.sqlite.org/atomiccommit.html)
  documentation explains rollback-journal ordering, flush barriers, hot-journal
  recovery, and old-or-new transaction visibility.
- WAL provides snapshot reads while a writer appends changes. The official
  [WAL documentation](https://www.sqlite.org/wal.html) states that readers and a
  writer can proceed concurrently and that each read transaction sees one end
  mark.
- Tables and indexes would make arbitrary queries, LRU metadata, candidate-set
  trimming, and reachability/GC bookkeeping easier to implement.
- `PRAGMA user_version`, `application_id`, `quick_check`, backup APIs, and widely
  available tools make operational diagnosis and schema evolution convenient.
- SQLite is explicitly appropriate as an application file format and archive
  container; it is not unreasonable as a cache backend in general.

### 4.2 What SQLite would add to this particular cache

SQLite does not remove persistence mechanics; it replaces our small immutable
publication protocol with its pager protocol:

- In WAL mode, committed pages first live in the `-wal` file and later move into
  the main database during checkpoint. `Reference/sqlite/src/wal.c:13-32` and
  `:89-98` implement commit markers, checksummed frames, checkpointing, and sync
  barriers.
- The official WAL documentation notes that only one writer can exist per
  database, long-lived readers can prevent checkpoint completion, and the WAL
  can grow until a reader gap permits reset.
- The database, `-wal`, and `-shm` files are one coordinated state. The official
  documentation warns that separating the database from its WAL can lose
  committed transactions or corrupt the database.
- WAL shared-memory coordination is same-host only. `Reference/sqlite/src/wal.c:127-136`
  says WAL is unsupported on network filesystems because every user must share
  the wal-index.
- A database-level failure has a larger physical blast radius than one corrupt
  content-addressed pack. Content hashes can still detect bad rows, but recovery
  normally resets/quarantines the database as a unit.
- Deleting rows does not automatically produce a compact deterministic file;
  free pages, WAL checkpoint policy, and optional VACUUM become storage policy.

For this cache, the largest mismatch is the payload API:

- Cache V2 plans aggregate packs with a default 64 MiB uncompressed target and
  random/range lookup by manifest offset.
- UE 5.8's `FSQLitePreparedStatement::GetColumnValueByIndex` calls
  `sqlite3_column_blob`, then appends the entire BLOB into a `TArray<uint8>`:
  `SQLitePreparedStatement.cpp:674-685`. The wrapper therefore adds a full
  payload copy for a pack BLOB.
- Blob binding also uses an `int32` byte count:
  `SQLitePreparedStatement.cpp:345-352`.
- The raw SQLite C API has incremental BLOB I/O, and `SQLiteCore` exports the C
  API, but using it would bypass the simple UE wrapper and still would not expose
  a stable zero-copy mapped range equivalent to a pinned immutable pack handle.

There is also a plugin-distribution cost:

- UE 5.8 ships SQLiteCore as an Engine Runtime plugin, but it is disabled by
  default and uses SQLite 3.47.1 in this engine installation.
- `SQLiteCore.Build.cs` states that when a target uses Unreal's custom SQLite
  platform, the HAL lacks shared memory and granular file locks, so only one
  `FSQLiteDatabase` may have the file open at a time.
- AngelscriptRuntime currently has no SQLiteCore/SQLiteSupport dependency. Adding
  one broadens the reusable plugin's engine-plugin, version, target, and platform
  validation surface.

### 4.3 SQLite size limits are not the deciding issue

SQLite's default maximum BLOB/row length is one billion bytes and its current
implementation can support values up to approximately 2 GiB, as described in
[SQLite limits](https://www.sqlite.org/limits.html). A 64 MiB pack can therefore
fit as a BLOB. The objection is not “SQLite cannot store it”; it is that doing so
does not match Cache V2's desired I/O, determinism, failure isolation, and
publication model.

## 5. Storage alternatives compared

| Criterion | Immutable file/CAS + packs | Full SQLite payload store | Packs + SQLite index |
|---|---|---|---|
| Fit to current wire | Direct fit: RecordId, PackId, manifest offsets and pointer wire remain authoritative. | Poor fit if each record becomes a row; redundant if each pack is only a BLOB row. | Manifest and SQL index duplicate the same RecordId-to-location mapping. |
| Deterministic bytes and IDs | Pack and manifest bytes can be canonical and hashed directly. | Logical row values can be deterministic, but physical database bytes/page layout must not be used as artifact identity. | Pack bytes remain deterministic; database remains non-authoritative metadata. |
| Read path | Open/pin immutable pack, validate once, range-read and decompress selected records. | UE wrapper copies a whole selected BLOB; raw incremental BLOB APIs require lower-level integration. | Payload read remains good, but every lookup may add SQL/connection work unless the index is loaded into memory. |
| Write path | Write new immutable content once, validate, rename no-replace, publish a small root last. | Large rows are written through pager/journal or WAL and later checkpointed; transaction/checkpoint policy affects latency and temporary disk usage. | Packs still need custom safe publication, and SQLite adds a second commit/recovery boundary. |
| Crash atomicity | Must correctly implement flush/close/reopen/rename and root-last ordering. Unpublished files remain unreachable. | Excellent, mature transaction recovery if VFS/locking/fsync assumptions hold. | Hardest to reason about if SQL commit and file publication can disagree; requires a strict two-phase rule and repair path. |
| Readers and writers | Immutable readers do not block; one namespace publication lock is enough for V1. | WAL supports many snapshot readers but only one writer; checkpoint can be delayed by long readers. | SQL index readers and pinned pack readers have separate lifetimes and failure modes. |
| Corruption scope | One pack/manifest/root can be rejected by content hash; other immutable objects remain usable. | A corrupt database may force quarantine/reset of the namespace database. | Index can be rebuilt from manifests, but that makes it optional rather than authoritative. |
| Deduplication | Natural by RecordId/PackId and publish-if-absent. | Requires unique hash indexes and row policy; pack-as-BLOB dedupes only at PackId granularity. | Same payload dedupe as the file design. |
| GC/compaction | Requires explicit mark/sweep or repack and careful pinned-reader handling. | SQL reachability/deletes are easy, but file-space reclamation/checkpoint/VACUUM remain policy. | SQL helps select garbage, but physical repack and file deletion remain custom. |
| Query flexibility | Purpose-built lookups only. | Excellent for ad-hoc diagnostics, joins, LRU and inventory queries. | Good metadata queries, but not currently required on the startup hot path. |
| Dependency/portability | Uses Core/HAL file operations only; easiest reusable-plugin boundary. | Adds SQLiteCore enablement/version/platform validation; custom VFS targets can lose normal concurrency. | Same SQLite dependency despite retaining custom payload storage. |
| Implementation risk | High if treated as a database; manageable if restricted to immutable put-if-absent, validated open, root commit and explicit GC. | Low for transaction machinery, but high migration/integration cost against the already frozen pack/manifest model. | Highest V1 surface area because both systems must be made consistent. |

## 6. Recommendation

### Decision S1: retain the file/CAS store for V1

Retain the current logical shape:

```text
Saved/Angelscript/CacheV2/<CompatibilityKey>/<ContextKey>/
    Current.ascurrent
    Previous.ascurrent
    PendingColdStart.ascurrent
    Manifests/<GenerationId>.asmanifest
    Packs/<PackId>.aspack
```

The physical store should remain deliberately narrower than a database:

1. `PutImmutable(PackId, Bytes)` / `PutImmutable(GenerationId, Bytes)` writes
   only missing content and accepts a benign identical-content race.
2. `OpenValidated(Id)` pins a final immutable handle for a read session.
3. `LoadSlots()` reads and validates the few mutable pointer records.
4. `CommitSlot(ExpectedOld, New)` is the sole logical publication seam.
5. `EnumerateStrictFinalNames()` plus explicit rooted mark/sweep is maintenance,
   never a prerequisite for normal startup.

This is “custom storage” only in the sense of a domain-specific immutable object
store. It must not grow SQL-like query, update, locking, or transaction features.

### Decision S2: no SQLite index in V1

The generation manifest already is the complete startup index and is loaded as
validated immutable state. Adding SQLite now would create two answers for the
same question: the canonical manifest location and the SQL row location.

If diagnostics need ad-hoc queries, export the validated manifest/inventory to
JSON or CSV. Diagnostic convenience does not justify making SQL part of Runtime
cache correctness.

### Decision S3: keep a backend boundary

Compiler and lifecycle code should depend on semantic operations, not file
layout or SQL:

```text
semantic cache service
    -> immutable object store
       - put-if-absent
       - open/pin validated object
       - existence/batch-missing query
    -> root publication store
       - load slots
       - compare-and-publish slot
    -> maintenance
       - enumerate strict finals
       - mark rooted objects
       - sweep/repack outside startup
```

This mirrors sccache's storage trait and Bazel's Action Cache/CAS boundary. It
also leaves room for a read-only seed layer or remote layer with local backfill.

### Decision S4: keep SQLite as an evidence-triggered fallback

Reconsider SQLite only if measurements demonstrate at least one of these
conditions:

- generation-manifest parsing/index memory is a material warm-start bottleneck;
- the number of logical objects makes the manifest exceed its configured memory
  budget despite sharding or module-level indexes;
- cross-process arbitrary metadata queries become a product requirement;
- multi-process writer coordination becomes required rather than optional;
- file enumeration/GC dominates maintenance and cannot be solved by strict
  naming, sharding, and a rebuildable inventory;
- a crash-injection matrix shows the narrow file publication seam cannot be made
  reliable on supported UE platforms.

Even then, the first SQLite experiment should use it as a **rebuildable metadata
index**, while immutable payloads remain content-addressed files. Moving payloads
into BLOB rows should require a separate benchmark proving that UE-side copies,
WAL/checkpoint behavior, disk amplification, and compaction are acceptable.

## 7. Adjustments suggested by the external comparison

These are research recommendations, not silent changes to frozen contracts.

### 7.1 Preserve the semantic design that already matches mature systems

Keep:

- full-width stable identity and domain-separated hashes;
- separate compatibility, context, lookup-input, and output-content identities;
- actual dependency capture rather than broad global invalidation;
- declaration/interface/layout resolution before changed-module function-body
  reuse;
- immutable content plus publish-last generation root;
- module-atomic activation even though physical records are granular;
- cache failure as miss/recompile, never authorization to run different-source
  stale behavior.

The project-specific function layer also remains required by the actual product:
`StableFunctionKey`, per-function FunctionBody/content identity and exact
StaticJIT Provider matching cannot be replaced by a module Blob cache. A full
changed-module compile is the fallback and equivalence oracle; supported V1
invocations still require real pre-compiler FunctionBody hits.

### 7.2 Bound historical candidate state

ccache and sccache both bound the number of historical dependency/result
candidates and discard the optimization state when it grows pathologically.

Cache V2 should distinguish:

- activation roots (`Current`, `Previous`, `PendingColdStart`), which have
  lifecycle meaning; and
- optional lookup candidate history for a stable source/function key, which is
  only a performance hint.

A candidate history, if added, should be newest-first, bounded by both candidate
count and total dependency entries, and safe to clear at any time. It must not be
implemented as an authoritative unbounded dependency database.

This can be deferred until the single-current-candidate path is behavior GREEN;
losing an old candidate causes recompilation, not incorrect execution.

### 7.3 Separate cache-format compatibility from migrations

The mature compiler caches put format/compiler configuration in the key and
start fresh when it changes. Cache V2 should retain explicit schemas and strict
decoders for untrusted Saved data, but it does not need a permanent migration
chain for disposable cache generations.

SQLite schema migration is therefore not a benefit Cache V2 currently needs.

### 7.4 Keep publication simpler than activation

The store publication rule is:

```text
write immutable packs
    -> validate final packs
    -> write immutable generation manifest
    -> validate final manifest and all references
    -> atomically publish one slot/root last
```

`PendingColdStart` exists because an AngelScript structural result may be valid
for a future cold activation but invalid for the currently active PIE/runtime
state. That is a lifecycle distinction. It should not cause packs themselves to
gain pending/current transaction states.

### 7.5 Treat pruning as opportunistic cache maintenance

ccache, sccache, LLVM and UE DDC all tolerate stale cache content and clean it
according to bounds/age/size policy. V1 should not perform a mandatory full
reachability compaction during startup. Unreachable immutable files are a space
cost, not a correctness failure.

Explicit compaction still needs the existing pinned-reader and re-mark-before-
sweep rules, but it should remain outside the compile/activation success path.

## 8. Required benchmark before freezing the physical policy

The wire can support different pack targets because pack size is writer policy,
not semantic identity. Before declaring 64 MiB optimal, benchmark at least 4,
16, and 64 MiB targets with the same canonical record set.

Measure:

1. cold store creation time and physical bytes written;
2. unchanged warm open, manifest validation, and module restore time;
3. one-function body edit: records reused, bytes written, manifest/pack count and
   publication latency;
4. structural module edit with `PendingColdStart`;
5. random record lookup latency and number of file handles/reads;
6. peak memory and bytes copied before decompression;
7. concurrent immutable readers plus one publisher;
8. crash injection before/after each flush, rename, validation and root replace;
9. corruption of one pointer, manifest, pack header, index entry and payload;
10. explicit compaction wall time, peak temporary disk and pinned-reader behavior.

If SQLite is benchmarked, compare the same logical data under:

- one BLOB per pack through the UE wrapper;
- one record per row;
- raw incremental BLOB I/O;
- rollback journal and WAL with stated `synchronous` and checkpoint settings.

Do not compare only steady-state SQL lookup time. Include database open/recovery,
WAL growth, checkpoint spikes, copies, physical bytes, VACUUM/reclaim behavior,
and crash recovery.

## 9. Risks that remain with the recommended file store

Choosing the file/CAS design does not make the current store automatically
correct. The implementation still must prove:

- same-directory temporary writes and exact final-name containment;
- flush/close/reopen validation before publication;
- supported old-or-new atomic pointer replacement on every target platform;
- no-replace immutable final publication or verified identical-content races;
- reader handle pinning across manifest and every referenced pack;
- strict count/offset/size/arithmetic/decompression budgets before allocation;
- full content identity/checksum verification and correct corruption
  classification;
- one defined writer lock/rebase policy and no mutable-engine access on workers;
- crash/cancellation outcomes after the root is already committed;
- cache reset/quarantine that never deletes source and never authorizes stale
  different-source execution.

SQLite would provide many low-level transaction guarantees, but it would not
prove AngelScript semantic eligibility, source authority, declaration/layout
compatibility, module-atomic activation, or hot-reload lifecycle correctness.
Those remain the dominant risks whichever backend is selected.

## 10. Final direction

The mature-source comparison plus this project's StaticJIT/Editor requirements
supports the following layered architecture:

```text
Direct source/action key
    -> bounded historical preprocess dependency candidate (optimization only)
        -> exact ModuleSnapshot restore, or authoritative changed-module frontend
            -> StableFunctionKey builder invocation
                -> validated FunctionInputDigest -> attach hit / compile miss
                    -> immutable content-addressed records or packs
                        -> generation manifest (logical result)
                            -> Current / Previous / PendingColdStart root last

StaticJIT independently consumes:
    StableFunctionKey + FunctionContentHash + profile/native ABI
        -> exact Native entry or current VM fallback
```

For V1, use the domain-specific immutable file/CAS store. Do not use full SQLite
and do not add a redundant SQLite index. Keep the store interface replaceable,
collect the benchmark data above, and revisit SQLite only if the measured problem
is metadata scale/query/coordination—not simply because implementing correct
file publication requires care.

## 11. Maturity assessment and limits of inference

### 11.1 Overall judgment

The references are mature, but the complete Cache V2/StaticJIT composition is
new to this project:

> Mature components and patterns reduce design risk; they do not transfer
> production proof to a new composition automatically.

The comparison must distinguish three questions:

1. Is the referenced project itself maintained and used in real production
   workflows?
2. Which exact property of that project supports a Cache V2 decision?
3. Which Cache V2 or StaticJIT behavior remains unproven by that reference?

### 11.2 Reference-by-reference classification

| Reference | Maturity judgment | Mature evidence used here | What it does not prove for Cache V2 |
|---|---|---|---|
| ccache | High | Stable input hashing, direct/preprocessor modes, dependency manifest candidates, result reuse, integrity checks and bounded cleanup | UE type rebuilding, ModuleSnapshot activation, PIE lifecycle or StaticJIT routes |
| sccache | High for compiler caching and storage backends; actively evolving | Compiler-request-to-result caching, local/remote/multi-level backends, miss compilation and backend separation | AngelScript semantic dependency discovery, module-atomic activation or Live Coding integration |
| LLVM ThinLTO | High | Scalable incremental native backend work, cache keys after global facts, parallel codegen and cache pruning across major linkers | Cache V2 wire/store, ClassGenerator lifecycle or VM fallback |
| Bazel/REAPI | High | Action Cache/CAS separation, digest-addressed blobs, result metadata referencing content and disposable rebuildable cache | A local UE Runtime schema, hot reload or the need to adopt the full remote protocol |
| UE DDC/Zen | High and ecosystem-native | Authoritative source versus disposable derived data, hierarchical replaceable backends, async backfill, GC and read-only Pak distribution | Script semantic eligibility, type/layout compatibility or active module publication |
| SQLite | Very high as an embedded database | ACID transactions, stable single-file format, crash recovery, indexing and long-term support | Cache keys, source authority, dependency invalidation, module activation or Native route eligibility |
| UE Live Coding | High as an Editor C++ rebuild/patch backend | Runtime C++ rebuild and binary patching, PIE/Editor workflow, reinstancing and reload completion integration | The generated AngelScript StaticJIT provider ABI, per-function matching and safe route lifecycle |

Primary official evidence:

- [ccache manual](https://ccache.dev/manual/latest.html) documents BLAKE3 input
  hashing, direct/preprocessor lookup, manifests, result integrity and automatic
  or manual cleanup. Its documented direct-mode caveats are also evidence that a
  fast candidate lookup must not replace complete Cache V2 source authority.
- [sccache](https://github.com/mozilla/sccache) documents local disk, multiple
  cloud backends, multi-level caching and distributed compilation, as well as
  path and compiler-mode caveats.
- [LLVM ThinLTO](https://clang.llvm.org/docs/ThinLTO.html) has supported
  incremental caches across gold, ld64, lld and lld-link releases for years and
  documents cache pruning and distributed backend work.
- [Bazel remote caching](https://bazel.build/remote/caching) defines the Action
  Cache plus CAS split and permits HTTP, gRPC and filesystem/disk backends.
- [UE DDC](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-derived-data-cache-in-unreal-engine)
  documents regenerable derived data, hierarchical lookup/backfill, Zen as the
  modern local default, file-system Shared DDC and read-only DDC Pak.
- [SQLite](https://sqlite.org/about.html) documents its embedded, transactional,
  single-file, long-supported and extensively tested engine. Its
  [WAL documentation](https://sqlite.org/wal.html) also documents checkpoint
  cost, reader interaction and checkpoint-starvation trade-offs that a Cache V2
  benchmark must include.
- [UE Live Coding](https://dev.epicgames.com/documentation/en-us/unreal-engine/using-live-coding-to-recompile-unreal-engine-applications-at-runtime)
  documents runtime C++ rebuild/binary patching, PIE support, reinstancing and
  the need to invalidate or repopulate retained pointers after reload.

### 11.3 Decisions with strong mature-system support

The following Cache V2 directions are cross-supported by multiple mature
implementations:

- stable, deterministic input and content identities;
- separation of lookup/action identity from immutable result identity;
- small logical result or manifest metadata referencing content-addressed bytes;
- eligibility including compiler/configuration and actual dependency state;
- miss or corruption falling back to authoritative compilation/rebuild;
- immutable content publication before publishing a root/result reference;
- reuse and invalidation at the smallest sound semantic unit;
- backend storage not entering compiler or artifact semantic identity;
- stale immutable data being a cleanup/space concern rather than correctness;
- cache size/age pruning outside the semantic success path;
- native work split into stable incremental backend units.

These principles are not experimental inventions of this change.

### 11.4 Project-specific composition that remains unproven

No single reference directly validates the following complete composition:

- seven Cache V2 record kinds and their V1 canonical wire;
- ModuleSnapshot graph validation and module-atomic activation;
- `Current`, `Previous`, and `PendingColdStart` lifecycle roots;
- the default 64 MiB aggregate-Pack target and 128 MiB physical bound;
- two-phase source/profile-revalidated compaction with pinned readers;
- ClassGenerator, Editor and PIE activation integration;
- the shared FunctionContentHash contract with an external StaticJIT provider;
- engine-owned immutable Native/VM route snapshots;
- a Native caller invoking the current changed callee through a stable route;
- deterministic StaticJIT fixed buckets generated into a project Runtime module;
- explicit UE Live Coding refresh, provider-generation validation and VM
  fallback;
- cooked full-provider-set validation before direct Native-to-Native calls.

These are reasoned adaptations of mature ideas. They remain project claims until
the planned wire goldens, crash injection, concurrent-reader publication,
multi-engine isolation, VM/Native parity, Live Coding failure and real PIE/
package acceptance tests pass.

The 64 MiB Pack target in particular is a writer hypothesis, not a mature-system
fact. The required 4/16/64 MiB benchmark in section 8 must decide it.

### 11.5 Confidence levels and decision rule

Current confidence should be communicated in three tiers:

| Confidence | Scope | Required posture |
|---|---|---|
| High | Stable hashes, content addressing, source authority, manifest/CAS separation, miss/rebuild, VM fallback and backend abstraction | Preserve these boundaries unless contrary measurements or correctness evidence appear |
| Medium | Domain-specific aggregate Pack, complete Generation Manifest, atomic roots, retention and compaction | Implement behind the narrow Store boundary and prove with deterministic/fault/concurrency tests plus Pack-size benchmarks |
| Not yet production-proven | StaticJIT provider + Live Coding + engine-owned routes and hot-reloadable cross-function dispatch | Keep VM authoritative, enable Native only on exact match, and do not remove legacy transport until provider parity and acceptance evidence exist |

Therefore the existence of mature references supports continuing the current
direction, but it does not authorize skipping project-specific verification. It
also does not justify choosing SQLite merely because SQLite is mature, or
choosing ordinary files merely because a file-system DDC backend exists. The
backend decision remains workload-specific and reversible; the semantic and
lifecycle contracts remain the correctness core.

## 12. Legacy `PrecompiledScript.Cache` debug-data behavior

This section records the actual project implementation examined on 2026-08-09.
It is intentionally separate from AngelScript's stock `SaveByteCode` format:
the project's startup cache uses `FAngelscriptPrecompiledData` and its own Unreal
`FArchive` records rather than calling `asCModule::SaveByteCode`.

### 12.1 Storage shape

- One `PrecompiledScript*.Cache` archive serializes the cache GUID, build
  identifier, the complete module map and global type/function/property
  reference maps.
- Each `FAngelscriptPrecompiledModule` mixes functions, classes, enums, globals,
  imports and preprocessor descriptors in one module record.
- Each `FAngelscriptPrecompiledFunction` mixes executable bytecode and
  relocatable bytecode references with runtime stack/object-variable state,
  numeric cache function ID, `DeclaredAt`, `LineNumbers`, signature data and
  UFunction/preprocessor metadata.
- The custom cache does not preserve a separate debug blob, stable debug key or
  per-function debug-sidecar identity. It also does not serialize the stock
  AngelScript `sectionIdxs` table or stock local-variable debug names into this
  record. Instead, restore assigns the module's script-section index and copies
  the saved declaration/line table when VM bytecode is materialized.
- `DeclaredAt` and `LineNumbers` are captured only outside Shipping builds.
  When a StaticJIT entry is found by the saved numeric cache ID, the function can
  be installed without allocating/restoring `scriptData`; this legacy path is
  therefore not a general, independently managed debug-information system.

AngelScript's stock module writer is richer: when debug stripping is disabled it
serializes program-position/line pairs, section transitions by section name,
local variable declaration positions and names, the function declaration
section/name, declaration location and parameter names. Type/stack-position
parts of variable information remain necessary even when debug information is
stripped because context serialization needs them. That stock behavior explains
the underlying runtime fields, but it must not be mistaken for the project's
current `PrecompiledScript.Cache` wire format.

### 12.2 Load and runtime lookup

- Cache load first validates a build identifier containing the schema and UE
  build configuration. A mismatch discards the complete loaded archive.
- The cache GUID is compared with the GUID compiled into StaticJIT output. A
  mismatch disables the complete transpiled-function database rather than
  invalidating one function.
- A module is reused only when its saved `CodeHash` matches the current module
  `CodeHash` and all imports were eligible for precompiled loading. There is no
  independent debug-only reuse or refresh decision.
- In the fully precompiled non-development path the cached descriptors replace
  preprocessing and hot reload is disabled for that run.
- At runtime the debugger does not reopen the cache. It asks the active execution
  context/function for the current line and section; the function reads its
  in-memory `scriptData->lineNumbers`, `scriptSectionIdx` and, on ordinary
  compiler/stock-restore paths, `sectionIdxs`.

### 12.3 Function-ID consequences

The legacy serialized function `Id` is a cache/JIT identity, not the live
AngelScript engine function ID assigned during module reconstruction. It is
derived from module identity, object type and function declaration, then made
unique by incrementing on collision; unnamed global initializer functions use a
random value. StaticJIT looks up native entries by that saved ID, while the
newly created AngelScript function still receives the engine's next runtime
function ID. This is stable enough only inside the legacy whole-cache + matching
GUID workflow and is not a sound cross-generation public FunctionKey contract.

### 12.4 Cache V2 consequence

Cache V2 must keep the useful ownership relation (debug information belongs to
one function body) without retaining the legacy physical coupling. The planned
`FunctionBody` and optional `DebugSidecar` therefore have separate hashes and
payload ownership under the same stable `FunctionKey`. Whitespace/line-only
changes may then preserve executable content while replacing source/line debug
data, but activation remains atomic: a sidecar may be published only with its
exact owning body and valid `SourceIndex` references.
