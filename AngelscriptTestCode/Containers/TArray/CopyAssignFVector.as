/**
 * @version v1
 * @summary Copy assignment copies FVector elements and leaves the source independently mutable.
 * @topic Containers
 *
 * CopyAssignFVector
 */
/**
 * @begin CopyAssignFVector
 * @summary Copy assignment copies FVector elements and leaves the source independently mutable.
 * @topic Containers
 */
bool CopyAssignFVector()
{
	TArray<FVector> Right;
	Right.Add(FVector(1.0f, 0.0f, 0.0f));
	Right.Add(FVector(0.0f, 1.0f, 0.0f));
	TArray<FVector> Left;
	Left = Right;
	bool bCopiedEqual = Left.Num() == 2
		&& Left[0].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& Left[1].Equals(FVector(0.0f, 1.0f, 0.0f));
	Right.Add(FVector(0.0f, 0.0f, 1.0f));
	bool bCopyIndependent = Left.Num() == 2 && Right.Num() == 3;
	return bCopiedEqual && bCopyIndependent;
}
/** @end */
