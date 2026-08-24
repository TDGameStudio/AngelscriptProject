// Theme: World.Component. WorldStory: component BeginPlay reads owning script actor.
// C++: AngelscriptComponentTests.cpp::ActorOwner
// spawn ATestComponentOwnerActor + attach UTestComponentActorOwner, BeginPlay, then
// VerifyByPath ReadOwnerValue=42. Keep OwnerValue and ReadOwnerValue.
// sha256=c5e80fc7ffebdeba38e27d9ba30b129a3bb1341c8ca2f975d6eb3ff64358f16d; lines 267-291.
// Extra: local construct leaves ReadOwnerValue 0 (null owner path); copy writes stay independent.
// FixtureIsolated. Runner owns World teardown.

UCLASS()
class ATestComponentOwnerActor : AActor
{
	UPROPERTY()
	int OwnerValue = 42;
}

UCLASS()
class UTestComponentActorOwner : UActorComponent
{
	UPROPERTY()
	int ReadOwnerValue = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		ATestComponentOwnerActor OwnerActor = Cast<ATestComponentOwnerActor>(GetOwner());
		if (OwnerActor != null)
		{
			ReadOwnerValue = OwnerActor.OwnerValue;
		}
	}
}

bool Observe_ActorOwner_DefaultReadZero(UTestComponentActorOwner Comp)
{
	if (Comp is null)
	{
		throw("Test_ActorOwner setup: required Comp is null");
	}
	return Comp.ReadOwnerValue == 0;
}

bool Observe_ActorOwner_CopyIndependence(UTestComponentActorOwner First, UTestComponentActorOwner Second)
{
	if (First is null)
	{
		throw("Test_ActorOwner setup: required First is null");
	}
	if (Second is null)
	{
		throw("Test_ActorOwner setup: required Second is null");
	}
	First.ReadOwnerValue = 42;
	return First.ReadOwnerValue == 42 && Second.ReadOwnerValue == 0;
}
