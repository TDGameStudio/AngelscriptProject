/**
 * @version v1
 * @summary An &inout TMap<int, UObject> Adds one pair so GetKeys Num becomes 3.
 * @topic Containers
 *
 * MutateGetKeysListsPresentKeysUObject
 */
/**
 * @begin MutateGetKeysListsPresentKeysUObject
 * @summary An &inout TMap<int, UObject> Adds one pair so GetKeys Num becomes 3.
 * @topic Containers
 */
UCLASS()
class UTMapMutateGetKeysListsPresentKeysUObjectHost : UObject
{
}

void MutateGetKeysListsPresentKeysUObject(TMap<int, UObject>&inout Values)
{
	Values.Add(30, NewObject(GetTransientPackage(), UTMapMutateGetKeysListsPresentKeysUObjectHost::StaticClass(), n"GetKeys_Mutate", true));
}
/** @end */
