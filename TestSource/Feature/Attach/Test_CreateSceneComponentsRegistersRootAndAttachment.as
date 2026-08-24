// Theme: Feature.Attach. WorldStory: CreateComponent registers root then attaches the second scene component.
// C++: AngelscriptActorComponentManagementTests.cpp::CreateSceneComponentsRegistersRootAndAttachment.
// Oracle: CreateRuntimeComponents()==1; FirstCreated becomes root; SecondCreated attaches to FirstCreated.
// Failure codes: FirstCreated nullptr returns 10; SecondCreated nullptr returns 20.
// Extra: CDO FirstCreated/SecondCreated null; copy independence of null defaults.
// FixtureIsolated. Keep FirstCreated, SecondCreated.

UCLASS()
class ATestActorComponentManagementCreateScene : AActor
{
	UPROPERTY()
	USceneComponent FirstCreated;

	UPROPERTY()
	USceneComponent SecondCreated;

	UFUNCTION()
	int CreateRuntimeComponents()
	{
		FirstCreated = Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"RuntimeRoot"));
		if (FirstCreated == nullptr)
		{
			return 10;
		}

		SecondCreated = Cast<USceneComponent>(CreateComponent(USceneComponent::StaticClass(), n"RuntimeChild"));
		if (SecondCreated == nullptr)
		{
			return 20;
		}

		return 1;
	}
}

bool Observe_CreateScene_EmptyDefault(ATestActorComponentManagementCreateScene Actor)
{
	if (Actor is null)
	{
		throw("Test_CreateSceneComponentsRegistersRootAndAttachment setup: required Actor is null");
	}
	return Actor.FirstCreated == nullptr && Actor.SecondCreated == nullptr;
}

bool Observe_CreateScene_CopyIndependence(ATestActorComponentManagementCreateScene Original, ATestActorComponentManagementCreateScene Copy)
{
	if (Original is null)
	{
		throw("Test_CreateSceneComponentsRegistersRootAndAttachment setup: required Original is null");
	}
	if (Copy is null)
	{
		throw("Test_CreateSceneComponentsRegistersRootAndAttachment setup: required Copy is null");
	}
	return Original.FirstCreated == nullptr
		&& Original.SecondCreated == nullptr
		&& Copy.FirstCreated == nullptr
		&& Copy.SecondCreated == nullptr
		&& Original != Copy;
}
