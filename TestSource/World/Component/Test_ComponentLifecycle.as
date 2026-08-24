// Theme: World.Component. C++ compiles this actor then VerifyByPath LifecycleStage 2 and
// TickCount 2. CSV marks NegativeDiagnostic; the method is a lifecycle oracle, not a compile-fail
// (unsupported tick-surface probes are separate C++ helpers, not this block).
// C++: AngelscriptCoverageComponentTests.cpp::ComponentLifecycle
// Extra: LifecycleStage 0 and TickCount 0 until BeginPlay/Tick. Do not spawn from script.
// FixtureIsolated.

UCLASS()
class ULifecycleTestComponent : UActorComponent
{
	UPROPERTY()
	int LifecycleStage = 0;

	UPROPERTY()
	int TickCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		LifecycleStage = 2;
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (LifecycleStage == 2)
		{
			TickCount++;
		}
	}

	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason EndPlayReason)
	{
		if (LifecycleStage == 2)
		{
			LifecycleStage = 3;
		}
	}
}

UCLASS()
class ACoverageComponentLifecycleActor : AActor
{
	UPROPERTY(DefaultComponent)
	ULifecycleTestComponent TestComp;
}
