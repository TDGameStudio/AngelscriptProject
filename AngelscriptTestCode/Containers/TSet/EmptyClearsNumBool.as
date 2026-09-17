/**
 * @version v1
 * @summary Empty clears every bool member so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNumBool
 */
/**
 * @begin EmptyClearsNumBool
 * @summary Empty clears every bool member so Num is 0.
 * @topic Containers
 */
bool EmptyClearsNumBool()
{
	TSet<bool> Values;
	Values.Add(true);
	Values.Empty();
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
