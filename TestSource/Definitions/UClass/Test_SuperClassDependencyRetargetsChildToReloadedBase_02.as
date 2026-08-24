// Theme: Definitions.UClass. Reload version pair 02 (base layout change). Positive super-class dependency.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::SuperClassDependencyRetargetsChildToReloadedBase ReloadSource.
// Oracle: ReadValue returns Value + AddedValue (1 + 2 == 3). Child inherits AddedValue from the reloaded base.
// Retained: Base/Child types, Value, ReadValue name. Replaced: AddedValue = 2; ReadValue body uses AddedValue.
// Extra: both zeros is the empty boundary; mutating one child does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationBase : UObject
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
}

UCLASS()
class UClassGeneratorPropagationChild : UClassGeneratorPropagationBase
{
	UFUNCTION()
	int ReadValue()
	{
		return Value + AddedValue;
	}
}

int Observe_SuperReload_ReadValueDefault(UClassGeneratorPropagationChild Child)
{
	return Child.ReadValue();
}

int Observe_SuperReload_EmptyValuesBoundary(UClassGeneratorPropagationChild Child)
{
	Child.Value = 0;
	Child.AddedValue = 0;
	return Child.ReadValue();
}

int Observe_SuperReload_AddedValueDefault(UClassGeneratorPropagationChild Child)
{
	return Child.AddedValue;
}

bool Observe_SuperReload_CopyIndependent(UClassGeneratorPropagationChild First, UClassGeneratorPropagationChild Second)
{
	First.Value = 9;
	First.AddedValue = 9;
	return Second.ReadValue() == 3;
}
