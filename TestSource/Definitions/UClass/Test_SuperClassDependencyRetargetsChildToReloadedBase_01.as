// Theme: Definitions.UClass. Reload version pair 01 (initial). Positive super-class dependency.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::SuperClassDependencyRetargetsChildToReloadedBase InitialSource.
// Oracle: ReadValue returns Value (default 1).
// Retained after reload: Base/Child types, Value, ReadValue. Replaced in 02: Base.AddedValue and ReadValue body.
// Extra: Value 0 is the empty boundary; mutating one child does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationBase : UObject
{
	UPROPERTY()
	int Value = 1;
}

UCLASS()
class UClassGeneratorPropagationChild : UClassGeneratorPropagationBase
{
	UFUNCTION()
	int ReadValue()
	{
		return Value;
	}
}

int Observe_SuperInitial_ReadValueDefault(UClassGeneratorPropagationChild Child)
{
	return Child.ReadValue();
}

int Observe_SuperInitial_EmptyValueBoundary(UClassGeneratorPropagationChild Child)
{
	Child.Value = 0;
	return Child.ReadValue();
}

bool Observe_SuperInitial_NullDefault()
{
	UClassGeneratorPropagationChild Child = nullptr;
	return Child == nullptr;
}

bool Observe_SuperInitial_CopyIndependent(UClassGeneratorPropagationChild First, UClassGeneratorPropagationChild Second)
{
	First.Value = 9;
	return Second.ReadValue() == 1;
}
