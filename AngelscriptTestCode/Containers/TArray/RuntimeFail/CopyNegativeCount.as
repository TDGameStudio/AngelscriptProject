/**
 * @version v1
 * @summary Copy with a negative Count throws Count should not be negative.
 * @topic Containers
 *
 * CopyNegativeCount
 */
/**
 * @begin CopyNegativeCount
 * @summary Copy with a negative Count throws Count should not be negative.
 * @topic Containers
 */
void CopyNegativeCount()
{
	TArray<int32> Source;
	Source.Add(10);
	TArray<int32> Dest;
	Dest.Add(0);
	Dest.Copy(Source, 0, -1, 0);
}
/** @end */
