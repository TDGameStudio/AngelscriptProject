/**
 * @version v1
 * @summary Actor handles stored in containers: a TArray holding a null handle mid-sequence, and two TMaps keyed by int and string. A stored null is a value, not a missing key.
 * @topic Language
 */
/**
 * @version root
 * @summary Actor handles stored in containers: a TArray holding a null handle mid-sequence, and two TMaps keyed by int and string. A stored null is a value, not a missing key.
 * @topic Baseline
 */
UCLASS()
class ACoverageHandleContainerActor : AActor
{
	UPROPERTY()
	TArray<AActor> ActorArray;

	UPROPERTY()
	TMap<int, AActor> IntToActorMap;

	UPROPERTY()
	TMap<FString, AActor> StringToActorMap;

	/**
	 * Populates all three containers with handles including a null.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the containers hold self, spawned actors and null
	 */
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

	/**
	 * Observe that a locally constructed actor leaves all containers empty.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three containers report 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleInContainersDefaultEmpty()
	{
		if (ActorArray.Num() != 0)
		{
			return false;
		}

		if (IntToActorMap.Num() != 0)
		{
			return false;
		}

		return StringToActorMap.Num() == 0;
	}

	/**
	 * Observe that a null handle can be stored and read back.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a script-side array holding self, an actor and null
	 * @Return true when the null sits at index 2 and the count is 3
	 * @Boundary stored null
	 */
	UFUNCTION()
	bool HandleInContainersStoredNull()
	{
		TArray<AActor> Local;
		Local.Add(this);
		Local.Add(nullptr);
		Local.Add(SpawnActor(AActor::StaticClass()));

		if (Local.Num() != 3)
		{
			return false;
		}

		if (Local[0] != this)
		{
			return false;
		}

		return Local[1] == nullptr;
	}
}
/** @end */
