// Theme: Definitions.UInterface. WorldStory: script AdjustNativeValue also persists call count and last value.
// C++ after BeginPlay: ScriptAdjustedValue 15, AdjustCallCount 1, LastAdjustedValue 15.
// C++ Execute_ later: CppAdjustedValue 27, AdjustCallCount 2, LastAdjustedValue 27.
// Extra: null self-cast leaves counts at 0. FixtureIsolated.

UCLASS()
class ATestInterfaceNativeReferenceRoundTripCppBridgeState : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int ScriptAdjustedValue = 0;

	UPROPERTY()
	int AdjustCallCount = 0;

	UPROPERTY()
	int LastAdjustedValue = 0;

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
		AdjustCallCount += 1;
		LastAdjustedValue = Value;
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

bool Observe_NullSelfDoesNotCountAdjust()
{
	UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
	return ParentRef == nullptr;
}

int Observe_AdjustNativeValue_IndependentBuffers()
{
	int ScriptBuffer = 10;
	int CppBuffer = 22;
	ScriptBuffer += 5;
	CppBuffer += 5;
	return ScriptBuffer == 15 && CppBuffer == 27 ? 1 : 0;
}
