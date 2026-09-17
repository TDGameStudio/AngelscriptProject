/**
 * @version v1
 * @summary BlueprintAssignable and BlueprintCallable are unknown property specifiers on script events, so this program is rejected.
 * @topic Feature
 */
/**
 * @version root
 * @summary BlueprintAssignable and BlueprintCallable are unknown property specifiers on script events, so this program is rejected.
 * @topic Negative
 */
/**
 * A parameterless multicast event.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageBlueprintNoParamEvent();

/**
 * A multicast event carrying an int payload.
 *
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs int NewValue
 * @Return nothing when broadcast
 */
event void FCoverageBlueprintValueEvent(int NewValue);

UCLASS()
class ACoverageBlueprintDelegateMetadataActor : AActor
{
	UPROPERTY()
	int EventCount = 0;

	UPROPERTY(BlueprintAssignable)
	FCoverageBlueprintNoParamEvent OnCustomEvent;

	UPROPERTY(BlueprintCallable)
	FCoverageBlueprintValueEvent OnValueChanged;

	/**
	 * Binds both handlers and broadcasts both events.
	 *
	 * @Kind CompileReject
	 * @Covers Delegates.Declaration
	 * @Inputs none
	 * @Return does not compile; the specifiers are unknown
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnCustomEvent.AddUFunction(this, n"HandleCustomEvent");
		OnValueChanged.AddUFunction(this, n"HandleValueChanged");

		OnCustomEvent.Broadcast();
		OnValueChanged.Broadcast(50);
	}

	/**
	 * Records the parameterless broadcast.
	 *
	 * @Covers Delegates.Declaration
	 * @Inputs none
	 * @Return nothing; the count gains 1
	 */
	UFUNCTION()
	void HandleCustomEvent()
	{
		EventCount++;
	}

	/**
	 * Records the value broadcast.
	 *
	 * @Covers Delegates.Declaration
	 * @Inputs NewValue the payload
	 * @Return nothing; the count gains NewValue
	 */
	UFUNCTION()
	void HandleValueChanged(int NewValue)
	{
		EventCount += NewValue;
	}
}
/** @end */
