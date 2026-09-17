/**
 * @version v1
 * @summary Clearing a weak UPROPERTY makes it explicitly null.
 * @topic Containers
 *
 * ClearingWeakPropertyMakesItExplicitlyNull
 */
/**
 * @begin ClearingWeakPropertyMakesItExplicitlyNull
 * @summary Clearing a weak UPROPERTY makes it explicitly null.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrPropertyOwner : UObject
{
	UPROPERTY()
	TWeakObjectPtr<UObject> BackRef;
}

bool ClearingWeakPropertyMakesItExplicitlyNull()
{
	UTWeakObjectPtrPropertyOwner First = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyOwner::StaticClass(), n"TWeakObjProp_ClearA", true);
	UTWeakObjectPtrPropertyOwner Second = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyOwner::StaticClass(), n"TWeakObjProp_ClearB", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	Second.BackRef = First;
	if (!Second.BackRef.IsValid())
	{
		return false;
	}

	Second.BackRef = nullptr;
	return !Second.BackRef.IsValid()
		&& Second.BackRef.Get() == nullptr
		&& Second.BackRef.IsExplicitlyNull();
}
/** @end */
