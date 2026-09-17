/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 *
 * FillByRemoveAndCopyValueUObject
 */
/**
 * @begin FillByRemoveAndCopyValueUObject
 * @summary An &out TMap<int, UObject> is filled then RemoveAndCopyValue drops the pair.
 * @topic Containers
 */
UCLASS()
class UTMapFillByRemoveAndCopyValueUObjectHost : UObject
{
}

void FillByRemoveAndCopyValueUObject(TMap<int, UObject>&out Result)
{
	UObject OutValue = nullptr;
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByRemoveAndCopyValueUObjectHost::StaticClass(), n"RemoveAndCopy_Fill", true));
	Result.RemoveAndCopyValue(10, OutValue);
}
/** @end */
