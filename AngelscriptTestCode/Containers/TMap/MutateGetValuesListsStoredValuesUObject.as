/**
 * @version v1
 * @summary An &inout TMap<int, UObject> Adds one pair so GetValues Num becomes 3.
 * @topic Containers
 *
 * MutateGetValuesListsStoredValuesUObject
 */
/**
 * @begin MutateGetValuesListsStoredValuesUObject
 * @summary An &inout TMap<int, UObject> Adds one pair so GetValues Num becomes 3.
 * @topic Containers
 */
UCLASS()
class UTMapMutateGetValuesListsStoredValuesUObjectHost : UObject
{
}

void MutateGetValuesListsStoredValuesUObject(TMap<int, UObject>&inout Values)
{
	Values.Add(30, NewObject(GetTransientPackage(), UTMapMutateGetValuesListsStoredValuesUObjectHost::StaticClass(), n"GetValues_Mutate", true));
}
/** @end */
