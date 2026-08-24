// Theme: Feature.Delegates. WorldStory: three multicast listeners run in add order.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastMultipleListeners
// Spawn + BeginPlay oracle: Counter==111 (1+10+100), Result=="ABC".
// Extra: default Counter 0 / empty Result; default event unbound. Keep Counter, Result.
// FixtureIsolated.

event void FCoverageMulticastMultipleSignal();

UCLASS()
class ACoverageMulticastMultipleActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FString Result;

	UPROPERTY()
	FCoverageMulticastMultipleSignal OnMulticast;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		// Add three listeners
		OnMulticast.AddUFunction(this, n"Listener1");
		OnMulticast.AddUFunction(this, n"Listener2");
		OnMulticast.AddUFunction(this, n"Listener3");

		// Broadcast - all three should be called
		OnMulticast.Broadcast();
	}

	UFUNCTION()
	void Listener1()
	{
		Counter += 1;
		Result += "A";
	}

	UFUNCTION()
	void Listener2()
	{
		Counter += 10;
		Result += "B";
	}

	UFUNCTION()
	void Listener3()
	{
		Counter += 100;
		Result += "C";
	}
}

int Observe_Counter_DefaultZero(ACoverageMulticastMultipleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastMultipleListeners setup: required Actor is null");
	}
	return Actor.Counter;
}

bool Observe_Result_DefaultEmpty(ACoverageMulticastMultipleActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastMultipleListeners setup: required Actor is null");
	}
	return Actor.Result.Len() == 0;
}

bool Observe_String_CopyIndependence()
{
	FString Original = "ABC";
	FString Copy = Original;
	Copy += "X";
	return Original == "ABC" && Copy == "ABCX";
}
