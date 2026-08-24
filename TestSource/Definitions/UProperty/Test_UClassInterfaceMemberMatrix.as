// Theme: Definitions.UProperty. WorldStory: UCLASS native interface members default null, assign, dispatch, reset.
// C++: VerifyByPath bDefaultNull/bAssignmentWorked/bDispatchWorked/bNullResetWorked true;
// DispatchValue 37; AdjustedValue 42; NativeMarker FromUClassPropertyInterface.
// Extra: empty interface ref is null independently of NativeValue. FixtureIsolated.

UCLASS()
class ACoverageUClassInterfaceMemberActor : AActor, UAngelscriptNativeParentInterface
{
	UAngelscriptNativeParentInterface InterfaceRef;

	UAngelscriptNativeParentInterface ClearedInterfaceRef;

	UPROPERTY()
	int NativeValue = 37;

	UPROPERTY()
	int DispatchValue = 0;

	UPROPERTY()
	int AdjustedValue = 0;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	bool bDefaultNull = false;

	UPROPERTY()
	bool bAssignmentWorked = false;

	UPROPERTY()
	bool bDispatchWorked = false;

	UPROPERTY()
	bool bNullResetWorked = false;

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
		UAngelscriptNativeParentInterface EmptyRef;
		bDefaultNull = EmptyRef == nullptr;

		UObject SelfObject = this;
		InterfaceRef = Cast<UAngelscriptNativeParentInterface>(SelfObject);
		bAssignmentWorked = InterfaceRef != nullptr;

		if (InterfaceRef != nullptr)
		{
			DispatchValue = InterfaceRef.GetNativeValue();
			AdjustedValue = 40;
			InterfaceRef.AdjustNativeValue(2, AdjustedValue);
			InterfaceRef.SetNativeMarker(n"FromUClassPropertyInterface");
			bDispatchWorked = DispatchValue == 37 && AdjustedValue == 42;
		}

		ClearedInterfaceRef = InterfaceRef;
		ClearedInterfaceRef = nullptr;
		bNullResetWorked = ClearedInterfaceRef == nullptr;
	}
}

bool Observe_InterfaceMember_EmptyRefIsNull()
{
	UAngelscriptNativeParentInterface EmptyRef;
	return EmptyRef == nullptr;
}

int Observe_InterfaceMember_AdjustFromZero()
{
	int Value = 0;
	Value += 2;
	return Value;
}
