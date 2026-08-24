// Theme: Gameplay.Debug. WorldStory conditional Print by debug mode and log level.
// C++: AngelscriptCoverageLoggingTests.cpp::ConditionalLogging
// CSV NegativeDiagnostic; C++ compiles. VerifyByPath bDebugMode true, LogLevel 2.
// Extra: bDebugMode false / LogLevel 0 is the gated boundary. FixtureIsolated.
// Keep UPROPERTY names.

UCLASS()
class AConditionalLogTestActor : AActor
{
	UPROPERTY()
	bool bDebugMode = true;

	UPROPERTY()
	int LogLevel = 2;

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
}

bool Observe_ConditionalLog_Defaults(AConditionalLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ConditionalLogging setup: required Actor is null");
	}
	return Actor.bDebugMode == true && Actor.LogLevel == 2;
}

bool Observe_ConditionalLog_FalseBoundary(AConditionalLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ConditionalLogging setup: required Actor is null");
	}
	Actor.bDebugMode = false;
	Actor.LogLevel = 0;
	return Actor.bDebugMode == false && Actor.LogLevel == 0;
}
