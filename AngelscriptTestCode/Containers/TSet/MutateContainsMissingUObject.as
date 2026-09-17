/**
 * @version v1
 * @summary An &inout TSet<UObject> receives Add of a present handle only.
 * @topic Containers
 *
 * MutateContainsMissingUObject
 */
/**
 * @begin MutateContainsMissingUObject
 * @summary An &inout TSet<UObject> receives Add of a present handle only.
 * @topic Containers
 */
UCLASS()
class UTSetMutateContainsMissingUObjectHost : UObject
{
}

void MutateContainsMissingUObject(TSet<UObject>&inout Values)
{
	Values.Add(NewObject(GetTransientPackage(), UTSetMutateContainsMissingUObjectHost::StaticClass(), n"MutateContainsMissing_New", true));
}
/** @end */
