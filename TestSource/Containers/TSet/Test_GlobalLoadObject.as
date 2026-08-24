// Theme: Containers.TSet. Positive global LoadObject known vs missing texture.
// C++ ReplaceInline of __DEFAULT_TEXTURE_PATH__ / __MISSING_TEXTURE_PATH__ become runner
// parameters. Oracle: LoadObjectKnownTexture==1, LoadObjectMissingTexture==1.
// Extra: empty path does not load a texture; two LoadObject calls of the same path alias.
// DefaultSafe.

int LoadObjectKnownTexture()
{
	UObject Outer = nullptr;
	UObject Loaded = LoadObject(Outer, "__DEFAULT_TEXTURE_PATH__");
	return Cast<UTexture2D>(Loaded) != null ? 1 : 0;
}

int LoadObjectKnownTexture(const FString& DefaultTexturePath)
{
	UObject Outer = nullptr;
	UObject Loaded = LoadObject(Outer, DefaultTexturePath);
	return Cast<UTexture2D>(Loaded) != null ? 1 : 0;
}

int LoadObjectMissingTexture()
{
	UObject Outer = nullptr;
	UObject Loaded = LoadObject(Outer, "__MISSING_TEXTURE_PATH__");
	return Loaded == null ? 1 : 0;
}

int LoadObjectMissingTexture(const FString& MissingTexturePath)
{
	UObject Outer = nullptr;
	UObject Loaded = LoadObject(Outer, MissingTexturePath);
	return Loaded == null ? 1 : 0;
}

int Observe_LoadObject_Nominal(const FString& DefaultTexturePath, const FString& MissingTexturePath)
{
	return LoadObjectKnownTexture(DefaultTexturePath) == 1
		&& LoadObjectMissingTexture(MissingTexturePath) == 1
		? 1 : 0;
}

int Observe_LoadObject_EmptyPathBoundary()
{
	UObject Outer = nullptr;
	UObject Loaded = LoadObject(Outer, "");
	return Loaded == null ? 1 : 0;
}

int Observe_LoadObject_CopyAlias(const FString& DefaultTexturePath)
{
	UObject Outer = nullptr;
	UObject First = LoadObject(Outer, DefaultTexturePath);
	UObject Second = LoadObject(Outer, DefaultTexturePath);
	return First != null && First == Second ? 1 : 0;
}
