/**
 * @version v1
 * @summary Copy assignment copies UObject pairs and stays independent of later source inserts.
 * @topic Containers
 *
 * CopyAssignUObject
 */
/**
 * @begin CopyAssignUObject
 * @summary Copy assignment copies UObject pairs and stays independent of later source inserts.
 * @topic Containers
 */
UCLASS()
class UTMapCopyAssignUObjectHost : UObject
{
}

bool CopyAssignUObject()
{
	TMap<int, UObject> Other;
	UObject First = NewObject(GetTransientPackage(), UTMapCopyAssignUObjectHost::StaticClass(), n"CopyAssign_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTMapCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}
	Other.Add(10, First);
	TMap<int, UObject> Map;
	Map = Other;
	bool bCopied = Map.Num() == 1 && Map.Contains(10) && Map[10] == First;
	Other.Add(20, Second);
	return bCopied && !Map.Contains(20) && Map.Num() == 1 && Other.Num() == 2;
}
/** @end */
