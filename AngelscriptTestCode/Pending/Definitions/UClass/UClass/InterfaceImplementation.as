/**
 * @version v1
 * @summary A native interface implementer. After BeginPlay, InterfaceCastWorked is true, NativeValue is 100, NativeMarker is FromClassFeatures, and AdjustedValue is 12. Keep those UPROPERTY names.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A native interface implementer. After BeginPlay, InterfaceCastWorked is true, NativeValue is 100, NativeMarker is FromClassFeatures, and AdjustedValue is 12. Keep those UPROPERTY names.
 * @topic Baseline
 */
UCLASS()
class ANativeInterfaceFeatureActor : AActor, UAngelscriptNativeParentInterface
{
	UPROPERTY()
	int NativeValue = 100;

	UPROPERTY()
	FName NativeMarker = NAME_None;

	UPROPERTY()
	int AdjustedValue = 0;

	UPROPERTY()
	bool InterfaceCastWorked = false;

	/**
	 * Observe GetNativeValue: it returns NativeValue.
	 *
	 * @Kind Observe
	 * @Covers UClass.Interface
	 * @Inputs NativeValue
	 * @Return NativeValue
	 */
	UFUNCTION()
	int GetNativeValue() const
	{
		return NativeValue;
	}

	/**
	 * Observe SetNativeMarker: it writes NativeMarker.
	 *
	 * @Kind Observe
	 * @Covers UClass.Interface
	 * @Param Marker Name written to NativeMarker
	 * @Inputs Marker
	 * @Return NativeMarker updated
	 */
	UFUNCTION()
	void SetNativeMarker(FName Marker)
	{
		NativeMarker = Marker;
	}

	/**
	 * Observe AdjustNativeValue: it adds Delta into the inout Value.
	 *
	 * @Kind Observe
	 * @Covers UClass.Interface
	 * @Param Delta Amount added
	 * @Param Value Inout integer updated in place
	 * @Inputs Value += Delta
	 * @Return Value increased by Delta
	 */
	UFUNCTION()
	void AdjustNativeValue(int Delta, int&inout Value)
	{
		Value += Delta;
	}

	/**
	 * WorldStory: BeginPlay casts to the native interface and writes marker/adjusted value.
	 *
	 * @Kind WorldStory
	 * @Covers UClass.Interface
	 * @Inputs Cast to UAngelscriptNativeParentInterface
	 * @Return InterfaceCastWorked, NativeMarker, AdjustedValue updated
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		UObject Self = this;
		UAngelscriptNativeParentInterface InterfaceRef = Cast<UAngelscriptNativeParentInterface>(Self);
		if (InterfaceRef != nullptr)
		{
			InterfaceCastWorked = true;
			NativeValue = InterfaceRef.GetNativeValue();
			InterfaceRef.SetNativeMarker(n"FromClassFeatures");

			int Value = 5;
			InterfaceRef.AdjustNativeValue(7, Value);
			AdjustedValue = Value;
		}
	}

	/**
	 * Observe that an unset handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Interface
	 * @Inputs an unset ANativeInterfaceFeatureActor handle
	 * @Return true when the handle is null
	 * @Boundary default null
	 */
	UFUNCTION()
	bool DefaultHandleIsNull()
	{
		ANativeInterfaceFeatureActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe NativeValue before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.Interface
	 * @Inputs a freshly constructed actor
	 * @Return NativeValue
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	int NativeValueDefault()
	{
		return NativeValue;
	}

	/**
	 * Observe InterfaceCastWorked before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UClass.Interface
	 * @Inputs a freshly constructed actor
	 * @Return true when InterfaceCastWorked is false
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool CastFlagDefaultFalse()
	{
		return InterfaceCastWorked == false;
	}

	/**
	 * Observe AdjustNativeValue with a zero delta.
	 *
	 * @Kind Observe
	 * @Covers UClass.Interface
	 * @Inputs Value=5, AdjustNativeValue(0, Value)
	 * @Return Value after the call
	 * @Boundary zero delta
	 */
	UFUNCTION()
	int AdjustNativeValueZeroDeltaBoundary()
	{
		int Value = 5;
		AdjustNativeValue(0, Value);
		return Value;
	}
}
/** @end */
