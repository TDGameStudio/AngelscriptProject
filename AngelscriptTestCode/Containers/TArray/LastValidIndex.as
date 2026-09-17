/**
 * @version v1
 * @summary Last() write-through is visible and Last(1) reads from the end.
 * @topic Containers
 *
 * LastValidIndex
 */
/**
 * @begin LastValidIndex
 * @summary Last() write-through is visible and Last(1) reads from the end.
 * @topic Containers
 */
bool LastValidIndex()
{
	TArray<int32> Values;
	Values.Add(10);
	Values.Add(20);
	Values.Add(30);
	int32& LastMut = Values.Last();
	bool bLastIsThirty = LastMut == 30;
	LastMut = 31;
	int32& FromEnd = Values.Last(1);
	const TArray<int32> ConstValues = Values;
	const int32& ConstLast = ConstValues.Last();
	const int32& ConstFromEnd = ConstValues.Last(1);
	return bLastIsThirty && Values[2] == 31 && FromEnd == 20 && ConstLast == 31 && ConstFromEnd == 20;
}
/** @end */
