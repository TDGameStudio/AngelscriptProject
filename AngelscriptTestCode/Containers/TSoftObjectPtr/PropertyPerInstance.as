/**
 * @version v1
 * @summary Two instances hold independent TSoftObjectPtr UPROPERTY paths.
 * @topic Containers
 * PropertyPerInstance
 */
/**
 * @begin PropertyPerInstance
 * @summary Two instances hold independent TSoftObjectPtr UPROPERTY paths.
 * @topic Containers
 */
UCLASS()
class UTSSoftObjectPtrPropertyPerInstanceHolder : UObject
{
	UPROPERTY()
	TSoftObjectPtr<UObject> ObjectRef;
}

bool PropertyPerInstance()
{
	UTSSoftObjectPtrPropertyPerInstanceHolder First = Cast<UTSSoftObjectPtrPropertyPerInstanceHolder>(
		NewObject(GetTransientPackage(), UTSSoftObjectPtrPropertyPerInstanceHolder::StaticClass(), n"TSSoftObjectPtrProperty_First", true));
	UTSSoftObjectPtrPropertyPerInstanceHolder Second = Cast<UTSSoftObjectPtrPropertyPerInstanceHolder>(
		NewObject(GetTransientPackage(), UTSSoftObjectPtrPropertyPerInstanceHolder::StaticClass(), n"TSSoftObjectPtrProperty_Second", true));
	if (First is null || Second is null || First == Second)
	{
		return false;
	}

	First.ObjectRef = FSoftObjectPath("/Game/AngelscriptTest/SomePackage.SomeAsset");
	return !First.ObjectRef.IsNull() && Second.ObjectRef.IsNull();
}
/** @end */
