/**
 * Prints gated behind a debug-mode flag and a log level. The CSV NegativeDiagnostic
 * label is a heuristic: C++ compiles this and verifies the flag and level by path, so
 * this is a value oracle. The UPROPERTY names are part of the contract and are kept
 * verbatim.
 *
 * @Theme Gameplay.Debug
 * @Subject Debug.ConditionalLogging
 * @Harness UClass
 * @Tag Gameplay.Debug.ConditionalLogging
 * @Provenance Theme: Gameplay.Debug. WorldStory conditional Print by debug mode and log level.
 * @Provenance C++: AngelscriptCoverageLoggingTests.cpp::ConditionalLogging
 * @Provenance CSV NegativeDiagnostic; C++ compiles. VerifyByPath bDebugMode true, LogLevel 2.
 * @Provenance Extra: bDebugMode false / LogLevel 0 is the gated boundary. FixtureIsolated.
 * @Provenance Keep UPROPERTY names.
 */

UCLASS()
class AConditionalLogTestActor : AActor
{
	UPROPERTY()
	bool bDebugMode = true;

	UPROPERTY()
	int LogLevel = 2;

	/**
	 * WorldStory: BeginPlay prints each tier whose gate is open, then reports on an
	 * operation outcome.
	 *
	 * @Kind WorldStory
	 * @Covers Debug.ConditionalLogging
	 * @Inputs none
	 * @Return the debug, info and verbose tiers printed with the declared defaults
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (bDebugMode)
		{
			Print("[DEBUG] Debug mode is enabled");
		}

		if (LogLevel >= 1)
		{
			Print("[INFO] Basic information");
		}

		if (LogLevel >= 2)
		{
			Print("[VERBOSE] Detailed information");
		}

		if (LogLevel >= 3)
		{
			Print("[VERY_VERBOSE] Very detailed information");
		}

		int Health = 0;
		if (Health <= 0)
		{
			PrintError("Health is zero or negative!");
		}

		float Temperature = 95.0f;
		if (Temperature > 90.0f)
		{
			PrintWarning("Temperature is high: " + Temperature);
		}

		bool bOperationSuccess = true;
		if (bOperationSuccess)
		{
			Print("[SUCCESS] Operation completed successfully");
		}
		else
		{
			PrintError("[FAILURE] Operation failed");
		}
	}

	/**
	 * Observe that a locally constructed actor keeps its declared gate values.
	 *
	 * @Kind Observe
	 * @Covers Debug.ConditionalLogging
	 * @Inputs an actor that has not run BeginPlay
	 * @Return true when bDebugMode is set and LogLevel is 2
	 * @Boundary declared defaults
	 */
	UFUNCTION()
	bool Defaults()
	{
		if (!bDebugMode)
		{
			return false;
		}
		return LogLevel == 2;
	}

	/**
	 * Observe that clearing the gates suppresses every tier.
	 *
	 * @Kind Observe
	 * @Covers Debug.ConditionalLogging
	 * @Inputs none
	 * @Return true when bDebugMode is clear and LogLevel is 0
	 * @Boundary gated off
	 */
	UFUNCTION()
	bool FalseBoundary()
	{
		bDebugMode = false;
		LogLevel = 0;

		if (bDebugMode)
		{
			return false;
		}
		return LogLevel == 0;
	}
}
