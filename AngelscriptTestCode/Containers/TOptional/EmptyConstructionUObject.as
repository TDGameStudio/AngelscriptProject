/**
 * @version v1
 * @summary Default TOptional<UObject> is unset and copy-independent.
 * @topic Containers
 *
 * EmptyConstructionUObject
 */
/**
 * @begin EmptyConstructionUObject
 * @summary Default TOptional<UObject> is unset and copy-independent.
 * @topic Containers
 */
UCLASS()
class UTOptionalEmptyConstructionUObjectHost : UObject
{
}

bool EmptyConstructionUObject()
{
	TOptional<UObject> First;
	TOptional<UObject> Second;
	bool bDefaultUnset = !First.IsSet() && !Second.IsSet();
	UObject Object = NewObject(GetTransientPackage(), UTOptionalEmptyConstructionUObjectHost::StaticClass(), n"EmptyConstruction_First", true);
	if (Object == nullptr)
	{
		return false;
	}

	First.Set(Object);
	bool bCopyIndependent = First.IsSet() && !Second.IsSet();
	TOptional<UObject> NullHeld;
	NullHeld.Set(nullptr);
	return bDefaultUnset && bCopyIndependent && NullHeld.IsSet() && NullHeld.GetValue() == nullptr;
}
/** @end */
