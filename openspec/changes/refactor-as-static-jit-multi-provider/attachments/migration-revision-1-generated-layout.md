# Revision-1 generated-layout migration boundary

## Context

The approved current layout uses ownership revision 2 and emits exactly one
real source per non-empty AS module:

```text
Profiles/<Profile>/Modules/<full StableModuleKey>.jit.cpp
```

Revision 1 used per-function slices and fixed buckets. Revision-1 output is
never accepted as current and is never emitted again. Its inventory may be
read only to support a one-time removal migration.

## Problem found during implementation

The first removal-only implementation required a revision-1 ownership marker,
but it treated any prior-inventory path carrying any revision-1 marker as
deletable. That was broader than the design: a forged or accidentally retained
file such as `Custom/Retained.cpp` with `kind=bucket` could be deleted even
though its path was not part of the old generated layout.

Focused RED evidence:

- build containing the new regression test:
  `Saved/Build/staticjit-legacy-path-hardening-red-build/20260812_201438_929_65af0aa7`;
- ProjectGeneration result, 3/4 with the new assertion failing because the
  forged path was incorrectly accepted:
  `Saved/Tests/staticjit-legacy-path-hardening-red/20260812_201458_154_6fb4076d/Report`.

## Final migration rule

A revision-1 file absent from current output is deletable only when both its
normalized path shape and its exact first-line marker match one of these old
generator forms:

| Old path | Required exact kind |
| --- | --- |
| `Slices/**/*.jit.hpp` | `function-slice` |
| `Buckets/JITBucket_*.generated.inl` or `Buckets/JITBucket_*.cpp` | `bucket` |

Any other path, wrong kind, missing marker, invalid inventory, ProviderId
mismatch, profile mismatch, or path escaping the selected profile root is an
ownership conflict. Publication then stops before writing or deleting output.

For paths that still exist in the revision-2 output, migration overwrite is
allowed only when the old marker has the exact same generated-file kind as the
new expected file. Revision-1 bytes are still reported stale and are never
treated as current.

The separate fixed project scaffold removes its former
`Private/Generated/Buckets/JITBucket_*.cpp` shell files using the same
path-plus-exact-marker principle. User-owned lookalikes block Scaffold and are
left byte-for-byte unchanged.

## GREEN evidence

- Development Editor build:
  `Saved/Build/staticjit-legacy-path-hardening-green/20260812_201602_309_4fecde57`;
- ProjectGeneration migration/publication matrix, 4/4:
  `Saved/Tests/staticjit-legacy-path-hardening-green-tests/20260812_201619_462_6d416349/Report`;
- bucket-free scaffold migration/conflict matrix, 6/6:
  `Saved/Tests/staticjit-per-module-scaffold-green-tests/20260812_200934_302_2ae76879/Report`.

No normative design change was needed: this hardening makes the code conform
to the already approved removal-only migration boundary.
