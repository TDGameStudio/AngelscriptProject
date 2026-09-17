/**
 * @version v1
 * @summary Empty clears every FName-key pair so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNumFName
 */
/**
 * @begin EmptyClearsNumFName
 * @summary Empty clears every FName-key pair so Num is 0.
 * @topic Containers
 */
bool EmptyClearsNumFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 1);
	Map.Empty();
	bool bDefaultEmpty = Map.IsEmpty();
	Map.Add(n"Red", 1);
	Map.Empty(4);
	return bDefaultEmpty && Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
