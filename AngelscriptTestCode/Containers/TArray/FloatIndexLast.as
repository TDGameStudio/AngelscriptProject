/**
 * @version v1
 * @summary Last(0.9f) and Last(1.9f) truncate IndexFromEnd toward zero.
 * @topic Containers
 *
 * FloatIndexLast
 */
/**
 * @begin FloatIndexLast
 * @summary Last(0.9f) and Last(1.9f) truncate IndexFromEnd toward zero.
 * @topic Containers
 */
bool FloatIndexLast()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	Values.Add(30);
	return Values.Last(0.9f) == 30 && Values.Last(1.9f) == 20;
}
/** @end */
