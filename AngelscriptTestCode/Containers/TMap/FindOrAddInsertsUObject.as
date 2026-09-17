/**
 * @version v1
 * @summary FindOrAdd of a missing int key inserts a default UObject handle and does not throw.
 * @topic Containers
 *
 * FindOrAddInsertsUObject
 */
/**
 * @begin FindOrAddInsertsUObject
 * @summary FindOrAdd of a missing int key inserts a default UObject handle and does not throw.
 * @topic Containers
 */
UCLASS()
class UTMapFindOrAddInsertsUObjectHost : UObject
{
}

bool FindOrAddInsertsUObject()
{
	TMap<int, UObject> Map;
	UObject Probe = NewObject(GetTransientPackage(), UTMapFindOrAddInsertsUObjectHost::StaticClass(), n"FindOrAddInserts_Probe", true);
	UObject Added = Map.FindOrAdd(20);
	return Probe != nullptr && Added == nullptr && Map.Num() == 1 && Map.Contains(20) && Map[20] == nullptr;
}
/** @end */
