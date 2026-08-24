// Theme: Definitions.UFunction. WorldStory: default arguments plus int &out writeback.
// C++: AngelscriptCoverageUFunctionTests.cpp::DefaultArgumentsAndOutFlagLayout
// Oracle: AddDefaults(20,11,11)==42 LastInput 42; WriteOutput(37) writes LastOutput 42.
// Extra: AddDefaults omitted defaults 20+7+3==30; AddDefaults(0,0,0)==0; default LastInput 0.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageUFunctionDefaultOutActor : AActor
{
	UPROPERTY()
	int LastInput = 0;

	UPROPERTY()
	int LastOutput = 0;

	UFUNCTION(BlueprintCallable, Category="Coverage|Defaults")
	int AddDefaults(int Base, int Delta = 7, int Extra = 3)
	{
		LastInput = Base + Delta + Extra;
		return LastInput;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|Out")
	void WriteOutput(int Input, int&out Output)
	{
		Output = Input + 5;
		LastOutput = Output;
	}
}

int Observe_DefaultOut_Explicit42(ACoverageUFunctionDefaultOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentsAndOutFlagLayout setup: required Actor is null");
	}
	return Actor.AddDefaults(20, 11, 11);
}

int Observe_DefaultOut_OmittedDefaults(ACoverageUFunctionDefaultOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentsAndOutFlagLayout setup: required Actor is null");
	}
	return Actor.AddDefaults(20);
}

int Observe_DefaultOut_Write37(ACoverageUFunctionDefaultOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentsAndOutFlagLayout setup: required Actor is null");
	}
	int Output = 0;
	Actor.WriteOutput(37, Output);
	if (Output != 42)
	{
		return -1;
	}
	return Actor.LastOutput;
}

int Observe_DefaultOut_ZeroBoundary(ACoverageUFunctionDefaultOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentsAndOutFlagLayout setup: required Actor is null");
	}
	return Actor.AddDefaults(0, 0, 0);
}

int Observe_DefaultOut_DefaultLastInput(ACoverageUFunctionDefaultOutActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DefaultArgumentsAndOutFlagLayout setup: required Actor is null");
	}
	return Actor.LastInput;
}
