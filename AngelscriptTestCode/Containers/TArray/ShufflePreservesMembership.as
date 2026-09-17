/**
 * @version v1
 * @summary Shuffle keeps Num and membership of every original element.
 * @topic Containers
 *
 * ShufflePreservesMembership
 */
/**
 * @begin ShufflePreservesMembership
 * @summary Shuffle keeps Num and membership of every original element.
 * @topic Containers
 */
bool ShufflePreservesMembership()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Add(3);
	Values.Shuffle();
	return Values.Num() == 3 && Values.Contains(1) && Values.Contains(2) && Values.Contains(3);
}
/** @end */
