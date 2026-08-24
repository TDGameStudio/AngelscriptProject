// Theme: Definitions.UProperty. WorldStory: spawned actor keeps UPROPERTY defaults.
// C++: VerifyByPath Health 100; DisplayName TestActor.
// Extra: empty sibling Health 0 / empty DisplayName is independent of the defaults. FixtureIsolated.

UCLASS()
class ATestActorUProperty : AActor
{
	UPROPERTY()
	int Health = 100;

	UPROPERTY()
	FString DisplayName = "TestActor";
}

UCLASS()
class ATestActorUPropertyEmpty : AActor
{
	UPROPERTY()
	int Health = 0;

	UPROPERTY()
	FString DisplayName;
}

int Observe_UProperty_EmptyHealthIndependent()
{
	int Health = 100;
	int EmptyHealth = 0;
	return EmptyHealth != Health ? EmptyHealth : -1;
}

bool Observe_UProperty_EmptyDisplayName()
{
	FString DisplayName;
	return DisplayName.Len() == 0;
}
