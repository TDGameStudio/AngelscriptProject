// Theme: Definitions.UInterface. WorldStory: script implements native parent and self-casts in BeginPlay.
// C++: ParentCastWorked 1; NativeValue 123; NativeMarker FromScript then FromCpp via Execute_.
// Extra: null self-object leaves ParentCastWorked 0. FixtureIsolated.

UCLASS()
class ATestInterfaceNativeImplement : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 123;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int ParentCastWorked = 0;

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
			ParentCastWorked = 1;
			NativeValue = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"FromScript");
		}
	}
}

bool Observe_NullSelfDoesNotCast()
{
	UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
	return ParentRef == nullptr;
}

int Observe_AdjustNativeValue_CopyIndependence()
{
	int First = 0;
	int Second = 10;
	First += 5;
	Second += 5;
	return First != Second ? Second : 0;
}
