/**
 * @version v1
 * @summary FSoftObjectPath and FSoftClassPath are the path values a TSoftObjectPtr carries, so their string identity is part of the soft-pointer surface. ToString round-trips the full path, GetLongPackageName yields the package.
 * @topic Containers
 */
/**
 * @version root
 * @summary FSoftObjectPath and FSoftClassPath are the path values a TSoftObjectPtr carries, so their string identity is part of the soft-pointer surface. ToString round-trips the full path, GetLongPackageName yields the package.
 * @topic Baseline
 */
namespace TSoftObjectPtrTest
{
	/**
	 * Observe FSoftObjectPath string identity: the path round-trips and its
	 * package and asset parts split cleanly.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Inputs FSoftObjectPath built from a texture path token
	 * @Return true when ToString matches the path and package/asset split correctly
	 */
	UFUNCTION()
	bool SoftObjectPathStringIdentity()
	{
		FSoftObjectPath TexturePath("__DEFAULT_TEXTURE_PATH__");
		if (!TexturePath.IsValid())
		{
			return false;
		}
		if (TexturePath.IsNull())
		{
			return false;
		}
		if (!TexturePath.IsAsset())
		{
			return false;
		}
		if (TexturePath.IsSubobject())
		{
			return false;
		}
		if (TexturePath.ToString() != "__DEFAULT_TEXTURE_PATH__")
		{
			return false;
		}
		if (TexturePath.GetLongPackageName() != "__DEFAULT_TEXTURE_PACKAGE__")
		{
			return false;
		}
		return TexturePath.GetAssetName() == "__DEFAULT_TEXTURE_ASSET__";
	}

	/**
	 * Observe FSoftClassPath string identity: a class path splits the same way.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Inputs FSoftClassPath built from an actor class path token
	 * @Return true when ToString matches the path and package/asset split correctly
	 */
	UFUNCTION()
	bool SoftClassPathStringIdentity()
	{
		FSoftClassPath ClassPath("__ACTOR_CLASS_PATH__");
		if (!ClassPath.IsValid())
		{
			return false;
		}
		if (ClassPath.IsNull())
		{
			return false;
		}
		if (!ClassPath.IsAsset())
		{
			return false;
		}
		if (ClassPath.IsSubobject())
		{
			return false;
		}
		if (ClassPath.ToString() != "__ACTOR_CLASS_PATH__")
		{
			return false;
		}
		if (ClassPath.GetLongPackageName() != "__ACTOR_CLASS_PACKAGE__")
		{
			return false;
		}
		return ClassPath.GetAssetName() == "__ACTOR_CLASS_ASSET__";
	}

	/**
	 * Observe the missing-class boundary: a well-formed path to a class that
	 * does not exist is still valid as a path, while both resolve and load
	 * return null rather than throwing.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.IsValid
	 * @Inputs FSoftClassPath built from a missing class path token
	 * @Return true when the path is valid yet ResolveClass and TryLoadClass are null
	 * @Boundary path validity vs asset availability
	 */
	UFUNCTION()
	bool MissingSoftClassPathResolveBoundaries()
	{
		FSoftClassPath ClassPath("__MISSING_CLASS_PATH__");
		if (!ClassPath.IsValid())
		{
			return false;
		}
		if (ClassPath.ResolveClass() != nullptr)
		{
			return false;
		}
		return ClassPath.TryLoadClass() == nullptr;
	}

	/**
	 * Observe that an empty FSoftObjectPath is null rather than valid.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.IsNull
	 * @Inputs FSoftObjectPath built from an empty string
	 * @Return true when IsNull() is true
	 */
	UFUNCTION()
	bool EmptySoftObjectPathIsNull()
	{
		FSoftObjectPath TexturePath("");
		if (!TexturePath.IsNull())
		{
			return false;
		}
		return !TexturePath.IsValid();
	}

	/**
	 * Observe that two paths built from the same string are independent values
	 * that compare equal.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Inputs Two FSoftObjectPath built from the same path token
	 * @Return true when both produce the same string
	 */
	UFUNCTION()
	bool SoftObjectPathCopyIndependence()
	{
		FSoftObjectPath First("__DEFAULT_TEXTURE_PATH__");
		FSoftObjectPath Second("__DEFAULT_TEXTURE_PATH__");
		if (First.ToString() != Second.ToString())
		{
			return false;
		}
		return First.IsValid() && Second.IsValid();
	}

	/**
	 * In-only: read a path's package and asset parts through a const&in reference.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.GetLongPackageName
	 * @Param Path Source path received as const FSoftObjectPath&in
	 * @Inputs Path was built from a texture path token
	 * @Return true when the package and asset parts match
	 */
	UFUNCTION()
	bool ReadPathParts(const FSoftObjectPath&in Path)
	{
		if (Path.GetLongPackageName() != "__DEFAULT_TEXTURE_PACKAGE__")
		{
			return false;
		}
		return Path.GetAssetName() == "__DEFAULT_TEXTURE_ASSET__";
	}

	/**
	 * Out-only: fill an &out path with a texture path.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Param Result Destination received as FSoftObjectPath&out
	 * @Inputs Empty &out FSoftObjectPath
	 * @Return void; Result holds a valid texture path
	 */
	UFUNCTION()
	void FillWithTexturePath(FSoftObjectPath&out Result)
	{
		Result = FSoftObjectPath("__DEFAULT_TEXTURE_PATH__");
	}

	/**
	 * Inout: rewrite a path in place and confirm the identity follows.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Param Path Path received as FSoftObjectPath&inout, starts holding a texture path
	 * @Inputs Path.IsValid() is true
	 * @Return void; Path holds the actor class path
	 */
	UFUNCTION()
	void RewritePath(FSoftObjectPath&inout Path)
	{
		Path = FSoftObjectPath("__ACTOR_CLASS_PATH__");
	}
}
/** @end */
