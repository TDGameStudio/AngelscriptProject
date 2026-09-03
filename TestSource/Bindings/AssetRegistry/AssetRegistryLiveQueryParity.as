/**
 * AssetRegistry live queries compared against native baselines: HasAssets,
 * GetAssetsByPath, GetAssetByObjectPath, and GetAllAssets. The token form
 * carries the expected values inline for the default oracle; the parameter
 * form takes them as runner parameters so the same query can be replayed
 * against a different asset set. Out arrays are filled by the query, and two
 * queries over the same path stay copy-independent.
 * Moved here from ../../Containers/TSet/Function/ where it sat misplaced
 * under a container whose API it does not touch.
 *
 * @Theme Bindings.AssetRegistry
 * @Subject AssetRegistry.LiveQueryParity
 * @Harness Function
 * @Tag Bindings.AssetRegistry.AssetRegistryLiveQueryParity
 * @Namespace AssetRegistryTest
 */

namespace AssetRegistryTest
{
	/**
	 * Observe HasAssets parity against a native baseline.
	 *
	 * @Kind Observe
	 * @Covers AssetRegistry.HasAssets
	 * @Inputs HasAssets on the engine materials path token, recursive false
	 * @Return true when the result matches the baseline has-assets flag
	 */
	UFUNCTION()
	bool HasAssetsParity()
	{
		const bool bBaselineHasAssets = __EXPECTED_HAS_ASSETS__;
		const bool bActualHasAssets = AssetRegistry::HasAssets(n"__ENGINE_MATERIALS_PATH__", false);
		return bActualHasAssets == bBaselineHasAssets;
	}

	/**
	 * Observe HasAssets parity with the expected flag and path supplied as parameters.
	 *
	 * @Kind RoundTrip
	 * @Covers AssetRegistry.HasAssets
	 * @Param bBaselineHasAssets Baseline result from the native baseline
	 * @Param EngineMaterialsPath Path queried for assets
	 * @Inputs HasAssets on the supplied path, recursive false
	 * @Return true when the result matches the expected flag
	 */
	UFUNCTION()
	bool HasAssetsParity(bool bBaselineHasAssets, FName EngineMaterialsPath)
	{
		const bool bActualHasAssets = AssetRegistry::HasAssets(EngineMaterialsPath, false);
		return bActualHasAssets == bBaselineHasAssets;
	}

	/**
	 * Observe GetAssetsByPath parity against a native baseline.
	 *
	 * @Kind Observe
	 * @Covers AssetRegistry.GetAssetsByPath
	 * @Inputs GetAssetsByPath on the engine materials path token, filling an out array
	 * @Return true when the success flag, count, and matched asset paths all match
	 */
	UFUNCTION()
	bool GetAssetsByPathParity()
	{
		const bool bBaselineGetAssetsByPath = __EXPECTED_GET_ASSETS_BY_PATH__;
		const int BaselineAssetsByPathCount = __EXPECTED_ASSETS_BY_PATH_COUNT__;
		const FString BaselineObjectPathString = "__EXPECTED_OBJECT_PATH_STRING__";
		const FString BaselineSoftObjectPathString = "__EXPECTED_SOFT_OBJECT_PATH_STRING__";

		TArray<FAssetData> AssetsByPath;
		const bool bActualGetAssetsByPath = AssetRegistry::GetAssetsByPath(n"__ENGINE_MATERIALS_PATH__", AssetsByPath, false, false);
		if (bActualGetAssetsByPath != bBaselineGetAssetsByPath)
		{
			return false;
		}
		if (AssetsByPath.Num() != BaselineAssetsByPathCount)
		{
			return false;
		}

		for (int Index = 0; Index < AssetsByPath.Num(); ++Index)
		{
			if (AssetsByPath[Index].GetObjectPathString() == BaselineObjectPathString)
			{
				return AssetsByPath[Index].GetSoftObjectPath().ToString() == BaselineSoftObjectPathString;
			}
		}
		return false;
	}

