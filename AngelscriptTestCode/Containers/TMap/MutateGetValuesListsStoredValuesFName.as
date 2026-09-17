/**
 * @version v1
 * @summary An &inout TMap<FName, int> Adds one pair so GetValues Num becomes 3.
 * @topic Containers
 *
 * MutateGetValuesListsStoredValuesFName
 */
/**
 * @begin MutateGetValuesListsStoredValuesFName
 * @summary An &inout TMap<FName, int> Adds one pair so GetValues Num becomes 3.
 * @topic Containers
 */
void MutateGetValuesListsStoredValuesFName(TMap<FName, int>&inout Values)
{
	Values.Add(n"Blue", 3);
}
/** @end */
