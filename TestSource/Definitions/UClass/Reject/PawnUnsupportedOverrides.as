/**
 * Native-only APawn BlueprintOverride methods are rejected. SetupPlayerInputComponent
 * and PossessedBy do not exist in the script-visible Pawn superclass, and
 * UnPossessed does not match the supported signature.
 *
 * @Theme Definitions.UClass
 * @Subject UClass.PawnUnsupportedOverrides
 * @Harness CompileReject
 * @Tag Definitions.UClass.PawnUnsupportedOverrides
 * @Kind CompileReject
 * @Covers UClass.BlueprintOverride
 * @Inputs SetupPlayerInputComponent, PossessedBy, UnPossessed BlueprintOverride methods
 * @Return does not compile; diagnostic "BlueprintOverride method SetupPlayerInputComponent / PossessedBy do not exist in superclass Pawn"
 * @Provenance Theme: Definitions.UClass. NegativeDiagnostic: APawn native-only BlueprintOverride surface.
 * @Provenance C++: AngelscriptCoverageClassLifecycleTests.cpp::PawnLifecycle CompileAndExpectFailure.
 * @Provenance Expected diagnostic: BlueprintOverride SetupPlayerInputComponent / PossessedBy do not exist
 * @Provenance in superclass Pawn; UnPossessed / ReceiveUnpossessed signature mismatch.
 * @Provenance Isolate this failing program. DiagnosticOnly.
 */

UCLASS()
class ALifecyclePawnUnsupportedOverrides : APawn
{
	/**
	 * Illegal BlueprintOverride of SetupPlayerInputComponent.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Param PlayerInputComponent Input component
	 * @Inputs SetupPlayerInputComponent override on APawn
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void SetupPlayerInputComponent(UInputComponent PlayerInputComponent)
	{
	}

	/**
	 * Illegal BlueprintOverride of PossessedBy.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Param NewController Possessing controller
	 * @Inputs PossessedBy override on APawn
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void PossessedBy(AController NewController)
	{
	}

	/**
	 * Illegal BlueprintOverride of UnPossessed.
	 *
	 * @Kind CompileReject
	 * @Covers UClass.BlueprintOverride
	 * @Inputs UnPossessed override on APawn
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void UnPossessed()
	{
	}
}
