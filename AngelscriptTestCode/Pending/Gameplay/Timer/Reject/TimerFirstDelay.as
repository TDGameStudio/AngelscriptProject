/**
 * @version v1
 * @summary The native SetTimer first-delay overload is unbound, so this program is rejected. C++ compiles this as the module ASCoverageTimer_FirstDelayUnsupported and expects the diagnostic to name SetTimer.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary The native SetTimer first-delay overload is unbound, so this program is rejected. C++ compiles this as the module ASCoverageTimer_FirstDelayUnsupported and expects the diagnostic to name SetTimer.
 * @topic Negative
 */
UCLASS()
class ACoverageTimerFirstDelayActor : AActor
{
	FTimerHandle FirstDelayHandle;

	/**
	 * Named callback the unbound first-delay SetTimer overload would fire into.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerFirstDelay
	 * @Inputs none
	 * @Return nothing; the failing SetTimer call is what the test observes
	 */
	UFUNCTION()
	void FirstDelayCallback()
	{
	}

	/**
	 * The isolated failing program: SetTimer has no first-delay overload.
	 *
	 * @Kind CompileReject
	 * @Covers Timer.TimerFirstDelay
	 * @Inputs none
	 * @Return does not compile; SetTimer rejects the native first-delay overload
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FirstDelayHandle = System::SetTimer(this, n"FirstDelayCallback", 1.0f, true, 2.0f);
	}
}
/** @end */
