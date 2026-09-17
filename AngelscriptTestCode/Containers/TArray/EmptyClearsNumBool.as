/**
 * @version v1
 * @summary Empty clears bool Num to 0 and Empty(8) retains Max of at least 8.
 * @topic Containers
 *
 * EmptyClearsNumBool
 */
/**
 * @begin EmptyClearsNumBool
 * @summary Empty clears bool Num to 0 and Empty(8) retains Max of at least 8.
 * @topic Containers
 */
bool EmptyClearsNumBool()
{
	TArray<bool> Values;
	Values.Add(false);
	Values.Add(true);
	Values.Empty();
	bool bDefaultEmpty = Values.IsEmpty() && Values.Num() == 0;
	Values.Add(false);
	Values.Empty(8);
	return bDefaultEmpty && Values.IsEmpty() && Values.Max() >= 8;
}
/** @end */
