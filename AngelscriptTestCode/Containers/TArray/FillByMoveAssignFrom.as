/**
 * @version v1
 * @summary An &out TArray<int32> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 *
 * FillByMoveAssignFrom
 */
/**
 * @begin FillByMoveAssignFrom
 * @summary An &out TArray<int32> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 */
void FillByMoveAssignFrom(TArray<int32>&out Result)
{
	TArray<int32> Source;
	Source.Add(1);
	Source.Add(2);
	Source.Add(3);
	Result.MoveAssignFrom(Source);
}
/** @end */
