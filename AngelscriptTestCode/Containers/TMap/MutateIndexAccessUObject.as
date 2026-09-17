/**
 * @version v1
 * @summary An &inout TMap<int, UObject> writes an existing key through bracket access.
 * @topic Containers
 *
 * MutateIndexAccessUObject
 */
/**
 * @begin MutateIndexAccessUObject
 * @summary An &inout TMap<int, UObject> writes an existing key through bracket access.
 * @topic Containers
 */
UCLASS()
class UTMapMutateIndexAccessUObjectHost : UObject
{
}

void MutateIndexAccessUObject(TMap<int, UObject>&inout Values)
{
	Values[10] = NewObject(GetTransientPackage(), UTMapMutateIndexAccessUObjectHost::StaticClass(), n"Index_Mutate", true);
}
/** @end */
