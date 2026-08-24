// Purpose: Observe CallOrRegister_OnCompletedInitialScan invoking a reflected
// no-argument callback, including already-completed scan and invalid inputs.
// AS-facing API: void AssetManager.CallOrRegister_OnCompletedInitialScan(
// UObject Object, FName Function);
// Inputs: UAssetManager::Get(), a UTSAssetManagerScanReceiver with
// OnInitialScanComplete, Function n"OnInitialScanComplete", NAME_None, a
// missing n"DoesNotExist", and a null callback object.
// Expected observations: A valid receiver is invoked immediately when the
// initial scan has already completed, so CallbackCount becomes at least 1.
// Repeating the same registration does not require a second scan. NAME_None,
// missing function names, and null objects are no-ops.
// Boundary/ownership: Object is borrowed as the callback receiver. Function
// is a reflected UFUNCTION name, not a script delegate the manager owns.
// A null manager or receiver is setup failure.

UCLASS()
class UTSAssetManagerScanReceiver : UObject
{
	UPROPERTY()
	int CallbackCount = 0;

	UFUNCTION()
	void OnInitialScanComplete()
	{
		CallbackCount += 1;
	}
}

namespace TS_AssetManagerScriptMixins_Behavior_01
{
	bool Observe_CallOrRegister_OnCompletedInitialScan_Nominal()
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
}
