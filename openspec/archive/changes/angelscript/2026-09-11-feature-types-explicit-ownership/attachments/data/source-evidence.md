# Planning source evidence

Captured against parent 0f0cf23ee78e563bf93dcf20b43a55381948273d and plugin 7f26e86451a5857fb7096fb4321743f51ac22dd0. The plugin already has an unrelated Bind_FName.cpp edit, preserved in this delivery. This is read-only planning evidence, not a new execution result.

## Observed boundaries

| Evidence | Observation | Consequence |
| --- | --- | --- |
| as_metadata_image.cpp:517 | CreateObjectType constructs an actual object with the Image owner, without an Engine | Keep the real graph; add publication ownership instead of proxies |
| as_metadata_image.h:267; as_scriptengine_metadata.cpp:57 | One BoundEngine plus bound ID maps; a second Engine gets ForeignEngine | Introduce external library attachment and retain exclusive private adoption |
| as_typeinfo.cpp:291; as_metadata_image.cpp:217 | Numeric IDs are resolved through the attached Image | Publish external IDs before Engine construction; query through explicit owner |
| as_context.cpp:653; as_bytecode_linker.cpp:610 | Admission recovers the owning Engine from the declaration/Image | Check the receiving Engine's exact visible definition set |
| as_vm_object.cpp:45; as_vm_object.h:13 | Allocation derives Engine from Type; object header already stores both separately | Pass explicit runtime authority and retain it in object cleanup |
| AngelscriptTypeBindInfoApply.cpp:1049 | Template operations pointer is written to Type plainUserData | Move installation state into an Engine sidecar; migrate storage predicates |
| as_scriptengine.cpp:5419 | GetTypeIdByDecl returns asNOT_SUPPORTED in the maintained path | Implement query-only current-frontend resolution, without restoring dormant code |
| as_runtime_type_binding.h:34 | Generation and typed runtime ID already exist | Reuse them instead of adding a second durable/runtime identity scheme |
| frontend/as_type_context.h | Canonical context is deliberately explicit, not a process singleton | Numeric allocation never becomes a global semantic registry |
| frontend/as_builder_stages.h | Builder accepts TypeContext and explicit definition Dependencies | Preserve engine-free compilation and adopt output in the receiving Engine |

## Existing concrete test construction

- EngineRegistrationTests retains original pointers, keeps legacy typeId/engine fields unset, rejects a second private Engine and checks enum/alias/primitive IDs. Adapt the relevant controls under the new task selector; change expectations only for an explicitly external library.
- GenericDefinitionTests.ConcreteArgumentsProduceDistinctActualObjectTypes and DetachedBuilderResolvesExplicitAndArrayShorthandToOneConcreteType provide actual specialization and source dependency construction. Their present success does not prove new private placement.
- VMObjectLifetimeTests.DestructorFiresThroughNativeBinding, NativeHandleIsNotProbedAsSdkHeader and PartialMemberFailureSkipsWholeObjectDestructor distinguish native storage and actual cleanup.
- RuntimeBindingIsolationTests.OneCapturedProviderBuildsDistinctOwnerMetadata, NativeAuxiliaryAndOwnerRestoreAfterNestedOtherEngineCall and RebindingOneOwnerKeepsActiveAuxiliaryGenerationAndOtherOwner provide independent owner/callback controls. Add shared-preparation cases rather than erasing independent-capture coverage.

## Source hashes

| Relative path | SHA-256 |
| --- | --- |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.h | abb48ad9a419f471f9fa0dd168abebe47d1fc346ed4d7136e433cba7e335dfa0 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_metadata_image.cpp | 12ab9c4674ada3fd181fadf0ace2e211903441db481e602f29c6bd30f551cd4a |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptengine_metadata.cpp | 95819711a61a8ab84e1696681d006c7baeb7ca449177bbc0479df70530ca9e92 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_typeinfo.cpp | 152b6f49540dd62f632eda01375b5af510c30d4578c32d70e9838cbeee3514c6 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_objecttype.cpp | 58c1801af30a1d78ca03356f5ac62ca5a29c609447ef07fd3b36d1fe8e45cba6 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_scriptfunction.cpp | 7b6dc0a285a064bb526eb1907b8065ff93f183be2aefef33bc88a0e64ba692ca |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_context.cpp | 6178e01e459d47e20f7c16d4ebf970a87d2d8b10fe6bd30dc99a691aa407373e |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_vm_object.h | fe72eccca40222d10b4c1d40644deba91ef3805d38cdbae4dccd955ac1bd02a1 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_vm_object.cpp | 487c766edde8d420f4161401c8b15aaca738741c62960c8b26d244c02227540c |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_bytecode_linker.cpp | 2c001da9cb9f4c60e6ce071b7438168230b6fa312cb62f39237824ebb469b299 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/as_runtime_type_binding.h | e49c1abf4b52c4e67dd1e1187f94d32b1d98559e2e8ce9dd34e322e70531fdd5 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_type_context.h | 16e4f2f4452738f50a95bb7ebe423b6396d0be4827f973f0caac5ba0ec077aaf |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_builder_stages.h | 59750ca8c85b6ce4dae0dc77287e74ec61342e3fb138ddbb9c1dbcbae358a2ad |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_binding_declaration.h | 7f0c6a2e3cb3be624c998e15bee82db1d69f136c436c56c3337c5a565965d2ca |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_definition_consumer.cpp | 95f4fec5beb3d2e93686e0dc6ad29e73a6379e806a5a5e448f87cc73482c06b3 |
| Plugins/Angelscript/Source/AngelscriptRuntime/ThirdParty/angelscript/source/frontend/as_compilation_session_types.cpp | e515c56729f9ef36d620656a5f78614e9a42a8559b24dfc005604642e4c7e11b |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/angelscript.h | b0c0fdd9a66671f3aade622146e01a6a5805f54d500771943e1cad1b63126e6b |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptTypeBindInfoApply.cpp | 4cf6c9078150c5e0c9f1b601075b0b0915eac70a0cf4de4d9ad7c971c483bcc2 |
| Plugins/Angelscript/Source/AngelscriptRuntime/Core/AngelscriptEngine.cpp | 2e9fcc2b141b9d71f253ded63a8350df9332c5eeedf97a1afe7643e147f70519 |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Registration/EngineRegistrationTests.cpp | 658f9a7501fcdac17a839d2ade28f7ac96d79c22a5d8a49184ea4d8e275d278e |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/Definitions/GenericDefinitionTests.cpp | 9a76c6a8267bbc2c21752cf6c976a0f8d3f19f4884409e52bb036d99cd3cf097 |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/NativeEngine/VM/VMObjectLifetimeTests.cpp | e20cb2acc3f4cf507548328bafa1195d9349ef456bed5e8c1b04089e1476bd52 |
| Plugins/Angelscript/Source/AngelscriptTest/NewVersion/Bindings/RuntimeBindingIsolationTests.cpp | 5dabfd9ec088afa942b9d068362fb7b306533748ddcc359e64db41b3b7cb29f0 |
| Temp/Bind/README.md | 3480eabfc5396e24ae4c7bbc637fe9cd10721e03aff7f5d9c72024b6b5f029e8 |
| Temp/Bind/37-query-surface.md | 39dd28918d1c827503a712bb0c0250e56a4b0efa28994365c65cd9f2b777b756 |

Temp/Bind is exploratory input. Its claim that preallocated dense IDs require one Engine is superseded by the accepted external allocator design. Its approximate CALLSYS lookup chain is not a measured instruction trace. No historical timings or passing counts are treated as fresh verification.

