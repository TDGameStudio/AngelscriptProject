/**
 * @version v1
 * @summary An &inout TMap<int, int> Adds one pair so Find can hit a new key.
 * @topic Containers
 *
 * MutateFindValueReturnsStoredValue
 */
/**
 * @begin MutateFindValueReturnsStoredValue
 * @summary An &inout TMap<int, int> Adds one pair so Find can hit a new key.
 * @topic Containers
 */
void MutateFindValueReturnsStoredValue(TMap<int, int>&inout Values)
{
	Values.Add(30, 300);
}
/** @end */
