/**
 * The latent SystemLibrary::Delay overload still requires FLatentActionInfo and
 * cannot complete synchronously. C++ compiles this as the module
 * ASCoverageTimer_SystemDelayBoundary and expects the diagnostic to name Delay.
 *
 * @Theme Gameplay.Timer
 * @Subject Timer.SystemDelayCompilesWithoutDeterministicLatentAdvance
 * @Harness CompileReject
 * @Tag Gameplay.Timer.SystemDelayCompilesWithoutDeterministicLatentAdvance
 * @Provenance Theme: Gameplay.Timer. Isolated compile-fail: SystemLibrary::Delay latent overload
 * @Provenance requires FLatentActionInfo and cannot complete synchronously.
 * @Provenance C++: AngelscriptCoverageTimerTests.cpp::SystemDelayCompilesWithoutDeterministicLatentAdvance
 * @Provenance CompileAndExpectFailure. CSV WorldStory; C++ does not compile. Diagnostic: Delay.
 * @Provenance Do not add extra declarations that would make this compile.
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
