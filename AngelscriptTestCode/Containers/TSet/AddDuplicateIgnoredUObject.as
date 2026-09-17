/**
 * @version v1
 * @summary A duplicate UObject Add is ignored and is not appended.
 * @topic Containers
 *
 * AddDuplicateIgnoredUObject
 */
/**
 * @begin AddDuplicateIgnoredUObject
 * @summary A duplicate UObject Add is ignored and is not appended.
 * @topic Containers
 */
UCLASS()
class UTSetAddDuplicateIgnoredUObjectHost : UObject
{
}

bool AddDuplicateIgnoredUObject()
{
	TSet<UObject> Values;
	UObject First = NewObject(GetTransientPackage(), UTSetAddDuplicateIgnoredUObjectHost::StaticClass(), n"AddDuplicateIgnored_First", true);
	Values.Add(First);
	if (Values.Num() != 1 || !Values.Contains(First))
	{
		return false;
	}

	Values.Add(First);
	return Values.Num() == 1 && Values.Contains(First);
}
/** @end */
