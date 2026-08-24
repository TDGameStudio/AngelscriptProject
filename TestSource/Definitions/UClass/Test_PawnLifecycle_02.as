// Theme: Definitions.UClass. WorldStory pawn BeginPlay plus supported UFUNCTION lifecycle.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::PawnLifecycle
// Oracle: BeginPlayCalled=1; SetupPlayerInputComponent/PossessedBy reflection write 1;
// UnPossessed BlueprintOverride writes UnPossessedCalled=1.
// Extra: unset handle is null; pre-BeginPlay counters stay 0. FixtureIsolated.

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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCalled = 1;
	}

	UFUNCTION()
	void SetupPlayerInputComponent(UInputComponent PlayerInputComponent)
	{
		SetupInputCalled = 1;
	}

	UFUNCTION()
	void PossessedBy(AController NewController)
	{
		PossessedByCalled = 1;
	}

	UFUNCTION(BlueprintOverride)
	void UnPossessed(AController OldController)
	{
		UnPossessedCalled = 1;
		if (OldController != nullptr)
		{
			UnPossessedOldControllerReceived = 1;
		}
	}
}

bool Observe_LifecyclePawn_EmptyDefaultIsNull()
{
	ALifecyclePawn Pawn;
	return Pawn == nullptr;
}

int Observe_LifecyclePawn_CountersDefault(ALifecyclePawn Pawn)
{
	if (Pawn == nullptr)
	{
		throw("TS-DEF-0043 setup: required ALifecyclePawn is null");
	}
	return Pawn.BeginPlayCalled + Pawn.SetupInputCalled + Pawn.PossessedByCalled
		+ Pawn.UnPossessedCalled + Pawn.UnPossessedOldControllerReceived;
}

int Observe_LifecyclePawn_PossessedByNullBoundary(ALifecyclePawn Pawn)
{
	if (Pawn == nullptr)
	{
		throw("TS-DEF-0043 setup: required ALifecyclePawn is null");
	}
	Pawn.PossessedBy(nullptr);
	return Pawn.PossessedByCalled;
}
