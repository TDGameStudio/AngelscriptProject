// Theme: Feature.Delegates. WorldStory dynamic single Execute then multicast Broadcast.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateParameters
// Oracle after BeginPlay: ReceivedInt==100, ReceivedString=="Test".
// Extra: empty actor is null; pre-BeginPlay 0 / empty string. FixtureIsolated.

delegate void FCoverageDynamicIntEvent(int Value);
event void FCoverageDynamicIntStringEvent(int IntValue, FString StringValue);

UCLASS()
class ACoverageDynamicParamsActor : AActor
{
	UPROPERTY()
	int ReceivedInt = 0;

	UPROPERTY()
	FString ReceivedString;

	FCoverageDynamicIntEvent OnIntEvent;
	FCoverageDynamicIntStringEvent OnIntStringEvent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnIntEvent.BindUFunction(this, n"HandleIntEvent");
		OnIntEvent.Execute(42);

		OnIntStringEvent.AddUFunction(this, n"HandleIntStringEvent");
		OnIntStringEvent.Broadcast(100, "Test");
	}

	UFUNCTION()
	void HandleIntEvent(int Value)
	{
		ReceivedInt = Value;
	}

	UFUNCTION()
	void HandleIntStringEvent(int IntValue, FString StringValue)
	{
		ReceivedInt = IntValue;
		ReceivedString = StringValue;
	}
}

bool Observe_DynamicParams_EmptyDefaultIsNull()
{
	ACoverageDynamicParamsActor Actor;
	return Actor == nullptr;
}

int Observe_DynamicParams_ReceivedIntDefault(ACoverageDynamicParamsActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0032 setup: required ACoverageDynamicParamsActor is null");
	}
	return Actor.ReceivedInt;
}

FString Observe_DynamicParams_ReceivedStringDefault(ACoverageDynamicParamsActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0032 setup: required ACoverageDynamicParamsActor is null");
	}
	return Actor.ReceivedString;
}
