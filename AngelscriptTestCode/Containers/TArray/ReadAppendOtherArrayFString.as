/**
 * @version v1
 * @summary A const&in TArray<FString> reports Append order.
 * @topic Containers
 *
 * ReadAppendOtherArrayFString
 */
/**
 * @begin ReadAppendOtherArrayFString
 * @summary A const&in TArray<FString> reports Append order.
 * @topic Containers
 */
bool ReadAppendOtherArrayFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3 && Values[0] == "alpha" && Values[1] == "beta" && Values[2] == "gamma";
}
/** @end */
