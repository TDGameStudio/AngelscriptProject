# SourceIndex / ModuleInterface decoder migration audit

Date: 2026-08-08
Scope: read-only current-consumer and ownership audit for IC-122/IC-137.
Implementation status: migration not yet applied; this attachment fixes the
consumer map and deletion order before the common private bridge is written.

## Required end state

The seven-kind `FAngelscriptDecodedCacheRecord::TryDecodeInternal` is the only
record-level candidate transaction, decoded-allocation charge authority, retained
owner and publication boundary. SourceIndex and ModuleInterface reuse their mature
private physical/semantic algorithms, but neither public legacy decoder may be
called by the common factory.

```text
one immutable common owner
one TryDecodeInternal
one decoded candidate
one constructor-owned charge sink
one canonical-payload copy
one physical decode
one complete typed offset capture
one PromoteToRetained
one final handle publication
```

No compatibility wrapper is required: the plugin is pre-release and the audit
found no Runtime/Editor consumer outside the implementation unit and tests.

## Current SourceIndex path

Public/transitional declarations:

- `Cache/AngelscriptCacheSemanticRecords.h:535` —
  `FAngelscriptValidatedSourceIndex`, a second owning validated token;
- `:798` — `DeserializeSourceIndex`;
- `:808` — test-only `DeserializeSourceIndexForTests`.

Implementation path:

- `Cache/AngelscriptCacheSemanticRecords.cpp:2877` — physical
  `ReadSourceIndexPayload`;
- `:1752` — `PrepareSourceIndex` local semantic/graph preparation;
- `:4966` — `DeserializeSourceIndexInternal`;
- `:5020` — public owning wrapper;
- `:5136` — test-only raw DTO wrapper.

The current wrapper begins and promotes its own decoded candidate and moves the DTO
into `FAngelscriptValidatedSourceIndex`. Its `FSourceIndexReadOffsets` at `:1726`
captures only ten coarse top-level offsets. It does not preserve the final 89 valid
wire field coordinates (`EAngelscriptSourceIndexCapturedField` values `1..89`;
the enum has 90 values only when `Invalid=0` is counted).

## Current ModuleInterface path

Public/transitional declaration:

- `Cache/AngelscriptCacheSemanticRecords.h:803` —
  `DeserializeModuleInterface`, returning a mutable DTO.

Implementation path:

- `Cache/AngelscriptCacheSemanticRecords.cpp:3916` — physical
  `ReadModuleInterfacePayload`;
- `:3549` — `PrepareModuleInterface`;
- `:5074` — public wrapper with its candidate lifecycle inlined.

Its `FModuleInterfaceReadOffsets` at `:1740` captures only eight coarse top-level
offsets. It does not preserve the final 88 valid wire field coordinates
(`EAngelscriptModuleInterfaceCapturedField` values `1..88`; 89 including
`Invalid=0`).

Reusable mature helpers in the same implementation unit include:

- `:321` — stable-reference physical reader;
- `:377` — semantic-dependency reader;
- `:499` — recursive DataType reader;
- `:585` — Metadata reader;
- `:658` — Parameter reader;
- `:691` — Slot reader.

These algorithms are the reuse boundary. The old public record decoders and their
candidate/publication behavior are not.

## Current consumers

The only production consumer is SourceIndex exact-fast-path eligibility:

- `Cache/AngelscriptCacheSemanticRecords.cpp:4558` — internal query;
- `:4891` — public query wrapper;
- `:4910` — test capture wrapper.

It currently accepts `FAngelscriptValidatedSourceIndex`. The replacement accepts a
`const FAngelscriptDecodedCacheRecord&`, rejects wrong kind before ModuleKey and
before scratch allocation, then obtains the const SourceIndex DTO through
`TryGetSourceIndex()`.

All direct test consumers are localized in
`Source/AngelscriptTest/Cache/AngelscriptCacheSourceInterfaceTests.cpp`:

| Transitional expression | Current call-expression count |
|---|---:|
| `DeserializeSourceIndex` | 18 |
| `DeserializeSourceIndexForTests` | 11 |
| `DeserializeModuleInterface` | 12 |
| `QueryExactFastPathEligibility` | 18 |
| eligibility allocation-capture wrapper | 3 |

