/**
 * Default arguments plus int &out writeback. AddDefaults(20,11,11) is 42 and
 * LastInput 42. WriteOutput(37) writes LastOutput 42. Omitted defaults are
 * 20+7+3==30. AddDefaults(0,0,0) is 0. Default LastInput is 0.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.DefaultArgumentsAndOutFlagLayout
 * @Harness UClass
 * @Tag Definitions.UFunction.DefaultArgumentsAndOutFlagLayout
 * @Provenance Theme: Definitions.UFunction. WorldStory: default arguments plus int &out writeback.
 * @Provenance C++: AngelscriptCoverageUFunctionTests.cpp::DefaultArgumentsAndOutFlagLayout
 * @Provenance Oracle: AddDefaults(20,11,11)==42 LastInput 42; WriteOutput(37) writes LastOutput 42.
 * @Provenance Extra: AddDefaults omitted defaults 20+7+3==30; AddDefaults(0,0,0)==0; default LastInput 0.
 * @Provenance FixtureIsolated. Runner owns World teardown.
 */

UCLASS()
class ACoverageUFunctionDefaultOutActor : AActor
{
	UPROPERTY()
	int LastInput = 0;

	UPROPERTY()
	int LastOutput = 0;

	/**
	 * Store Base + Delta + Extra as LastInput and return it.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Base Required addend
	 * @Param Delta Optional addend, default 7
	 * @Param Extra Optional addend, default 3
	 * @Inputs Base, Delta, and Extra
	 * @Return LastInput after the write
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Defaults")
	int AddDefaults(int Base, int Delta = 7, int Extra = 3)
	{
		LastInput = Base + Delta + Extra;
		return LastInput;
	}

	/**
	 * Write Input + 5 into Output and LastOutput.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param Input Source
	 * @Param Output Destination received as int&out
	 * @Inputs Input and Output
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|Out")
	void WriteOutput(int Input, int&out Output)
	{
		Output = Input + 5;
		LastOutput = Output;
	}

	/**
	 * Observe AddDefaults(20, 11, 11).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AddDefaults(20, 11, 11)
	 * @Return 42
	 */
	UFUNCTION()
	int DefaultOutExplicit42()
	{
		return AddDefaults(20, 11, 11);
	}

	/**
	 * Observe AddDefaults(20) with omitted optional arguments.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AddDefaults(20)
	 * @Return 30
	 * @Boundary omitted defaults
	 */
	UFUNCTION()
	int DefaultOutOmittedDefaults()
	{
		return AddDefaults(20);
	}

	/**
	 * Observe WriteOutput(37) and LastOutput.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs WriteOutput(37)
	 * @Return 42 when Output is 42, otherwise -1
	 */
	UFUNCTION()
	int DefaultOutWrite37()
	{
		int Output = 0;
		WriteOutput(37, Output);
		if (Output != 42)
		{
			return -1;
		}
		return LastOutput;
	}

	/**
	 * Observe AddDefaults(0, 0, 0).
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs AddDefaults(0, 0, 0)
	 * @Return 0
	 * @Boundary zero addends
	 */
	UFUNCTION()
	int DefaultOutZeroBoundary()
	{
		return AddDefaults(0, 0, 0);
	}

	/**
	 * Observe the default LastInput.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs LastInput on a freshly constructed actor
	 * @Return 0
	 * @Boundary default LastInput
	 */
	UFUNCTION()
	int DefaultOutDefaultLastInput()
	{
		return LastInput;
	}
}
