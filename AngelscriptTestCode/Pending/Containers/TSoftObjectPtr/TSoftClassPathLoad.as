/**
 * @version v1
 * @summary FSoftClassPath resolves to a UClass rather than an object, which makes it the class-side counterpart of the path a TSoftObjectPtr carries. TryLoadClass loads synchronously and returns the class; ResolveClass only returns.
 * @topic Containers
 */
/**
 * @version root
 * @summary FSoftClassPath resolves to a UClass rather than an object, which makes it the class-side counterpart of the path a TSoftObjectPtr carries. TryLoadClass loads synchronously and returns the class; ResolveClass only returns.
 * @topic Baseline
 */
namespace TSoftObjectPtrTest
{
	/**
	 * Observe TryLoadClass: a path to a known actor class loads synchronously.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Get
	 * @Inputs FSoftClassPath built from an actor class path token
	 * @Return true when TryLoadClass() returns the actor class
	 */
	UFUNCTION()
	bool TryLoadKnownActorClass()
	{
		FSoftClassPath ClassPath("__ACTOR_CLASS_PATH__");
		UClass LoadedClass = ClassPath.TryLoadClass();
		if (LoadedClass == nullptr)
		{
			return false;
		}
		return LoadedClass == AActor::StaticClass();
	}

	/**
	 * Observe that once TryLoadClass has run, ResolveClass returns the same
	 * class: the load brought it into memory.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Get
	 * @Inputs FSoftClassPath built from an actor class path token; TryLoadClass then ResolveClass
	 * @Return true when ResolveClass matches the loaded class
	 * @Boundary ResolveClass only sees classes already in memory
	 */
	UFUNCTION()
	bool ResolveKnownActorClassAfterLoad()
	{
		FSoftClassPath ClassPath("__ACTOR_CLASS_PATH__");
		UClass LoadedClass = ClassPath.TryLoadClass();
		UClass ResolvedClass = ClassPath.ResolveClass();
		if (LoadedClass == nullptr)
		{
			return false;
		}
		return ResolvedClass == LoadedClass;
	}

	/**
	 * Observe that an empty path loads nothing: TryLoadClass returns null and
	 * the path stays null.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.IsNull
	 * @Inputs FSoftClassPath built from an empty string
	 * @Return true when TryLoadClass is null and the path is null
	 */
	UFUNCTION()
	bool EmptyPathLoadsNothing()
	{
		FSoftClassPath ClassPath("");
		if (ClassPath.TryLoadClass() != nullptr)
		{
			return false;
		}
		return ClassPath.IsNull();
	}

	/**
	 * Observe that two paths built from the same string resolve to the same
	 * class: the load result is a property of the path, not of the instance.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Get
	 * @Inputs Two FSoftClassPath built from the same actor class path token
	 * @Return true when both resolve to the same non-null class
	 */
	UFUNCTION()
	bool SoftClassPathCopyIndependence()
	{
		FSoftClassPath First("__ACTOR_CLASS_PATH__");
		FSoftClassPath Second("__ACTOR_CLASS_PATH__");

		UClass LoadedFirst = First.TryLoadClass();
		UClass LoadedSecond = Second.TryLoadClass();
		if (LoadedFirst == nullptr)
		{
			return false;
		}
		return LoadedFirst == LoadedSecond;
	}

	/**
	 * In-only: load a class through a const&in class path.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.Get
	 * @Param Path Source class path received as const FSoftClassPath&in
	 * @Inputs Path holds a known actor class path
	 * @Return true when TryLoadClass returns the actor class
	 */
	UFUNCTION()
	bool LoadClassThroughPath(const FSoftClassPath&in Path)
	{
		UClass LoadedClass = Path.TryLoadClass();
		if (LoadedClass == nullptr)
		{
			return false;
		}
		return LoadedClass == AActor::StaticClass();
	}

	/**
	 * Out-only: fill an &out class path with a known actor class path.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Param Result Destination received as FSoftClassPath&out
	 * @Inputs Empty &out FSoftClassPath
	 * @Return void; Result holds a loadable actor class path
	 */
	UFUNCTION()
	void FillWithActorClassPath(FSoftClassPath&out Result)
	{
		Result = FSoftClassPath("__ACTOR_CLASS_PATH__");
	}

	/**
	 * Inout: rewrite a class path in place and confirm the new one loads.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.Get
	 * @Param Path Path received as FSoftClassPath&inout, starts holding an actor class path
	 * @Inputs Path.IsValid() is true
	 * @Return void; Path holds a missing class path that loads nothing
	 */
	UFUNCTION()
	void RewritePathToMissingClass(FSoftClassPath&inout Path)
	{
		Path = FSoftClassPath("__MISSING_CLASS_PATH__");
	}
}
/** @end */
