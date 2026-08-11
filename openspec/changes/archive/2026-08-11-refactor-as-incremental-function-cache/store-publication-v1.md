# Cache V2 Task Group 3 Store Publication V1

## Status and authority

This document is the normative filesystem, pointer, publication, concurrency,
recovery, reader-session, fallback, retention, and compaction contract for
Task Group 3 of `refactor-as-incremental-function-cache`.

It consumes only manifests, packs, IDs, locations, validation errors, limits,
and exact reachability already frozen by `manifest-pack-wire-v1.md`. It does
not redefine record payloads, RecordId, PackId, GenerationId, pack grouping,
Zlib, manifest graph validation, or archive error classification.

Store control-flow/I/O errors are deliberately separate from
`EAngelscriptCacheValidationError`. A malformed pack or manifest returns the
frozen archive validation result nested in a store result; lock, path, flush,
rename, cancellation, and commit outcomes never acquire fake archive error
numbers.

The V1 store is Saved-first, content-addressed, immutable after final rename,
source-authoritative, and safe under multiple readers and serialized writers.
There is no legacy `PrecompiledScript.Cache` reader, migration, baseline, or
dual-write path.

## Directory and filename contract

### Base root

The default base root is exactly:

```text
<FPaths::ProjectSavedDir()>/Angelscript/CacheV2
```

An explicit `-as-cache-root=<AbsoluteOrRelativePath>` replaces this complete
base root; the service does not append another `Angelscript/CacheV2` below an
override. A relative override is resolved once against the process launch
working directory before store construction. The compatibility/context
namespace levels are always appended afterward.

The override is a diagnostic/test/package-smoke escape hatch, not a packaged
cache baseline. With no override, all V1 writes remain under Project Saved.

The concrete compatibility descriptor used by the store additionally includes
the exact canonical input `cache-pointer-schema=1`, alongside the pack,
manifest, and storage-compressor inputs frozen by
`manifest-pack-wire-v1.md`. A pointer-wire revision therefore selects another
compatibility namespace rather than misreading an existing Current file.

### Namespace

One namespace is:

```text
<BaseRoot>/<CompatibilityHex>/<ContextHex>
```

`CompatibilityHex` and `ContextHex` are the complete 32-byte hashes encoded as
exactly 64 lower-case ASCII hexadecimal characters. A path component with an
upper-case hex digit, non-hex byte, short/truncated hash, slash, backslash,
drive marker, dot segment, NUL, or other character is invalid. Profile remains
inside the manifest; it is not another directory level.

The namespace contains only these authoritative final locations:

```text
Current.ascurrent
Previous.ascurrent
PendingColdStart.ascurrent
Generations/<GenerationHex>.asmanifest
Packs/<PackHex>.aspack
```

`GenerationHex` and `PackHex` use the same exact lower-case full-hash rule.
Manifest bytes never supply a filesystem path. All paths are built from the
validated namespace plus a known directory/name/extension, then checked to
remain beneath the canonical base root.

### Root normalization and containment

Before enabling a writable store, the platform file seam must return one
canonical absolute base/namespace identity:

1. convert to absolute;
2. normalize separators to `/` for identity;
3. collapse `.` and reject unresolved `..`;
4. remove trailing separators except a volume/filesystem root;
5. resolve the existing parent's symlink/junction/real-path aliases where the
   platform supports them;
6. on a case-insensitive filesystem, apply `FChar::ToLower` independently to
   each TCHAR for the identity comparison/hash; on a case-sensitive filesystem
   preserve exact case; and
7. verify the final namespace, Packs, Generations, temp, and final paths remain
   descendants of the canonical base.

If the platform cannot produce one stable canonical identity for the selected
root, writable V1 construction returns `InvalidRoot`. It does not create two
locks for two aliases of the same directory.

## Pointer wire V1

### Version, magic, and kind

```text
PointerSchemaVersion = 1
PointerMagic         = 8 ASCII bytes "UEASCV2C"

EAngelscriptCachePointerKind : u8
  Invalid=0
  Current=1
  Previous=2
  PendingColdStart=3
```

### Fixed 80-byte file

Every `.ascurrent` is exactly 80 bytes:

