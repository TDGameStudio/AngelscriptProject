/**
 * @version v1
 * @summary A single-shot FTimerDelegate built from an inline lambda is rejected. Script timers bind by object and function name, not a lambda constructor.
 * @topic Feature
 */
/**
 * @version root
 * @summary A single-shot FTimerDelegate built from an inline lambda is rejected. Script timers bind by object and function name, not a lambda constructor.
 * @topic Negative
 */
UCLASS()
class ACoverageTimerDelegateLambdaActor : AActor
{
	UPROPERTY()
	int LambdaCallCount = 0;

	UPROPERTY()
	int LambdaObservedValue = 0;

	UPROPERTY()
	bool bLambdaHandleActiveAfterSet = false;

	UPROPERTY()
	int SeedValue = 41;

	FTimerHandle LambdaHandle;

	/**
	 * The isolated failing program: a single-shot lambda FTimerDelegate.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.LambdaSyntax
	 * @Inputs none
	 * @Return does not compile; FTimerDelegate has no lambda constructor
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
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
			LambdaCallCount++;
			LambdaObservedValue = SeedValue + 1;
		}), 0.05f, false);

		bLambdaHandleActiveAfterSet = SystemLibrary::IsTimerActiveHandle(LambdaHandle);
	}
}
/** @end */
