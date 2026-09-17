/**
 * @version v1
 * @summary Empty clears every bool pair so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNumBool
 */
/**
 * @begin EmptyClearsNumBool
 * @summary Empty clears every bool pair so Num is 0.
 * @topic Containers
 */
bool EmptyClearsNumBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	Map.Empty();
	bool bDefaultEmpty = Map.IsEmpty();
	Map.Add(1, true);
	Map.Empty(4);
	return bDefaultEmpty && Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
