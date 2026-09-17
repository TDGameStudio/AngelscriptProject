/**
 * @version v1
 * @summary Pointers to the same target are equal and stay independent.
 * @topic Containers
 *
 * PointersToSameTargetAreEqualAndIndependent
 */
/**
 * @begin PointersToSameTargetAreEqualAndIndependent
 * @summary Pointers to the same target are equal and stay independent.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrSameTarget : UObject
{
}

bool PointersToSameTargetAreEqualAndIndependent()
{
	UObject Target = NewObject(GetTransientPackage(), UTObjectPtrSameTarget::StaticClass(), n"TObjPtrValid_Shared", true);
	if (Target == nullptr)
	{
		return false;
	}

	TObjectPtr<UObject> First;
	TObjectPtr<UObject> Second;
	First = Target;
	Second = Target;
	if (First != Second)
	{
		return false;
	}

	Second = nullptr;
	return First.Get() == Target && Second.Get() == nullptr && First != Second;
}
/** @end */
