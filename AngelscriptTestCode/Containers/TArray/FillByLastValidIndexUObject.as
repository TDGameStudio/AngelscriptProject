/**
 * @version v1
 * @summary An &out TArray<UObject> is filled so Last() is the tail handle.
 * @topic Containers
 *
 * FillByLastValidIndexUObject
 */
/**
 * @begin FillByLastValidIndexUObject
 * @summary An &out TArray<UObject> is filled so Last() is the tail handle.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByLastValidIndexUObjectHost : UObject
{
}

void FillByLastValidIndexUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByLastValidIndexUObjectHost::StaticClass(), n"FillByLastValidIndex_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByLastValidIndexUObjectHost::StaticClass(), n"FillByLastValidIndex_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByLastValidIndexUObjectHost::StaticClass(), n"FillByLastValidIndex_2", true));
}
/** @end */
