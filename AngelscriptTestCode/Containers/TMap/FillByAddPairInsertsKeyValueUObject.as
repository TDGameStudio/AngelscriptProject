/**
 * @version v1
 * @summary An &out TMap<int, UObject> is filled by Add of three NewObject handles.
 * @topic Containers
 *
 * FillByAddPairInsertsKeyValueUObject
 */
/**
 * @begin FillByAddPairInsertsKeyValueUObject
 * @summary An &out TMap<int, UObject> is filled by Add of three NewObject handles.
 * @topic Containers
 */
UCLASS()
class UTMapFillByAddPairInsertsKeyValueUObjectHost : UObject
{
}

void FillByAddPairInsertsKeyValueUObject(TMap<int, UObject>&out Result)
{
	Result.Add(10, NewObject(GetTransientPackage(), UTMapFillByAddPairInsertsKeyValueUObjectHost::StaticClass(), n"AddPair_Fill_0", true));
	Result.Add(20, NewObject(GetTransientPackage(), UTMapFillByAddPairInsertsKeyValueUObjectHost::StaticClass(), n"AddPair_Fill_1", true));
	Result.Add(30, NewObject(GetTransientPackage(), UTMapFillByAddPairInsertsKeyValueUObjectHost::StaticClass(), n"AddPair_Fill_2", true));
}
/** @end */
