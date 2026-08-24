// Theme: Definitions.UClass. WorldStory abstract actor compiles but SpawnActor rejects it.
// C++: AngelscriptCoverageUClassTests.cpp::UClassAbstractActorSpawnIsRejected
// CSV NegativeDiagnostic is wrong: the module compiles; spawn of the abstract class is the runtime boundary.
// Oracle: AbstractValue default 19 on concrete spawn; ConcreteValue default 23; abstract spawn is null.
// Extra: unset handles are null. FixtureIsolated.

UCLASS(Abstract)
class ACoverageUClassUnspawnableAbstractActor : AActor
{
	UPROPERTY()
	int AbstractValue = 19;
}

UCLASS()
class ACoverageUClassSpawnableConcreteActor : ACoverageUClassUnspawnableAbstractActor
{
	UPROPERTY()
	int ConcreteValue = 0;

	default ConcreteValue = 23;
}

bool Observe_UnspawnableAbstract_EmptyDefaultIsNull()
{
	ACoverageUClassUnspawnableAbstractActor Actor;
	return Actor == nullptr;
}

bool Observe_SpawnableConcrete_EmptyDefaultIsNull()
{
	ACoverageUClassSpawnableConcreteActor Actor;
	return Actor == nullptr;
}

int Observe_SpawnableConcrete_AbstractValueDefault(ACoverageUClassSpawnableConcreteActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0150 setup: required ACoverageUClassSpawnableConcreteActor is null");
	}
	return Actor.AbstractValue;
}

int Observe_SpawnableConcrete_ConcreteValueDefault(ACoverageUClassSpawnableConcreteActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0150 setup: required ACoverageUClassSpawnableConcreteActor is null");
	}
	return Actor.ConcreteValue;
}

int Observe_SpawnableConcrete_ConcreteValueZeroBoundary(ACoverageUClassSpawnableConcreteActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-DEF-0150 setup: required ACoverageUClassSpawnableConcreteActor is null");
	}
	Actor.ConcreteValue = 0;
	return Actor.ConcreteValue;
}
