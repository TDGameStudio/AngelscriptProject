/**
 * A script actor implements native child and parent interfaces. C++ verifies
 * after BeginPlay: ParentCastWorked==1, ChildCastWorked==1, ParentResult==7,
 * ChildResult==11 and NativeMarker==n"ParentRoute".
 *
 * @Theme Feature.Inheritance
 * @Subject Inheritance.NativeInheritedImplement
 * @Harness UClass
 * @Tag Feature.Inheritance.NativeInheritedImplement
 * @Provenance Theme: Feature.Inheritance. WorldStory script actor implements native child+parent interfaces.
 * @Provenance C++: AngelscriptInterfaceNativeTests.cpp::NativeInheritedImplement
 * @Provenance Oracle after BeginPlay: ParentCastWorked==1, ChildCastWorked==1, ParentResult==7,
 * @Provenance ChildResult==11, NativeMarker==n"ParentRoute".
 * @Provenance Extra: empty handle null; pre-BeginPlay zeros/NAME_None. FixtureIsolated.
 * @Provenance Keep ParentCastWorked/ChildCastWorked/ParentResult/ChildResult/NativeMarker.
 */

UCLASS()
class ATestInterfaceNativeInheritedImplement : AActor, UAngelscriptNativeChildInterface
{
	UPROPERTY()
	int ParentCastWorked = 0;

	UPROPERTY()
	int ChildCastWorked = 0;

	UPROPERTY()
	int ParentResult = 0;

	UPROPERTY()
	int ChildResult = 0;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	/**
	 * Native parent interface GetNativeValue implementation.
	 *
	 * @Kind Action
	 * @Covers Inheritance.NativeInheritedImplement
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
	 * @Covers Inheritance.NativeInheritedImplement
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
	 * @Covers Inheritance.NativeInheritedImplement
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
	 * @Covers Inheritance.NativeInheritedImplement
	 * @Inputs none
	 * @Return 11
	 */
	UFUNCTION()
	int GetChildValue() const
	{
		return 11;
	}

	/**
	 * WorldStory: BeginPlay casts to parent and child interfaces and records both.
	 *
	 * @Kind WorldStory
	 * @Covers Inheritance.NativeInheritedImplement
	 * @Inputs Cast to UAngelscriptNativeParentInterface and UAngelscriptNativeChildInterface
	 * @Return ParentCastWorked 1, ChildCastWorked 1, ParentResult 7, ChildResult 11, NativeMarker ParentRoute
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (ParentRef != nullptr)
		{
			ParentCastWorked = 1;
			ParentResult = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"ParentRoute");
		}

		UAngelscriptNativeChildInterface ChildRef = Cast<UAngelscriptNativeChildInterface>(Self);
		if (ChildRef != nullptr)
		{
			ChildCastWorked = 1;
			ChildResult = ChildRef.GetChildValue();
		}
	}

	/**
	 * Observe that a locally constructed actor has not begun play.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeInheritedImplement
	 * @Inputs an actor that has not begun play
	 * @Return the sum of the integer sentinels, expected to be 0
	 * @Boundary local construct
	 */
	UFUNCTION()
	int BeforeBeginPlay()
	{
		return ParentCastWorked + ChildCastWorked + ParentResult + ChildResult;
	}

	/**
	 * Observe the native inherited implementer after BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeInheritedImplement
	 * @Inputs an actor whose BeginPlay has run
	 * @Return true when parent and child casts and results match the oracle
	 */
	UFUNCTION()
	bool AfterBeginPlay()
	{
		if (ParentCastWorked != 1)
		{
			return false;
		}
		if (ChildCastWorked != 1)
		{
			return false;
		}
		if (ParentResult != 7)
		{
			return false;
		}
		if (ChildResult != 11)
		{
			return false;
		}
		return NativeMarker == n"ParentRoute";
	}

	/**
	 * Observe AdjustNativeValue(0) leaving a zero payload unchanged.
	 *
	 * @Kind Observe
	 * @Covers Inheritance.NativeInheritedImplement
	 * @Inputs AdjustNativeValue(0, Value) with Value 0
	 * @Return Value, expected to be 0
	 * @Boundary zero delta
	 */
	UFUNCTION()
	int AdjustZeroBoundary()
	{
		int Value = 0;
		AdjustNativeValue(0, Value);
		return Value;
	}
}