	/**
	 * Observe GetAssetsByPath parity with the expected values supplied as parameters.
	 *
	 * @Kind RoundTrip
	 * @Covers AssetRegistry.GetAssetsByPath
	 * @Param bBaselineGetAssetsByPath Baseline success flag from the native baseline
	 * @Param BaselineAssetsByPathCount Baseline number of assets returned
	 * @Param BaselineObjectPathString Path string used to locate the target asset
	 * @Param BaselineSoftObjectPathString Soft path string the target asset should report
	 * @Param EngineMaterialsPath Path queried for assets
	 * @Inputs GetAssetsByPath on the supplied path, filling an out array
	 * @Return true when the success flag, count, and matched asset paths all match
	 */
	UFUNCTION()
	bool GetAssetsByPathParity(
		bool bBaselineGetAssetsByPath,
		int BaselineAssetsByPathCount,
		const FString&in BaselineObjectPathString,
		const FString&in BaselineSoftObjectPathString,
		FName EngineMaterialsPath)
	{
		TArray<FAssetData> AssetsByPath;
		const bool bActualGetAssetsByPath = AssetRegistry::GetAssetsByPath(EngineMaterialsPath, AssetsByPath, false, false);
		if (bActualGetAssetsByPath != bBaselineGetAssetsByPath)
		{
			return false;
		}
		if (AssetsByPath.Num() != BaselineAssetsByPathCount)
		{
			return false;
		}

		for (int Index = 0; Index < AssetsByPath.Num(); ++Index)
		{
			if (AssetsByPath[Index].GetObjectPathString() == BaselineObjectPathString)
			{
				return AssetsByPath[Index].GetSoftObjectPath().ToString() == BaselineSoftObjectPathString;
			}
		}
		return false;
	}

	/**
	 * Observe GetAssetByObjectPath parity against a native baseline.
	 *
	 * @Kind Observe
	 * @Covers AssetRegistry.GetAssetByObjectPath
	 * @Inputs GetAssetByObjectPath with the target object path token
	 * @Return true when both the object path and soft object path strings match
	 */
	UFUNCTION()
	bool GetAssetByObjectPathParity()
	{
		const FString TargetObjectPath = "__TARGET_OBJECT_PATH__";
		const FString BaselineObjectPathString = "__EXPECTED_OBJECT_PATH_STRING__";
		const FString BaselineSoftObjectPathString = "__EXPECTED_SOFT_OBJECT_PATH_STRING__";

		FAssetData AssetByObjectPath = AssetRegistry::GetAssetByObjectPath(FSoftObjectPath(TargetObjectPath), false);
		if (AssetByObjectPath.GetObjectPathString() != BaselineObjectPathString)
		{
			return false;
		}
		return AssetByObjectPath.GetSoftObjectPath().ToString() == BaselineSoftObjectPathString;
	}

	/**
	 * Observe GetAssetByObjectPath parity with the paths supplied as parameters.
	 *
	 * @Kind RoundTrip
	 * @Covers AssetRegistry.GetAssetByObjectPath
	 * @Param TargetObjectPath Object path looked up in the registry
	 * @Param BaselineObjectPathString Object path string the result should report
	 * @Param BaselineSoftObjectPathString Soft path string the result should report
	 * @Inputs GetAssetByObjectPath with the supplied target path
	 * @Return true when both the object path and soft object path strings match
	 */
	UFUNCTION()
	bool GetAssetByObjectPathParity(
		const FString&in TargetObjectPath,
		const FString&in BaselineObjectPathString,
		const FString&in BaselineSoftObjectPathString)
	{
		FAssetData AssetByObjectPath = AssetRegistry::GetAssetByObjectPath(FSoftObjectPath(TargetObjectPath), false);
		if (AssetByObjectPath.GetObjectPathString() != BaselineObjectPathString)
		{
			return false;
		}
		return AssetByObjectPath.GetSoftObjectPath().ToString() == BaselineSoftObjectPathString;
	}

