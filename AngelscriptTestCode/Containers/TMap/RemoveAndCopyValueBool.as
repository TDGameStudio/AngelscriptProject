/**
 * @version v1
 * @summary RemoveAndCopyValue copies the bool out and leaves a missing key unchanged.
 * @topic Containers
 *
 * RemoveAndCopyValueBool
 */
/**
 * @begin RemoveAndCopyValueBool
 * @summary RemoveAndCopyValue copies the bool out and leaves a missing key unchanged.
 * @topic Containers
 */
bool RemoveAndCopyValueBool()
{
	TMap<int, bool> Map;
	Map.Add(1, true);
	bool OutValue = false;
	bool bRemoved = Map.RemoveAndCopyValue(1, OutValue);
	bool MissingOut = false;
	bool bMissing = Map.RemoveAndCopyValue(1, MissingOut);
	return bRemoved && OutValue == true && !bMissing && MissingOut == false && Map.IsEmpty();
}
/** @end */
