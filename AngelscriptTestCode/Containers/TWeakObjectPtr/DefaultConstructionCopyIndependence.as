/**
 * @version v1
 * @summary Setting only the first of two default weak pointers leaves the second null.
 * @topic Containers
 *
 * DefaultConstructionCopyIndependence
 */
/**
 * @begin DefaultConstructionCopyIndependence
 * @summary Setting only the first of two default weak pointers leaves the second null.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrEmptyConstructionObject : UObject
{
}

bool DefaultConstructionCopyIndependence()
{
	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrEmptyConstructionObject::StaticClass(), n"TWeakObjEmpty_First", true);
	if (Target == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UObject> First;
	TWeakObjectPtr<UObject> Second;
	First = Target;
	return First.IsValid() && !Second.IsValid();
}
/** @end */
