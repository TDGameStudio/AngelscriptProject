// Purpose: Observe editor/registry expansion queries: Blueprint CDOs, tags,
// object-path lookup, filters, dependencies, referencers, and generated
// class names.
// AS-facing API: void AssetRegistry::GetBlueprintCDOsByParentClass(UClass Class, TArray<UObject>& OutAssets);
// void AssetRegistry::GetWidgetBlueprintCDOsByParentClass(UClass Class, TArray<UObject>& OutAssets);
// bool AssetRegistry::GetAssetsByTags(const TArray<FName>& AssetTags, TArray<FAssetData>& OutAssetData);
// FAssetData AssetRegistry::GetAssetByObjectPath(const FSoftObjectPath& ObjectPath, bool bIncludeOnlyOnDiskAssets = false);
// bool AssetRegistry::GetAllAssets(TArray<FAssetData>& OutAssetData, bool bIncludeOnlyOnDiskAssets = false);
// bool AssetRegistry::GetAssets(const FARFilter& Filter, TArray<FAssetData>& OutAssetData, bool bSkipARFilteredAssets = true);
// bool AssetRegistry::GetDependencies(FName PackageName, const FAssetRegistryDependencyOptions& DependencyOptions, TArray<FName>& OutDependencies);
// bool AssetRegistry::GetReferencers(FName PackageName, const FAssetRegistryDependencyOptions& ReferenceOptions, TArray<FName>& OutReferencers);
// void AssetRegistry::GetDerivedClassNames(const TArray<FTopLevelAssetPath>& ClassNames, const TSet<FTopLevelAssetPath>& ExcludedClassNames, TSet<FTopLevelAssetPath>&OutDerivedClassNames);
// bool AssetRegistry::GetGeneratedClassName(const FAssetData& AssetData, FTopLevelAssetPath& OutGeneratedClassName);
// Inputs: AActor and UUserWidget parent classes, empty and n"AssetTag" tag
// lists, FSoftObjectPath("/Script/Engine.Default__Actor"), default FARFilter,
// package n"/Engine/EngineMaterials", empty FAssetData, and empty exclusion
// set.
// Expected observations: Out arrays grow from empty or stay empty. Missing
// object paths yield invalid FAssetData. Empty tags and missing packages
// return false with empty writebacks. Generated-class lookup on empty
// FAssetData is false and leaves OutGeneratedClassName invalid.
// Boundary/ownership: OutAssets/OutAssetData/OutDependencies are caller-owned
// writebacks. GetBlueprintCDOsByParentClass rejects a null Class.

namespace TS_AssetRegistry_Queries_02
{
	bool Observe_GetBlueprintCDOsByParentClass_Nominal()
	{
		TArray<UObject> OutAssets;
		int32 Before = OutAssets.Num();
		AssetRegistry::GetBlueprintCDOsByParentClass(AActor::StaticClass(), OutAssets);
		int32 After = OutAssets.Num();
		AssetRegistry::GetBlueprintCDOsByParentClass(AActor::StaticClass(), OutAssets);
		int32 AfterRepeat = OutAssets.Num();
		if (After == 0)
		{
			return Before == 0 && AfterRepeat == 0;
		}
		return Before == 0 && After > 0 && OutAssets[0] != nullptr && (AfterRepeat == After || AfterRepeat == After * 2);
	}

	bool Observe_GetWidgetBlueprintCDOsByParentClass_Nominal()
	{
		TArray<UObject> OutAssets;
		int32 Before = OutAssets.Num();
		AssetRegistry::GetWidgetBlueprintCDOsByParentClass(UUserWidget::StaticClass(), OutAssets);
		int32 After = OutAssets.Num();
		if (After == 0)
		{
			return Before == 0;
		}
		return Before == 0 && After > 0 && OutAssets[0] != nullptr;
	}

	bool Observe_GetAssetsByTags_Nominal()
	{
		TArray<FName> EmptyTags;
		TArray<FAssetData> EmptyOut;
		int32 EmptyBefore = EmptyOut.Num();
		bool bEmpty = AssetRegistry::GetAssetsByTags(EmptyTags, EmptyOut);

		TArray<FName> Tags;
		Tags.Add(n"AssetTag");
		TArray<FAssetData> Tagged;
		bool bTagged = AssetRegistry::GetAssetsByTags(Tags, Tagged);

		return EmptyBefore == 0 &&
			!bEmpty &&
			EmptyOut.Num() == 0 &&
			(bTagged || Tagged.Num() == 0);
	}

	bool Observe_GetAssetByObjectPath_Nominal()
	{
		FSoftObjectPath MissingPath("/Script/Engine.DefinitelyMissingAsset");
		FAssetData Missing = AssetRegistry::GetAssetByObjectPath(MissingPath);
		FAssetData MissingOnDisk = AssetRegistry::GetAssetByObjectPath(MissingPath, true);
		FSoftObjectPath EmptyPath;
		FAssetData Empty = AssetRegistry::GetAssetByObjectPath(EmptyPath, false);
		return Missing.GetObjectPathString().IsEmpty() &&
			MissingOnDisk.GetObjectPathString().IsEmpty() &&
			Empty.GetObjectPathString().IsEmpty();
	}

