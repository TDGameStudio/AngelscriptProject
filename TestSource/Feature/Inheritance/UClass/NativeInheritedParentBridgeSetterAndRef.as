/**
 * Parent Execute_ bridge through a child implementation. C++ verifies after
 * Execute_SetNativeMarker("FromParentExecute") and AdjustNativeValue(9) on 20:
 * NativeMarker==n"FromParentExecute", AdjustedValue==29, ParentAdjustedValue==29.
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.NativeInheritedParentBridgeSetterAndRef
 * @Harness UClass
 * @Tag Feature.Inheritance.NativeInheritedParentBridgeSetterAndRef
 * @Provenance Theme: Feature.Inheritance. WorldStory parent Execute_ bridge through child implementation.
 * @Provenance C++: AngelscriptInterfaceNativeTests.cpp::NativeInheritedParentBridgeSetterAndRef
 * @Provenance Oracle after C++ Execute_SetNativeMarker("FromParentExecute") + AdjustNativeValue(9) on 20:
 * @Provenance NativeMarker==n"FromParentExecute", AdjustedValue==29, ParentAdjustedValue==29.
 * @Provenance Extra: empty handle null; defaults NAME_None/0; AdjustNativeValue(0) stays 20.
 * @Provenance FixtureIsolated. Keep NativeMarker/ParentAdjustedValue.
 */

UCLASS()
class ATestInterfaceNativeInheritedParentBridge : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int ParentAdjustedValue = 0;

	/**
	 * Native parent interface GetNativeValue implementation.
	 *
	 * @Kind Action
	 * @Covers Inheritance.NativeInheritedParentBridgeSetterAndRef
	 * @Inputs none
	 * @Return 0
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return 0;
	}

	/**
	 * Native parent interface SetNativeMarker implementation.
	 *
	 * @Kind Action
	 * @Covers Inheritance.NativeInheritedParentBridgeSetterAndRef
	 * @Inputs the marker name
	 * @Return NativeMarker == Marker
	 * @Param Marker stored on NativeMarker
	 */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	/**
	 * Native parent interface AdjustNativeValue implementation that also stores ParentAdjustedValue.
	 *
	 * @Kind Action
	 * @Covers Inheritance.NativeInheritedParentBridgeSetterAndRef
	 * @Inputs Delta and an inout Value
	 * @Return Value += Delta; ParentAdjustedValue = Value
	 * @Param Delta added to Value
	 * @Param Value the inout payload
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta;
		ParentAdjustedValue = Value;
	}

	/**
	 * Native child interface GetChildValue implementation.
	 *
	 * @Kind Action
	 * @Covers Inheritance.NativeInheritedParentBridgeSetterAndRef
	 * @Inputs none
	 * @Return 11
	 */
	UFUNCTION()
	int GetChildValue() const
	{
		return 11;
	}

	/**
	 * Observe the default NativeMarker.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeInheritedParentBridgeSetterAndRef
	 * @Inputs a freshly constructed actor
	 * @Return NativeMarker, expected to be NAME_None
	 * @Boundary local construct
	 */
	UFUNCTION()
	FName DefaultMarker()
	{
		return NativeMarker;
	}

	/**
	 * Observe AdjustNativeValue(9) on 20 writing 29.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeInheritedParentBridgeSetterAndRef
	 * @Inputs AdjustNativeValue(9, Value) with Value 20
	 * @Return Value, expected to be 29
	 */
	UFUNCTION()
	int ScriptAdjustFrom20()
	{
		int Value = 20;
		AdjustNativeValue(9, Value);
		return Value;
	}

	/**
	 * Observe ParentAdjustedValue after AdjustNativeValue(9) on 20.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeInheritedParentBridgeSetterAndRef
	 * @Inputs AdjustNativeValue(9, Value) with Value 20
	 * @Return ParentAdjustedValue, expected to be 29
	 */
	UFUNCTION()
	int PersistedAdjusted()
	{
		int Value = 20;
		AdjustNativeValue(9, Value);
		return ParentAdjustedValue;
	}

	/**
	 * Observe SetNativeMarker(n"FromParentExecute") writing NativeMarker.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeInheritedParentBridgeSetterAndRef
	 * @Inputs SetNativeMarker(n"FromParentExecute")
	 * @Return NativeMarker, expected to be n"FromParentExecute"
	 */
	UFUNCTION()
	FName SetFromParentExecute()
	{
		SetNativeMarker(n"FromParentExecute");
		return NativeMarker;
	}

	/**
	 * Observe AdjustNativeValue(0) leaving 20 unchanged.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeInheritedParentBridgeSetterAndRef
	 * @Inputs AdjustNativeValue(0, Value) with Value 20
	 * @Return Value, expected to be 20
	 * @Boundary zero delta
	 */
	UFUNCTION()
	int ZeroDeltaBoundary()
	{
		int Value = 20;
		AdjustNativeValue(0, Value);
		return Value;
	}
}
