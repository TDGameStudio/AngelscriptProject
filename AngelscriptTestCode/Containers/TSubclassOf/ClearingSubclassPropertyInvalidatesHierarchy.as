/**
 * @version v1
 * @summary Clearing a TSubclassOf UPROPERTY returns it to null and fails IsChildOf.
 * @topic Containers
 *
 * ClearingSubclassPropertyInvalidatesHierarchy
 */
/**
 * @begin ClearingSubclassPropertyInvalidatesHierarchy
 * @summary Clearing a TSubclassOf UPROPERTY returns it to null and fails IsChildOf.
 * @topic Containers
 */
UCLASS()
class UClearingHierarchyBase : UObject
{
}

UCLASS()
class UClearingHierarchyDerived : UClearingHierarchyBase
{
}

UCLASS()
class UClearingHierarchyHolder : UObject
{
	UPROPERTY()
	TSubclassOf<UClearingHierarchyBase> BaseClass;
}

bool ClearingSubclassPropertyInvalidatesHierarchy()
{
	UClearingHierarchyHolder Holder = NewObject(GetTransientPackage(), UClearingHierarchyHolder::StaticClass(), n"ClearingHierarchyHolder", true);
	if (Holder == nullptr)
	{
		return false;
	}

	Holder.BaseClass = UClearingHierarchyDerived::StaticClass();
	if (!Holder.BaseClass.IsChildOf(UClearingHierarchyBase::StaticClass()))
	{
		return false;
	}

	Holder.BaseClass = nullptr;
	return !Holder.BaseClass.IsValid()
		&& Holder.BaseClass.Get() == nullptr
		&& !Holder.BaseClass.IsChildOf(UClearingHierarchyBase::StaticClass());
}
/** @end */
