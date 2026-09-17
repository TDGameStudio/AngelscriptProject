/**
 * @version v1
 * @summary A const&in TArray<float> reports Append order.
 * @topic Containers
 *
 * ReadAppendOtherArrayFloat
 */
/**
 * @begin ReadAppendOtherArrayFloat
 * @summary A const&in TArray<float> reports Append order.
 * @topic Containers
 */
bool ReadAppendOtherArrayFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3 && Values[0] == 10.0f && Values[1] == 20.0f && Values[2] == 30.0f;
}
/** @end */
