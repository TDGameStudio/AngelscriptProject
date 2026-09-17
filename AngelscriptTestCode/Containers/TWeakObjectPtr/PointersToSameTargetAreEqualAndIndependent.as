/**
 * @version v1
 * @summary Two pointers to the same object are equal, and clearing one leaves the other valid.
 * @topic Containers
 *
 * PointersToSameTargetAreEqualAndIndependent
 */
/**
 * @begin PointersToSameTargetAreEqualAndIndependent
 * @summary Two pointers to the same object are equal, and clearing one leaves the other valid.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrValidityObject : UObject
{
}

bool PointersToSameTargetAreEqualAndIndependent()
{
	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrValidityObject::StaticClass(), n"TWeakObjValid_Shared", true);
	if (Target == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UObject> First;
	TWeakObjectPtr<UObject> Second;
	First = Target;
	Second = Target;
	if (First != Second)
	{
		return false;
	}

	Second = nullptr;
	return First.IsValid() && !Second.IsValid() && First != Second;
}
/** @end */
