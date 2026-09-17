/**
 * @version v1
 * @summary TryLoad of a live CDO returns that identity; empty and missing paths return null.
 * @topic Containers
 *
 * TryLoadReturnsObject
 */
/**
 * @begin TryLoadReturnsObject
 * @summary TryLoad of a live CDO returns that identity; empty and missing paths return null.
 * @topic Containers
 */
bool TryLoadReturnsObject()
{
	AActor LiveCdo = TSubclassOf<AActor>(AActor::StaticClass()).GetDefaultObject();
	if (LiveCdo is null)
	{
		throw("TryLoadReturnsObject setup: required Actor CDO is null");
	}
	FSoftObjectPath FromObject(LiveCdo);
	UObject Loaded = FromObject.TryLoad();
	FSoftObjectPath Empty;
	UObject EmptyLoaded = Empty.TryLoad();
	FSoftObjectPath Missing("/Game/DoesNotExist.DoesNotExist");
	UObject MissingLoaded = Missing.TryLoad();
	return Loaded == LiveCdo && EmptyLoaded is null && MissingLoaded is null;
}
/** @end */
