/**
 * @version v1
 * @summary AssetManagerScriptMixins host API observes merged from Bindings leftovers.
 * @topic Unreal
 * @topic AssetManagerScriptMixins
 *
 * call-or-register-on-completed-initial-scan
 * get-primary-asset-data
 * get-primary-asset-object
 */
/**
 * @begin call-or-register-on-completed-initial-scan
 * @summary A null manager or receiver is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveCallOrRegisterOnCompletedInitialScanNominal
 * @summary A null manager or receiver is setup failure.
 * @covers AssetManagerScriptMixins.call-or-register-on-completed-initial-scan
 * @inputs AssetManagerScriptMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
UCLASS()
class UTSAssetManagerScanReceiver : UObject
{
	UPROPERTY()
	int CallbackCount = 0;

bool ObserveCallOrRegisterOnCompletedInitialScanNominal()
{
	UAssetManager AssetManager = UAssetManager::Get();
	if (AssetManager is null)
	{
		throw("TS_AssetManagerScriptMixins_Behavior_01 setup: required AssetManager is null");
	}
	UTSAssetManagerScanReceiver Receiver = Cast<UTSAssetManagerScanReceiver>(
		NewObject(GetTransientPackage(), UTSAssetManagerScanReceiver::StaticClass(), n"TSAssetManagerScanReceiver", true));
	if (Receiver is null)
	{
		throw("TS_AssetManagerScriptMixins_Behavior_01 setup: required Receiver is null");
	}
	int Before = Receiver.CallbackCount;

	AssetManager.CallOrRegister_OnCompletedInitialScan(Receiver, n"OnInitialScanComplete");
	int AfterFirst = Receiver.CallbackCount;

	AssetManager.CallOrRegister_OnCompletedInitialScan(Receiver, n"OnInitialScanComplete");
	int AfterRepeat = Receiver.CallbackCount;

	UObject NullObject = nullptr;
	AssetManager.CallOrRegister_OnCompletedInitialScan(NullObject, n"OnInitialScanComplete");
	AssetManager.CallOrRegister_OnCompletedInitialScan(Receiver, NAME_None);
	AssetManager.CallOrRegister_OnCompletedInitialScan(Receiver, n"DoesNotExist");
	int AfterInvalid = Receiver.CallbackCount;

	return Before == 0 && AfterFirst >= 1 && AfterRepeat >= AfterFirst && AfterInvalid == AfterRepeat;
}
/** @end */
/**
 * @begin get-primary-asset-data
 * @summary FPrimaryAssetId,
 * @topic Unreal
 */
/**
 * @function ObserveGetPrimaryAssetDataNominal
 * @summary FPrimaryAssetId,
 * @covers AssetManagerScriptMixins.get-primary-asset-data
 * @inputs AssetManagerScriptMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
// FPrimaryAssetId,

 and FPrimaryAssetId("MissingType:MissingName") as a
// negative lookup key.
// Expected observations: Missing and invalid ids return false from
// GetPrimaryAssetData and leave Data invalid. GetPrimaryAssetObject returns
// null when the asset is not resident.
// Boundary/ownership: Data is a writeback copy of scanned metadata. The
// returned UObject is borrowed; a null result does not create an object.
// A null manager is setup failure.
bool ObserveGetPrimaryAssetDataNominal()
{
	UAssetManager AssetManager = UAssetManager::Get();
	if (AssetManager is null)
	{
		throw("TS_AssetManagerScriptMixins_Queries_01 setup: required AssetManager is null");
	}

	FAssetData InvalidOut;
	FString InvalidOutBefore = InvalidOut.GetObjectPathString();
	FPrimaryAssetId InvalidId;
	bool bInvalidFound = AssetManager.GetPrimaryAssetData(InvalidId, InvalidOut);
	bool bInvalidLookupFails = !bInvalidFound && InvalidOut.GetObjectPathString().IsEmpty() && InvalidOutBefore.IsEmpty();

	FAssetData MissingOut;
	FName MissingOutBefore = MissingOut.AssetName;
	FPrimaryAssetId MissingId("MissingType:MissingName");
	bool bMissingFound = AssetManager.GetPrimaryAssetData(MissingId, MissingOut);
	bool bMissingLookupFails = !bMissingFound && MissingOut.AssetName == MissingOutBefore;

	return bInvalidLookupFails && bMissingLookupFails;
}
/** @end */
/**
 * @begin get-primary-asset-object
 * @summary A null manager is setup failure.
 * @topic Unreal
 */
/**
 * @function ObserveGetPrimaryAssetObjectNominal
 * @summary A null manager is setup failure.
 * @covers AssetManagerScriptMixins.get-primary-asset-object
 * @inputs AssetManagerScriptMixins values exercised by this observe
 * @return true when the observe comparison holds
 */
// FPrimaryAssetId,

bool ObserveGetPrimaryAssetObjectNominal()
{
	UAssetManager AssetManager = UAssetManager::Get();
	if (AssetManager is null)
	{
		throw("TS_AssetManagerScriptMixins_Queries_01 setup: required AssetManager is null");
	}
	FPrimaryAssetId InvalidId;
	UObject InvalidObject = AssetManager.GetPrimaryAssetObject(InvalidId);

	FPrimaryAssetId MissingId("MissingType:MissingName");
	UObject MissingObject = AssetManager.GetPrimaryAssetObject(MissingId);

	return InvalidObject is null && MissingObject is null;
}
/** @end */
