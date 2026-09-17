/**
 * @version v1
 * @summary A const&in TOptional<FVector> copies by assignment and compares equal.
 * @topic Containers
 *
 * ReadCopyAssignFVector
 */
/**
 * @begin ReadCopyAssignFVector
 * @summary A const&in TOptional<FVector> copies by assignment and compares equal.
 * @topic Containers
 */
bool ReadCopyAssignFVector(const TOptional<FVector>&in Value)
{
	TOptional<FVector> Copy;
	Copy = Value;
	TOptional<FVector> Expected;
	Expected.Set(FVector(1.0f, 0.0f, 0.0f));
	return Copy.IsSet() && Copy == Expected && Copy.GetValue().Equals(FVector(1.0f, 0.0f, 0.0f));
}
/** @end */
