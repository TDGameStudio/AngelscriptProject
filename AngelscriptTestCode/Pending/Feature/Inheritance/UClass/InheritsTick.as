/**
 * @version v1
 * @summary A Blueprint child inherits a script Tick that increments TickCount. C++ verifies TickCount is at least DefaultTickCount (3) after world ticks. The zero-delta call still increments.
 * @topic Feature
 */
/**
 * @version root
 * @summary A Blueprint child inherits a script Tick that increments TickCount. C++ verifies TickCount is at least DefaultTickCount (3) after world ticks. The zero-delta call still increments.
 * @topic Baseline
 */
UCLASS()
class ATestBPChildInheritsTickParent : AActor
{
	UPROPERTY()
	int TickCount = 0;

	/**
	 * WorldStory: Tick counts each dispatch so a Blueprint child inherits it.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.InheritsTick
	 * @Inputs the frame delta
	 * @Return TickCount incremented once per tick
	 * @Param DeltaTime the frame delta
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount += 1;
	}

	/**
	 * Observe that a locally constructed parent has not ticked.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritsTick
	 * @Inputs an actor that has not been ticked
	 * @Return TickCount, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int DefaultCount()
	{
		return TickCount;
	}

	/**
	 * Observe that Tick(0.0) still increments the count.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritsTick
	 * @Inputs Tick(0.0f)
	 * @Return TickCount after a zero-delta tick
	 * @Boundary zero delta
	 */
	UFUNCTION()
	int ZeroDeltaBoundary()
	{
		Tick(0.0f);
		return TickCount;
	}

	/**
	 * Observe TickCount after the world has ticked.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.InheritsTick
	 * @Inputs an actor the world has ticked
	 * @Return TickCount, expected to be at least 3
	 */
	UFUNCTION()
	int AfterWorldTicks()
	{
		return TickCount;
	}
}
/** @end */
