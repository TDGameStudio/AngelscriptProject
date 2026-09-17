/**
 * @version v1
 * @summary Operator [] reads and writes UObject handles by pointer identity.
 * @topic Containers
 *
 * IndexAccessReadsAndWritesUObject
 */
/**
 * @begin IndexAccessReadsAndWritesUObject
 * @summary Operator [] reads and writes UObject handles by pointer identity.
 * @topic Containers
 */
UCLASS()
class UTArrayIndexAccessReadsAndWritesUObjectHost : UObject
{
}

bool IndexAccessReadsAndWritesUObject()
{
	TArray<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTArrayIndexAccessReadsAndWritesUObjectHost::StaticClass(), n"IndexAccess_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayIndexAccessReadsAndWritesUObjectHost::StaticClass(), n"IndexAccess_Second", true);
	UObject Wrote = NewObject(GetTransientPackage(), UTArrayIndexAccessReadsAndWritesUObjectHost::StaticClass(), n"IndexAccess_Wrote", true);
	Values.Add(First);
	Values.Add(Second);
	UObject& Mutable = Values[0];
	bool bFirstMatches = Mutable == First;
	Mutable = Wrote;
	UObject AfterWrite = Values[0];
	UObject Last = Values[1];
	const TArray<UObject> ConstValues = Values;
	const UObject& ConstFirst = ConstValues[0];
	return bFirstMatches && AfterWrite == Wrote && Last == Second && ConstFirst == Wrote;
}
/** @end */
