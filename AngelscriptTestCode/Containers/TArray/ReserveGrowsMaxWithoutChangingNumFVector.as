/**
 * @version v1
 * @summary Reserve(100) grows Max on TArray<FVector> before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 *
 * ReserveGrowsMaxWithoutChangingNumFVector
 */
/**
 * @begin ReserveGrowsMaxWithoutChangingNumFVector
 * @summary Reserve(100) grows Max on TArray<FVector> before Add and leaves Num 10 after ten Adds.
 * @topic Containers
 */
bool ReserveGrowsMaxWithoutChangingNumFVector()
{
	TArray<FVector> Values;
	Values.Reserve(100);
	if (Values.Num() != 0 || Values.Max() < 100 || Values.GetSlack() < 100)
	{
		return false;
	}

	for (int Index = 0; Index < 10; ++Index)
	{
		Values.Add(FVector(1.0f, 0.0f, 0.0f));
	}
	return Values.Num() == 10
		&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values[9].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Values.Max() >= 100;
}
/** @end */
