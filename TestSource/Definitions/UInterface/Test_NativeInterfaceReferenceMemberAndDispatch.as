// Theme: Definitions.UInterface. WorldStory: native interface member defaults null, assigns, dispatches, then resets.
// C++: VerifyByPath DefaultNullWorked/AssignmentWorked/InterfaceCallWorked/NullResetWorked true;
// NativeMarker FromInterfaceRef. NativeValue stays 42.
// Extra: empty interface ref is null; null Target does not assign. FixtureIsolated.

UCLASS()
class ACoverageNativeInterfaceReferenceActor : AActor, UAngelscriptNativeParentInterface
{
	UAngelscriptNativeParentInterface InterfaceRef;

	UPROPERTY()
	int NativeValue = 42;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	bool DefaultNullWorked = false;

	UPROPERTY()
	bool AssignmentWorked = false;

	UPROPERTY()
	bool NullResetWorked = false;

	UPROPERTY()
	bool InterfaceCallWorked = false;

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
		DefaultNullWorked = EmptyRef == nullptr;

		UObject SelfObject = this;
		InterfaceRef = Cast<UAngelscriptNativeParentInterface>(SelfObject);
		AssignmentWorked = InterfaceRef != nullptr;

		if (InterfaceRef != nullptr)
		{
			InterfaceCallWorked = InterfaceRef.GetNativeValue() == 42;
			InterfaceRef.SetNativeMarker(n"FromInterfaceRef");
		}

		InterfaceRef = nullptr;
		NullResetWorked = InterfaceRef == nullptr;
	}
}

bool Observe_EmptyNativeParentRefIsNull()
{
	UAngelscriptNativeParentInterface EmptyRef;
	return EmptyRef == nullptr;
}

bool Observe_NullObjectDoesNotAssignNativeParent()
{
	UAngelscriptNativeParentInterface Assigned = Cast<UAngelscriptNativeParentInterface>(nullptr);
	return Assigned == nullptr;
}
