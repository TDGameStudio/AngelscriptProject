/**
 * @version v1
 * @summary RemoveAndCopyValue copies the value out and leaves a missing FString key unchanged.
 * @topic Containers
 *
 * RemoveAndCopyValueFString
 */
/**
 * @begin RemoveAndCopyValueFString
 * @summary RemoveAndCopyValue copies the value out and leaves a missing FString key unchanged.
 * @topic Containers
 */
bool RemoveAndCopyValueFString()
{
	TMap<FString, int> Map;
	Map.Add("alpha", 9);
	int OutValue = -1;
	bool bRemoved = Map.RemoveAndCopyValue("alpha", OutValue);
	int MissingOut = -1;
	bool bMissing = Map.RemoveAndCopyValue("alpha", MissingOut);
	return bRemoved && OutValue == 9 && !bMissing && MissingOut == -1 && Map.IsEmpty();
}
/** @end */
