/**
 * An actor that applies the SetActorQuat mixin, first to yaw 90 then to yaw 45.
 * C++ expects RunSetQuatTest() to return 1 when each yaw is within one degree.
 * The observers cover the empty handle and the default rotation.
 *
 * @Theme Feature.Mixin
 * @Subject Mixin.SetActorQuat
 * @Harness UClass
 * @Tag Feature.Mixin.SetActorQuat
 * @Provenance Theme: Feature.Mixin. WorldStory AActor SetActorQuat mixin.
 * @Provenance C++: AngelscriptActorMixinTests.cpp::SetActorQuat
 * @Provenance Oracle: RunSetQuatTest()==1 (yaw 90 then 45 within 1 degree).
 * @Provenance Extra: empty handle null. FixtureIsolated.
 */

UCLASS()
class ATestActorMixinSetQuat : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	/**
	 * WorldStory: SetActorQuat applies yaw 90 then yaw 45.
	 *
	 * @Kind WorldStory
	 * @Covers Mixin.SetActorQuat
	 * @Inputs none
	 * @Return 1 when both yaws land within one degree; 10 or 20 on mismatch
	 */
	UFUNCTION()
	int RunSetQuatTest()
	{
		FQuat Target = FQuat(FRotator(0.0, 90.0, 0.0));
		SetActorQuat(Target);

		FRotator Result = GetActorRotation();
		float YawDiff = Math::Abs(Result.Yaw - 90.0);
		if (YawDiff > 1.0)
		{
			return 10;
		}

		SetActorQuat(FQuat(FRotator(0.0, 45.0, 0.0)));
		FRotator Result2 = GetActorRotation();
		float YawDiff2 = Math::Abs(Result2.Yaw - 45.0);
		if (YawDiff2 > 1.0)
		{
			return 20;
		}

		return 1;
	}

	/**
	 * Observe that an unset actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Mixin.SetActorQuat
	 * @Inputs an unset ATestActorMixinSetQuat handle
	 * @Return true when the handle is null
	 * @Boundary empty handle
	 */
	UFUNCTION()
	bool NullDefault()
	{
		ATestActorMixinSetQuat Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the actor's rotation before SetActorQuat runs.
	 *
	 * @Kind Observe
	 * @Covers Mixin.SetActorQuat
	 * @Inputs this actor before RunSetQuatTest
	 * @Return GetActorRotation()
	 * @Boundary default rotation
	 */
	UFUNCTION()
	FRotator DefaultRotation()
	{
		return GetActorRotation();
	}
}
