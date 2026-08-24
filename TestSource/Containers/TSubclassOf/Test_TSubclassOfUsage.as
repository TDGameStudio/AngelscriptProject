// Theme: Containers.TSubclassOf. WorldStory: TSubclassOf declare, assign, Get, spawn, IsChildOf.
// C++: AngelscriptCoverageHandlesTests.cpp::TSubclassOfUsage CompileScriptModule + spawn + BeginPlay.
// Oracle: Declaration/Assignment/NullCheck/Get/Comparison/SpawnWithClass/IsChildOf flags true.
// Extra: local construct leaves flags false and ActorClass null.
// FixtureIsolated. Runner owns spawned actors.

UCLASS()
class ACoverageHandlesTSubclassOfActor : AActor
{
	UPROPERTY(EditDefaultsOnly)
	TSubclassOf<AActor> ActorClass;

	UPROPERTY(EditAnywhere)
	TSubclassOf<APawn> PawnClass;

	UPROPERTY()
	bool DeclarationWorked = false;

	UPROPERTY()
	bool AssignmentWorked = false;

	UPROPERTY()
	bool NullCheckWorked = false;

	UPROPERTY()
	bool GetWorked = false;

	UPROPERTY()
	bool ComparisonWorked = false;

	UPROPERTY()
	bool SpawnWithClassWorked = false;

	UPROPERTY()
	bool IsChildOfWorked = false;

	UPROPERTY()
	AActor SpawnedActor;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test declaration
		TSubclassOf<AActor> TempClass;
		DeclarationWorked = true;

		// Test null by default
		if (TempClass == nullptr)
		{
			NullCheckWorked = true;
		}

		// Test assignment
		ActorClass = AActor::StaticClass();
		PawnClass = APawn::StaticClass();
		if (ActorClass != nullptr && PawnClass != nullptr)
		{
			AssignmentWorked = true;
		}

		// Test Get method
		UClass ClassRef = ActorClass.Get();
		if (ClassRef != nullptr)
		{
			GetWorked = true;
		}

		// Test comparison
		TSubclassOf<AActor> SameClass = AActor::StaticClass();
		if (ActorClass == SameClass)
		{
			ComparisonWorked = true;
		}

		// Test spawning with TSubclassOf
		if (ActorClass != nullptr)
		{
			SpawnedActor = SpawnActor(ActorClass);
			if (SpawnedActor != nullptr)
			{
				SpawnWithClassWorked = true;
			}
		}

		// Test IsChildOf type checking
		UClass PawnClassRef = PawnClass.Get();
		if (PawnClassRef != nullptr && PawnClassRef.IsChildOf(AActor::StaticClass()))
		{
			IsChildOfWorked = true;
		}
	}
}

bool Observe_TSubclassOfUsage_DefaultEmpty(ACoverageHandlesTSubclassOfActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSubclassOfUsage setup: required Actor is null");
	}
	return Actor.DeclarationWorked == false
		&& Actor.AssignmentWorked == false
		&& Actor.NullCheckWorked == false
		&& Actor.GetWorked == false
		&& Actor.ComparisonWorked == false
		&& Actor.SpawnWithClassWorked == false
		&& Actor.IsChildOfWorked == false
		&& Actor.ActorClass == nullptr
		&& Actor.SpawnedActor == nullptr;
}

bool Observe_TSubclassOfUsage_EmptyNull()
{
	TSubclassOf<AActor> TempClass;
	return TempClass == nullptr;
}

bool Observe_TSubclassOfUsage_CopyIndependence()
{
	TSubclassOf<AActor> First = AActor::StaticClass();
	TSubclassOf<AActor> Second;
	return First != nullptr && Second == nullptr;
}
