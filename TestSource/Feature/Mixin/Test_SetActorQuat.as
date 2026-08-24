// Theme: Feature.Mixin. WorldStory AActor SetActorQuat mixin.
// C++: AngelscriptActorMixinTests.cpp::SetActorQuat
// Oracle: RunSetQuatTest()==1 (yaw 90 then 45 within 1 degree).
// Extra: empty handle null. FixtureIsolated.

UCLASS()
class ATestActorMixinSetQuat : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

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
}

bool Observe_SetActorQuat_EmptyHandleIsNull()
{
	ATestActorMixinSetQuat Actor;
	return Actor == nullptr;
}

int Observe_SetActorQuat_Run(ATestActorMixinSetQuat Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0163 setup: required ATestActorMixinSetQuat is null");
	}
	return Actor.RunSetQuatTest();
}

FRotator Observe_SetActorQuat_DefaultRotation(ATestActorMixinSetQuat Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0163 setup: required ATestActorMixinSetQuat is null");
	}
	return Actor.GetActorRotation();
}
