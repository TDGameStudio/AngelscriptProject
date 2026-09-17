/**
 * @version v1
 * @summary Reserve(100) grows Max on TArray<FString> before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 *
 * ReserveGrowsMaxWithoutChangingNumFString
 */
/**
 * @begin ReserveGrowsMaxWithoutChangingNumFString
 * @summary Reserve(100) grows Max on TArray<FString> before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 */
bool ReserveGrowsMaxWithoutChangingNumFString()
{
	TArray<FString> Values;
	Values.Reserve(100);
	if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
	{
		return false;
	}

	for (int Index = 0; Index < 10; ++Index)
	{
		Values.Add("alpha");
	}
	return Values.Num() == 10 && Values[0] == "alpha" && Values[9] == "alpha" && Values.Max() >= 100;
}
/** @end */
