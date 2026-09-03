/**
 * A default tick interval applied at instance construction. C++ spawns the actor
 * and verifies the interval. The sibling keeps the engine default interval, so the
 * two together separate "the default was applied" from "the engine default was
 * left alone".
 *
 * @Theme World.Actor
 * @Subject Actor.DefaultValues
 * @Harness UClass
 * @Tag World.Actor.DefaultValues
 * @Provenance Theme: World.Actor. WorldStory: default PrimaryActorTick.TickInterval = 0.5f.
 * @Provenance C++: AngelscriptActorPropertyInterfaceTests.cpp::DefaultValues
 * @Provenance Oracle: spawned actor TickInterval is 0.5.
 * @Provenance Extra: unreplicated sibling keeps the engine default interval (no 0.5 override).
 * @Provenance Do not spawn from script. FixtureIsolated.
 */

UCLASS()
class ATestActorDefaultValues : AActor
{
	default PrimaryActorTick.TickInterval = 0.5f;
}

/**
 * The sibling that keeps the engine default interval, which is the boundary C++
 * compares the overridden interval against.
 *
 * @Covers Actor.DefaultValues
 * @Inputs none
 * @Return an actor with no tick interval override
 * @Boundary engine default interval
 */
UCLASS()
class ATestActorDefaultValuesUnreplicated : AActor
{
	default PrimaryActorTick.TickInterval = 0.0f;
}
