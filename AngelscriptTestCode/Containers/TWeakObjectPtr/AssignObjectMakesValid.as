/**
 * @version v1
 * @summary Assigning a UObject makes the weak pointer valid and Get returns that object.
 * @topic Containers
 *
 * AssignObjectMakesValid
 */
/**
 * @begin AssignObjectMakesValid
 * @summary Assigning a UObject makes the weak pointer valid and Get returns that object.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrAssignObject : UObject
{
}

bool AssignObjectMakesValid()
{
	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_First", true);
	if (Target == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UObject> Weak;
	if (Weak.IsValid())
	{
		return false;
	}

	Weak = Target;
	return Weak.IsValid() && Weak.Get() == Target;
}
/** @end */
