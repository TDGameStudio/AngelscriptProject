/**
 * @version v1
 * @summary A derived class held in TSubclassOf is a child of its base.
 * @topic Containers
 *
 * DerivedIsChildOfBase
 */
/**
 * @begin DerivedIsChildOfBase
 * @summary A derived class held in TSubclassOf is a child of its base.
 * @topic Containers
 */
UCLASS()
class UDerivedIsChildBase : UObject
{
}

UCLASS()
class UDerivedIsChildDerived : UDerivedIsChildBase
{
}

bool DerivedIsChildOfBase()
{
	TSubclassOf<UObject> Class;
	Class = UDerivedIsChildDerived::StaticClass();
	return Class.IsChildOf(UDerivedIsChildBase::StaticClass());
}
/** @end */
