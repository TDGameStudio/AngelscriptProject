/**
 * @version v1
 * @summary Complex expressions inside a literal asset block: arithmetic, a comparison that reads a property written earlier in the same block, and an FVector constructor. C++ executes TestComplexInitialization and expects 1, so.
 * @topic Feature
 */
/**
 * @version root
 * @summary Complex expressions inside a literal asset block: arithmetic, a comparison that reads a property written earlier in the same block, and an FVector constructor. C++ executes TestComplexInitialization and expects 1, so.
 * @topic Baseline
 */
UCLASS()
class UComplexAssetCarrier : UObject
{
	UPROPERTY()
	int Sum = 0;

	UPROPERTY()
	bool Condition = false;

	UPROPERTY()
	FVector Position;

	/**
	 * Read the materialized asset and check every initialized property.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetComplexInitialization
	 * @Inputs the generated GetMyComplexAsset getter
	 * @Return 1 when Sum is 60, Condition is true, and Position is (1, 2, 3); otherwise 0
	 */
	UFUNCTION()
	int TestComplexInitialization()
	{
		UComplexAssetCarrier Asset = GetMyComplexAsset();
		if (Asset == nullptr)
		{
			return 0;
		}

		if (Asset.Sum != 60)
		{
			return 0;
		}

		if (!Asset.Condition)
		{
			return 0;
		}

		if (!Asset.Position.Equals(FVector(1.0, 2.0, 3.0), 0.001))
		{
			return 0;
		}

		return 1;
	}

	/**
	 * Observe that a fresh carrier keeps the class defaults.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetComplexInitialization
	 * @Inputs a freshly constructed carrier
	 * @Return true when Sum is 0, Condition is false, and Position is the zero vector
	 * @Boundary class default
	 */
	UFUNCTION()
	bool EmptyDefault()
	{
		if (Sum != 0)
		{
			return false;
		}
		if (Condition)
		{
			return false;
		}
		return Position.Equals(FVector::ZeroVector, 0.001);
	}

	/**
	 * Observe that writing another carrier leaves this instance at its defaults.
	 *
	 * @Kind Observe
	 * @Covers Asset.AssetComplexInitialization
	 * @Inputs this carrier plus a second carrier
	 * @Return true when this still holds the defaults and the copy holds the written values
	 * @Param Copy the other carrier, mutated independently
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UComplexAssetCarrier Copy)
	{
		if (Copy is null)
		{
			throw("AssetComplexInitialization setup: required Copy is null");
		}
		Copy.Sum = 9;
		Copy.Condition = true;
		Copy.Position = FVector(4.0, 5.0, 6.0);

		if (Sum != 0)
		{
			return false;
		}
		if (Condition)
		{
			return false;
		}
		if (!Position.Equals(FVector::ZeroVector, 0.001))
		{
			return false;
		}
		if (Copy.Sum != 9)
		{
			return false;
		}
		if (!Copy.Condition)
		{
			return false;
		}
		return Copy.Position.Equals(FVector(4.0, 5.0, 6.0), 0.001);
	}
}

asset MyComplexAsset of UComplexAssetCarrier
{
	Sum = 10 + 20 + 30;
	Condition = (Sum > 50);
	Position = FVector(1.0, 2.0, 3.0);
}
/** @end */
