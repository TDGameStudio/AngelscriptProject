/**
 * @version v1
 * @summary Remove deletes every matching UObject handle and leaves non-matches in place.
 * @topic Containers
 *
 * RemoveAllMatchesUObject
 */
/**
 * @begin RemoveAllMatchesUObject
 * @summary Remove deletes every matching UObject handle and leaves non-matches in place.
 * @topic Containers
 */
UCLASS()
class UTArrayRemoveAllMatchesUObjectHost : UObject
{
}

bool RemoveAllMatchesUObject()
{
	UObject First = NewObject(GetTransientPackage(), UTArrayRemoveAllMatchesUObjectHost::StaticClass(), n"RemoveAllMatches_First", true);
	UObject Second = NewObject(GetTransientPackage(), UTArrayRemoveAllMatchesUObjectHost::StaticClass(), n"RemoveAllMatches_Second", true);
	UObject MissingHandle = NewObject(GetTransientPackage(), UTArrayRemoveAllMatchesUObjectHost::StaticClass(), n"RemoveAllMatches_Missing", true);
	TArray<UObject> Values;
	Values.Add(First);
	Values.Add(Second);
	Values.Add(First);
	int Removed = Values.Remove(First);
	int Missing = Values.Remove(MissingHandle);
	return Removed == 2 && Missing == 0 && Values.Num() == 1 && Values[0] == Second;
}
/** @end */
