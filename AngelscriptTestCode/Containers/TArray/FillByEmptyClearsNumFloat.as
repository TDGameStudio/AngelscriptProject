/**
 * @version v1
 * @summary An &out TArray<float> is filled then Empty clears Num.
 * @topic Containers
 *
 * FillByEmptyClearsNumFloat
 */
/**
 * @begin FillByEmptyClearsNumFloat
 * @summary An &out TArray<float> is filled then Empty clears Num.
 * @topic Containers
 */
void FillByEmptyClearsNumFloat(TArray<float>&out Result)
{
	Result.Add(10.0f);
	Result.Add(20.0f);
	Result.Add(30.0f);
	Result.Empty();
}
/** @end */
