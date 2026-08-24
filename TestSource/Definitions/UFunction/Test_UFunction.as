// Theme: Definitions.UFunction. WorldStory: script UFUNCTION reads script UPROPERTY.
// C++: AngelscriptActorPropertyInterfaceTests.cpp::UFunction
// Spawn ATestActorUFunction, invoke GetHealth. Oracle: Result == 100 (Health default).
// Extra: Health 0 is the false/zero boundary; a second instance stays at 100.
// FixtureIsolated. Keep Health. Runner owns spawn.

UCLASS()
class ATestActorUFunction : AActor
{
	UPROPERTY()
	int Health = 100;

	UFUNCTION()
	int GetHealth()
	{
		return Health;
	}
}

int Observe_GetHealth_Nominal(ATestActorUFunction Actor)
{
	return Actor.GetHealth();
}

int Observe_GetHealth_PropertyDefault(ATestActorUFunction Actor)
{
	return Actor.Health;
}

int Observe_GetHealth_ZeroBoundary(ATestActorUFunction Actor)
{
	Actor.Health = 0;
	return Actor.GetHealth();
}

bool Observe_GetHealth_SecondInstanceIndependent(
	ATestActorUFunction First,
	ATestActorUFunction Second)
{
	First.Health = 0;
	return First.GetHealth() == 0 && Second.GetHealth() == 100 && Second.Health == 100;
}
