/**
 * @version v1
 * @summary UAssetManager host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic UAssetManager
 *
 * type
 * id
 * unload-primary-asset
 * unload-primary-assets
 * assignment
 * load-primary-asset
 * load-primary-assets
 * equality
 * get-name
 * is-valid
 * get-primary-asset-id-for-path
 * get-primary-asset-path
 * get-primary-asset-id-for-data
 */
/**
 * @begin type
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveTypeNominal
 * @summary Observe the container API.
 * @covers UAssetManager.type
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 FPrimaryAssetId Id(const FString& InString);
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
bool ObserveTypeNominal()
{
	FPrimaryAssetType Type(n"Weapon");
	FPrimaryAssetType NoneType(NAME_None);
	FPrimaryAssetType Empty;
	return Type.IsValid() && Type.GetName() == n"Weapon" && !NoneType.IsValid() && !Empty.IsValid();
}
/** @end */
/**
 * @begin id
 * @summary Null AssetManager is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveIdNominal
 * @summary Null AssetManager is setup failure.
 * @covers UAssetManager.id
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIdNominal()
{
	FPrimaryAssetId Id("Weapon:Sword");
	FPrimaryAssetId EmptyString("");
	FPrimaryAssetId TypeOnly("Weapon:");
	FPrimaryAssetId DefaultId;
	return Id.IsValid() && !EmptyString.IsValid() && !TypeOnly.IsValid() && !DefaultId.IsValid();
}
/** @end */
/**
 * @begin unload-primary-asset
 * @summary Null AssetManager is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveUnloadPrimaryAssetNominal
 * @summary Null AssetManager is setup failure.
 * @covers UAssetManager.unload-primary-asset
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveUnloadPrimaryAssetNominal()
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
/** @end */
/**
 * @begin unload-primary-assets
 * @summary Null AssetManager is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveUnloadPrimaryAssetsNominal
 * @summary Null AssetManager is setup failure.
 * @covers UAssetManager.unload-primary-assets
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveUnloadPrimaryAssetsNominal()
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
/** @end */
/**
 * @begin assignment
 * @summary not retain the identifier.
 * @topic Unreal
 */
/**
 * @function ObserveAssignmentNominal
 * @summary not retain the identifier.
 * @covers UAssetManager.assignment
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveAssignmentNominal()
{
	FPrimaryAssetType Type(n"Weapon");
	FString TypeText = f"{Type}";
	FPrimaryAssetType CopiedType = Type;
	FString CopiedTypeText = f"{CopiedType}";
	FPrimaryAssetType EmptyType;
	FString EmptyTypeText = f"{EmptyType}";

	FPrimaryAssetId Id("Weapon:Sword");
	FString IdText = f"{Id}";
	FPrimaryAssetId CopiedId = Id;
	FString CopiedIdText = f"{CopiedId}";
	FPrimaryAssetId EmptyId;
	FString EmptyIdText = f"{EmptyId}";

	Type = FPrimaryAssetType(n"Armor");
	Id = FPrimaryAssetId("Armor:Shield");
	return TypeText.Len() > 0 &&
		TypeText.Contains("Weapon") &&
		CopiedTypeText.Contains("Weapon") &&
		CopiedType.GetName() == n"Weapon" &&
		IdText.Len() > 0 &&
		IdText.Contains("Weapon") &&
		IdText.Contains("Sword") &&
		CopiedIdText.Contains("Sword") &&
		CopiedId.IsValid() &&
		EmptyTypeText != TypeText &&
		EmptyIdText != IdText;
}
/** @end */
/**
 * @begin load-primary-asset
 * @summary AssetManager is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveLoadPrimaryAssetNominal
 * @summary AssetManager is setup failure.
 * @covers UAssetManager.load-primary-asset
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSAssetManagerLoadReceiver : UObject
{
	UPROPERTY()
	int FinishedCount = 0;

	UPROPERTY()
	int CanceledCount = 0;

bool ObserveLoadPrimaryAssetNominal()
{
	UAssetManager AssetManager = UAssetManager::Get();
	if (AssetManager is null)
	{
		throw("TS_UAssetManager_MutationAndLifecycle_01 setup: required AssetManager is null");
	}
	FPrimaryAssetId AssetToLoad("Weapon:Sword");
	TArray<FName> LoadBundles;
	LoadBundles.Add(n"Bundle");
	UTSAssetManagerLoadReceiver Receiver = Cast<UTSAssetManagerLoadReceiver>(
		NewObject(GetTransientPackage(), UTSAssetManagerLoadReceiver::StaticClass(), n"TSAssetManagerLoadReceiver", true));
	if (Receiver is null)
	{
		throw("TS_UAssetManager_MutationAndLifecycle_01 setup: required Receiver is null");
	}

	AssetManager.LoadPrimaryAsset(AssetToLoad, LoadBundles);
	AssetManager.LoadPrimaryAsset(AssetToLoad, LoadBundles, 0);
	AssetManager.LoadPrimaryAsset(AssetToLoad, LoadBundles, 1, Receiver, n"OnLoadFinished", n"OnLoadCanceled");
	AssetManager.LoadPrimaryAsset(AssetToLoad, LoadBundles, 0, Receiver, NAME_None, NAME_None);
	return AssetManager == UAssetManager::Get() && Receiver.FinishedCount == 0 && Receiver.CanceledCount == 0;
}
/** @end */
/**
 * @begin load-primary-assets
 * @summary AssetManager is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveLoadPrimaryAssetsNominal
 * @summary AssetManager is setup failure.
 * @covers UAssetManager.load-primary-assets
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSAssetManagerLoadReceiver : UObject
{
	UPROPERTY()
	int FinishedCount = 0;

	UPROPERTY()
	int CanceledCount = 0;

bool ObserveLoadPrimaryAssetsNominal()
{
	UAssetManager AssetManager = UAssetManager::Get();
	if (AssetManager is null)
	{
		throw("TS_UAssetManager_MutationAndLifecycle_01 setup: required AssetManager is null");
	}
	TArray<FPrimaryAssetId> AssetsToLoad;
	AssetsToLoad.Add(FPrimaryAssetId("Weapon:Sword"));
	AssetsToLoad.Add(FPrimaryAssetId("Weapon:Axe"));
	TArray<FName> LoadBundles;
	LoadBundles.Add(n"Bundle");
	TArray<FPrimaryAssetId> EmptyAssets;
	TArray<FName> EmptyBundles;
	UTSAssetManagerLoadReceiver Receiver = Cast<UTSAssetManagerLoadReceiver>(
		NewObject(GetTransientPackage(), UTSAssetManagerLoadReceiver::StaticClass(), n"TSAssetManagerLoadReceiverList", true));
	if (Receiver is null)
	{
		throw("TS_UAssetManager_MutationAndLifecycle_01 setup: required Receiver is null");
	}

	AssetManager.LoadPrimaryAssets(AssetsToLoad, LoadBundles);
	AssetManager.LoadPrimaryAssets(EmptyAssets, EmptyBundles, 0);
	AssetManager.LoadPrimaryAssets(AssetsToLoad, LoadBundles, 1, Receiver, n"OnLoadFinished", n"OnLoadCanceled");
	return AssetManager == UAssetManager::Get() && Receiver.FinishedCount == 0 && Receiver.CanceledCount == 0;
}
/** @end */
/**
 * @begin equality
 * @summary operators do not mutate either operand.
 * @topic Unreal
 */
