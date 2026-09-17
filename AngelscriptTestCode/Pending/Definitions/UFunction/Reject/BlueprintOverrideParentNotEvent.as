/**
 * @version v1
 * @summary BlueprintOverride requires the parent method to be a BlueprintEvent. The base NotAnEvent is only BlueprintCallable, so the child override is illegal. This file is the illegal program itself.
 * @topic Definitions
 */
/**
 * @version root
 * @summary BlueprintOverride requires the parent method to be a BlueprintEvent. The base NotAnEvent is only BlueprintCallable, so the child override is illegal. This file is the illegal program itself.
 * @topic Negative
 */
UCLASS()
class ACoverageUFunctionNonEventBaseActor : AActor
{
	/**
	 * Parent BlueprintCallable method that is not an event.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintCallable) void NotAnEvent()
	 * @Return does not compile as part of the child override
	 */
	UFUNCTION(BlueprintCallable)
	void NotAnEvent()
	{
	}
}

UCLASS()
class ACoverageUFunctionNonEventChildActor : ACoverageUFunctionNonEventBaseActor
{
	/**
	 * Illegal BlueprintOverride of a non-event parent method.
	 *
	 * @Kind CompileReject
	 * @Covers UFunction.Specifier
	 * @Inputs UFUNCTION(BlueprintOverride) void NotAnEvent()
	 * @Return does not compile
	 */
	UFUNCTION(BlueprintOverride)
	void NotAnEvent()
	{
	}
}
/** @end */
