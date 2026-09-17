/**
 * @version v1
 * @summary AssetRegistry host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic AssetRegistry
 *
 * path
 * assignment
 * asset-created
 * reset
 * load-all-blueprints-under-path
 * equality
 * get-soft-object-path
 * get-object-path-string
 * is-instance-of
 * is-valid
 * is-null
 * is-loading-assets
 * has-assets
 * get-assets-by-package-name
 * get-assets-by-path
 * get-assets-by-class
 * get-blueprint-cd-os-by-parent-class
 * get-widget-blueprint-cd-os-by-parent-class
 * get-assets-by-tags
 * get-asset-by-object-path
 * get-all-assets
 * get-assets
 * get-dependencies
 * get-referencers
 * get-derived-class-names
 * get-generated-class-name
 */
/**
 * @begin path
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObservePathNominal
 * @summary Observe the container API.
 * @covers AssetRegistry.path
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FTopLevelAssetPath Path(const FString& AssetPath);
// FTopLevelAssetPath Path(const FName& PackageName, const FName& AssetName);
// Inputs: AActor::StaticClass() as the object, "/Script/Engine.Actor" as the
// string, n"/Script/Engine" plus n"Actor" as names, nullptr as the empty
// object, and "" / NAME_None as empty name inputs.
// Expected observations: Object, string, and name constructors of Actor
// compare equal and IsValid. Null object and empty names produce a null or
// invalid path.
// Boundary/ownership: Constructors copy path names. They do not keep the
// source UObject alive.
bool ObservePathNominal()
{
	FTopLevelAssetPath FromObject(AActor::StaticClass());
	FTopLevelAssetPath FromString("/Script/Engine.Actor");
	FTopLevelAssetPath FromNames(n"/Script/Engine", n"Actor");

	UObject NullObject = nullptr;
	FTopLevelAssetPath FromNull(NullObject);
	FTopLevelAssetPath FromEmptyString("");
	FTopLevelAssetPath FromNoneNames(NAME_None, NAME_None);

	return FromObject.IsValid() &&
		FromString.IsValid() &&
		FromString == FromObject &&
		FromNames.IsValid() &&
		FromNames == FromObject &&
		(FromNull.IsNull() || !FromNull.IsValid()) &&
		(FromEmptyString.IsNull() || !FromEmptyString.IsValid()) &&
		(FromNoneNames.IsNull() || !FromNoneNames.IsValid());
}
/** @end */
/**
 * @begin assignment
 * @summary is not retained.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary is not retained.
 * @covers AssetRegistry.assignment
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FTopLevelAssetPath Path;
	bool bDefaultIsNull = Path.IsNull();
	FString ActorPath = "/Script/Engine.Actor";
	Path = ActorPath;
	FString Formatted = f"{Path}";
	bool bAssignedIsValid = Path.IsValid();
	bool bFormatterNonEmpty = Formatted.Len() > 0;

	FTopLevelAssetPath Copy;
	Copy = ActorPath;
	bool bCopyMatches = Copy == Path;
	ActorPath = "/Script/Engine.Pawn";
	bool bAssignmentCopiedString = Path.IsValid() && Copy.IsValid();

	FString EmptyPath = "";
	Path = EmptyPath;
	FString EmptyFormatted = f"{Path}";
	bool bEmptyAssignmentClears = Path.IsNull();
	bool bEmptyFormatterConsumed = EmptyFormatted.IsEmpty() || EmptyFormatted != Formatted;

	return bDefaultIsNull &&
		bAssignedIsValid &&
		bFormatterNonEmpty &&
		bCopyMatches &&
		bAssignmentCopiedString &&
		bEmptyAssignmentClears &&
		bEmptyFormatterConsumed;
}
/** @end */
/**
 * @begin asset-created
 * @summary object's outer/owner.
 * @topic Unreal
 */
/**
 * @function ObserveAssetCreatedNominal
 * @summary object's outer/owner.
 * @covers AssetRegistry.asset-created
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssetCreatedNominal()
{
	UObject NewAsset = NewObject(GetTransientPackage(), UTexture2D::StaticClass(), n"TSAssetRegistryCreated", true);
	if (NewAsset is null)
	{
		throw("TS_AssetRegistry_ConversionAndFormatting_01 setup: required NewAsset is null");
	}
	AssetRegistry::AssetCreated(NewAsset);
	AssetRegistry::AssetCreated(NewAsset);
	UObject NullAsset = nullptr;
	AssetRegistry::AssetCreated(NullAsset);
	return NewAsset.GetName() == "TSAssetRegistryCreated";
}
/** @end */
/**
 * @begin reset
 * @summary borrows PathToLoadFrom and copies the optional regex.
 * @topic Unreal
 */
