/**
 * @version v1
 * @summary LoadAsync of an already-loaded UObject invokes the handler with that object.
 * @topic Containers
 * LoadAsyncInvokesHandler
 */
/**
 * @begin LoadAsyncInvokesHandler
 * @summary LoadAsync of an already-loaded UObject invokes the handler with that object.
 * @topic Containers
 */
UCLASS()
class UTSSoftObjectPtrLoadAsyncReceiver : UObject
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

bool LoadAsyncInvokesHandler()
{
	UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		return false;
	}

	UTSSoftObjectPtrLoadAsyncReceiver Receiver = Cast<UTSSoftObjectPtrLoadAsyncReceiver>(
		NewObject(GetTransientPackage(), UTSSoftObjectPtrLoadAsyncReceiver::StaticClass(), n"TSSoftObjectPtrLoadAsyncReceiver", true));
	if (Receiver is null)
	{
		return false;
	}

	FOnSoftObjectLoaded ObjectDelegate;
	ObjectDelegate.BindUFunction(Receiver, n"HandleObjectLoaded");
	TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
	ObjectRef.LoadAsync(ObjectDelegate);
	return Receiver.ObjectLoadCount == 1 && Receiver.LastLoadedObject == LiveCdo;
}
/** @end */
