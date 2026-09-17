/**
 * @version v1
 * @summary Hot-reload Before: FReloadableCapabilityStruct publishes opEquals, Hash, and ToString. C++ freezes this identical+hash capability set on the original version.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Hot-reload Before: FReloadableCapabilityStruct publishes opEquals, Hash, and ToString. C++ freezes this identical+hash capability set on the original version.
 * @topic Baseline
 */
USTRUCT()
struct FReloadableCapabilityStruct
{
	UPROPERTY()
	int Value = 1;

	/**
	 * Compare two instances by Value.
	 *
	 * @Covers UStruct.ReloadableCapabilityStructWithHash
	 * @Inputs another FReloadableCapabilityStruct
	 * @Return true when Value matches
	 * @Param Other the other instance
	 */
	bool opEquals(const FReloadableCapabilityStruct&in Other) const
	{
		return Value == Other.Value;
	}

	/**
	 * Hash the instance as Value + 7.
	 *
	 * @Covers UStruct.ReloadableCapabilityStructWithHash
	 * @Inputs none
	 * @Return uint32(Value + 7)
	 */
	uint32 Hash() const
	{
		return uint32(Value + 7);
	}

	/**
	 * Format the capability set as a fixed string.
	 *
	 * @Covers UStruct.ReloadableCapabilityStructWithHash
	 * @Inputs none
	 * @Return "HasAllCapabilities"
	 */
	FString ToString() const
	{
		return "HasAllCapabilities";
	}
};

namespace UStructTest
{
	/**
	 * Observe the V1 defaults, hash, ToString, and equality.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ReloadableCapabilityStructWithHash
	 * @Inputs two default-constructed instances
	 * @Return true when Value is 1, Hash is 8, ToString matches, and they compare equal
	 */
	UFUNCTION()
	bool NominalCapabilities()
	{
		FReloadableCapabilityStruct First;
		FReloadableCapabilityStruct Second;
		if (First.Value != 1)
		{
			return false;
		}
		if (First.Hash() != uint32(8))
		{
			return false;
		}
		if (First.ToString() != "HasAllCapabilities")
		{
			return false;
		}
		return First.opEquals(Second);
	}

	/**
	 * Observe the zero-value hash boundary.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ReloadableCapabilityStructWithHash
	 * @Inputs a struct whose Value was set to 0
	 * @Return true when Hash is 7 and ToString is unchanged
	 * @Boundary zero value
	 */
	UFUNCTION()
	bool ZeroHashBoundary()
	{
		FReloadableCapabilityStruct Empty;
		Empty.Value = 0;
		if (Empty.Hash() != uint32(7))
		{
			return false;
		}
		return Empty.ToString() == "HasAllCapabilities";
	}

	/**
	 * Observe copy independence and inequality after mutation.
	 *
	 * @Kind Observe
	 * @Covers UStruct.ReloadableCapabilityStructWithHash
	 * @Inputs a copy whose Value was set to 0
	 * @Return true when the original stays 1, the copy is 0, and they compare unequal
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependenceAndInequality()
	{
		FReloadableCapabilityStruct Original;
		FReloadableCapabilityStruct Copy = Original;
		Copy.Value = 0;
		if (Original.Value != 1)
		{
			return false;
		}
		if (Copy.Value != 0)
		{
			return false;
		}
		return !Original.opEquals(Copy);
	}
}
/** @end */
