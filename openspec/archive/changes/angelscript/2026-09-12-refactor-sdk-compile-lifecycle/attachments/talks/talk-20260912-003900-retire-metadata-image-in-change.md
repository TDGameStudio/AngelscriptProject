# Retire MetadataImage in this Change

## Context

The approved draft (`asCMetadataImage 这个不要了哈`) deleted the type. The Change then carved a BindInfo exception: Image stays BindInfo-only; `as_metadata_image.*` is not deleted while Draft/Apply still `Create()` Image.

## Evidence

User (attended, 2026-09-12): this Change must finally remove the Image products and use DefinitionSet + Registration; comment Binding tests; replan. That invalidates the BindInfo leftover boundary, INDEX Forbidden "do not delete `as_metadata_image.*`", and 5.2 as the terminal node.

Handoff flip condition already named this path: require BindInfo to stop using Image in this same Change.

## Options

1. Keep Image as BindInfo-only leftover; later Binding Change deletes the type.
2. Delete Image in this Change; BindInfo owner-swaps onto DefinitionSet; comment Binding tests that fail; Binding GREEN stays with `angelscript/refactor-bindings-two-stage-pipeline`.
3. Stub BindInfo Install so Image can be deleted without an owner swap.

## Settled Decision

Option 2. Script and BindInfo TypeInfo ownership use `asCModuleDefinitionSet` until `asCEngineCompileRegistration`. Comment Binding `TEST_CLASS` files that fail because Image is gone. Do not rewrite the Binding two-stage pipeline. Do not stub Install as the product.

## Consequences and Flip Condition

6.1 does the owner swap and comments tests. 6.2 deletes `as_metadata_image.*` and Engine Image APIs. Flip if BindInfo must keep Image as a type, or if Binding GREEN becomes a gate of this Change.

## Sources

User replan request. Draft finding `drafts/findings/metadata-image-removed.md`. Prior design BindInfo exception (superseded).
