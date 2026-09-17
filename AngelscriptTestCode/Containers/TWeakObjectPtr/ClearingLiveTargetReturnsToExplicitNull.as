/**
 * @version v1
 * @summary Clearing a live target with nullptr returns the pointer to explicitly null.
 * @topic Containers
 *
 * ClearingLiveTargetReturnsToExplicitNull
 */
/**
 * @begin ClearingLiveTargetReturnsToExplicitNull
 * @summary Clearing a live target with nullptr returns the pointer to explicitly null.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrValidityObject : UObject
{
}

bool ClearingLiveTargetReturnsToExplicitNull()
{
	UObject Target = NewObject(GetTransientPackage(), UTWeakObjectPtrValidityObject::StaticClass(), n"TWeakObjValid_Clear", true);
	if (Target == nullptr)
	{
		return false;
	}

	TWeakObjectPtr<UObject> Weak;
	Weak = Target;
	if (!Weak.IsValid())
	{
		return false;
	}

	Weak = nullptr;
	return !Weak.IsValid()
		&& Weak.Get() == nullptr
		&& Weak.IsExplicitlyNull();
}
/** @end */
