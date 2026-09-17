/**
 * @version v1
 * @summary Copy assignment copies FString-key pairs and stays independent of later source inserts.
 * @topic Containers
 *
 * CopyAssignFString
 */
/**
 * @begin CopyAssignFString
 * @summary Copy assignment copies FString-key pairs and stays independent of later source inserts.
 * @topic Containers
 */
bool CopyAssignFString()
{
	TMap<FString, int> Other;
	Other.Add("alpha", 100);
	TMap<FString, int> Map;
	Map = Other;
	bool bCopied = Map.Num() == 1 && Map.Contains("alpha") && Map["alpha"] == 100;
	Other.Add("beta", 200);
	return bCopied && !Map.Contains("beta") && Map.Num() == 1 && Other.Num() == 2;
}
/** @end */
