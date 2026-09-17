/**
 * @version v1
 * @summary ResolveClass of AActor::StaticClass returns that class; an empty class path returns null.
 * @topic Containers
 *
 * ResolveClassReturnsClass
 */
/**
 * @begin ResolveClassReturnsClass
 * @summary ResolveClass of AActor::StaticClass returns that class; an empty class path returns null.
 * @topic Containers
 */
bool ResolveClassReturnsClass()
{
	UClass ActorClass = AActor::StaticClass();
	if (ActorClass is null)
	{
		throw("ResolveClassReturnsClass setup: required Actor class is null");
	}
	FSoftClassPath FromClass(ActorClass);
	UClass Resolved = FromClass.ResolveClass();
	FSoftClassPath Empty;
	UClass EmptyResolved = Empty.ResolveClass();
	return Resolved == ActorClass && EmptyResolved is null;
}
/** @end */
