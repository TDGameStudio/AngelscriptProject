/**
 * @version v1
 * @summary Copy assignment copies bool elements and leaves the source independently mutable.
 * @topic Containers
 *
 * CopyAssignBool
 */
/**
 * @begin CopyAssignBool
 * @summary Copy assignment copies bool elements and leaves the source independently mutable.
 * @topic Containers
 */
bool CopyAssignBool()
{
	TArray<bool> Right;
	Right.Add(false);
	Right.Add(true);
	TArray<bool> Left;
	Left = Right;
	bool bCopiedEqual = Left == Right && Left.Num() == 2 && Left[0] == false && Left[1] == true;
	Right.Add(false);
	bool bCopyIndependent = Left.Num() == 2 && Right.Num() == 3;
	return bCopiedEqual && bCopyIndependent;
}
/** @end */
