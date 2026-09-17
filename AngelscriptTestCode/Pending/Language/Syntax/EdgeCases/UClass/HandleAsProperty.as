/**
 * @version v1
 * @summary Handle UPROPERTYs carrying different specifiers: an EditAnywhere actor handle, a BlueprintReadWrite pawn handle, and a categorized component handle. BeginPlay assigns the first two from the world.
 * @topic Language
 */
/**
 * @version root
 * @summary Handle UPROPERTYs carrying different specifiers: an EditAnywhere actor handle, a BlueprintReadWrite pawn handle, and a categorized component handle. BeginPlay assigns the first two from the world.
 * @topic Baseline
 */
UCLASS()
class ACoverageHandlePropertyActor : AActor
{
	UPROPERTY(EditAnywhere)
	AActor TargetActor;

	UPROPERTY(BlueprintReadWrite)
	APawn TargetPawn;

	UPROPERTY(Category="Refs")
	UActorComponent TargetComponent;

	UPROPERTY()
	bool PropertiesAssigned = false;

	/**
	 * Assigns the actor and pawn handles.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; PropertiesAssigned records both assignments
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TargetActor = this;
		TargetPawn = Cast<APawn>(SpawnActor(APawn::StaticClass()));

		if (TargetActor != nullptr && TargetPawn != nullptr)
		{
			PropertiesAssigned = true;
		}
	}

	/**
	 * Observe that a locally constructed actor leaves every handle null.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all three handles are null and the flag is false
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool HandleAsPropertyDefaultEmpty()
	{
		if (TargetActor != nullptr)
		{
			return false;
		}

		if (TargetPawn != nullptr)
		{
			return false;
		}

		if (TargetComponent != nullptr)
		{
			return false;
		}

		return !PropertiesAssigned;
	}
}
/** @end */
