/**
 * @version v1
 * @summary Shuffle keeps Num and membership of every original float.
 * @topic Containers
 *
 * ShufflePreservesMembershipFloat
 */
/**
 * @begin ShufflePreservesMembershipFloat
 * @summary Shuffle keeps Num and membership of every original float.
 * @topic Containers
 */
bool ShufflePreservesMembershipFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	Values.Add(2.0f);
	Values.Add(3.0f);
	Values.Shuffle();
	return Values.Num() == 3 && Values.Contains(1.0f) && Values.Contains(2.0f) && Values.Contains(3.0f);
}
/** @end */
