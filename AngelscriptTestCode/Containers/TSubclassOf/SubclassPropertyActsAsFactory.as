/**
 * @version v1
 * @summary A TSubclassOf UPROPERTY can be used as a NewObject class argument.
 * @topic Containers
 *
 * SubclassPropertyActsAsFactory
 */
/**
 * @begin SubclassPropertyActsAsFactory
 * @summary A TSubclassOf UPROPERTY can be used as a NewObject class argument.
 * @topic Containers
 */
UCLASS()
class UFactoryPropertyDerived : UObject
{
}

UCLASS()
class UFactoryPropertyHolder : UObject
{
	UPROPERTY()
	TSubclassOf<UObject> ObjectClass;
}

bool SubclassPropertyActsAsFactory()
{
	UFactoryPropertyHolder Holder = NewObject(GetTransientPackage(), UFactoryPropertyHolder::StaticClass(), n"FactoryPropertyHolder", true);
	if (Holder == nullptr)
	{
		return false;
	}

	Holder.ObjectClass = UFactoryPropertyDerived::StaticClass();

	UObject Produced = NewObject(GetTransientPackage(), Holder.ObjectClass, n"FactoryPropertyProduced", true);
	return Produced != nullptr
		&& Cast<UFactoryPropertyDerived>(Produced) != nullptr;
}
/** @end */
