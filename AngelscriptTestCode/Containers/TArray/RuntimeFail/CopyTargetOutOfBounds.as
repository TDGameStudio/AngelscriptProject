/**
 * @version v1
 * @summary Copy when dest does not already have enough slots throws Target array out of bounds.
 * @topic Containers
 *
 * CopyTargetOutOfBounds
 */
/**
 * @begin CopyTargetOutOfBounds
 * @summary Copy when dest does not already have enough slots throws Target array out of bounds.
 * @topic Containers
 */
void CopyTargetOutOfBounds()
{
	TArray<int32> Source;
	Source.Add(10);
	Source.Add(20);
	TArray<int32> Dest;
	Dest.Add(0);
	Dest.Copy(Source, 0, 2, 0);
}
/** @end */
