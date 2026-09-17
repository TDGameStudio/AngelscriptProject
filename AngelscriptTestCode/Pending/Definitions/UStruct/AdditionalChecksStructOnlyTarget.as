/**
 * @version v1
 * @summary A struct-only module skips post-reload extra compile checks. C++ compiles FAdditionalChecksStructOnlyTarget and expects PostReloadCount==0.
 * @topic Definitions
 */
/**
 * @version root
 * @summary A struct-only module skips post-reload extra compile checks. C++ compiles FAdditionalChecksStructOnlyTarget and expects PostReloadCount==0.
 * @topic Baseline
 */
USTRUCT()
struct FAdditionalChecksStructOnlyTarget
{
	UPROPERTY()
	int Value = 19;
}

namespace UStructTest
{
	/**
	 * Observe the default Value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.AdditionalChecksStructOnlyTarget
	 * @Inputs a default-constructed FAdditionalChecksStructOnlyTarget
	 * @Return 19
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultValue()
	{
		FAdditionalChecksStructOnlyTarget Target;
		return Target.Value;
	}

	/**
	 * Observe the zero write boundary.
	 *
	 * @Kind Observe
	 * @Covers UStruct.AdditionalChecksStructOnlyTarget
	 * @Inputs a struct whose Value was set to 0
	 * @Return 0
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		FAdditionalChecksStructOnlyTarget Target;
		Target.Value = 0;
		return Target.Value;
	}

	/**
	 * Observe that copying the struct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.AdditionalChecksStructOnlyTarget
	 * @Inputs a copy whose Value was set to 0
	 * @Return true when the original stays 19 and the copy is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FAdditionalChecksStructOnlyTarget Original;
		FAdditionalChecksStructOnlyTarget Copy = Original;
		Copy.Value = 0;
		if (Original.Value != 19)
		{
			return false;
		}
		return Copy.Value == 0;
	}
}
/** @end */
