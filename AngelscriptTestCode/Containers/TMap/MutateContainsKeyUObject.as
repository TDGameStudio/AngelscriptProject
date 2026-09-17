/**
 * @version v1
 * @summary An &inout TMap<int, UObject> Adds one pair so Contains can see a new key.
 * @topic Containers
 *
 * MutateContainsKeyUObject
 */
/**
 * @begin MutateContainsKeyUObject
 * @summary An &inout TMap<int, UObject> Adds one pair so Contains can see a new key.
 * @topic Containers
 */
UCLASS()
class UTMapMutateContainsKeyUObjectHost : UObject
{
}

void MutateContainsKeyUObject(TMap<int, UObject>&inout Values)
{
	Values.Add(30, NewObject(GetTransientPackage(), UTMapMutateContainsKeyUObjectHost::StaticClass(), n"Contains_Mutate", true));
}
/** @end */
