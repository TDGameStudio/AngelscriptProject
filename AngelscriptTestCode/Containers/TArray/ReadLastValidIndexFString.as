/**
 * @version v1
 * @summary A const&in TArray<FString> reports Last() and Last(1) from the end.
 * @topic Containers
 *
 * ReadLastValidIndexFString
 */
/**
 * @begin ReadLastValidIndexFString
 * @summary A const&in TArray<FString> reports Last() and Last(1) from the end.
 * @topic Containers
 */
bool ReadLastValidIndexFString(const TArray<FString>&in Values)
{
	return Values.Last() == "gamma" && Values.Last(1) == "beta" && Values.Last(2) == "alpha";
}
/** @end */
