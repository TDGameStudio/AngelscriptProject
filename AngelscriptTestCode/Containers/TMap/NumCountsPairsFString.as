/**
 * @version v1
 * @summary Num counts distinct FString keys; overwrite does not grow Num.
 * @topic Containers
 *
 * NumCountsPairsFString
 */
/**
 * @begin NumCountsPairsFString
 * @summary Num counts distinct FString keys; overwrite does not grow Num.
 * @topic Containers
 */
bool NumCountsPairsFString()
{
	TMap<FString, int> Map;
	if (Map.Num() != 0)
	{
		return false;
	}

	Map.Add("alpha", 100);
	if (Map.Num() != 1)
	{
		return false;
	}

	Map.Add("beta", 200);
	Map.Add("alpha", 999);
	return Map.Num() == 2;
}
/** @end */
