/**
 * @version v1
 * @summary Empty clears Num to 0 and Empty(8) retains Max of at least 8.
 * @topic Containers
 *
 * EmptyClearsNum
 */
/**
 * @begin EmptyClearsNum
 * @summary Empty clears Num to 0 and Empty(8) retains Max of at least 8.
 * @topic Containers
 */
bool EmptyClearsNum()
{
	TArray<int32> Values;
	Values.Add(1);
	Values.Add(2);
	Values.Empty();
	bool bDefaultEmpty = Values.IsEmpty() && Values.Num() == 0;
	Values.Add(1);
	Values.Empty(8);
	return bDefaultEmpty && Values.IsEmpty() && Values.Max() >= 8;
}
/** @end */
