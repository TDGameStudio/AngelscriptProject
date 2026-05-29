# Tasks - improve-as-bind-verse-style-thunks

> `tasks.md` is the implementation plan. Update checkboxes only after the matching verification passes.

## 1. Frame ABI tests and runtime bridge

- [x] 1.1 <!-- TDD --> Add static/runtime tests that require a `FAngelscriptCrossModuleCallFrame` ABI, frame-based thunk signature, and generated frame-wrapper shard text.
- [x] 1.2 <!-- TDD --> Change `AngelscriptCrossModuleBindings.h` and `Bind_CrossModuleDirect.cpp` to build a call frame in the generic hook and invoke `Entry.Thunk(Self, &Frame)`.
- [x] 1.3 <!-- TDD --> Update direct-bind runtime tests from raw `void** Args` expectations to frame slot/return expectations.

## 2. UHT generator frame-wrapper output

- [x] 2.1 <!-- TDD --> Update cross-module generated shard ABI mirror to include `FCrossModuleCallFrame` and frame-based thunk pointers.
- [x] 2.2 <!-- TDD --> Generate wrapper thunks that read arguments from `Frame->ArgSlots`, write return values to `Frame->ReturnSlot`, and keep current safe direct-bind behavior.
- [x] 2.3 <!-- TDD --> Add `ThunkStyle=FrameWrapper` diagnostics to generated entries/summary without changing Direct/CrossModule/Stub classification.

## 3. Verse-aligned diagnostics and deferrals

- [x] 3.1 <!-- TDD --> Split `cross-module-unsupported-signature` into protocol-oriented reasons for WorldContext, out/ref, ref return, static arrays, containers, interfaces, delegates, and script receiver projection.
- [x] 3.2 <!-- TDD --> Keep RPC/Net classified as `rpc-net-function` and verify it does not emit frame-wrapper thunks.

## 4. Verification

- [x] 4.1 <!-- Non-TDD --> Run `openspec validate "improve-as-bind-verse-style-thunks" --strict --json`.
- [x] 4.2 <!-- Non-TDD --> Run `Tools\RunTests.ps1 -TestPrefix "Angelscript.CppTests.UHTToolResolver" -Label verse-style-thunks -TimeoutMs 900000`.
- [x] 4.3 <!-- Non-TDD --> Run `Tools\RunBuild.ps1 -Label verse-style-thunks-build -TimeoutMs 900000 -SerializeByEngine -NoXGE`.
