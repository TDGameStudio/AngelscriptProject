/**
 * @version v1
 * @summary The function entry and exit print pattern, where each function announces its entry, its work and its exit. C++ spawns the actor and lets BeginPlay drive both entrypoints. The observers cover the nominal validation, the.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The function entry and exit print pattern, where each function announces its entry, its work and its exit. C++ spawns the actor and lets BeginPlay drive both entrypoints. The observers cover the nominal validation, the.
 * @topic Baseline
 */
UCLASS()
class AFunctionLogTestActor : AActor
{
	/**
	 * Print the entry, the computed result and the exit for a value doubling.
	 *
	 * @Kind Action
	 * @Covers Debug.FunctionEntryExitLogging
	 * @Inputs the value to double
	 * @Return nothing; the three print lines are what the test observes
	 * @Param Value the value to double
	 */
	UFUNCTION()
	void ProcessData(int Value)
	{
		Print(">>> Enter ProcessData, Value=" + Value);

		int Result = Value * 2;
		Print("    Computed result: " + Result);

		Print("<<< Exit ProcessData");
	}

	/**
	 * Print the entry and exit for a non-empty input check.
	 *
	 * @Kind Observe
	 * @Covers Debug.FunctionEntryExitLogging
	 * @Inputs the string to validate
	 * @Return true when the input is non-empty
	 * @Param Input the string to validate
	 * @Boundary empty input
	 */
	UFUNCTION()
	bool ValidateInput(FString Input)
	{
		Print(">>> Enter ValidateInput");

		bool bValid = Input.Len() > 0;
		Print("    Input length: " + Input.Len() + ", Valid: " + bValid);

		Print("<<< Exit ValidateInput, returning: " + bValid);
		return bValid;
	}

	/**
	 * WorldStory: BeginPlay brackets its own work and drives both instrumented
	 * entrypoints.
	 *
	 * @Kind WorldStory
	 * @Covers Debug.FunctionEntryExitLogging
	 * @Inputs none
	 * @Return ProcessData(42) and ValidateInput("TestString") both run
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("=== BeginPlay Start ===");

		ProcessData(42);

		bool bResult = ValidateInput("TestString");
		Print("Validation result: " + bResult);

		Print("=== BeginPlay End ===");
	}

	/**
	 * Observe that a non-empty input validates.
	 *
	 * @Kind Observe
	 * @Covers Debug.FunctionEntryExitLogging
	 * @Inputs a non-empty string
	 * @Return ValidateInput("TestString"), expected to be true
	 */
	UFUNCTION()
	bool ValidateInputNominal()
	{
		return ValidateInput("TestString");
	}

	/**
	 * Observe that an empty input is rejected.
	 *
	 * @Kind Observe
	 * @Covers Debug.FunctionEntryExitLogging
	 * @Inputs an empty string
	 * @Return the negation of ValidateInput(""), expected to be true
	 * @Boundary empty input
	 */
	UFUNCTION()
	bool ValidateInputEmpty()
	{
		return !ValidateInput("");
	}

	/**
	 * Observe that a zero value doubles to zero and survives the instrumented call.
	 *
	 * @Kind Observe
	 * @Covers Debug.FunctionEntryExitLogging
	 * @Inputs a zero value
	 * @Return true when the doubled result is 0
	 * @Boundary zero value
	 */
	UFUNCTION()
	bool ProcessDataZeroBoundary()
	{
		int Value = 0;
		int Result = Value * 2;
		ProcessData(Value);
		return Result == 0;
	}
}
/** @end */
