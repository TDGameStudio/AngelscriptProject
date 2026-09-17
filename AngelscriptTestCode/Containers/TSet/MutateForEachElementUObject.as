/**
 * @version v1
 * @summary An &inout TSet<UObject> receives Add of one more member.
 * @topic Containers
 *
 * MutateForEachElementUObject
 */
/**
 * @begin MutateForEachElementUObject
 * @summary An &inout TSet<UObject> receives Add of one more member.
 * @topic Containers
 */
UCLASS()
class UTSetMutateForEachElementUObjectHost : UObject
{
}

void MutateForEachElementUObject(TSet<UObject>&inout Values)
{
	Values.Add(NewObject(GetTransientPackage(), UTSetMutateForEachElementUObjectHost::StaticClass(), n"MutateForEachElement_New", true));
}
/** @end */
