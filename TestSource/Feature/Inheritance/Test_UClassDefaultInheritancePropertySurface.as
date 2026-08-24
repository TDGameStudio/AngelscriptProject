// Theme: Feature.Inheritance. WorldStory UCLASS default inheritance CDO vs spawned surface.
// C++: AngelscriptCoverageUClassTests.cpp::UClassDefaultInheritancePropertySurface
// CompileUClassFixture + spawn. Oracle: leaf CDO Health==100, Label==n"Base"; ActorClass CDO null;
// spawned leaf GetIsReplicated true; spawned tags accumulate BaseTag/MidTag/LeafTag.
// Extra: empty ActorRef; Health 0 boundary on a copy-independent second instance.
// FixtureIsolated. Keep Health/Label/ActorClass/ActorRef.

UCLASS()
class ACoverageUClassDefaultBaseActor : AActor
{
	default Tags.Add(n"BaseTag");
	default SetReplicates(false);

	UPROPERTY()
	int Health = 100;

	UPROPERTY()
	FName Label = n"Base";
}

UCLASS()
class ACoverageUClassDefaultMidActor : ACoverageUClassDefaultBaseActor
{
	default Health = 200;
	default Label = n"Mid";
	default Tags.Add(n"MidTag");
}

UCLASS()
class ACoverageUClassDefaultLeafActor : ACoverageUClassDefaultMidActor
{
	default Health = 300;
	default Tags.Add(n"LeafTag");
	default SetReplicates(true);

	UPROPERTY()
	TSubclassOf<AActor> ActorClass = ACoverageUClassDefaultBaseActor::StaticClass();

	UPROPERTY()
	ACoverageUClassDefaultBaseActor ActorRef;
}

bool Observe_DefaultInheritance_EmptyHandleIsNull()
{
	ACoverageUClassDefaultLeafActor Actor;
	return Actor == nullptr;
}

bool Observe_DefaultInheritance_EmptyActorRef(ACoverageUClassDefaultLeafActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0116 setup: required ACoverageUClassDefaultLeafActor is null");
	}
	return Actor.ActorRef == nullptr;
}

bool Observe_DefaultInheritance_CDOBoundary(ACoverageUClassDefaultLeafActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0116 setup: required ACoverageUClassDefaultLeafActor is null");
	}
	return Actor.Health == 100 && Actor.Label == n"Base";
}

bool Observe_DefaultInheritance_CopyIndependence(
	ACoverageUClassDefaultLeafActor First,
	ACoverageUClassDefaultLeafActor Second)
{
	if (First == nullptr || Second == nullptr)
	{
		throw("TS-FEAT-0116 setup: required leaf actors are null");
	}
	First.Health = 0;
	First.Label = n"";
	return Second.Health == 100 && Second.Label == n"Base" && First.Health == 0;
}
