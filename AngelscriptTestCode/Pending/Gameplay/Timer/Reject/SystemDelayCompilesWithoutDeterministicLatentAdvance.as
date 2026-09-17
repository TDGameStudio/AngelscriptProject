/**
 * @version v1
 * @summary The latent SystemLibrary::Delay overload still requires FLatentActionInfo and cannot complete synchronously. C++ compiles this as the module ASCoverageTimer_SystemDelayBoundary and expects the diagnostic to name Delay.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The latent SystemLibrary::Delay overload still requires FLatentActionInfo and cannot complete synchronously. C++ compiles this as the module ASCoverageTimer_SystemDelayBoundary and expects the diagnostic to name Delay.
 * @topic Negative
 */
UCLASS()
class ACoverageTimerSystemDelayBoundaryActor : AActor
{
	/**
	 * The isolated failing program: Delay cannot be called with only a duration.
	 *
	 * @Kind CompileReject
	 * @Covers Timer.SystemDelayCompilesWithoutDeterministicLatentAdvance
	 * @Inputs none
	 * @Return does not compile; Delay requires FLatentActionInfo
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SystemLibrary::Delay(0.25f);
	}
}
/** @end */
