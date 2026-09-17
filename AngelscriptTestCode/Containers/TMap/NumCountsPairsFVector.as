/**
 * @version v1
 * @summary Num counts distinct int keys in a TMap of FVector values; overwrite does not grow Num.
 * @topic Containers
 *
 * NumCountsPairsFVector
 */
/**
 * @begin NumCountsPairsFVector
 * @summary Num counts distinct int keys in a TMap of FVector values; overwrite does not grow Num.
 * @topic Containers
 */
bool NumCountsPairsFVector()
{
	TMap<int, FVector> Map;
	if (Map.Num() != 0)
	{
		return false;
	}

	Map.Add(1, FVector(1.0f, 0.0f, 0.0f));
	if (Map.Num() != 1)
	{
		return false;
	}

	Map.Add(2, FVector(0.0f, 1.0f, 0.0f));
	Map.Add(1, FVector(9.0f, 9.0f, 9.0f));
	return Map.Num() == 2;
}
/** @end */
