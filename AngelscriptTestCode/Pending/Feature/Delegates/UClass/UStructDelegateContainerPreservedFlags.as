/**
 * @version v1
 * @summary Preserved-field flags on the container actor. Defaults are false. Toggling a copy does not change the original actor flags.
 * @topic Feature
 */
/**
 * @version root
 * @summary Preserved-field flags on the container actor. Defaults are false. Toggling a copy does not change the original actor flags.
 * @topic Baseline
 */
UCLASS()
class ACoverageStructDelegateContainerActor : AActor
{
	UPROPERTY()
	bool bArrayValuePreserved = false;

	UPROPERTY()
	bool bArrayInPreserved = false;

	UPROPERTY()
	bool bMapValuePreserved = false;

	UPROPERTY()
	bool bMapInPreserved = false;

	UPROPERTY()
	bool bKeyMapValuePreserved = false;

	UPROPERTY()
	bool bKeyMapInPreserved = false;

	UPROPERTY()
	bool bKeyMapOutPreserved = false;

	UPROPERTY()
	bool bKeyMapInoutPreserved = false;

	UPROPERTY()
	bool bKeyMapReturnPreserved = false;

	UPROPERTY()
	bool bStructMapValuePreserved = false;

	UPROPERTY()
	bool bStructMapInPreserved = false;

	UPROPERTY()
	bool bStructMapOutPreserved = false;

	UPROPERTY()
	bool bStructMapInoutPreserved = false;

	UPROPERTY()
	bool bStructMapReturnPreserved = false;

	UPROPERTY()
	bool bSetValuePreserved = false;

	UPROPERTY()
	bool bSetInPreserved = false;

	/**
	 * Observe that the representative preserved flags start false.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs this
	 * @Return true when array/map/key-map/struct-map/set value flags are false
	 * @Boundary default false
	 */
	UFUNCTION()
	bool PreservedFlagsDefaultFalse()
	{
		if (bArrayValuePreserved)
		{
			return false;
		}
		if (bMapValuePreserved)
		{
			return false;
		}
		if (bKeyMapValuePreserved)
		{
			return false;
		}
		if (bStructMapValuePreserved)
		{
			return false;
		}
		return !bSetValuePreserved;
	}

	/**
	 * Observe that assigning a bool copy leaves the original false.
	 *
	 * @Kind Observe
	 * @Covers Delegates.UStruct
	 * @Inputs Original false; Copy true
	 * @Return true when Original stays false and Copy is true
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool BoolFlagCopyIndependence()
	{
		bool Original = false;
		bool Copy = Original;
		Copy = true;
		if (Original)
		{
			return false;
		}
		return Copy;
	}
}
/** @end */
