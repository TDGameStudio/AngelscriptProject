// Theme: Feature.Mixin. WorldStory AActor SetActorLocation mixin with unused hit/sweep args.
// C++: AngelscriptActorMixinTests.cpp::SetActorLocationSweep
// Oracle: RunSetLocSweepTest()==1 (500,0,0 then 1000,200,0).
// Extra: empty handle null; default location. FixtureIsolated.

UCLASS()
class ATestActorMixinSetLocSweep : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UFUNCTION()
	int RunSetLocSweepTest()
	{
		FHitResult Hit;
		bool bMoved = SetActorLocation(FVector(500.0, 0.0, 0.0), false, Hit, false);
		if (!bMoved)
		{
			return 10;
		}

		FVector NewLoc = GetActorLocation();
		if (!NewLoc.Equals(FVector(500.0, 0.0, 0.0)))
		{
			return 20;
		}

		FHitResult Hit2;
		bool bMoved2 = SetActorLocation(FVector(1000.0, 200.0, 0.0), false, Hit2, true);
		if (!bMoved2)
		{
			return 30;
		}

		FVector FinalLoc = GetActorLocation();
		if (!FinalLoc.Equals(FVector(1000.0, 200.0, 0.0)))
		{
			return 40;
		}

		return 1;
	}
}

bool Observe_SetLocSweep_EmptyHandleIsNull()
{
	ATestActorMixinSetLocSweep Actor;
	return Actor == nullptr;
}

int Observe_SetLocSweep_Run(ATestActorMixinSetLocSweep Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0164 setup: required ATestActorMixinSetLocSweep is null");
	}
	return Actor.RunSetLocSweepTest();
}

FVector Observe_SetLocSweep_DefaultLocation(ATestActorMixinSetLocSweep Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0164 setup: required ATestActorMixinSetLocSweep is null");
	}
	return Actor.GetActorLocation();
}
