/**
 * A script UAnimNotifyState subclass registers UPROPERTY defaults. C++ verifies
 * WindowStrength, WindowPriority and bFiresOnTick, so those names are kept. The
 * observers cover the empty strength 0 and that a false tick flag is independent
 * of the true default.
 *
 * @Theme Definitions.UProperty
 * @Subject UProperty.SubclassRegistersUPropertyAndDerivesFromUAnimNotifyState
 * @Harness UClass
 * @Tag Definitions.UProperty.SubclassRegistersUPropertyAndDerivesFromUAnimNotifyState
 * @Provenance Theme: Definitions.UProperty. Positive: script UAnimNotifyState subclass registers UPROPERTY defaults.
 * @Provenance C++: class is child of UAnimNotifyState; WindowStrength FDoubleProperty; WindowPriority FIntProperty;
 * @Provenance bFiresOnTick CDO true. Extra: false tick flag and 0 strength are independent of the defaults.
 * @Provenance DefaultSafe.
 */

UCLASS()
class UFunctionalAnimNotifyState_ScriptWindow : UAnimNotifyState
{
	UPROPERTY(EditAnywhere)
	float WindowStrength = 0.5;

	UPROPERTY(EditAnywhere)
	int32 WindowPriority = 3;

	UPROPERTY(EditAnywhere)
	bool bFiresOnTick = true;

	/**
	 * Observe the empty strength boundary.
	 *
	 * @Kind Observe
	 * @Covers UProperty.SubclassRegistersUPropertyAndDerivesFromUAnimNotifyState
	 * @Inputs none
	 * @Return 0.0
	 * @Boundary empty strength
	 */
	UFUNCTION()
	float AnimNotifyStateEmptyStrengthBoundary()
	{
		return 0.0;
	}

	/**
	 * Observe that a false tick flag is independent of the true default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.SubclassRegistersUPropertyAndDerivesFromUAnimNotifyState
	 * @Inputs local bFiresOnTick true and EmptyTick false
	 * @Return true when the true default does not alias the false flag
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool AnimNotifyStateFalseTickIndependent()
	{
		bool bFiresOnTick = true;
		bool EmptyTick = false;
		if (!bFiresOnTick)
		{
			return false;
		}
		return !EmptyTick;
	}
}
