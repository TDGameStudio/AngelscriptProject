/**
 * @version v1
 * @summary An &out TArray<float> is filled then [] writes one slot.
 * @topic Containers
 *
 * FillByIndexAccessReadsAndWritesFloat
 */
/**
 * @begin FillByIndexAccessReadsAndWritesFloat
 * @summary An &out TArray<float> is filled then [] writes one slot.
 * @topic Containers
 */
void FillByIndexAccessReadsAndWritesFloat(TArray<float>&out Result)
{
	Result.Add(10.0f);
	Result.Add(20.0f);
	Result.Add(30.0f);
	Result[1] = 99.0f;
}
/** @end */
