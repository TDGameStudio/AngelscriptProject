/**
 * @version v1
 * @summary Copy places UObject source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 *
 * CopyRangeUObject
 */
/**
 * @begin CopyRangeUObject
 * @summary Copy places UObject source[1..2] at dest[0] and can target a dest index.
 * @topic Containers
 */
UCLASS()
class UTArrayCopyRangeUObjectHost : UObject
{
}

bool CopyRangeUObject()
{
	UObject A = NewObject(GetTransientPackage(), UTArrayCopyRangeUObjectHost::StaticClass(), n"CopyRange_A", true);
	UObject B = NewObject(GetTransientPackage(), UTArrayCopyRangeUObjectHost::StaticClass(), n"CopyRange_B", true);
	UObject C = NewObject(GetTransientPackage(), UTArrayCopyRangeUObjectHost::StaticClass(), n"CopyRange_C", true);
	UObject D = NewObject(GetTransientPackage(), UTArrayCopyRangeUObjectHost::StaticClass(), n"CopyRange_D", true);
	TArray<UObject> Source;
	Source.Add(A);
	Source.Add(B);
	Source.Add(C);
	Source.Add(D);
	TArray<UObject> Dest;
	Dest.SetNum(3);
	Dest.Copy(Source, 1, 2);
	TArray<UObject> DestIndexed;
	DestIndexed.SetNum(4);
	DestIndexed.Copy(Source, 0, 2, 1);
	return Dest.Num() >= 2 && Dest[0] == B && Dest[1] == C && DestIndexed[1] == A && DestIndexed[2] == B;
}
/** @end */
