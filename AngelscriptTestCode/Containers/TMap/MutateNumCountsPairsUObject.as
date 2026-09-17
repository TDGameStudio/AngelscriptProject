/**
 * @version v1
 * @summary An &inout TMap<int, UObject> Adds one pair so Num becomes 3.
 * @topic Containers
 *
 * MutateNumCountsPairsUObject
 */
/**
 * @begin MutateNumCountsPairsUObject
 * @summary An &inout TMap<int, UObject> Adds one pair so Num becomes 3.
 * @topic Containers
 */
UCLASS()
class UTMapMutateNumCountsPairsUObjectHost : UObject
{
}

void MutateNumCountsPairsUObject(TMap<int, UObject>&inout Values)
{
	Values.Add(30, NewObject(GetTransientPackage(), UTMapMutateNumCountsPairsUObjectHost::StaticClass(), n"Num_Mutate", true));
}
/** @end */
