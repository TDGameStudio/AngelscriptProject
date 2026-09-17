/**
 * @version v1
 * @summary An &out TSet<FVector> is filled by Append of another set.
 * @topic Containers
 *
 * FillByAppendOtherSetFVector
 */
/**
 * @begin FillByAppendOtherSetFVector
 * @summary An &out TSet<FVector> is filled by Append of another set.
 * @topic Containers
 */
void FillByAppendOtherSetFVector(TSet<FVector>&out Result)
{
	Result.Add(FVector(1.0f, 0.0f, 0.0f));
	TSet<FVector> Other;
	Other.Add(FVector(0.0f, 0.0f, 1.0f));
	Other.Add(FVector(1.0f, 1.0f, 0.0f));
	Result.Append(Other);
}
/** @end */
