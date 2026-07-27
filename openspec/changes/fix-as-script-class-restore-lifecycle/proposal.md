## Why

Raw script classes restored from bytecode can publish incorrect inherited/value
property layout or lose lifecycle behavior, and exceptional destructor paths can
skip generated member/base cleanup. The native SDK regressions require restored
classes to behave like freshly compiled classes across construction, execution,
failure, and teardown.

## What Changes

- Rebuild restored script-class layouts in base-before-derived order with
  validated inherited-property offsets and value-member alignment.
- Preserve default constructor/destructor/member-initialization behavior through
  save/load.
- Clean still-live members and base state when a script destructor exits through
  an exception.
- Contain raw script-object allocation/refcount registrations to their owning
  engine and remove them during object/engine teardown.
- Route public SDK `AddRefScriptObject` / `ReleaseScriptObject` ownership for
  standalone raw script classes through that same registry so the final
  application release runs the generated destructor and frees the allocation.
- Preserve VM ownership when a registered derived raw script object is held
  through a compatible base or implemented-interface TypeInfo, while rejecting
  unrelated TypeInfo and destructing through the registered dynamic type.
- Add focused class layout, special-member, partial-construction, destructor,
  save/load, and post-teardown regressions.

## Capabilities

### New Capabilities

- `as-script-class-restore-lifecycle`: Defines equivalence and cleanup
  requirements for freshly compiled and bytecode-restored script classes.

### Modified Capabilities

None.

## Impact

- Vendored runtime: builder/compiler special members, restore class
  type/property/layout paths, context cleanup, script object destructor flow,
  script engine allocation hooks.
- Runtime integration: raw script-object registry hooks in ClassGenerator/Core
  where required for the fork allocator, including the public engine ownership
  entry points.
- Tests: Module save/load, Constructors, Destructors, Runtime script-object
  lifecycle, and Conformance default special members.
- Related coverage record:
  `test-as-native-sdk-comprehensive-coverage/runtime-change-map.md`.
