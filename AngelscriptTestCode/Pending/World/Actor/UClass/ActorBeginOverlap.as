/**
 * @version v1
 * @summary The ActorBeginOverlap BlueprintOverride recording how many times it fired and the actor that last overlapped. C++ drives the overlap and verifies both by path. ATestOverlapTrigger is the empty sibling that C++ also.
 * @topic World
 */
/**
 * @version root
 * @summary The ActorBeginOverlap BlueprintOverride recording how many times it fired and the actor that last overlapped. C++ drives the overlap and verifies both by path. ATestOverlapTrigger is the empty sibling that C++ also.
 * @topic Baseline
 */
UCLASS()
class ATestOverlapReceiver : AActor
{
	UPROPERTY()
	int EventCallCount = 0;

	UPROPERTY()
	AActor LastActorRef = nullptr;

	/**
	 * WorldStory: the begin overlap override records the other actor and counts the
	 * call.
	 *
	 * @Kind WorldStory
	 * @Covers Actor.BeginOverlap
	 * @Inputs the actor that began overlapping
	 * @Return EventCallCount incremented and LastActorRef set to the trigger
	 * @Param OtherActor the actor that began overlapping
	 */
	UFUNCTION(BlueprintOverride)
	void ActorBeginOverlap(AActor OtherActor)
	{
		LastActorRef = OtherActor;
		EventCallCount += 1;
	}

	/**
	 * Observe that a locally constructed receiver has not fired.
	 *
	 * @Kind Observe
	 * @Covers Actor.BeginOverlap
	 * @Inputs a receiver that has not overlapped anything
	 * @Return true when the count is 0 and the last actor is null
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool DefaultEmpty()
	{
		if (EventCallCount != 0)
		{
			return false;
		}
		return LastActorRef == nullptr;
	}
}

/**
 * The empty trigger actor that C++ compiles alongside the receiver.
 *
 * @Covers Actor.BeginOverlap
 * @Inputs none
 * @Return a declared but empty actor used as the overlap trigger
 */
UCLASS()
class ATestOverlapTrigger : AActor
{
}
/** @end */
