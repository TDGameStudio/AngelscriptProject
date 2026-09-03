/**
 * SoftReload of a UCLASS module into a USTRUCT is rejected. The type-kind
 * swap requires a full reload instead of publishing the struct.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.FixingRejectedReloadRejected
 * @Harness CompileReject
 * @Tag Definitions.UClass.FixingRejectedReloadRejected
 * @Kind CompileReject
 * @Covers UClass.Reload
 * @Inputs USTRUCT FClassGeneratorNameConflictRecovery replacing a prior UCLASS
 * @Return does not compile; diagnostic "Full Reload is required due to UPROPERTY() or UFUNCTION() changes"
 * @Provenance Theme: Definitions.UClass. Isolated compile-fail: SoftReload of a UCLASS module into a USTRUCT.
 * @Provenance C++: AngelscriptClassGeneratorNameConflictTests.cpp::FixingRejectedReloadPublishesCorrectedClass RejectedSource.
 * @Provenance CompileModuleWithResult SoftReloadOnly is false. Expected diagnostic: Full Reload is required due to
 * @Provenance UPROPERTY() or UFUNCTION() changes (type-kind swap is rejected instead of publishing the struct).
 * @Provenance DiagnosticOnly. Replaced vs 01: UCLASS -> USTRUCT FClassGeneratorNameConflictRecovery, Value 1 -> 2.
 * @Provenance Do not keep the original UCLASS; that would make this reload source compile.
 */

USTRUCT()
struct FClassGeneratorNameConflictRecovery
{
	UPROPERTY()
	int Value = 2;
}