/**
 * @function ObserveResetNominal
 * @summary borrows PathToLoadFrom and copies the optional regex.
 * @covers AssetRegistry.reset
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveResetNominal()
{
	FTopLevelAssetPath Path(AActor::StaticClass());
	bool bWasValid = Path.IsValid();
	Path.Reset();
	bool bResetClears = Path.IsNull();
	Path.Reset();
	bool bRepeatedResetStable = Path.IsNull();
	FTopLevelAssetPath Empty;
	Empty.Reset();
	bool bEmptyResetStable = Empty.IsNull();
	return bWasValid && bResetClears && bRepeatedResetStable && bEmptyResetStable;
}
/** @end */
/**
 * @begin load-all-blueprints-under-path
 * @summary borrows PathToLoadFrom and copies the optional regex.
 * @topic Unreal
 */
/**
 * @function ObserveLoadAllBlueprintsUnderPathNominal
 * @summary borrows PathToLoadFrom and copies the optional regex.
 * @covers AssetRegistry.load-all-blueprints-under-path
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveLoadAllBlueprintsUnderPathNominal()
{
	AssetRegistry::LoadAllBlueprintsUnderPath(n"/Engine");
	AssetRegistry::LoadAllBlueprintsUnderPath(n"/Engine", "");
	AssetRegistry::LoadAllBlueprintsUnderPath(n"/Engine", ".*");
	AssetRegistry::LoadAllBlueprintsUnderPath(n"__MissingBlueprintPath__", "");
	AssetRegistry::LoadAllBlueprintsUnderPath(NAME_None);
	return AssetRegistry::HasAssets(n"/Engine") && !AssetRegistry::HasAssets(n"__MissingBlueprintPath__");
}
/** @end */
/**
 * @begin equality
 * @summary The operator is value-returning and does not mutate either operand.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary The operator is value-returning and does not mutate either operand.
 * @covers AssetRegistry.equality
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FTopLevelAssetPath Left("/Script/Engine.Actor");
	FTopLevelAssetPath RightSame("/Script/Engine.Actor");
	FTopLevelAssetPath RightDifferent("/Script/Engine.Pawn");
	FTopLevelAssetPath Empty;
	FTopLevelAssetPath AnotherEmpty;

	return (Left == RightSame) &&
		!(Left == RightDifferent) &&
		!(Left == Empty) &&
		(Empty == AnotherEmpty);
}
/** @end */
/**
 * @begin get-soft-object-path
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetSoftObjectPathNominal
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @covers AssetRegistry.get-soft-object-path
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetSoftObjectPathNominal()
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
/** @end */
/**
 * @begin get-object-path-string
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetObjectPathStringNominal
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @covers AssetRegistry.get-object-path-string
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetObjectPathStringNominal()
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
/** @end */
/**
 * @begin is-instance-of
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIsInstanceOfNominal
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @covers AssetRegistry.is-instance-of
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsInstanceOfNominal()
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
/** @end */
/**
 * @begin is-valid
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @covers AssetRegistry.is-valid
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsValidNominal()
{
	FTopLevelAssetPath Empty;
	FTopLevelAssetPath ActorPath(AActor::StaticClass());
	FTopLevelAssetPath Parsed("/Script/Engine.Actor");
	FTopLevelAssetPath FromNames(n"/Script/Engine", n"Actor");
	return !Empty.IsValid() && ActorPath.IsValid() && Parsed.IsValid() && FromNames.IsValid();
}
/** @end */
/**
 * @begin is-null
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIsNullNominal
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @covers AssetRegistry.is-null
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsNullNominal()
{
	FTopLevelAssetPath Empty;
	FTopLevelAssetPath ActorPath(AActor::StaticClass());
	return Empty.IsNull() && !ActorPath.IsNull();
}
/** @end */
/**
 * @begin is-loading-assets
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveIsLoadingAssetsNominal
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @covers AssetRegistry.is-loading-assets
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveIsLoadingAssetsNominal(bool bExpectLoading)
{
	return AssetRegistry::IsLoadingAssets() == bExpectLoading;
}
/** @end */
/**
 * @begin has-assets
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveHasAssetsNominal
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @covers AssetRegistry.has-assets
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveHasAssetsNominal()
{
	bool bEngineHasAssets = AssetRegistry::HasAssets(n"/Engine");
	bool bEngineRecursive = AssetRegistry::HasAssets(n"/Engine", true);
	bool bMissing = AssetRegistry::HasAssets(n"__MissingPackagePath__", false);
	bool bNone = AssetRegistry::HasAssets(NAME_None);
	return (bEngineHasAssets || bEngineRecursive) && !bMissing && !bNone;
}
/** @end */
/**
 * @begin get-assets-by-package-name
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetAssetsByPackageNameNominal
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @covers AssetRegistry.get-assets-by-package-name
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAssetsByPackageNameNominal()
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
/** @end */
/**
 * @begin get-assets-by-path
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetAssetsByPathNominal
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @covers AssetRegistry.get-assets-by-path
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAssetsByPathNominal()
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
/** @end */
/**
 * @begin get-assets-by-class
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @topic Unreal
 */
