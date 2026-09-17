/**
 * @version v1
 * @summary Copy assignment copies TOptional<UObject> set state and handle without sharing storage.
 * @topic Containers
 *
 * CopyAssignUObject
 */
/**
 * @begin CopyAssignUObject
 * @summary Copy assignment copies TOptional<UObject> set state and handle without sharing storage.
 * @topic Containers
 */
UCLASS()
class UTOptionalCopyAssignUObjectHost : UObject
{
}

bool CopyAssignUObject()
{
	TOptional<UObject> UnsetRight;
	TOptional<UObject> UnsetLeft;
	UnsetLeft = UnsetRight;
	bool bCopiedUnset = !UnsetLeft.IsSet() && !UnsetRight.IsSet();

	UObject First = NewObject(GetTransientPackage(), UTOptionalCopyAssignUObjectHost::StaticClass(), n"CopyAssign_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTOptionalCopyAssignUObjectHost::StaticClass(), n"CopyAssign_Second", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	TOptional<UObject> SetRight;
	SetRight.Set(First);
	TOptional<UObject> SetLeft;
	SetLeft = SetRight;
	bool bCopiedSet = SetLeft.IsSet() && SetLeft.GetValue() == First;
	SetRight.Set(Second);
	bool bCopyIndependent = SetLeft.GetValue() == First && SetRight.GetValue() == Second;

	return bCopiedUnset && bCopiedSet && bCopyIndependent;
}
/** @end */
