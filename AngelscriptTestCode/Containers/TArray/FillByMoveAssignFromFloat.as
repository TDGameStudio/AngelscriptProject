/**
 * @version v1
 * @summary An &out TArray<float> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 *
 * FillByMoveAssignFromFloat
 */
/**
 * @begin FillByMoveAssignFromFloat
 * @summary An &out TArray<float> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 */
void FillByMoveAssignFromFloat(TArray<float>&out Result)
{
	TArray<float> Source;
	Source.Add(1.0f);
	Source.Add(2.0f);
	Source.Add(3.0f);
	Result.MoveAssignFrom(Source);
}
/** @end */
