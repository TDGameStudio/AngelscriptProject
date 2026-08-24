// Theme: Containers.TSet. Positive FSoftObjectPath / FSoftClassPath string identity.
// C++ ReplaceInline tokens become runner parameters on the overloads.
// Oracle: SoftObjectPathStringIdentity==1, SoftClassPathStringIdentity==1,
// MissingSoftClassPathResolveBoundaries==1. Extra: empty FSoftObjectPath is null;
// missing class already covers the null resolve/load boundary. DefaultSafe.

int SoftObjectPathStringIdentity()
{
	FSoftObjectPath TexturePath("__DEFAULT_TEXTURE_PATH__");
	if (!TexturePath.IsValid() || TexturePath.IsNull())
	{
		return 0;
	}

	if (!TexturePath.IsAsset() || TexturePath.IsSubobject())
	{
		return 0;
	}

	if (TexturePath.ToString() != "__DEFAULT_TEXTURE_PATH__")
	{
		return 0;
	}

	if (TexturePath.GetLongPackageName() != "__DEFAULT_TEXTURE_PACKAGE__")
	{
		return 0;
	}

	return TexturePath.GetAssetName() == "__DEFAULT_TEXTURE_ASSET__" ? 1 : 0;
}

int SoftObjectPathStringIdentity(const FString& TexturePathString, const FString& TexturePackage, const FString& TextureAsset)
{
	FSoftObjectPath TexturePath(TexturePathString);
	if (!TexturePath.IsValid() || TexturePath.IsNull())
	{
		return 0;
	}

	if (!TexturePath.IsAsset() || TexturePath.IsSubobject())
	{
		return 0;
	}

	if (TexturePath.ToString() != TexturePathString)
	{
		return 0;
	}

	if (TexturePath.GetLongPackageName() != TexturePackage)
	{
		return 0;
	}

	return TexturePath.GetAssetName() == TextureAsset ? 1 : 0;
}

int SoftClassPathStringIdentity()
{
	FSoftClassPath ClassPath("__ACTOR_CLASS_PATH__");
	if (!ClassPath.IsValid() || ClassPath.IsNull())
	{
		return 0;
	}

	if (!ClassPath.IsAsset() || ClassPath.IsSubobject())
	{
		return 0;
	}

	if (ClassPath.ToString() != "__ACTOR_CLASS_PATH__")
	{
		return 0;
	}

	if (ClassPath.GetLongPackageName() != "__ACTOR_CLASS_PACKAGE__")
	{
		return 0;
	}

	return ClassPath.GetAssetName() == "__ACTOR_CLASS_ASSET__" ? 1 : 0;
}

int SoftClassPathStringIdentity(const FString& ActorClassPath, const FString& ActorClassPackage, const FString& ActorClassAsset)
{
	FSoftClassPath ClassPath(ActorClassPath);
	if (!ClassPath.IsValid() || ClassPath.IsNull())
	{
		return 0;
	}

	if (!ClassPath.IsAsset() || ClassPath.IsSubobject())
	{
		return 0;
	}

	if (ClassPath.ToString() != ActorClassPath)
	{
		return 0;
	}

	if (ClassPath.GetLongPackageName() != ActorClassPackage)
	{
		return 0;
	}

	return ClassPath.GetAssetName() == ActorClassAsset ? 1 : 0;
}

int MissingSoftClassPathResolveBoundaries()
{
	FSoftClassPath ClassPath("__MISSING_CLASS_PATH__");
	return ClassPath.IsValid()
		&& ClassPath.ResolveClass() == null
		&& ClassPath.TryLoadClass() == null ? 1 : 0;
}

int MissingSoftClassPathResolveBoundaries(const FString& MissingClassPath)
{
	FSoftClassPath ClassPath(MissingClassPath);
	return ClassPath.IsValid()
		&& ClassPath.ResolveClass() == null
		&& ClassPath.TryLoadClass() == null ? 1 : 0;
}

int Observe_SoftPathIdentity_Nominal(
	const FString& TexturePathString,
	const FString& TexturePackage,
	const FString& TextureAsset,
	const FString& ActorClassPath,
	const FString& ActorClassPackage,
	const FString& ActorClassAsset,
	const FString& MissingClassPath)
{
	return SoftObjectPathStringIdentity(TexturePathString, TexturePackage, TextureAsset) == 1
		&& SoftClassPathStringIdentity(ActorClassPath, ActorClassPackage, ActorClassAsset) == 1
		&& MissingSoftClassPathResolveBoundaries(MissingClassPath) == 1
		? 1 : 0;
}

int Observe_SoftObjectPath_EmptyNullBoundary()
{
	FSoftObjectPath TexturePath("");
	return TexturePath.IsNull() ? 1 : 0;
}

int Observe_SoftObjectPath_CopyIndependence(const FString& TexturePathString)
{
	FSoftObjectPath First(TexturePathString);
	FSoftObjectPath Second(TexturePathString);
	return First.ToString() == Second.ToString() ? 1 : 0;
}
