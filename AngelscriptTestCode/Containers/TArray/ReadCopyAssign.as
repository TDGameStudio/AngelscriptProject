/**
 * @version v1
 * @summary A const&in TArray<int32> reports assigned element order.
 * @topic Containers
 *
 * ReadCopyAssign
 */
/**
 * @begin ReadCopyAssign
 * @summary A const&in TArray<int32> reports assigned element order.
 * @topic Containers
 */
bool ReadCopyAssign(const TArray<int32>&in Values)
{
	return Values.Num() == 2 && Values[0] == 1 && Values[1] == 2;
}
/** @end */
