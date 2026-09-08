# Fingerprint Contract and Admission Matrix

This is the accepted design input matrix for tasks 1.1/1.2/2.3, not a report of implemented hash APIs. Definitions remain the one metadata authority. Fingerprints and retained canonical witnesses are computed from that graph, not a second descriptor graph.

## Canonical fields

| Layer | Canonical input | Explicit exclusions / ordering |
|---|---|---|
| Stable declaration identity | Existing version/domain, stable scope, namespace, semantic owner, kind, canonical name, generic arity, origin/generator identity | Preserve existing encoding; no fields/layout/runtime IDs |
| Full TypeUse identity | Primitive or declaration target, ordered generic arguments, callable structure and legal const/reference/handle/nullable forms | Parameter direction and ownership events are separate; no parsing display strings |
| Local SchemaHash | Semantic kind/flags; nominal/generic/alias relations; base/interface identities; ordered fields with names/full type uses/access; enum names/values; method membership/full signatures and traits; behaviour/factory/list-initializer contracts; stable access-policy content | Fields and meaningful lists preserve declaration order; unordered methods/interfaces/behaviours sorted by full canonical identity; no body/source/runtime state |
| LayoutHash | Target/storage ABI versions; architecture/pointer width/byte order; primitive/float representation; storage category; payload size/alignment; base/by-value child layouts; final field offsets/storage/address modes and packing policy | Handle/reference edges encode pointer representation, not recursive pointee layout; no header address, native callable pointer or object memory image |
| Callable ABI requirement | Callable kind/owner; complete return and ordered parameter types/modes; receiver adjustment and calling convention; native argument/return lowering; behaviour/lifetime contract | Ordinary FunctionKey can stay equal after return changes; native entry addresses are runtime bindings only |
| Dependency requirement closure | Sorted complete canonical requirements for every reachable symbol/definition needed by the image, with expected compatible schema/layout/call witnesses | Deduplicate exact equal requirements; bound traversal, reject conflicts/collisions; never use arrival order |

Select semantic flags by meaning, not by hashing an entire mixed runtime flag word. Default-argument expressions and parameter names affect source call formation, not this precompiled executable call ABI; they remain metadata but are excluded from the executable schema fingerprint unless an existing semantic capability explicitly makes them part of the admitted definition contract. Function bodies and debug locations never enter type fingerprints.

## State and witness admission

| State | Stable key query | New fingerprint query | Executable linking |
|---|---|---|---|
| Building / incomplete | Available for existing shell | NotReady or InvalidDefinition, no output | Reject |
| Frozen but unauthenticated shell | Available | UnauthenticatedDefinition, no output | Reject |
| Frozen and fully authenticated | Available | Success | Caller must separately register; no implicit attachment |
| Attaching | Available | NotReady | Reject |
| Attached to this live Engine, authentic | Available | Success | Revalidate actual witness and bind atomically |
| Attached to another Engine | Available | Semantic inspection only | ForeignEngine |
| Retired but retained and authentic | Available | Read-only success | Retired; no reattachment |
| Tampered after previous success | Key alone remains insufficient | InvalidDefinition, no new output | Reject; old cached digest does not authorize |

Existing IsFrozen() is not an admission predicate: it includes Attaching and Retired. Existing low-level Freeze() remains unchanged as an owner lifecycle operation; new compatibility APIs explicitly authenticate identities and all required definition facts.

## Cycles and native layout

Local SchemaHash records A's B field by B's canonical type-use key. The dependency table separately authenticates B. A handle cycle A -> B@ -> A@ therefore terminates. Layout recursion includes base and by-value edges only; A -> B -> A by value is rejected before any partial layout/fingerprint becomes visible.

Direct native addresses are owner-relative offsets. CompositeInline uses an in-owner composite extent plus a member offset. CompositeIndirect uses a pointer slot plus an authenticated pointee layout/member offset and a checked runtime null guard. FinalizeLayouts must validate and preserve these facts instead of rewriting them with AS sequential offsets. Check overflow, extent, declared alignment/packing, ownership and direct overlap before mutation.

For native C++ fixtures, supply actual sizeof/alignof/offsetof and compare member addresses and sentinel values independently. A structurally legal but incorrect offset cannot be inferred from a member name: linking needs the host's authoritative native contract/witness. Merely comparing total size or an FName hash cannot authenticate layout.

## Mutation oracles

- Same key, different field name/type/order or method return: compare the appropriate domain; full callable signatures catch equal FunctionKey/different return.
- Same payload layout, different function body: no identity/schema/layout change.
- Equivalent definitions in different creation order: identical witnesses and digests.
- Equal injected digest, different canonical witnesses: collision rejection, no merge.
- Tampered method/behaviour/access/property relation after initial query: revalidation rejects.
- Raw pointer, runtime ID, refcount, registration ordinal, FName index or source location perturbation: no canonical digest input changes.

Source anchors: frontend/as_type_identity.h/.cpp, frontend/as_stable_key.h/.cpp, as_typeinfo.h/.cpp, as_metadata_image.h/.cpp, as_property.h and as_scriptengine_metadata.cpp under the maintained SDK. These inputs align with the existing durable stable-identity domain separation; public hash APIs are new work, not an already working cache.

