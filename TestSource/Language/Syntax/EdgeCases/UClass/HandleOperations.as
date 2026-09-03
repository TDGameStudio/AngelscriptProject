/**
 * Handle introspection: GetClass, GetName and IsA on an actor handle, with the
 * observed name stored for C++ to verify.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.HandleOperations
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.HandleOperations
 * @Provenance C++: AngelscriptCoverageHandleTests.cpp::HandleOperations
 * @Provenance sha256=216b6d09b57cb5a699f7f7a3fa737d5c189d1c48df5d19609e271754992ab226; lines 767-809.
 * @Provenance Oracle: GetClassWorked=true; GetNameWorked=true; IsAWorked=true; ActorName non-empty.
 * @Provenance Extra: flags false and ActorName empty. FixtureIsolated.
 */

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

	/**
	 * Runs GetClass, GetName and IsA over this handle.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the flags and name record each outcome
	 */
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

	/**
	 * Observe that a locally constructed actor has run no operation.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all flags are false and the name is empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleOperationsDefaultEmpty()
	{
		if (GetClassWorked)
		{
			return false;
		}

		if (GetNameWorked)
		{
			return false;
		}

		if (IsAWorked)
		{
			return false;
		}

		return ActorName.Len() == 0;
	}
}
