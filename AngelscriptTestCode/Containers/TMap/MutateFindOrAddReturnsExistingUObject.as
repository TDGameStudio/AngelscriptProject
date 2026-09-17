/**
 * @version v1
 * @summary An &inout TMap<int, UObject> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 *
 * MutateFindOrAddReturnsExistingUObject
 */
/**
 * @begin MutateFindOrAddReturnsExistingUObject
 * @summary An &inout TMap<int, UObject> calls FindOrAdd with a default that is ignored for an existing key.
 * @topic Containers
 */
UCLASS()
class UTMapMutateFindOrAddReturnsExistingUObjectHost : UObject
{
}

void MutateFindOrAddReturnsExistingUObject(TMap<int, UObject>&inout Values)
{
	Values.FindOrAdd(10, NewObject(GetTransientPackage(), UTMapMutateFindOrAddReturnsExistingUObjectHost::StaticClass(), n"FindOrAddExisting_Mutate", true));
}
/** @end */
