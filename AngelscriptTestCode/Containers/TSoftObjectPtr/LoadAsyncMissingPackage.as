/**
 * @version v1
 * @summary LoadAsync of a missing package invokes the handler with nullptr.
 * @topic Containers
 * LoadAsyncMissingPackage
 */
/**
 * @begin LoadAsyncMissingPackage
 * @summary LoadAsync of a missing package invokes the handler with nullptr.
 * @topic Containers
 */
UCLASS()
class UTSSoftObjectPtrLoadAsyncMissingReceiver : UObject
{
	UPROPERTY()
	int32 ObjectLoadCount = 0;

	UPROPERTY()
	UObject LastLoadedObject = nullptr;

	UFUNCTION()
	void HandleObjectLoaded(UObject Loaded)
	{
		ObjectLoadCount += 1;
		LastLoadedObject = Loaded;
	}
}

bool LoadAsyncMissingPackage()
{
	UTSSoftObjectPtrLoadAsyncMissingReceiver Receiver = Cast<UTSSoftObjectPtrLoadAsyncMissingReceiver>(
		NewObject(GetTransientPackage(), UTSSoftObjectPtrLoadAsyncMissingReceiver::StaticClass(), n"TSSoftObjectPtrLoadAsyncMissingReceiver", true));
	if (Receiver is null)
	{
		return false;
	}

	FOnSoftObjectLoaded ObjectDelegate;
	ObjectDelegate.BindUFunction(Receiver, n"HandleObjectLoaded");
	TSoftObjectPtr<UObject> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
	Missing.LoadAsync(ObjectDelegate);
	return Receiver.ObjectLoadCount == 1 && Receiver.LastLoadedObject == nullptr;
}
/** @end */
