/**
 * @version v1
 * @summary An &inout TMap<int, bool> Adds one pair so Find can hit a new key.
 * @topic Containers
 *
 * MutateFindValueReturnsStoredValueBool
 */
/**
 * @begin MutateFindValueReturnsStoredValueBool
 * @summary An &inout TMap<int, bool> Adds one pair so Find can hit a new key.
 * @topic Containers
 */
void MutateFindValueReturnsStoredValueBool(TMap<int, bool>&inout Values)
{
	Values.Add(3, true);
}
/** @end */
