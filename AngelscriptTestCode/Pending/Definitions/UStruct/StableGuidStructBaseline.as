/**
 * @version v1
 * @summary Hot-reload Before: FStableGuidStruct publishes a stable custom GUID. C++ keeps that GUID across a same-name reload. This file is the V1 layout.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Hot-reload Before: FStableGuidStruct publishes a stable custom GUID. C++ keeps that GUID across a same-name reload. This file is the V1 layout.
 * @topic Baseline
 */
USTRUCT()
struct FStableGuidStruct
{
	UPROPERTY()
	int Value = 1;
};

namespace UStructTest
{
	/**
	 * Observe the V1 default Value.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StableGuidStructBaseline
	 * @Inputs a default-constructed FStableGuidStruct
	 * @Return 1
	 * @Boundary default value
	 */
	UFUNCTION()
	int DefaultValue()
	{
		FStableGuidStruct Stable;
		return Stable.Value;
	}

	/**
	 * Observe the zero write boundary.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StableGuidStructBaseline
	 * @Inputs a struct whose Value was set to 0
	 * @Return 0
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	int ZeroBoundary()
	{
		FStableGuidStruct Stable;
		Stable.Value = 0;
		return Stable.Value;
	}

	/**
	 * Observe that copying the struct does not alias it.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StableGuidStructBaseline
	 * @Inputs a copy whose Value was set to 0
	 * @Return true when the original stays 1 and the copy is 0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FStableGuidStruct Original;
		FStableGuidStruct Copy = Original;
		Copy.Value = 0;
		if (Original.Value != 1)
		{
			return false;
		}
		return Copy.Value == 0;
	}
}
/** @end */
