/**
 * @version v1
 * @summary An &inout TArray<UObject> has its first matching handle deleted by RemoveSingle.
 * @topic Containers
 *
 * MutateRemoveSinglePreservesOrderUObject
 */
/**
 * @begin MutateRemoveSinglePreservesOrderUObject
 * @summary An &inout TArray<UObject> has its first matching handle deleted by RemoveSingle.
 * @topic Containers
 */
void MutateRemoveSinglePreservesOrderUObject(TArray<UObject>&inout Values)
{
	UObject Match = Values[1];
	Values.RemoveSingle(Match);
}
/** @end */
