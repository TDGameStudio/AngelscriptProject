/**
 * @version v1
 * @summary An &out TArray<bool> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 *
 * FillByMoveAssignFromBool
 */
/**
 * @begin FillByMoveAssignFromBool
 * @summary An &out TArray<bool> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 */
void FillByMoveAssignFromBool(TArray<bool>&out Result)
{
	TArray<bool> Source;
	Source.Add(false);
	Source.Add(true);
	Source.Add(false);
	Result.MoveAssignFrom(Source);
}
/** @end */
