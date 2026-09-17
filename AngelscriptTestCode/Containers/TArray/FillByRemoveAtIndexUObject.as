/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then RemoveAt drops the first index.
 * @topic Containers
 *
 * FillByRemoveAtIndexUObject
 */
/**
 * @begin FillByRemoveAtIndexUObject
 * @summary An &out TArray<UObject> is filled then RemoveAt drops the first index.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByRemoveAtIndexUObjectHost : UObject
{
}

void FillByRemoveAtIndexUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByRemoveAtIndexUObjectHost::StaticClass(), n"FillByRemoveAtIndex_A", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByRemoveAtIndexUObjectHost::StaticClass(), n"FillByRemoveAtIndex_B", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByRemoveAtIndexUObjectHost::StaticClass(), n"FillByRemoveAtIndex_C", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByRemoveAtIndexUObjectHost::StaticClass(), n"FillByRemoveAtIndex_D", true));
	Result.RemoveAt(0);
}
/** @end */
