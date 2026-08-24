// Theme: Containers.TObjectPtr. WorldStory: object-handle declaration, null, assign, IsValid.
// C++ VerifyByPath: DeclarationWorked, NullCheckPassed, AssignmentWorked, IsValidCheckPassed all true.
// Extra: ActorRef/ObjectRef/PawnRef default null until BeginPlay. FixtureIsolated.

UCLASS()
class ACoverageHandlesObjectRefActor : AActor
{
	UPROPERTY()
	bool DeclarationWorked = false;

	UPROPERTY()
	bool NullCheckPassed = false;

	UPROPERTY()
	bool AssignmentWorked = false;

	UPROPERTY()
	bool IsValidCheckPassed = false;

	UPROPERTY()
	AActor ActorRef;

	UPROPERTY()
	UObject ObjectRef;

	UPROPERTY()
	APawn PawnRef;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test declaration - references are null by default
		AActor TempActor;
		if (TempActor == nullptr)
		{
			DeclarationWorked = true;
		}

		// Test null check
		if (ActorRef == nullptr)
		{
			NullCheckPassed = true;
		}

		// Test assignment
		ActorRef = this;
		if (ActorRef != nullptr && ActorRef == this)
		{
			AssignmentWorked = true;
		}

		// Test IsValid
		if (!IsValid(ObjectRef) && IsValid(ActorRef))
		{
			IsValidCheckPassed = true;
		}

		// Assign different types
		PawnRef = Cast<APawn>(SpawnActor(APawn::StaticClass()));
		ObjectRef = PawnRef;
	}
}
