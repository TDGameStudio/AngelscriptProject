/**
 * @version v1
 * @summary SystemLibrary::Delay is a latent UFUNCTION whose bound signature requires FLatentActionInfo, so a duration-only call is rejected. C++ compiles this as the module ASCoverageTimer_SystemDelay and expects the diagnostic to.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary SystemLibrary::Delay is a latent UFUNCTION whose bound signature requires FLatentActionInfo, so a duration-only call is rejected. C++ compiles this as the module ASCoverageTimer_SystemDelay and expects the diagnostic to.
 * @topic Negative
 */
UCLASS()
class ACoverageTimerSystemDelayActor : AActor
{
	/**
	 * The isolated failing program: Delay has no duration-only signature.
	 *
	 * @Kind CompileReject
	 * @Covers Timer.SystemDelay
	 * @Inputs none
	 * @Return does not compile; Delay requires FLatentActionInfo
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		SystemLibrary::Delay(0.5f);
	}
}
/** @end */
