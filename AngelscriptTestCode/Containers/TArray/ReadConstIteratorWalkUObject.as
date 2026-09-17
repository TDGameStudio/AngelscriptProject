/**
 * @version v1
 * @summary A const&in TArray<UObject> is walked with TArrayConstIterator.
 * @topic Containers
 *
 * ReadConstIteratorWalkUObject
 */
/**
 * @begin ReadConstIteratorWalkUObject
 * @summary A const&in TArray<UObject> is walked with TArrayConstIterator.
 * @topic Containers
 */
bool ReadConstIteratorWalkUObject(const TArray<UObject>&in Values)
{
	TArrayConstIterator<UObject> ConstIterator = Values.Iterator();
	int32 Count = 0;
	while (ConstIterator.CanProceed)
	{
		const UObject& Value = ConstIterator.Proceed();
		if (Value != nullptr)
		{
			Count += 1;
		}
	}
	return Count == Values.Num();
}
/** @end */
