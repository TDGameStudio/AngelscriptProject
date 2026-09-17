/**
 * @version v1
 * @summary Add grows Num for new FString members only.
 * @topic Containers
 *
 * AddElementIsContainedFString
 */
/**
 * @begin AddElementIsContainedFString
 * @summary Add grows Num for new FString members only.
 * @topic Containers
 */
bool AddElementIsContainedFString()
{
	TSet<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	return Values.Num() == 2 && Values.Contains("alpha") && Values.Contains("beta");
}
/** @end */
