/**
 * @version v1
 * @summary Reserve(100) grows Max on TArray<float> before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 *
 * ReserveGrowsMaxWithoutChangingNumFloat
 */
/**
 * @begin ReserveGrowsMaxWithoutChangingNumFloat
 * @summary Reserve(100) grows Max on TArray<float> before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 */
bool ReserveGrowsMaxWithoutChangingNumFloat()
{
	TArray<float> Values;
	Values.Reserve(100);
	if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
	{
		return false;
	}

	for (int Index = 0; Index < 10; ++Index)
	{
		Values.Add(1.0f);
	}
	return Values.Num() == 10 && Values[0] == 1.0f && Values[9] == 1.0f && Values.Max() >= 100;
}
/** @end */
