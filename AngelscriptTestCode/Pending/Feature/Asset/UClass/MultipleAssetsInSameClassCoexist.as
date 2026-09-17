/**
 * @version v1
 * @summary Two literal assets of the same class coexist as independent objects. C++ compiles the module and finds FirstAsset and SecondAsset, so those asset names and the UPROPERTY name Marker are part of the contract and are kept.
 * @topic Feature
 */
/**
 * @version root
 * @summary Two literal assets of the same class coexist as independent objects. C++ compiles the module and finds FirstAsset and SecondAsset, so those asset names and the UPROPERTY name Marker are part of the contract and are kept.
 * @topic Baseline
 */
UCLASS()
class UMultiAssetOwner : UObject
{
	UPROPERTY()
	int Marker = 0;

	/**
	 * Read FirstAsset's Marker through the generated getter.
	 *
	 * @Kind Observe
	 * @Covers Asset.MultipleAssetsInSameClassCoexist
	 * @Inputs the generated GetFirstAsset getter
	 * @Return 10 when the asset is present, otherwise -1
	 */
	UFUNCTION()
	int FirstAssetMarker()
	{
		UMultiAssetOwner Asset = GetFirstAsset();
		if (Asset == nullptr)
		{
			return -1;
		}
		return Asset.Marker;
	}

	/**
	 * Read SecondAsset's Marker through the generated getter.
	 *
	 * @Kind Observe
	 * @Covers Asset.MultipleAssetsInSameClassCoexist
	 * @Inputs the generated GetSecondAsset getter
	 * @Return 20 when the asset is present, otherwise -1
	 */
	UFUNCTION()
	int SecondAssetMarker()
	{
		UMultiAssetOwner Asset = GetSecondAsset();
		if (Asset == nullptr)
		{
			return -1;
		}
		return Asset.Marker;
	}

	/**
	 * Observe that the two materialized assets are distinct objects.
	 *
	 * @Kind Observe
	 * @Covers Asset.MultipleAssetsInSameClassCoexist
	 * @Inputs GetFirstAsset and GetSecondAsset
	 * @Return true when both assets are non-null and they are not the same object
	 */
	UFUNCTION()
	bool AssetsIndependent()
	{
		UMultiAssetOwner First = GetFirstAsset();
		UMultiAssetOwner Second = GetSecondAsset();
		if (First == nullptr)
		{
			return false;
		}
		if (Second == nullptr)
		{
			return false;
		}
		return First != Second;
	}

	/**
	 * Observe that a fresh owner keeps the class default of 0.
	 *
	 * @Kind Observe
	 * @Covers Asset.MultipleAssetsInSameClassCoexist
	 * @Inputs a freshly constructed owner
	 * @Return the class default Marker, which is 0
	 * @Boundary class default
	 */
	UFUNCTION()
	int EmptyDefault()
	{
		return Marker;
	}

	/**
	 * Observe that writing another owner leaves this instance at 0.
	 *
	 * @Kind Observe
	 * @Covers Asset.MultipleAssetsInSameClassCoexist
	 * @Inputs this owner plus a second owner
	 * @Return true when this still holds 0 and the copy holds 3
	 * @Param Copy the other owner, mutated independently
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool CopyIndependence(UMultiAssetOwner Copy)
	{
		if (Copy is null)
		{
			throw("MultipleAssetsInSameClassCoexist setup: required Copy is null");
		}
		Copy.Marker = 3;

		if (Marker != 0)
		{
			return false;
		}
		return Copy.Marker == 3;
	}
}

asset FirstAsset of UMultiAssetOwner
{
	Marker = 10;
}

asset SecondAsset of UMultiAssetOwner
{
	Marker = 20;
}
/** @end */
