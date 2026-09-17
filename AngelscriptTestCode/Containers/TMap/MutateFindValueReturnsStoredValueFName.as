/**
 * @version v1
 * @summary An &inout TMap<FName, int> Adds one pair so Find can hit a new key.
 * @topic Containers
 *
 * MutateFindValueReturnsStoredValueFName
 */
/**
 * @begin MutateFindValueReturnsStoredValueFName
 * @summary An &inout TMap<FName, int> Adds one pair so Find can hit a new key.
 * @topic Containers
 */
void MutateFindValueReturnsStoredValueFName(TMap<FName, int>&inout Values)
{
	Values.Add(n"Blue", 3);
}
/** @end */
