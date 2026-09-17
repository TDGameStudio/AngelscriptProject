/**
 * @version v1
 * @summary An &inout TMap<FString, int> Adds one pair so Find can hit a new key.
 * @topic Containers
 *
 * MutateFindValueReturnsStoredValueFString
 */
/**
 * @begin MutateFindValueReturnsStoredValueFString
 * @summary An &inout TMap<FString, int> Adds one pair so Find can hit a new key.
 * @topic Containers
 */
void MutateFindValueReturnsStoredValueFString(TMap<FString, int>&inout Values)
{
	Values.Add("gamma", 300);
}
/** @end */
