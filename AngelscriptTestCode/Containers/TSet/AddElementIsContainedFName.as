/**
 * @version v1
 * @summary Add grows Num for new FName members only.
 * @topic Containers
 *
 * AddElementIsContainedFName
 */
/**
 * @begin AddElementIsContainedFName
 * @summary Add grows Num for new FName members only.
 * @topic Containers
 */
bool AddElementIsContainedFName()
{
	TSet<FName> Values;
	Values.Add(n"Red");
	Values.Add(n"Green");
	return Values.Num() == 2 && Values.Contains(n"Red") && Values.Contains(n"Green");
}
/** @end */
