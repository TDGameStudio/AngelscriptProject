/**
 * @version v1
 * @summary An &inout TArray<UObject> Adds one NewObject so Num grows by one.
 * @topic Containers
 *
 * MutateNumCountsElementsUObject
 */
/**
 * @begin MutateNumCountsElementsUObject
 * @summary An &inout TArray<UObject> Adds one NewObject so Num grows by one.
 * @topic Containers
 */
UCLASS()
class UTArrayMutateNumCountsElementsUObjectHost : UObject
{
}

void MutateNumCountsElementsUObject(TArray<UObject>&inout Values)
{
	Values.Add(NewObject(GetTransientPackage(), UTArrayMutateNumCountsElementsUObjectHost::StaticClass(), n"MutateNum_Tail", true));
}
/** @end */
