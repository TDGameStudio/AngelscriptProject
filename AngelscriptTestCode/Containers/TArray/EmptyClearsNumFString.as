/**
 * @version v1
 * @summary Empty clears FString Num to 0 and Empty(8) retains Max of at least 8.
 * @topic Containers
 *
 * EmptyClearsNumFString
 */
/**
 * @begin EmptyClearsNumFString
 * @summary Empty clears FString Num to 0 and Empty(8) retains Max of at least 8.
 * @topic Containers
 */
bool EmptyClearsNumFString()
{
	TArray<FString> Values;
	Values.Add("alpha");
	Values.Add("beta");
	Values.Empty();
	bool bDefaultEmpty = Values.IsEmpty() && Values.Num() == 0;
	Values.Add("alpha");
	Values.Empty(8);
	return bDefaultEmpty && Values.IsEmpty() && Values.Max() >= 8;
}
/** @end */
