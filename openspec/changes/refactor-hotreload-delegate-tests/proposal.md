# Refactor HotReload Delegate Tests

## Summary

`AngelscriptHotReloadDelegateTests.cpp` currently mixes reload hook scenarios, assertion macros, helper state, and test class forwarding in one file. Refactor the test structure without changing runtime behavior or adding coverage.

## Goals

- Keep existing automation prefixes and test method names stable.
- Keep constants, script fixtures, observation structs, and assertions inside their owning `TEST_CLASS_WITH_FLAGS` bodies.
- Remove file-level assertion macros from the delegate reload test.
- Document the existing reload delegate hook tests in the HotReload catalog.

## Non-Goals

- No runtime hot reload behavior changes.
- No new delegate reload coverage.
- No renaming of discovered automation test entries.
