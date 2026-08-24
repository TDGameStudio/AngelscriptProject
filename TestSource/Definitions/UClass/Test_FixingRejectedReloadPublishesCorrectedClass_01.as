// Theme: Definitions.UClass. Reload version pair 01 (initial). CSV NegativeDiagnostic is wrong;
// C++ CompileAnnotatedModuleFromMemory succeeds and publishes the class.
// C++: AngelscriptClassGeneratorNameConflictTests.cpp::FixingRejectedReloadPublishesCorrectedClass InitialSource.
// Oracle: Value defaults to 1. Retained across the pair: UClassGeneratorNameConflictRecovery name.
// Extra: unset handle is null; mutating one instance does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorNameConflictRecovery : UObject
{
	UPROPERTY()
	int Value = 1;
}

int Observe_RecoveryInitial_DefaultValue(UClassGeneratorNameConflictRecovery Object)
{
	return Object.Value;
}

bool Observe_RecoveryInitial_NullDefault()
{
	UClassGeneratorNameConflictRecovery Object = nullptr;
	return Object == nullptr;
}

bool Observe_RecoveryInitial_CopyIndependent(UClassGeneratorNameConflictRecovery First, UClassGeneratorNameConflictRecovery Second)
{
	First.Value = 0;
	return Second.Value == 1;
}
