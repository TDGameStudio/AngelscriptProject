// Theme: Definitions.UFunction. WorldStory bool UFUNCTION echo/toggle with LastInput/LastOutput.
// C++: AngelscriptCoverageBoolFunctionTests.cpp::UFunctionParametersAndReturn
// Oracle: EchoBool(true) true and LastInput true; ToggleBool(true) false and LastOutput false.
// Extra: EchoBool(false) empty/false vector; nullptr actor is the empty handle.
// FixtureIsolated. Keep LastInput / LastOutput names.

UCLASS()
class ACoverageBoolFunctionActor : AActor
{
	UPROPERTY()
	bool LastInput = false;

	UPROPERTY()
	bool LastOutput = false;

	UFUNCTION()
	bool EchoBool(bool b)
	{
		LastInput = b;
		return b;
	}

	UFUNCTION()
	bool ToggleBool(bool b)
	{
		LastInput = b;
		LastOutput = !b;
		return LastOutput;
	}
}

bool Observe_BoolFunction_TrueEcho(ACoverageBoolFunctionActor Actor)
{
	return Actor.EchoBool(true) && Actor.LastInput;
}

bool Observe_BoolFunction_FalseEmpty(ACoverageBoolFunctionActor Actor)
{
	return !Actor.EchoBool(false) && !Actor.LastInput;
}

bool Observe_BoolFunction_NullDefault()
{
	ACoverageBoolFunctionActor Actor = nullptr;
	return Actor == nullptr;
}

bool Observe_BoolFunction_ToggleBoundary(ACoverageBoolFunctionActor Actor)
{
	return Actor.ToggleBool(true) == false && Actor.LastOutput == false && Actor.ToggleBool(false) == true;
}
