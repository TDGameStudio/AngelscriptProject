# Candidate: Identity, Compatibility and Runtime Lifetime

## Reusable Insight

A stable key answers which declaration/type use is intended. Schema and layout fingerprints answer whether its current definition can satisfy a cached requirement. A live executable lease answers whether resolved pointers/callables may still be used. None replaces the other two.

## Evidence

- as_typeinfo constructor stores the key before Engine registration; as_metadata_image creates actual ObjectType objects with that key.
- as_scriptengine_metadata binds the existing pointers and local IDs to one Engine, and rejects sharing an attached image.
- as_metadata_image::Freeze can accept low-level shells without full canonical identity authentication; IsFrozen includes Attaching and Retired.
- Ordinary FunctionKey omits return type; complete callable compatibility must not compare keys alone.
- Metadata lifetime after Engine retirement preserves definitions but clears Engine bindings. Existing raw Type.engine/id fields do not become authoritative after metadata registration.

All files are beneath Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/. Exact inspected-source provenance is in the indexed runtime-dependency inventory.

## Boundaries

This is a source-backed knowledge candidate, not a claim that public SchemaHash, the symbolic codec or the new runtime are implemented. It is not promoted into current capability knowledge by Change creation. New executable correctness still requires the planned real CQTests.

## Application

Use canonical role-aware lookup, not hash reversal or display-name parsing. Validate witnesses and explicit image/Engine state before publishing a binding. Reuse code across Engines only with separately owned equivalent definitions. Retain code/native/runtime ownership through cleanup; retain metadata separately for inspection. Prefer plain data and existing metadata owners over a second synchronized type graph.

## Sources

Current as_typeinfo.h/.cpp, as_metadata_image.h/.cpp, as_scriptengine_metadata.cpp and frontend/as_type_identity.cpp; durable openspec/specs/angelscript/language/types/stable-identity/spec.md and definitions/spec.md. Promotion is deferred until implementation/regression evidence establishes the reusable conclusions on the completed product boundary.


## Final disposition

Retired as a separate knowledge candidate after verified implementation. The durable distinction between identity, authenticated compatibility and actual runtime ownership is now carried directly by the synchronized stable-identity, definitions, bytecode and VM specifications. A second guidance document would duplicate those requirements. The original preimplementation evidence and limitations above remain historical; final source/DLL/case verification is in ../data/final-runtime-drain-acceptance.md. No project-wide instruction change or implicit capability-knowledge promotion is made.
