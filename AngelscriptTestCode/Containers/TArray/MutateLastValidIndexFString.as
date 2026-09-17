/**
 * @version v1
 * @summary An &inout TArray<FString> overwrites Last() in place.
 * @topic Containers
 *
 * MutateLastValidIndexFString
 */
/**
 * @begin MutateLastValidIndexFString
 * @summary An &inout TArray<FString> overwrites Last() in place.
 * @topic Containers
 */
void MutateLastValidIndexFString(TArray<FString>&inout Values)
{
	Values.Last() = "omega";
}
/** @end */
