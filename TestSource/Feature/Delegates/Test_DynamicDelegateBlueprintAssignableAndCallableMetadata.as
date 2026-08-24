// Theme: Feature.Delegates. Isolated compile-fail.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateBlueprintAssignableAndCallableMetadata
// Expected diagnostic: Unknown property specifier BlueprintAssignable
// Expected diagnostic: Unknown property specifier BlueprintCallable
// DiagnosticOnly. Isolation=none.

event void FCoverageBlueprintNoParamEvent();
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

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnCustomEvent.AddUFunction(this, n"HandleCustomEvent");
		OnValueChanged.AddUFunction(this, n"HandleValueChanged");

		OnCustomEvent.Broadcast();
		OnValueChanged.Broadcast(50);
	}

	UFUNCTION()
	void HandleCustomEvent()
	{
		EventCount++;
	}

	UFUNCTION()
	void HandleValueChanged(int NewValue)
	{
		EventCount += NewValue;
	}
}
