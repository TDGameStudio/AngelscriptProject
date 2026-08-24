// Theme: Definitions.UInterface. WorldStory: parent and secondary native interfaces dispatch independently.
// C++: VerifyByPath ParentCastWorked/SecondaryCastWorked true; ParentResult 31; SecondaryResult 409;
// IndependentDispatchWorked true; NativeMarker FromParentInterface; SecondaryLabel FromSecondaryInterface.
// Extra: null self-object leaves both results 0. FixtureIsolated.

UCLASS()
class ACoverageNativeMultipleInterfaceActor : AActor, UAngelscriptNativeParentInterface, UAngelscriptNativeSecondaryInterface
{
	UPROPERTY()
	int NativeValue = 31;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int SecondaryValue = 409;

	UPROPERTY()
	FString SecondaryLabel;

	UPROPERTY()
	int ParentResult = 0;

	UPROPERTY()
	int SecondaryResult = 0;

	UPROPERTY()
	bool ParentCastWorked = false;

	UPROPERTY()
	bool SecondaryCastWorked = false;

	UPROPERTY()
	bool IndependentDispatchWorked = false;

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
	}

	UFUNCTION()
	int GetSecondaryValue() const
	{
		return SecondaryValue;
	}

	UFUNCTION()
	void SetSecondaryLabel(const FString& NewLabel)
	{
		SecondaryLabel = NewLabel;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject SelfObject = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(SelfObject);
		UAngelscriptNativeSecondaryInterface SecondaryRef = Cast<UAngelscriptNativeSecondaryInterface>(SelfObject);

		ParentCastWorked = ParentRef != nullptr;
		SecondaryCastWorked = SecondaryRef != nullptr;
		if (ParentRef == nullptr || SecondaryRef == nullptr)
		{
			return;
		}

		ParentResult = ParentRef.GetNativeValue();
		SecondaryResult = SecondaryRef.GetSecondaryValue();
		ParentRef.SetNativeMarker(n"FromParentInterface");
		SecondaryRef.SetSecondaryLabel("FromSecondaryInterface");
		IndependentDispatchWorked = ParentResult == 31 && SecondaryResult == 409;
	}
}

bool Observe_NullSelfDoesNotCastEitherInterface()
{
	UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
	UAngelscriptNativeSecondaryInterface SecondaryRef = Cast<UAngelscriptNativeSecondaryInterface>(nullptr);
	return ParentRef == nullptr && SecondaryRef == nullptr;
}

bool Observe_EmptySecondaryLabelDefault()
{
	FString EmptyLabel;
	return EmptyLabel.Len() == 0;
}
