# Accepted vocabulary

English export of host-collect-inject/glossary.md; accepted Q33/Q36/Q41/Q47-Q50/Q57/Q60-Q63 and Q66 on 2026-09-16.

| Name | Meaning / provenance |
|---|---|
| asETypeInfoKind | Shared origin enum on types and functions; replaces Metadata-origin vocabulary |
| HostProcess | Process-owned immutable host graph, permanently null Engine |
| ScriptEngine | Script definitions transferred to one Engine |
| LiveRegister | Definitions created by explicit live SDK registration; Q65 includes reconstruction |
| typeInfoKind | Origin field, Q36 |
| FAngelscriptBindCollection | Existing collection owns frozen HostDefs; no new library class, Q60 |
| asCDefinitions | Common host/script definition container; no split base class, Q49 |
| InjectDefinitions(const asCDefinitions&) | SDK host injection API, Q61; FAngelscriptEngine forwards it |
| RegisterExternalDefinitions | Script unique-transfer API, Q48 |
| RetireExternalDefinitions | Paired script retirement API, Q48 |
| DependencyDefinitions / AddDependencyDefinitions | Session dependency closure names, Q47 |
| CollectDependencyDefinitions / References | Dependency extraction and closure-membership names, Q50 |
| asSDefinitionOptions | Former asSMetadataOptions, Q63 |
| as.Bind.WriteWorkers | Creation/member wave worker count; default 1, 0 means 1, Q57/Q58 |
| Attaching / Attached | Retained script ownership states, Q62 |
| asEDefinitionResult | Former asEMetadataResult, Q66 |
| asERegistrationResult | Former asEMetadataRegistrationResult, Q66 |
| FindType / FindFunction | Former FindMetadataType / FindMetadataFunction, Q66 |
| GetDeclarationKind | Former GetMetadataDeclarationKind; distinct from origin kind, Q66 |
| definitions / GetDefinitions | Former metadataOwner / GetDefinitionSet, Q66 |
| stableKey | Former metadataStableKey, Q66 |
| typesByName / typesById / typesByKey | Type directories without Metadata prefix, Q66 |
| functionsById / functionsByKey | Function directories, Q66 |
| globalsByName / globalsByKey | Global directories, Q66 |
| as_scriptengine_registration.cpp | Former as_scriptengine_metadata.cpp, Q66 |
| as_definitions.h / as_definitions.cpp | Former as_module_definition_set files, Q66 |
| asEDefinitionState | Former asEDefinitionSetState, Q66 |
| RegistrationName / RegistrationThreadPolicy / Record.Registrations | Registration vocabulary replaces Provider, Q17 |
| angelscript/refactor-bindings-process-host-typeinfo | Change identity, Q41/Q67 |

OwnerModule remains implicit UE_MODULE_NAME; ExplicitBindings remains the default author phase. Preserve the existing phase enum for ordered construction. List-pattern/fingerprint families, Legacy, UE UMETA and unrelated comments are excluded from mechanical renaming. Remaining internal names follow these families.

New test file/class names in tasks follow the inspected CQTest and repository layer conventions, not new product vocabulary. Future source-writing tasks record additional convention-derived implementation names in their Evidence.
