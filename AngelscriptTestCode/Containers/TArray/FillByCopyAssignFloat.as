/**
 * @version v1
 * @summary An &out TArray<float> is filled by assigning a local source array.
 * @topic Containers
 *
 * FillByCopyAssignFloat
 */
/**
 * @begin FillByCopyAssignFloat
 * @summary An &out TArray<float> is filled by assigning a local source array.
 * @topic Containers
 */
void FillByCopyAssignFloat(TArray<float>&out Result)
{
	TArray<float> Source;
	Source.Add(1.0f);
	Source.Add(2.0f);
	Result = Source;
}
/** @end */
