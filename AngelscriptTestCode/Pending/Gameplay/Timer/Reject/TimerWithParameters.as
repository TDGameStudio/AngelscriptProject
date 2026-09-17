/**
 * @version v1
 * @summary SetTimer by function name rejects callbacks that require parameters, so this program is rejected. C++ compiles this as the module ASCoverageTimer_WithParametersUnsupported and expects the diagnostic to name SetTimer.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary SetTimer by function name rejects callbacks that require parameters, so this program is rejected. C++ compiles this as the module ASCoverageTimer_WithParametersUnsupported and expects the diagnostic to name SetTimer.
 * @topic Negative
 */
UCLASS()
class ACoverageTimerWithParametersActor : AActor
{
	FTimerHandle ParameterHandle;

	/**
	 * Named callback that requires parameters, which SetTimer by name rejects.
	 *
	 * @Kind EventHandler
	 * @Covers Timer.TimerWithParameters
	 * @Inputs a payload value and message
	 * @Return nothing; the failing SetTimer call is what the test observes
	 * @Param Value unused payload integer
	 * @Param Message unused payload string
	 */
	UFUNCTION()
	void ParameterCallback(int Value, FString Message)
	{
	}

	/**
	 * The isolated failing program: SetTimer cannot bind a parameterized callback.
	 *
	 * @Kind CompileReject
	 * @Covers Timer.TimerWithParameters
	 * @Inputs none
	 * @Return does not compile; SetTimer rejects callbacks that require parameters
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ParameterHandle = System::SetTimer(this, n"ParameterCallback", 0.1f, false, 42, "payload");
	}
}
/** @end */
