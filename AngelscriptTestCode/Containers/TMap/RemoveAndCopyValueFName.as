/**
 * @version v1
 * @summary RemoveAndCopyValue copies the value out and leaves a missing FName key unchanged.
 * @topic Containers
 *
 * RemoveAndCopyValueFName
 */
/**
 * @begin RemoveAndCopyValueFName
 * @summary RemoveAndCopyValue copies the value out and leaves a missing FName key unchanged.
 * @topic Containers
 */
bool RemoveAndCopyValueFName()
{
	TMap<FName, int> Map;
	Map.Add(n"Red", 9);
	int OutValue = -1;
	bool bRemoved = Map.RemoveAndCopyValue(n"Red", OutValue);
	int MissingOut = -1;
	bool bMissing = Map.RemoveAndCopyValue(n"Red", MissingOut);
	return bRemoved && OutValue == 9 && !bMissing && MissingOut == -1 && Map.IsEmpty();
}
/** @end */