```text
offset 0   8 bytes  ASCII "UEASCV2C"
offset 8   u32 LE   PointerSchemaVersion, exactly 1
offset 12  u8       PointerKind
offset 13  3 bytes  reserved, exactly zero
offset 16  32 bytes GenerationId, nonzero
offset 48  32 bytes PointerChecksum
EOF exactly at byte 80
```

PointerChecksum is direct BLAKE3-256 over exactly bytes `[0,48)`, with no
external prefix:

```text
PointerChecksum = BLAKE3_256(PointerBytes[0..47])
```

Magic, schema, kind, reserved bytes, and GenerationId all enter the checksum.
The filename and embedded PointerKind must agree. Current bytes cannot be
renamed to Previous without reconstructing kind/checksum.

A missing pointer file means that slot is absent and is not corruption. An
empty, short, long, zero-ID, wrong-kind, wrong-schema, nonzero-reserved, or
checksum-mismatching pointer is invalid. A pointer does not duplicate
Compatibility, Context, Profile, or SourceSnapshot; those values come from the
referenced immutable manifest and remain the sole authority.

Pointer validation is a store/pointer result, not an archive validation error.
Once a pointer resolves its manifest, manifest/pack failures use the nested
`FAngelscriptCacheValidationResult` frozen elsewhere.

## Temporary files

Every temporary file is created in the same final directory and therefore the
same volume/filesystem as its destination:

```text
Packs/<PackHex>.aspack.tmp.<WriterToken>
Generations/<GenerationHex>.asmanifest.tmp.<WriterToken>
Current.ascurrent.tmp.<WriterToken>
Previous.ascurrent.tmp.<WriterToken>
PendingColdStart.ascurrent.tmp.<WriterToken>
```

WriterToken is `<decimal-process-id>-<32-lower-hex-characters>`, where the
second component is the exact lower-case encoding of a 128-bit random nonce.
It is unique for one publication attempt, is never a persistent identity, and enters no
PackId, GenerationId, pointer bytes, lock name, report identity, or final
filename.

A reader never accepts a name containing `.tmp.`. A live writer records every
temp it creates and only attempts to delete those exact paths during local
failure cleanup. A process crash cannot clean its own files; after the next
writer owns the namespace lock, it may delete residual names only when they
strictly parse as one of the five temp patterns above. It never recursively
deletes the namespace or treats an invalid final file as temp.

Because only one writer owns the namespace lock, every matching temp found
before the new writer creates its own token is stale. No age heuristic is used.
Failure to delete a stale temp is diagnostic and does not make that temp
readable.

## Required platform atomic-file seam

### Why generic move is insufficient

V1 does not implement pointer replacement with
`IFileManager::Move(Dest, Src, Replace=true)`. UE's generic implementation may
delete Dest before moving Src; a process stop in that gap leaves no Current and
violates the old-or-new atomic-pointer requirement.

The Runtime owns an injectable platform seam equivalent to:

```cpp
class IAngelscriptCacheAtomicFileOps
{
public:
    virtual FAngelscriptCacheStoreResult CanonicalizeAndValidateRoot(
        const FString& RequestedBaseRoot,
        FAngelscriptCanonicalCacheRoot& OutRoot) = 0;

    // Idempotently creates only a caller-validated Base, Namespace, Packs, or
    // Generations directory tree. It never accepts a glob or deletes content.
    virtual FAngelscriptCacheStoreResult EnsureDirectoryTree(
        const FString& DirectoryPath) = 0;

    virtual FAngelscriptCacheStoreResult WriteFlushClose(
        const FString& TempPath,
        TConstArrayView<uint8> Bytes) = 0;

    virtual FAngelscriptCacheStoreResult ReopenReadAll(
        const FString& Path,
        uint64 MaxBytes,
        TArray<uint8>& OutBytes) = 0;

    // Destination must not exist. Never replaces an immutable final object.
    virtual FAngelscriptCacheStoreResult RenameNewImmutable(
        const FString& TempPath,
        const FString& FinalPath) = 0;

    // Success guarantees observers see either the complete old pointer or the
    // complete new pointer, never missing/partial bytes.
    virtual FAngelscriptCacheStoreResult AtomicInstallOrReplacePointer(
        const FString& TempPath,
        const FString& PointerPath) = 0;

    // Success guarantees observers see the complete old pointer or absence.
    virtual FAngelscriptCacheStoreResult AtomicRemovePointer(
        const FString& PointerPath) = 0;

    // Removes only the caller-supplied, already validated same-directory temp
    // path. This is never used for final objects or pointer slots.
    virtual FAngelscriptCacheStoreResult RemoveOwnTemp(
        const FString& TempPath) = 0;

    // Removes only a direct-child final Pack or Manifest path whose strict
    // content-addressed basename was already validated by the locked compactor.
    // A live-reader sharing refusal returns DeleteDeferred rather than weakening
    // the committed pointer state.
    virtual FAngelscriptCacheStoreResult RemoveFinalImmutable(
        const FString& FinalPath) = 0;

    virtual FAngelscriptCacheStoreResult SyncDirectory(
        const FString& DirectoryPath) = 0;

    virtual bool SupportsSharedAtomicCacheStore() const = 0;
};
```

