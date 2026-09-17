/**
 * @version v1
 * @summary Copy assignment copies FName-key pairs and stays independent of later source inserts.
 * @topic Containers
 *
 * CopyAssignFName
 */
/**
 * @begin CopyAssignFName
 * @summary Copy assignment copies FName-key pairs and stays independent of later source inserts.
 * @topic Containers
 */
bool CopyAssignFName()
{
	TMap<FName, int> Other;
	Other.Add(n"Red", 1);
	TMap<FName, int> Map;
	Map = Other;
	bool bCopied = Map.Num() == 1 && Map.Contains(n"Red") && Map[n"Red"] == 1;
	Other.Add(n"Green", 2);
	return bCopied && !Map.Contains(n"Green") && Map.Num() == 1 && Other.Num() == 2;
}
/** @end */
