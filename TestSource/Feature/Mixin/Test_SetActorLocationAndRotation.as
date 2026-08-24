// Theme: Feature.Mixin. WorldStory AActor SetActorLocationAndRotation mixin.
// C++: AngelscriptActorMixinTests.cpp::SetActorLocationAndRotation
// Oracle: RunSetLocAndRotTest()==1 (location 100,200,300 and yaw 90).
// Extra: empty handle null; default transform. FixtureIsolated.

UCLASS()
class ATestActorMixinSetLocAndRot : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

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
}

bool Observe_SetLocAndRot_EmptyHandleIsNull()
{
	ATestActorMixinSetLocAndRot Actor;
	return Actor == nullptr;
}

int Observe_SetLocAndRot_Run(ATestActorMixinSetLocAndRot Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0165 setup: required ATestActorMixinSetLocAndRot is null");
	}
	return Actor.RunSetLocAndRotTest();
}

FVector Observe_SetLocAndRot_DefaultLocation(ATestActorMixinSetLocAndRot Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-FEAT-0165 setup: required ATestActorMixinSetLocAndRot is null");
	}
	return Actor.GetActorLocation();
}
