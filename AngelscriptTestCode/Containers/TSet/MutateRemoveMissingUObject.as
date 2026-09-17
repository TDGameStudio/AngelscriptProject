/**
 * @version v1
 * @summary An &inout TSet<UObject> receives Remove of an absent handle.
 * @topic Containers
 *
 * MutateRemoveMissingUObject
 */
/**
 * @begin MutateRemoveMissingUObject
 * @summary An &inout TSet<UObject> receives Remove of an absent handle.
 * @topic Containers
 */
UCLASS()
class UTSetMutateRemoveMissingUObjectHost : UObject
{
}

void MutateRemoveMissingUObject(TSet<UObject>&inout Values)
{
	Values.Remove(NewObject(GetTransientPackage(), UTSetMutateRemoveMissingUObjectHost::StaticClass(), n"MutateRemoveMissing_Missing", true));
}
/** @end */
