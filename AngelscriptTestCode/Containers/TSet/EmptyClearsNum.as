/**
 * @version v1
 * @summary Empty clears every member so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNum
 */
/**
 * @begin EmptyClearsNum
 * @summary Empty clears every member so Num is 0.
 * @topic Containers
 */
bool EmptyClearsNum()
{
	TSet<int32> Values;
	Values.Add(1);
	Values.Empty();
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
