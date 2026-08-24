// Purpose: Observe asynchronous primary-asset load requests, including
// default callback omission and invalid callback names.
// AS-facing API: AssetManager.LoadPrimaryAsset(const FPrimaryAssetId& AssetToLoad,
// const TArray<FName>& LoadBundles, int32 Priority = 0,
// UObject OptionalCallbackObject = nullptr,
// FName OptionalFinishedCallbackFunctionName = NAME_None,
// FName OptionalCanceledCallbackName = NAME_None);
// AssetManager.LoadPrimaryAssets(const TArray<FPrimaryAssetId>& AssetsToLoad,
// const TArray<FName>& LoadBundles, int32 Priority = 0,
// UObject OptionalCallbackObject = nullptr,
// FName OptionalFinishedCallbackFunctionName = NAME_None,
// FName OptionalCanceledCallbackName = NAME_None);
// Inputs: UAssetManager::Get(), FPrimaryAssetId("Weapon:Sword"), bundle
// n"Bundle", Priority 0 and 1, a UTSAssetManagerLoadReceiver with
// OnLoadFinished/OnLoadCanceled, default callback omission, and n"DoesNotExist"
// as the diagnostic callback name.
// Expected observations: Valid-looking loads return without throwing. Repeating
// the request is accepted. Default callback names skip binding. Missing
// callback UFUNCTION names are the expected-diagnostic path.
// Boundary/ownership: LoadBundles are copied. OptionalCallbackObject is
// borrowed; the manager does not take outer ownership of it. Null
// AssetManager is setup failure.

UCLASS()
class UTSAssetManagerLoadReceiver : UObject
{
	UPROPERTY()
	int FinishedCount = 0;

	UPROPERTY()
	int CanceledCount = 0;

	UFUNCTION()
	void OnLoadFinished()
	{
		FinishedCount += 1;
	}

	UFUNCTION()
	void OnLoadCanceled()
	{
		CanceledCount += 1;
	}
}

namespace TS_UAssetManager_MutationAndLifecycle_01
{
	bool Observe_LoadPrimaryAsset_Nominal()
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

	bool Observe_LoadPrimaryAssets_Nominal()
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

	void ExerciseExpectedFailure()
	{
		UAssetManager AssetManager = UAssetManager::Get();
		FPrimaryAssetId AssetToLoad("Weapon:Sword");
		TArray<FName> LoadBundles;
		LoadBundles.Add(n"Bundle");
		UTSAssetManagerLoadReceiver Receiver = Cast<UTSAssetManagerLoadReceiver>(
			NewObject(GetTransientPackage(), UTSAssetManagerLoadReceiver::StaticClass(), n"TSAssetManagerLoadReceiverInvalid", true));
		AssetManager.LoadPrimaryAsset(AssetToLoad, LoadBundles, 0, Receiver, n"DoesNotExist", n"DoesNotExist");
		TArray<FPrimaryAssetId> AssetsToLoad;
		AssetsToLoad.Add(AssetToLoad);
		AssetManager.LoadPrimaryAssets(AssetsToLoad, LoadBundles, 0, Receiver, n"DoesNotExist", n"DoesNotExist");
		FPrimaryAssetId InvalidId;
		TArray<FName> EmptyBundles;
		AssetManager.LoadPrimaryAsset(InvalidId, EmptyBundles);
	}
}
