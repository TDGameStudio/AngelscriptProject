/**
 * SystemLibrary::Delay is a latent UFUNCTION whose bound signature requires
 * FLatentActionInfo, so a duration-only call is rejected. C++ compiles this as
 * the module ASCoverageTimer_SystemDelay and expects the diagnostic to name Delay.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.SystemDelay
 * @Harness CompileReject
 * @Tag Gameplay.Timer.SystemDelay
 * @Provenance Theme: Gameplay.Timer. Isolated compile-fail: SystemLibrary::Delay is latent
 * @Provenance and requires FLatentActionInfo; a duration-only call does not resolve.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::SystemDelay CompileAndExpectFailure.
 * @Provenance CSV WorldStory; C++ does not compile. Diagnostic: Delay.
 * @Provenance Do not add extra declarations that would make this compile.
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
