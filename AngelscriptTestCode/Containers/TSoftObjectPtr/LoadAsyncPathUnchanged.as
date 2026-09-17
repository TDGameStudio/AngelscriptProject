/**
 * @version v1
 * @summary LoadAsync requests a load and does not rewrite the pointer path.
 * @topic Containers
 * LoadAsyncPathUnchanged
 */
/**
 * @begin LoadAsyncPathUnchanged
 * @summary LoadAsync requests a load and does not rewrite the pointer path.
 * @topic Containers
 */
UCLASS()
class UTSSoftObjectPtrLoadAsyncPathReceiver : UObject
{
	UFUNCTION()
	void HandleObjectLoaded(UObject Loaded)
	{
	}
}

bool LoadAsyncPathUnchanged()
{
	UTSSoftObjectPtrLoadAsyncPathReceiver Receiver = Cast<UTSSoftObjectPtrLoadAsyncPathReceiver>(
		NewObject(GetTransientPackage(), UTSSoftObjectPtrLoadAsyncPathReceiver::StaticClass(), n"TSSoftObjectPtrLoadAsyncPathReceiver", true));
	if (Receiver is null)
	{
		return false;
	}

	FSoftObjectPath Original("/Game/AngelscriptTest/SomePackage.SomeAsset");
	TSoftObjectPtr<UObject> Soft;
	Soft = Original;

	FOnSoftObjectLoaded ObjectDelegate;
	ObjectDelegate.BindUFunction(Receiver, n"HandleObjectLoaded");
	Soft.LoadAsync(ObjectDelegate);
	return Soft.ToSoftObjectPath() == Original;
}
/** @end */
