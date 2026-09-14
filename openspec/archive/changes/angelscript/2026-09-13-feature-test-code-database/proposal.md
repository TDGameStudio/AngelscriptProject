# Shared AngelScript test code database

## Why

Replacement tests need reusable, independently addressable source versions without reviving the dormant legacy runtime. The earlier unified-framework plan still describes SourceId, generated C++ diffs, and execution-layer work. The user explicitly requested a separate Change focused on the code database after reviewing the revised architecture.

## What Changes

- Introduce one exported AngelscriptTest::FAngelscriptTestCode center in AngelscriptTest.
- Store immutable SourceCase values indexed by relative file Tag and explicit version Tag.
- Accept original .as containers embedded as Windows resources and hand-written static C++ factories using AS_TEST_SOURCE.
- Parse Doxygen metadata, complete source versions, position annotations, and author-origin mappings.
- Defer factory execution until startup modules have loaded; admit each registration batch atomically.
- Return explicit construction, activation, and lookup errors without compiling source or aborting editor startup.
- Prove resource content and file-set changes through the real installed-engine build path.

## Capabilities

### New Capabilities

- `angelscript/testing/code-database`: reusable source authoring, ownership, providers, activation, and retrieval.

### Modified Capabilities

None in this creation. The existing testing baseline remains unchanged. Current specification synchronization is a later verified operation.

## Scope and non-goals

This Change owns the code database, generic annotations, its two input adapters, and focused contract tests. It does not own diagnostics expectations, negative-test execution semantics, LSP/DAP integration, runtime reload scheduling, general data-row registration, filesystem live overrides, late DLL unload, or Live Coding registration.

## Impact

Implementation belongs in the Plugins/Angelscript submodule: AngelscriptTest/NewVersion/Framework and its tests, narrow build/startup wiring, plugin-owned resource tools, and a gated secondary-provider fixture in the existing AngelscriptTestJIT module. The parent owns the unified AngelscriptTestCode authoring root and this OpenSpec record. Source/AngelscriptProject remains untouched.

## Authorization and overlap

The user confirmed this Change ID, then explicitly instructed direct creation without further questioning on 2026-09-13. On the next attended goal turn the user explicitly requested completion of this exact Change, authorizing its implementation. Remaining detailed recommendations are recorded as planning assumptions in [design](design.md), not retroactive questionnaire answers.

The existing `angelscript/refactor-testing-unified-framework` is neither modified nor archived. Its source/database-related tasks overlap and MUST NOT be executed concurrently with these tasks. See [scope ownership](attachments/data/scope-ownership.md). Independent execution-layer work is not silently cancelled.
