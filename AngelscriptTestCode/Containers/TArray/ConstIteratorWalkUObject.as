/**
 * @version v1
 * @summary A TArrayConstIterator<UObject> Proceeds through each handle without mutating the array.
 * @topic Containers
 *
 * ConstIteratorWalkUObject
 */
/**
 * @begin ConstIteratorWalkUObject
 * @summary A TArrayConstIterator<UObject> Proceeds through each handle without mutating the array.
 * @topic Containers
 */
UCLASS()
class UTArrayConstIteratorWalkUObjectHost : UObject
{
}

bool ConstIteratorWalkUObject()
{
	UObject FirstObject = NewObject(GetTransientPackage(), UTArrayConstIteratorWalkUObjectHost::StaticClass(), n"ConstIteratorWalk_First", true);
	UObject SecondObject = NewObject(GetTransientPackage(), UTArrayConstIteratorWalkUObjectHost::StaticClass(), n"ConstIteratorWalk_Second", true);
	TArray<UObject> Values;
	Values.Add(FirstObject);
	Values.Add(SecondObject);
	const TArray<UObject> ConstValues = Values;
	TArrayConstIterator<UObject> ConstIterator = ConstValues.Iterator();
	const UObject& First = ConstIterator.Proceed();
	const UObject& Second = ConstIterator.Proceed();
	return First == FirstObject && Second == SecondObject && !ConstIterator.CanProceed;
}
/** @end */