`WriteFlushClose` performs a complete write, calls `IFileHandle::Flush(true)`
or a stronger platform equivalent, verifies success, and closes the handle.
Every temp is then reopened from the filesystem and byte/ID validated before a
rename/replace. Validating only the original memory buffer is insufficient.

`EnsureDirectoryTree` is the first-launch directory boundary. The Store invokes
it only after it has built the exact canonical paths and owns the namespace
writer lock. It creates Base, Namespace, Packs and Generations idempotently,
then the Store re-canonicalizes Namespace/Packs/Generations and requires their
resolved identities to equal the precomputed descendants. This prevents a
junction/symlink alias inserted at a newly created component from redirecting
later final or temp paths. A crash during directory creation commits no pointer;
the next launch may safely repeat the operation.

`RemoveOwnTemp` is the injectable cleanup boundary required by the failure rule
above. Store control flow may call it only for an exact temp path constructed
from the current publication's validated `WriterToken` and recorded by that
attempt. A cleanup failure is diagnostic and does not replace the primary
write/read/validation/rename failure. Generic recursive deletion and removal of
final names remain forbidden.

`RenameNewImmutable` is same-volume and no-replace. `AtomicInstallOrReplacePointer`
uses a platform primitive with replace-existing atomicity and durable rename
semantics. `SyncDirectory` durably records directory-entry changes: POSIX
implementations fsync the parent directory; Win64 uses a write-through atomic
move/replace primitive and any additional platform directory durability step
available. A platform implementation documents the local filesystems on which
it can make this guarantee.

V1 writable sharing is enabled only when the target platform supplies both a
working cross-process lock and `SupportsSharedAtomicCacheStore()`. In the
current UE platform surface, Win64/Linux/macOS have a system-wide mutex type;
Android/iOS alias it to a not-implemented type unless the plugin supplies an
equivalent. Unsupported targets return `UnsupportedPlatformAtomicity` and do
not silently use delete-then-move or an in-process-only mutex. Read-only
inspection of already valid immutable bytes may remain available, but the
first-launch write-through guarantee is not claimed until that target has a
real implementation.

Remote/network/removable filesystems that cannot guarantee same-filesystem
atomic replacement and durability are rejected for writable overrides. V1's
crash/power-loss guarantee applies to a supported local store after successful
full flush, atomic rename/replace, and directory sync.

## Immutable object installation

Packs and manifests become immutable after final rename. For each missing
object the writer:

1. writes its same-directory unique temp completely;
2. full-flushes and closes it;
3. reopens it through the filesystem;
4. validates the complete pack/manifest bytes and expected PackId/GenerationId;
5. renames it to the no-replace final name;
6. syncs the parent directory; and
7. reopens and revalidates the final object before any pointer commit.

All required packs become final and valid before the manifest temp is written.
The manifest becomes final and valid before any publication pointer is
replaced.

If a final content-addressed name already exists:

- a complete re-read with equal expected ID and byte-exact content is reused;
- an invalid file or same name with different bytes returns
  `ImmutableObjectCollisionOrCorruption`; and
- ordinary publication never overwrites, deletes, repairs, or quarantines it.

Explicit verify/repair tooling may later quarantine an invalid object under a
non-authoritative diagnostic name, but that is not an implicit publication
side effect. BLAKE3 collision and disk corruption are both fail-closed at the
immutable namespace boundary.

