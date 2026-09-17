/**
 * @version v1
 * @summary Last() write-through is visible on TArray<FVector> and Last(1) reads from the end.
 * @topic Containers
 *
 * LastValidIndexFVector
 */
/**
 * @begin LastValidIndexFVector
 * @summary Last() write-through is visible on TArray<FVector> and Last(1) reads from the end.
 * @topic Containers
 */
bool LastValidIndexFVector()
{
	TArray<FVector> Values;
	Values.Add(FVector(1.0f, 0.0f, 0.0f));
	Values.Add(FVector(0.0f, 1.0f, 0.0f));
	Values.Add(FVector(0.0f, 0.0f, 1.0f));
	FVector& LastMut = Values.Last();
	bool bLastIsUp = LastMut.Equals(FVector(0.0f, 0.0f, 1.0f));
	LastMut = FVector(1.0f, 1.0f, 1.0f);
	FVector& FromEnd = Values.Last(1);
	const TArray<FVector> ConstValues = Values;
	const FVector& ConstLast = ConstValues.Last();
	const FVector& ConstFromEnd = ConstValues.Last(1);
	return bLastIsUp
		&& Values[2].Equals(FVector(1.0f, 1.0f, 1.0f))
		&& FromEnd.Equals(FVector(0.0f, 1.0f, 0.0f))
		&& ConstLast.Equals(FVector(1.0f, 1.0f, 1.0f))
		&& ConstFromEnd.Equals(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
