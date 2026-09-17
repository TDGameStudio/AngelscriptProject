/**
 * @version v1
 * @summary ResolveClass of a missing package path returns null without loading.
 * @topic Containers
 *
 * ResolveClassMissingPath
 */
/**
 * @begin ResolveClassMissingPath
 * @summary ResolveClass of a missing package path returns null without loading.
 * @topic Containers
 */
bool ResolveClassMissingPath()
{
	FSoftClassPath Missing("/Game/DoesNotExist.DoesNotExist");
	UClass Resolved = Missing.ResolveClass();
	return Resolved is null;
}
/** @end */
