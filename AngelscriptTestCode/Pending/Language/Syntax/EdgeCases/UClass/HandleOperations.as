/**
 * @version v1
 * @summary Handle introspection: GetClass, GetName and IsA on an actor handle, with the observed name stored for C++ to verify.
 * @topic Language
 */
/**
 * @version root
 * @summary Handle introspection: GetClass, GetName and IsA on an actor handle, with the observed name stored for C++ to verify.
 * @topic Baseline
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
/** @end */
