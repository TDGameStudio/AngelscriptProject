/**
 * @version v1
 * @summary TryLoadClass of AActor::StaticClass returns that class; empty and missing paths return null.
 * @topic Containers
 *
 * TryLoadClassReturnsClass
 */
/**
 * @begin TryLoadClassReturnsClass
 * @summary TryLoadClass of AActor::StaticClass returns that class; empty and missing paths return null.
 * @topic Containers
 */
bool TryLoadClassReturnsClass()
{
	UClass ActorClass = AActor::StaticClass();
	if (ActorClass is null)
	{
		throw("TryLoadClassReturnsClass setup: required Actor class is null");
	}
	FSoftClassPath FromClass(ActorClass);
	UClass Loaded = FromClass.TryLoadClass();
	FSoftClassPath Empty;
	UClass EmptyLoaded = Empty.TryLoadClass();
	FSoftClassPath Missing("/Game/DoesNotExist.DoesNotExist");
	UClass MissingLoaded = Missing.TryLoadClass();
	return Loaded == ActorClass && EmptyLoaded is null && MissingLoaded is null;
}
/** @end */
