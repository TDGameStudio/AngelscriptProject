/**
 * @version v1
 * @summary A const&in TArray<float> reports Shuffle membership.
 * @topic Containers
 *
 * ReadShufflePreservesMembershipFloat
 */
/**
 * @begin ReadShufflePreservesMembershipFloat
 * @summary A const&in TArray<float> reports Shuffle membership.
 * @topic Containers
 */
bool ReadShufflePreservesMembershipFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3 && Values.Contains(10.0f) && Values.Contains(20.0f) && Values.Contains(30.0f);
}
/** @end */
