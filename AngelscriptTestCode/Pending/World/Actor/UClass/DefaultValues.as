/**
 * @version v1
 * @summary A default tick interval applied at instance construction. C++ spawns the actor and verifies the interval. The sibling keeps the engine default interval, so the two together separate "the default was applied" from "the.
 * @topic World
 */
/**
 * @version root
 * @summary A default tick interval applied at instance construction. C++ spawns the actor and verifies the interval. The sibling keeps the engine default interval, so the two together separate "the default was applied" from "the.
 * @topic Baseline
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
/** @end */