## System-wide namespace lock

### Lock identity

The lock is derived from the canonical absolute **namespace** path, not merely
the base root. Its hash is built by the existing
`FAngelscriptArtifactCanonicalWriter`:

```text
domain = "cache-store-lock"
WriteString(CanonicalAbsoluteNamespacePathUsingForwardSlashes)
LockHash = FinalizeHash()
LockName = "UEASCacheV2-" + lower-case full 64-hex LockHash
```

This uses the already frozen canonical-writer byte stream (`UEAS-ARTIFACT`,
NUL, IdentitySchemaVersion 1, length-prefixed domain, then length-prefixed UTF-8
string). The safe ASCII LockName may then pass through the platform's mutex-name
sanitizer without changing its uniqueness.

Compatibility/context namespaces use distinct locks. Every mutation of final
objects, pointers, stale temps, or compaction state requires this lock.

### Acquisition, cancellation, and abandoned locks

Lock acquisition receives the caller's deadline and cancellation token. It
attempts ownership in at most 100-millisecond wait slices, checking cancellation
and deadline between slices. A shutdown flush therefore remains bounded by its
caller-supplied five-second deadline instead of blocking inside one mutex wait.

Failure to acquire returns `LockTimeout` or `Cancelled` with NotCommitted.
An abandoned platform mutex may report owned/valid while shared files are in an
unknown previous-writer state. The new owner always cleans only recognized
temps and rereads/revalidates all pointers/final objects; it never trusts an
in-memory base merely because lock acquisition succeeded.

The frozen lock order is engine mutation gate first, namespace lock second.
Store code never calls back into AngelScript/UE engine mutation while holding
the namespace lock. Pure readers may briefly take only the namespace lock to
pin immutable handles as defined below.

## Publication request and rebase

A publication request is one immutable pointer-free DTO and contains at least:

- disposition: Current or PendingColdStart;
- CompatibilityKey, ContextKey, ProfileKey, SourceSnapshot;
- exact SourceIndex, keyed ModuleSnapshot roots, reachable prepared records;
- the selected slot's observed base GenerationId or explicit Absent;
- a source-validation epoch/token owned by the caller; and
- cancellation/deadline.

No worker/store writer rereads mutable module descriptors or calls AS engine
APIs.

After acquiring the namespace lock and before writing final bytes, the writer
reopens Current, Previous, and PendingColdStart and revalidates every usable
manifest/pack location needed for reuse.

### Rebase rules

1. If the selected slot still equals the observed base, continue.
2. If another writer changed the selected slot but its valid SourceSnapshot is
   equal to the DTO SourceSnapshot, rebase content-addressed locations.
3. If the selected slot changed to a different SourceSnapshot, return
   `NeedsSourceRevalidation` without publication. The store cannot decide which
   process observed current source; the caller must resnapshot/revalidate.
4. Reuse candidates come only from valid retained manifests. For one RecordId
   with multiple valid locations, choose Current first, then Previous, then an
   eligible PendingColdStart, and within one slot choose lowest full PackId then
   lowest offset.
5. Exact reachable records with no selected reusable location enter the frozen
   deterministic pack builder.
6. Recompute all final locations, manifest bytes, and GenerationId after
   rebase. Any pre-lock GenerationId is provisional.
7. If the now-Current generation has equal Compatibility, Context, Profile,
   SourceSnapshot, keyed roots, and exact RecordId set, it is the winner and
   publication succeeds as `AlreadyCurrent` without rotating Previous or
   writing an alternate physical layout.
8. Equal SourceSnapshot but different semantic roots/RecordId set is
   `RebaseSemanticConflict`, not last-writer-wins. It indicates producer
   nondeterminism or an unrepresented source race.

For Pending publication, the same rules compare the observed/current Pending
slot. Pending may intentionally describe source newer than active Current, so a
different Current alone is not a rebase conflict; its caller-provided source
epoch must still be valid.

If old Current pointer/manifest/packs are corrupt, it is not promoted to
Previous. A valid existing Previous remains untouched while the new valid
Current may still be published. A missing Current is the first-publish case.

## Current and Previous publication protocol

After every new pack and manifest is final, reopened, and valid:

