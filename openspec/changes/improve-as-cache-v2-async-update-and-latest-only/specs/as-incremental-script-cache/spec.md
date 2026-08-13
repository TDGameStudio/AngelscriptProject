## MODIFIED Requirements

### Requirement: Generation publication is atomic and recoverable

The writer MUST publish new immutable pack data and a validated generation manifest before atomically replacing Current. Every temp SHALL use the frozen same-directory writer-token name and SHALL be fully written, flushed, closed, reopened and validated. Immutable finals SHALL use no-replace rename, directory sync and final reopen validation. Pointer replacement/removal MUST use a supported platform old-or-new atomic seam; a generic delete-then-move MUST NOT satisfy this contract. After Current replacement succeeds for a hot reload or explicit cache update, the writer MUST NOT keep Previous as a long-lived retention root. Readers MUST pin one manifest handle and every distinct referenced pack handle for an entire immutable read session.

#### Scenario: Process stops during pack or manifest write

- **WHEN** cancellation, crash, or shutdown occurs before Current is replaced
- **THEN** the previous Current remains selected on the next launch
- **AND** incomplete temporary files are never accepted as records

#### Scenario: Two processes publish concurrently

- **WHEN** two engines target the same store
- **THEN** writers serialize through a store-path system-wide lock
- **AND** the later writer rereads/rebases Current before publication
- **AND** readers never observe a half-published generation

#### Scenario: Cancellation arrives after Current replacement

- **WHEN** the platform has successfully atomically replaced Current and cancellation or directory synchronization failure is observed afterward
- **THEN** the outcome records CurrentCommitted and does not roll back the pointer
- **AND** immutable packs or manifests are not deleted as cancellation rollback of that commit

#### Scenario: A pinned reader overlaps publication or compaction

- **WHEN** a reader has pinned the selected manifest and every referenced pack before the namespace lock is released
- **THEN** later pointer movement cannot change the bytes used by that session
- **AND** latest-only sweep either unlinks with handle-safe semantics or defers deletion without substituting path-opened data

### Requirement: Runtime reload and cache controls are exposed through stable APIs

The Runtime SHALL expose reload mode, request status, reload outcome, and result types to C++ and Blueprint; `UAngelscriptSubsystem` SHALL expose `RequestRuntimeReload()` and a completion delegate. It SHALL expose `RequestCacheUpdate()` and a cache-update completion delegate. It SHALL also expose `as.ReloadScripts`, `as.Cache.Update`, `as.Cache.Status`, `as.Cache.Flush`, `as.Cache.Verify`, `as.Cache.Compact`, `as.Cache.ForceClean`, `as.Cache.Explain`, and `as.Cache.Trace` console commands.

#### Scenario: Blueprint queues a manual reload

- **WHEN** Blueprint calls `RequestRuntimeReload()` while Manual mode is idle
- **THEN** it receives `Queued`
- **AND** the completion delegate later reports `NoChanges`, `AppliedCodeOnly`, `RequiresRestart`, `CompileFailed`, or `Cancelled` with module and cache diagnostics

#### Scenario: Blueprint queues a cache update

- **WHEN** Blueprint calls `RequestCacheUpdate()` while Cache V2 is enabled and idle
- **THEN** it receives `Queued`
- **AND** the completion delegate later reports `Published`, `NoChanges`, `CompileFailed`, or `Cancelled`

#### Scenario: Flush command is used by package smoke

- **WHEN** `as.Cache.Flush` is executed after startup compilation
- **THEN** it waits for valid prepared cache work to commit or reports a typed failure
- **AND** shutdown can follow without losing an already completed generation

### Requirement: Unreachable content is reclaimed outside startup

Normal startup MUST NOT rewrite valid packs solely to remove unreachable records. After a successful Current commit from hot reload or an explicit cache update, physical retention in that namespace SHALL treat only Current as the live root, plus PendingColdStart when that pointer is still present. Previous SHALL be cleared. The publisher SHALL then reacquire the namespace lock, remark those roots, and sweep unmarked strict-name final objects and recognized temps in this namespace only. A pinned-reader deletion failure SHALL be deferred rather than invalidating the committed Current. Explicit Compact remains available to rewrite reachable bytes without compiling. Sibling Compatibility or Context directories MUST NOT be deleted by this sweep.

#### Scenario: Function is renamed or deleted and reload publishes Current

- **WHEN** a successful hot reload or cache update commits a generation that no longer references an old FunctionBody
- **THEN** Previous is not retained
- **AND** packs and manifests that are not reachable from Current (and still-present PendingColdStart) are swept from this namespace
- **AND** startup is not blocked on that sweep

#### Scenario: Startup sees unreachable packs before any successful new commit

- **WHEN** the store still contains packs not reachable from retained pointers and no new Current has been committed in this process
- **THEN** startup does not block on compaction
- **AND** those orphans remain until the next successful Current commit or an explicit Compact

#### Scenario: Publication occurs between pointer switch and sweep

- **WHEN** another valid publication changes physical roots after Current is replaced but before sweep
- **THEN** the sweeper reacquires the namespace lock and recomputes currently present pointer roots
- **AND** it does not delete any manifest or pack newly rooted by that publication

#### Scenario: PIE PendingColdStart is published

- **WHEN** a structural PIE compile publishes PendingColdStart without advancing Current
- **THEN** Current is not swept away
- **AND** latest-only sweep does not run against Current as a discarded root

## ADDED Requirements

### Requirement: Successful Current publication keeps only the latest generation in its namespace

Once Current replacement has succeeded for an Editor hot reload, a packaged code-only reload that publishes, or an explicit cache update, the service MUST clear Previous and MUST NOT leave older generation manifests or unreferenced packs in that Compatibility/Context namespace after sweep completes or is safely deferred. Failed compiles MUST NOT run this latest-only sweep.

#### Scenario: Two successful body reloads in one session

- **WHEN** the second code-only reload commits a new Current
- **THEN** Status reports a single Current root in that namespace
- **AND** the first reload's exclusive packs and manifest are gone or deletion-deferred while a pinned reader still holds them
- **AND** Previous is absent

#### Scenario: Failed reload after a latest-only Current

- **WHEN** a later reload compile fails
- **THEN** the last committed Current remains
- **AND** no additional sweep removes that last-good generation