There are 62 migration call expressions and no distributed product compatibility
surface.

## Private bridge and capture design

Add `Cache/Private/AngelscriptCacheSemanticRecordCodec.h` with a narrowly friended
bridge. It borrows the factory's existing Limits, Budget and decoded charge sink and
decodes directly into the active final SourceIndex or ModuleInterface alternative:

```text
final alternative
  ├─ final DTO
  └─ final complete captured-offset storage
```

The bridge never begins/promotes a candidate and never publishes or owns a shared
handle. Reader helpers receive a capture policy (`NoCapture`, `SourceIndexCapture`
or `ModuleInterfaceCapture`) so serializers/primitive wrappers remain unchanged.

The one physical pass captures:

- top-level fields and array rows;
- nested fields;
- Optional presence/tag and present value independently;
- stable references and semantic dependencies;
- recursive DataType nodes in preorder;
- Metadata, Parameter and Slot rows;
- Source Mount/Provider/Hook/File/Input/Edge/Ineligible rows; and
- multiple logical coordinates that intentionally share one byte offset.

Every final offset-entry array is allocator-authoritatively reserved through the
same candidate charge sink before growth. Missing-coordinate lookup never falls
back to offset zero, no second byte scan/Reader run is permitted, and semantic
validators obtain enclosing error offsets from the captured diagnostic context
rather than guessing a top-level field.

## Migration and deletion order

1. Add the private bridge, capture policies and private Source/Module decode
   functions while the old wrappers temporarily keep the TU buildable.
2. Connect both alternatives to the existing sole common factory and its one
   candidate/sink.
3. Add the decoded-record eligibility query, with wrong-kind precedence before
   ModuleKey/access/scratch work.
4. Migrate all 62 test call expressions to the common handle and const typed
   accessors.
5. Replace the old validated-token move test with shared immutable-handle identity,
   zero-allocation copy and independent-reset lifetime tests.
6. Prove zero calls with `rg`, then remove the old query wrappers.
7. Remove the three old decoder declarations/definitions.
8. Remove `FAngelscriptValidatedSourceIndex` last.
9. Remove the old ten/eight coarse offset structs after the final capture policies
   are the only diagnostic source.

Shared primitive candidate infrastructure remains: do not remove
`FAngelscriptCacheSemanticCandidateAccess`, `MakeCandidateDecodedChargeSink` or the
canonical string/DataType primitive paths merely because the record wrappers are
deleted.

## Failure risks that must remain executable tests

- nested candidate, double Total/live charge or double promotion;
- old owning SourceIndex token wrapped inside the common token;
- mutable ModuleInterface intermediate copied into the variant;
- controller or canonical payload missing/double charge;
- output reset causing aliased-input use-after-free;
- offset arrays growing outside the charge sink;
- wrong active `TVariant` alternative;
- retaining only ten/eight coarse offsets;
- offset-zero fallback or a second payload scan;
- wrong-kind eligibility checked after ModuleKey/scratch;
- local-semantic errors retaining stage `None`;
- eligibility result allocations incorrectly charged as decoded-token storage.

## Focused verification after migration

Repository-wrapper SingleFile targets:

```text
AngelscriptCacheDecodedRecord.cpp
AngelscriptCacheSemanticRecords.cpp
AngelscriptCacheSourceInterfaceTests.cpp
AngelscriptCacheTypeSchemaTests.cpp
```

Focused Automation prefixes:

```text
Angelscript.TestModule.Cache.Archive.SourceInterface
Angelscript.TestModule.Cache.Archive.TypeSchema
Angelscript.TestModule.Cache.Archive.Primitives
Angelscript.TestModule.Cache.Budget
Angelscript.TestModule.Cache.Archive.DecodedRecordDeclaration
Angelscript.TestModule.Cache.RemainingRecordCoordinates
```

The final proof also requires a whole-tree zero-reference scan for the three legacy
decoder names, the old validated token and its query overload before deleting the
symbols.
