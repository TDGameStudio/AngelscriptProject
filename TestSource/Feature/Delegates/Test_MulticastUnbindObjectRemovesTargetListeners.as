// Theme: Feature.Delegates. WorldStory: UnbindObject removes every listener on the target.
// C++: AngelscriptCoverageMulticastDelegateTests.cpp::MulticastUnbindObjectRemovesTargetListeners
// Spawn + BeginPlay oracle: WasBoundBeforeUnbind==true, WasBoundAfterUnbind==false,
// CountA/CountB/CountC each ==1 (second broadcast is a no-op).
// Extra: default counts 0; default WasBoundBeforeUnbind false / WasBoundAfterUnbind true.
// Keep Count* and WasBound*. FixtureIsolated.

event void FCoverageUnbindObjectSignal();

UCLASS()
class ACoverageMulticastUnbindObjectActor : AActor
{
	UPROPERTY()
	int CountA = 0;

	UPROPERTY()
	int CountB = 0;

	UPROPERTY()
	int CountC = 0;

	UPROPERTY()
	bool WasBoundBeforeUnbind = false;

	UPROPERTY()
	bool WasBoundAfterUnbind = true;

	UPROPERTY()
	FCoverageUnbindObjectSignal OnSignal;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnSignal.AddUFunction(this, n"HandlerA");
		OnSignal.AddUFunction(this, n"HandlerB");
		OnSignal.AddUFunction(this, n"HandlerC");
		WasBoundBeforeUnbind = OnSignal.IsBound();

		OnSignal.Broadcast();
		OnSignal.UnbindObject(this);
		WasBoundAfterUnbind = OnSignal.IsBound();
		OnSignal.Broadcast();
	}

	UFUNCTION()
	void HandlerA()
	{
		CountA += 1;
	}

	UFUNCTION()
	void HandlerB()
	{
		CountB += 1;
	}

	UFUNCTION()
	void HandlerC()
	{
		CountC += 1;
	}
}

int Observe_Counts_DefaultZero(ACoverageMulticastUnbindObjectActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastUnbindObjectRemovesTargetListeners setup: required Actor is null");
	}
	return Actor.CountA + Actor.CountB + Actor.CountC;
}

bool Observe_BoundFlags_Defaults(ACoverageMulticastUnbindObjectActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MulticastUnbindObjectRemovesTargetListeners setup: required Actor is null");
	}
	return !Actor.WasBoundBeforeUnbind && Actor.WasBoundAfterUnbind;
}
