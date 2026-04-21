/**
 * Subsystem lifecycle example.
 *
 * Unreal Engine provides several subsystem types that are automatically
 * created and destroyed with their outer object. Script classes can
 * derive from these to add modular, self-contained gameplay systems.
 *
 * NOTE: WorldSubsystem and GameInstanceSubsystem support in this plugin
 * is still being finalized. This example uses property-based patterns
 * to demonstrate how subsystems are typically used.
 */

/**
 * A script component that acts as a self-contained subsystem-like module.
 * This pattern is the most portable way to create modular gameplay systems
 * in AngelScript without depending on specific subsystem base class availability.
 */
class UExampleGameModule : UActorComponent
{
	UPROPERTY(BlueprintReadOnly, Category = "Module")
	int InitCounter = 0;

	UPROPERTY(BlueprintReadOnly, Category = "Module")
	bool bIsInitialized = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		InitCounter += 1;
		bIsInitialized = true;
		Log(f"ExampleGameModule initialized (count: {InitCounter})");
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		bIsInitialized = false;
		Log("ExampleGameModule deinitialized");
	}

	UFUNCTION(BlueprintPure)
	int GetInitCount()
	{
		return InitCounter;
	}
};

/**
 * An actor that hosts the game module component,
 * demonstrating the subsystem-like lifecycle pattern.
 */
class AExampleSubsystemHost : AActor
{
	UPROPERTY()
	UExampleGameModule GameModule;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (GameModule != nullptr)
		{
			int Count = GameModule.GetInitCount();
			Log(f"SubsystemHost: module init count = {Count}");
		}
	}
};
