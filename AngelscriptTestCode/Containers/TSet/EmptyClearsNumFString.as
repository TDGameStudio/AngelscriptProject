/**
 * @version v1
 * @summary Empty clears every FString member so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNumFString
 */
/**
 * @begin EmptyClearsNumFString
 * @summary Empty clears every FString member so Num is 0.
 * @topic Containers
 */
bool EmptyClearsNumFString()
{
	TSet<FString> Values;
	Values.Add("alpha");
	Values.Empty();
	return Values.IsEmpty() && Values.Num() == 0;
}
/** @end */