/**
 * @function ObserveGetAssetsByClassNominal
 * @summary IsInstanceOf with a null BaseClass is the invalid-class diagnostic path.
 * @covers AssetRegistry.get-assets-by-class
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAssetsByClassNominal()
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
/** @end */
/**
 * @begin get-blueprint-cd-os-by-parent-class
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetBlueprintCDOsByParentClassNominal
 * @summary writebacks.
 * @covers AssetRegistry.get-blueprint-cd-os-by-parent-class
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetBlueprintCDOsByParentClassNominal()
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
/** @end */
/**
 * @begin get-widget-blueprint-cd-os-by-parent-class
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetWidgetBlueprintCDOsByParentClassNominal
 * @summary writebacks.
 * @covers AssetRegistry.get-widget-blueprint-cd-os-by-parent-class
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetWidgetBlueprintCDOsByParentClassNominal()
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
/** @end */
/**
 * @begin get-assets-by-tags
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetAssetsByTagsNominal
 * @summary writebacks.
 * @covers AssetRegistry.get-assets-by-tags
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAssetsByTagsNominal()
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
/** @end */
/**
 * @begin get-asset-by-object-path
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetAssetByObjectPathNominal
 * @summary writebacks.
 * @covers AssetRegistry.get-asset-by-object-path
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAssetByObjectPathNominal()
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
/** @end */
/**
 * @begin get-all-assets
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetAllAssetsNominal
 * @summary writebacks.
 * @covers AssetRegistry.get-all-assets
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAllAssetsNominal()
{
	TArray<FAssetData> OutAssetData;
	int32 Before = OutAssetData.Num();
	bool bAll = AssetRegistry::GetAllAssets(OutAssetData);
	int32 After = OutAssetData.Num();
	TArray<FAssetData> OnDisk;
	bool bOnDisk = AssetRegistry::GetAllAssets(OnDisk, true);
	return Before == 0 && bAll && After > 0 && (bOnDisk || OnDisk.Num() == 0);
}
/** @end */
/**
 * @begin get-assets
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetAssetsNominal
 * @summary writebacks.
 * @covers AssetRegistry.get-assets
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetAssetsNominal()
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
/** @end */
/**
 * @begin get-dependencies
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetDependenciesNominal
 * @summary writebacks.
 * @covers AssetRegistry.get-dependencies
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDependenciesNominal()
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
/** @end */
/**
 * @begin get-referencers
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetReferencersNominal
 * @summary writebacks.
 * @covers AssetRegistry.get-referencers
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetReferencersNominal()
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
/** @end */
/**
 * @begin get-derived-class-names
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetDerivedClassNamesNominal
 * @summary writebacks.
 * @covers AssetRegistry.get-derived-class-names
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetDerivedClassNamesNominal()
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
/** @end */
/**
 * @begin get-generated-class-name
 * @summary writebacks.
 * @topic Unreal
 */
/**
 * @function ObserveGetGeneratedClassNameNominal
 * @summary writebacks.
 * @covers AssetRegistry.get-generated-class-name
 * @inputs AssetRegistry values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveGetGeneratedClassNameNominal()
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
/** @end */
