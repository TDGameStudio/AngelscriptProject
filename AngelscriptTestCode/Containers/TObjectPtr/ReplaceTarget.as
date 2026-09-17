/**
 * @version v1
 * @summary An &inout TObjectPtr replaces its held target.
 * @topic Containers
 *
 * ReplaceTarget
 */
/**
 * @begin ReplaceTarget
 * @summary An &inout TObjectPtr replaces its held target.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrReplaceObject : UObject
{
}

void ReplaceInOut(TObjectPtr<UObject>&inout Value)
{
	Value = NewObject(GetTransientPackage(), UTObjectPtrReplaceObject::StaticClass(), n"TObjPtrAssign_Replace", true);
}

bool ReplaceTarget()
{
	UObject First = NewObject(GetTransientPackage(), UTObjectPtrReplaceObject::StaticClass(), n"TObjPtrAssign_ReplaceFirst", true);
	if (First == nullptr)
	{
		return false;
	}

	TObjectPtr<UObject> Ptr;
	Ptr = First;
	ReplaceInOut(Ptr);
	return Ptr.Get() != nullptr && Ptr.Get() != First;
}
/** @end */
