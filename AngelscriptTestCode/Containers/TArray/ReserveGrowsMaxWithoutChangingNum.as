/**
 * @version v1
 * @summary Reserve(100) grows Max before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 *
 * ReserveGrowsMaxWithoutChangingNum
 */
/**
 * @begin ReserveGrowsMaxWithoutChangingNum
 * @summary Reserve(100) grows Max before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 */
bool ReserveGrowsMaxWithoutChangingNum()
{
	TArray<int32> Values;
	Values.Reserve(100);
	if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
	{
		return false;
	}

	for (int Index = 0; Index < 10; ++Index)
	{
		Values.Add(Index * 10);
	}
	return Values.Num() == 10 && Values[0] == 0 && Values[9] == 90 && Values.Max() >= 100;
}
/** @end */
