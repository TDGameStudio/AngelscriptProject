/**
 * @version v1
 * @summary Unbinding one handler from an event. Two handlers are bound and the event is broadcast twice with an Unbind between them, so the first broadcast reaches both handlers and the second reaches only the survivor.
 * @topic Language
 */
/**
 * @version root
 * @summary Unbinding one handler from an event. Two handlers are bound and the event is broadcast twice with an Unbind between them, so the first broadcast reaches both handlers and the second reaches only the survivor.
 * @topic Baseline
 */
/**
 * The event one handler is unbound from.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageUnbindEvent();

UCLASS()
class ACoverageEventUnbindingActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	FCoverageUnbindEvent OnEvent;

	/**
	 * Binds two handlers, broadcasts, unbinds one, and broadcasts again.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter accumulates the handler deltas
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnEvent.AddUFunction(this, n"Handler1");
		OnEvent.AddUFunction(this, n"Handler2");

		OnEvent.Broadcast();

		OnEvent.Unbind(this, n"Handler1");

		OnEvent.Broadcast();
	}

	/**
	 * The handler later unbound from the event.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 1
	 */
	UFUNCTION()
	void Handler1()
	{
		Counter += 1;
	}

	/**
	 * The handler that survives the unbind.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 10
	 */
	UFUNCTION()
	void Handler2()
	{
		Counter += 10;
	}

	/**
	 * Observe that a locally constructed actor has counted nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the counter is 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EventUnbindCounterDefaultsToZero()
	{
		return Counter == 0;
	}

	/**
	 * Observe the count after the bind, broadcast, unbind, broadcast sequence.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then the counter
	 * @Return true when the counter is 21
	 */
	UFUNCTION()
	bool EventUnbindLeavesSurvivingHandler()
	{
		BeginPlay();
		return Counter == 21;
	}
}
/** @end */
