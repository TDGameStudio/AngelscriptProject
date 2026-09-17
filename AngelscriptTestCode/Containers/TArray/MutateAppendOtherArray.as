/**
 * @version v1
 * @summary An &inout TArray<int32> receives Append of another array.
 * @topic Containers
 *
 * MutateAppendOtherArray
 */
/**
 * @begin MutateAppendOtherArray
 * @summary An &inout TArray<int32> receives Append of another array.
 * @topic Containers
 */
void MutateAppendOtherArray(TArray<int32>&inout Values)
{
	TArray<int32> Other;
	Other.Add(20);
	Other.Add(30);
	Values.Append(Other);
}
/** @end */
