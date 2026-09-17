/**
 * @version v1
 * @summary An &out TArray<FString> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 *
 * FillByMoveAssignFromFString
 */
/**
 * @begin FillByMoveAssignFromFString
 * @summary An &out TArray<FString> is filled by MoveAssignFrom of a local source.
 * @topic Containers
 */
void FillByMoveAssignFromFString(TArray<FString>&out Result)
{
	TArray<FString> Source;
	Source.Add("alpha");
	Source.Add("beta");
	Result.MoveAssignFrom(Source);
}
/** @end */
