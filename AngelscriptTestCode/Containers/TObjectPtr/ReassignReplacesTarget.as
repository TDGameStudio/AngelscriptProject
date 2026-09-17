/**
 * @version v1
 * @summary Reassigning replaces the held target.
 * @topic Containers
 *
 * ReassignReplacesTarget
 */
/**
 * @begin ReassignReplacesTarget
 * @summary Reassigning replaces the held target.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrReassignTarget : UObject
{
}

bool ReassignReplacesTarget()
{
	UObject First = NewObject(GetTransientPackage(), UTObjectPtrReassignTarget::StaticClass(), n"TObjPtrAssign_Re0", true);
	UObject Second = NewObject(GetTransientPackage(), UTObjectPtrReassignTarget::StaticClass(), n"TObjPtrAssign_Re1", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	TObjectPtr<UObject> Ptr;
	Ptr = First;
	if (Ptr.Get() != First)
	{
		return false;
	}

	Ptr = Second;
	return Ptr.Get() == Second && Ptr.Get() != First;
}
/** @end */
