/**
 * UCLASS native interface members default null, assign, dispatch, and reset.
 * C++ verifies named flags and DispatchValue by path, so those names are kept.
 * The observers cover a null interface ref and adjusting a zero value by 2.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.UClassInterfaceMemberMatrix
 * @Harness UClass
 * @Tag Definitions.UProperty.UClassInterfaceMemberMatrix
 * @Provenance Theme: Definitions.UProperty. WorldStory: UCLASS native interface members default null, assign, dispatch, reset.
 * @Provenance C++: VerifyByPath bDefaultNull/bAssignmentWorked/bDispatchWorked/bNullResetWorked true;
 * @Provenance DispatchValue 37; AdjustedValue 42; NativeMarker FromUClassPropertyInterface.
 * @Provenance Extra: empty interface ref is null independently of NativeValue. FixtureIsolated.
 */

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

	/**
	 * Native interface getter used by the dispatch path.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassInterfaceMemberMatrix
	 * @Inputs none
	 * @Return NativeValue
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue;
	}

	/**
	 * Native interface setter used by the dispatch path.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassInterfaceMemberMatrix
	 * @Param Marker the name written to NativeMarker
	 * @Inputs Marker n"FromUClassPropertyInterface"
	 * @Return void; NativeMarker is updated
	 */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	/**
	 * Native interface adjuster used by the dispatch path.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassInterfaceMemberMatrix
	 * @Param Delta added to Value
	 * @Param Value inout integer adjusted in place
	 * @Inputs Delta 2
	 * @Return void; Value is increased
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta;
	}

	/**
	 * WorldStory: assign, dispatch, and reset the native interface member.
	 *
	 * @Kind WorldStory
	 * @Covers UProperty.UClassInterfaceMemberMatrix
	 * @Inputs none
	 * @Return bDefaultNull/bAssignmentWorked/bDispatchWorked/bNullResetWorked
	 */
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

	/**
	 * Observe that an empty interface ref is null.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassInterfaceMemberMatrix
	 * @Inputs an unset UAngelscriptNativeParentInterface
	 * @Return true when the ref is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool InterfaceMemberEmptyRefIsNull()
	{
		UAngelscriptNativeParentInterface EmptyRef;
		return EmptyRef == nullptr;
	}

	/**
	 * Observe adjusting a zero value by 2 without an interface.
	 *
	 * @Kind Observe
	 * @Covers UProperty.UClassInterfaceMemberMatrix
	 * @Inputs a local Value 0 plus 2
	 * @Return 2
	 * @Boundary empty default
	 */
	UFUNCTION()
	int InterfaceMemberAdjustFromZero()
	{
		int Value = 0;
		Value += 2;
		return Value;
	}
}
