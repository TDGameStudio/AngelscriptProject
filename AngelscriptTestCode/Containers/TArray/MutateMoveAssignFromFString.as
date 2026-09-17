/**
 * @version v1
 * @summary An &inout TArray<FString> is replaced by MoveAssignFrom.
 * @topic Containers
 *
 * MutateMoveAssignFromFString
 */
/**
 * @begin MutateMoveAssignFromFString
 * @summary An &inout TArray<FString> is replaced by MoveAssignFrom.
 * @topic Containers
 */
void MutateMoveAssignFromFString(TArray<FString>&inout Values)
{
	TArray<FString> Source;
	Source.Add("alpha");
	Source.Add("beta");
	Values.MoveAssignFrom(Source);
}
/** @end */
