/**
 * @version v1
 * @summary Empty clears every pair so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNum
 */
/**
 * @begin EmptyClearsNum
 * @summary Empty clears every pair so Num is 0.
 * @topic Containers
 */
bool EmptyClearsNum()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 1);
	Map.Empty();
	bool bDefaultEmpty = Map.IsEmpty();
	Map.Add(n"Alpha", 1);
	Map.Empty(4);
	return bDefaultEmpty && Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
