/**
 * @version v1
 * @summary An &inout TMap<int, UObject> receives Add of a third NewObject handle.
 * @topic Containers
 *
 * MutateAddPairInsertsKeyValueUObject
 */
/**
 * @begin MutateAddPairInsertsKeyValueUObject
 * @summary An &inout TMap<int, UObject> receives Add of a third NewObject handle.
 * @topic Containers
 */
UCLASS()
class UTMapMutateAddPairInsertsKeyValueUObjectHost : UObject
{
}

void MutateAddPairInsertsKeyValueUObject(TMap<int, UObject>&inout Values)
{
	Values.Add(30, NewObject(GetTransientPackage(), UTMapMutateAddPairInsertsKeyValueUObjectHost::StaticClass(), n"AddPair_Mutate", true));
}
/** @end */
