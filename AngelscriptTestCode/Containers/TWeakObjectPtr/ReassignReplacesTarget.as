/**
 * @version v1
 * @summary Reassigning a weak pointer replaces the previous target.
 * @topic Containers
 *
 * ReassignReplacesTarget
 */
/**
 * @begin ReassignReplacesTarget
 * @summary Reassigning a weak pointer replaces the previous target.
 * @topic Containers
 */
UCLASS()
class UTWeakObjectPtrAssignObject : UObject
{
}

bool ReassignReplacesTarget()
{
	UObject First = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Re_0", true);
	UObject Second = NewObject(GetTransientPackage(), UTWeakObjectPtrAssignObject::StaticClass(), n"TWeakObjAssign_Re_1", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	TWeakObjectPtr<UObject> Weak;
	Weak = First;
	if (Weak.Get() != First)
	{
		return false;
	}

	Weak = Second;
	return Weak.IsValid() && Weak.Get() == Second && Weak.Get() != First;
}
/** @end */
