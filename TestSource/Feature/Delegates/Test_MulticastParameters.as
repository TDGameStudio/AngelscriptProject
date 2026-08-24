// Theme: Feature.Delegates. WorldStory: multicast broadcasts int and FString payloads.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastParameters
// Spawn + BeginPlay oracle: IntSum==190 (50+100 + 10+30), ConcatenatedString=="TestTest".
// Extra: default IntSum 0 / empty string; empty vs "Test" copy independence. Keep IntSum.
// FixtureIsolated.

event void FCoverageMcIntSignal(int Value);
event void FCoverageMcIntStringSignal(int IntValue, FString StringValue);

UCLASS()
class ACoverageMulticastParamsActor : AActor
{
	UPROPERTY()
	int IntSum = 0;

	UPROPERTY()
	FString ConcatenatedString;

	UPROPERTY()
	FCoverageMcIntSignal OnIntMulticast;

	UPROPERTY()
	FCoverageMcIntStringSignal OnIntStringMulticast;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// One parameter
		OnIntMulticast.AddUFunction(this, n"HandleInt1");
		OnIntMulticast.AddUFunction(this, n"HandleInt2");
		OnIntMulticast.Broadcast(50);

		// Two parameters
		OnIntStringMulticast.AddUFunction(this, n"HandleIntString1");
		OnIntStringMulticast.AddUFunction(this, n"HandleIntString2");
		OnIntStringMulticast.Broadcast(10, "Test");
	}

	UFUNCTION()
	void HandleInt1(int Value)
	{
		IntSum += Value;
	}

	UFUNCTION()
	void HandleInt2(int Value)
	{
		IntSum += Value * 2;
	}

	UFUNCTION()
	void HandleIntString1(int IntValue, FString StringValue)
	{
		IntSum += IntValue;
		ConcatenatedString += StringValue;
	}

	UFUNCTION()
	void HandleIntString2(int IntValue, FString StringValue)
	{
		IntSum += IntValue * 3;
		ConcatenatedString += StringValue;
	}
}

int Observe_IntSum_DefaultZero(ACoverageMulticastParamsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastParameters setup: required Actor is null");
	}
	return Actor.IntSum;
}

bool Observe_ConcatenatedString_DefaultEmpty(ACoverageMulticastParamsActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastParameters setup: required Actor is null");
	}
	return Actor.ConcatenatedString.Len() == 0;
}

bool Observe_String_CopyIndependence()
{
	FString Original = "Test";
	FString Copy = Original;
	Copy += "Test";
	return Original == "Test" && Copy == "TestTest";
}
