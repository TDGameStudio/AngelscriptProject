/**
 * @version v1
 * @summary Copy places float source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 *
 * CopyRangeFloat
 */
/**
 * @begin CopyRangeFloat
 * @summary Copy places float source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 */
bool CopyRangeFloat()
{
	TArray<float> Source;
	Source.Add(10.0f);
	Source.Add(20.0f);
	Source.Add(30.0f);
	Source.Add(40.0f);
	TArray<float> Dest;
	Dest.SetNum(3);
	Dest.Copy(Source, 1, 2);
	TArray<float> DestIndexed;
	DestIndexed.SetNum(4);
	DestIndexed.Copy(Source, 0, 2, 1);
	return Dest.Num() >= 2 && Dest[0] == 20.0f && Dest[1] == 30.0f && DestIndexed[1] == 10.0f && DestIndexed[2] == 20.0f;
}
/** @end */
