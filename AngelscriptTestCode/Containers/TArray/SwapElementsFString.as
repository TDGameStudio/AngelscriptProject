/**
 * @version v1
 * @summary Swap(0, 2) exchanges FString ends while the middle value stays.
 * @topic Containers
 *
 * SwapElementsFString
 */
/**
 * @begin SwapElementsFString
 * @summary Swap(0, 2) exchanges FString ends while the middle value stays.
 * @topic Containers
 */
bool SwapElementsFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Add("gamma");
	Values.Swap(0, 2);
	Values.Swap(1, 1);
	return Values[0] == "gamma" && Values[2] == "alpha" && Values[1] == "beta" && Values.Num() == 3;
}
/** @end */
