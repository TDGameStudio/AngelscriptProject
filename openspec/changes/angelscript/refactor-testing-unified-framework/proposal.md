# Unified AngelScript testing framework

## Why

The reconstruction has a useful replacement CQTest foundation, a large external
`TestSource` collection, Python generation and SourceHistory utilities, and an
older working data-driven prototype in the `script-corpus` workspace. These
pieces do not yet form one supported authoring-to-execution path. Source lookup,
case metadata, expected results, registration, fixture lifetime, and evidence
have overlapping historical owners. A source file or a successful export has
also been too easy to mistake for executed coverage.

The accepted direction preserves the useful work while establishing one source
entry point, explicit test ownership, independently addressable data rows, and a
testing guide that cannot accidentally reactivate the legacy framework.

## Delivery boundary

**This delivery creates this Change only.** It does not edit framework code,
generators, tests, Skill files, current specifications, or other Changes. Every
node in `tasks.md` describes future work and remains unchecked. The user has
explicitly requested detailed landing decisions before implementation.

This Change remains active after strict planning validation. Do not apply,
synchronize, archive, commit, integrate the historical workspace, or create a new
workspace merely because the planning artifacts are complete.

## What Changes

- Keep `FAngelscriptTestCode` as the sole public AS test-source center. Absorb the
  source responsibilities of `FAngelscriptTestScriptCorpus` and the useful
  Snippet lookup/query functions. Use `FAngelscriptTestSourceStore` only as an
  internal storage implementation.
- Support external AS, local inline AS, generated source, and AS-free C++ data
  cases without requiring every test to have an AS file or JSON manifest.
- Retain `TestSource` as the file-based case/row authoring center. Checked-in
  AngelScript TestCode originals are structured mirrored registrations owned by
  `angelscript/refactor-test-code-structured-registration`. Runtime tests consume
  that database and inline sources without reading the parent authoring directory
  or a second shard/aggregate carrier.
- Make `SourceId + VersionTag` the source reference. Retain root source plus
  comment-contained child snapshots; generate and verify parent-to-child diffs.
  Source ancestry and C++ reload execution order are separate contracts.
- Introduce `AS_TEST_SOURCE(R"AS(...)AS")` and an explicit exact-text variant,
  returning an owning source object rather than changing legacy `ASTEST_AS`
  string semantics. Keep exact bytes, UTF-8 ownership, and source mapping explicit.
- Register typed data rows as independent Automation items through one thin
  plugin adapter. Keep ordinary CQTest and its public assertion API.
- Separate input/source truth, case/oracle truth, and run evidence. Unsupported
  capabilities, skipped execution, and unverified corpus entries are never PASS.
- Consolidate the testing Skill after implementation reaches each documented
  capability. Immediately applicable authoring rules have their own future
  documentation task, including no anonymous namespace solely for one CQTest
  class, class-local helpers, public hooks, and visible scenario flow.

## Success criteria

1. A reader can follow all three authoring entrances to discovery, execution,
   cleanup, and evidence without choosing between parallel source centers.
2. Inline and embedded source resolve to the same owned input abstraction;
   `SourceId`, `VersionTag`, content hash, logical path, and host origin have
   distinct meanings.
3. Every selected data row is independently named and reported; changing row
   order does not change identity or hide subsequent rows after a failure.
4. SourceHistory can reconstruct every tag and explain a failed reload without
   promoting the failed candidate to the active/last-good runtime state.
5. A plugin checkout can consume its generated source release without Python or
   the parent authoring tree. Parent regeneration detects stale generated data.
6. Future tasks specify files, prerequisites, exact proofs, failure cases, and
   realistic adoption examples. Current Skill instructions never claim a
   proposed API is already callable.

## Capabilities

### New capabilities

- `angelscript/testing/test-code`: source identities, input forms, local source
  scope, and the public TestCode entry point. Checked-in original-file delivery
  is owned by the structured-registration Change.
- `angelscript/testing/source-history`: tagged trees and later reload-history
  materialization. This is not the checked-in TestCode carrier.
- `angelscript/testing/data-driven`: typed rows, discovery, fixture lifecycle,
  capability selection, reproducible generators, and evidence.
- `angelscript/testing/authoring`: test structure, inline macro semantics,
  truthful current guidance, and example promotion.

### Modified capabilities

- `angelscript/testing/baseline`: extend replacement discovery with data-row
  identity and retain the dormant legacy/source-isolation boundary.

## Ownership and compatibility

Future implementation touches the parent (`TestSource`, Skill, OpenSpec) and the
`Plugins/Angelscript` submodule (test framework, tooling package, generated
release, and replacement tests). `Source/AngelscriptProject` remains minimal.
Only this parent Change directory is modified by the present delivery.

The current target is **UE 5.8**. The older UE 5.7 sentence in OpenSpec's shared
project context is historical; it does not override current project instructions.
Use `WITH_ANGELSCRIPT_TESTS`, `NewVersion`, and `Angelscript.UnitTest.*`.
`WITH_ANGELSCRIPT_UNITTESTS`, legacy engine pools, old force includes, dormant
runtime services, and their Automation prefixes remain inactive.

The active `angelscript/refactor-builder-engine-independent` work is a
coordination boundary. This Change does not own language grammar, Builder
semantics, engine registration, or its task state. Frontend test adapters consume
public source/diagnostic/stage interfaces and must not introduce a second parser
or engine-dependent frontend path.

## Explicit exclusions

No complete legacy corpus migration, parallel `Bindings2`/`Coverage2` tree,
independent database service, web editor, long-running fuzz platform, automatic
reducer, standalone native runner, or restoration of VM/cache/JIT/World/reload
runtime support is included in the first implementation slice. Their extension
contracts and acceptance boundaries are recorded in the design. No new review
workflow or unconditional full-suite gate is introduced.

## Reading order

Read `tasks.md` and `attachments/INDEX.md` first when resuming. `design.md` owns
implementation decisions; delta specs own durable behavior; indexed authoring
examples make the public interface concrete. Existing implementation and
historical execution evidence are classified in the provenance attachment.
