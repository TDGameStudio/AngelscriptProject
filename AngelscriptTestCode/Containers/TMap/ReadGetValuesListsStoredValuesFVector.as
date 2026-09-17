/**
 * @version v1
 * @summary A const&in TMap<int, FVector> reports GetValues membership without writing the map back.
 * @topic Containers
 *
 * ReadGetValuesListsStoredValuesFVector
 */
/**
 * @begin ReadGetValuesListsStoredValuesFVector
 * @summary A const&in TMap<int, FVector> reports GetValues membership without writing the map back.
 * @topic Containers
 */
bool ReadGetValuesListsStoredValuesFVector(const TMap<int, FVector>&in Values)
{
	TArray<FVector> OutValues;
	Values.GetValues(OutValues);
	if (OutValues.Num() != 3)
	{
		return false;
	}
	bool bHasX = false;
	bool bHasY = false;
	bool bHasZ = false;
	for (FVector Value : OutValues)
	{
		if (Value.Equals(FVector(1.0f, 0.0f, 0.0f)))
		{
			bHasX = true;
		}
		if (Value.Equals(FVector(0.0f, 1.0f, 0.0f)))
		{
			bHasY = true;
		}
		if (Value.Equals(FVector(0.0f, 0.0f, 1.0f)))
		{
			bHasZ = true;
		}
	}
	return bHasX && bHasY && bHasZ;
}
/** @end */
