/**
 * @version v1
 * @summary GetDefaultObject returns a CDO of the held class, not the template parameter.
 * @topic Containers
 *
 * GetDefaultObjectIsOfHeldClass
 */
/**
 * @begin GetDefaultObjectIsOfHeldClass
 * @summary GetDefaultObject returns a CDO of the held class, not the template parameter.
 * @topic Containers
 */
UCLASS()
class UHeldClassCdoBase : UObject
{
}

UCLASS()
class UHeldClassCdoDerived : UHeldClassCdoBase
{
}

bool GetDefaultObjectIsOfHeldClass()
{
	TSubclassOf<UObject> Class;
	Class = UHeldClassCdoDerived::StaticClass();

	UObject Cdo = Class.GetDefaultObject();
	return Cdo != nullptr && Cast<UHeldClassCdoDerived>(Cdo) != nullptr;
}
/** @end */
