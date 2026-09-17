/**
 * @version v1
 * @summary EditAnywhere on a plain non-USTRUCT member currently compiles because C++ wraps the failure in #if 0 (structural-validation-absent). The observers cover the default 0 and copy independence after mutate.
 * @topic Definitions
 */
/**
 * @version root
 * @summary EditAnywhere on a plain non-USTRUCT member currently compiles because C++ wraps the failure in #if 0 (structural-validation-absent). The observers cover the default 0 and copy independence after mutate.
 * @topic Baseline
 */
struct FPlain
{
	UPROPERTY(EditAnywhere)
	int X = 0;
}

namespace UPropertyTest
{
	/**
	 * Observe the default X of a plain struct.
	 *
	 * @Kind Observe
	 * @Covers UProperty.EditAnywhereOnPlainStruct
	 * @Inputs a default-constructed FPlain
	 * @Return true when X is 0
	 */
	UFUNCTION()
	bool PlainDefault()
	{
		FPlain Value;
		return Value.X == 0;
	}

	/**
	 * Observe that a second default-constructed FPlain is also 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.EditAnywhereOnPlainStruct
	 * @Inputs a default-constructed FPlain
	 * @Return true when X is 0
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool PlainEmptyDefault()
	{
		FPlain Value;
		return Value.X == 0;
	}

	/**
	 * Observe that mutating a copy leaves the original at 0.
	 *
	 * @Kind Observe
	 * @Covers UProperty.EditAnywhereOnPlainStruct
	 * @Inputs a default-constructed FPlain copied then mutated
	 * @Return true when Original.X is 0 and Copy.X is 7
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool PlainCopyIndependence()
	{
		FPlain Original;
		FPlain Copy = Original;
		Copy.X = 7;
		if (Original.X != 0)
		{
			return false;
		}
		return Copy.X == 7;
	}
}
/** @end */
