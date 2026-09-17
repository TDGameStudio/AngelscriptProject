/**
 * @version v1
 * @summary UCLASS(Abstract) sets CLASS_Abstract. The generated object is not instantiated; an unset handle is null. Value remains an exposed UPROPERTY.
 * @topic Definitions
 */
/**
 * @version root
 * @summary UCLASS(Abstract) sets CLASS_Abstract. The generated object is not instantiated; an unset handle is null. Value remains an exposed UPROPERTY.
 * @topic Baseline
 */
UCLASS(Abstract)
class UAbstractTestObj : UObject
{
	UPROPERTY()
	int Value;

	/**
	 * Observe that an unset abstract handle is null.
	 *
	 * @Kind Observe
	 * @Covers UClass.Specifier
	 * @Inputs an unset UAbstractTestObj handle
	 * @Return 1 when the handle is null, otherwise 0
	 * @Boundary default null
	 */
	UFUNCTION()
	int DefaultHandleIsNull()
	{
		UAbstractTestObj Unset;
		if (Unset is null)
		{
			return 1;
		}
		return 0;
	}
}
/** @end */
