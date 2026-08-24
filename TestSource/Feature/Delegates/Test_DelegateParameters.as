// Theme: Feature.Delegates. WorldStory one-param then two-param Execute.
// C++: AngelscriptCoverageDelegateTests.cpp::DelegateParameters
// Oracle after BeginPlay: ReceivedInt==100, ReceivedString=="Test".
// Extra: empty actor is null; pre-BeginPlay 0 / empty string. FixtureIsolated.

delegate void FCoverageIntDelegate(int Value);
delegate void FCoverageIntStringDelegate(int IntValue, FString StringValue);

UCLASS()
class ACoverageDelegateParamsActor : AActor
{
	UPROPERTY()
	int ReceivedInt = 0;

	UPROPERTY()
	FString ReceivedString;

	FCoverageIntDelegate OnIntDelegate;
	FCoverageIntStringDelegate OnIntStringDelegate;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnIntDelegate.BindUFunction(this, n"HandleIntDelegate");
		OnIntDelegate.Execute(42);

		OnIntStringDelegate.BindUFunction(this, n"HandleIntStringDelegate");
		OnIntStringDelegate.Execute(100, "Test");
	}

	UFUNCTION()
	void HandleIntDelegate(int Value)
	{
		ReceivedInt = Value;
	}

	UFUNCTION()
	void HandleIntStringDelegate(int IntValue, FString StringValue)
	{
		ReceivedInt = IntValue;
		ReceivedString = StringValue;
	}
}

bool Observe_DelegateParams_EmptyDefaultIsNull()
{
	ACoverageDelegateParamsActor Actor;
	return Actor == nullptr;
}

int Observe_DelegateParams_ReceivedIntDefault(ACoverageDelegateParamsActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0018 setup: required ACoverageDelegateParamsActor is null");
	}
	return Actor.ReceivedInt;
}

FString Observe_DelegateParams_ReceivedStringDefault(ACoverageDelegateParamsActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0018 setup: required ACoverageDelegateParamsActor is null");
	}
	return Actor.ReceivedString;
}
