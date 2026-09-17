/**
 * @version v1
 * @summary RemoveAndCopyValue copies the UObject handle out and leaves a missing key unchanged.
 * @topic Containers
 *
 * RemoveAndCopyValueUObject
 */
/**
 * @begin RemoveAndCopyValueUObject
 * @summary RemoveAndCopyValue copies the UObject handle out and leaves a missing key unchanged.
 * @topic Containers
 */
UCLASS()
class UTMapRemoveAndCopyValueUObjectHost : UObject
{
}

bool RemoveAndCopyValueUObject()
{
	TMap<int, UObject> Map;
	UObject First = NewObject(GetTransientPackage(), UTMapRemoveAndCopyValueUObjectHost::StaticClass(), n"RemoveAndCopy_First", true);
	if (First == nullptr)
	{
		return false;
	}
	Map.Add(10, First);
	UObject OutValue = nullptr;
	bool bRemoved = Map.RemoveAndCopyValue(10, OutValue);
	UObject MissingOut = nullptr;
	bool bMissing = Map.RemoveAndCopyValue(10, MissingOut);
	return bRemoved && OutValue == First && !bMissing && MissingOut == nullptr && Map.IsEmpty();
}
/** @end */
