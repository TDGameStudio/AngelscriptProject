/**
 * @version v1
 * @summary A const&in TArray<float> reports a copied run.
 * @topic Containers
 *
 * ReadCopyRangeFloat
 */
/**
 * @begin ReadCopyRangeFloat
 * @summary A const&in TArray<float> reports a copied run.
 * @topic Containers
 */
bool ReadCopyRangeFloat(const TArray<float>&in Values)
{
	return Values.Num() == 4 && Values[0] == 0.0f && Values[1] == 7.0f && Values[2] == 8.0f && Values[3] == 9.0f;
}
/** @end */
