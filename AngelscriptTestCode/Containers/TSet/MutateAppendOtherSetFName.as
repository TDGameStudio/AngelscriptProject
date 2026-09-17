/**
 * @version v1
 * @summary An &inout TSet<FName> receives Append of another set.
 * @topic Containers
 *
 * MutateAppendOtherSetFName
 */
/**
 * @begin MutateAppendOtherSetFName
 * @summary An &inout TSet<FName> receives Append of another set.
 * @topic Containers
 */
void MutateAppendOtherSetFName(TSet<FName>&inout Values)
{
	TSet<FName> Other;
	Other.Add(n"Blue");
	Other.Add(n"Yellow");
	Values.Append(Other);
}
/** @end */
