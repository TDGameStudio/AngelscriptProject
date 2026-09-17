/**
 * @version v1
 * @summary Assigning one weak pointer onto another copies the target and they compare equal.
 * @topic Containers
 *
 * AssignPointerCopiesTarget
 */
/**
 * @begin AssignPointerCopiesTarget
 * @summary Assigning one weak pointer onto another copies the target and they compare equal.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrAssignObject : UObject
{
}

bool AssignPointerCopiesTarget()
{
	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Copy", true);
	if (Target == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UObject> Source;
	Source = Target;

	TWeakObjectPtr<UObject> Dest;
	Dest = Source;
	return Dest.IsValid()
		&& Dest.Get() == Target
		&& Dest == Source;
}
/** @end */
