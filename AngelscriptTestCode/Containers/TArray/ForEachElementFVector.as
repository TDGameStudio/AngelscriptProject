/**
 * @version v1
 * @summary Range-for visits every FVector and indexed range-for adds the index.
 * @topic Containers
 *
 * ForEachElementFVector
 */
/**
 * @begin ForEachElementFVector
 * @summary Range-for visits every FVector and indexed range-for adds the index.
 * @topic Containers
 */
bool ForEachElementFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
	int32 MutableCount = 0;
	for (FVector& Value : Values)
	{
		if (Value.Equals(Values[MutableCount]))
		{
			MutableCount += 1;
		}
	}
	int32 ConstCount = 0;
	const TArray<FVector> ConstValues = Values;
	for (const FVector& Value : ConstValues)
	{
		ConstCount += 1;
	}
	int32 IndexedCount = 0;
	for (int Index, FVector& Value : Values)
	{
		IndexedCount += Index + 1;
	}
	return MutableCount == 3 && ConstCount == 3 && IndexedCount == 6
		&& Values[0].Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
