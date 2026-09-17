/**
 * @version v1
 * @summary AActor and UENUM delegate returns. After BeginPlay, ReturnedActor is self, bReturnedSelf is true, and ReturnedRoute is Matched.
 * @topic Feature
 */
/**
 * @version root
 * @summary AActor and UENUM delegate returns. After BeginPlay, ReturnedActor is self, bReturnedSelf is true, and ReturnedRoute is Matched.
 * @topic Baseline
 */
UENUM()
enum ECoverageDelegateObjectRoute
{
	Missing,
	Matched,
	Fallback
}

/**
 * A unicast that returns an AActor.
 *
 * @Covers Delegates.Execute
 * @Inputs none
 * @Return an AActor from the bound handler
 */
delegate AActor FDelegateActorReturn();

/**
 * A unicast that classifies an actor as a route enum.
 *
 * @Covers Delegates.Execute
 * @Inputs ActorValue
 * @Return ECoverageDelegateObjectRoute
 */
delegate ECoverageDelegateObjectRoute FDelegateEnumReturn(AActor ActorValue);

UCLASS()
class ACoverageDelegateObjectEnumReturnActor : AActor
{
	UPROPERTY()
	AActor ReturnedActor;

	UPROPERTY()
	ECoverageDelegateObjectRoute ReturnedRoute = ECoverageDelegateObjectRoute::Missing;

	UPROPERTY()
	bool bReturnedSelf = false;

	/**
	 * Binds ReturnSelfActor and ClassifyActor, then executes both.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return nothing; ReturnedActor is self and ReturnedRoute is Matched
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FDelegateActorReturn ActorReturn;
		ActorReturn.BindUFunction(this, n"ReturnSelfActor");
		ReturnedActor = ActorReturn.Execute();
		bReturnedSelf = ReturnedActor == this;

		FDelegateEnumReturn EnumReturn;
		EnumReturn.BindUFunction(this, n"ClassifyActor");
		ReturnedRoute = EnumReturn.Execute(ReturnedActor);
	}

	/**
	 * Returns this actor.
	 *
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return this
	 */
	UFUNCTION()
	AActor ReturnSelfActor()
	{
		return this;
	}

	/**
	 * Classifies ActorValue as Matched when it is this, else Fallback.
	 *
	 * @Covers Delegates.Execute
	 * @Param ActorValue the actor to classify
	 * @Inputs ActorValue
	 * @Return Matched or Fallback
	 */
	UFUNCTION()
	ECoverageDelegateObjectRoute ClassifyActor(AActor ActorValue)
	{
		if (ActorValue == this)
		{
			return ECoverageDelegateObjectRoute::Matched;
		}

		return ECoverageDelegateObjectRoute::Fallback;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a local ACoverageDelegateObjectEnumReturnActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDelegateObjectEnumReturnActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe that ReturnedActor starts null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs this
	 * @Return true when ReturnedActor is null
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool ReturnedActorDefaultNull()
	{
		return ReturnedActor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay bReturnedSelf flag.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs this
	 * @Return bReturnedSelf
	 * @Boundary pre-BeginPlay
	 */
	UFUNCTION()
	bool ReturnedSelfDefault()
	{
		return bReturnedSelf;
	}
}
/** @end */
