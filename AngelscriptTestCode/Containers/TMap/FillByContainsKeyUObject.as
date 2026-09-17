/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled with a Contains sequence.
 * @topic Containers
 *
 * FillByContainsKeyUObject
 */
/**
 * @begin FillByContainsKeyUObject
 * @summary An &out TMap<int, UObject> is filled with a Contains sequence.
 * @topic Containers
 */
UCLASS()
class UTMapFillByContainsKeyUObjectHost : UObject
{
}

void FillByContainsKeyUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByContainsKeyUObjectHost::StaticClass(), n"Contains_Fill_0", true));
	Result.Add(20, NewObject(GetTransientPackage(), UTMapFillByContainsKeyUObjectHost::StaticClass(), n"Contains_Fill_1", true));
	Result.Add(30, NewObject(GetTransientPackage(), UTMapFillByContainsKeyUObjectHost::StaticClass(), n"Contains_Fill_2", true));
}
/** @end */
