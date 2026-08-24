// Theme: Language.Syntax.EdgeCases. WorldStory GetClass/GetName/IsA on a handle.
// C++: AngelscriptCoverageHandleTests.cpp::HandleOperations
// sha256=216b6d09b57cb5a699f7f7a3fa737d5c189d1c48df5d19609e271754992ab226; lines 767-809.
// Oracle: GetClassWorked=true; GetNameWorked=true; IsAWorked=true; ActorName non-empty.
// Extra: flags false and ActorName empty. FixtureIsolated.

UCLASS()
class ACoverageHandleOperationsActor : AActor
{
	UPROPERTY()
	bool GetClassWorked = false;

	UPROPERTY()
	bool GetNameWorked = false;

	UPROPERTY()
	bool IsAWorked = false;

	UPROPERTY()
	FString ActorName;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test GetClass
		UClass MyClass = GetClass();
		if (MyClass != nullptr)
		{
			GetClassWorked = true;
		}

		// Test GetName
		FString Name = GetName().ToString();
		if (!Name.IsEmpty())
		{
			GetNameWorked = true;
			ActorName = Name;
		}

		// Test IsA check
		AActor ActorRef = this;
		if (ActorRef.IsA(AActor::StaticClass()))
		{
			IsAWorked = true;
		}
	}
}

bool Observe_HandleOperations_DefaultEmpty(ACoverageHandleOperationsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HandleOperations setup: required Actor is null");
	}
	return !Actor.GetClassWorked && !Actor.GetNameWorked && !Actor.IsAWorked && Actor.ActorName.Len() == 0;
}
