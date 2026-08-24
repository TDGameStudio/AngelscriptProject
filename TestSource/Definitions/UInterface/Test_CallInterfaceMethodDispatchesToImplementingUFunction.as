// Theme: Definitions.UInterface. WorldStory: production dispatch bridge routes Get/Adjust/Set to the UFunction.
// C++: ScriptObservedValue 55; ScriptAdjustedValue 15; ScriptObservedMarker BridgeHit.
// Extra: null self-cast leaves observed ints 0 and marker NAME_None. FixtureIsolated.

UCLASS()
class AInterfaceDispatchBridgeCarrier : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int ScriptObservedValue = 0;

	UPROPERTY()
	int ScriptAdjustedValue = 0;

	UPROPERTY()
	FName ScriptObservedMarker = NAME_None;

	UFUNCTION()
	int GetNativeValue() const
	{
		return 55;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		ScriptObservedMarker = Marker;
	}

	UFUNCTION()
	void AdjustNativeValue(int Delta, int& Value)
	{
		Value += Delta;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (ParentRef == nullptr)
		{
			return;
		}

		ScriptObservedValue = ParentRef.GetNativeValue();

		int Value = 10;
		ParentRef.AdjustNativeValue(5, Value);
		ScriptAdjustedValue = Value;

		ParentRef.SetNativeMarker(n"BridgeHit");
	}
}

bool Observe_NullSelfDoesNotDispatch()
{
	UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
	return ParentRef == nullptr;
}

int Observe_AdjustNativeValue_EmptyStart()
{
	int Value = 0;
	Value += 5;
	return Value;
}
