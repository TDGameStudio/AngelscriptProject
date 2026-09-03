/**
 * BlueprintAssignable and BlueprintCallable are unknown property specifiers on
 * script events, so this program is rejected.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.BlueprintAssignableAndCallableMetadata
 * @Harness CompileReject
 * @Tag Feature.Delegates.BlueprintAssignableAndCallableMetadata
 * @Kind CompileReject
 * @Covers Delegates.Declaration
 * @Inputs UPROPERTY(BlueprintAssignable) and UPROPERTY(BlueprintCallable) on events
 * @Return does not compile
 * @Provenance Theme: Feature.Delegates. Isolated compile-fail.
 * @Provenance C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateBlueprintAssignableAndCallableMetadata
 * @Provenance Expected diagnostic: Unknown property specifier BlueprintAssignable
 * @Provenance Expected diagnostic: Unknown property specifier BlueprintCallable
 * @Provenance DiagnosticOnly. Isolation=none.
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
