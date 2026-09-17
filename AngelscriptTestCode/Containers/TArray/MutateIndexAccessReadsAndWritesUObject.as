/**
 * @version v1
 * @summary An &inout TArray<UObject> writes one [] handle in place.
 * @topic Containers
 *
 * MutateIndexAccessReadsAndWritesUObject
 */
/**
 * @begin MutateIndexAccessReadsAndWritesUObject
 * @summary An &inout TArray<UObject> writes one [] handle in place.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateIndexAccessReadsAndWritesUObjectHost : UObject
{
}

void MutateIndexAccessReadsAndWritesUObject(TArray<UObject>&inout Values)
{
	Values[1] = NewObject(GetTransientPackage(), UTArrayMutateIndexAccessReadsAndWritesUObjectHost::StaticClass(), n"MutateIndex_Wrote", true);
}
/** @end */
