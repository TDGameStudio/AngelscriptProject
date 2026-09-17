/**
 * @version v1
 * @summary A const&in TArray<float> reports unique AddUnique order.
 * @topic Containers
 *
 * ReadAddUniqueRejectsDuplicateFloat
 */
/**
 * @begin ReadAddUniqueRejectsDuplicateFloat
 * @summary A const&in TArray<float> reports unique AddUnique order.
 * @topic Containers
 */
bool ReadAddUniqueRejectsDuplicateFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3 && Values[0] == 10.0f && Values[1] == 20.0f && Values[2] == 30.0f;
}
/** @end */
