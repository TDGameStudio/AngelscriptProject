// Theme: World.Actor. WorldStory: AActor bound methods before/after BeginPlay and instigator.
// C++: AngelscriptActorPropertyInterfaceTests.cpp::InterfaceBoundMethods
// Oracle: CheckBeforeBeginPlay 1, CheckInstigator 1, CheckAfterBeginPlay 1 on the spawned actor.
// Extra: CheckInstigator(null, null) is the empty/false instigator vector (returns 1 when both
// native instigators are unset). Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorInterfaceBoundMethods : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	UFUNCTION()
	int CheckBeforeBeginPlay()
	{
		if (!IsActorInitialized())
		{
			return 10;
		}
		if (HasActorBegunPlay())
		{
			return 20;
		}
		if (!IsHidden())
		{
			return 30;
		}
		if (!GetActorLocation().Equals(FVector(10.0, 20.0, 30.0)))
		{
			return 40;
		}
		if (!GetActorRotation().Equals(FRotator(5.0, 45.0, 15.0), 0.01))
		{
			return 50;
		}

		SetActorScale3D(FVector(2.0, 3.0, 4.0));
		SetActorTickInterval(0.25f);

		if (GetActorNameOrLabel().Len() <= 0)
		{
			return 60;
		}
		if (!IsValid(GetGameInstance()))
		{
			return 70;
		}

		return 1;
	}

	UFUNCTION()
	int CheckInstigator(APawn ExpectedPawn, AController ExpectedController)
	{
		if (GetInstigator() != ExpectedPawn)
		{
			return 100;
		}
		if (GetInstigatorController() != ExpectedController)
		{
			return 110;
		}

		return 1;
	}

	UFUNCTION()
	int CheckAfterBeginPlay()
	{
		if (!HasActorBegunPlay())
		{
			return 80;
		}
		if (!GetActorLocation().Equals(FVector(10.0, 20.0, 30.0)))
		{
			return 90;
		}

		return 1;
	}
}
