/**
 * @version v1
 * @summary An &inout TSet<bool> receives Append of another set.
 * @topic Containers
 *
 * MutateAppendOtherSetBool
 */
/**
 * @begin MutateAppendOtherSetBool
 * @summary An &inout TSet<bool> receives Append of another set.
 * @topic Containers
 */
void MutateAppendOtherSetBool(TSet<bool>&inout Values)
{
	TSet<bool> Other;
	Other.Add(false);
	Values.Append(Other);
}
/** @end */
