/**
 * @version v1
 * @summary RemoveAndCopyValue copies the value out and leaves a missing key unchanged.
 * @topic Containers
 *
 * RemoveAndCopyValue
 */
/**
 * @begin RemoveAndCopyValue
 * @summary RemoveAndCopyValue copies the value out and leaves a missing key unchanged.
 * @topic Containers
 */
bool RemoveAndCopyValue()
{
	TMap<FName, int32> Map;
	Map.Add(n"Alpha", 9);
	int32 OutValue = -1;
	bool bRemoved = Map.RemoveAndCopyValue(n"Alpha", OutValue);
	int32 MissingOut = -1;
	bool bMissing = Map.RemoveAndCopyValue(n"Alpha", MissingOut);
	return bRemoved && OutValue == 9 && !bMissing && MissingOut == -1 && Map.IsEmpty();
}
/** @end */
