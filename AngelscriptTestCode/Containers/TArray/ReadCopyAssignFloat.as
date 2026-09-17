/**
 * @version v1
 * @summary A const&in TArray<float> reports assigned element order.
 * @topic Containers
 *
 * ReadCopyAssignFloat
 */
/**
 * @begin ReadCopyAssignFloat
 * @summary A const&in TArray<float> reports assigned element order.
 * @topic Containers
 */
bool ReadCopyAssignFloat(const TArray<float>&in Values)
{
	return Values.Num() == 2 && Values[0] == 1.0f && Values[1] == 2.0f;
}
/** @end */
