// Theme: Definitions.UInterface. WorldStory: script AdjustNativeValue round-trips the int& payload.
// C++: ScriptAdjustedValue 15; C++ Execute_ later writes 27 into a separate buffer.
// Extra: null self-cast leaves ScriptAdjustedValue 0. FixtureIsolated.

UCLASS()
class ATestInterfaceNativeReferenceRoundTrip : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int ScriptAdjustedValue = 0;

	UFUNCTION()
	int GetNativeValue() const
	{
		return 0;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
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

		int Value = 10;
		ParentRef.AdjustNativeValue(5, Value);
		ScriptAdjustedValue = Value;
	}
}

bool Observe_NullSelfDoesNotAdjust()
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
