/**
 * @version v1
 * @summary Transient sets CPF_Transient. The observers cover the empty default 0 and that mutating a local CachedValue leaves EmptyCachedValue at 0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Transient sets CPF_Transient. The observers cover the empty default 0 and that mutating a local CachedValue leaves EmptyCachedValue at 0.
 * @topic Baseline
 */
UCLASS()
class UTransientTestObj : UObject
{
	UPROPERTY(Transient)
	int CachedValue;

	UPROPERTY(Transient)
	int EmptyCachedValue = 0;

	/**
	 * Observe the empty Transient default.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TransientSpecifierSetsCPFTransient
	 * @Inputs none
	 * @Return 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	int TransientDefaultZero()
	{
		return 0;
	}

	/**
	 * Observe that writing a local CachedValue leaves EmptyCachedValue at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.TransientSpecifierSetsCPFTransient
	 * @Inputs local CachedValue written to 8
	 * @Return 0 from EmptyCachedValue
	 * @Boundary copy independence
	 */
	UFUNCTION()
	int TransientEmptyIndependent()
	{
		int CachedValue = 0;
		int EmptyCachedValue = 0;
		CachedValue = 8;
		return EmptyCachedValue;
	}
}
/** @end */
