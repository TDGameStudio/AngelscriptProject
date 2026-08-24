// Theme: Containers.TSubclassOf. WorldStory: TSubclassOf UPROPERTY specifiers.
// C++: AngelscriptCoverageWeakReferenceTests.cpp::TSubclassOfAsProperty
// CompileScriptModule + spawn + BeginPlay. Oracle: PropertiesSet true; EditDefaultsOnly and
// BlueprintReadWrite reflected flags.
// Extra: local construct leaves PropertiesSet false and class refs null.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ACoverageSubclassOfPropertyActor : AActor
{
	UPROPERTY(EditDefaultsOnly)
	TSubclassOf<AActor> ActorClass;

	UPROPERTY(EditAnywhere, BlueprintReadWrite)
	TSubclassOf<APawn> PawnClass;

	UPROPERTY(Category="Classes")
	TSubclassOf<AActor> CategoryClass;

	UPROPERTY()
	bool PropertiesSet = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ActorClass = AActor::StaticClass();
		PawnClass = APawn::StaticClass();
		CategoryClass = AActor::StaticClass();

		if (ActorClass != nullptr && PawnClass != nullptr && CategoryClass != nullptr)
		{
			PropertiesSet = true;
		}
	}
}

bool Observe_SubclassOfProperty_DefaultEmpty(ACoverageSubclassOfPropertyActor Actor)
{
	if (Actor is null)
	{
		throw("Test_TSubclassOfAsProperty setup: required Actor is null");
	}
	return Actor.PropertiesSet == false
		&& Actor.ActorClass == nullptr
		&& Actor.PawnClass == nullptr
		&& Actor.CategoryClass == nullptr;
}

bool Observe_SubclassOfProperty_CopyIndependence(ACoverageSubclassOfPropertyActor First, ACoverageSubclassOfPropertyActor Second)
{
	if (First is null)
	{
		throw("Test_TSubclassOfAsProperty setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_TSubclassOfAsProperty setup: required Second is null");
	}
	First.ActorClass = AActor::StaticClass();
	return First.ActorClass != nullptr && Second.ActorClass == nullptr;
}
