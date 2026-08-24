// Theme: World.Actor. WorldStory: default PrimaryActorTick.TickInterval = 0.5f.
// C++: AngelscriptActorPropertyInterfaceTests.cpp::DefaultValues
// Oracle: spawned actor TickInterval is 0.5.
// Extra: unreplicated sibling keeps the engine default interval (no 0.5 override).
// Do not spawn from script. FixtureIsolated.

UCLASS()
class ATestActorDefaultValues : AActor
{
	default PrimaryActorTick.TickInterval = 0.5f;
}

UCLASS()
class ATestActorDefaultValuesUnreplicated : AActor
{
	default PrimaryActorTick.TickInterval = 0.0f;
}
