/**
 * @version v1
 * @summary Copy one element from an empty source throws Source array out of bounds.
 * @topic Containers
 *
 * CopySourceOutOfBoundsEmptyIndex
 */
/**
 * @begin CopySourceOutOfBoundsEmptyIndex
 * @summary Copy one element from an empty source throws Source array out of bounds.
 * @topic Containers
 */
void CopySourceOutOfBoundsEmptyIndex()
{
	TArray<int32> Source;
	TArray<int32> Dest;
	Dest.Add(0);
	Dest.Copy(Source, 0, 1, 0);
}
/** @end */
