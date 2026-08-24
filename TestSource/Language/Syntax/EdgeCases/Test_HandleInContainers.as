// Theme: Language.Syntax.EdgeCases. WorldStory TArray/TMap of AActor handles including null.
// C++: AngelscriptCoverageHandleTests.cpp::HandleInContainers
// sha256=c9c7c987b6ea82c64a4c6f61bcb5b90830d6a92ecf95bb0974afc14436f070b2; lines 655-687.
// Oracle after BeginPlay: ActorArray.Num=4 [0]=self [2]=null; IntToActorMap.Num=3; StringToActorMap has Self.
// Extra: containers empty. FixtureIsolated. Null handle is a stored value, not a missing key.

UCLASS()
class ACoverageHandleContainerActor : AActor
{
	UPROPERTY()
	TArray<AActor> ActorArray;

	UPROPERTY()
	TMap<int, AActor> IntToActorMap;

	UPROPERTY()
	TMap<FString, AActor> StringToActorMap;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Populate TArray with handles
		ActorArray.Add(this);
		ActorArray.Add(SpawnActor(AActor::StaticClass()));
		ActorArray.Add(nullptr);
		ActorArray.Add(SpawnActor(AActor::StaticClass()));

		// Populate TMap<int, AActor>
		IntToActorMap.Add(1, this);
		IntToActorMap.Add(2, ActorArray[1]);
		IntToActorMap.Add(3, nullptr);

		// Populate TMap<FString, AActor>
		StringToActorMap.Add("Self", this);
		StringToActorMap.Add("Other", ActorArray[1]);
	}
}

bool Observe_HandleInContainers_DefaultEmpty(ACoverageHandleContainerActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HandleInContainers setup: required Actor is null");
	}
	return Actor.ActorArray.Num() == 0 && Actor.IntToActorMap.Num() == 0 && Actor.StringToActorMap.Num() == 0;
}
