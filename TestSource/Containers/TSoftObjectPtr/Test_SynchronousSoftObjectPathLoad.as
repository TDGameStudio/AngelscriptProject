// Theme: Containers.TSoftObjectPtr. Positive: FSoftObjectPath TryLoad / ResolveObject.
// C++: AngelscriptCoverageAssetLoadingTests.cpp::SynchronousSoftObjectPathLoad
// ExecuteAndExpectInt TryLoadKnownTexture/ResolveKnownTextureAfterLoad/MissingTextureReturnsNull == 1.
// C++ __DEFAULT_TEXTURE_PATH__ / __MISSING_TEXTURE_PATH__ become runner parameters.
// Extra: empty path TryLoad is null; known load then ResolveObject aliases the same object.
// DefaultSafe. Source owns locals.

int TryLoadKnownTexture(FString DefaultTexturePath)
{
	FSoftObjectPath TexturePath(DefaultTexturePath);
	UObject Loaded = TexturePath.TryLoad();
	return Cast<UTexture2D>(Loaded) != null ? 1 : 0;
}

int ResolveKnownTextureAfterLoad(FString DefaultTexturePath)
{
	FSoftObjectPath TexturePath(DefaultTexturePath);
	UObject Loaded = TexturePath.TryLoad();
	UObject Resolved = TexturePath.ResolveObject();
	return Loaded != null && Resolved == Loaded ? 1 : 0;
}

int MissingTextureReturnsNull(FString MissingTexturePath)
{
	FSoftObjectPath TexturePath(MissingTexturePath);
	return TexturePath.TryLoad() == null ? 1 : 0;
}

int Observe_TryLoadKnownTexture_Nominal(FString DefaultTexturePath)
{
	return TryLoadKnownTexture(DefaultTexturePath);
}

int Observe_TryLoad_EmptyPathNull()
{
	FSoftObjectPath TexturePath("");
	return TexturePath.TryLoad() == null ? 1 : 0;
}

int Observe_ResolveKnownTextureAfterLoad_CopyAlias(FString DefaultTexturePath)
{
	return ResolveKnownTextureAfterLoad(DefaultTexturePath);
}

int Observe_MissingTextureReturnsNull_Boundary(FString MissingTexturePath)
{
	return MissingTextureReturnsNull(MissingTexturePath);
}
