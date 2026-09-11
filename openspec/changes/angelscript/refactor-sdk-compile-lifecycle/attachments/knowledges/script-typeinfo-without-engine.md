---
disposition: candidate
---

# Script TypeInfo is created without an Engine

## Reusable Insight

Script `asCTypeInfo` / `asCScriptFunction` are allocated at Builder time with `engine == nullptr` and TypeId -1. Engine is not required for later units to name those types. Numeric TypeId and `Type->engine` appear only at Registration Install.

## Evidence

- `asCBuilder(Snapshot, Diagnostics, Options)` does not take an Engine.
- DefinitionConsumer `CreateObjectType` on the former Image; attach wrote BoundTypeIds only in `RegisterMetadataImage`.
- `asCTypeInfo::GetEngine` / `GetTypeId` return null / -1 before attach.

## Boundaries

Does not describe BindInfo native publications or host ClassGen. Does not claim two Engines may share one TypeInfo pointer.

## Application

When adding a compile or emit test, do not construct `asCScriptEngine` unless the case is Registration or Prepare.

## Sources

- attachments/drafts/findings/compile-then-batch-register.md
- attachments/drafts/design.md
