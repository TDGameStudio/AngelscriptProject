/**
 * @version v1
 * @summary Empty clears every FString-key pair so Num is 0.
 * @topic Containers
 *
 * EmptyClearsNumFString
 */
/**
 * @begin EmptyClearsNumFString
 * @summary Empty clears every FString-key pair so Num is 0.
 * @topic Containers
 */
bool EmptyClearsNumFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 100);
	Map.Empty();
	bool bDefaultEmpty = Map.IsEmpty();
	Map.Add("alpha", 100);
	Map.Empty(4);
	return bDefaultEmpty && Map.IsEmpty() && Map.Num() == 0;
}
/** @end */
