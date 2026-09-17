/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled so GetKeys can list present keys.
 * @topic Containers
 *
 * FillByGetKeysListsPresentKeysUObject
 */
/**
 * @begin FillByGetKeysListsPresentKeysUObject
 * @summary An &out TMap<int, UObject> is filled so GetKeys can list present keys.
 * @topic Containers
 */
UCLASS()
class UTMapFillByGetKeysListsPresentKeysUObjectHost : UObject
{
}

void FillByGetKeysListsPresentKeysUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByGetKeysListsPresentKeysUObjectHost::StaticClass(), n"GetKeys_Fill_0", true));
	Result.Add(20, NewObject(GetTransientPackage(), UTMapFillByGetKeysListsPresentKeysUObjectHost::StaticClass(), n"GetKeys_Fill_1", true));
	Result.Add(30, NewObject(GetTransientPackage(), UTMapFillByGetKeysListsPresentKeysUObjectHost::StaticClass(), n"GetKeys_Fill_2", true));
}
/** @end */
