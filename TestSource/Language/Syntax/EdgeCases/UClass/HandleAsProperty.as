/**
 * Handle UPROPERTYs carrying different specifiers: an EditAnywhere actor handle,
 * a BlueprintReadWrite pawn handle, and a categorized component handle. BeginPlay
 * assigns the first two from the world.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.HandleAsProperty
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.HandleAsProperty
 * @Provenance C++: AngelscriptCoverageHandleTests.cpp::HandleAsProperty
 * @Provenance sha256=fd7776416e48293547702235fa57da10d6834e099b10a276fd76d9f06725bcd9; lines 344-372.
 * @Provenance Oracle: TargetActor CPF_Edit; TargetPawn CPF_BlueprintVisible; PropertiesAssigned=true.
 * @Provenance Extra: handles default null and PropertiesAssigned false. FixtureIsolated.
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
