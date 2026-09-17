/**
 * @version v1
 * @summary An &out TArray<FVector> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 *
 * FillByMoveAssignFromFVector
 */
/**
 * @begin FillByMoveAssignFromFVector
 * @summary An &out TArray<FVector> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 */
void FillByMoveAssignFromFVector(TArray<FVector>&out Result)
{
	TArray<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	Result.MoveAssignFrom(Source);
}
/** @end */
