# Planning validation

Self-review 2026-09-19 for `angelscript/feature-delegates-uproperty-execute`.

## Coverage

Every requirement and acceptance condition in `tasks.md` `## Requirement coverage` maps to a task:

| Requirement / scenario | Task |
|---|---|
| Isolated host seeds adapters; multicast is `FMulticastInlineDelegateProperty` | 1.1 |
| Isolated host single-cast is `FDelegateProperty` | 1.1 |
| Script AddDynamic + Broadcast writes Current | 1.1 |
| Script BindDynamic + Execute void side-effect | 1.1 |
| Native ProcessDelegate on a local multicast | 1.1 |
| Clear / Remove / RemoveAll stop later Broadcast | 1.1 |
| IsBound false / true / false | 1.1 |
| AddDynamic(this) fires | 1.1 |
| Unbound ExecuteIfBound is quiet | 1.1 |
| Missing bind name fails compile | 1.1 |
| BindUFunction Execute writes returned int | 2.1 |
| One-param FName multicast writes owner FName | 2.1 |
| Zero-param void UFUNCTION side-effect | 2.1 |
| ProcessCallPtr fires without property-byte ProcessDelegate | 3.1 |
| SoftReload copies CallPtr slot and keeps neighbor int | 3.1 |
| No ProcessDelegate on property bytes | 1.1, 2.1, 3.1 |

Delta specs under `specs/angelscript/bindings/delegates` and `specs/angelscript/runtime/delegates` use the same mapping.

## Placeholder scan

`tasks.md` has no TBD, TODO, implement later, fill in details, empty Interfaces fences, or unspecified cook/Language gates. Each leaf card names one `ue.test` prefix and, for 1.1, the adjacent `DelegateBinding` / `DelegateExecute` observe-after-GREEN commands.

## Symbols

Glossary / design names `DelegateProperty`, `PropertyIsBoundReports`, `AddDynamicThisFires`, `ExecuteIfBoundUnboundQuiet`, `RemoveAllStopsBroadcast`, `BindMissingUFunctionRejected`, `RetValWriteback`, `FNameParamFires`, `ZeroParamFires`, `ConvertCallPtrFires`, `SoftReloadCopiesCallPtrSlot`, `ProcessCallPtr`, `SeedHostScriptDelegateTypes` match the producing cards. Inspected source names (`asCSema::ActOnMemberCall`, `asCParser::ParseCallArguments`, `asCallBoundUFunction`, `FRawUnrealPropertyType::CopyValue`, `FAngelscriptDelegateOperations`) match current `file:line` citations. `FAngelscriptDelegateOperations::ProcessCallPtr` is convention-derived; 3.1 records `Naming assumed` after the run.