1. construct Current pointer bytes for the new GenerationId;
2. write/full-flush/close/reopen-validate its unique Current temp;
3. if old Current is a fully valid generation, construct Previous pointer bytes
   of kind Previous pointing to old Current's GenerationId, then
   write/full-flush/close/reopen-validate its unique Previous temp;
4. emit `AfterPointerTempsFlush` fault point;
5. if a Previous temp exists, emit `BeforePreviousReplace`, atomically
   install/replace Previous, sync the namespace directory, and emit
   `AfterPreviousReplace`;
6. emit `BeforeCurrentReplace` fault point;
7. atomically install/replace Current;
8. **successful Current atomic replace is the publication commit point**;
9. sync the namespace directory;
10. emit `AfterCurrentReplace` fault point; and
11. report committed outcome.

On first publication there is no Previous temp/replacement. Missing Previous
remains valid absence.

If the process stops after Previous replacement but before Current replacement,
Current still selects old Current and Previous also points to that same valid
generation. The older Previous may be lost, but no half-published generation is
selected. If it stops after Current replacement, Current selects the new valid
generation and Previous selects old Current.

A directory-sync error after successful Current replacement reports an error
with `CurrentCommitted`; it never claims NotCommitted or attempts rollback.

## Pending publication and promotion

A PendingColdStart-only request writes/finalizes packs and manifest in the same
way, prepares and revalidates a Pending pointer temp, emits
`BeforePendingReplace`, atomically installs/replaces only
`PendingColdStart.ascurrent`, syncs the namespace directory, and emits
`AfterPendingReplace`. It never changes Previous or Current. Successful Pending
replacement is the Pending commit point even if the later directory sync
reports `DirectorySyncFailed`.

Promotion is authorized only by a later successful cold/full transaction that
has revalidated source, environment, module assembly, and ClassGenerator. It
then performs the normal Current/Previous protocol using the Pending generation
or an equivalent rebased generation. Only after Current is committed may it
call `AtomicRemovePointer(PendingColdStart)` when Pending still points to the
promoted GenerationId, followed by directory sync.

A process stop may leave redundant Pending pointing to the same generation as
Current. This is valid and does not override Current. A later locked writer or
compactor removes it after revalidation.

## Fault-injection points and crash invariants

The store seam exposes these exact deterministic points:

```text
BeforePackTempWrite
AfterPackTempFlush
AfterPackRename
AfterManifestTempFlush
AfterManifestRename
AfterPointerTempsFlush
BeforePreviousReplace
AfterPreviousReplace
BeforeCurrentReplace
AfterCurrentReplace
BeforePendingReplace
AfterPendingReplace
```

`AfterPackTempFlush` and `AfterManifestTempFlush` occur after full flush and
close but before reopen validation. `AfterPackRename` and
`AfterManifestRename` occur only after no-replace rename, parent-directory
sync, and final reopen/identity validation. `AfterPointerTempsFlush` occurs
after every pointer temp required by that request has been full-flushed,
closed, and reopened successfully. The Before pointer points are immediately
before the platform atomic call; the After points are after successful atomic
replacement and required directory sync.

At every injected stop:

- a temp file is never accepted;
- any final pack/manifest is complete, immutable, and identity-valid;
- before successful Current replacement, old Current remains selected;
- after successful Current replacement, new Current is selected;
- after Previous but before Current, Previous may equal Current and both are
  valid;
- Pending-only points never change Current/Previous;
- orphan final objects are allowed and reclaimed only by compaction; and
- a subsequent writer can acquire the lock, clean recognized temps, reread
  pointers, and continue without a repair-on-startup requirement.

## Cancellation and commit-state rules

Cancellation is observed during pure preparation, lock wait, between file
operations, and before pointer replacement. Its exact result is:

| Observation point | Required outcome |
|---|---|
| before lock or during pure preparation | `Cancelled`, NotCommitted, no final/pointer mutation |
| during lock wait | `Cancelled`, NotCommitted |
| before/after temp write/flush | delete own known temps best-effort; NotCommitted |
| after immutable pack/manifest rename but before pointer protocol | leave orphan immutable objects; NotCommitted |
| after Previous replace but before Current call | may stop; Current remains old, NotCommitted |
| before `AtomicInstallOrReplacePointer(Current)` | last cancellable Current point |
| Current replace returns success | CurrentCommitted; ignore later cancellation; never rollback |
| Current replace returns failure/indeterminate | reread Current under lock; new ID means CurrentCommitted, otherwise NotCommitted |
| Pending replace returns success | PendingCommitted; ignore later cancellation |
| compaction pointer switch commits | CompactionCommitted; sweep cancellation may defer deletion but not rollback pointers |

