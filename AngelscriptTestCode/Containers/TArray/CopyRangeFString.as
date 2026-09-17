/**
 * @version v1
 * @summary Copy places FString source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 *
 * CopyRangeFString
 */
/**
 * @begin CopyRangeFString
 * @summary Copy places FString source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 */
bool CopyRangeFString()
{
	TArray<FString> Source;
	Source.Add("alpha");
	Source.Add("beta");
	Source.Add("gamma");
	Source.Add("delta");
	TArray<FString> Dest;
	Dest.SetNum(3);
	Dest.Copy(Source, 1, 2);
	TArray<FString> DestIndexed;
	DestIndexed.SetNum(4);
	DestIndexed.Copy(Source, 0, 2, 1);
	return Dest.Num() >= 2 && Dest[0] == "beta" && Dest[1] == "gamma" && DestIndexed[1] == "alpha" && DestIndexed[2] == "beta";
}
/** @end */
