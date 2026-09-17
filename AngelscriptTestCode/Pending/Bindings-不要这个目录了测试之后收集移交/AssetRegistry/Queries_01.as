/**
 * @version v1
 * @summary Observe FAssetData path/class queries, FTopLevelAssetPath validity, and AssetRegistry package/class lookups.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe FAssetData path/class queries, FTopLevelAssetPath validity, and AssetRegistry package/class lookups.
 * @topic Baseline
 */
// FString AssetData.GetObjectPathString() const;
// bool AssetData.IsInstanceOf(const UClass BaseClass, bool bResolveClass = false) const;
// bool Path.IsValid() const; bool Path.IsNull() const;
// bool AssetRegistry::IsLoadingAssets();
// bool AssetRegistry::HasAssets(const FName PackagePath, const bool bRecursive = false);
// bool AssetRegistry::GetAssetsByPackageName(FName PackageName, TArray<FAssetData>& OutAssetData, bool bIncludeOnlyOnDiskAssets = false);
// bool AssetRegistry::GetAssetsByPath(FName PackagePath, TArray<FAssetData>& OutAssetData, bool bRecursive = false, bool bIncludeOnlyOnDiskAssets = false);
// bool AssetRegistry::GetAssetsByClass(const FTopLevelAssetPath& ClassPath, TArray<FAssetData>& OutAssetData, bool bSearchSubClasses = false);
// Inputs: Default FAssetData, a path from AActor::StaticClass(), package
// n"/Engine", n"/Engine/EngineMaterials", missing n"__MissingPackagePath__",
// UBlueprint class path, empty FTopLevelAssetPath, and default bResolveClass.
// Expected observations: Empty asset data yields an empty/null soft path.
// Actor path IsValid is true and IsNull is false. HasAssets is true for
// /Engine and false for the missing path. Missing package lookups write empty
// arrays. IsLoadingAssets matches the runner-supplied expectation.
// Boundary/ownership: OutAssetData is a writeback list of value copies.
// IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.

namespace TS_AssetRegistry_Queries_01
{
	bool Observe_GetSoftObjectPath_Nominal()
	{
		FAssetData Empty;
		FSoftObjectPath EmptyPath = Empty.GetSoftObjectPath();
		bool bEmptyPathIsNull = EmptyPath.IsNull();

		TArray<FAssetData> Assets;
		FTopLevelAssetPath BlueprintClassPath(UBlueprint::StaticClass());
		AssetRegistry::GetAssetsByClass(BlueprintClassPath, Assets);
		if (Assets.Num() == 0)
		{
			return bEmptyPathIsNull;
		}
		FSoftObjectPath FirstPath = Assets[0].GetSoftObjectPath();
		return bEmptyPathIsNull && FirstPath.IsValid();
	}

	bool Observe_GetObjectPathString_Nominal()
	{
		FAssetData Empty;
		FString EmptyText = Empty.GetObjectPathString();
		TArray<FAssetData> Assets;
		AssetRegistry::GetAssetsByClass(FTopLevelAssetPath(UBlueprint::StaticClass()), Assets);
		if (Assets.Num() == 0)
		{
			return EmptyText.IsEmpty();
		}
		FString FirstText = Assets[0].GetObjectPathString();
		return EmptyText.IsEmpty() && FirstText.Len() > 0;
	}

	bool Observe_IsInstanceOf_Nominal()
	{
		FAssetData Empty;
		bool bEmptyIsActor = Empty.IsInstanceOf(AActor::StaticClass());
		bool bEmptyIsActorResolved = Empty.IsInstanceOf(AActor::StaticClass(), true);
		bool bEmptyIsObject = Empty.IsInstanceOf(UObject::StaticClass(), false);

		TArray<FAssetData> Assets;
		AssetRegistry::GetAssetsByClass(FTopLevelAssetPath(UBlueprint::StaticClass()), Assets, true);
		if (Assets.Num() == 0)
		{
			return !bEmptyIsActor && !bEmptyIsActorResolved && !bEmptyIsObject;
		}
		bool bFirstIsBlueprint = Assets[0].IsInstanceOf(UBlueprint::StaticClass());
		bool bFirstIsActor = Assets[0].IsInstanceOf(AActor::StaticClass(), false);
		return !bEmptyIsActor && !bEmptyIsActorResolved && !bEmptyIsObject && bFirstIsBlueprint && !bFirstIsActor;
	}

