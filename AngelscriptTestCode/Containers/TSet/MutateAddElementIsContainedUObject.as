/**
 * @version v1
 * @summary An &inout TSet<UObject> receives Add of a new NewObject handle.
 * @topic Containers
 *
 * MutateAddElementIsContainedUObject
 */
/**
 * @begin MutateAddElementIsContainedUObject
 * @summary An &inout TSet<UObject> receives Add of a new NewObject handle.
 * @topic Containers
 */
UCLASS()
class UTSetMutateAddElementIsContainedUObjectHost : UObject
{
}

void MutateAddElementIsContainedUObject(TSet<UObject>&inout Values)
{
	Values.Add(NewObject(GetTransientPackage(), UTSetMutateAddElementIsContainedUObjectHost::StaticClass(), n"MutateAddElementIsContained_New", true));
}
/** @end */
