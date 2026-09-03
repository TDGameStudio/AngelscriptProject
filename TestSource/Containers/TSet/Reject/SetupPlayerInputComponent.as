/**
 * Not TSet API. Kept here until moved.
 *
 * @Theme Containers.TSet
 * @Subject Misplaced
 * @Harness CompileReject
 * @Tag Containers.TSet.SetupPlayerInputComponent
 * @Kind CompileReject
 * @Covers SetupPlayerInputComponent
 * @Inputs BlueprintOverride SetupPlayerInputComponent
 * @Return does not compile; BlueprintOverride method SetupPlayerInputComponent
 */

// Theme: Containers.TSet. NegativeDiagnostic: SetupPlayerInputComponent BlueprintOverride.
// C++: AngelscriptCoverageInputTests.cpp::SetupPlayerInputComponent CompileAndExpectFailure
// Expected diagnostic: "BlueprintOverride method SetupPlayerInputComponent".
// Isolate the failing pawn. DiagnosticOnly.

UCLASS()
class AInputSetupPawn : APawn
{
	UPROPERTY()
	bool InputComponentReceived = false;

	UPROPERTY()
	bool InputComponentValid = false;

	UFUNCTION(BlueprintOverride)
	void SetupPlayerInputComponent(UInputComponent PlayerInputComponent)
	{
		InputComponentReceived = true;
		InputComponentValid = (PlayerInputComponent != nullptr);
	}
}
