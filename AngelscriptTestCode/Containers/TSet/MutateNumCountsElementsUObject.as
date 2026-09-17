/**
 * @version v1
 * @summary An &inout TSet<UObject> Adds one value so Num grows by one.
 * @topic Containers
 *
 * MutateNumCountsElementsUObject
 */
/**
 * @begin MutateNumCountsElementsUObject
 * @summary An &inout TSet<UObject> Adds one value so Num grows by one.
 * @topic Containers
 */
UCLASS()
class UTSetMutateNumCountsElementsUObjectHost : UObject
{
}

void MutateNumCountsElementsUObject(TSet<UObject>&inout Values)
{
	Values.Add(NewObject(GetTransientPackage(), UTSetMutateNumCountsElementsUObjectHost::StaticClass(), n"MutateNumCountsElements_New", true));
}
/** @end */
