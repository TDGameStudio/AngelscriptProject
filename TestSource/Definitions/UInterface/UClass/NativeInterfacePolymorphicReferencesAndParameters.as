/**
 * Parent and child implementers dispatch through one collector. C++ verifies the
 * assignment/dispatch flags and PolymorphicSum 57, so those UPROPERTY names are part of
 * the contract and are kept verbatim.
 *
 * @Theme Definitions.UInterface
 * @Subject UInterface.NativeInterfacePolymorphicReferencesAndParameters
 * @Harness UClass
 * @Tag Definitions.UInterface.NativeInterfacePolymorphicReferencesAndParameters
 * @Provenance Theme: Definitions.UInterface. WorldStory: parent/child implementers dispatch through one collector.
 * @Provenance C++: VerifyByPath FirstAssigned/SecondAssigned/PolymorphicDispatchWorked/InterfaceParameterWorked/ChildCastWorked true;
 * @Provenance PolymorphicSum 57; ParameterAdjustedValue 50; ChildInterfaceValue 223.
 * @Provenance Extra: missing FirstSource/SecondSource leaves flags false and sums 0. FixtureIsolated.
 */

UCLASS()
class ACoverageNativeInterfaceBaseActor : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 11;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	/**
	 * Return the native parent value.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
	 * @Inputs none
	 * @Return NativeValue
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue;
	}

	/**
	 * Write the native parent marker.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
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
	 * Add Delta plus NativeValue to an in-out integer.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
	 * @Inputs a delta and an integer to adjust
	 * @Return Value increased by Delta + NativeValue
	 * @Param Delta the amount to add
	 * @Param Value the integer adjusted in place
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta + NativeValue;
	}
}

UCLASS()
class ACoverageNativeInterfaceChildActor : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	int NativeValue = 23;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	/**
	 * Return the child-interface value.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
	 * @Inputs none
	 * @Return 223
	 */
	UFUNCTION()
	int GetChildValue() const
	{
		return 223;
	}

	/**
	 * Return the native parent value from the child implementer.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
	 * @Inputs none
	 * @Return 46
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return 46;
	}

	/**
	 * Write the native parent marker.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
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
	 * Add Delta plus NativeValue to an in-out integer.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
	 * @Inputs a delta and an integer to adjust
	 * @Return Value increased by Delta + NativeValue
	 * @Param Delta the amount to add
	 * @Param Value the integer adjusted in place
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta + NativeValue;
	}
}

UCLASS()
class ACoverageNativeInterfacePolymorphicCollector : AActor
{
	UPROPERTY()
	UObject FirstSource;

	UPROPERTY()
	UObject SecondSource;

	UAngelscriptNativeParentInterface CurrentRef;

	UPROPERTY()
	int PolymorphicSum = 0;

	UPROPERTY()
	int ParameterAdjustedValue = 0;

	UPROPERTY()
	int ChildInterfaceValue = 0;

	UPROPERTY()
	bool FirstAssigned = false;

	UPROPERTY()
	bool SecondAssigned = false;

	UPROPERTY()
	bool PolymorphicDispatchWorked = false;

	UPROPERTY()
	bool InterfaceParameterWorked = false;

	UPROPERTY()
	bool ChildCastWorked = false;

	/**
	 * Capture a parent interface, adjust a local integer, and accumulate ParameterAdjustedValue.
	 *
	 * @Kind Action
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
	 * @Inputs a parent interface
	 * @Return ParameterAdjustedValue increased; InterfaceParameterWorked when the sum is 50
	 * @Param InInterface the parent interface to capture
	 */
	void CaptureParent(UAngelscriptNativeParentInterface InInterface)
	{
		if (InInterface == nullptr)
		{
			return;
		}

		int Value = 5;
		InInterface.AdjustNativeValue(3, Value);
		ParameterAdjustedValue += Value;
		InterfaceParameterWorked = ParameterAdjustedValue == 50;
	}

	/**
	 * WorldStory: BeginPlay casts both sources, sums GetNativeValue, captures both, and reads the child.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
	 * @Inputs none
	 * @Return PolymorphicSum 57 and the dispatch flags true when both sources are present
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UAngelscriptNativeParentInterface FirstRef = Cast<UAngelscriptNativeParentInterface>(FirstSource);
		UAngelscriptNativeParentInterface SecondRef = Cast<UAngelscriptNativeParentInterface>(SecondSource);

		FirstAssigned = FirstRef != nullptr;
		SecondAssigned = SecondRef != nullptr;
		if (FirstRef == nullptr || SecondRef == nullptr)
		{
			return;
		}

		PolymorphicSum = FirstRef.GetNativeValue() + SecondRef.GetNativeValue();
		PolymorphicDispatchWorked = PolymorphicSum == 57;

		CurrentRef = SecondRef;
		CaptureParent(FirstRef);
		CaptureParent(CurrentRef);

		UAngelscriptNativeChildInterface ChildRef = Cast<UAngelscriptNativeChildInterface>(SecondSource);
		ChildCastWorked = ChildRef != nullptr;
		if (ChildRef != nullptr)
		{
			ChildInterfaceValue = ChildRef.GetChildValue();
		}
	}

	/**
	 * Observe that null sources do not assign parent interfaces.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
	 * @Inputs none
	 * @Return true when both casts of nullptr are null
	 * @Boundary missing sources
	 */
	UFUNCTION()
	bool NullSourcesDoNotAssign()
	{
		UAngelscriptNativeParentInterface FirstRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
		UAngelscriptNativeParentInterface SecondRef = Cast<UAngelscriptNativeParentInterface>(nullptr);

		if (FirstRef != nullptr)
		{
			return false;
		}
		return SecondRef == nullptr;
	}

	/**
	 * Observe that capturing a null parent interface is a no-op.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeInterfacePolymorphicReferencesAndParameters
	 * @Inputs none
	 * @Return true when an empty parent ref is null
	 * @Boundary null capture
	 */
	UFUNCTION()
	bool NullCaptureParentIsNoOp()
	{
		UAngelscriptNativeParentInterface EmptyRef;
		return EmptyRef == nullptr;
	}
}
