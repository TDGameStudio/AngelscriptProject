/**
 * @version v1
 * @summary A TSubclassOf UPROPERTY keeps the assigned class and its hierarchy.
 * @topic Containers
 *
 * SubclassPropertyKeepsClassAndHierarchy
 */
/**
 * @begin SubclassPropertyKeepsClassAndHierarchy
 * @summary A TSubclassOf UPROPERTY keeps the assigned class and its hierarchy.
 * @topic Containers
 */
UCLASS()
class UKeepsHierarchyBase : UObject
{
}

UCLASS()
class UKeepsHierarchyDerived : UKeepsHierarchyBase
{
}

UCLASS()
class UKeepsHierarchyHolder : UObject
{
	UPROPERTY()
	TSubclassOf<UKeepsHierarchyBase> BaseClass;
}

bool SubclassPropertyKeepsClassAndHierarchy()
{
	UKeepsHierarchyHolder Holder = NewObject(GetTransientPackage(), UKeepsHierarchyHolder::StaticClass(), n"KeepsHierarchyHolder", true);
	if (Holder == nullptr)
	{
		return false;
	}

	UClass Derived = UKeepsHierarchyDerived::StaticClass();
	Holder.BaseClass = Derived;

	return Holder.BaseClass.IsValid()
		&& Holder.BaseClass.Get() == Derived
		&& Holder.BaseClass.IsChildOf(UKeepsHierarchyBase::StaticClass());
}
/** @end */
