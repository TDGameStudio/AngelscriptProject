/**
 * @version v1
 * @summary Copy places FVector source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 *
 * CopyRangeFVector
 */
/**
 * @begin CopyRangeFVector
 * @summary Copy places FVector source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 */
bool CopyRangeFVector()
{
	TArray<FVector> Source;
	Source.Add(FVector(1.0f, 0.0f, 0.0f));
	Source.Add(FVector(0.0f, 1.0f, 0.0f));
	Source.Add(FVector(0.0f, 0.0f, 1.0f));
	Source.Add(FVector(1.0f, 1.0f, 0.0f));
	TArray<FVector> Dest;
	Dest.SetNum(3);
	Dest.Copy(Source, 1, 2);
	TArray<FVector> DestIndexed;
	DestIndexed.SetNum(4);
	DestIndexed.Copy(Source, 0, 2, 1);
	return Dest.Num() >= 2
		&& Dest[0].Equals(FVector(0.0f, 1.0f, 0.0f))
		&& Dest[1].Equals(FVector(0.0f, 0.0f, 1.0f))
		&& DestIndexed[1].Equals(FVector(1.0f, 0.0f, 0.0f))
		&& DestIndexed[2].Equals(FVector(0.0f, 1.0f, 0.0f));
}
/** @end */
