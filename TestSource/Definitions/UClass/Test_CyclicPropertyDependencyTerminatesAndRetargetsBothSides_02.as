// Theme: Definitions.UClass. Reload version pair 02 (cycle A layout change). Positive cyclic dependency.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::CyclicPropertyDependencyTerminatesAndRetargetsBothSides ReloadSource.
// Oracle: AddedValue defaults to 2; Other properties remain null on live nodes.
// Retained: CycleA/CycleB types and Other properties. Replaced: CycleA.AddedValue = 2.
// Extra: AddedValue 0 is the empty boundary; mutating one CycleA does not write the other.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationCycleA : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationCycleB Other;

	UPROPERTY()
	int AddedValue = 2;
}

UCLASS()
class UClassGeneratorPropagationCycleB : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationCycleA Other;
}

int Observe_CycleReload_AddedValueDefault(UClassGeneratorPropagationCycleA Node)
{
	return Node.AddedValue;
}

int Observe_CycleReload_AddedValueEmptyBoundary(UClassGeneratorPropagationCycleA Node)
{
	Node.AddedValue = 0;
	return Node.AddedValue;
}

bool Observe_CycleReload_AOtherNull(UClassGeneratorPropagationCycleA Node)
{
	return Node.Other == nullptr;
}

bool Observe_CycleReload_CopyIndependent(UClassGeneratorPropagationCycleA First, UClassGeneratorPropagationCycleA Second)
{
	First.AddedValue = 9;
	return Second.AddedValue == 2;
}
