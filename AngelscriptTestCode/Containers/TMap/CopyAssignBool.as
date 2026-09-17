/**
 * @version v1
 * @summary Copy assignment copies bool pairs and stays independent of later source inserts.
 * @topic Containers
 *
 * CopyAssignBool
 */
/**
 * @begin CopyAssignBool
 * @summary Copy assignment copies bool pairs and stays independent of later source inserts.
 * @topic Containers
 */
bool CopyAssignBool()
{
	TMap<int, bool> Other;
	Other.Add(1, true);
	TMap<int, bool> Map;
	Map = Other;
	bool bCopied = Map.Num() == 1 && Map.Contains(1) && Map[1] == true;
	Other.Add(2, false);
	return bCopied && !Map.Contains(2) && Map.Num() == 1 && Other.Num() == 2;
}
/** @end */
