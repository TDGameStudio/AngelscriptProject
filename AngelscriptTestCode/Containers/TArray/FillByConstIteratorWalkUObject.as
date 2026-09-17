/**
 * @version v1
 * @summary An &out TArray<UObject> is filled then walked with an iterator.
 * @topic Containers
 *
 * FillByConstIteratorWalkUObject
 */
/**
 * @begin FillByConstIteratorWalkUObject
 * @summary An &out TArray<UObject> is filled then walked with an iterator.
 * @topic Containers
 */
UCLASS()
class UTArrayFillByConstIteratorWalkUObjectHost : UObject
{
}

void FillByConstIteratorWalkUObject(TArray<UObject>&out Result)
{
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByConstIteratorWalkUObjectHost::StaticClass(), n"FillByConstIteratorWalk_0", true));
	Result.Add(NewObject(GetTransientPackage(), UTArrayFillByConstIteratorWalkUObjectHost::StaticClass(), n"FillByConstIteratorWalk_1", true));
	TArrayIterator<UObject> Iterator = Result.Iterator();
	while (Iterator.CanProceed)
	{
		Iterator.Proceed();
	}
}
/** @end */
