/**
 * @version v1
 * @summary Last() write-through is visible on TArray<UObject> and Last(1) reads from the end.
 * @topic Containers
 *
 * LastValidIndexUObject
 */
/**
 * @begin LastValidIndexUObject
 * @summary Last() write-through is visible on TArray<UObject> and Last(1) reads from the end.
 * @topic Containers
 */
UCLASS()
class UTArrayLastValidIndexUObjectHost : UObject
{
}

bool LastValidIndexUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTArrayLastValidIndexUObjectHost::StaticClass(), n"LastValidIndex_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayLastValidIndexUObjectHost::StaticClass(), n"LastValidIndex_Second", true);
	UObject Third = NewObject(GetTransientPackage(), UTArrayLastValidIndexUObjectHost::StaticClass(), n"LastValidIndex_Third", true);
	UObject Wrote = NewObject(GetTransientPackage(), UTArrayLastValidIndexUObjectHost::StaticClass(), n"LastValidIndex_Wrote", true);
	TArray<UObject> Values;
	Values.Add(First);
	Values.Add(Second);
	Values.Add(Third);
	UObject& LastMut = Values.Last();
	bool bLastIsThird = LastMut == Third;
	LastMut = Wrote;
	UObject& FromEnd = Values.Last(1);
	const TArray<UObject> ConstValues = Values;
	const UObject& ConstLast = ConstValues.Last();
	const UObject& ConstFromEnd = ConstValues.Last(1);
	return bLastIsThird && Values[2] == Wrote && FromEnd == Second && ConstLast == Wrote && ConstFromEnd == Second;
}
/** @end */
