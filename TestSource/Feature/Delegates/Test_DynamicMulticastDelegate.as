// Theme: Feature.Delegates. WorldStory multicast AddUFunction / Broadcast / Unbind.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicMulticastDelegate
// Oracle after BeginPlay: Counter==212, Result=="ABCAC".
// Extra: empty actor is null; pre-BeginPlay Counter==0 / Result empty. FixtureIsolated.

event void FCoverageDynamicMulticastEvent();

UCLASS()
class ACoverageDynamicMulticastActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FString Result;

	FCoverageDynamicMulticastEvent OnMulticastEvent;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnMulticastEvent.AddUFunction(this, n"Listener1");
		OnMulticastEvent.AddUFunction(this, n"Listener2");
		OnMulticastEvent.AddUFunction(this, n"Listener3");

		OnMulticastEvent.Broadcast();

		OnMulticastEvent.Unbind(this, n"Listener2");

		OnMulticastEvent.Broadcast();
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

bool Observe_DynamicMulticast_EmptyDefaultIsNull()
{
	ACoverageDynamicMulticastActor Actor;
	return Actor == nullptr;
}

int Observe_DynamicMulticast_CounterDefault(ACoverageDynamicMulticastActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0031 setup: required ACoverageDynamicMulticastActor is null");
	}
	return Actor.Counter;
}

FString Observe_DynamicMulticast_ResultDefault(ACoverageDynamicMulticastActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0031 setup: required ACoverageDynamicMulticastActor is null");
	}
	return Actor.Result;
}