/**
 * @function ObserveEqualityNominal
 * @summary operators do not mutate either operand.
 * @covers UAssetManager.equality
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
bool ObserveEqualityNominal()
{
	FPrimaryAssetType LeftType(n"Weapon");
	FPrimaryAssetType RightType(n"Weapon");
	FPrimaryAssetType OtherType(n"Armor");
	FPrimaryAssetType EmptyType;
	FPrimaryAssetType AnotherEmptyType;

	FPrimaryAssetId LeftId("Weapon:Sword");
	FPrimaryAssetId RightId("Weapon:Sword");
	FPrimaryAssetId OtherId("Weapon:Axe");
	FPrimaryAssetId EmptyId;
	FPrimaryAssetId AnotherEmptyId;

	return LeftType == RightType &&
		!(LeftType == OtherType) &&
		!(LeftType == EmptyType) &&
		EmptyType == AnotherEmptyType &&
		LeftId == RightId &&
		!(LeftId == OtherId) &&
		!(LeftId == EmptyId) &&
		EmptyId == AnotherEmptyId;
}
/** @end */
/**
 * @begin get-name
 * @summary Observe the container API.
 * @topic Unreal
 */
/**
 * @function ObserveGetNameNominal
 * @summary Observe the container API.
 * @covers UAssetManager.get-name
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
//

 Inputs: FPrimaryAssetType(n"Weapon"), empty type, FPrimaryAssetId("Weapon:Sword"),
// empty id, FSoftObjectPath("/Script/Engine.Default__Actor"), empty
// FSoftObjectPath, and default FAssetData. Receiver is UAssetManager::Get().
// Expected observations: GetName of Weapon is n"Weapon". Empty type/id are
// invalid; nominal values are valid. Missing path/data lookups return an
// invalid FPrimaryAssetId or a null FSoftObjectPath.
// Boundary/ownership: Lookups return copies. They do not load or own the
// referenced asset. Null AssetManager is setup failure.
bool ObserveGetNameNominal()
{
	FPrimaryAssetType Type(n"Weapon");
	FName Name = Type.GetName();
	FPrimaryAssetType Empty;
	FName EmptyName = Empty.GetName();
	return Name == n"Weapon" && EmptyName.IsNone();
}
/** @end */
/**
 * @begin is-valid
 * @summary referenced asset.
 * @topic Unreal
 */
/**
 * @function ObserveIsValidNominal
 * @summary referenced asset.
 * @covers UAssetManager.is-valid
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveIsValidNominal()
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
/** @end */
/**
 * @begin get-primary-asset-id-for-path
 * @summary referenced asset.
 * @topic Unreal
 */
/**
 * @function ObserveGetPrimaryAssetIdForPathNominal
 * @summary referenced asset.
 * @covers UAssetManager.get-primary-asset-id-for-path
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetPrimaryAssetIdForPathNominal(bool bExpectActorId)
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
/** @end */
/**
 * @begin get-primary-asset-path
 * @summary referenced asset.
 * @topic Unreal
 */
/**
 * @function ObserveGetPrimaryAssetPathNominal
 * @summary referenced asset.
 * @covers UAssetManager.get-primary-asset-path
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetPrimaryAssetPathNominal()
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
/** @end */
/**
 * @begin get-primary-asset-id-for-data
 * @summary referenced asset.
 * @topic Unreal
 */
/**
 * @function ObserveGetPrimaryAssetIdForDataNominal
 * @summary referenced asset.
 * @covers UAssetManager.get-primary-asset-id-for-data
 * @inputs UAssetManager values exercised by this observe
 * @return true when the observe comparison holds
 */
//

bool ObserveGetPrimaryAssetIdForDataNominal()
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
/** @end */
