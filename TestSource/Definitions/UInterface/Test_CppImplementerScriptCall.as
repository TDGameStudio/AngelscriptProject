// Theme: Definitions.UInterface. WorldStory: script casts a C++ native implementer and dispatches Get/Adjust/Set.
// C++: bCastSucceeded 1; ReadValue 123; AdjustedValue 15; NativeMarker FromScript; LastAdjustmentDelta 5.
// Extra: null Target leaves bCastSucceeded/ReadValue/AdjustedValue at 0. FixtureIsolated.

UCLASS()
class ATestInterfaceNativeCppImplementerBridge : AActor
{
	UPROPERTY()
	UObject Target;

	UPROPERTY()
	int bCastSucceeded = 0;

	UPROPERTY()
	int ReadValue = 0;

	UPROPERTY()
	int AdjustedValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Target);
		if (ParentRef == nullptr)
		{
			return;
		}

		bCastSucceeded = 1;
		ReadValue = ParentRef.GetNativeValue();

		int Value = 10;
		ParentRef.AdjustNativeValue(5, Value);
		AdjustedValue = Value;

		ParentRef.SetNativeMarker(n"FromScript");
	}
}

bool Observe_NullTargetDoesNotCast()
{
	UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
	return ParentRef == nullptr;
}

int Observe_AdjustFromTenPlusFive()
{
	int Value = 10;
	Value += 5;
	return Value;
}
