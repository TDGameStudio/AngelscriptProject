/**
 * @version v1
 * @summary Shuffle keeps Num and membership of every original bool.
 * @topic Containers
 *
 * ShufflePreservesMembershipBool
 */
/**
 * @begin ShufflePreservesMembershipBool
 * @summary Shuffle keeps Num and membership of every original bool.
 * @topic Containers
 */
bool ShufflePreservesMembershipBool()
{
	TArray<bool> Values;
	Values.Add(true);
	Values.Add(false);
	Values.Add(true);
	Values.Shuffle();
	return Values.Num() == 3 && Values.Contains(true) && Values.Contains(false);
}
/** @end */
