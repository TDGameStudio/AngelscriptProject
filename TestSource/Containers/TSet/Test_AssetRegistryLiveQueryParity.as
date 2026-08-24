// Theme: Containers.TSet. Positive AssetRegistry live-query parity vs native baselines.
// C++ ReplaceInline of __EXPECTED_*__ / path tokens become runner parameters on overloads.
// Oracle: HasAssetsParity, GetAssetsByPathParity, GetAssetByObjectPathParity, GetAllAssetsParity
// all return 1. Extra: empty out array before GetAssetsByPath; two queries copy-independent.
// DefaultSafe.

int HasAssetsParity()
{
	const bool bExpectedHasAssets = __EXPECTED_HAS_ASSETS__;
	const bool bActualHasAssets = AssetRegistry::HasAssets(n"__ENGINE_MATERIALS_PATH__", false);
	return bActualHasAssets == bExpectedHasAssets ? 1 : 0;
}

int HasAssetsParity(bool bExpectedHasAssets, FName EngineMaterialsPath)
{
	const bool bActualHasAssets = AssetRegistry::HasAssets(EngineMaterialsPath, false);
	return bActualHasAssets == bExpectedHasAssets ? 1 : 0;
}

int GetAssetsByPathParity()
{
	const bool bExpectedGetAssetsByPath = __EXPECTED_GET_ASSETS_BY_PATH__;
	const int ExpectedAssetsByPathCount = __EXPECTED_ASSETS_BY_PATH_COUNT__;
	const FString ExpectedObjectPathString = "__EXPECTED_OBJECT_PATH_STRING__";
	const FString ExpectedSoftObjectPathString = "__EXPECTED_SOFT_OBJECT_PATH_STRING__";

	TArray<FAssetData> AssetsByPath;
	const bool bActualGetAssetsByPath = AssetRegistry::GetAssetsByPath(n"__ENGINE_MATERIALS_PATH__", AssetsByPath, false, false);
	if (bActualGetAssetsByPath != bExpectedGetAssetsByPath)
	{
		return 0;
	}
	if (AssetsByPath.Num() != ExpectedAssetsByPathCount)
	{
		return 0;
	}

	for (int Index = 0; Index < AssetsByPath.Num(); ++Index)
	{
		if (AssetsByPath[Index].GetObjectPathString() == ExpectedObjectPathString)
		{
			return AssetsByPath[Index].GetSoftObjectPath().ToString() == ExpectedSoftObjectPathString ? 1 : 0;
		}
	}
	return 0;
}

int GetAssetsByPathParity(
	bool bExpectedGetAssetsByPath,
	int ExpectedAssetsByPathCount,
	const FString& ExpectedObjectPathString,
	const FString& ExpectedSoftObjectPathString,
	FName EngineMaterialsPath)
{
	TArray<FAssetData> AssetsByPath;
	const bool bActualGetAssetsByPath = AssetRegistry::GetAssetsByPath(EngineMaterialsPath, AssetsByPath, false, false);
	if (bActualGetAssetsByPath != bExpectedGetAssetsByPath)
	{
		return 0;
	}
	if (AssetsByPath.Num() != ExpectedAssetsByPathCount)
	{
		return 0;
	}

	for (int Index = 0; Index < AssetsByPath.Num(); ++Index)
	{
		if (AssetsByPath[Index].GetObjectPathString() == ExpectedObjectPathString)
		{
			return AssetsByPath[Index].GetSoftObjectPath().ToString() == ExpectedSoftObjectPathString ? 1 : 0;
		}
	}
	return 0;
}

