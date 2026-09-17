/**
 * @version v1
 * @summary Copy-constructing from another weak pointer copies the target.
 * @topic Containers
 *
 * CopyConstructFromPointer
 */
/**
 * @begin CopyConstructFromPointer
 * @summary Copy-constructing from another weak pointer copies the target.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrAssignObject : UObject
{
}

bool CopyConstructFromPointer()
{
	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Ctor", true);
	if (Target == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UObject> Source;
	Source = Target;
	TWeakObjectPtr<UObject> Copy = TWeakObjectPtr<UObject>(Source);
	return Copy.IsValid()
		&& Copy.Get() == Target
		&& Copy == Source;
}
/** @end */
