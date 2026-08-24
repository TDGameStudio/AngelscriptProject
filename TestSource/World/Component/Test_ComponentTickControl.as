// Theme: World.Component. WorldStory: disable component tick after three ticks.
// C++: AngelscriptCoverageComponentTests.cpp::ComponentTickControl
// Oracle: VerifyByPath DisableTickCount 2 after ticks reach TestComp.TickCount >= 3.
// Extra: DisableTickCount 0, TickCount 0, AccumulatedTime 0 until BeginPlay/Tick.
// Do not spawn from script. FixtureIsolated.

UCLASS()
class UTickControlComponent : UActorComponent
{
	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	float AccumulatedTime = 0.0f;

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount++;
		AccumulatedTime += DeltaTime;
	}
}

UCLASS()
class ACoverageComponentTickControlActor : AActor
{
	UPROPERTY(DefaultComponent)
	UTickControlComponent TestComp;

	UPROPERTY()
	int DisableTickCount = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		if (TestComp.IsComponentTickEnabled())
		{
			DisableTickCount = 1;
		}
	}

	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		if (TestComp.TickCount >= 3 && DisableTickCount == 1)
		{
			TestComp.SetComponentTickEnabled(false);
			DisableTickCount = 2;
		}
	}
}
