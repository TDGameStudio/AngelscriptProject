// Theme: Definitions.UInterface. WorldStory: self-cast native parent interface dispatches Get/Set/Adjust.
// C++: VerifyByPath SelfCastWorked/SelfDispatchWorked true; AdjustedValue 72; GetNativeValue 64;
// NativeMarker FromSingleInterfaceCast.
// Extra: failed self-cast leaves AdjustedValue 0. FixtureIsolated.

UCLASS()
class ACoverageNativeSingleInterfaceActor : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 64;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int AdjustedValue = 0;

	UPROPERTY()
	bool SelfCastWorked = false;

	UPROPERTY()
	bool SelfDispatchWorked = false;

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
		Value += Delta + NativeValue;
		AdjustedValue = Value;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject SelfObject = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(SelfObject);
		SelfCastWorked = ParentRef != nullptr;
		if (ParentRef == nullptr)
		{
			return;
		}

		int Value = 3;
		ParentRef.AdjustNativeValue(5, Value);
		ParentRef.SetNativeMarker(n"FromSingleInterfaceCast");
		SelfDispatchWorked = ParentRef.GetNativeValue() == 64 && Value == 72;
	}
}

bool Observe_NullSelfObjectDoesNotCast()
{
	UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
	return ParentRef == nullptr;
}

int Observe_AdjustNativeValue_EmptyStart(int NativeValue)
{
	int Value = 0;
	Value += 5 + NativeValue;
	return Value;
}
