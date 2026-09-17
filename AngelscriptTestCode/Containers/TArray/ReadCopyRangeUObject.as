/**
 * @version v1
 * @summary A const&in TArray<UObject> reports a copied run length.
 * @topic Containers
 *
 * ReadCopyRangeUObject
 */
/**
 * @begin ReadCopyRangeUObject
 * @summary A const&in TArray<UObject> reports a copied run length.
 * @topic Containers
 */
bool ReadCopyRangeUObject(const TArray<UObject>&in Values)
{
	return Values.Num() == 3 && Values[1] != nullptr && Values[2] != nullptr;
}
/** @end */
