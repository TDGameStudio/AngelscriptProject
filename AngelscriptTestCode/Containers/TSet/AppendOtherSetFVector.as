/**
 * @version v1
 * @summary Append unions another FVector set and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherSetFVector
 */
/**
 * @begin AppendOtherSetFVector
 * @summary Append unions another FVector set and leaves the source unchanged.
 * @topic Containers
 */
bool AppendOtherSetFVector()
{
	TSet<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	TSet<FVector> Other;
	Other.Add(FVector(0.0f, 0.0f, 1.0f));
	Other.Add(FVector(1.0f, 1.0f, 0.0f));
	Values.Append(Other);
	return Values.Num() == 3
		&& Values.Contains(FVector(1.0f, 0.0f, 0.0f))
		&& Values.Contains(FVector(0.0f, 0.0f, 1.0f))
		&& Values.Contains(FVector(1.0f, 1.0f, 0.0f))
		&& Other.Num() == 2;
}
/** @end */
