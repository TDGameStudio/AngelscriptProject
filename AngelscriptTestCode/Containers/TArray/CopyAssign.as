/**
 * @version v1
 * @summary Copy assignment copies elements and leaves the source independently mutable.
 * @topic Containers
 *
 * CopyAssign
 */
/**
 * @begin CopyAssign
 * @summary Copy assignment copies elements and leaves the source independently mutable.
 * @topic Containers
 */
bool CopyAssign()
{
	TArray<int32> Right;
	Right.Add(1);
	Right.Add(2);
	TArray<int32> Left;
	Left = Right;
	bool bCopiedEqual = Left == Right && Left.Num() == 2 && Left[0] == 1;
	Right.Add(3);
	bool bCopyIndependent = Left.Num() == 2 && Right.Num() == 3;
	TArray<FString> StringRight;
	StringRight.Add("Alpha");
	TArray<FString> StringLeft;
	StringLeft = StringRight;
	return bCopiedEqual && bCopyIndependent && StringLeft.Num() == 1 && StringLeft[0] == "Alpha";
}
/** @end */
