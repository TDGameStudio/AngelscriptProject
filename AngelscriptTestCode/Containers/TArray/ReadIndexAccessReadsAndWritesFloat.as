/**
 * @version v1
 * @summary A const&in TArray<float> reports [] insertion order.
 * @topic Containers
 *
 * ReadIndexAccessReadsAndWritesFloat
 */
/**
 * @begin ReadIndexAccessReadsAndWritesFloat
 * @summary A const&in TArray<float> reports [] insertion order.
 * @topic Containers
 */
bool ReadIndexAccessReadsAndWritesFloat(const TArray<float>&in Values)
{
	return Values.Num() == 3 && Values[0] == 10.0f && Values[1] == 20.0f && Values[2] == 30.0f;
}
/** @end */
