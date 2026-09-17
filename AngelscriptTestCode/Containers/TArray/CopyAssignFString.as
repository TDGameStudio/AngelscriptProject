/**
 * @version v1
 * @summary Copy assignment copies FString elements and leaves the source independently mutable.
 * @topic Containers
 *
 * CopyAssignFString
 */
/**
 * @begin CopyAssignFString
 * @summary Copy assignment copies FString elements and leaves the source independently mutable.
 * @topic Containers
 */
bool CopyAssignFString()
{
	TArray<FString> Right;
	Right.Add("alpha");
	Right.Add("beta");
	TArray<FString> Left;
	Left = Right;
	bool bCopiedEqual = Left == Right && Left.Num() == 2 && Left[0] == "alpha" && Left[1] == "beta";
	Right.Add("gamma");
	bool bCopyIndependent = Left.Num() == 2 && Right.Num() == 3;
	return bCopiedEqual && bCopyIndependent;
}
/** @end */
