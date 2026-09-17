/**
 * @version v1
 * @summary A pointer equals its held object only when set.
 * @topic Containers
 *
 * PointerEqualsHeldObjectOnlyWhenSet
 */
/**
 * @begin PointerEqualsHeldObjectOnlyWhenSet
 * @summary A pointer equals its held object only when set.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrEqualsHeldTarget : UObject
{
}

bool PointerEqualsHeldObjectOnlyWhenSet()
{
	UObject Target = NewObject(GetTransientPackage(), UTObjectPtrEqualsHeldTarget::StaticClass(), n"TObjPtrValid_Eq", true);
	if (Target == nullptr)
	{
		return false;
	}

	TObjectPtr<UObject> Null;
	TObjectPtr<UObject> Set;
	Set = Target;

	return !(Null == Target) && Set == Target;
}
/** @end */
