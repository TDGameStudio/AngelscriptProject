/**
 * @version v1
 * @summary Hot-reload After: the same FStableGuidStruct name with AddedValue. C++ keeps the custom GUID from the V1 layout while the new member appears.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Hot-reload After: the same FStableGuidStruct name with AddedValue. C++ keeps the custom GUID from the V1 layout while the new member appears.
 * @topic Baseline
 */
USTRUCT()
struct FStableGuidStruct
{
	UPROPERTY()
	int Value = 1;

	UPROPERTY()
	int AddedValue = 2;
};

namespace UStructTest
{
	/**
	 * Observe the V2 member defaults.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StableGuidStructAddedMember
	 * @Inputs a default-constructed FStableGuidStruct
	 * @Return true when Value is 1 and AddedValue is 2
	 * @Boundary default values
	 */
	UFUNCTION()
	bool Defaults()
	{
		FStableGuidStruct Stable;
		if (Stable.Value != 1)
		{
			return false;
		}
		return Stable.AddedValue == 2;
	}

	/**
	 * Observe the zero write boundary on both members.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StableGuidStructAddedMember
	 * @Inputs a struct whose members were set to 0
	 * @Return true when both members read 0
	 * @Boundary zero assignment
	 */
	UFUNCTION()
	bool ZeroBoundary()
	{
		FStableGuidStruct Stable;
		Stable.Value = 0;
		Stable.AddedValue = 0;
		if (Stable.Value != 0)
		{
			return false;
		}
		return Stable.AddedValue == 0;
	}

	/**
	 * Observe that copying the struct does not alias either member.
	 *
	 * @Kind Observe
	 * @Covers UStruct.StableGuidStructAddedMember
	 * @Inputs a copy whose members were set to 0
	 * @Return true when the original keeps 1/2 and the copy is 0/0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence()
	{
		FStableGuidStruct Original;
		FStableGuidStruct Copy = Original;
		Copy.Value = 0;
		Copy.AddedValue = 0;
		if (Original.Value != 1)
		{
			return false;
		}
		if (Original.AddedValue != 2)
		{
			return false;
		}
		if (Copy.Value != 0)
		{
			return false;
		}
		return Copy.AddedValue == 0;
	}
}
/** @end */
