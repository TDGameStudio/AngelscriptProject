// Theme: Definitions.UClass. NegativeDiagnostic: APawn native-only BlueprintOverride surface.
// C++: AngelscriptCoverageClassLifecycleTests.cpp::PawnLifecycle CompileAndExpectFailure.
// Expected diagnostic: BlueprintOverride SetupPlayerInputComponent / PossessedBy do not exist
// in superclass Pawn; UnPossessed / ReceiveUnpossessed signature mismatch.
// Isolate this failing program. DiagnosticOnly.

UCLASS()
class ALifecyclePawnUnsupportedOverrides : APawn
{
	UFUNCTION(BlueprintOverride)
	void SetupPlayerInputComponent(UInputComponent PlayerInputComponent)
	{
	}

	UFUNCTION(BlueprintOverride)
	void PossessedBy(AController NewController)
	{
	}

	UFUNCTION(BlueprintOverride)
	void UnPossessed()
	{
	}
}
