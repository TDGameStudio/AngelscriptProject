// Theme: Definitions.UStruct. WorldStory FInstancedStruct Reset / array / EchoPayload.
// C++: AngelscriptCoverageUStructTests.cpp::FInstancedStructCoverageSemantics
// CSV says NegativeDiagnostic; C++ CompileScriptModule + spawn + VerifyByPath bResetInvalid==true.
// Extra: local construct leaves bResetInvalid false, Payloads empty, Payload invalid;
// EchoPayload of empty stays invalid. FixtureIsolated. Keep UPROPERTY names Payload, Payloads, bResetInvalid.

USTRUCT()
struct FInstancedStructPayload
{
	UPROPERTY()
	int Value = 42;
}

UCLASS()
class AInstancedStructCoverageActor : AActor
{
	UPROPERTY()
	FInstancedStruct Payload;

	UPROPERTY()
	TArray<FInstancedStruct> Payloads;

	UPROPERTY()
	bool bResetInvalid = false;

	UFUNCTION()
	FInstancedStruct EchoPayload(FInstancedStruct Input)
	{
		return Input;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Payload.Reset();
		Payloads.Add(Payload);
		bResetInvalid = !Payload.IsValid() && Payloads.Num() == 1;
	}
}

bool Observe_InstancedStruct_DefaultEmpty(AInstancedStructCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FInstancedStructCoverageSemantics setup: required Actor is null");
	}
	return Actor.bResetInvalid == false
		&& Actor.Payloads.Num() == 0
		&& !Actor.Payload.IsValid();
}

bool Observe_InstancedStruct_EchoEmptyBoundary(AInstancedStructCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FInstancedStructCoverageSemantics setup: required Actor is null");
	}
	FInstancedStruct Empty;
	FInstancedStruct Echoed = Actor.EchoPayload(Empty);
	return !Empty.IsValid() && !Echoed.IsValid();
}

bool Observe_InstancedStruct_ResetInvalidShape(AInstancedStructCoverageActor Actor)
{
	if (Actor is null)
	{
		throw("Test_FInstancedStructCoverageSemantics setup: required Actor is null");
	}
	Actor.Payload.Reset();
	Actor.Payloads.Add(Actor.Payload);
	Actor.bResetInvalid = !Actor.Payload.IsValid() && Actor.Payloads.Num() == 1;
	return Actor.bResetInvalid == true;
}
