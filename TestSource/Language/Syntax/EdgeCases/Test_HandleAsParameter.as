// Theme: Language.Syntax.EdgeCases. WorldStory handle as in/return/&out.
// C++: AngelscriptCoverageHandleTests.cpp::HandleAsParameter
// sha256=a2eccd7c0a16b65d220665a10ee9ffa6f1241a102401321b3ef0e6c47ad7a84b; lines 557-613.
// Oracle: InputParamWorked=true; ReturnValueWorked=true; OutParamWorked=true.
// Extra: flags default false. FixtureIsolated. &out writes the actor handle.

UCLASS()
class ACoverageHandleParameterActor : AActor
{
	UPROPERTY()
	bool InputParamWorked = false;

	UPROPERTY()
	bool ReturnValueWorked = false;

	UPROPERTY()
	bool OutParamWorked = false;

	// Function taking handle as input parameter
	void ProcessActor(AActor InActor)
	{
		if (InActor != nullptr && InActor == this)
		{
			InputParamWorked = true;
		}
	}

	// Function returning handle
	AActor GetSelf()
	{
		return this;
	}

	// Function with out parameter
	void GetActorOut(AActor&out OutActor)
	{
		OutActor = this;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Test input parameter
		ProcessActor(this);

		// Test return value
		AActor Returned = GetSelf();
		if (Returned == this)
		{
			ReturnValueWorked = true;
		}

		// Test out parameter
		AActor OutResult;
		GetActorOut(OutResult);
		if (OutResult == this)
		{
			OutParamWorked = true;
		}
	}
}

bool Observe_HandleAsParameter_DefaultFalse(ACoverageHandleParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_HandleAsParameter setup: required Actor is null");
	}
	return !Actor.InputParamWorked && !Actor.ReturnValueWorked && !Actor.OutParamWorked;
}
