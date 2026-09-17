/**
 * @version v1
 * @summary Empty clears every FName member so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNumFName
 */
/**
 * @begin EmptyClearsNumFName
 * @summary Empty clears every FName member so Num is 0.
 * @topic Containers
 */
bool EmptyClearsNumFName()
{
	TSet<FName> Values;
	Values.Add(n"Red");
	Values.Empty();
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
