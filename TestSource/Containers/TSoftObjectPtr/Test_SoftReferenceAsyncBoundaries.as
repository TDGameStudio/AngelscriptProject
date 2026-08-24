// Theme: Containers.TSoftObjectPtr. Positive: TSoftObjectPtr/TSoftClassPtr LoadAsync callbacks.
// C++: AngelscriptCoverageAssetLoadingTests.cpp::SoftReferenceAsyncBoundaries
// ExecuteAndExpectInt AsyncObjectLoadedPathInvokesCallback / Missing / Class == 1.
// Path tokens become runner FString parameters.
// Extra: empty default receiver counts are 0; missing path reports a null payload.
// DefaultSafe. Receiver is NewObject-owned.

UCLASS()
class UCoverageSoftReferenceAsyncReceiver : UObject
{
	UPROPERTY()
	int ObjectCallbackCount = 0;

	UPROPERTY()
	bool bObjectPayloadWasTexture = false;

	UPROPERTY()
	int MissingObjectCallbackCount = 0;

	UPROPERTY()
	bool bMissingObjectPayloadWasNull = false;

	UPROPERTY()
	int ClassCallbackCount = 0;

	UPROPERTY()
	bool bClassPayloadWasActorClass = false;

	UFUNCTION()
	void HandleObjectLoaded(UObject Loaded)
	{
		ObjectCallbackCount += 1;
		bObjectPayloadWasTexture = Cast<UTexture2D>(Loaded) != nullptr;
	}

	UFUNCTION()
	void HandleMissingObject(UObject Loaded)
	{
		MissingObjectCallbackCount += 1;
		bMissingObjectPayloadWasNull = Loaded == nullptr;
	}

	UFUNCTION()
	void HandleClassLoaded(UClass Loaded)
	{
		ClassCallbackCount += 1;
		bClassPayloadWasActorClass = Loaded != nullptr && Loaded.IsChildOf(AActor::StaticClass());
	}
}

int AsyncObjectLoadedPathInvokesCallback(FString DefaultTexturePath)
{
	UCoverageSoftReferenceAsyncReceiver Receiver = Cast<UCoverageSoftReferenceAsyncReceiver>(
		NewObject(GetTransientPackage(), UCoverageSoftReferenceAsyncReceiver::StaticClass(), n"CoverageSoftReferenceObjectReceiver", true));
	if (Receiver == nullptr)
	{
		return 0;
	}

	FOnSoftObjectLoaded Delegate;
	Delegate.BindUFunction(Receiver, n"HandleObjectLoaded");

	FSoftObjectPath TexturePath(DefaultTexturePath);
	UObject LoadedTexture = TexturePath.TryLoad();
	if (LoadedTexture == nullptr)
	{
		return 0;
	}
	TSoftObjectPtr<UTexture2D> TextureRef(TexturePath);
	TextureRef.LoadAsync(Delegate);
	return Receiver.ObjectCallbackCount == 1 && Receiver.bObjectPayloadWasTexture ? 1 : 0;
}

int AsyncObjectMissingPathReportsNull(FString MissingTexturePath)
{
	UCoverageSoftReferenceAsyncReceiver Receiver = Cast<UCoverageSoftReferenceAsyncReceiver>(
		NewObject(GetTransientPackage(), UCoverageSoftReferenceAsyncReceiver::StaticClass(), n"CoverageSoftReferenceMissingReceiver", true));
	if (Receiver == nullptr)
	{
		return 0;
	}

	FOnSoftObjectLoaded Delegate;
	Delegate.BindUFunction(Receiver, n"HandleMissingObject");

	TSoftObjectPtr<UTexture2D> MissingRef(FSoftObjectPath(MissingTexturePath));
	MissingRef.LoadAsync(Delegate);
	return Receiver.MissingObjectCallbackCount == 1 && Receiver.bMissingObjectPayloadWasNull ? 1 : 0;
}

int AsyncClassLoadedPathInvokesCallback(FString ActorClassPath)
{
	UCoverageSoftReferenceAsyncReceiver Receiver = Cast<UCoverageSoftReferenceAsyncReceiver>(
		NewObject(GetTransientPackage(), UCoverageSoftReferenceAsyncReceiver::StaticClass(), n"CoverageSoftReferenceClassReceiver", true));
	if (Receiver == nullptr)
	{
		return 0;
	}

	FOnSoftClassLoaded Delegate;
	Delegate.BindUFunction(Receiver, n"HandleClassLoaded");

	FSoftClassPath ClassPath(ActorClassPath);
	UClass LoadedClass = ClassPath.TryLoadClass();
	if (LoadedClass == nullptr)
	{
		return 0;
	}
	TSoftClassPtr<AActor> ActorClassRef(FSoftObjectPath(ActorClassPath));
	ActorClassRef.LoadAsync(Delegate);
	return Receiver.ClassCallbackCount == 1 && Receiver.bClassPayloadWasActorClass ? 1 : 0;
}

bool Observe_SoftAsyncReceiver_DefaultEmpty(UCoverageSoftReferenceAsyncReceiver Receiver)
{
	if (Receiver is null)
	{
		throw("Test_SoftReferenceAsyncBoundaries setup: required Receiver is null");
	}
	return Receiver.ObjectCallbackCount == 0
		&& Receiver.bObjectPayloadWasTexture == false
		&& Receiver.MissingObjectCallbackCount == 0
		&& Receiver.bMissingObjectPayloadWasNull == false
		&& Receiver.ClassCallbackCount == 0
		&& Receiver.bClassPayloadWasActorClass == false;
}

int Observe_AsyncObjectLoaded_Nominal(FString DefaultTexturePath)
{
	return AsyncObjectLoadedPathInvokesCallback(DefaultTexturePath);
}

int Observe_AsyncObjectMissing_NullBoundary(FString MissingTexturePath)
{
	return AsyncObjectMissingPathReportsNull(MissingTexturePath);
}
