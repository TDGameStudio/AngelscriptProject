// Theme: Gameplay.Debug. WorldStory function entry/exit Print pattern.
// C++: AngelscriptCoverageLoggingTests.cpp::FunctionEntryExitLogging
// Oracle: AFunctionLogTestActor compiles and spawns; BeginPlay calls ProcessData(42)
// and ValidateInput("TestString"). Extra: empty Input is invalid; Value 0. FixtureIsolated.

UCLASS()
class AFunctionLogTestActor : AActor
{
	UFUNCTION()
	void ProcessData(int Value)
	{
		Print(">>> Enter ProcessData, Value=" + Value);

		int Result = Value * 2;
		Print("    Computed result: " + Result);

		Print("<<< Exit ProcessData");
	}

	UFUNCTION()
	bool ValidateInput(FString Input)
	{
		Print(">>> Enter ValidateInput");

		bool bValid = Input.Len() > 0;
		Print("    Input length: " + Input.Len() + ", Valid: " + bValid);

		Print("<<< Exit ValidateInput, returning: " + bValid);
		return bValid;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== BeginPlay Start ===");

		ProcessData(42);

		bool bResult = ValidateInput("TestString");
		Print("Validation result: " + bResult);

		Print("=== BeginPlay End ===");
	}
}

bool Observe_ValidateInput_Nominal(AFunctionLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionEntryExitLogging setup: required Actor is null");
	}
	return Actor.ValidateInput("TestString") == true;
}

bool Observe_ValidateInput_Empty(AFunctionLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionEntryExitLogging setup: required Actor is null");
	}
	return Actor.ValidateInput("") == false;
}

bool Observe_ProcessData_ZeroBoundary(AFunctionLogTestActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FunctionEntryExitLogging setup: required Actor is null");
	}
	int Value = 0;
	int Result = Value * 2;
	Actor.ProcessData(Value);
	return Result == 0;
}
