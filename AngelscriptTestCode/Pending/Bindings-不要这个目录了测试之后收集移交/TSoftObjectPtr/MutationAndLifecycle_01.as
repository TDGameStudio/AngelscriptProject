/**
 * @version v1
 * @summary Observe Reset clearing soft object/class pointers and LoadAsync invoking a bound delegate for an already-loaded UObject and UClass.
 * @topic Bindings
 */
/**
 * @version root
 * @summary Observe Reset clearing soft object/class pointers and LoadAsync invoking a bound delegate for an already-loaded UObject and UClass.
 * @topic Baseline
 */
// void TSoftObjectPtr<T>.LoadAsync(FOnSoftObjectLoaded OnLoaded) const;
// void TSoftClassPtr<T>.Reset();
// void TSoftClassPtr<T>.LoadAsync(FOnSoftClassLoaded OnLoaded) const;
// Inputs: Pointers seeded from a live UObject CDO and AActor class, Reset,
// a second Reset, and LoadAsync with BindUFunction receivers. Missing path
// LoadAsync reports null.
// Expected observations: Reset yields IsNull true and empty ToString.
// LoadAsync of an already-loaded UObject CDO increments the receiver count
// with that identity. Missing object LoadAsync reports null. Class LoadAsync
// of AActor delivers AActor::StaticClass().
// Boundary/ownership: Reset does not destroy the referenced UObject.
// LoadAsync of TSoftObjectPtr<AActor> is forbidden and is not called here.

UCLASS()
class UTSSoftObjectPtrLoadReceiver : UObject
{
	UPROPERTY()
	int32 ObjectLoadCount = 0;

	UPROPERTY()
	UObject LastLoadedObject = nullptr;

	UPROPERTY()
	int32 ClassLoadCount = 0;

	UPROPERTY()
	UClass LastLoadedClass = nullptr;

	UFUNCTION()
	void HandleObjectLoaded(UObject Loaded)
	{
		ObjectLoadCount += 1;
		LastLoadedObject = Loaded;
	}

	UFUNCTION()
	void HandleClassLoaded(UClass Loaded)
	{
		ClassLoadCount += 1;
		LastLoadedClass = Loaded;
	}
}

namespace TS_TSoftObjectPtr_MutationAndLifecycle_01
{
	bool Observe_Reset_Nominal()
	{
		AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_MutationAndLifecycle_01 setup: required AActor CDO is null");
		}
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		ObjectRef.Reset();
		bool bObjectReset = ObjectRef.IsNull() && ObjectRef.ToString().IsEmpty();
		ObjectRef.Reset();
		bool bRepeatedObjectReset = ObjectRef.IsNull();

		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		ClassRef.Reset();
		bool bClassReset = ClassRef.IsNull() && ClassRef.ToString().IsEmpty();
		ClassRef.Reset();
		return bObjectReset && bRepeatedObjectReset && bClassReset && ClassRef.IsNull();
	}

	bool Observe_LoadAsync_Nominal()
	{
		UObject LiveCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
		if (LiveCdo is null)
		{
			throw("TS_TSoftObjectPtr_MutationAndLifecycle_01 setup: required UObject CDO is null");
		}
		UTSSoftObjectPtrLoadReceiver Receiver = Cast<UTSSoftObjectPtrLoadReceiver>(
			NewObject(GetTransientPackage(), UTSSoftObjectPtrLoadReceiver::StaticClass(), n"TSSoftObjectPtrLoadReceiver", true));
		if (Receiver is null)
		{
			throw("TS_TSoftObjectPtr_MutationAndLifecycle_01 setup: required Receiver is null");
		}
		Receiver.ObjectLoadCount = 0;
		Receiver.LastLoadedObject = nullptr;
		Receiver.ClassLoadCount = 0;
		Receiver.LastLoadedClass = nullptr;

		FOnSoftObjectLoaded ObjectDelegate;
		ObjectDelegate.BindUFunction(Receiver, n"HandleObjectLoaded");
		TSoftObjectPtr<UObject> ObjectRef = LiveCdo;
		ObjectRef.LoadAsync(ObjectDelegate);
		bool bLoadedObject = Receiver.ObjectLoadCount == 1 && Receiver.LastLoadedObject == LiveCdo;

		FOnSoftObjectLoaded MissingDelegate;
		MissingDelegate.BindUFunction(Receiver, n"HandleObjectLoaded");
		TSoftObjectPtr<UObject> Missing(FSoftObjectPath("/Game/DoesNotExist.DoesNotExist"));
		Missing.LoadAsync(MissingDelegate);
		bool bMissingObject = Receiver.ObjectLoadCount == 2 && Receiver.LastLoadedObject == nullptr;

		FOnSoftClassLoaded ClassDelegate;
		ClassDelegate.BindUFunction(Receiver, n"HandleClassLoaded");
		TSoftClassPtr<AActor> ClassRef = AActor::StaticClass();
		ClassRef.LoadAsync(ClassDelegate);

		return bLoadedObject &&
			bMissingObject &&
			Receiver.ClassLoadCount == 1 &&
			Receiver.LastLoadedClass == AActor::StaticClass();
	}
}
/** @end */
