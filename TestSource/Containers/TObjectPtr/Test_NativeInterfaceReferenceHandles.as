// Theme: Containers.TObjectPtr. WorldStory: native parent interface handle dispatch.
// C++ VerifyByPath: DefaultNullWorked, CastAssignmentWorked, InterfaceDispatchWorked,
// InterfaceParameterWorked, NullResetWorked true; ParameterValue=46; NativeMarker set.
// Extra: InterfaceRef default null; NativeValue stays 37. FixtureIsolated.

UCLASS()
class ACoverageHandlesNativeInterfaceRefsActor : AActor, UAngelscriptNativeParentInterface
{
	UAngelscriptNativeParentInterface InterfaceRef;

	UAngelscriptNativeParentInterface ClearedInterfaceRef;

	UPROPERTY()
	int NativeValue = 37;

	UPROPERTY()
	int ParameterValue = 0;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	bool DefaultNullWorked = false;

	UPROPERTY()
	bool CastAssignmentWorked = false;

	UPROPERTY()
	bool InterfaceDispatchWorked = false;

	UPROPERTY()
	bool InterfaceParameterWorked = false;

	UPROPERTY()
	bool NullResetWorked = false;

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

	void AcceptInterface(UAngelscriptNativeParentInterface InInterface)
	{
		if (InInterface != nullptr)
		{
			int Adjusted = 5;
			InInterface.AdjustNativeValue(4, Adjusted);
			ParameterValue = InInterface.GetNativeValue() + Adjusted;
			InterfaceParameterWorked = ParameterValue == 46;
		}
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UAngelscriptNativeParentInterface EmptyRef;
		DefaultNullWorked = EmptyRef == nullptr;

		UObject SelfObject = this;
		InterfaceRef = Cast<UAngelscriptNativeParentInterface>(SelfObject);
		CastAssignmentWorked = InterfaceRef != nullptr;

		if (InterfaceRef != nullptr)
		{
			InterfaceDispatchWorked = InterfaceRef.GetNativeValue() == 37;
			InterfaceRef.SetNativeMarker(n"FromNativeInterfaceHandle");
			AcceptInterface(InterfaceRef);
		}

		ClearedInterfaceRef = InterfaceRef;
		ClearedInterfaceRef = nullptr;
		NullResetWorked = ClearedInterfaceRef == nullptr;
	}
}
