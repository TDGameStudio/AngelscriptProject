/**
 * @version v1
 * @summary A const&in TArray<int32> reports a copied run.
 * @topic Containers
 *
 * ReadCopyRange
 */
/**
 * @begin ReadCopyRange
 * @summary A const&in TArray<int32> reports a copied run.
 * @topic Containers
 */
bool ReadCopyRange(const TArray<int32>&in Values)
{
	return Values.Num() == 4 && Values[0] == 0 && Values[1] == 7 && Values[2] == 8 && Values[3] == 9;
}
/** @end */
