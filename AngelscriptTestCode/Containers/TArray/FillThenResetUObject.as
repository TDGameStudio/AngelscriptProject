/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then emptied by Reset.
 * @topic Containers
 *
 * FillThenResetUObject
 */
/**
 * @begin FillThenResetUObject
 * @summary An &out TArray<UObject> is filled then emptied by Reset.
 * @topic Containers
 */
UCLASS()
class UTArrayFillThenResetUObjectHost : UObject
{
}

void FillThenResetUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillThenResetUObjectHost::StaticClass(), n"FillThenReset_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillThenResetUObjectHost::StaticClass(), n"FillThenReset_1", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillThenResetUObjectHost::StaticClass(), n"FillThenReset_2", true));
	Result.Reset();
}
/** @end */
