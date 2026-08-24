// Theme: Definitions.UClass. Reload version pair 01 (initial). Positive cyclic property dependency.
// C++: AngelscriptClassGeneratorReloadPropagationTests.cpp::CyclicPropertyDependencyTerminatesAndRetargetsBothSides InitialSource.
// Oracle: live CycleA.Other and CycleB.Other default to null.
// Retained after reload: CycleA/CycleB types and Other properties. Replaced in 02: CycleA.AddedValue.
// Extra: unset CycleA handle is null; assigning aliases the same handle.
// FixtureIsolated. Object handles are runner-owned when non-null.

UCLASS()
class UClassGeneratorPropagationCycleA : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationCycleB Other;
}

UCLASS()
class UClassGeneratorPropagationCycleB : UObject
{
	UPROPERTY()
	UClassGeneratorPropagationCycleA Other;
}

bool Observe_CycleInitial_AOtherNull(UClassGeneratorPropagationCycleA Node)
{
	return Node.Other == nullptr;
}

bool Observe_CycleInitial_BOtherNull(UClassGeneratorPropagationCycleB Node)
{
	return Node.Other == nullptr;
}

bool Observe_CycleInitial_ANullDefault()
{
	UClassGeneratorPropagationCycleA Node = nullptr;
	return Node == nullptr;
}

bool Observe_CycleInitial_AssignAliases(UClassGeneratorPropagationCycleA Node)
{
	UClassGeneratorPropagationCycleA Alias = Node;
	return Alias == Node;
}
