// Theme: Definitions.UClass. Isolated compile-fail: SoftReload of a UCLASS module into a USTRUCT.
// C++: AngelscriptClassGeneratorNameConflictTests.cpp::FixingRejectedReloadPublishesCorrectedClass RejectedSource.
// CompileModuleWithResult SoftReloadOnly is false. Expected diagnostic: Full Reload is required due to
// UPROPERTY() or UFUNCTION() changes (type-kind swap is rejected instead of publishing the struct).
// DiagnosticOnly. Replaced vs 01: UCLASS -> USTRUCT FClassGeneratorNameConflictRecovery, Value 1 -> 2.
// Do not keep the original UCLASS; that would make this reload source compile.

USTRUCT()
struct FClassGeneratorNameConflictRecovery
{
	UPROPERTY()
	int Value = 2;
}
