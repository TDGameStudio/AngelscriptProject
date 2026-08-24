// Theme: HotReload VersionPair After. Reference parameter expansion.
// C++: AngelscriptHotReloadDelegateTests.cpp::InvokeReferenceSignatureAfterReload
// Retained: Texture validity bit, receiver, RunReferences, BindUFunction HandleReferences.
// Replaced: UClass TextureClass, TSubclassOf<AActor> ActorClass, TSoftObjectPtr SoftTexture, TSoftClassPtr SoftActorClass.
// Oracle: Execute live refs -> 63 (1|2|4|8|16|32). Extra: null Texture/class names "null". FixtureIsolated.

delegate int FHotReloadReferenceSignal(UTexture2D Texture, UClass TextureClass, TSubclassOf<AActor> ActorClass, TSoftObjectPtr<UTexture2D> SoftTexture, TSoftClassPtr<AActor> SoftActorClass);

UCLASS()
class UHotReloadReferenceReceiver : UObject
{
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
