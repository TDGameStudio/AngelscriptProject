/**
 * @version v1
 * @summary LoadObject is the synchronous counterpart of the load a TSoftObjectPtr defers: it takes a path and returns the object immediately, or null when the path names nothing. A known texture path yields a UTexture2D, a missing.
 * @topic Containers
 */
/**
 * @version root
 * @summary LoadObject is the synchronous counterpart of the load a TSoftObjectPtr defers: it takes a path and returns the object immediately, or null when the path names nothing. A known texture path yields a UTexture2D, a missing.
 * @topic Baseline
 */
namespace TSoftObjectPtrTest
{
	/**
	 * Observe LoadObject on a known texture path: the asset loads and casts
	 * to a texture.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Get
	 * @Inputs LoadObject with a default texture path token
	 * @Return true when the result casts to UTexture2D
	 */
	UFUNCTION()
	bool LoadObjectKnownTexture()
	{
		UObject Outer = nullptr;
		UObject Loaded = LoadObject(Outer, "__DEFAULT_TEXTURE_PATH__");
		if (Loaded == nullptr)
		{
			return false;
		}
		return Cast<UTexture2D>(Loaded) != nullptr;
	}

	/**
	 * Observe LoadObject on a missing path: it returns null rather than throwing.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Get
	 * @Inputs LoadObject with a missing texture path token
	 * @Return true when the result is null
	 * @Boundary missing asset is null, not an error
	 */
	UFUNCTION()
	bool LoadObjectMissingTexture()
	{
		UObject Outer = nullptr;
		UObject Loaded = LoadObject(Outer, "__MISSING_TEXTURE_PATH__");
		return Loaded == nullptr;
	}

	/**
	 * Observe LoadObject on an empty path: it returns null rather than throwing.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.IsNull
	 * @Inputs LoadObject with an empty path
	 * @Return true when the result is null
	 * @Boundary empty path
	 */
	UFUNCTION()
	bool LoadObjectEmptyPathIsNull()
	{
		UObject Outer = nullptr;
		UObject Loaded = LoadObject(Outer, "");
		return Loaded == nullptr;
	}

	/**
	 * Observe that two loads of the same path return the same object: the
	 * loaded asset is cached rather than duplicated.
	 *
	 * @Kind Observe
	 * @Covers TSoftObjectPtr.Get
	 * @Inputs Two LoadObject calls with the same texture path token
	 * @Return true when both return the same non-null object
	 */
	UFUNCTION()
	bool LoadObjectSamePathAliases()
	{
		UObject Outer = nullptr;
		UObject First = LoadObject(Outer, "__DEFAULT_TEXTURE_PATH__");
		UObject Second = LoadObject(Outer, "__DEFAULT_TEXTURE_PATH__");
		if (First == nullptr)
		{
			return false;
		}
		return First == Second;
	}

	/**
	 * In-only: load through a path received as const&in.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.Get
	 * @Param Path Source path received as const FSoftObjectPath&in
	 * @Inputs Path holds a known texture path
	 * @Return true when the loaded object casts to UTexture2D
	 */
	UFUNCTION()
	bool LoadThroughPath(const FSoftObjectPath&in Path)
	{
		UObject Outer = nullptr;
		UObject Loaded = LoadObject(Outer, Path.ToString());
		if (Loaded == nullptr)
		{
			return false;
		}
		return Cast<UTexture2D>(Loaded) != nullptr;
	}

	/**
	 * Out-only: fill an &out path with a known texture path ready to load.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.ToSoftObjectPath
	 * @Param Result Destination received as FSoftObjectPath&out
	 * @Inputs Empty &out FSoftObjectPath
	 * @Return void; Result holds a loadable texture path
	 */
	UFUNCTION()
	void FillWithLoadableTexturePath(FSoftObjectPath&out Result)
	{
		Result = FSoftObjectPath("__DEFAULT_TEXTURE_PATH__");
	}

	/**
	 * Inout: rewrite a path so that it names a missing asset.
	 *
	 * @Kind RoundTrip
	 * @Covers TSoftObjectPtr.IsNull
	 * @Param Path Path received as FSoftObjectPath&inout, starts holding a texture path
	 * @Inputs Path.IsValid() is true
	 * @Return void; Path holds a missing texture path that loads to null
	 */
	UFUNCTION()
	void RewritePathToMissingTexture(FSoftObjectPath&inout Path)
	{
		Path = FSoftObjectPath("__MISSING_TEXTURE_PATH__");
	}
}
/** @end */
