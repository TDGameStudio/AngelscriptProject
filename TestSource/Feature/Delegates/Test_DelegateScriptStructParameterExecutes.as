// Theme: Feature.Delegates. WorldStory script USTRUCT passed through Execute.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateScriptStructParameterExecutes
// Oracle after BeginPlay: DelegateWasBound==true, Result==42 (19+23).
// Extra: empty actor is null; pre-BeginPlay Result==0 / DelegateWasBound==false;
// empty payload sums to 0. FixtureIsolated.

USTRUCT()
struct FCoverageDelegatePayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;
}

delegate int FCoverageDelegatePayloadCallback(FCoverageDelegatePayload Payload);

UCLASS()
class ACoverageDelegateScriptStructActor : AActor
{
	UPROPERTY()
	int Result = 0;

	UPROPERTY()
	bool DelegateWasBound = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FCoverageDelegatePayload Payload;
		Payload.Value = 19;
		Payload.Bonus = 23;

		FCoverageDelegatePayloadCallback Callback;
		Callback.BindUFunction(this, n"HandlePayload");
		DelegateWasBound = Callback.IsBound();
		Result = Callback.Execute(Payload);
	}

	UFUNCTION()
	int HandlePayload(FCoverageDelegatePayload Payload)
	{
		return Payload.Value + Payload.Bonus;
	}
}

bool Observe_ScriptStructDelegate_EmptyDefaultIsNull()
{
	ACoverageDelegateScriptStructActor Actor;
	return Actor == nullptr;
}

int Observe_ScriptStructDelegate_ResultDefault(ACoverageDelegateScriptStructActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0029 setup: required ACoverageDelegateScriptStructActor is null");
	}
	return Actor.Result;
}

int Observe_ScriptStructDelegate_EmptyPayloadSum()
{
	FCoverageDelegatePayload Empty;
	return Empty.Value + Empty.Bonus;
}
