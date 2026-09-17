/**
 * @version v1
 * @summary A const&in TArray<FString> reports Shuffle membership.
 * @topic Containers
 *
 * ReadShufflePreservesMembershipFString
 */
/**
 * @begin ReadShufflePreservesMembershipFString
 * @summary A const&in TArray<FString> reports Shuffle membership.
 * @topic Containers
 */
bool ReadShufflePreservesMembershipFString(const TArray<FString>&in Values)
{
	return Values.Num() == 3 && Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma");
}
/** @end */
