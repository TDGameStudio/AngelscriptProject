/**
 * @version v1
 * @summary Latent MoveComponentTo and RotatorTo stay compile boundaries until deterministic latent advance exists. C++ compiles this as the module ASCoverageTimer_LatentMovementUnsupported and expects diagnostics naming both.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Latent MoveComponentTo and RotatorTo stay compile boundaries until deterministic latent advance exists. C++ compiles this as the module ASCoverageTimer_LatentMovementUnsupported and expects diagnostics naming both.
 * @topic Negative
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
/** @end */
