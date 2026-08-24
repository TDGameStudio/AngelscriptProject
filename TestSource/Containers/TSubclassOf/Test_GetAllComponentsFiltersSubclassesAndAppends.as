// Theme: Containers.TSubclassOf. WorldStory: GetAllComponents filters subclasses and appends.
// C++: AngelscriptActorComponentManagementTests.cpp::GetAllComponentsFiltersSubclassesAndAppends
// CompileScriptModule + spawn + BeginPlay + CallAndReturn RunGetAllAppendTest == 1.
// Oracle: SceneA pre-seed plus GetAllComponents yields 3; OnlyB is SceneB; NoMesh stays empty.
// Extra: empty output array for a missing class is Num()==0 (return 30 path is the empty filter).
// FixtureIsolated. Runner owns World and DefaultComponents.

UCLASS()
class UTestActorComponentManagementSceneA : USceneComponent
{
}

UCLASS()
class UTestActorComponentManagementSceneB : USceneComponent
{
}

UCLASS()
class ATestActorComponentManagementGetAllAppend : AActor
{
	UPROPERTY(DefaultComponent, RootComponent)
	UTestActorComponentManagementSceneA SceneA;

	UPROPERTY(DefaultComponent, Attach = SceneA)
	UTestActorComponentManagementSceneB SceneB;

	UFUNCTION()
	int RunGetAllAppendTest()
	{
		TArray<UActorComponent> AllScenes;
		AllScenes.Add(SceneA);
		GetAllComponents(USceneComponent::StaticClass(), AllScenes);
		if (AllScenes.Num() != 3)
		{
			return 10;
		}

		TArray<UActorComponent> OnlyB;
		GetAllComponents(UTestActorComponentManagementSceneB::StaticClass(), OnlyB);
		if (OnlyB.Num() != 1 || OnlyB[0] != SceneB)
		{
			return 20;
		}

		TArray<UActorComponent> NoMesh;
		GetAllComponents(UStaticMeshComponent::StaticClass(), NoMesh);
		if (NoMesh.Num() != 0)
		{
			return 30;
		}

		return 1;
	}
}

int Observe_GetAllAppend_Nominal(ATestActorComponentManagementGetAllAppend Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-CONT-0120 setup: required actor is null");
	}
	return Actor.RunGetAllAppendTest();
}

int Observe_GetAllAppend_EmptyFilter(ATestActorComponentManagementGetAllAppend Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-CONT-0120 setup: required actor is null");
	}
	TArray<UActorComponent> NoMesh;
	Actor.GetAllComponents(UStaticMeshComponent::StaticClass(), NoMesh);
	return NoMesh.Num();
}

bool Observe_GetAllAppend_CopyIndependence(ATestActorComponentManagementGetAllAppend Actor)
{
	if (Actor == nullptr)
	{
		throw("TS-CONT-0120 setup: required actor is null");
	}
	TArray<UActorComponent> First;
	TArray<UActorComponent> Second;
	First.Add(Actor.SceneA);
	Actor.GetAllComponents(USceneComponent::StaticClass(), First);
	return First.Num() == 3 && Second.Num() == 0;
}
