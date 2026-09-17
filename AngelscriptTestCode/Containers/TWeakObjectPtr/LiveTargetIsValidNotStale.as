/**
 * @version v1
 * @summary A weak pointer to a live object is valid, not stale, and not explicitly null.
 * @topic Containers
 *
 * LiveTargetIsValidNotStale
 */
/**
 * @begin LiveTargetIsValidNotStale
 * @summary A weak pointer to a live object is valid, not stale, and not explicitly null.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrValidityObject : UObject
{
}

bool LiveTargetIsValidNotStale()
{
	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrValidityObject::StaticClass(), n"TWeakObjValid_Live", true);
	if (Target == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UObject> Weak;
	Weak = Target;
	return Weak.IsValid()
		&& !Weak.IsStale()
		&& !Weak.IsExplicitlyNull();
}
/** @end */
