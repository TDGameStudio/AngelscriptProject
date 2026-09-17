/**
 * @version v1
 * @summary An &inout TArray<UObject> has every matching handle deleted by Remove.
 * @topic Containers
 *
 * MutateRemoveAllMatchesUObject
 */
/**
 * @begin MutateRemoveAllMatchesUObject
 * @summary An &inout TArray<UObject> has every matching handle deleted by Remove.
 * @topic Containers
 */
void MutateRemoveAllMatchesUObject(TArray<UObject>&inout Values)
{
	UObject Match = Values[1];
	Values.Remove(Match);
}
/** @end */
