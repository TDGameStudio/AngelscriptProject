/**
 * @version v1
 * @summary Captured lambda FTimerDelegate is an unsupported System::SetTimer boundary, so this program is rejected. C++ compiles this as the module ASCoverageTimer_LambdaCaptureUnsupported and expects the diagnostic to name.
 * @topic Gameplay
 */
/**
 * @version root
 * @summary Captured lambda FTimerDelegate is an unsupported System::SetTimer boundary, so this program is rejected. C++ compiles this as the module ASCoverageTimer_LambdaCaptureUnsupported and expects the diagnostic to name.
 * @topic Negative
 */
UCLASS()
class ACoverageTimerLambdaCaptureActor : AActor
{
	FTimerHandle LambdaHandle1;
	FTimerHandle LambdaHandle2;

	/**
	 * The isolated failing program: captured lambda FTimerDelegate overloads are
	 * not bound on System::SetTimer.
	 *
	 * @Kind CompileReject
	 * @Covers Timer.TimerLambdaCapture
	 * @Inputs none
	 * @Return does not compile; FTimerDelegate lambda overloads are unsupported
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Print("TimerLambdaCapture: Testing lambda callbacks with captured variables");

		int LocalValue = 42;
		FString LocalMessage = "Hello from lambda";

		/**
		 * Isolated failing lambda: first captured-locals timer delegate.
		 *
		 * @Kind CompileReject
		 * @Covers Timer.TimerLambdaCapture
		 * @Inputs captured LocalValue 42 and LocalMessage
		 * @Return does not compile; FTimerDelegate is not a SetTimer overload
		 */
		System::SetTimer(FTimerDelegate(this, function()
		{
			Print("Lambda timer callback executed");
			Print("Captured LocalValue: " + LocalValue);
			Print("Captured LocalMessage: " + LocalMessage);
		}), 0.1f, false);

		int Value1 = 100;
		int Value2 = 200;

		/**
		 * Isolated failing lambda: second captured-int timer delegate.
		 *
		 * @Kind CompileReject
		 * @Covers Timer.TimerLambdaCapture
		 * @Inputs captured Value1 100
		 * @Return does not compile; FTimerDelegate is not a SetTimer overload
		 */
		LambdaHandle1 = System::SetTimer(FTimerDelegate(this, function()
		{
			Print("Lambda1 with captured value: " + Value1);
		}), 0.2f, false);

		/**
		 * Isolated failing lambda: third captured-int timer delegate.
		 *
		 * @Kind CompileReject
		 * @Covers Timer.TimerLambdaCapture
		 * @Inputs captured Value2 200
		 * @Return does not compile; FTimerDelegate is not a SetTimer overload
		 */
		LambdaHandle2 = System::SetTimer(FTimerDelegate(this, function()
		{
			Print("Lambda2 with captured value: " + Value2);
		}), 0.3f, false);
	}
}
/** @end */
