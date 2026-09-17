/**
 * @version v1
 * @summary Copy places source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 *
 * CopyRange
 */
/**
 * @begin CopyRange
 * @summary Copy places source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 */
bool CopyRange()
{
	TArray<int32> Source;
	Source.Add(10);
	Source.Add(20);
	Source.Add(30);
	Source.Add(40);
	TArray<int32> Dest;
	Dest.SetNum(3);
	Dest.Copy(Source, 1, 2);
	TArray<int32> DestIndexed;
	DestIndexed.SetNum(4);
	DestIndexed.Copy(Source, 0, 2, 1);
	return Dest.Num() >= 2 && Dest[0] == 20 && Dest[1] == 30 && DestIndexed[1] == 10 && DestIndexed[2] == 20;
}
/** @end */
