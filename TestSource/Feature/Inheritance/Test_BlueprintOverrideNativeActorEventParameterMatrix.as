// Theme: Feature.Inheritance. WorldStory native actor event BlueprintOverride parameter matrix.
// C++: AngelscriptCoverageUFunctionTests.cpp::BlueprintOverrideNativeActorEventParameterMatrix
// Oracle: OnReset -> ResetCount==1; self EndOverlap -> LastReason==22;
// ReadTransformByConstRef(10,20,12) -> LastTransformScore==42;
// Destroy -> EndPlayCount==1, DestroyedCount==1.
// Extra: empty handle null; pre-notify counters 0; self BeginOverlap LastReason==11.
// FixtureIsolated. Keep ConstructionCount/DestroyedCount/EndPlayCount/ResetCount/LastReason/LastTransformScore.

UCLASS()
class ACoverageUFunctionNativeEventActor : AActor
{
	UPROPERTY()
	int ConstructionCount = 0;

	UPROPERTY()
	int DestroyedCount = 0;

	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	int ResetCount = 0;

	UPROPERTY()
	int LastReason = -1;

	UPROPERTY()
	int LastTransformScore = 0;

	UFUNCTION(BlueprintOverride)
	void UserConstructionScript()
	{
		ConstructionCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		LastReason = OtherActor == this ? 11 : -11;
	}

	UFUNCTION(BlueprintOverride)
	void ActorEndOverlap(AActor OtherActor)
	{
		LastReason = OtherActor == this ? 22 : -22;
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		EndPlayCount += 1;
		LastReason = int(EndPlayReason);
	}

	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCount += 1;
	}

	UFUNCTION(BlueprintOverride)
	void OnReset()
	{
		ResetCount += 1;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|NativeEvents")
	void ReadTransformByConstRef(const FTransform&in Transform)
	{
		FVector Location = Transform.GetLocation();
		LastTransformScore = int(Location.X + Location.Y + Location.Z);
	}
}

bool Observe_NativeEventActor_EmptyHandleIsNull()
{
	ACoverageUFunctionNativeEventActor Actor;
	return Actor == nullptr;
}

int Observe_NativeEventActor_CountersBeforeNotify(ACoverageUFunctionNativeEventActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0126 setup: required ACoverageUFunctionNativeEventActor is null");
	}
	return Actor.DestroyedCount + Actor.EndPlayCount + Actor.ResetCount + Actor.LastTransformScore;
}

int Observe_NativeEventActor_SelfBeginOverlapReason(ACoverageUFunctionNativeEventActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0126 setup: required ACoverageUFunctionNativeEventActor is null");
	}
	Actor.ActorBeginOverlap(Actor);
	return Actor.LastReason;
}

int Observe_NativeEventActor_SelfEndOverlapReason(ACoverageUFunctionNativeEventActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0126 setup: required ACoverageUFunctionNativeEventActor is null");
	}
	Actor.ActorEndOverlap(Actor);
	return Actor.LastReason;
}

int Observe_NativeEventActor_OnResetCount(ACoverageUFunctionNativeEventActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0126 setup: required ACoverageUFunctionNativeEventActor is null");
	}
	Actor.OnReset();
	return Actor.ResetCount;
}

int Observe_NativeEventActor_ConstRefTransformScore(ACoverageUFunctionNativeEventActor Actor, FTransform Transform)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0126 setup: required ACoverageUFunctionNativeEventActor is null");
	}
	Actor.ReadTransformByConstRef(Transform);
	return Actor.LastTransformScore;
}

int Observe_NativeEventActor_ZeroTransformScoreBoundary(ACoverageUFunctionNativeEventActor Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0126 setup: required ACoverageUFunctionNativeEventActor is null");
	}
	FTransform Transform;
	Actor.ReadTransformByConstRef(Transform);
	return Actor.LastTransformScore;
}
