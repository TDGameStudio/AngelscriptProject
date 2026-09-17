/**
 * @version v1
 * @summary An &out TArray<UObject> is filled by Add of three NewObject handles.
 * @topic Containers
 *
 * FillByAddUObject
 */
/**
 * @begin FillByAddUObject
 * @summary An &out TArray<UObject> is filled by Add of three NewObject handles.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByAddUObjectHost : UObject
{
}

void FillByAddUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByAddUObjectHost::StaticClass(), n"FillByAdd_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByAddUObjectHost::StaticClass(), n"FillByAdd_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByAddUObjectHost::StaticClass(), n"FillByAdd_2", true));
}
/** @end */
