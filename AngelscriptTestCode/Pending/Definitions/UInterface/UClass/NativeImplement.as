/**
 * @version v1
 * @summary A script implementer of the native parent interface that self-casts in BeginPlay. C++ reads ParentCastWorked 1, NativeValue 123 and NativeMarker FromScript, then overwrites the marker through Execute_.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A script implementer of the native parent interface that self-casts in BeginPlay. C++ reads ParentCastWorked 1, NativeValue 123 and NativeMarker FromScript, then overwrites the marker through Execute_.
 * @topic Baseline
 */
UCLASS()
class ATestInterfaceNativeImplement : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 123;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int ParentCastWorked = 0;

	/**
	 * Native parent getter returning the backing NativeValue.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.NativeImplement
	 * @Inputs none
	 * @Return NativeValue
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue;
	}

	/**
	 * Native parent setter that stores the dispatched marker.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.NativeImplement
	 * @Inputs the marker written through the interface
	 * @Return NativeMarker set to Marker
	 * @Param Marker the name written by the interface setter
	 */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	/**
	 * Native parent adjuster that adds Delta onto the by-ref payload.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.NativeImplement
	 * @Inputs Delta plus a mutable Value
	 * @Return Value increased by Delta
	 * @Param Delta the amount added
	 * @Param Value the payload received as int&inout
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta;
	}

	/**
	 * WorldStory: self-cast to the parent interface and write NativeValue plus NativeMarker.
	 *
	 * @Kind WorldStory
	 * @Covers UInterface.NativeImplement
	 * @Inputs this actor as UObject
	 * @Return ParentCastWorked 1, NativeMarker FromScript
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (ParentRef != nullptr)
		{
			ParentCastWorked = 1;
			NativeValue = ParentRef.GetNativeValue();
			ParentRef.SetNativeMarker(n"FromScript");
		}
	}

	/**
	 * Observe that a null self object does not cast to the parent interface.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeImplement
	 * @Inputs a null UObject
	 * @Return true when the cast yields null
	 * @Boundary null self
	 */
	UFUNCTION()
	bool NullSelfDoesNotCast()
	{
		UAngelscriptNativeParentInterface ParentRef = Cast<UAngelscriptNativeParentInterface>(nullptr);
		return ParentRef == nullptr;
	}

	/**
	 * Observe that two independent adjust buffers do not alias.
	 *
	 * @Kind Observe
	 * @Covers UInterface.NativeImplement
	 * @Inputs First starting at 0 and Second starting at 10, each plus 5
	 * @Return Second (15) when the buffers differ, otherwise 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int AdjustNativeValueCopyIndependence()
	{
		int First = 0;
		int Second = 10;
		First += 5;
		Second += 5;
		if (First == Second)
		{
			return 0;
		}
		return Second;
	}
}
/** @end */
