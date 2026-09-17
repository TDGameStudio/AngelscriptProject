/**
 * @version v1
 * @summary Copy one element onto empty dest [0] throws Target array out of bounds.
 * @topic Containers
 *
 * CopyTargetOutOfBoundsEmptyIndex
 */
/**
 * @begin CopyTargetOutOfBoundsEmptyIndex
 * @summary Copy one element onto empty dest [0] throws Target array out of bounds.
 * @topic Containers
 */
void CopyTargetOutOfBoundsEmptyIndex()
{
	TArray<int32> Source;
	Source.Add(10);
	TArray<int32> Dest;
	Dest.Copy(Source, 0, 1, 0);
}
/** @end */