Already-final immutable objects are never deleted as cancellation rollback.
Another generation may already reuse them; only root-based compaction decides
their lifetime.

## Immutable read-session pinning

### Why pointer-only pinning is insufficient

Reading Current once prevents following a moving pointer, but does not prevent
a compactor from unlinking the old manifest/pack before a lazy reader opens it.
V1 therefore pins actual immutable file handles.

### Session-open protocol

One `OpenBestGeneration` attempt owns one cumulative
`FAngelscriptCacheReadBudget` across Current/Previous/Pending candidates; a bad
candidate or retry does not reset it.

For each candidate in selection order, the reader:

1. briefly acquires the namespace lock using its deadline/cancellation token;
2. reads and validates the complete 80-byte pointer;
3. opens and reads the referenced manifest with MaxManifestBytes, validates its
   local wire and GenerationId, and counts distinct nonzero PackIds before any
   pack open;
4. requires that count to be at most MaxGenerationPacks (default 4,096), charges
   the bounded handle/index preparation through the same read budget, and
   returns nested `BudgetExceeded` at SessionPin without opening a pack when it
   exceeds the limit;
5. opens and pins the manifest handle and every distinct referenced pack handle
   before releasing the lock;
6. uses platform delete-sharing when available so compaction may unlink while
   the open handle remains readable; if deletion sharing is unavailable, the
   open handle intentionally causes deletion to defer;
7. releases the namespace lock; and
8. validates complete PackIds, locations, records, reachability, graph, and
   eligibility using only the pinned handles and captured manifest bytes.

The resulting immutable session stores GenerationId, decoded manifest,
validated eligibility coordinates, the one cumulative budget, and all pack
handles. It never rereads Current and never substitutes a path-opened pack.
Closing/destroying the session releases every handle.

The store writer applies the same MaxGenerationPacks limit to every final
manifest before writing it. Rebase and compaction may not publish a manifest
that the immutable session contract would refuse to pin.

If a candidate fails after pinning, its handles are released and the next
candidate repeats the short locked open. Failure to open one required pack is a
candidate failure, never permission to read a different file with the same
offset.

## Candidate selection, fallback, and source authority

The deterministic fresh/cold candidate order is:

```text
Current -> Previous -> PendingColdStart
```

PendingColdStart is considered only when the caller explicitly marks the
operation fresh/cold eligible; it is skipped for an already-active PIE engine
or ordinary soft reload.

Each candidate must independently pass:

- pointer integrity and filename-kind agreement;
- manifest and all required pack physical validation;
- CompatibilityKey, ContextKey, ProfileKey equality;
- exact manifest/record/module graph validation; and
- SourceIndex.SourceSnapshot equality with the authoritative current source
  snapshot discovered for this load.

Compatibility/context/profile/source/current ABI mismatches retain their
archive Ineligible classification. Corrupt Current does not make a
different-source Previous/Pending eligible. If no source-matching valid
candidate exists, the result is a cache miss and the caller compiles current
source.

Physical pointer/manifest/PackId/index/location corruption rejects that
generation candidate. If complete physical identity is valid but one semantic
record or ModuleSnapshot graph fails, the owning ModuleSnapshot is a safe
compile miss as frozen by the record/graph contracts; no partial snapshot is
attached. Because PackId covers the complete file, ordinary stored-byte bit rot
normally rejects the whole candidate before module planning.

A fresh-start parse/compiler/ClassGenerator failure for current source remains
authoritative. It never triggers a later attempt to execute a different-source
cached generation. For an already-active editor/runtime hot reload, failure
keeps the in-memory last-good active modules and leaves Current unchanged; that
lifecycle behavior is not a stale disk fallback.

## Physical retention roots

Selection eligibility and deletion safety are distinct:

