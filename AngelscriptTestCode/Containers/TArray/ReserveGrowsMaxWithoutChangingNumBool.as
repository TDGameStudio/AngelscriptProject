/**
 * @version v1
 * @summary Reserve(100) grows Max on TArray<bool> before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 *
 * ReserveGrowsMaxWithoutChangingNumBool
 */
/**
 * @begin ReserveGrowsMaxWithoutChangingNumBool
 * @summary Reserve(100) grows Max on TArray<bool> before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 */
bool ReserveGrowsMaxWithoutChangingNumBool()
{
	TArray<bool> Values;
	Values.Reserve(100);
	if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
	{
		return false;
	}

	for (int Index = 0; Index < 10; ++Index)
	{
		Values.Add(Index % 2 == 0);
	}
	return Values.Num() == 10 && Values[0] == true && Values[1] == false && Values.Max() >= 100;
}
/** @end */
