/**
 * @version v1
 * @summary Shuffle keeps Num and membership of every original FString.
 * @topic Containers
 *
 * ShufflePreservesMembershipFString
 */
/**
 * @begin ShufflePreservesMembershipFString
 * @summary Shuffle keeps Num and membership of every original FString.
 * @topic Containers
 */
bool ShufflePreservesMembershipFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("gamma");
	Values.Shuffle();
	return Values.Num() == 3 && Values.Contains("alpha") && Values.Contains("beta") && Values.Contains("gamma");
}
/** @end */