- logical selection uses the source/profile rules above;
- physical mark/sweep treats every currently present, valid Current, Previous,
  or Pending pointer as a root until that pointer is successfully atomically
  removed/replaced.

This prevents an ineligible-but-still-present Pending pointer from dangling.
Duplicate pointers to one GenerationId are deduplicated for work but remain
valid. Every rooted manifest and every pack referenced by its record index is
retained. A pack remains whole while any rooted manifest references one entry;
normal startup/publication never repacks merely to remove its unreferenced
entries.

Missing/invalid pointers are not roots. Orphan temp files, orphan manifests,
and packs not reachable from physical pointer roots are not candidates, but
their presence is not a startup error. Startup may count/report them; it never
performs full mark/sweep or blocks on compaction.

## Explicit compaction V1

Compaction requires an authoritative current SourceSnapshot and Profile. If
the caller cannot provide them, it returns `NeedsSourceRevalidation` before
mutation. V1 does not guess Pending eligibility.

Compaction is two crash-safe phases. Both use the namespace lock, but Phase B
reacquires it and recomputes roots so an intervening normal publication is
safe.

### Phase A: rewrite and switch

1. acquire the namespace lock and clean only recognized stale temps;
2. reopen/validate Current, Previous, and Pending physical roots;
3. if Pending is not source/profile eligible, call AtomicRemovePointer and sync
   the directory; only confirmed absence removes it from physical roots;
4. compute the union of semantic records reachable from all remaining valid
   physical roots;
5. rebuild that union through the frozen deterministic pack grouping policy,
   intentionally excluding pack-only unreachable extras; if a rebuilt PackId
   already exists byte-identically, reuse it;
6. for each retained semantic generation, rewrite only its record locations,
   preserving Compatibility/Context/Profile/SourceSnapshot/roots/RecordIds,
   and compute its new physical GenerationId;
7. finalize/revalidate all replacement packs and manifests before pointers;
8. atomically replace rewritten slot pointers in order Previous,
   PendingColdStart, Current; these are same-slot physical rewrites, not normal
   Previous rotation;
9. sync after every pointer replacement; and
10. successful Current replacement, or the final existing-slot replacement
    when Current is absent, marks Phase A CompactionCommitted.

A process stop during pointer switching leaves a mixture of old and new
pointers, but every referenced old/new manifest and pack remains present and
valid. No immutable manifest or pack deletion occurs in Phase A; its only
removals are recognized stale temps and a confirmed ineligible Pending pointer.

Compaction may change GenerationIds without changing source or semantic
RecordIds. Diagnostics report `CompactionLayoutRewrite`, not a source edit.

### Phase B: mark and sweep

1. release and reacquire the namespace lock;
2. reread every physically present valid pointer, including a Pending that may
   have reappeared through another publication;
3. mark exactly those manifests and every PackId they reference;
4. enumerate only strict final-name patterns under Generations and Packs;
5. delete unmarked final manifests/packs and recognized stale temps;
6. sync affected directories; and
7. release the lock.

`RemoveFinalImmutable` is not a general deletion API: callers may pass only an
exact direct child discovered under `Packs/` or `Generations/` whose basename is
respectively `<lower-full-hash>.aspack` or
`<lower-full-hash>.asmanifest`. It is never used for pointer slots, temp files,
directories, recursive paths or unvalidated caller input.

An already-open V1 read-session handle remains valid after unlink on platforms
with delete-sharing/POSIX unlink semantics. If the platform refuses deletion
because a reader has the file open, record `DeleteDeferred`, keep the file, and
retry on a later explicit compaction. Deletion failure never invalidates the
committed replacement pointers.

Compaction does not run automatically at startup. A future background-idle
trigger may call this same explicit protocol, but cannot invent a weaker GC
path.

## Store result, stage, and error contract

These values are control-plane diagnostics and are not serialized in pack,
manifest, or pointer wire.

