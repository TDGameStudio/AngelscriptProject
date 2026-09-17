/**
 * @version v1
 * @summary A const&in TArray<FString> reports the array after Remove deleted every match.
 * @topic Containers
 *
 * ReadRemoveAllMatchesFString
 */
/**
 * @begin ReadRemoveAllMatchesFString
 * @summary A const&in TArray<FString> reports the array after Remove deleted every match.
 * @topic Containers
 */
bool ReadRemoveAllMatchesFString(const TArray<FString>&in Values)
{
	return Values.Num() == 4
		&& Values[0] == "alpha" && Values[1] == "gamma" && Values[2] == "delta" && Values[3] == "echo";
}
/** @end */
