/**
 * @version v1
 * @summary Add appends FString values in insertion order.
 * @topic Containers
 *
 * AddAndOrderFString
 */
/**
 * @begin AddAndOrderFString
 * @summary Add appends FString values in insertion order.
 * @topic Containers
 */
bool AddAndOrderFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	return Values.Num() == 2 && Values[0] == "alpha" && Values[1] == "beta";
}
/** @end */
