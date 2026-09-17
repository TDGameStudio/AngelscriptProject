/**
 * @version v1
 * @summary An &inout TSet<int32> receives Append of another set.
 * @topic Containers
 *
 * MutateAppendOtherSet
 */
/**
 * @begin MutateAppendOtherSet
 * @summary An &inout TSet<int32> receives Append of another set.
 * @topic Containers
 */
void MutateAppendOtherSet(TSet<int32>&inout Values)
{
	TSet<int32> Other;
	Other.Add(3);
	Other.Add(4);
	Values.Append(Other);
}
/** @end */