	bool Observe_IsValid_Nominal()
	{
		FTopLevelAssetPath Empty;
		FTopLevelAssetPath ActorPath(AActor::StaticClass());
		FTopLevelAssetPath Parsed("/Script/Engine.Actor");
		FTopLevelAssetPath FromNames(n"/Script/Engine", n"Actor");
		return !Empty.IsValid() && ActorPath.IsValid() && Parsed.IsValid() && FromNames.IsValid();
	}

	bool Observe_IsNull_Nominal()
	{
		FTopLevelAssetPath Empty;
		FTopLevelAssetPath ActorPath(AActor::StaticClass());
		return Empty.IsNull() && !ActorPath.IsNull();
	}

	bool Observe_IsLoadingAssets_Nominal(bool bExpectLoading)
	{
		return AssetRegistry::IsLoadingAssets() == bExpectLoading;
	}

	bool Observe_HasAssets_Nominal()
	{
		bool bEngineHasAssets = AssetRegistry::HasAssets(n"/Engine");
		bool bEngineRecursive = AssetRegistry::HasAssets(n"/Engine", true);
		bool bMissing = AssetRegistry::HasAssets(n"__MissingPackagePath__", false);
		bool bNone = AssetRegistry::HasAssets(NAME_None);
		return (bEngineHasAssets || bEngineRecursive) && !bMissing && !bNone;
	}

	bool Observe_GetAssetsByPackageName_Nominal()
	{
		TArray<FAssetData> OutAssetData;
		int32 Before = OutAssetData.Num();
		bool bFound = AssetRegistry::GetAssetsByPackageName(n"/Script/Engine", OutAssetData);
		int32 After = OutAssetData.Num();
		TArray<FAssetData> OnDiskOnly;
		bool bOnDisk = AssetRegistry::GetAssetsByPackageName(n"/Script/Engine", OnDiskOnly, true);
		TArray<FAssetData> Missing;
		bool bMissing = AssetRegistry::GetAssetsByPackageName(n"__MissingPackageName__", Missing);
		return Before == 0 &&
			After >= Before &&
			!bMissing &&
			Missing.Num() == 0 &&
			(bFound || After == 0) &&
			(bOnDisk || OnDiskOnly.Num() == 0);
	}

	bool Observe_GetAssetsByPath_Nominal()
	{
		TArray<FAssetData> OutAssetData;
		int32 Before = OutAssetData.Num();
		bool bFound = AssetRegistry::GetAssetsByPath(n"/Engine", OutAssetData);
		int32 After = OutAssetData.Num();
		TArray<FAssetData> Recursive;
		bool bRecursive = AssetRegistry::GetAssetsByPath(n"/Engine", Recursive, true, false);
		TArray<FAssetData> Missing;
		bool bMissing = AssetRegistry::GetAssetsByPath(n"__MissingPackagePath__", Missing, true, false);
		return Before == 0 &&
			bFound &&
			After > 0 &&
			bRecursive &&
			Recursive.Num() > 0 &&
			!bMissing &&
			Missing.Num() == 0;
	}

	bool Observe_GetAssetsByClass_Nominal()
	{
		TArray<FAssetData> OutAssetData;
		FTopLevelAssetPath BlueprintClassPath(UBlueprint::StaticClass());
		bool bFound = AssetRegistry::GetAssetsByClass(BlueprintClassPath, OutAssetData);
		TArray<FAssetData> WithSubclasses;
		bool bWithSubclasses = AssetRegistry::GetAssetsByClass(BlueprintClassPath, WithSubclasses, true);
		TArray<FAssetData> EmptyClass;
		FTopLevelAssetPath EmptyPath;
		bool bEmptyClass = AssetRegistry::GetAssetsByClass(EmptyPath, EmptyClass);
		return (bFound || OutAssetData.Num() == 0) &&
			(bWithSubclasses || WithSubclasses.Num() == 0) &&
			!bEmptyClass &&
			EmptyClass.Num() == 0;
	}

	void ExerciseExpectedFailure()
	{
		FAssetData Data;
		UClass NullClass;
		bool bInstance = Data.IsInstanceOf(NullClass, true);
	}
}
/** @end */
