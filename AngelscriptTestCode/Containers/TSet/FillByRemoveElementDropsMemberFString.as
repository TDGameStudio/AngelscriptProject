/**
 * @version v1
 * @summary An &out TSet<FString> is filled then Remove drops one member.
 * @topic Containers
 *
 * FillByRemoveElementDropsMemberFString
 */
/**
 * @begin FillByRemoveElementDropsMemberFString
 * @summary An &out TSet<FString> is filled then Remove drops one member.
 * @topic Containers
 */
void FillByRemoveElementDropsMemberFString(TSet<FString>&out Result)
{
	Result.Add("alpha");
	Result.Add("beta");
	Result.Remove("alpha");
}
/** @end */
