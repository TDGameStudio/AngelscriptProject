/**
 * @version v1
 * @summary A script UAnimNotify subclass registers UPROPERTY defaults. C++ verifies the class is a child of UAnimNotify and that EffectTag/EffectStrength reflect, so those names are kept. The observers cover NAME_None versus.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A script UAnimNotify subclass registers UPROPERTY defaults. C++ verifies the class is a child of UAnimNotify and that EffectTag/EffectStrength reflect, so those names are kept. The observers cover NAME_None versus.
 * @topic Baseline
 */
UCLASS()
class UFunctionalAnimNotify_ScriptEffect : UAnimNotify
{
	UPROPERTY(EditAnywhere)
	FName EffectTag = n"Default";

	UPROPERTY(EditAnywhere)
	float EffectStrength = 1.0;

	/**
	 * Observe that NAME_None is independent of the Default tag.
	 *
	 * @Kind Observe
	 * @Covers UProperty.SubclassRegistersUPropertyAndDerivesFromUAnimNotify
	 * @Inputs n"Default" versus NAME_None
	 * @Return true when the two names differ
	 * @Boundary empty tag
	 */
	UFUNCTION()
	bool AnimNotifyEmptyTagIndependent()
	{
		FName EffectTag = n"Default";
		FName EmptyTag = NAME_None;
		return EffectTag != EmptyTag;
	}

	/**
	 * Observe the empty strength boundary.
	 *
	 * @Kind Observe
	 * @Covers UProperty.SubclassRegistersUPropertyAndDerivesFromUAnimNotify
	 * @Inputs none
	 * @Return 0.0
	 * @Boundary empty strength
	 */
	UFUNCTION()
	float AnimNotifyEmptyStrengthBoundary()
	{
		return 0.0;
	}
}
/** @end */
