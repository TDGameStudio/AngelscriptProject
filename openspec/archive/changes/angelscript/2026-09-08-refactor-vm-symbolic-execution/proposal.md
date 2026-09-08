## Why

The reconstructed SDK already creates actual engine-independent `asCTypeInfo`, `asCObjectType`, and `asCScriptFunction` definitions and registers a frozen image into one Engine. Its stable keys identify those definitions, but do not authenticate their schema, native layout, executable bodies, or runtime resources. The initial implementation now executes the maintained interpreter and bounded canonical source through symbolic images; two historical NativeEngine runs report 704/704. The fixed-snapshot acceptance Review identifies incomplete verifier/frame contracts, mutable non-atomic executable publication, cache authentication, runtime lifetimes and source lowering/cleanup. A successful key lookup or aggregate passing run does not establish those missing guarantees.

We need to test the real maintained VM through independent layers: manually create actual detached metadata, hand-author bytecode to isolate execution, and compile basic AS source through the current canonical frontend into the same executable format. Direct-bytecode fixtures must not need source compilation; source fixtures must prove actual execution rather than stopping at AST or frozen definitions. Both execution paths link stable references against a fresh minimal SDK Engine without starting legacy Unreal integration. The same boundary should make bytecode reusable across separately constructed Engines without persisting process-local IDs or pointers.

## What Changes

- Preserve the existing 32-byte BLAKE3 stable identity and expose separate authenticated `SchemaHash` and target-dependent `LayoutHash` values on frozen definitions. Add explicit native field addressing so real C++ offsets are not guessed by AS field packing.
- Introduce an SDK bytecode image builder, immutable symbolic image, versioned codec/dump, structural verifier, and transactional linker. Symbols carry complete canonical requirements; bytecode refers to compact artifact-local slots.
- Require all types, callable declarations, and global storage to be established in the destination Engine first. Cached signatures validate those definitions; this first cache version does not recreate them. Code bodies and string constants belong to the executable image.
- Resolve validated stable symbols to an Engine-owned executable snapshot with live type/function bindings, frame and unwind data, native entry points, and explicit lifetime leases. Adapt the actual interpreter to this boundary instead of adding a reduced interpreter or restoring old module compilation.
- Restore the complete maintained SDK VM semantics: primitives and control flow, script/native calls, AS object lifetime and dispatch, globals, exceptions, suspension, nested contexts, weak references, and cycle GC. Explicitly classify every assigned opcode, including retired instructions and VM-only JIT markers.
- Add an Engine-free canonical AST bytecode emitter as an explicit consumer after the existing Builder reaches DefinitionsFrozen. Cover bounded basic source semantics, explicit unsupported/error rejection, and source-produced cache execution through the same verifier/linker/VM.
- Add authenticated manual-definition fixtures using actual asCObjectType/asCScriptFunction factories, not mock classes or fake Engine IDs. Directly prove metadata/signature/layout/fingerprint/lifetime behavior without creating an AS Engine.
- Add replacement-only CQTest feature groups with concrete positive, negative, boundary, cross-Engine, and failure-atomicity oracles. Related cases follow grouped RED/GREEN and may share a justified proving run.

## Delivery Boundary

The current authorization preserves every completed task ID and its executed evidence. Progress Review P01-P04 add follow-up nodes 6.5 and 7.3 without unchecking 6.4 or 7.1; P05 destructor dispatch remains on 8.3. Both External Reviews stay CHANGES_REQUIRED until repairs and exact verification. A Replan changes planning artifacts first; product TDD follows on the new Ready nodes. It does not sync durable specs, archive or publish Git changes.

Remaining implementation retains `asCScriptEngine` as the minimal runtime owner. Independence means no mandatory Builder, source compilation, ambient `FAngelscriptEngine`, or UE object-registration prerequisite for runtime execution. Metadata, image production and structural verification remain Engine-free; optional source production uses the current Builder without an Engine. Actual execution still uses the minimal SDK runtime owner. This does not mean deleting every SDK Engine pointer or sharing one definition image among Engines. CQTest's UE test host remains a separate dependency; no standalone test runner is introduced.

Explicit non-goals:

- Restoring AS type/function declarations, mutable global values, heap objects, or suspended stacks from the cache; replacing already installed executable bodies; hot reload.
- UClass/UStruct/UObject, World, ClassGenerator, generated/manual UE Bindings, subsystem startup, or the existing TypeScript tooling.
- Reactivating the legacy compiler, test framework, Cache V2, module Save/LoadByteCode, JIT backend, Standalone, or dormant services.
- A complete source-language backend beyond the bounded source-execution matrix, or extraction of a new Engine-less runtime owner. Unsupported valid AST forms fail explicitly; the complete direct-bytecode VM requirement is unchanged.
- Cross-architecture bytecode compatibility, unsupported historical native platform ABIs, or an untrusted-code security sandbox.
- Depending on the active diagnostics or unified-test-framework Changes. Their shared files require coordination if implemented concurrently, but neither is a functional prerequisite.
- Product edits, durable-spec synchronization, archive, commit, push, or worktree changes during this planning-only Review/Replan delivery.

## Capabilities

### New Capabilities

- `angelscript/runtime/bytecode`: engine-independent manual and canonical-AST executable image production, canonical stable requirements, versioned persistence, validation, and atomic runtime linking to pre-registered definitions.
- `angelscript/runtime/vm`: actual SDK execution, native calling, SDK-owned object lifetime, GC, and Context lifecycle without legacy UE services.

### Modified Capabilities

- `angelscript/language/types/stable-identity`: concrete schema/layout fingerprint admission while preserving identity, type-use qualifiers, canonical witnesses, and runtime-local IDs.
- `angelscript/language/types/definitions`: exact native member addressing, complete callable contracts, and lease-safe executable use of immutable single-Engine definitions.
- `angelscript/testing/baseline`: method-owned minimal SDK runtime fixtures and real VM coverage under the existing replacement CQTest identity, with detached metadata, frontend and image-only fixtures remaining Engine-free.

## Impact

Planning changes only the parent repository beneath this Change. Later product work belongs to the `Plugins/Angelscript` submodule: maintained SDK sources including the new canonical AST emitter and narrowly necessary host-signature, reference/default and constructor semantic-fact preservation, Core object bridge routing, and `AngelscriptTest/NewVersion/NativeEngine`. The host project module, public Harness route API, compile gates, and dormant UE startup contract are unchanged.

The supported future test entry is Harness `ue.build` followed by exact `Angelscript.UnitTest.NativeEngine.<Area>` Automation selectors with `Fast = $true`. The final NativeEngine regression is justified by shared definitions, bindings, and Context changes; no full UE suite or unrelated Harness aggregate is a default gate.

The accepted decision, source evidence, dependency/ownership map, opcode dispositions, and requirement-to-task mapping are reachable through `attachments/INDEX.md` and `tasks.md`.
