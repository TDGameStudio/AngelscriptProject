/**
 * @version v1
 * @summary HotReload VersionPair Before. UTexture2D-only reference delegate.
 * @topic HotReload
 */
/**
 * @version root
 * @summary HotReload VersionPair Before. UTexture2D-only reference delegate.
 * @topic Baseline
 */
// Retained after reload: FHotReloadReferenceSignal name, UHotReloadReferenceReceiver, HandleReferences, RunReferences.
// Replaced in After: UClass, TSubclassOf, TSoftObjectPtr, TSoftClassPtr parameters.
// Oracle: valid texture -> 17; null texture would return 0. FixtureIsolated.

/** Delegate FHotReloadReferenceSignal: carries (UTexture2D Texture) for this reload scenario. */
delegate int FHotReloadReferenceSignal(UTexture2D Texture);

UCLASS()
class UHotReloadReferenceReceiver : UObject
{
	/** Handles the references callback. */
	UFUNCTION()
	int HandleReferences(UTexture2D Texture)
	{
		int Result = IsValid(Texture) ? 17 : 0;
		Log(n"HotReloadDelegateTests", "Reference V1 HandleReferences TextureValid=" + IsValid(Texture) + " Result=" + Result);
		return Result;
	}
}

/** Runs the references path and returns the observed result. */
int RunReferences(UHotReloadReferenceReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "Reference V1 RunReferences: creating texture");
	UTexture2D Texture = Cast<UTexture2D>(NewObject(GetTransientPackage(), UTexture2D::StaticClass()));

	FHotReloadReferenceSignal Signal;
	Signal.BindUFunction(Receiver, n"HandleReferences");
	int Result = Signal.Execute(Texture);
	Log(n"HotReloadDelegateTests", "Reference V1 RunReferences Result=" + Result);
	return Result;
}
/** @end */
/**
 * @version after
 * @parent root
 * @summary HotReload VersionPair After. Reference parameter expansion.
 * @topic HotReload
 */
/** Delegate FHotReloadReferenceSignal: carries (UTexture2D Texture, UClass TextureClass, TSubclassOf<AActor> ActorClass, TSoftObjectPtr<UTexture2D> SoftTexture, TSoftClassPtr<AActor> SoftActorClass) for this reload scenario. */
delegate int FHotReloadReferenceSignal(UTexture2D Texture, UClass TextureClass, TSubclassOf<AActor> ActorClass, TSoftObjectPtr<UTexture2D> SoftTexture, TSoftClassPtr<AActor> SoftActorClass);

UCLASS()
class UHotReloadReferenceReceiver : UObject
{
	/** Handles the references callback. */
	UFUNCTION()
	int HandleReferences(UTexture2D Texture, UClass TextureClass, TSubclassOf<AActor> ActorClass, TSoftObjectPtr<UTexture2D> SoftTexture, TSoftClassPtr<AActor> SoftActorClass)
	{
		TSubclassOf<AActor> ResolvedSoftActorClass = SoftActorClass.Get();
		FString TextureClassName = TextureClass != null ? TextureClass.GetName().ToString() : "null";
		FString ActorClassName = ActorClass.Get() != null ? ActorClass.Get().GetName().ToString() : "null";
		FString SoftActorClassName = ResolvedSoftActorClass.Get() != null ? ResolvedSoftActorClass.Get().GetName().ToString() : "null";
		Log(n"HotReloadDelegateTests", "Reference V2 HandleReferences TextureValid=" + IsValid(Texture) + " TextureClass=" + TextureClassName + " ActorClass=" + ActorClassName + " SoftTextureValid=" + IsValid(SoftTexture.Get()) + " SoftActorClass=" + SoftActorClassName);
		int Result = 0;

		if (IsValid(Texture))
		{
			Result += 1;
		}

		if (TextureClass == UTexture2D::StaticClass())
		{
			Result += 2;
		}

		if (ActorClass == ACameraActor::StaticClass())
		{
			Result += 4;
		}

		AActor DefaultActor = ActorClass.GetDefaultObject();
		if (IsValid(DefaultActor) && DefaultActor.IsA(ACameraActor::StaticClass()))
		{
			Result += 8;
		}

		if (SoftTexture == Texture && SoftTexture.Get() == Texture)
		{
			Result += 16;
		}

		if (SoftActorClass.Get() == AActor::StaticClass())
		{
			Result += 32;
		}

		Log(n"HotReloadDelegateTests", "Reference V2 HandleReferences Result=" + Result);
		return Result;
	}
}

/** Runs the references path and returns the observed result. */
int RunReferences(UHotReloadReferenceReceiver Receiver)
{
	Log(n"HotReloadDelegateTests", "Reference V2 RunReferences: creating reference parameters");
	UTexture2D Texture = Cast<UTexture2D>(NewObject(GetTransientPackage(), UTexture2D::StaticClass()));
	TSubclassOf<AActor> ActorClass = ACameraActor::StaticClass();
	TSoftObjectPtr<UTexture2D> SoftTexture(Texture);
	TSoftClassPtr<AActor> SoftActorClass(AActor::StaticClass());

	FHotReloadReferenceSignal Signal;
	Signal.BindUFunction(Receiver, n"HandleReferences");
	int Result = Signal.Execute(Texture, UTexture2D::StaticClass(), ActorClass, SoftTexture, SoftActorClass);
	Log(n"HotReloadDelegateTests", "Reference V2 RunReferences Result=" + Result);
	return Result;
}
/** @end */
