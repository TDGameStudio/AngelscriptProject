/**
 * @version v1
 * @summary GetValues copies every stored FVector into the destination array.
 * @topic Containers
 *
 * GetValuesListsStoredValuesFVector
 */
/**
 * @begin GetValuesListsStoredValuesFVector
 * @summary GetValues copies every stored FVector into the destination array.
 * @topic Containers
 */
bool GetValuesListsStoredValuesFVector()
{
	TMap<int, FVector> Map;
	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
	TArray<FVector> Values;
	Map.GetValues(Values);
	if (Values.Num() != 2)
	{
		return false;
	}
	bool bHasX = false;
	bool bHasY = false;
	for (FVector Value : Values)
	{
		if (Value.Equals(FVector(1.0f, 0.0f, 0.0f)))
		{
			bHasX = true;
		}
		if (Value.Equals(FVector(0.0f, 1.0f, 0.0f)))
		{
			bHasY = true;
		}
	}
	return bHasX && bHasY;
}
/** @end */
