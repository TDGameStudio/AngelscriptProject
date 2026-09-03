/**
 * An actor that applies the SetActorLocation mixin with unused hit and sweep
 * arguments. C++ expects RunSetLocSweepTest() to return 1 after moving to
 * (500,0,0) then (1000,200,0). The observers cover the empty handle and the
 * default location.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.SetActorLocationSweep
 * @Harness UClass
 * @Tag Feature.Mixin.SetActorLocationSweep
 * @Provenance Theme: Feature.Mixin. WorldStory AActor SetActorLocation mixin with unused hit/sweep args.
 * @Provenance C++: AngelscriptActorMixinTests.cpp::SetActorLocationSweep
 * @Provenance Oracle: RunSetLocSweepTest()==1 (500,0,0 then 1000,200,0).
 * @Provenance Extra: empty handle null; default location. FixtureIsolated.
 */

UCLASS()
class ATestActorMixinSetLocSweep : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	/**
	 * WorldStory: SetActorLocation moves to (500,0,0) then (1000,200,0).
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.SetActorLocationSweep
	 * @Inputs unused FHitResult and sweep flags
	 * @Return 1 when both locations match; 10, 20, 30 or 40 on mismatch
	 */
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

	/**
	 * Observe that an unset actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.SetActorLocationSweep
	 * @Inputs an unset ATestActorMixinSetLocSweep handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestActorMixinSetLocSweep Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the actor's location before SetActorLocation runs.
	 *
	 * @Kind Observe
	 * @Covers Mixin.SetActorLocationSweep
	 * @Inputs this actor before RunSetLocSweepTest
	 * @Return GetActorLocation()
	 * @Boundary default location
	 */
	UFUNCTION()
	FVector DefaultLocation()
	{
		return GetActorLocation();
	}
}
