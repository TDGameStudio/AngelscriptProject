/**
 * @version v1
 * @summary Copy places bool source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 *
 * CopyRangeBool
 */
/**
 * @begin CopyRangeBool
 * @summary Copy places bool source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 */
bool CopyRangeBool()
{
	TArray<bool> Source;
	Source.Add(false);
	Source.Add(true);
	Source.Add(false);
	Source.Add(true);
	TArray<bool> Dest;
	Dest.SetNum(3);
	Dest.Copy(Source, 1, 2);
	TArray<bool> DestIndexed;
	DestIndexed.SetNum(4);
	DestIndexed.Copy(Source, 0, 2, 1);
	return Dest.Num() >= 2 && Dest[0] == true && Dest[1] == false && DestIndexed[1] == false && DestIndexed[2] == true;
}
/** @end */
