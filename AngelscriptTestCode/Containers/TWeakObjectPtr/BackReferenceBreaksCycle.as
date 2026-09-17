/**
 * @version v1
 * @summary A strong forward and weak back pair both resolve without forming a strong cycle.
 * @topic Containers
 *
 * BackReferenceBreaksCycle
 */
/**
 * @begin BackReferenceBreaksCycle
 * @summary A strong forward and weak back pair both resolve without forming a strong cycle.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrPropertyOwner : UObject
{
	UPROPERTY()
	UObject StrongRef;

	UPROPERTY()
	TWeakObjectPtr<UObject> BackRef;
}

bool BackReferenceBreaksCycle()
{
	UTWeakObjectPtrPropertyOwner First = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyOwner::StaticClass(), n"TWeakObjProp_OwnerA", true);
	UTWeakObjectPtrPropertyOwner Second = NewObject(GetTransientPackage(), UTWeakObjectPtrPropertyOwner::StaticClass(), n"TWeakObjProp_OwnerB", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	First.StrongRef = Second;
	Second.BackRef = First;

	return First.StrongRef == Second
		&& Second.BackRef.IsValid()
		&& Second.BackRef.Get() == First;
}
/** @end */
