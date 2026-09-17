/**
 * @version v1
 * @summary Assigning one pointer copies the target and stays independent.
 * @topic Containers
 *
 * AssignPointerCopiesTargetAndStaysIndependent
 */
/**
 * @begin AssignPointerCopiesTargetAndStaysIndependent
 * @summary Assigning one pointer copies the target and stays independent.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrAssignPointerCopyTarget : UObject
{
}

bool AssignPointerCopiesTargetAndStaysIndependent()
{
	UObject First = NewObject(GetTransientPackage(), UTObjectPtrAssignPointerCopyTarget::StaticClass(), n"TObjPtrAssign_Copy0", true);
	UObject Second = NewObject(GetTransientPackage(), UTObjectPtrAssignPointerCopyTarget::StaticClass(), n"TObjPtrAssign_Copy1", true);
	if (First == nullptr || Second == nullptr || First == Second)
	{
		return false;
	}

	TObjectPtr<UObject> Source;
	Source = First;

	TObjectPtr<UObject> Dest;
	Dest = Source;
	if (Dest.Get() != First || Dest != Source)
	{
		return false;
	}

	Source = Second;
	return Dest.Get() == First && Source.Get() == Second && Dest != Source;
}
/** @end */
