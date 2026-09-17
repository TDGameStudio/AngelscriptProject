/**
 * @version v1
 * @summary Copy assignment copies UObject members and stays independent of later source mutation.
 * @topic Containers
 *
 * CopyAssignUObject
 */
/**
 * @begin CopyAssignUObject
 * @summary Copy assignment copies UObject members and stays independent of later source mutation.
 * @topic Containers
 */
UCLASS()
class UTSetCopyAssignUObjectHost : UObject
{
}

bool CopyAssignUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTSetCopyAssignUObjectHost::StaticClass(), n"CopyAssign_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTSetCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Second", true);
	UObject Third = NewObject(GetTransientPackage(), UTSetCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Third", true);
	TSet<UObject> Other;
	Other.Add(First);
	Other.Add(Second);
	TSet<UObject> Values;
	Values = Other;
	Other.Add(Third);
	return Values.Num() == 2
		&& Values.Contains(First)
		&& Values.Contains(Second)
		&& !Values.Contains(Third)
		&& Other.Num() == 3;
}
/** @end */
