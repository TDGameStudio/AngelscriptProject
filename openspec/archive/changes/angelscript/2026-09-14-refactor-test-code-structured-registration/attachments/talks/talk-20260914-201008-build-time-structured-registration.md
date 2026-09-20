# Build-time structured registration

## Context

The first checked-in carrier intentionally treated authored `.as` as opaque bytes and reused the C++ parser during module activation. The resulting generated code is a large hexadecimal array, hides real file/version metadata and creates two FileMeta facts. The user selected Python fixture parsing and direct structured C++ registration while explicitly retaining the C++ parser as an independent capability.

## Evidence

- The current Counter projection contains 420 expanded bytes and calls `FAngelscriptTestSourceParser::Parse` from its activation factory.
- Registration owns a placeholder Summary while the parser reconstructs final metadata from the container.
- The Python tool already owns discovery, deterministic rendering and checked-in synchronization, so fixture parsing is naturally pre-mutation work.
- Builder already owns version topology and all-or-nothing Case construction.

## Options

1. Keep opaque bytes and activation-time parsing. This maximizes reuse but retains unreadable output, startup work and duplicate metadata truth.
2. Render the complete container as a raw string but still parse at activation. This improves source readability only; metadata and marker interpretation remain delayed.
3. Parse fixture metadata and annotations in Python, then render structured Builder inputs. This duplicates the protocol parser but makes generated output directly reviewable and removes runtime parsing.
4. Delete the C++ parser after adopting Python. This removes drift but also removes dynamic/handwritten parsing and an independent conformance oracle.

## Settled Decision

Use option 3 for checked-in generated files and retain option 4's rejected component: the C++ parser stays available but generated translation units neither include nor invoke it. One durable authoring specification and shared fixtures govern both implementations.

## Consequences

- Generated format advances from opaque v1 bytes to structured v2 C++.
- Python validates fixture protocol before output mutation but never validates AngelScript language correctness.
- Generated lambdas use real metadata, clean `AS_TEST_SOURCE` bodies and typed annotation/origin descriptors.
- Builder remains a runtime admission defense without becoming a parser.
- Parser drift becomes an explicit conformance-test responsibility.

## Flip Condition

Revisit the decision only if a demonstrated runtime consumer needs the complete original container, or Python cannot reproduce the v1 fixture semantics and macro-byte/origin mappings deterministically. Such evidence requires an OpenSpec replan; it does not justify silently restoring activation-time parsing.

## Visual

```text
old: .as → Python bytes → uint8[] → activation C++ Parse → Cases
new: .as → Python Parse → structured C++ → activation Builder → Cases
                                └──────── retained C++ Parse for independent inputs/tests
```

## Sources

- [Build-time parser evidence](../drafts/findings/generated-build-time-parser.md)
- [Counter before and after](../drafts/findings/generated-before-after-counter-example.md)
- [Accepted design](../drafts/design.md)
- Approval provenance: brainstorming topic `angelscript/test-framework-completion`, generated-structured-registration rounds on 2026-09-14.
