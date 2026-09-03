/**
 * A native interface member defaults null, assigns, dispatches, then resets. C++ verifies
 * DefaultNullWorked, AssignmentWorked, InterfaceCallWorked and NullResetWorked, so those
 * UPROPERTY names are part of the contract and are kept verbatim.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.NativeInterfaceReferenceMemberAndDispatch
 * @Harness UClass
 * @Tag Definitions.UInterface.NativeInterfaceReferenceMemberAndDispatch
 * @Provenance Theme: Definitions.UInterface. WorldStory: native interface member defaults null, assigns, dispatches, then resets.
 * @Provenance C++: VerifyByPath DefaultNullWorked/AssignmentWorked/InterfaceCallWorked/NullResetWorked true;
 * @Provenance NativeMarker FromInterfaceRef. NativeValue stays 42.
 * @Provenance Extra: empty interface ref is null; null Target does not assign. FixtureIsolated.
 */

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

	/**
	 * Return the native value for the parent interface.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeInterfaceReferenceMemberAndDispatch
	 * @Inputs none
	 * @Return NativeValue
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue;
	}

	/**
	 * Write the native marker for the parent interface.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeInterfaceReferenceMemberAndDispatch
	 * @Inputs a marker name
	 * @Return NativeMarker written
	 * @Param Marker the marker to store
	 */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	/**
	 * Add Delta to an in-out integer.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeInterfaceReferenceMemberAndDispatch
	 * @Inputs a delta and an integer to adjust
	 * @Return Value increased by Delta
	 * @Param Delta the amount to add
	 * @Param Value the integer adjusted in place
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta;
	}

	/**
	 * WorldStory: BeginPlay records default-null, assignment, dispatch and null-reset.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.NativeInterfaceReferenceMemberAndDispatch
	 * @Inputs none
	 * @Return the four Worked flags true and NativeMarker FromInterfaceRef
	 */
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

	/**
	 * Observe that an empty native parent ref is null.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeInterfaceReferenceMemberAndDispatch
	 * @Inputs none
	 * @Return true when a default interface ref is null
	 * @Boundary empty interface ref
	 */
	UFUNCTION()
	bool EmptyNativeParentRefIsNull()
	{
		UAngelscriptNativeParentInterface EmptyRef;
		return EmptyRef == nullptr;
	}

	/**
	 * Observe that a null object does not assign a native parent interface.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeInterfaceReferenceMemberAndDispatch
	 * @Inputs none
	 * @Return true when the cast of nullptr is null
	 * @Boundary null Target
	 */
	UFUNCTION()
	bool NullObjectDoesNotAssignNativeParent()
	{
		UAngelscriptNativeParentInterface Assigned = Cast<UAngelscriptNativeParentInterface>(nullptr);
		return Assigned == nullptr;
	}
}
