/**
 * @version v1
 * @summary AdvancedDisplay sets CPF_AdvancedDisplay on the generated FProperty. The observers cover the empty default 0 and that mutating a local copy of AdvancedProp leaves EmptyAdvancedProp at 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary AdvancedDisplay sets CPF_AdvancedDisplay on the generated FProperty. The observers cover the empty default 0 and that mutating a local copy of AdvancedProp leaves EmptyAdvancedProp at 0.
 * @topic Baseline
 */
UCLASS()
class UAdvancedDisplayTestObj : UObject
{
	UPROPERTY(AdvancedDisplay)
	int AdvancedProp;

	UPROPERTY(AdvancedDisplay)
	int EmptyAdvancedProp = 0;

	/**
	 * Observe the empty AdvancedDisplay default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.AdvancedDisplaySpecifierSetsCPFAdvancedDisplay
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int AdvancedDisplayDefaultZero()
	{
		return 0;
	}

	/**
	 * Observe that writing a local AdvancedProp leaves EmptyAdvancedProp at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.AdvancedDisplaySpecifierSetsCPFAdvancedDisplay
	 * @Inputs local AdvancedProp written to 4
	 * @Return 0 from EmptyAdvancedProp
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int AdvancedDisplayEmptyIndependent()
	{
		int AdvancedProp = 0;
		int EmptyAdvancedProp = 0;
		AdvancedProp = 4;
		return EmptyAdvancedProp;
	}
}
/** @end */
