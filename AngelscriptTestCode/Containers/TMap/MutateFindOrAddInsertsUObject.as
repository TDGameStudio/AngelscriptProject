/**
 * @version v1
 * @summary An &inout TMap<int, UObject> inserts a missing key by FindOrAdd.
 * @topic Containers
 *
 * MutateFindOrAddInsertsUObject
 */
/**
 * @begin MutateFindOrAddInsertsUObject
 * @summary An &inout TMap<int, UObject> inserts a missing key by FindOrAdd.
 * @topic Containers
 */
UCLASS()
class UTMapMutateFindOrAddInsertsUObjectHost : UObject
{
}

void MutateFindOrAddInsertsUObject(TMap<int, UObject>&inout Values)
{
	Values.FindOrAdd(30) = NewObject(GetTransientPackage(), UTMapMutateFindOrAddInsertsUObjectHost::StaticClass(), n"FindOrAddInserts_Mutate", true);
}
/** @end */
