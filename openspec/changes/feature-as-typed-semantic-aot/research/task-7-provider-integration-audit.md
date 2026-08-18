# Task 7 provider integration audit

## Provider boundary consumed

The provider task group from `refactor-as-static-jit-multi-provider` is
available in plugin commit
`3d6f231ab0d902e14a4fe944cf2ea9c1191711e7`. Typed semantic AOT therefore
consumes the landed contract instead of creating another provider, registry,
refresh, Live Coding, or route-publication layer.

The current contract is `FAngelscriptJITProviderAbi::Revision == 7` and uses:

- `FAngelscriptJITProviderId` and `FAngelscriptJITProviderGeneration` for
  Provider ownership and immutable generation identity;
- `FAngelscriptStableModuleKey` and `FAngelscriptStableFunctionKey` for script
  identity;
- execution hash, debug hash, artifact profile, Entry ABI hash, and native
  environment fingerprint for exact compatibility;
- the backend-neutral `FAngelscriptJITEntryPoints` tuple containing VM, Raw,
  and Parms pointers.

Backend choice is retained only in optional catalog diagnostics as
`ActualBackendId`; it does not create a TypedAST-specific entry type or a
second FunctionKey namespace.

## Mixed-module publication proof

The generated EditorDevelopment `AngelscriptTestJIT` Provider contains 80
function entries across seven AS ModuleKeys. Its diagnostics contain both
`typed-ast` and `bytecode` actual backend results inside individual modules.
The focused catalog test does not depend on generated symbol spelling or a
hard-coded fixture FunctionKey. It joins diagnostics to entries by stable
FunctionKey, requires exactly one entry per diagnostic, and searches for one
ModuleKey that contains both backends.

For the selected same-module pair it requires:

- the TypedASTJIT function has non-null VM, Raw, and Parms entry pointers;
- the BytecodeJIT function has a non-null VM entry;
- both entries retain the Provider artifact profile and native-environment
  fingerprint while having distinct FunctionKeys.

Runtime dispatch remains a separate test responsibility. The existing
`UASFunctionDispatch` family executes generated VM/Raw/Parms paths and proves
that the generated-WorldContext fixture can fall back per function to
BytecodeJIT while deliberately avoiding an unsafe Parms entry. Thus a mixed
module does not become all-Typed or all-Bytecode merely because one function
is unsupported.

## Test ownership and evidence

- `StaticJIT/AOT/Generation/AngelscriptStaticJITAotMixedBackendPublicationTests.cpp`
  owns the installed Provider ABI and same-module publication shape. It reads
  an existing registry snapshot and creates no Engine.
- `StaticJIT/AOT/UASFunctionDispatch/AngelscriptStaticJITAotUASFunctionDispatchTests.cpp`
  owns actual dispatch and shares one fixture through its narrow bridge.

Verification:

- `Saved/Build/typed-aot-mixed-provider-publication/
  20260816_181918_358_f8f3a8cc/` — focused incremental Editor build PASS;
  the new translation unit was compiled through adaptive non-unity;
- `Saved/Tests/typed-aot-mixed-provider-publication/
  20260816_181942_055_1b02f904/` — new mixed-publication prefix `1/1 PASS`;
- `Saved/Tests/typed-aot-mixed-provider-vm-fallback/
  20260816_182017_685_ad09d0ae/` — existing UASFunctionDispatch prefix
  `7/7 PASS`, including Typed VM/Raw/Parms and Bytecode per-function fallback.

Tasks 7.3, 7.5, and the 7.6 contingency are complete. No temporary provider
API was introduced.