	bool Observe_GetAllAssets_Nominal()
	{
		TArray<FAssetData> OutAssetData;
		int32 Before = OutAssetData.Num();
		bool bAll = AssetRegistry::GetAllAssets(OutAssetData);
		int32 After = OutAssetData.Num();
		TArray<FAssetData> OnDisk;
		bool bOnDisk = AssetRegistry::GetAllAssets(OnDisk, true);
		return Before == 0 && bAll && After > 0 && (bOnDisk || OnDisk.Num() == 0);
	}

	bool Observe_GetAssets_Nominal()
	{
		FARFilter Filter;
		TArray<FAssetData> OutAssetData;
		int32 Before = OutAssetData.Num();
		bool bDefaultFilter = AssetRegistry::GetAssets(Filter, OutAssetData);
		int32 After = OutAssetData.Num();
		TArray<FAssetData> IncludeFiltered;
		bool bIncludeFiltered = AssetRegistry::GetAssets(Filter, IncludeFiltered, false);
		return Before == 0 &&
			(bDefaultFilter || After == 0) &&
			(bIncludeFiltered || IncludeFiltered.Num() == 0);
	}

	bool Observe_GetDependencies_Nominal()
	{
		FAssetRegistryDependencyOptions DependencyOptions;
		TArray<FName> OutDependencies;
		int32 Before = OutDependencies.Num();
		bool bFound = AssetRegistry::GetDependencies(n"/Engine/EngineMaterials", DependencyOptions, OutDependencies);
		int32 After = OutDependencies.Num();
		TArray<FName> Missing;
		bool bMissing = AssetRegistry::GetDependencies(n"__MissingPackageName__", DependencyOptions, Missing);
		return Before == 0 &&
			(bFound || After == 0) &&
			!bMissing &&
			Missing.Num() == 0;
	}

	bool Observe_GetReferencers_Nominal()
	{
		FAssetRegistryDependencyOptions ReferenceOptions;
		TArray<FName> OutReferencers;
		int32 Before = OutReferencers.Num();
		bool bFound = AssetRegistry::GetReferencers(n"/Engine/EngineMaterials", ReferenceOptions, OutReferencers);
		int32 After = OutReferencers.Num();
		TArray<FName> Missing;
		bool bMissing = AssetRegistry::GetReferencers(n"__MissingPackageName__", ReferenceOptions, Missing);
		return Before == 0 &&
			(bFound || After == 0) &&
			!bMissing &&
			Missing.Num() == 0;
	}

	bool Observe_GetDerivedClassNames_Nominal()
	{
		TArray<FTopLevelAssetPath> ClassNames;
		ClassNames.Add(FTopLevelAssetPath(AActor::StaticClass()));
		TSet<FTopLevelAssetPath> ExcludedClassNames;
		TSet<FTopLevelAssetPath> OutDerivedClassNames;
		int32 Before = OutDerivedClassNames.Num();
		AssetRegistry::GetDerivedClassNames(ClassNames, ExcludedClassNames, OutDerivedClassNames);
		int32 After = OutDerivedClassNames.Num();

		TSet<FTopLevelAssetPath> ExcludedWithActor;
		ExcludedWithActor.Add(FTopLevelAssetPath(APawn::StaticClass()));
		TSet<FTopLevelAssetPath> OutWithExclusion;
		AssetRegistry::GetDerivedClassNames(ClassNames, ExcludedWithActor, OutWithExclusion);

		TArray<FTopLevelAssetPath> EmptyClasses;
		TSet<FTopLevelAssetPath> EmptyOut;
		AssetRegistry::GetDerivedClassNames(EmptyClasses, ExcludedClassNames, EmptyOut);

		return Before == 0 && After > 0 && EmptyOut.Num() == 0 && OutWithExclusion.Num() <= After;
	}

	bool Observe_GetGeneratedClassName_Nominal()
	{
		FAssetData Empty;
		FTopLevelAssetPath OutGeneratedClassName;
		bool bEmptyFound = AssetRegistry::GetGeneratedClassName(Empty, OutGeneratedClassName);
		bool bEmptyLeavesInvalid = !OutGeneratedClassName.IsValid();

		TArray<FAssetData> Assets;
		AssetRegistry::GetAssetsByClass(FTopLevelAssetPath(UBlueprint::StaticClass()), Assets);
		if (Assets.Num() == 0)
		{
			return !bEmptyFound && bEmptyLeavesInvalid;
		}
		FTopLevelAssetPath Generated;
		bool bGenerated = AssetRegistry::GetGeneratedClassName(Assets[0], Generated);
		return !bEmptyFound && bEmptyLeavesInvalid && bGenerated == Generated.IsValid();
	}
}
