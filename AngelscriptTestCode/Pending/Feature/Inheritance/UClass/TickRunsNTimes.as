/**
 * @version v1
 * @summary Tick advances one logical count per world-time step. C++ verifies FinalLogicalTickCount - InitialLogicalTickCount == DefaultActorTestTickCount (3). LastTickWorldTime starts at -1.0 so a Tick with no world keeps the count.
 * @topic Feature
 */
/**
 * @version root
 * @summary Tick advances one logical count per world-time step. C++ verifies FinalLogicalTickCount - InitialLogicalTickCount == DefaultActorTestTickCount (3). LastTickWorldTime starts at -1.0 so a Tick with no world keeps the count.
 * @topic Baseline
 */
UCLASS()
class ATestScriptActorTickRunsNTimes : AActor
{
	UPROPERTY()
	int LogicalTickCount = 0;

	UPROPERTY()
	float LastTickWorldTime = -1.0f;

	/**
	 * WorldStory: Tick increments LogicalTickCount only when world time advances.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.TickRunsNTimes
	 * @Inputs the frame delta and GetWorld().GetTimeSeconds()
	 * @Return LogicalTickCount increased once per advancing world-time step
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		float CurrentTime = -1.0f;
		if (GetWorld() != null)
		{
			CurrentTime = GetWorld().GetTimeSeconds();
		}

		if (CurrentTime > LastTickWorldTime)
		{
			LogicalTickCount += 1;
			LastTickWorldTime = CurrentTime;
		}
	}

	/**
	 * Observe that a locally constructed actor has not ticked.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.TickRunsNTimes
	 * @Inputs an actor that has not been ticked
	 * @Return LogicalTickCount, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int DefaultCount()
	{
		return LogicalTickCount;
	}

	/**
	 * Observe the default LastTickWorldTime sentinel.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.TickRunsNTimes
	 * @Inputs an actor that has not been ticked
	 * @Return LastTickWorldTime, expected to be -1.0
	 * @Boundary default world time
	 */
	UFUNCTION()
	float DefaultLastWorldTime()
	{
		return LastTickWorldTime;
	}

	/**
	 * Observe LogicalTickCount after the world has ticked.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.TickRunsNTimes
	 * @Inputs an actor the world has ticked
	 * @Return LogicalTickCount, expected to have advanced by 3
	 */
	UFUNCTION()
	int AfterWorldTicks()
	{
		return LogicalTickCount;
	}
}
/** @end */
