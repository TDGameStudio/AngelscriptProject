/**
 * @version v1
 * @summary An &inout TSet<FString> receives Remove of a present member.
 * @topic Containers
 *
 * MutateRemoveElementDropsMemberFString
 */
/**
 * @begin MutateRemoveElementDropsMemberFString
 * @summary An &inout TSet<FString> receives Remove of a present member.
 * @topic Containers
 */
void MutateRemoveElementDropsMemberFString(TSet<FString>&inout Values)
{
	Values.Remove("alpha");
}
/** @end */
