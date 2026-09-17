/**
 * @version v1
 * @summary Copy of one existing source slot overwrites dest[0] without changing Num.
 * @topic Containers
 *
 * CopySlice
 */
/**
 * @begin CopySlice
 * @summary Copy of one existing source slot overwrites dest[0] without changing Num.
 * @topic Containers
 */
bool CopySlice()
{
	TArray<int32> Dest;
	Dest.Add(0);
	TArray<int32> Source;
	Source.Add(10);
	Dest.Copy(Source, 0, 1, 0);
	return Dest.Num() == 1 && Dest[0] == 10;
}
/** @end */
