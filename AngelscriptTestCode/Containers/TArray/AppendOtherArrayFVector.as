/**
 * @version v1
 * @summary Append copies the other FVector array onto the end and leaves the source unchanged.
 * @topic Containers
 *
 * AppendOtherArrayFVector
 */
/**
 * @begin AppendOtherArrayFVector
 * @summary Append copies the other FVector array onto the end and leaves the source unchanged.
 * @topic Containers
 */
bool AppendOtherArrayFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	TArray<FVector> Other;
	Other.Add(FVector(0.0f, 1.0f, 0.0f));
	Other.Add(FVector(0.0f, 0.0f, 1.0f));
	Values.Append(Other);
	TArray<FVector> EmptyOther;
	Values.Append(EmptyOther);
	return Values.Num() == 3
		&& Values[1].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Values[2].Equals(FVector(0.0f, 0.0f, 1.0f))
		&& Other.Num() == 2;
}
/** @end */
