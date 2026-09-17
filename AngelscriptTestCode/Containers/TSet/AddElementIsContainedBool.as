/**
 * @version v1
 * @summary Add grows Num for new bool members only.
 * @topic Containers
 *
 * AddElementIsContainedBool
 */
/**
 * @begin AddElementIsContainedBool
 * @summary Add grows Num for new bool members only.
 * @topic Containers
 */
bool AddElementIsContainedBool()
{
	TSet<bool> Values;
	Values.Add(true);
	Values.Add(false);
	return Values.Num() == 2 && Values.Contains(true) && Values.Contains(false);
}
/** @end */
