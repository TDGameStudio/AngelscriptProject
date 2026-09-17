/**
 * @version v1
 * @summary Last() write-through is visible on TArray<bool> and Last(1) reads from the end.
 * @topic Containers
 *
 * LastValidIndexBool
 */
/**
 * @begin LastValidIndexBool
 * @summary Last() write-through is visible on TArray<bool> and Last(1) reads from the end.
 * @topic Containers
 */
bool LastValidIndexBool()
{
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	Values.Add(false);
	bool& LastMut = Values.Last();
	bool bLastIsFalse = LastMut == false;
	LastMut = true;
	bool& FromEnd = Values.Last(1);
	const TArray<bool> ConstValues = Values;
	const bool& ConstLast = ConstValues.Last();
	const bool& ConstFromEnd = ConstValues.Last(1);
	return bLastIsFalse && Values[2] == true && FromEnd == true && ConstLast == true && ConstFromEnd == true;
}
/** @end */
