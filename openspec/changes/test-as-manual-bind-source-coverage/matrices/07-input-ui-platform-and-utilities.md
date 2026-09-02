# Input, UI, platform, and utilities

Legacy/Enhanced Input, widget, command line, paths/files, platform/process/application APIs, dialogs, timers, and utility parsing.

## Accounting

- Logical units: 20
- Planned AS-facing surface rows: 326
- Planned `.as` files: 66
- Target root: `TestSource/Bindings/`

## Unit closure

| BindId | Logical unit | Physical shards | Surfaces | Planned files | ReferenceIds | Future runners | Disposition |
|---|---|---:|---:|---:|---|---|---|
| `MB-021` | `FApp` | 1 | 2 | 1 | `REF-0122` `REF-0123` `REF-0124` `REF-0125` `REF-0126` `REF-0127` `REF-0128` `REF-0129` `REF-0130` | `Engine` | `PlannedSource` |
| `MB-031` | `FCommandLine` | 1 | 2 | 2 | `REF-0181` `REF-0182` `REF-0183` `REF-0184` `REF-0185` `REF-0186` `REF-0187` `REF-0188` `REF-0189` | `Engine` | `PlannedSource` |
| `MB-034` | `FFileHelper` | 1 | 6 | 2 | `REF-0201` `REF-0202` `REF-0203` `REF-0204` `REF-0205` `REF-0206` `REF-0207` `REF-0208` `REF-0209` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-037` | `FGenericPlatformMisc` | 1 | 1 | 1 | `REF-0218` `REF-0219` `REF-0220` | `Engine` | `PlannedSource` |
| `MB-041` | `FInputActionKeyMapping` | 1 | 1 | 1 | `REF-0246` `REF-0247` `REF-0248` `REF-0249` `REF-0250` `REF-0251` `REF-0252` | `Engine` | `PlannedSource` |
| `MB-042` | `FInputActionValue` | 1 | 14 | 4 | `REF-0253` `REF-0254` `REF-0255` `REF-0256` `REF-0257` `REF-0258` `REF-0259` `REF-0260` `REF-0261` | `Engine` | `PlannedSource` |
| `MB-043` | `FInputBindingHandle` | 1 | 18 | 4 | `REF-0262` `REF-0263` `REF-0264` | `Engine` `Editor` | `PlannedSource` |
| `MB-055` | `FMessageDialog` | 1 | 2 | 1 | `REF-0333` | `Editor` | `PlannedSource` |
| `MB-059` | `FParse` | 1 | 4 | 1 | `REF-0350` `REF-0351` `REF-0352` `REF-0353` `REF-0354` `REF-0355` `REF-0356` `REF-0357` `REF-0358` | `Engine` | `PlannedSource` |
| `MB-060` | `FPaths` | 1 | 41 | 7 | `REF-0359` `REF-0360` `REF-0361` `REF-0362` `REF-0363` `REF-0364` `REF-0365` | `World` `Engine` `Editor` | `PlannedSource` |
| `MB-063` | `FPlatformApplicationMisc` | 1 | 2 | 1 | `REF-0378` | `Engine` | `PlannedSource` |
| `MB-064` | `FPlatformMisc` | 1 | 3 | 2 | `REF-0379` `REF-0380` `REF-0381` `REF-0382` `REF-0383` `REF-0384` | `Engine` | `PlannedSource` |
| `MB-065` | `FPlatformProcess` | 1 | 13 | 3 | `REF-0385` `REF-0386` `REF-0387` `REF-0388` `REF-0389` `REF-0390` `REF-0391` `REF-0392` `REF-0393` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-088` | `InputComponentScriptMixins` | 1 | 4 | 1 | `REF-0533` | `World` | `PlannedSource` |
| `MB-089` | `InputEvents` | 2 | 127 | 17 | `REF-0534` `REF-0535` `REF-0536` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-099` | `SystemTimers` | 1 | 5 | 3 | `REF-0593` `REF-0594` `REF-0595` | `World` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-109` | `UEnhancedInputComponent` | 1 | 20 | 4 | `REF-0658` `REF-0659` `REF-0660` `REF-0661` `REF-0662` `REF-0663` | `World` `Editor` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-113` | `UInputMappingContext` | 2 | 23 | 4 | `REF-0680` `REF-0681` `REF-0682` | `Engine` `ExpectedDiagnostic` | `PlannedSource` |
| `MB-114` | `UInputSettings` | 1 | 8 | 2 | `REF-0683` `REF-0684` `REF-0685` `REF-0686` `REF-0687` | `Engine` | `PlannedSource` |
| `MB-125` | `UUserWidget` | 2 | 30 | 5 | `REF-0751` `REF-0752` `REF-0753` `REF-0754` `REF-0755` `REF-0756` `REF-0757` `REF-0758` | `Engine` `Editor` | `PlannedSource` |

## Planned source files

Each row is one future .as file and one checkbox in `tasks.md`. Exact signatures, inputs, observations, exclusions, comments, references, and dependencies are authoritative in `planned-test-sources.csv`.

| TaskId | Target | SurfaceIds | Shape | Runner |
|---|---|---|---|---|
| `TS-BIND-FAPP-001` | `TestSource/Bindings/FApp/Test_Queries_01.as` | `MB-021-S001` `MB-021-S002` | `Positive` | `Engine` |
| `TS-BIND-FCOMMANDLINE-001` | `TestSource/Bindings/FCommandLine/Test_Queries_01.as` | `MB-031-S001` | `Positive` | `Engine` |
| `TS-BIND-FCOMMANDLINE-002` | `TestSource/Bindings/FCommandLine/Test_ConversionAndFormatting_01.as` | `MB-031-S002` | `Positive` | `Engine` |
| `TS-BIND-FFILEHELPER-001` | `TestSource/Bindings/FFileHelper/Test_ConstructionAndAssignment_01.as` | `MB-034-S001` `MB-034-S002` `MB-034-S003` `MB-034-S004` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FFILEHELPER-002` | `TestSource/Bindings/FFileHelper/Test_MutationAndLifecycle_01.as` | `MB-034-S005` `MB-034-S006` | `Positive` | `Engine` |
| `TS-BIND-FGENERICPLATFORMMISC-001` | `TestSource/Bindings/FGenericPlatformMisc/Test_NamespaceAndGlobalFunctions_01.as` | `MB-037-S001` | `Positive` | `Engine` |
| `TS-BIND-FINPUTACTIONKEYMAPPING-001` | `TestSource/Bindings/FInputActionKeyMapping/Test_Operators_01.as` | `MB-041-S001` | `Positive` | `Engine` |
| `TS-BIND-FINPUTACTIONVALUE-001` | `TestSource/Bindings/FInputActionValue/Test_ConstructionAndAssignment_01.as` | `MB-042-S005` `MB-042-S006` | `Positive` | `Engine` |
| `TS-BIND-FINPUTACTIONVALUE-002` | `TestSource/Bindings/FInputActionValue/Test_Queries_01.as` | `MB-042-S007` `MB-042-S010` `MB-042-S011` `MB-042-S012` `MB-042-S013` `MB-042-S014` | `Positive` | `Engine` |
| `TS-BIND-FINPUTACTIONVALUE-003` | `TestSource/Bindings/FInputActionValue/Test_ConversionAndFormatting_01.as` | `MB-042-S008` `MB-042-S009` | `Positive` | `Engine` |
| `TS-BIND-FINPUTACTIONVALUE-004` | `TestSource/Bindings/FInputActionValue/Test_Behavior_01.as` | `MB-042-S001` `MB-042-S002` `MB-042-S003` `MB-042-S004` | `Positive` | `Engine` |
| `TS-BIND-FINPUTBINDINGHANDLE-001` | `TestSource/Bindings/FInputBindingHandle/Test_Operators_01.as` | `MB-043-S001` `MB-043-S003` `MB-043-S011` `MB-043-S016` | `Positive` | `Engine` |
| `TS-BIND-FINPUTBINDINGHANDLE-002` | `TestSource/Bindings/FInputBindingHandle/Test_Queries_01.as` | `MB-043-S002` `MB-043-S004` `MB-043-S005` `MB-043-S006` `MB-043-S009` `MB-043-S013` `MB-043-S014` `MB-043-S015` `MB-043-S017` | `Positive` | `Engine` |
| `TS-BIND-FINPUTBINDINGHANDLE-003` | `TestSource/Bindings/FInputBindingHandle/Test_MutationAndLifecycle_01.as` | `MB-043-S007` `MB-043-S008` `MB-043-S018` | `Positive` | `Editor` |
| `TS-BIND-FINPUTBINDINGHANDLE-004` | `TestSource/Bindings/FInputBindingHandle/Test_Behavior_01.as` | `MB-043-S010` `MB-043-S012` | `Positive` | `Engine` |
| `TS-BIND-FMESSAGEDIALOG-001` | `TestSource/Bindings/FMessageDialog/Test_Operators_01.as` | `MB-055-S001` `MB-055-S002` | `Positive` | `Editor` |
| `TS-BIND-FPARSE-001` | `TestSource/Bindings/FParse/Test_NamespaceAndGlobalFunctions_01.as` | `MB-059-S001` `MB-059-S002` `MB-059-S003` `MB-059-S004` | `Positive` | `Engine` |
| `TS-BIND-FPATHS-001` | `TestSource/Bindings/FPaths/Test_Queries_01.as` | `MB-060-S018` `MB-060-S019` `MB-060-S020` `MB-060-S021` `MB-060-S022` `MB-060-S023` `MB-060-S029` `MB-060-S030` `MB-060-S031` `MB-060-S032` | `Positive` | `World` |
| `TS-BIND-FPATHS-002` | `TestSource/Bindings/FPaths/Test_Queries_02.as` | `MB-060-S033` | `Positive` | `Engine` |
| `TS-BIND-FPATHS-003` | `TestSource/Bindings/FPaths/Test_MutationAndLifecycle_01.as` | `MB-060-S025` `MB-060-S037` | `Positive` | `Engine` |
| `TS-BIND-FPATHS-004` | `TestSource/Bindings/FPaths/Test_ConversionAndFormatting_01.as` | `MB-060-S040` `MB-060-S041` | `Positive` | `Engine` |
| `TS-BIND-FPATHS-005` | `TestSource/Bindings/FPaths/Test_NamespaceAndGlobalFunctions_01.as` | `MB-060-S001` `MB-060-S002` `MB-060-S003` `MB-060-S004` `MB-060-S005` `MB-060-S006` `MB-060-S007` `MB-060-S008` `MB-060-S009` `MB-060-S010` | `Positive` | `Editor` |
| `TS-BIND-FPATHS-006` | `TestSource/Bindings/FPaths/Test_NamespaceAndGlobalFunctions_02.as` | `MB-060-S011` `MB-060-S012` `MB-060-S013` `MB-060-S014` `MB-060-S015` `MB-060-S016` `MB-060-S017` `MB-060-S024` `MB-060-S026` `MB-060-S027` | `Positive` | `Engine` |
| `TS-BIND-FPATHS-007` | `TestSource/Bindings/FPaths/Test_NamespaceAndGlobalFunctions_03.as` | `MB-060-S028` `MB-060-S034` `MB-060-S035` `MB-060-S036` `MB-060-S038` `MB-060-S039` | `Positive` | `Engine` |
| `TS-BIND-FPLATFORMAPPLICATIONMISC-001` | `TestSource/Bindings/FPlatformApplicationMisc/Test_NamespaceAndGlobalFunctions_01.as` | `MB-063-S001` `MB-063-S002` | `Positive` | `Engine` |
| `TS-BIND-FPLATFORMMISC-001` | `TestSource/Bindings/FPlatformMisc/Test_Queries_01.as` | `MB-064-S003` | `Positive` | `Engine` |
| `TS-BIND-FPLATFORMMISC-002` | `TestSource/Bindings/FPlatformMisc/Test_NamespaceAndGlobalFunctions_01.as` | `MB-064-S001` `MB-064-S002` | `Positive` | `Engine` |
| `TS-BIND-FPLATFORMPROCESS-001` | `TestSource/Bindings/FPlatformProcess/Test_Queries_01.as` | `MB-065-S010` | `Positive` | `Engine` |
| `TS-BIND-FPLATFORMPROCESS-002` | `TestSource/Bindings/FPlatformProcess/Test_NamespaceAndGlobalFunctions_01.as` | `MB-065-S001` `MB-065-S002` `MB-065-S003` `MB-065-S004` `MB-065-S005` `MB-065-S006` `MB-065-S007` `MB-065-S008` `MB-065-S009` `MB-065-S011` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-FPLATFORMPROCESS-003` | `TestSource/Bindings/FPlatformProcess/Test_NamespaceAndGlobalFunctions_02.as` | `MB-065-S012` `MB-065-S013` | `Positive` | `Engine` |
| `TS-BIND-INPUTCOMPONENTSCRIPTMIXINS-001` | `TestSource/Bindings/InputComponentScriptMixins/Test_MutationAndLifecycle_01.as` | `MB-088-S001` `MB-088-S002` `MB-088-S003` `MB-088-S004` | `Positive` | `World` |
| `TS-BIND-INPUTEVENTS-001` | `TestSource/Bindings/InputEvents/Test_ConstructionAndAssignment_01.as` | `MB-089-S002` `MB-089-S126` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-002` | `TestSource/Bindings/InputEvents/Test_Operators_01.as` | `MB-089-S013` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-003` | `TestSource/Bindings/InputEvents/Test_IndexAndIteration_01.as` | `MB-089-S030` `MB-089-S050` `MB-089-S060` `MB-089-S061` `MB-089-S092` `MB-089-S098` `MB-089-S119` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-INPUTEVENTS-004` | `TestSource/Bindings/InputEvents/Test_Queries_01.as` | `MB-089-S003` `MB-089-S004` `MB-089-S005` `MB-089-S006` `MB-089-S007` `MB-089-S008` `MB-089-S009` `MB-089-S010` `MB-089-S011` `MB-089-S012` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-005` | `TestSource/Bindings/InputEvents/Test_Queries_02.as` | `MB-089-S016` `MB-089-S017` `MB-089-S018` `MB-089-S019` `MB-089-S020` `MB-089-S021` `MB-089-S022` `MB-089-S023` `MB-089-S024` `MB-089-S025` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-006` | `TestSource/Bindings/InputEvents/Test_Queries_03.as` | `MB-089-S026` `MB-089-S027` `MB-089-S028` `MB-089-S031` `MB-089-S032` `MB-089-S033` `MB-089-S034` `MB-089-S035` `MB-089-S036` `MB-089-S037` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-007` | `TestSource/Bindings/InputEvents/Test_Queries_04.as` | `MB-089-S038` `MB-089-S039` `MB-089-S040` `MB-089-S041` `MB-089-S042` `MB-089-S043` `MB-089-S044` `MB-089-S045` `MB-089-S046` `MB-089-S047` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-008` | `TestSource/Bindings/InputEvents/Test_Queries_05.as` | `MB-089-S048` `MB-089-S051` `MB-089-S052` `MB-089-S053` `MB-089-S054` `MB-089-S055` `MB-089-S056` `MB-089-S057` `MB-089-S058` `MB-089-S059` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-009` | `TestSource/Bindings/InputEvents/Test_Queries_06.as` | `MB-089-S062` `MB-089-S063` `MB-089-S064` `MB-089-S065` `MB-089-S066` `MB-089-S078` `MB-089-S079` `MB-089-S080` `MB-089-S081` `MB-089-S082` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-010` | `TestSource/Bindings/InputEvents/Test_Queries_07.as` | `MB-089-S083` `MB-089-S084` `MB-089-S085` `MB-089-S086` `MB-089-S087` `MB-089-S088` `MB-089-S089` `MB-089-S090` `MB-089-S093` `MB-089-S094` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-011` | `TestSource/Bindings/InputEvents/Test_Queries_08.as` | `MB-089-S095` `MB-089-S096` `MB-089-S097` `MB-089-S099` `MB-089-S100` `MB-089-S101` `MB-089-S102` `MB-089-S103` `MB-089-S104` `MB-089-S105` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-012` | `TestSource/Bindings/InputEvents/Test_Queries_09.as` | `MB-089-S106` `MB-089-S107` `MB-089-S108` `MB-089-S109` `MB-089-S110` `MB-089-S111` `MB-089-S112` `MB-089-S113` `MB-089-S114` `MB-089-S115` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-013` | `TestSource/Bindings/InputEvents/Test_Queries_10.as` | `MB-089-S116` `MB-089-S117` `MB-089-S120` `MB-089-S121` `MB-089-S122` `MB-089-S123` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-014` | `TestSource/Bindings/InputEvents/Test_MutationAndLifecycle_01.as` | `MB-089-S068` `MB-089-S069` `MB-089-S075` `MB-089-S076` `MB-089-S077` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-015` | `TestSource/Bindings/InputEvents/Test_NamespaceAndGlobalFunctions_01.as` | `MB-089-S124` `MB-089-S125` `MB-089-S127` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-016` | `TestSource/Bindings/InputEvents/Test_Behavior_01.as` | `MB-089-S001` `MB-089-S014` `MB-089-S015` `MB-089-S029` `MB-089-S049` `MB-089-S067` `MB-089-S070` `MB-089-S071` `MB-089-S072` `MB-089-S073` | `Positive` | `Engine` |
| `TS-BIND-INPUTEVENTS-017` | `TestSource/Bindings/InputEvents/Test_Behavior_02.as` | `MB-089-S074` `MB-089-S091` `MB-089-S118` | `Positive` | `Engine` |
| `TS-BIND-SYSTEMTIMERS-001` | `TestSource/Bindings/SystemTimers/Test_Queries_01.as` | `MB-099-S002` | `Positive` | `World` |
| `TS-BIND-SYSTEMTIMERS-002` | `TestSource/Bindings/SystemTimers/Test_MutationAndLifecycle_01.as` | `MB-099-S001` `MB-099-S005` | `Positive;NegativeDiagnostic` | `World;ExpectedDiagnostic` |
| `TS-BIND-SYSTEMTIMERS-003` | `TestSource/Bindings/SystemTimers/Test_NamespaceAndGlobalFunctions_01.as` | `MB-099-S003` `MB-099-S004` | `Positive` | `World` |
| `TS-BIND-UENHANCEDINPUTCOMPONENT-001` | `TestSource/Bindings/UEnhancedInputComponent/Test_Queries_01.as` | `MB-109-S003` `MB-109-S020` | `Positive` | `World` |
| `TS-BIND-UENHANCEDINPUTCOMPONENT-002` | `TestSource/Bindings/UEnhancedInputComponent/Test_MutationAndLifecycle_01.as` | `MB-109-S001` `MB-109-S004` `MB-109-S005` `MB-109-S006` `MB-109-S007` `MB-109-S008` `MB-109-S009` `MB-109-S010` `MB-109-S011` `MB-109-S012` | `Positive;NegativeDiagnostic` | `Editor;ExpectedDiagnostic` |
| `TS-BIND-UENHANCEDINPUTCOMPONENT-003` | `TestSource/Bindings/UEnhancedInputComponent/Test_MutationAndLifecycle_02.as` | `MB-109-S013` `MB-109-S014` `MB-109-S015` `MB-109-S016` `MB-109-S017` `MB-109-S018` `MB-109-S019` | `Positive` | `World` |
| `TS-BIND-UENHANCEDINPUTCOMPONENT-004` | `TestSource/Bindings/UEnhancedInputComponent/Test_Behavior_01.as` | `MB-109-S002` | `Positive` | `Editor` |
| `TS-BIND-UINPUTMAPPINGCONTEXT-001` | `TestSource/Bindings/UInputMappingContext/Test_Operators_01.as` | `MB-113-S006` | `Positive` | `Engine` |
| `TS-BIND-UINPUTMAPPINGCONTEXT-002` | `TestSource/Bindings/UInputMappingContext/Test_Queries_01.as` | `MB-113-S002` `MB-113-S004` `MB-113-S007` `MB-113-S009` `MB-113-S013` `MB-113-S016` `MB-113-S021` `MB-113-S022` `MB-113-S023` | `Positive;NegativeDiagnostic` | `Engine;ExpectedDiagnostic` |
| `TS-BIND-UINPUTMAPPINGCONTEXT-003` | `TestSource/Bindings/UInputMappingContext/Test_MutationAndLifecycle_01.as` | `MB-113-S001` `MB-113-S003` `MB-113-S008` `MB-113-S010` `MB-113-S011` `MB-113-S012` `MB-113-S014` `MB-113-S015` | `Positive` | `Engine` |
| `TS-BIND-UINPUTMAPPINGCONTEXT-004` | `TestSource/Bindings/UInputMappingContext/Test_Behavior_01.as` | `MB-113-S005` `MB-113-S017` `MB-113-S018` `MB-113-S019` `MB-113-S020` | `Positive` | `Engine` |
| `TS-BIND-UINPUTSETTINGS-001` | `TestSource/Bindings/UInputSettings/Test_Queries_01.as` | `MB-114-S001` `MB-114-S002` `MB-114-S003` `MB-114-S004` `MB-114-S005` | `Positive` | `Engine` |
| `TS-BIND-UINPUTSETTINGS-002` | `TestSource/Bindings/UInputSettings/Test_Behavior_01.as` | `MB-114-S006` `MB-114-S007` `MB-114-S008` | `Positive` | `Engine` |
| `TS-BIND-UUSERWIDGET-001` | `TestSource/Bindings/UUserWidget/Test_ConstructionAndAssignment_01.as` | `MB-125-S005` | `Positive` | `Engine` |
| `TS-BIND-UUSERWIDGET-002` | `TestSource/Bindings/UUserWidget/Test_Queries_01.as` | `MB-125-S001` `MB-125-S003` `MB-125-S008` `MB-125-S009` `MB-125-S010` `MB-125-S011` `MB-125-S012` | `Positive` | `Editor` |
| `TS-BIND-UUSERWIDGET-003` | `TestSource/Bindings/UUserWidget/Test_MutationAndLifecycle_01.as` | `MB-125-S002` `MB-125-S004` `MB-125-S006` `MB-125-S007` `MB-125-S023` | `Positive` | `Editor` |
| `TS-BIND-UUSERWIDGET-004` | `TestSource/Bindings/UUserWidget/Test_NamespaceAndGlobalFunctions_01.as` | `MB-125-S014` `MB-125-S015` `MB-125-S016` `MB-125-S017` `MB-125-S018` `MB-125-S029` `MB-125-S030` | `Positive` | `Engine` |
| `TS-BIND-UUSERWIDGET-005` | `TestSource/Bindings/UUserWidget/Test_Behavior_01.as` | `MB-125-S013` `MB-125-S019` `MB-125-S020` `MB-125-S021` `MB-125-S022` `MB-125-S024` `MB-125-S025` `MB-125-S026` `MB-125-S027` `MB-125-S028` | `Positive` | `Engine` |

## Review focus

- Every non-void signature in this matrix must have its return consumed and compared.
- Every void signature must expose a state, callback, diagnostic, or lifecycle observation.
- out/inout, reference, object-handle, default-argument, empty, null, and boundary dimensions are applied per row in the planning CSV.
- Registration/thunk provenance and native-only shards remain C++ concerns; see `../inventory/native-only-review.md`.
