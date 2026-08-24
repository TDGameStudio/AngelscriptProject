// Theme: Feature.Delegates. WorldStory: FVector/FString/int pass through dynamic delegates.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateComplexParameters
// Spawn + BeginPlay oracle: ReceivedVector==(10,20,30) after complex broadcast overwrites
// the earlier (1,2,3) Execute; ReceivedString=="Complex"; ReceivedInt==42.
// Extra: default vector zero / empty string / 0; zero vector vs filled. Keep Received*.
// FixtureIsolated.

delegate void FCoverageDynamicVectorEvent(FVector V);
event void FCoverageDynamicVectorStringIntEvent(FVector V, FString S, int I);

UCLASS()
class ACoverageDynamicComplexParamsActor : AActor
{
	UPROPERTY()
	FVector ReceivedVector;

	UPROPERTY()
	FString ReceivedString;

	UPROPERTY()
	int ReceivedInt = 0;

	FCoverageDynamicVectorEvent OnVectorEvent;
	FCoverageDynamicVectorStringIntEvent OnComplexEvent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// FVector parameter
		OnVectorEvent.BindUFunction(this, n"HandleVectorEvent");
		OnVectorEvent.Execute(FVector(1.0f, 2.0f, 3.0f));

		// Multiple complex parameters
		OnComplexEvent.AddUFunction(this, n"HandleComplexEvent");
		OnComplexEvent.Broadcast(FVector(10.0f, 20.0f, 30.0f), "Complex", 42);
	}

	UFUNCTION()
	void HandleVectorEvent(FVector V)
	{
		ReceivedVector = V;
	}

	UFUNCTION()
	void HandleComplexEvent(FVector V, FString S, int I)
	{
		ReceivedVector = V;
		ReceivedString = S;
		ReceivedInt = I;
	}
}

FVector Observe_ReceivedVector_DefaultZero(ACoverageDynamicComplexParamsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DynamicDelegateComplexParameters setup: required Actor is null");
	}
	return Actor.ReceivedVector;
}

int Observe_ReceivedInt_DefaultZero(ACoverageDynamicComplexParamsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DynamicDelegateComplexParameters setup: required Actor is null");
	}
	return Actor.ReceivedInt;
}

bool Observe_ReceivedString_DefaultEmpty(ACoverageDynamicComplexParamsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DynamicDelegateComplexParameters setup: required Actor is null");
	}
	return Actor.ReceivedString.Len() == 0;
}

bool Observe_Vector_CopyIndependence()
{
	FVector Original = FVector(1.0f, 2.0f, 3.0f);
	FVector Copy = Original;
	Copy = FVector(10.0f, 20.0f, 30.0f);
	return Original.X == 1.0f && Copy.X == 10.0f;
}
