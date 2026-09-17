/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled then Remove drops the middle key.
 * @topic Containers
 *
 * FillByRemoveKeyDropsPairUObject
 */
/**
 * @begin FillByRemoveKeyDropsPairUObject
 * @summary An &out TMap<int, UObject> is filled then Remove drops the middle key.
 * @topic Containers
 */
UCLASS()
class UTMapFillByRemoveKeyDropsPairUObjectHost : UObject
{
}

void FillByRemoveKeyDropsPairUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByRemoveKeyDropsPairUObjectHost::StaticClass(), n"RemoveKey_Fill_0", true));
	Result.Add(20, NewObject(GetTransientPackage(), UTMapFillByRemoveKeyDropsPairUObjectHost::StaticClass(), n"RemoveKey_Fill_1", true));
	Result.Add(30, NewObject(GetTransientPackage(), UTMapFillByRemoveKeyDropsPairUObjectHost::StaticClass(), n"RemoveKey_Fill_2", true));
	Result.Remove(20);
}
/** @end */
