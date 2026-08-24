// Theme: Containers.TSubclassOf. WorldStory: UClass.IsChildOf through TSubclassOf.Get().
// C++: AngelscriptCoverageWeakReferenceTests.cpp::TSubclassOfTypeCheck
// CompileScriptModule + spawn + BeginPlay. Oracle: IsChildOfActorWorked, IsChildOfPawnWorked,
// PawnIsChildOfActorWorked true.
// Extra: local construct leaves flags false; empty TSubclassOf has no class.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageSubclassOfTypeCheckActor : AActor
{
	UPROPERTY()
	bool IsChildOfActorWorked = false;

	UPROPERTY()
	bool IsChildOfPawnWorked = false;

	UPROPERTY()
	bool PawnIsChildOfActorWorked = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TSubclassOf<AActor> ActorClass = AActor::StaticClass();
		TSubclassOf<APawn> PawnClass = APawn::StaticClass();

		// Check if AActor is child of AActor (itself)
		UClass ActorClassRef = ActorClass.Get();
		if (ActorClassRef.IsChildOf(AActor::StaticClass()))
		{
			IsChildOfActorWorked = true;
		}

		// Check if APawn is child of APawn (itself)
		UClass PawnClassRef = PawnClass.Get();
		if (PawnClassRef.IsChildOf(APawn::StaticClass()))
		{
			IsChildOfPawnWorked = true;
		}

		// Check if APawn is child of AActor (inheritance)
		if (PawnClassRef.IsChildOf(AActor::StaticClass()))
		{
			PawnIsChildOfActorWorked = true;
		}
	}
}

bool Observe_SubclassOfTypeCheck_DefaultEmpty(ACoverageSubclassOfTypeCheckActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSubclassOfTypeCheck setup: required Actor is null");
	}
	return Actor.IsChildOfActorWorked == false
		&& Actor.IsChildOfPawnWorked == false
		&& Actor.PawnIsChildOfActorWorked == false;
}

bool Observe_SubclassOfTypeCheck_EmptyGetNull()
{
	TSubclassOf<AActor> ActorClass;
	return ActorClass.Get() == nullptr;
}

bool Observe_SubclassOfTypeCheck_CopyIndependence()
{
	TSubclassOf<AActor> First = AActor::StaticClass();
	TSubclassOf<APawn> Second;
	return First.Get() != nullptr && Second.Get() == nullptr
		&& First.Get().IsChildOf(AActor::StaticClass());
}
