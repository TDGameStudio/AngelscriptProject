/**
 * @version v1
 * @summary An &out TObjectPtr is filled with a newly created object.
 * @topic Containers
 *
 * FillWithNewObject
 */
/**
 * @begin FillWithNewObject
 * @summary An &out TObjectPtr is filled with a newly created object.
 * @topic Containers
 */
UCLASS()
class UTObjectPtrFillObject : UObject
{
}

void FillOut(TObjectPtr<UObject>&out Result)
{
	Result = NewObject(GetTransientPackage(), UTObjectPtrFillObject::StaticClass(), n"TObjPtrAssign_Fill", true);
}

bool FillWithNewObject()
{
	TObjectPtr<UObject> Ptr;
	FillOut(Ptr);
	return Ptr.Get() != nullptr;
}
/** @end */
