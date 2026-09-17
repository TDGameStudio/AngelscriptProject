/**
 * @version v1
 * @summary Constructing an FTimerDelegate from an inline lambda and passing it to SetTimer is rejected. Script timers bind by object and function name.
 * @topic Feature
 */
/**
 * @version root
 * @summary Constructing an FTimerDelegate from an inline lambda and passing it to SetTimer is rejected. Script timers bind by object and function name.
 * @topic Negative
 */
UCLASS()
class ACoverageTimerDelegateLambdaActor : AActor
{
	UPROPERTY()
	int LambdaCapturedValue = 0;

	FTimerHandle LambdaHandle;

	/**
	 * The isolated failing program: a lambda FTimerDelegate passed to SetTimer.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.LambdaSyntax
	 * @Inputs none
	 * @Return does not compile; FTimerDelegate has no lambda constructor
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		int CapturedValue = 42;
		/**
		 * Illegal lambda passed to FTimerDelegate.
		 *
		 * @Kind CompileReject
		 * @Covers Delegates.LambdaSyntax
		 * @Inputs none
		 * @Return does not compile
		 */
		LambdaHandle = System::SetTimer(FTimerDelegate(this, function()
		{
			LambdaCapturedValue = CapturedValue;
		}), 0.1f, false);
	}
}
/** @end */
