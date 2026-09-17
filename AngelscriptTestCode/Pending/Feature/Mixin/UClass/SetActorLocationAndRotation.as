/**
 * @version v1
 * @summary An actor that applies the SetActorLocationAndRotation mixin to (100,200,300) and yaw 90. C++ expects RunSetLocAndRotTest() to return 1. The observers cover the empty handle and the default location.
 * @topic Feature
 */
/**
 * @version root
 * @summary An actor that applies the SetActorLocationAndRotation mixin to (100,200,300) and yaw 90. C++ expects RunSetLocAndRotTest() to return 1. The observers cover the empty handle and the default location.
 * @topic Baseline
 */
UCLASS()
class ATestActorMixinSetLocAndRot : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	/**
	 * WorldStory: SetActorLocationAndRotation writes location and yaw together.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.SetActorLocationAndRotation
	 * @Inputs FVector(100,200,300), FRotator yaw 90, unused FHitResult
	 * @Return 1 when location and yaw match; 10, 20 or 30 on mismatch
	 */
	UFUNCTION()
	int RunSetLocAndRotTest()
	{
		FVector TargetLoc = FVector(100.0, 200.0, 300.0);
		FRotator TargetRot = FRotator(0.0, 90.0, 0.0);
		FHitResult Hit;

		bool bMoved = SetActorLocationAndRotation(TargetLoc, TargetRot, false, Hit, false);
		if (!bMoved)
		{
			return 10;
		}

		FVector ResultLoc = GetActorLocation();
		if (!ResultLoc.Equals(TargetLoc))
		{
			return 20;
		}

		FRotator ResultRot = GetActorRotation();
		float YawDiff = Math::Abs(ResultRot.Yaw - 90.0);
		if (YawDiff > 1.0)
		{
			return 30;
		}

		return 1;
	}

	/**
	 * Observe that an unset actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.SetActorLocationAndRotation
	 * @Inputs an unset ATestActorMixinSetLocAndRot handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestActorMixinSetLocAndRot Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the actor's location before SetActorLocationAndRotation runs.
	 *
	 * @Kind Observe
	 * @Covers Mixin.SetActorLocationAndRotation
	 * @Inputs this actor before RunSetLocAndRotTest
	 * @Return GetActorLocation()
	 * @Boundary default location
	 */
	UFUNCTION()
	FVector DefaultLocation()
	{
		return GetActorLocation();
	}
}
/** @end */
