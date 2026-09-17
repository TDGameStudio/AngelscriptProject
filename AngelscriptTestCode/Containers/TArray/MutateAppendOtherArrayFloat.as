/**
 * @version v1
 * @summary An &inout TArray<float> receives Append of another array.
 * @topic Containers
 *
 * MutateAppendOtherArrayFloat
 */
/**
 * @begin MutateAppendOtherArrayFloat
 * @summary An &inout TArray<float> receives Append of another array.
 * @topic Containers
 */
void MutateAppendOtherArrayFloat(TArray<float>&inout Values)
{
	TArray<float> Other;
	Other.Add(20.0f);
	Other.Add(30.0f);
	Values.Append(Other);
}
/** @end */
