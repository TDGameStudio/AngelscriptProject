// Purpose: Observe FPrimaryAssetType/FPrimaryAssetId construction and
// AssetManager unload handle counts.
// AS-facing API: FPrimaryAssetType Type(FName InName);
// FPrimaryAssetId Id(const FString& InString);
// int Unloaded = AssetManager.UnloadPrimaryAsset(const FPrimaryAssetId& AssetToUnload);
// int Unloaded = AssetManager.UnloadPrimaryAssets(const TArray<FPrimaryAssetId>& AssetsToUnload);
// Inputs: n"Weapon", "Weapon:Sword", empty name/string, UAssetManager::Get(),
// a never-loaded id, and an empty id list.
// Expected observations: Type(n"Weapon") is valid and GetName matches.
// Id("Weapon:Sword") is valid. Empty inputs are invalid. Unload of a
// never-loaded id returns 0. Unload of an empty list returns 0.
// Boundary/ownership: Construction copies interned names. Unload returns the
// number of affected handles and does not destroy the identifier value.
// Null AssetManager is setup failure.

namespace TS_UAssetManager_Behavior_01
{
	bool Observe_Type_Nominal()
	{
		FPrimaryAssetType Type(n"Weapon");
		FPrimaryAssetType NoneType(NAME_None);
		FPrimaryAssetType Empty;
		return Type.IsValid() && Type.GetName() == n"Weapon" && !NoneType.IsValid() && !Empty.IsValid();
	}

	bool Observe_Id_Nominal()
	{
		FPrimaryAssetId Id("Weapon:Sword");
		FPrimaryAssetId EmptyString("");
		FPrimaryAssetId TypeOnly("Weapon:");
		FPrimaryAssetId DefaultId;
		return Id.IsValid() && !EmptyString.IsValid() && !TypeOnly.IsValid() && !DefaultId.IsValid();
	}

	bool Observe_UnloadPrimaryAsset_Nominal()
	{
		UAssetManager AssetManager = UAssetManager::Get();
		if (AssetManager is null)
		{
			throw("TS_UAssetManager_Behavior_01 setup: required AssetManager is null");
		}
		FPrimaryAssetId AssetToUnload("Weapon:Sword");
		int UnloadedMissing = AssetManager.UnloadPrimaryAsset(AssetToUnload);
		int UnloadedRepeat = AssetManager.UnloadPrimaryAsset(AssetToUnload);
		FPrimaryAssetId InvalidId;
		int UnloadedInvalid = AssetManager.UnloadPrimaryAsset(InvalidId);
		return UnloadedMissing == 0 && UnloadedRepeat == 0 && UnloadedInvalid == 0;
	}

	bool Observe_UnloadPrimaryAssets_Nominal()
	{
		UAssetManager AssetManager = UAssetManager::Get();
		if (AssetManager is null)
		{
			throw("TS_UAssetManager_Behavior_01 setup: required AssetManager is null");
		}
		TArray<FPrimaryAssetId> AssetsToUnload;
		AssetsToUnload.Add(FPrimaryAssetId("Weapon:Sword"));
		AssetsToUnload.Add(FPrimaryAssetId("Weapon:Axe"));
		int UnloadedMissing = AssetManager.UnloadPrimaryAssets(AssetsToUnload);
		TArray<FPrimaryAssetId> EmptyAssets;
		int UnloadedEmpty = AssetManager.UnloadPrimaryAssets(EmptyAssets);
		return UnloadedMissing == 0 && UnloadedEmpty == 0;
	}
}
