/**
 * @version v1
 * @summary Copy assignment copies UObject handles and leaves the source independently mutable.
 * @topic Containers
 *
 * CopyAssignUObject
 */
/**
 * @begin CopyAssignUObject
 * @summary Copy assignment copies UObject handles and leaves the source independently mutable.
 * @topic Containers
 */
UCLASS()
class UTArrayCopyAssignUObjectHost : UObject
{
}

bool CopyAssignUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTArrayCopyAssignUObjectHost::StaticClass(), n"CopyAssign_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Second", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Third", true);
	TArray<UObject> Right;
	Right.Add(First);
	Right.Add(Second);
	TArray<UObject> Left;
	Left = Right;
	bool bCopiedEqual = Left.Num() == 2 && Left[0] == First && Left[1] == Second;
	Right.Add(Third);
	bool bCopyIndependent = Left.Num() == 2 && Right.Num() == 3 && Left[0] == First;
	return bCopiedEqual && bCopyIndependent;
}
/** @end */
