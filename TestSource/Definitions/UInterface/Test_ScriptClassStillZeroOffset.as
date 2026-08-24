// Theme: Definitions.UInterface. WorldStory: script-implemented native parent keeps PointerOffset 0.
// C++: bSelfCastSucceeded 1; DispatchedValue 321; NativeMarker FromSelf.
// Extra: null self-object leaves bSelfCastSucceeded 0. FixtureIsolated.

UCLASS()
class ATestInterfaceNativePointerOffsetScriptZero : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 321;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int bSelfCastSucceeded = 0;

	UPROPERTY()
	int DispatchedValue = 0;

	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue;
	}

	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
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
		if (ParentRef != nullptr)
		{
			bSelfCastSucceeded = 1;
			DispatchedValue = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"FromSelf");
		}
	}
}

bool Observe_NullSelfDoesNotCast()
{
	UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
	return ParentRef == nullptr;
}

int Observe_AdjustNativeValue_ZeroStart()
{
	int Value = 0;
	Value += 5;
	return Value;
}