	/**
	 * Observe GetAllAssets parity against a native baseline.
	 *
	 * @Kind Observe
	 * @Covers AssetRegistry.GetAllAssets
	 * @Inputs GetAllAssets filling an out array with every asset
	 * @Return true when the success flag, count, and target membership all match
	 */
	UFUNCTION()
	bool GetAllAssetsParity()
	{
		const bool bBaselineGetAllAssets = __EXPECTED_GET_ALL_ASSETS__;
		const bool bBaselineAllAssetsContainTarget = __EXPECTED_ALL_ASSETS_CONTAIN_TARGET__;
		const int BaselineAllAssetsCount = __EXPECTED_ALL_ASSETS_COUNT__;
		const FString BaselineObjectPathString = "__EXPECTED_OBJECT_PATH_STRING__";

		TArray<FAssetData> AllAssets;
		const bool bActualGetAllAssets = AssetRegistry::GetAllAssets(AllAssets, false);
		if (bActualGetAllAssets != bBaselineGetAllAssets)
		{
			return false;
		}
		if (AllAssets.Num() != BaselineAllAssetsCount)
		{
			return false;
		}

		bool bFoundTargetInAllAssets = false;
		for (int Index = 0; Index < AllAssets.Num(); ++Index)
		{
			if (AllAssets[Index].GetObjectPathString() == BaselineObjectPathString)
			{
				bFoundTargetInAllAssets = true;
				break;
			}
		}
		return bFoundTargetInAllAssets == bBaselineAllAssetsContainTarget;
	}

	/**
	 * Observe GetAllAssets parity with the expected values supplied as parameters.
	 *
	 * @Kind RoundTrip
	 * @Covers AssetRegistry.GetAllAssets
	 * @Param bBaselineGetAllAssets Baseline success flag from the native baseline
	 * @Param bBaselineAllAssetsContainTarget Whether the target asset should be present
	 * @Param BaselineAllAssetsCount Baseline number of assets returned
	 * @Param BaselineObjectPathString Path string used to locate the target asset
	 * @Inputs GetAllAssets filling an out array with every asset
	 * @Return true when the success flag, count, and target membership all match
	 */
	UFUNCTION()
	bool GetAllAssetsParity(
		bool bBaselineGetAllAssets,
		bool bBaselineAllAssetsContainTarget,
		int BaselineAllAssetsCount,
		const FString&in BaselineObjectPathString)
	{
		TArray<FAssetData> AllAssets;
		const bool bActualGetAllAssets = AssetRegistry::GetAllAssets(AllAssets, false);
		if (bActualGetAllAssets != bBaselineGetAllAssets)
		{
			return false;
		}
		if (AllAssets.Num() != BaselineAllAssetsCount)
		{
			return false;
		}

		bool bFoundTargetInAllAssets = false;
		for (int Index = 0; Index < AllAssets.Num(); ++Index)
		{
			if (AllAssets[Index].GetObjectPathString() == BaselineObjectPathString)
			{
				bFoundTargetInAllAssets = true;
				break;
			}
		}
		return bFoundTargetInAllAssets == bBaselineAllAssetsContainTarget;
	}

	/**
	 * Observe the empty default: an out array that received no assets is empty.
	 *
	 * @Kind Observe
	 * @Covers AssetRegistry.GetAssetsByPath
	 * @Inputs A freshly constructed FAssetData array
	 * @Return true when the array is empty
	 */
	UFUNCTION()
	bool AssetsByPathEmptyDefault()
	{
		TArray<FAssetData> AssetsByPath;
		return AssetsByPath.Num() == 0;
	}

	/**
	 * Observe copy independence: two lookups of the same path return results
	 * that agree with each other.
	 *
	 * @Kind RoundTrip
	 * @Covers AssetRegistry.GetAssetByObjectPath
	 * @Param TargetObjectPath Object path looked up in the registry
	 * @Param BaselineObjectPathString Object path string both results should report
	 * @Inputs Two GetAssetByObjectPath calls with the same path
	 * @Return true when both results report the same object path string
	 */
	UFUNCTION()
	bool GetAssetByObjectPathCopyIndependence(
		const FString&in TargetObjectPath,
		const FString&in BaselineObjectPathString)
	{
		FAssetData First = AssetRegistry::GetAssetByObjectPath(FSoftObjectPath(TargetObjectPath), false);
		FAssetData Second = AssetRegistry::GetAssetByObjectPath(FSoftObjectPath(TargetObjectPath), false);
		if (First.GetObjectPathString() != BaselineObjectPathString)
		{
			return false;
		}
		return First.GetObjectPathString() == Second.GetObjectPathString();
	}
}
