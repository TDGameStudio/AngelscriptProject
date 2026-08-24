// Purpose: Observe FTopLevelAssetPath.Reset and AssetRegistry Blueprint load
// under a path.
// AS-facing API: void Path.Reset();
// void AssetRegistry::LoadAllBlueprintsUnderPath(FName PathToLoadFrom,
// FString OptionalFileIncludeRegex = "");
// Inputs: A seeded actor path, repeated Reset, PathToLoadFrom n"/Engine",
// missing n"__MissingBlueprintPath__", default regex omission, and regex
// ".*".
// Expected observations: Reset clears a valid path to IsNull. A second Reset
// stays null. LoadAllBlueprintsUnderPath returns after scanning; missing
// paths are still accepted as a no-match load and HasAssets stays false.
// Boundary/ownership: Reset mutates the path value in place. Blueprint load
// borrows PathToLoadFrom and copies the optional regex.

namespace TS_AssetRegistry_MutationAndLifecycle_01
{
	bool Observe_Reset_Nominal()
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

	bool Observe_LoadAllBlueprintsUnderPath_Nominal()
	{
		AssetRegistry::LoadAllBlueprintsUnderPath(n"/Engine");
		AssetRegistry::LoadAllBlueprintsUnderPath(n"/Engine", "");
		AssetRegistry::LoadAllBlueprintsUnderPath(n"/Engine", ".*");
		AssetRegistry::LoadAllBlueprintsUnderPath(n"__MissingBlueprintPath__", "");
		AssetRegistry::LoadAllBlueprintsUnderPath(NAME_None);
		return AssetRegistry::HasAssets(n"/Engine") && !AssetRegistry::HasAssets(n"__MissingBlueprintPath__");
	}
}
