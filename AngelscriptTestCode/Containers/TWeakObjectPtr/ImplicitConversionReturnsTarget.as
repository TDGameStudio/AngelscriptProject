/**
 * @version v1
 * @summary A valid weak pointer compares equal to the object it holds.
 * @topic Containers
 *
 * ImplicitConversionReturnsTarget
 */
/**
 * @begin ImplicitConversionReturnsTarget
 * @summary A valid weak pointer compares equal to the object it holds.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrAssignObject : UObject
{
}

bool ImplicitConversionReturnsTarget()
{
	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Conv", true);
	if (Target == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UObject> Weak;
	Weak = Target;
	return Weak == Target;
}
/** @end */
