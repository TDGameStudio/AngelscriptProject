/**
 * @version v1
 * @summary An &inout TArray<FString> appends a duplicate so FindIndex still hits the first slot.
 * @topic Containers
 *
 * MutateFindIndexReturnsFirstOrMinusOneFString
 */
/**
 * @begin MutateFindIndexReturnsFirstOrMinusOneFString
 * @summary An &inout TArray<FString> appends a duplicate so FindIndex still hits the first slot.
 * @topic Containers
 */
void MutateFindIndexReturnsFirstOrMinusOneFString(TArray<FString>&inout Values)
{
	Values.Add("alpha");
}
/** @end */
