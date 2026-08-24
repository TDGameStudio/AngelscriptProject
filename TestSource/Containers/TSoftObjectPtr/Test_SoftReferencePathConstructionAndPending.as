// Theme: Containers.TSoftObjectPtr. Positive: TSoftObjectPtr/TSoftClassPtr path identity.
// C++: AngelscriptCoverageAssetLoadingTests.cpp::SoftReferencePathConstructionAndPending
// ExecuteAndExpectInt each helper == 1. Path tokens become runner FString parameters.
// Extra: ResetSoftReferencesClearPaths is the empty-after-reset vector; missing refs stay pending.
// DefaultSafe. Source owns locals.

int SoftObjectPtrConstructedFromPathKeepsIdentity(FString DefaultTexturePath)
{
	FSoftObjectPath TexturePath(DefaultTexturePath);
	TSoftObjectPtr<UTexture2D> TextureRef(TexturePath);
	return !TextureRef.IsNull()
		&& TextureRef.ToSoftObjectPath() == TexturePath
		&& TextureRef.ToString() == TexturePath.ToString()
		&& TextureRef.GetLongPackageName() == TexturePath.GetLongPackageName()
		&& TextureRef.GetAssetName() == TexturePath.GetAssetName() ? 1 : 0;
}

int MissingSoftObjectPtrReportsPending(FString MissingTexturePath)
{
	TSoftObjectPtr<UTexture2D> MissingRef(FSoftObjectPath(MissingTexturePath));
	return !MissingRef.IsNull()
		&& !MissingRef.IsValid()
		&& MissingRef.IsPending()
		&& MissingRef.Get() == null ? 1 : 0;
}

int CrossLevelSoftObjectPtrStaysPathOnly(FString CrossLevelActorPath)
{
	TSoftObjectPtr<AActor> ActorRef(FSoftObjectPath(CrossLevelActorPath));
	return !ActorRef.IsNull()
		&& !ActorRef.IsValid()
		&& ActorRef.IsPending()
		&& ActorRef.ToString().Contains("PersistentLevel.OtherActor") ? 1 : 0;
}

int SoftClassPtrConstructedFromPathResolvesActor(FString ActorClassPath)
{
	FSoftObjectPath ClassObjectPath(ActorClassPath);
	TSoftClassPtr<AActor> ActorClassRef(ClassObjectPath);
	TSubclassOf<AActor> LoadedClass = ActorClassRef.Get();
	return !ActorClassRef.IsNull()
		&& ActorClassRef.IsValid()
		&& ActorClassRef.ToSoftObjectPath() == ClassObjectPath
		&& LoadedClass.IsValid()
		&& LoadedClass.IsChildOf(AActor::StaticClass()) ? 1 : 0;
}

int MissingSoftClassPtrReportsPending(FString MissingClassPath)
{
	TSoftClassPtr<AActor> MissingClassRef(FSoftObjectPath(MissingClassPath));
	TSubclassOf<AActor> MissingClass = MissingClassRef.Get();
	return !MissingClassRef.IsNull()
		&& !MissingClassRef.IsValid()
		&& MissingClassRef.IsPending()
		&& !MissingClass.IsValid() ? 1 : 0;
}

int ResetSoftReferencesClearPaths(FString DefaultTexturePath, FString ActorClassPath)
{
	TSoftObjectPtr<UTexture2D> TextureRef(FSoftObjectPath(DefaultTexturePath));
	TSoftClassPtr<AActor> ActorClassRef(FSoftObjectPath(ActorClassPath));
	TextureRef.Reset();
	ActorClassRef.Reset();
	return TextureRef.IsNull()
		&& ActorClassRef.IsNull()
		&& !TextureRef.IsPending()
		&& !ActorClassRef.IsPending()
		&& TextureRef.ToString().IsEmpty()
		&& ActorClassRef.ToString().IsEmpty() ? 1 : 0;
}

int Observe_SoftObjectPtrIdentity_Nominal(FString DefaultTexturePath)
{
	return SoftObjectPtrConstructedFromPathKeepsIdentity(DefaultTexturePath);
}

int Observe_MissingSoftObjectPtr_PendingBoundary(FString MissingTexturePath)
{
	return MissingSoftObjectPtrReportsPending(MissingTexturePath);
}

int Observe_ResetSoftReferences_EmptyAfterReset(FString DefaultTexturePath, FString ActorClassPath)
{
	return ResetSoftReferencesClearPaths(DefaultTexturePath, ActorClassPath);
}
