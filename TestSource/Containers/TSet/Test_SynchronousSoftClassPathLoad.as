// Theme: Containers.TSet. Positive FSoftClassPath TryLoadClass / ResolveClass.
// C++ ReplaceInline of __ACTOR_CLASS_PATH__ becomes the ActorClassPath runner parameter.
// Oracle: TryLoadKnownActorClass==1, ResolveKnownActorClassAfterLoad==1.
// Extra: empty path does not load AActor; two ClassPath copies share the same load result.
// DefaultSafe.

int TryLoadKnownActorClass()
{
	FSoftClassPath ClassPath("__ACTOR_CLASS_PATH__");
	return ClassPath.TryLoadClass() == AActor::StaticClass() ? 1 : 0;
}

int TryLoadKnownActorClass(const FString& ActorClassPath)
{
	FSoftClassPath ClassPath(ActorClassPath);
	return ClassPath.TryLoadClass() == AActor::StaticClass() ? 1 : 0;
}

int ResolveKnownActorClassAfterLoad()
{
	FSoftClassPath ClassPath("__ACTOR_CLASS_PATH__");
	UClass LoadedClass = ClassPath.TryLoadClass();
	UClass ResolvedClass = ClassPath.ResolveClass();
	return LoadedClass != null && ResolvedClass == LoadedClass ? 1 : 0;
}

int ResolveKnownActorClassAfterLoad(const FString& ActorClassPath)
{
	FSoftClassPath ClassPath(ActorClassPath);
	UClass LoadedClass = ClassPath.TryLoadClass();
	UClass ResolvedClass = ClassPath.ResolveClass();
	return LoadedClass != null && ResolvedClass == LoadedClass ? 1 : 0;
}

int Observe_SoftClassPath_Nominal(const FString& ActorClassPath)
{
	return TryLoadKnownActorClass(ActorClassPath) == 1
		&& ResolveKnownActorClassAfterLoad(ActorClassPath) == 1
		? 1 : 0;
}

int Observe_SoftClassPath_EmptyPath()
{
	FSoftClassPath ClassPath("");
	return ClassPath.TryLoadClass() != AActor::StaticClass() ? 1 : 0;
}

int Observe_SoftClassPath_CopyIndependence(const FString& ActorClassPath)
{
	FSoftClassPath First(ActorClassPath);
	FSoftClassPath Second(ActorClassPath);
	UClass LoadedFirst = First.TryLoadClass();
	UClass LoadedSecond = Second.TryLoadClass();
	return LoadedFirst != null && LoadedFirst == LoadedSecond ? 1 : 0;
}
