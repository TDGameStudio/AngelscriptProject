// Theme: Language.Syntax.EdgeCases. WorldStory TArray/TMap of FQuat.
// C++: AngelscriptCoverageFQuatPropertyTests.cpp::FQuatContainerProperties
// sha256=2264d00498cbf59e2b88827ddb2037406b4141739a33905ad77e77b7465939ac; lines 256-278.
// Oracle after BeginPlay: QuatArray.Num=3; [0].W=1 Identity; [1].Z non-zero yaw 90;
// IntToQuatMap.Num=3; key 1 is Identity. Extra: local construct empty containers.
// FixtureIsolated.

UCLASS()
class ACoverageFQuatContainerActor : AActor
{
	UPROPERTY()
	TArray<FQuat> QuatArray;

	UPROPERTY()
	TMap<int, FQuat> IntToQuatMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		QuatArray.Add(FQuat::Identity);
		QuatArray.Add(FQuat(FRotator(0, 90, 0)));
		QuatArray.Add(FQuat(FRotator(90, 0, 0)));

		IntToQuatMap.Add(1, FQuat::Identity);
		IntToQuatMap.Add(2, FQuat(FRotator(0, 45, 0)));
		IntToQuatMap.Add(3, FQuat(FRotator(45, 0, 0)));
	}
}

bool Observe_FQuatContainer_DefaultEmpty(ACoverageFQuatContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FQuatContainerProperties setup: required Actor is null");
	}
	return Actor.QuatArray.Num() == 0 && Actor.IntToQuatMap.Num() == 0;
}

bool Observe_FQuatContainer_ScriptFillBoundary(ACoverageFQuatContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FQuatContainerProperties setup: required Actor is null");
	}
	Actor.QuatArray.Add(FQuat::Identity);
	Actor.QuatArray.Add(FQuat(FRotator(0, 90, 0)));
	Actor.IntToQuatMap.Add(1, FQuat::Identity);
	return Actor.QuatArray.Num() == 2 && Actor.QuatArray[0].Equals(FQuat::Identity, 0.001) && Math::Abs(Actor.QuatArray[1].Z) > 0.5 && Actor.IntToQuatMap[1].Equals(FQuat::Identity, 0.001);
}
