/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled by Add then overwrite of the same key.
 * @topic Containers
 *
 * FillByAddOverwriteReplacesValueUObject
 */
/**
 * @begin FillByAddOverwriteReplacesValueUObject
 * @summary An &out TMap<int, UObject> is filled by Add then overwrite of the same key.
 * @topic Containers
 */
UCLASS()
class UTMapFillByAddOverwriteReplacesValueUObjectHost : UObject
{
}

void FillByAddOverwriteReplacesValueUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByAddOverwriteReplacesValueUObjectHost::StaticClass(), n"AddOverwrite_Fill_0", true));
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByAddOverwriteReplacesValueUObjectHost::StaticClass(), n"AddOverwrite_Fill_1", true));
}
/** @end */
