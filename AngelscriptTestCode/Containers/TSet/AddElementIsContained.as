/**
 * @version v1
 * @summary Add grows Num for new members only.
 * @topic Containers
 *
 * AddElementIsContained
 */
/**
 * @begin AddElementIsContained
 * @summary Add grows Num for new members only.
 * @topic Containers
 */
bool AddElementIsContained()
{
	TSet<int32> Values;
	Values.Add(1);
	Values.Add(2);
	return Values.Num() == 2 && Values.Contains(1) && Values.Contains(2);
}
/** @end */
