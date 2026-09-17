/**
 * @version v1
 * @summary Empty clears float Num to 0 and Empty(8) retains Max of at least 8.
 * @topic Containers
 *
 * EmptyClearsNumFloat
 */
/**
 * @begin EmptyClearsNumFloat
 * @summary Empty clears float Num to 0 and Empty(8) retains Max of at least 8.
 * @topic Containers
 */
bool EmptyClearsNumFloat()
{
	TArray<float> Values;
	Values.Add(1.0f);
	Values.Add(2.0f);
	Values.Empty();
	bool bDefaultEmpty = Values.IsEmpty() && Values.Num() == 0;
	Values.Add(1.0f);
	Values.Empty(8);
	return bDefaultEmpty && Values.IsEmpty() && Values.Max() >= 8;
}
/** @end */
