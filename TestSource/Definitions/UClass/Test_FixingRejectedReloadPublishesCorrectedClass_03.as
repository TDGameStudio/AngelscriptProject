// Theme: Definitions.UClass. Reload version pair 03 (fixed full reload). CSV NegativeDiagnostic is wrong;
// C++ CompileModuleWithResult FullReload succeeds and publishes the corrected class.
// C++: AngelscriptClassGeneratorNameConflictTests.cpp::FixingRejectedReloadPublishesCorrectedClass FixedSource.
// Oracle: Value defaults to 3. Retained: UClassGeneratorNameConflictRecovery UCLASS. Replaced vs 02: USTRUCT -> UCLASS, Value 2 -> 3.
// Extra: unset handle is null; mutating one instance does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorNameConflictRecovery : UObject
{
	UPROPERTY()
	int Value = 3;
}

int Observe_RecoveryFixed_DefaultValue(UClassGeneratorNameConflictRecovery Object)
{
	return Object.Value;
}

bool Observe_RecoveryFixed_NullDefault()
{
	UClassGeneratorNameConflictRecovery Object = nullptr;
	return Object == nullptr;
}

bool Observe_RecoveryFixed_CopyIndependent(UClassGeneratorNameConflictRecovery First, UClassGeneratorNameConflictRecovery Second)
{
	First.Value = 0;
	return Second.Value == 3;
}
