/**
 * A native child interface exposes inherited parent methods. C++ verifies after
 * BeginPlay: ChildCastWorked==1, ChildParentResult==7, ChildAdjustedValue==29,
 * ChildOwnResult==11 and NativeMarker==n"ChildRoute".
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.ChildSurfaceIncludesParentMethods
 * @Harness UClass
 * @Tag Feature.Inheritance.ChildSurfaceIncludesParentMethods
 * @Provenance Theme: Feature.Inheritance. WorldStory native child interface exposes inherited parent methods.
 * @Provenance C++: AngelscriptInterfaceNativeInheritedChildSurfaceTests.cpp::ChildSurfaceIncludesParentMethods
 * @Provenance Oracle after BeginPlay: ChildCastWorked==1, ChildParentResult==7, ChildAdjustedValue==29,
 * @Provenance ChildOwnResult==11, NativeMarker==n"ChildRoute".
 * @Provenance Extra: empty handle null; pre-BeginPlay zeros/NAME_None. FixtureIsolated.
 * @Provenance Keep ChildCastWorked/ChildParentResult/ChildAdjustedValue/ChildOwnResult/NativeMarker.
 */

UCLASS()
class ATestInterfaceNativeInheritedChildSurface : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	int ChildCastWorked = 0;

	UPROPERTY()
	int ChildParentResult = 0;

	UPROPERTY()
	int ChildAdjustedValue = 0;

	UPROPERTY()
	int ChildOwnResult = 0;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	/**
	 * Native parent interface GetNativeValue implementation.
	 *
	 * @Kind Action
	 * @Covers Inheritance.ChildSurfaceIncludesParentMethods
	 * @Inputs none
	 * @Return 7
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return 7;
	}

	/**
	 * Native parent interface SetNativeMarker implementation.
	 *
	 * @Kind Action
	 * @Covers Inheritance.ChildSurfaceIncludesParentMethods
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
	 * Native parent interface AdjustNativeValue implementation.
	 *
	 * @Kind Action
	 * @Covers Inheritance.ChildSurfaceIncludesParentMethods
	 * @Inputs Delta and an inout Value
	 * @Return Value += Delta
	 * @Param Delta added to Value
	 * @Param Value the inout payload
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta;
	}

	/**
	 * Native child interface GetChildValue implementation.
	 *
	 * @Kind Action
	 * @Covers Inheritance.ChildSurfaceIncludesParentMethods
	 * @Inputs none
	 * @Return 11
	 */
	UFUNCTION()
	int GetChildValue() const
	{
		return 11;
	}

	/**
	 * WorldStory: BeginPlay casts to the child interface and exercises inherited methods.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.ChildSurfaceIncludesParentMethods
	 * @Inputs Cast<UAngelscriptNativeChildInterface>(this)
	 * @Return ChildCastWorked 1, ChildParentResult 7, ChildAdjustedValue 29, ChildOwnResult 11, NativeMarker ChildRoute
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeChildInterface ChildRef = Cast<UAngelscriptNativeChildInterface>(Self);
		if (ChildRef == nullptr)
		{
			return;
		}

		ChildCastWorked = 1;
		ChildParentResult = ChildRef.GetNativeValue();
		int Value = 20;
		ChildRef.AdjustNativeValue(9, Value);
		ChildAdjustedValue = Value;
		ChildOwnResult = ChildRef.GetChildValue();
		ChildRef.SetNativeMarker(n"ChildRoute");
	}

	/**
	 * Observe that a locally constructed actor has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ChildSurfaceIncludesParentMethods
	 * @Inputs an actor that has not begun play
	 * @Return the sum of the integer sentinels, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int BeforeBeginPlay()
	{
		return ChildCastWorked + ChildParentResult + ChildAdjustedValue + ChildOwnResult;
	}

	/**
	 * Observe the child surface after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ChildSurfaceIncludesParentMethods
	 * @Inputs an actor whose BeginPlay has run
	 * @Return true when the child surface matches the oracle
	 */
	UFUNCTION()
	bool AfterBeginPlay()
	{
		if (ChildCastWorked != 1)
		{
			return false;
		}
		if (ChildParentResult != 7)
		{
			return false;
		}
		if (ChildAdjustedValue != 29)
		{
			return false;
		}
		if (ChildOwnResult != 11)
		{
			return false;
		}
		return NativeMarker == n"ChildRoute";
	}

	/**
	 * Observe GetNativeValue directly on the implementer.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ChildSurfaceIncludesParentMethods
	 * @Inputs GetNativeValue()
	 * @Return 7
	 */
	UFUNCTION()
	int DirectNativeValue()
	{
		return GetNativeValue();
	}

	/**
	 * Observe the default NativeMarker.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.ChildSurfaceIncludesParentMethods
	 * @Inputs a freshly constructed actor
	 * @Return NativeMarker, expected to be NAME_None
	 * @Boundary empty marker
	 */
	UFUNCTION()
	FName EmptyMarkerDefault()
	{
		return NativeMarker;
	}
}
