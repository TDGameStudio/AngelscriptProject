/**
 * Pawn BeginPlay plus supported UFUNCTION lifecycle. BeginPlayCalled is 1;
 * SetupPlayerInputComponent/PossessedBy reflection write 1; UnPossessed
 * BlueprintOverride writes UnPossessedCalled=1. Keep those UPROPERTY names.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.PawnLifecycle
 * @Harness UClass
 * @Tag Definitions.UClass.PawnLifecycle
 * @Provenance Theme: Definitions.UClass. WorldStory pawn BeginPlay plus supported UFUNCTION lifecycle.
 * @Provenance C++: AngelscriptCoverageClassLifecycleTests.cpp::PawnLifecycle
 * @Provenance Oracle: BeginPlayCalled=1; SetupPlayerInputComponent/PossessedBy reflection write 1;
 * @Provenance UnPossessed BlueprintOverride writes UnPossessedCalled=1.
 * @Provenance Extra: unset handle is null; pre-BeginPlay counters stay 0. FixtureIsolated.
 */

UCLASS()
class ALifecyclePawn : APawn
{
	UPROPERTY()
	int SetupInputCalled = 0;

	UPROPERTY()
	int PossessedByCalled = 0;

	UPROPERTY()
	int UnPossessedCalled = 0;

	UPROPERTY()
	int UnPossessedOldControllerReceived = 0;

	UPROPERTY()
	int BeginPlayCalled = 0;

	/**
	 * WorldStory: BeginPlay records that the pawn entered play.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Pawn
	 * @Inputs none
	 * @Return BeginPlayCalled = 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCalled = 1;
	}

	/**
	 * Observe SetupPlayerInputComponent: it records that input was set up.
	 *
	 * @Kind Observe
	 * @Covers UClass.Pawn
	 * @Param PlayerInputComponent Input component
	 * @Inputs none
	 * @Return SetupInputCalled = 1
	 */
	UFUNCTION()
	void SetupPlayerInputComponent(UInputComponent PlayerInputComponent)
	{
		SetupInputCalled = 1;
	}

	/**
	 * Observe PossessedBy: it records that a controller possessed the pawn.
	 *
	 * @Kind Observe
	 * @Covers UClass.Pawn
	 * @Param NewController Possessing controller
	 * @Inputs none
	 * @Return PossessedByCalled = 1
	 */
	UFUNCTION()
	void PossessedBy(AController NewController)
	{
		PossessedByCalled = 1;
	}

	/**
	 * WorldStory: UnPossessed records the old controller when present.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Pawn
	 * @Param OldController Previous controller
	 * @Inputs OldController
	 * @Return UnPossessedCalled = 1; UnPossessedOldControllerReceived = 1 when OldController is non-null
	 */
	UFUNCTION(BlueprintOverride)
	void UnPossessed(AController OldController)
	{
		UnPossessedCalled = 1;
		if (OldController != nullptr)
		{
			UnPossessedOldControllerReceived = 1;
		}
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Pawn
	 * @Inputs an unset ALifecyclePawn handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ALifecyclePawn Pawn;
		return Pawn == nullptr;
	}

	/**
	 * Observe lifecycle counters before play.
	 *
	 * @Kind Observe
	 * @Covers UClass.Pawn
	 * @Inputs a freshly constructed pawn
	 * @Return the sum of the five lifecycle counters
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int CountersDefault()
	{
		return BeginPlayCalled + SetupInputCalled + PossessedByCalled
			+ UnPossessedCalled + UnPossessedOldControllerReceived;
	}

	/**
	 * Observe PossessedBy with a null controller.
	 *
	 * @Kind Observe
	 * @Covers UClass.Pawn
	 * @Inputs PossessedBy(nullptr)
	 * @Return PossessedByCalled
	 * @Boundary null controller
	 */
	UFUNCTION()
	int PossessedByNullBoundary()
	{
		PossessedBy(nullptr);
		return PossessedByCalled;
	}
}
