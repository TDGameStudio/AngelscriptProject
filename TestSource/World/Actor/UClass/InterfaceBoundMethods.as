/**
 * AActor bound methods exercised before and after BeginPlay, plus the instigator
 * pair. C++ runs the three entrypoints on the spawned actor and expects 1 from each.
 * The null instigator pair is the empty vector that still returns 1.
 *
 * @Theme World.Actor
 * @Subject Actor.InterfaceBoundMethods
 * @Harness UClass
 * @Tag World.Actor.InterfaceBoundMethods
 * @Provenance Theme: World.Actor. WorldStory: AActor bound methods before/after BeginPlay and instigator.
 * @Provenance C++: AngelscriptActorPropertyInterfaceTests.cpp::InterfaceBoundMethods
 * @Provenance Oracle: CheckBeforeBeginPlay 1, CheckInstigator 1, CheckAfterBeginPlay 1 on the spawned actor.
 * @Provenance Extra: CheckInstigator(null, null) is the empty/false instigator vector (returns 1 when both
 * @Provenance native instigators are unset). Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestActorInterfaceBoundMethods : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	USceneComponent RootScene;

	/**
	 * Exercise the bound methods that must already work before BeginPlay has run, then
	 * mutate the scale and tick interval.
	 *
	 * @Kind Observe
	 * @Covers Actor.InterfaceBoundMethods
	 * @Inputs none
	 * @Return 1 on success; 10 through 70 naming the step that failed
	 */
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

	/**
	 * Confirm that the instigator pair matches what the caller supplies.
	 *
	 * @Kind Observe
	 * @Covers Actor.InterfaceBoundMethods
	 * @Inputs the expected instigator pawn and controller
	 * @Return 1 on success; 100 or 110 naming the step that failed
	 * @Param BaselinePawn the pawn the instigator is expected to be, or null for unset
	 * @Param BaselineController the controller expected, or null for unset
	 * @Boundary null instigator pair
	 */
	UFUNCTION()
	int CheckInstigator(APawn BaselinePawn, AController BaselineController)
	{
		if (GetInstigator() != BaselinePawn)
		{
			return 100;
		}
		if (GetInstigatorController() != BaselineController)
		{
			return 110;
		}

		return 1;
	}

	/**
	 * Exercise the bound methods that only hold once BeginPlay has run.
	 *
	 * @Kind Observe
	 * @Covers Actor.InterfaceBoundMethods
	 * @Inputs none
	 * @Return 1 on success; 80 or 90 naming the step that failed
	 */
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

	/**
	 * Observe that the instigator check passes when both native instigators are unset.
	 *
	 * @Kind Observe
	 * @Covers Actor.InterfaceBoundMethods
	 * @Inputs no instigator pawn and no instigator controller
	 * @Return CheckInstigator(nullptr, nullptr), expected to be 1
	 * @Boundary null instigator pair
	 */
	UFUNCTION()
	int NullInstigatorReturnsOne()
	{
		return CheckInstigator(nullptr, nullptr);
	}
}
