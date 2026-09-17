/**
 * @version v1
 * @summary Copy when the source slice runs past Source.Num throws Source array out of bounds.
 * @topic Containers
 *
 * CopySourceOutOfBounds
 */
/**
 * @begin CopySourceOutOfBounds
 * @summary Copy when the source slice runs past Source.Num throws Source array out of bounds.
 * @topic Containers
 */
void CopySourceOutOfBounds()
{
	TArray<int32> Source;
	Source.Add(10);
	TArray<int32> Dest;
	Dest.Add(0);
	Dest.Add(0);
	Dest.Copy(Source, 0, 2, 0);
}
/** @end */