```text
EAngelscriptCacheStoreCommitState : u8
  NotStarted=0
  NotCommitted=1
  CurrentCommitted=2
  PendingCommitted=3
  CompactionCommitted=4

EAngelscriptCacheStoreStage : u8
  None=0
  RootValidation=1
  LockAcquisition=2
  TempCleanup=3
  Rebase=4
  PackTemp=5
  PackFinal=6
  ManifestTemp=7
  ManifestFinal=8
  PreviousPointer=9
  CurrentPointer=10
  PendingPointer=11
  SessionPin=12
  CandidateValidation=13
  CompactionRewrite=14
  CompactionSwitch=15
  CompactionSweep=16

EAngelscriptCacheStoreError : u8
  None=0
  InvalidRoot=1
  PathEscapesRoot=2
  UnsupportedPlatformAtomicity=3
  LockTimeout=4
  Cancelled=5
  OpenFailed=6
  ReadFailed=7
  WriteFailed=8
  FlushFailed=9
  RenameFailed=10
  AtomicReplaceFailed=11
  ImmutableObjectCollisionOrCorruption=12
  PointerInvalid=13
  ManifestMissing=14
  PackMissing=15
  NeedsSourceRevalidation=16
  RebaseSemanticConflict=17
  PointerRemoveFailed=18
  DeleteDeferred=19
  ContentValidationFailed=20
  DirectorySyncFailed=21
  FaultInjected=22
```

A store result carries Error, Stage, CommitState, optional nested
`FAngelscriptCacheValidationResult`, GenerationBefore/After, a sanitized path
category (`Root`, `Pack`, `Manifest`, or pointer slot), and an optional platform
error code for diagnostics. Stable reports do not serialize process-absolute
paths.

`ContentValidationFailed` requires the nested archive result. PointerInvalid
does not create an archive error. `DeleteDeferred` may be returned as a
nonfatal compaction warning with CompactionCommitted. `DirectorySyncFailed`
after a successful pointer replace carries the committed state. Callers never
infer NotCommitted merely because Error is non-None. `FaultInjected` is emitted
only by the optional transaction-local deterministic process-stop seam; it is
not a persisted value or a normal runtime failure. Its CommitState and
GenerationBefore/After report whether the exact injected checkpoint is before
or after the pointer commit point.

## Required store and crash evidence

Before Task Group 3 is GREEN, tests use an injected deterministic filesystem,
clock/cancellation source, atomic-file seam, and lock seam to freeze:

- first start with no namespace/pointers and first Current publish with no
  Previous;
- exact root/namespace/final/temp filenames and containment rejection;
- full 80-byte Current/Previous/Pending pointer goldens and every malformed
  field/checksum/trailing case;
- immutable exact-content reuse and same-name corrupt/different-byte refusal;
- every fault point's exact visible pointer/final/temp state;
- full flush/reopen-validation/rename/atomic-replace/directory-sync failure;
- rejection of a delete-then-move fake as unsupported atomic replacement;
- cancellation before/after each commit point and indeterminate replace reread;
- same-source/same-semantic concurrent no-op, same-source/different-semantic
  conflict, and different-source `NeedsSourceRevalidation`;
- lock timeout, 100-ms cancellation polling, abandoned-lock full reread, and
  compatibility/context lock isolation;
- MaxGenerationPacks+1 distinct IDs returning nested `BudgetExceeded` at
  SessionPin with zero pack-handle opens, plus an injected smaller positive
  limit that pins exactly the allowed count;
- reader pointer/manifest/pack handle pin while Current moves and compaction
  unlinks/defer-deletes old files;
- Current corruption fallback in exact order without different-source stale
  execution;
- Pending cold eligibility versus active PIE exclusion and post-promotion
  redundant Pending cleanup;
- retention of all physically rooted files and startup non-compaction; and
- two-phase compaction, crash-time old/new pointer mixtures, intervening normal
  publication before Phase B, deferred reader deletion, and later successful
  sweep.

Real multi-process and packaged launch acceptance remains later than these
pure/fake-store RED/GREEN tests, but it must exercise the same platform seam and
state machine rather than a second implementation.

## Closed V1 decisions

V1 has no remaining choice about root override semantics, hash filename case,
pointer text versus binary, pointer checksum, temp naming, final overwrite,
flush/reopen validation, delete-then-move, commit point, writer-lock identity,
lock polling, rebase winner/conflict behavior, cancellation after commit,
reader pinning, fallback order, physical versus eligible roots, Pending removal,
or compaction switch/sweep ordering. Changing one requires an explicit store
contract revision and corresponding crash/concurrency test updates; it is not
left to platform or implementation convenience.
