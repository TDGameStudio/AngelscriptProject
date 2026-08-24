// Theme: Definitions.Meta. WorldStory: DisplayName meta on mixed property types.
// C++: AngelscriptCoverageMetaSpecifierTests.cpp::DisplayNameMeta
// Oracle defaults: HP 100, Speed 5.0, PlayerName "John", bActive true.
// Extra: HP 0 / empty name / bActive false. FixtureIsolated.

UCLASS()
class ACoverageMetaDisplayNameActor : AActor
{
	UPROPERTY(meta = (DisplayName = "Health Points"))
	int HP = 100;

	UPROPERTY(meta = (DisplayName = "Movement Speed (m/s)"))
	float Speed = 5.0f;

	UPROPERTY(meta = (DisplayName = "Player Name"))
	FString PlayerName = "John";

	UPROPERTY(meta = (DisplayName = "Is Active?"))
	bool bActive = true;
}

int Observe_DisplayName_HPDefault(ACoverageMetaDisplayNameActor Actor)
{
	return Actor.HP;
}

float Observe_DisplayName_SpeedDefault(ACoverageMetaDisplayNameActor Actor)
{
	return Actor.Speed;
}

FString Observe_DisplayName_PlayerNameDefault(ACoverageMetaDisplayNameActor Actor)
{
	return Actor.PlayerName;
}

bool Observe_DisplayName_ActiveDefault(ACoverageMetaDisplayNameActor Actor)
{
	return Actor.bActive;
}

int Observe_DisplayName_ZeroHPBoundary(ACoverageMetaDisplayNameActor Actor)
{
	Actor.HP = 0;
	return Actor.HP;
}

bool Observe_DisplayName_EmptyNameAndInactive(ACoverageMetaDisplayNameActor Actor)
{
	Actor.PlayerName = "";
	Actor.bActive = false;
	return Actor.PlayerName.Len() == 0 && !Actor.bActive;
}
