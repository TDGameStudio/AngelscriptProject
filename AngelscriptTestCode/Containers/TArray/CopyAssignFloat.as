/**
 * @version v1
 * @summary Copy assignment copies float elements and leaves the source independently mutable.
 * @topic Containers
 *
 * CopyAssignFloat
 */
/**
 * @begin CopyAssignFloat
 * @summary Copy assignment copies float elements and leaves the source independently mutable.
 * @topic Containers
 */
bool CopyAssignFloat()
{
	TArray<float> Right;
	Right.Add(1.0f);
	Right.Add(2.0f);
	TArray<float> Left;
	Left = Right;
	bool bCopiedEqual = Left == Right && Left.Num() == 2 && Left[0] == 1.0f && Left[1] == 2.0f;
	Right.Add(3.0f);
	bool bCopyIndependent = Left.Num() == 2 && Right.Num() == 3;
	return bCopiedEqual && bCopyIndependent;
}
/** @end */