int GetAssetByObjectPathParity()
{
	const FString TargetObjectPath = "__TARGET_OBJECT_PATH__";
	const FString ExpectedObjectPathString = "__EXPECTED_OBJECT_PATH_STRING__";
	const FString ExpectedSoftObjectPathString = "__EXPECTED_SOFT_OBJECT_PATH_STRING__";

	FAssetData AssetByObjectPath = AssetRegistry::GetAssetByObjectPath(FSoftObjectPath(TargetObjectPath), false);
	return AssetByObjectPath.GetObjectPathString() == ExpectedObjectPathString
		&& AssetByObjectPath.GetSoftObjectPath().ToString() == ExpectedSoftObjectPathString ? 1 : 0;
}

int GetAssetByObjectPathParity(
	const FString& TargetObjectPath,
	const FString& ExpectedObjectPathString,
	const FString& ExpectedSoftObjectPathString)
{
	FAssetData AssetByObjectPath = AssetRegistry::GetAssetByObjectPath(FSoftObjectPath(TargetObjectPath), false);
	return AssetByObjectPath.GetObjectPathString() == ExpectedObjectPathString
		&& AssetByObjectPath.GetSoftObjectPath().ToString() == ExpectedSoftObjectPathString ? 1 : 0;
}

int GetAllAssetsParity()
{
	const bool bExpectedGetAllAssets = __EXPECTED_GET_ALL_ASSETS__;
	const bool bExpectedAllAssetsContainTarget = __EXPECTED_ALL_ASSETS_CONTAIN_TARGET__;
	const int ExpectedAllAssetsCount = __EXPECTED_ALL_ASSETS_COUNT__;
	const FString ExpectedObjectPathString = "__EXPECTED_OBJECT_PATH_STRING__";

	TArray<FAssetData> AllAssets;
	const bool bActualGetAllAssets = AssetRegistry::GetAllAssets(AllAssets, false);
	if (bActualGetAllAssets != bExpectedGetAllAssets)
	{
		return 0;
	}
	if (AllAssets.Num() != ExpectedAllAssetsCount)
	{
		return 0;
	}

	bool bFoundTargetInAllAssets = false;
	for (int Index = 0; Index < AllAssets.Num(); ++Index)
	{
		if (AllAssets[Index].GetObjectPathString() == ExpectedObjectPathString)
		{
			bFoundTargetInAllAssets = true;
			break;
		}
	}
	return bFoundTargetInAllAssets == bExpectedAllAssetsContainTarget ? 1 : 0;
}

int GetAllAssetsParity(
	bool bExpectedGetAllAssets,
	bool bExpectedAllAssetsContainTarget,
	int ExpectedAllAssetsCount,
	const FString& ExpectedObjectPathString)
{
	TArray<FAssetData> AllAssets;
	const bool bActualGetAllAssets = AssetRegistry::GetAllAssets(AllAssets, false);
	if (bActualGetAllAssets != bExpectedGetAllAssets)
	{
		return 0;
	}
	if (AllAssets.Num() != ExpectedAllAssetsCount)
	{
		return 0;
	}

	bool bFoundTargetInAllAssets = false;
	for (int Index = 0; Index < AllAssets.Num(); ++Index)
	{
		if (AllAssets[Index].GetObjectPathString() == ExpectedObjectPathString)
		{
			bFoundTargetInAllAssets = true;
			break;
		}
	}
	return bFoundTargetInAllAssets == bExpectedAllAssetsContainTarget ? 1 : 0;
}

int Observe_AssetsByPath_EmptyDefault()
{
	TArray<FAssetData> AssetsByPath;
	return AssetsByPath.Num() == 0 ? 1 : 0;
}

int Observe_GetAssetByObjectPath_CopyIndependence(
	const FString& TargetObjectPath,
	const FString& ExpectedObjectPathString)
{
	FAssetData First = AssetRegistry::GetAssetByObjectPath(FSoftObjectPath(TargetObjectPath), false);
	FAssetData Second = AssetRegistry::GetAssetByObjectPath(FSoftObjectPath(TargetObjectPath), false);
	return First.GetObjectPathString() == ExpectedObjectPathString
		&& First.GetObjectPathString() == Second.GetObjectPathString()
		? 1 : 0;
}
