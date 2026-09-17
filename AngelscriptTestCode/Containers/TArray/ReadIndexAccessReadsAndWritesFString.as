/**
 * @version v1
 * @summary A const&in TArray<FString> reports [] insertion order.
 * @topic Containers
 *
 * ReadIndexAccessReadsAndWritesFString
 */
/**
 * @begin ReadIndexAccessReadsAndWritesFString
 * @summary A const&in TArray<FString> reports [] insertion order.
 * @topic Containers
 */
bool ReadIndexAccessReadsAndWritesFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3 && Values[0] == "alpha" && Values[1] == "beta" && Values[2] == "gamma";
}
/** @end */
