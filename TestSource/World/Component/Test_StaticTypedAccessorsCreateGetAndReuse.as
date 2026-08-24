// Theme: World.Component. WorldStory: typed Create / Get / GetOrCreate reuse.
// C++: AngelscriptActorComponentManagementTests.cpp::StaticTypedAccessorsCreateGetAndReuse
// sha256=514d79768127804f5013ccf872fbd51fdefe96d1f75073f8eaf3b6ec04d84646; lines 168-204.
// Oracle RunTypedAccessorTest returns 1; Created/Found/Reused same object.
// Extra: local construct Created/Found/Reused null. FixtureIsolated.

UCLASS()
class UTestActorComponentManagementTypedScene : USceneComponent
{
}

UCLASS()
class ATestActorComponentManagementTypedAccessors : AActor
{
	UPROPERTY()
	UTestActorComponentManagementTypedScene Created;

	UPROPERTY()
	UTestActorComponentManagementTypedScene Found;

	UPROPERTY()
	UTestActorComponentManagementTypedScene Reused;

	UFUNCTION()
	int RunTypedAccessorTest()
	{
		Created = UTestActorComponentManagementTypedScene::Create(this, n"TypedScene");
		if (Created == nullptr)
		{
			return 10;
		}

		Found = UTestActorComponentManagementTypedScene::Get(this, n"TypedScene");
		if (Found == nullptr || Found != Created)
		{
			return 20;
		}

		Reused = UTestActorComponentManagementTypedScene::GetOrCreate(this, n"TypedScene");
		if (Reused == nullptr || Reused != Created)
		{
			return 30;
		}

		return 1;
	}
}

bool Observe_TypedAccessors_DefaultNull(ATestActorComponentManagementTypedAccessors Actor)
{
	if (Actor is null)
	{
		throw("Test_StaticTypedAccessorsCreateGetAndReuse setup: required Actor is null");
	}
	return Actor.Created == nullptr
		&& Actor.Found == nullptr
		&& Actor.Reused == nullptr;
}

bool Observe_TypedAccessors_CopyIndependence(ATestActorComponentManagementTypedAccessors First, ATestActorComponentManagementTypedAccessors Second)
{
	if (First is null)
	{
		throw("Test_StaticTypedAccessorsCreateGetAndReuse setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_StaticTypedAccessorsCreateGetAndReuse setup: required Second is null");
	}
	First.Created = First.Found;
	return First.Created == nullptr
		&& Second.Created == nullptr
		&& Second.Found == nullptr
		&& Second.Reused == nullptr;
}
