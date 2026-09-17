/**
 * @version v1
 * @summary Copy assignment copies pairs and stays independent of later source inserts.
 * @topic Containers
 *
 * CopyAssign
 */
/**
 * @begin CopyAssign
 * @summary Copy assignment copies pairs and stays independent of later source inserts.
 * @topic Containers
 */
bool CopyAssign()
{
	TMap<FName, int32> Other;
	Other.Add(n"Alpha", 1);
	TMap<FName, int32> Map;
	Map = Other;
	bool bCopied = Map.Num() == 1 && Map.Contains(n"Alpha") && Map[n"Alpha"] == 1;
	Other.Add(n"Beta", 2);
	bool bCopyIndependent = !Map.Contains(n"Beta") && Map.Num() == 1 && Other.Num() == 2;
	TMap<FString, int32> StringOther;
	StringOther.Add("Key", 7);
	TMap<FString, int32> StringMap;
	StringMap = StringOther;
	return bCopied && bCopyIndependent
		&& StringMap.Num() == 1 && StringMap.Contains("Key") && StringMap["Key"] == 7;
}
/** @end */
