---
task_graph:
  version: 1
  depends_on:
    "1.1": []
    "1.2": ["1.1"]
    "2.1": ["1.2"]
---

Use one PowerShell 7 process for Harness commands and the selected primary workspace. The current `angelscript/language/frontend/reflection-dependencies` specification is the accepted behavior; this defect Change adds no delta.

## 1. Typed payload repair

- [x] 1.1 Add focused metadata and enum-constant regressions and observe RED — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'as-reflection-payload-red-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'reflection payload RED build failed' }; Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.ReflectionDescriptors.MetadataArgumentsProjectIntoConcreteDescriptors+Angelscript.UnitTest.NativeEngine.ReflectionDescriptors.EnumConstantsProjectNamesAndValues'; Label = 'as-reflection-payload-red'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 } }`
  > Files: `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Reflection/AngelscriptFrontendReflectionDescriptorTests.cpp`, `openspec/changes/angelscript/fix-reflection-payload-projection/tasks.md`, `openspec/changes/angelscript/fix-reflection-payload-projection/attachments/INDEX.md`

  1. Assert metadata values from annotation arguments rather than annotation presence alone.
  2. Assert explicit and implicit enum values in authored order.
  3. Retain the managed failing scenario names and confirm discovery/process/report integrity.

- [x] 1.2 Add typed annotation payload and enum-constant nodes, then pass Reflection — verify: `& { $b = Invoke-Harness -Command ue.build -Context $context -Parameters @{ Target = 'AngelscriptProjectEditor'; Platform = 'Win64'; Configuration = 'Development'; Label = 'as-reflection-payload-final-build'; BuildConcurrency = 'Auto'; ConcurrencyPolicy = 'Auto'; TimeoutMs = 3600000 }; if ($b.status -ne 'Succeeded') { throw 'reflection payload build failed' }; $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.Reflection'; Label = 'as-reflection-payload-test'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'reflection payload test failed' }; $t }`
  > Files: `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_fwd.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_decl_nodes.def`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_decl.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_decl.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_ast_visitor.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_attr.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_attr.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_parser.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_parser.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_sema.h`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_frontend_sema.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session.cpp`, `Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_descriptor_consumer.cpp`, `Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Reflection/AngelscriptFrontendReflectionDescriptorTests.cpp`

  > Constraints: Parser authors typed attributes and enum constants; descriptor projection consumes those semantic objects only. Do not add a string-keyed event DTO, source reparse, legacy route, or Runtime/UE materialization.

  1. Preserve outer reflection attributes and parse their payload into target-valid typed flag/string attributes.
  2. Create concrete enum-constant declarations with deterministic explicit/implicit values and semantic keys.
  3. Project only accepted typed facts into the existing descriptor maps and enum arrays.
  4. Build and run the complete Reflection prefix.

## 2. Adjacent verification and closure readiness

- [x] 2.1 Pass adjacent typed-AST/declaration tests and strict record/spec checks — verify: `& { $t = Invoke-Harness -Command ue.test -Context $context -Parameters @{ TestPrefix = 'Angelscript.UnitTest.NativeEngine.AST+Angelscript.UnitTest.NativeEngine.Declarations'; Label = 'as-reflection-payload-adjacent'; Fast = $true; ConcurrencyPolicy = 'Auto'; TimeoutMs = 600000 }; if ($t.status -ne 'Succeeded') { throw 'reflection payload adjacent tests failed' }; $c = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('angelscript/fix-reflection-payload-projection','--type','change','--strict','--json'); if ($c.status -ne 'Succeeded') { throw 'reflection payload Change validation failed' }; $s = Invoke-Harness -Command openspec.validate -Context $context -ArgumentList @('--specs','--strict','--json'); if ($s.status -ne 'Succeeded') { throw 'current specification validation failed' }; $s }`
  > Files: `openspec/changes/angelscript/fix-reflection-payload-projection/proposal.md`, `openspec/changes/angelscript/fix-reflection-payload-projection/tasks.md`, `openspec/changes/angelscript/fix-reflection-payload-projection/attachments/INDEX.md`

  > Verification scope: AST and Declarations are included because the repair adds one concrete declaration kind and changes parser/Sema attribute ownership. Quick, Performance, Integration, complete UE suites, Standalone, and dormant legacy tests remain unrelated.

  1. Run only the two adjacent NativeEngine owners.
  2. Confirm the existing durable spec remains strict-valid without a semantic delta.
  3. Record exact counts, exclusions, and the absence or presence of any Harness defect.
