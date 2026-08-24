// Theme: Containers.TSoftObjectPtr. WorldStory: TSoftObjectPtr.LoadAsync callback.
// C++: AngelscriptCoverageSoftReferenceTests.cpp::SoftObjectPtrAsyncLoad
// CompileScriptModule + spawn + BeginPlay. Oracle: AsyncCallbackCount=1,
// AsyncLoadPreservedResourcePath true, AsyncLoadReturnedTexture true.
// Extra: local construct leaves count 0 and flags false.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageSoftRefAsyncLoadActor : AActor
{
	UPROPERTY()
	int AsyncCallbackCount = 0;

	UPROPERTY()
	bool AsyncLoadReturnedTexture = false;

	UPROPERTY()
	bool AsyncLoadPreservedResourcePath = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FOnSoftObjectLoaded Delegate;
		Delegate.BindUFunction(this, n"HandleTextureLoaded");

		FSoftObjectPath TexturePath("/Engine/EngineResources/DefaultTexture.DefaultTexture");
		TexturePath.TryLoad();

		TSoftObjectPtr<UTexture2D> TextureRef(TexturePath);
		AsyncLoadPreservedResourcePath = TextureRef.ToString().Contains("DefaultTexture");
		TextureRef.LoadAsync(Delegate);
	}

	UFUNCTION()
	void HandleTextureLoaded(UObject LoadedObject)
	{
		AsyncCallbackCount += 1;
		AsyncLoadReturnedTexture = Cast<UTexture2D>(LoadedObject) != nullptr;
	}
}

bool Observe_SoftAsyncLoad_DefaultEmpty(ACoverageSoftRefAsyncLoadActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftObjectPtrAsyncLoad setup: required Actor is null");
	}
	return Actor.AsyncCallbackCount == 0
		&& Actor.AsyncLoadReturnedTexture == false
		&& Actor.AsyncLoadPreservedResourcePath == false;
}

bool Observe_SoftAsyncLoad_CopyIndependence(ACoverageSoftRefAsyncLoadActor First, ACoverageSoftRefAsyncLoadActor Second)
{
	if (First is null)
	{
		throw("Test_SoftObjectPtrAsyncLoad setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_SoftObjectPtrAsyncLoad setup: required Second is null");
	}
	First.HandleTextureLoaded(nullptr);
	return First.AsyncCallbackCount == 1
		&& First.AsyncLoadReturnedTexture == false
		&& Second.AsyncCallbackCount == 0;
}

bool Observe_SoftAsyncLoad_NullPayloadBoundary(ACoverageSoftRefAsyncLoadActor Actor)
{
	if (Actor is null)
	{
		throw("Test_SoftObjectPtrAsyncLoad setup: required Actor is null");
	}
	Actor.HandleTextureLoaded(nullptr);
	return Actor.AsyncCallbackCount == 1 && Actor.AsyncLoadReturnedTexture == false;
}
