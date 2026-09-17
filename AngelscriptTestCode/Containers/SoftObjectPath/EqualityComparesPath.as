/**
 * @version v1
 * @summary Equal FSoftObjectPath values compare equal; empty equals empty; different CDO paths do not.
 * @topic Containers
 *
 * EqualityComparesPath
 */
/**
 * @begin EqualityComparesPath
 * @summary Equal FSoftObjectPath values compare equal; empty equals empty; different CDO paths do not.
 * @topic Containers
 */
bool EqualityComparesPath()
{
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("EqualityComparesPath setup: required Actor CDO is null");
	}
	FSoftObjectPath Left(LiveCdo);
	FSoftObjectPath RightSame(LiveCdo);
	FSoftObjectPath Empty;
	FSoftObjectPath EmptyOther;
	UObject ObjectCdo = TSubclassOf<UObject>(UObject::StaticClass()).GetDefaultObject();
	if (ObjectCdo is null)
	{
		throw("EqualityComparesPath setup: required UObject CDO is null");
	}
	FSoftObjectPath RightDifferent(ObjectCdo);
	return Left == RightSame && Empty == EmptyOther && !(Left == Empty) && !(Left == RightDifferent);
}
/** @end */
