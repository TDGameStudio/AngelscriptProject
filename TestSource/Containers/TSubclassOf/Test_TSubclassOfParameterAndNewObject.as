// Theme: Containers.TSubclassOf. WorldStory: TSubclassOf parameter plus NewObject class args.
// C++: AngelscriptCoverageHandleTests.cpp::TSubclassOfParameterAndNewObject
// CompileScriptModule + spawn + BeginPlay. Oracle: ParameterAcceptedClass,
// NewObjectFromClassWorked, NewObjectFromTSubclassOfWorked true.
// Extra: local construct leaves flags false; AcceptActorClass(nullptr) stays false.
// FixtureIsolated. Runner owns NewObject instances.

UCLASS()
class ACoverageHandleSubclassParameterActor : AActor
{
	UPROPERTY()
	bool ParameterAcceptedClass = false;

	UPROPERTY()
	bool NewObjectFromClassWorked = false;

	UPROPERTY()
	bool NewObjectFromTSubclassOfWorked = false;

	void AcceptActorClass(TSubclassOf<AActor> InClass)
	{
		ParameterAcceptedClass = InClass != nullptr && InClass.IsChildOf(AActor::StaticClass());
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		TSubclassOf<AActor> ActorClass = AActor::StaticClass();
		AcceptActorClass(ActorClass);

		TSubclassOf<UObject> TextureClass = UTexture2D::StaticClass();
		UObject FromClass = NewObject(GetTransientPackage(), TextureClass.Get(), n"CoverageSubclassNewObjectClass");
		NewObjectFromClassWorked = FromClass != nullptr && FromClass.IsA(UTexture2D::StaticClass());

		UObject FromSubclassOf = NewObject(GetTransientPackage(), TextureClass, n"CoverageSubclassNewObjectSubclass");
		NewObjectFromTSubclassOfWorked = FromSubclassOf != nullptr && FromSubclassOf.IsA(UTexture2D::StaticClass());
	}
}

bool Observe_SubclassParamNewObject_DefaultEmpty(ACoverageHandleSubclassParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSubclassOfParameterAndNewObject setup: required Actor is null");
	}
	return Actor.ParameterAcceptedClass == false
		&& Actor.NewObjectFromClassWorked == false
		&& Actor.NewObjectFromTSubclassOfWorked == false;
}

bool Observe_SubclassParamNewObject_NullBoundary(ACoverageHandleSubclassParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSubclassOfParameterAndNewObject setup: required Actor is null");
	}
	Actor.AcceptActorClass(nullptr);
	return Actor.ParameterAcceptedClass == false;
}

bool Observe_SubclassParamNewObject_Nominal(ACoverageHandleSubclassParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSubclassOfParameterAndNewObject setup: required Actor is null");
	}
	Actor.AcceptActorClass(AActor::StaticClass());
	return Actor.ParameterAcceptedClass == true;
}
