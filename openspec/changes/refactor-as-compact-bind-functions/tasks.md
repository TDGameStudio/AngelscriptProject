## 1. Record the compact-provider contract

- [x] 1.1 Record the fixed 55-provider inventory and the fifteen retained high-complexity geometry families in `candidate-inventory.md`.
- [x] 1.2 Reconcile the active manual-binding and reviewability records so stable named owners remain required but universal `_Functions.cpp` placement is no longer required.

## 2. Colocate compact providers

- [x] 2.1 Move selected value and utility provider bodies into their owning `Bind_*.cpp` files, retain shared family headers, and delete only obsolete companion files.
- [x] 2.2 Move selected platform, system, and helper provider bodies using the same declaration-before-registrar and definition-after-registrar layout.
- [x] 2.3 Move selected actor, component, world, and other compact UObject provider bodies without changing post-reflection phase ownership or callable traits.
- [x] 2.4 Remove provider-private family headers only after confirming no sibling `_Type.cpp` or other source file consumes their owner declarations.

## 3. Remove source-layout enforcement and verify behavior

- [x] 3.1 Remove `AngelscriptBindSourceLayoutTests.cpp` without introducing a source-layout replacement.
- [ ] 3.2 Run the plugin build, the full Bindings CQTest prefix, and StaticJIT AOT coverage; record results. Blocked by the pre-existing `Bind_Primitives.h/.cpp` compilation errors recorded in `verification.md`.
- [x] 3.3 Run strict OpenSpec validation and whitespace checks, then update this task list and inventory with final evidence.
