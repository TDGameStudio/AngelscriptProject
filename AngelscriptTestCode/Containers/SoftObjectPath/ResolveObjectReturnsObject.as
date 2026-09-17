/**
 * @version v1
 * @summary ResolveObject of a live CDO returns that identity; empty and missing paths return null.
 * @topic Containers
 *
 * ResolveObjectReturnsObject
 */
/**
 * @begin ResolveObjectReturnsObject
 * @summary ResolveObject of a live CDO returns that identity; empty and missing paths return null.
 * @topic Containers
 */
bool ResolveObjectReturnsObject()
{
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("ResolveObjectReturnsObject setup: required Actor CDO is null");
	}
	FSoftObjectPath FromObject(LiveCdo);
	UObject Resolved = FromObject.ResolveObject();
	FSoftObjectPath Empty;
	UObject EmptyResolved = Empty.ResolveObject();
	FSoftObjectPath Missing("/Game/DoesNotExist.DoesNotExist");
	UObject MissingResolved = Missing.ResolveObject();
	return Resolved == LiveCdo && EmptyResolved is null && MissingResolved is null;
}
/** @end */
