/**
 * @version v1
 * @summary An &inout TArray<FString> appends a marker in place by range-for ref.
 * @topic Containers
 *
 * MutateForEachElementFString
 */
/**
 * @begin MutateForEachElementFString
 * @summary An &inout TArray<FString> appends a marker in place by range-for ref.
 * @topic Containers
 */
void MutateForEachElementFString(TArray<FString>&inout Values)
{
	for (FString& Value : Values)
	{
		Value = Value + "!";
	}
}
/** @end */
