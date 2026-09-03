/**
 * Latent MoveComponentTo and RotatorTo stay compile boundaries until deterministic
 * latent advance exists. C++ compiles this as the module
 * ASCoverageTimer_LatentMovementUnsupported and expects diagnostics naming both
 * MoveComponentTo and RotatorTo.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.LatentMovementFunctionsRemainCompileBoundaries
 * @Harness CompileReject
 * @Tag Gameplay.Timer.LatentMovementFunctionsRemainCompileBoundaries
 * @Provenance Theme: Gameplay.Timer. Isolated compile-fail: latent MoveComponentTo and RotatorTo
 * @Provenance remain compile boundaries until deterministic latent advance exists.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::LatentMovementFunctionsRemainCompileBoundaries
 * @Provenance CompileAndExpectFailure. CSV WorldStory; C++ does not compile.
 * @Provenance Diagnostics: MoveComponentTo, RotatorTo.
 * @Provenance Do not add extra declarations that would make this compile.
 */

UCLASS()
class ACoverageTimerLatentMovementBoundaryActor : AActor
{
	/**
	 * The isolated failing program: MoveComponentTo and RotatorTo have no
	 * script-facing latent signatures.
	 *
	 * @Kind CompileReject
	 * @Covers Timer.LatentMovementFunctionsRemainCompileBoundaries
	 * @Inputs none
	 * @Return does not compile; MoveComponentTo and RotatorTo remain unbound
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		MoveComponentTo(nullptr, FVector::ZeroVector, FRotator::ZeroRotator, false, false, 0.25f, false, EMoveComponentAction::Move);
		RotatorTo(FRotator::ZeroRotator, FRotator(0.0f, 90.0f, 0.0f), 0.25f, 0.0f);
	}
}
