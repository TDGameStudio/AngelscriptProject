// Purpose: Observe primary-asset type/id validity and AssetManager path
// lookups.
// AS-facing API: FName Name = Type.GetName() const;
// bool bValid = Type.IsValid() const; bool bValid = Id.IsValid() const;
// FPrimaryAssetId Id = AssetManager.GetPrimaryAssetIdForPath(const FSoftObjectPath& ObjectPath) const;
// FSoftObjectPath Path = AssetManager.GetPrimaryAssetPath(const FPrimaryAssetId& PrimaryAssetId) const;
// FPrimaryAssetId Id = AssetManager.GetPrimaryAssetIdForData(const FAssetData& AssetData) const;
// Inputs: FPrimaryAssetType(n"Weapon"), empty type, FPrimaryAssetId("Weapon:Sword"),
// empty id, FSoftObjectPath("/Script/Engine.Default__Actor"), empty
// FSoftObjectPath, and default FAssetData. Receiver is UAssetManager::Get().
// Expected observations: GetName of Weapon is n"Weapon". Empty type/id are
// invalid; nominal values are valid. Missing path/data lookups return an
// invalid FPrimaryAssetId or a null FSoftObjectPath.
// Boundary/ownership: Lookups return copies. They do not load or own the
// referenced asset. Null AssetManager is setup failure.

namespace TS_UAssetManager_Queries_01
{
	bool Observe_GetName_Nominal()
	{
		FPrimaryAssetType Type(n"Weapon");
		FName Name = Type.GetName();
		FPrimaryAssetType Empty;
		FName EmptyName = Empty.GetName();
		return Name == n"Weapon" && EmptyName.IsNone();
	}

	bool Observe_IsValid_Nominal()
	{
		FPrimaryAssetType Type(n"Weapon");
		FPrimaryAssetType EmptyType;
		FPrimaryAssetId Id("Weapon:Sword");
		FPrimaryAssetId EmptyId;
		FPrimaryAssetId Incomplete("Weapon:");
		return Type.IsValid() &&
			!EmptyType.IsValid() &&
			Id.IsValid() &&
			!EmptyId.IsValid() &&
			!Incomplete.IsValid();
	}

	bool Observe_GetPrimaryAssetIdForPath_Nominal(bool bExpectActorId)
	{
		UAssetManager AssetManager = UAssetManager::Get();
		if (AssetManager is null)
		{
			throw("TS_UAssetManager_Queries_01 setup: required AssetManager is null");
		}
		FSoftObjectPath Missing("/Script/Engine.DefinitelyMissingPrimaryAsset");
		FPrimaryAssetId MissingId = AssetManager.GetPrimaryAssetIdForPath(Missing);
		FSoftObjectPath EmptyPath;
		FPrimaryAssetId EmptyPathId = AssetManager.GetPrimaryAssetIdForPath(EmptyPath);
		FSoftObjectPath ActorPath("/Script/Engine.Default__Actor");
		FPrimaryAssetId ActorId = AssetManager.GetPrimaryAssetIdForPath(ActorPath);
		return !MissingId.IsValid() && !EmptyPathId.IsValid() && ActorId.IsValid() == bExpectActorId;
	}

	bool Observe_GetPrimaryAssetPath_Nominal()
	{
		UAssetManager AssetManager = UAssetManager::Get();
		if (AssetManager is null)
		{
			throw("TS_UAssetManager_Queries_01 setup: required AssetManager is null");
		}
		FPrimaryAssetId Missing("MissingType:MissingName");
		FSoftObjectPath MissingPath = AssetManager.GetPrimaryAssetPath(Missing);
		FPrimaryAssetId EmptyId;
		FSoftObjectPath EmptyPath = AssetManager.GetPrimaryAssetPath(EmptyId);
		return MissingPath.IsNull() && EmptyPath.IsNull();
	}

	bool Observe_GetPrimaryAssetIdForData_Nominal()
	{
		UAssetManager AssetManager = UAssetManager::Get();
		if (AssetManager is null)
		{
			throw("TS_UAssetManager_Queries_01 setup: required AssetManager is null");
		}
		FAssetData EmptyData;
		FPrimaryAssetId EmptyId = AssetManager.GetPrimaryAssetIdForData(EmptyData);
		FAssetData MissingData;
		FPrimaryAssetId MissingId = AssetManager.GetPrimaryAssetIdForData(MissingData);
		return !EmptyId.IsValid() && !MissingId.IsValid();
	}
}
