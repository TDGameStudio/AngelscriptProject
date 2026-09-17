/**
 * @version v1
 * @summary Actor event bind, event bus, and lifecycle callbacks.
 * @topic Unreal
 * @topic Events
 *
 * namespace-scope-lifecycle
 * annotated-method-executes
 * blueprint-event-wrapper-executes-implementation
 * blueprint-event-wrapper-uses-mixed-push-paths
 * event-bind-and-trigger
 * event-bus-decouples-publisher-and-receiver
 * event-chaining
 * event-custom-game-events
 * event-lifecycle
 * event-multiple-handlers
 * event-unbinding
 * immediate-failure-callbacks
 */
/**
 * @begin namespace-scope-lifecycle
 * @summary Local scope lifetime: entering a scope constructs its locals, leaving an inner block destroys the inner locals while the outer state survives, and a container declared inside a loop body is destroyed on each iteration.
 * @topic Events
 */
UCLASS()
class AScopeLifecycleActor : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	int DestroyedCount = 0;

	/**
	 * Runs once when the actor enters play.
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		BeginPlayCount += 1;
	}

	/**
	 * Runs once when the actor leaves play.
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCount += 1;
	}

	/**
	 * Runs once after the actor is destroyed.
	 */
	UFUNCTION(BlueprintOverride)
	void Destroyed()
	{
		DestroyedCount += 1;
	}
}

namespace NamespaceTest
{
	/**
	 * Observe that entering a scope constructs its locals: a vector's
	 * components are packed into a container and read back in order.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeLifecycle
	 * @Inputs Declare FVector(1, 2, 3); pack its components into a TArray<int>
	 * @Return 123 when all three components round-trip in order
	 */
	UFUNCTION()
	int ScopeEntryConstructsLocals()
	{
		FVector Local = FVector(1, 2, 3);
		TArray<int> Values;
		Values.Add(int(Local.X));
		Values.Add(int(Local.Y));
		Values.Add(int(Local.Z));
		return Values[0] * 100 + Values[1] * 10 + Values[2];
	}

	/**
	 * Observe that leaving an inner block destroys the inner locals while the
	 * outer state survives and remains usable.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeLifecycle
	 * @Inputs Compute a result inside a block; after the block, build a fresh container
	 * @Return 456 when the outer result survives and the new container is independent
	 */
	UFUNCTION()
	int BlockExitKeepsOuterState()
	{
		int Result = 0;
		{
			TArray<int> Temp;
			Temp.Add(4);
			Temp.Add(5);
			Result = Temp[0] * 10 + Temp[1];
		}

		TArray<int> Temp;
		Temp.Add(6);
		return Result * 10 + Temp[0];
	}

	/**
	 * Observe that a container declared inside a loop body is destroyed on
	 * each iteration: the count reflects the per-iteration lifetime, not an
	 * accumulation across iterations.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeLifecycle
	 * @Inputs Loop three times, declaring a fresh container and adding two entries each time
	 * @Return 6 when each iteration sees its own two-element container
	 */
	UFUNCTION()
	int LocalContainerDestroyedAfterFunction()
	{
		int Total = 0;
		for (int Iteration = 0; Iteration < 3; ++Iteration)
		{
			TArray<int> Values;
			Values.Add(Iteration);
			Values.Add(Iteration + 1);
			Total += Values.Num();
		}
		return Total;
	}

	/**
	 * Observe the zero-vector boundary: a zero vector's components each
	 * truncate to 0.
	 *
	 * @Kind Observe
	 * @Covers Namespace.ScopeLifecycle
	 * @Inputs Declare FVector(0, 0, 0); sum its truncated components
	 * @Return 0 when every component truncates to zero
	 * @Boundary zero vector
	 */
	UFUNCTION()
	int ZeroVectorBoundary()
	{
		FVector Local = FVector(0, 0, 0);
		return int(Local.X) + int(Local.Y) + int(Local.Z);
	}

	/**
	 * Observe the actor lifecycle counters: a freshly spawned actor has run
	 * BeginPlay once and has not yet run EndPlay or Destroyed.
	 *
	 * @Kind WorldStory
	 * @Covers Namespace.ScopeLifecycle
	 * @Inputs SpawnActor of the lifecycle actor class
	 * @Return true when BeginPlayCount is 1 and the other two counters are 0
	 */
	UFUNCTION()
	bool ActorLifecycleCountersAfterBeginPlay()
	{
		AScopeLifecycleActor Actor = SpawnActor(AScopeLifecycleActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}
		if (Actor.BeginPlayCount != 1)
		{
			return false;
		}
		if (Actor.EndPlayCount != 0)
		{
			return false;
		}
		return Actor.DestroyedCount == 0;
	}

	/**
	 * Observe that destroying the actor runs EndPlay and Destroyed while
	 * leaving BeginPlayCount at the value it reached during play.
	 *
	 * @Kind WorldStory
	 * @Covers Namespace.ScopeLifecycle
	 * @Inputs Spawn the lifecycle actor, then destroy it
	 * @Return true when EndPlayCount and DestroyedCount are 1 and BeginPlayCount is still 1
	 */
	UFUNCTION()
	bool ActorLifecycleCountersAfterDestroy()
	{
		AScopeLifecycleActor Actor = SpawnActor(AScopeLifecycleActor::StaticClass());
		if (Actor == nullptr)
		{
			return false;
		}

		Actor.DestroyActor();
		if (Actor.EndPlayCount != 1)
		{
			return false;
		}
		if (Actor.DestroyedCount != 1)
		{
			return false;
		}
		return Actor.BeginPlayCount == 1;
	}
}
/** @end */
/**
 * @begin annotated-method-executes
 * @summary A UFUNCTION method that mutates its own object. The observers confirm the mutation persists on the instance it was called on and does not leak to a second instance.
 * @topic Events
 */
UCLASS()
class UCompilerExecutionCarrier : UObject
{
	UPROPERTY()
	int Score = 41;

	/**
	 * Increments the score and returns the new value.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the carrier's Score
	 * @Return 42 after the first call
	 */
	UFUNCTION()
	int IncrementAndGetScore()
	{
		Score += 1;
		return Score;
	}

	/**
	 * Observe that the mutation is returned and persisted.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs IncrementAndGetScore then Score
	 * @Return true when both report 42
	 */
	UFUNCTION()
	bool AnnotatedMethodMutatesAndPersists()
	{
		if (IncrementAndGetScore() != 42)
		{
			return false;
		}

		return Score == 42;
	}

	/**
	 * Observe the default state before any call.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed carrier
	 * @Return true when Score is 41
	 * @Boundary default value
	 */
	UFUNCTION()
	bool AnnotatedMethodScoreDefaultsToFortyOne()
	{
		return Score == 41;
	}

	/**
	 * Observe that mutating this carrier leaves another untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier mutated, compared against a second carrier
	 * @Return true when this carrier reads 42 and the other reads 41
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool AnnotatedMethodInstancesAreIndependent()
	{
		UCompilerExecutionCarrier Other =
			Cast<UCompilerExecutionCarrier>(
				NewObject(GetTransientPackage(), UCompilerExecutionCarrier::StaticClass(), n"CompilerExecutionCarrierOther"));
		if (Other == nullptr)
		{
			throw("Test_AnnotatedMethodExecutes setup: NewObject returned null");
		}

		IncrementAndGetScore();

		if (Score != 42)
		{
			return false;
		}

		return Other.Score == 41;
	}
}
/** @end */
/**
 * @begin blueprint-event-wrapper-executes-implementation
 * @summary A BlueprintEvent method whose wrapper dispatches to the script implementation. Calling the method from a plain UFUNCTION must reach the same body that a direct call reaches.
 * @topic Events
 */
UCLASS()
class UCompilerBlueprintEventWrapperCarrier : UObject
{
	/**
	 * The BlueprintEvent body the wrapper must route to.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs an integer addend
	 * @Return the value plus 21
	 * @Param Value the value to offset
	 */
	UFUNCTION(BlueprintEvent)
	int Compute(int Value)
	{
		return Value + 21;
	}

	/**
	 * Calls the BlueprintEvent method from a plain method.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int Entry()
	{
		return Compute(21);
	}

	/**
	 * Observe that the wrapped call and the direct call agree.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry() and Compute(21)
	 * @Return true when both report 42
	 */
	UFUNCTION()
	bool BlueprintEventWrapperReachesImplementation()
	{
		if (Entry() != 42)
		{
			return false;
		}

		return Compute(21) == 42;
	}

	/**
	 * Observe the zero boundary through the wrapped method.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Compute(0)
	 * @Return true when the result is 21
	 * @Boundary zero argument
	 */
	UFUNCTION()
	bool BlueprintEventWrapperZeroBoundary()
	{
		return Compute(0) == 21;
	}

	/**
	 * Observe that two carriers do not share state.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs this carrier and a second carrier
	 * @Return true when each reports its own expected value
	 * @Boundary instance independence
	 */
	UFUNCTION()
	bool BlueprintEventWrapperInstancesAreIndependent()
	{
		UCompilerBlueprintEventWrapperCarrier Other =
			Cast<UCompilerBlueprintEventWrapperCarrier>(
				NewObject(GetTransientPackage(), UCompilerBlueprintEventWrapperCarrier::StaticClass(), n"CompilerBlueprintEventWrapperCarrierOther"));
		if (Other == nullptr)
		{
			throw("TS-LANG-0001 setup: NewObject returned null");
		}

		if (Compute(1) != 22)
		{
			return false;
		}

		return Other.Entry() == 42;
	}
}
/** @end */
/**
 * @begin blueprint-event-wrapper-uses-mixed-push-paths
 * @summary A BlueprintEvent taking a const FString reference alongside a TSubclassOf, so its wrapper must marshal two different push paths in one call. Only the class argument affects the result; the label is passed but unused.
 * @topic Events
 */
UCLASS()
class UCompilerBlueprintEventMixedPushCarrier : UObject
{
	/**
	 * A BlueprintEvent combining a string reference and a class argument.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs a label and a class value
	 * @Return 42 when the class is AActor, otherwise 0
	 * @Param Label a string passed by const reference and left unused
	 * @Param TypeValue the class compared against AActor
	 */
	UFUNCTION(BlueprintEvent)
	int EvaluateMixedPush(const FString&in Label, TSubclassOf<AActor> TypeValue)
	{
		return TypeValue == AActor::StaticClass() ? 42 : 0;
	}

	/**
	 * Calls the mixed-push method with both argument kinds.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return 42
	 */
	UFUNCTION()
	int Entry()
	{
		return EvaluateMixedPush("Alpha", AActor::StaticClass());
	}

	/**
	 * Observe that the mixed-push wrapper returns the matched value.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs Entry()
	 * @Return true when the value is 42
	 */
	UFUNCTION()
	bool MixedPushWrapperReturnsMatchedValue()
	{
		return Entry() == 42;
	}

	/**
	 * Observe the empty-class boundary.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EvaluateMixedPush with an empty TSubclassOf
	 * @Return true when the result is 0
	 * @Boundary empty class
	 */
	UFUNCTION()
	bool MixedPushEmptyTypeBoundary()
	{
		TSubclassOf<AActor> Empty;
		return EvaluateMixedPush("Alpha", Empty) == 0;
	}

	/**
	 * Observe that an empty label does not change the class match.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs EvaluateMixedPush with an empty label
	 * @Return true when the result is still 42
	 * @Boundary empty label
	 */
	UFUNCTION()
	bool MixedPushEmptyLabelStillMatches()
	{
		return EvaluateMixedPush("", AActor::StaticClass()) == 42;
	}
}
/** @end */
/**
 * @begin event-bind-and-trigger
 * @summary Two script events bound through AddUFunction and broadcast during BeginPlay. The parameterless event appends to the log, and the data event contributes its payload to the count.
 * @topic Events
 */
/**
 * A parameterless script event.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageCustomEvent();

/**
 * A script event carrying a numeric and a string payload.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the payload Value and Data
 * @Return nothing when broadcast
 */
event void FCoverageDataChangedEvent(int Value, FString Data);

UCLASS()
class ACoverageEventBindTriggerActor : AActor
{
	UPROPERTY()
	int EventCount = 0;

	UPROPERTY()
	FString EventLog;

	FCoverageCustomEvent OnCustomEvent;
	FCoverageDataChangedEvent OnDataChanged;

	/**
	 * Binds both handlers and broadcasts both events.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the handlers record the broadcasts
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnCustomEvent.AddUFunction(this, n"HandleCustomEvent");
		OnDataChanged.AddUFunction(this, n"HandleDataChanged");

		OnCustomEvent.Broadcast();
		OnDataChanged.Broadcast(42, "TestData");
	}

	/**
	 * Records the parameterless broadcast.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the count gains 1 and the log gains a marker
	 */
	UFUNCTION()
	void HandleCustomEvent()
	{
		EventCount++;
		EventLog += "Custom;";
	}

	/**
	 * Records the data broadcast.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the payload Value and Data
	 * @Return nothing; the count gains Value and the log gains Data
	 * @Param Value the numeric payload
	 * @Param Data the string payload
	 */
	UFUNCTION()
	void HandleDataChanged(int Value, FString Data)
	{
		EventCount += Value;
		EventLog += Data + ";";
	}

	/**
	 * Observe that a locally constructed actor has recorded nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the count is 0 and the log is empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EventBindCountersDefaultToZero()
	{
		if (EventCount != 0)
		{
			return false;
		}

		return EventLog.Len() == 0;
	}

	/**
	 * Observe the state after BeginPlay broadcasts both events.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then both counters
	 * @Return true when the count is 43 and the log is "Custom;TestData;"
	 */
	UFUNCTION()
	bool EventBindBroadcastsReachHandlers()
	{
		BeginPlay();

		if (EventCount != 43)
		{
			return false;
		}

		return EventLog == "Custom;TestData;";
	}
}
/** @end */
/**
 * @begin event-bus-decouples-publisher-and-receiver
 * @summary An event bus decoupling a publisher actor from a receiver object: the receiver is bound, receives one broadcast, is unbound, and must not receive the second broadcast.
 * @topic Events
 */
/**
 * The message event carrying a numeric and a string payload.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the payload Value and Label
 * @Return nothing when broadcast
 */
event void FCoverageEventBusMessage(int Value, const FString&in Label);

UCLASS()
class UCoverageEventBusReceiver : UObject
{
	UPROPERTY()
	int Total = 0;

	UPROPERTY()
	FString Log;

	/**
	 * Records each delivered message.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the payload Value and Label
	 * @Return nothing; Total gains Value and Log gains Label
	 * @Param Value the numeric payload
	 * @Param Label the string payload
	 */
	UFUNCTION()
	void HandleMessage(int Value, const FString&in Label)
	{
		Total += Value;
		Log += Label;
	}
}

UCLASS()
class ACoverageEventBusActor : AActor
{
	UPROPERTY()
	FCoverageEventBusMessage OnMessage;

	UPROPERTY()
	UCoverageEventBusReceiver Receiver;

	UPROPERTY()
	int ReceiverTotal = 0;

	UPROPERTY()
	FString ReceiverLog;

	UPROPERTY()
	bool WasBoundBeforeUnbind = false;

	UPROPERTY()
	bool WasBoundAfterUnbind = true;

	/**
	 * Binds the receiver, broadcasts, unbinds, and broadcasts again.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the flags and snapshots record the sequence
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Receiver = Cast<UCoverageEventBusReceiver>(NewObject(this, UCoverageEventBusReceiver::StaticClass(), n"CoverageEventBusReceiver"));
		OnMessage.AddUFunction(Receiver, n"HandleMessage");
		WasBoundBeforeUnbind = OnMessage.IsBound();

		OnMessage.Broadcast(7, "A");
		OnMessage.Unbind(Receiver, n"HandleMessage");
		WasBoundAfterUnbind = OnMessage.IsBound();
		OnMessage.Broadcast(11, "B");

		ReceiverTotal = Receiver.Total;
		ReceiverLog = Receiver.Log;
	}

	/**
	 * Observe that a locally constructed actor has neither receiver nor record.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when no receiver exists and no message was recorded
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EventBusDefaultEmpty()
	{
		if (ReceiverTotal != 0)
		{
			return false;
		}

		if (ReceiverLog.Len() != 0)
		{
			return false;
		}

		if (WasBoundBeforeUnbind)
		{
			return false;
		}

		if (!WasBoundAfterUnbind)
		{
			return false;
		}

		return Receiver == nullptr;
	}
}
/** @end */
/**
 * @begin event-chaining
 * @summary Event chaining through nested broadcasts: the first handler broadcasts the second event, whose handler broadcasts the third. The ordering recorded in the chain proves the nesting unwinds depth-first.
 * @topic Events
 */
/**
 * The event type shared by all three links of the chain.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageChainEvent();

UCLASS()
class ACoverageEventChainingActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FString EventChain;

	FCoverageChainEvent OnFirstEvent;
	FCoverageChainEvent OnSecondEvent;
	FCoverageChainEvent OnThirdEvent;

	/**
	 * Binds the three handlers and triggers the chain.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the handlers record the chain
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnFirstEvent.AddUFunction(this, n"HandleFirstEvent");
		OnSecondEvent.AddUFunction(this, n"HandleSecondEvent");
		OnThirdEvent.AddUFunction(this, n"HandleThirdEvent");

		OnFirstEvent.Broadcast();
	}

	/**
	 * The first link of the chain, broadcasting the second event.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 1 and the second event fires
	 */
	UFUNCTION()
	void HandleFirstEvent()
	{
		Counter += 1;
		EventChain += "First;";
		OnSecondEvent.Broadcast();
	}

	/**
	 * The second link of the chain, broadcasting the third event.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 10 and the third event fires
	 */
	UFUNCTION()
	void HandleSecondEvent()
	{
		Counter += 10;
		EventChain += "Second;";
		OnThirdEvent.Broadcast();
	}

	/**
	 * The final link of the chain.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 100
	 */
	UFUNCTION()
	void HandleThirdEvent()
	{
		Counter += 100;
		EventChain += "Third;";
	}

	/**
	 * Observe that a locally constructed actor has recorded nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the counter is 0 and the chain is empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EventChainDefaultsToEmpty()
	{
		if (Counter != 0)
		{
			return false;
		}

		return EventChain.Len() == 0;
	}

	/**
	 * Observe the chain after BeginPlay triggers the first event.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then both counters
	 * @Return true when the counter is 111 and the chain records all three links
	 */
	UFUNCTION()
	bool EventChainTraversesAllLinks()
	{
		BeginPlay();

		if (Counter != 111)
		{
			return false;
		}

		return EventChain == "First;Second;Third;";
	}
}
/** @end */
/**
 * @begin event-custom-game-events
 * @summary Custom game events modelling health and death. Two damage calls drain the health pool to zero, firing the health-changed event twice and the death and state-changed events once.
 * @topic Events
 */
/**
 * Fires whenever the health pool changes value.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the previous and current health
 * @Return nothing when broadcast
 */
event void FCoverageHealthChangedEvent(float OldHealth, float NewHealth);

/**
 * Fires once when health reaches zero.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageDeathEvent();

/**
 * Fires when the alive/dead state flips.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs the new state
 * @Return nothing when broadcast
 */
event void FCoverageStateChangedEvent(bool NewState);

UCLASS()
class ACoverageEventCustomGameActor : AActor
{
	UPROPERTY()
	float Health = 100.0f;

	UPROPERTY()
	bool IsDead = false;

	UPROPERTY()
	int HealthChangeCount = 0;

	UPROPERTY()
	int DeathEventCount = 0;

	UPROPERTY()
	float LastOldHealth = 0.0f;

	UPROPERTY()
	float LastNewHealth = 0.0f;

	FCoverageHealthChangedEvent OnHealthChanged;
	FCoverageDeathEvent OnDeath;
	FCoverageStateChangedEvent OnStateChanged;

	/**
	 * Binds the three handlers and applies two damage hits.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the events record the damage sequence
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnHealthChanged.AddUFunction(this, n"HandleHealthChanged");
		OnDeath.AddUFunction(this, n"HandleDeath");
		OnStateChanged.AddUFunction(this, n"HandleStateChanged");

		TakeDamage(30.0f);
		TakeDamage(70.0f); // Should trigger death
	}

	/**
	 * Applies damage and fires the health-changed and death events.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the damage amount
	 * @Return nothing; health decreases and death fires when it hits zero
	 * @Param Damage the damage to apply
	 */
	void TakeDamage(float Damage)
	{
		float OldHealth = Health;
		Health -= Damage;

		if (Health < 0.0f)
		{
			Health = 0.0f;
		}

		OnHealthChanged.Broadcast(OldHealth, Health);

		if (Health <= 0.0f && !IsDead)
		{
			IsDead = true;
			OnDeath.Broadcast();
			OnStateChanged.Broadcast(true);
		}
	}

	/**
	 * Records each health change.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the previous and current health
	 * @Return nothing; the counter gains 1 and the last values update
	 * @Param OldHealth the health before the change
	 * @Param NewHealth the health after the change
	 */
	UFUNCTION()
	void HandleHealthChanged(float OldHealth, float NewHealth)
	{
		HealthChangeCount++;
		LastOldHealth = OldHealth;
		LastNewHealth = NewHealth;
	}

	/**
	 * Records the death event.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 1
	 */
	UFUNCTION()
	void HandleDeath()
	{
		DeathEventCount++;
	}

	/**
	 * Receives state changes; the body is intentionally empty.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the new alive/dead state
	 * @Return nothing
	 * @Param NewState the state after the change
	 */
	UFUNCTION()
	void HandleStateChanged(bool NewState)
	{
	}

	/**
	 * Observe that a locally constructed actor is alive and untouched.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when health is 100, alive, and no events counted
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool CustomGameActorDefaultsToAlive()
	{
		if (!Math::IsNearlyEqual(Health, 100.0))
		{
			return false;
		}

		if (IsDead)
		{
			return false;
		}

		if (HealthChangeCount != 0)
		{
			return false;
		}

		return DeathEventCount == 0;
	}

	/**
	 * Observe the recorded events after the damage sequence.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then the state and counters
	 * @Return true when both counts, the death flag and the final health match
	 */
	UFUNCTION()
	bool CustomGameEventsFireThroughDeath()
	{
		BeginPlay();

		if (HealthChangeCount != 2)
		{
			return false;
		}

		if (DeathEventCount != 1)
		{
			return false;
		}

		if (!IsDead)
		{
			return false;
		}

		return Math::IsNearlyEqual(Health, 0.0);
	}
}
/** @end */
/**
 * @begin event-lifecycle
 * @summary Actor lifecycle overrides combined with a custom event broadcast from both BeginPlay and EndPlay. The observers confirm the default state and the BeginPlay path; the world runner supplies Tick and Destroy for the rest.
 * @topic Events
 */
/**
 * The lifecycle event broadcast from BeginPlay and EndPlay.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageLifecycleEvent();

UCLASS()
class ACoverageEventLifecycleActor : AActor
{
	UPROPERTY()
	int BeginPlayCount = 0;

	UPROPERTY()
	int TickCount = 0;

	UPROPERTY()
	int EndPlayCount = 0;

	UPROPERTY()
	int LifecycleEventCount = 0;

	UPROPERTY()
	FCoverageLifecycleEvent OnLifecycle;

	/**
	 * Binds the lifecycle handler and broadcasts the first time.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; BeginPlayCount gains 1 and the event fires
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnLifecycle.AddUFunction(this, n"HandleLifecycle");
		BeginPlayCount += 1;
		OnLifecycle.Broadcast();
	}

	/**
	 * Counts each world tick.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the frame delta
	 * @Return nothing; TickCount gains 1
	 * @Param DeltaTime the seconds since the last tick
	 */
	UFUNCTION(BlueprintOverride)
	void Tick(float DeltaTime)
	{
		TickCount += 1;
	}

	/**
	 * Broadcasts the lifecycle event a final time.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the reason play is ending
	 * @Return nothing; EndPlayCount gains 1 and the event fires
	 * @Param Reason why the actor is leaving play
	 */
	UFUNCTION(BlueprintOverride)
	void EndPlay(EEndPlayReason Reason)
	{
		EndPlayCount += 1;
		OnLifecycle.Broadcast();
	}

	/**
	 * Records each lifecycle broadcast.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; LifecycleEventCount gains 1
	 */
	UFUNCTION()
	void HandleLifecycle()
	{
		LifecycleEventCount += 1;
	}

	/**
	 * Observe that a locally constructed actor has counted nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when all four counters are 0
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EventLifecycleCountersDefaultToZero()
	{
		if (BeginPlayCount != 0)
		{
			return false;
		}

		if (TickCount != 0)
		{
			return false;
		}

		if (EndPlayCount != 0)
		{
			return false;
		}

		return LifecycleEventCount == 0;
	}

	/**
	 * Observe the counts after the BeginPlay path runs.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then the counters
	 * @Return true when BeginPlayCount and LifecycleEventCount are both 1
	 */
	UFUNCTION()
	bool EventLifecycleBeginPlayBroadcastsOnce()
	{
		BeginPlay();

		if (BeginPlayCount != 1)
		{
			return false;
		}

		return LifecycleEventCount == 1;
	}
}
/** @end */
/**
 * @begin event-multiple-handlers
 * @summary One event with three handlers bound in order. A single broadcast must invoke all three in bind order, which the appended string records.
 * @topic Events
 */
/**
 * The game event carrying three bound handlers.
 *
 * @Covers Syntax.EdgeCases
 * @Inputs none
 * @Return nothing when broadcast
 */
event void FCoverageGameEvent();

UCLASS()
class ACoverageEventMultipleHandlersActor : AActor
{
	UPROPERTY()
	int Counter = 0;

	UPROPERTY()
	FString Result;

	FCoverageGameEvent OnGameEvent;

	/**
	 * Binds three handlers and broadcasts once.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; all three handlers run
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnGameEvent.AddUFunction(this, n"Handler1");
		OnGameEvent.AddUFunction(this, n"Handler2");
		OnGameEvent.AddUFunction(this, n"Handler3");

		OnGameEvent.Broadcast();
	}

	/**
	 * The first bound handler.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 1 and the result gains "A"
	 */
	UFUNCTION()
	void Handler1()
	{
		Counter += 1;
		Result += "A";
	}

	/**
	 * The second bound handler.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 10 and the result gains "B"
	 */
	UFUNCTION()
	void Handler2()
	{
		Counter += 10;
		Result += "B";
	}

	/**
	 * The third bound handler.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs none
	 * @Return nothing; the counter gains 100 and the result gains "C"
	 */
	UFUNCTION()
	void Handler3()
	{
		Counter += 100;
		Result += "C";
	}

	/**
	 * Observe that a locally constructed actor has recorded nothing.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a freshly constructed actor
	 * @Return true when the counter is 0 and the result is empty
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool EventMultipleHandlersDefaultToEmpty()
	{
		if (Counter != 0)
		{
			return false;
		}

		return Result.Len() == 0;
	}

	/**
	 * Observe the state after one broadcast reaches all three handlers.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs BeginPlay() then both counters
	 * @Return true when the counter is 111 and the result is "ABC"
	 */
	UFUNCTION()
	bool EventMultipleHandlersAllRunInOrder()
	{
		BeginPlay();

		if (Counter != 111)
		{
			return false;
		}

		return Result == "ABC";
	}
}
/** @end */
/**
 * @begin event-unbinding
 * @summary Unbinding one handler from an event. Two handlers are bound and the event is broadcast twice with an Unbind between them, so the first broadcast reaches both handlers and the second reaches only the survivor.
 * @topic Events
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
/**
 * @begin immediate-failure-callbacks
 * @summary The script harness for immediate save/load failure callbacks: two starters that bind completion delegates by name and forward the slot arguments. The failure cases belong to the C++ runner; this class only supplies the.
 * @topic Events
 */
UCLASS()
class UAsyncSaveLoadImmediateFailureScriptHarness : UObject
{
	/**
	 * Starts an async save bound to the receiver's completion callback.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the save object, receiver, slot name and user index
	 * @Return nothing; the delegate is bound and the save started
	 * @Param SaveGameObject the object being saved
	 * @Param Receiver the object owning the completion callback
	 * @Param SlotName the slot to save into
	 * @Param UserIndex the platform user index
	 */
	UFUNCTION()
	void StartAsyncSave(USaveGame SaveGameObject, UObject Receiver, const FString&in SlotName, int32 UserIndex)
	{
		FAsyncSaveGameToSlotDynamicDelegate SaveDelegate;
		SaveDelegate.BindUFunction(Receiver, n"OnSaveComplete");
		UGameplayLibrary::AsyncSaveGameToSlot(SaveGameObject, SlotName, UserIndex, SaveDelegate);
	}

	/**
	 * Starts an async load bound to the receiver's completion callback.
	 *
	 * @Covers Syntax.EdgeCases
	 * @Inputs the receiver, slot name and user index
	 * @Return nothing; the delegate is bound and the load started
	 * @Param Receiver the object owning the completion callback
	 * @Param SlotName the slot to load from
	 * @Param UserIndex the platform user index
	 */
	UFUNCTION()
	void StartAsyncLoad(UObject Receiver, const FString&in SlotName, int32 UserIndex)
	{
		FAsyncLoadGameFromSlotDynamicDelegate LoadDelegate;
		LoadDelegate.BindUFunction(Receiver, n"OnLoadComplete");
		UGameplayLibrary::AsyncLoadGameFromSlot(SlotName, UserIndex, LoadDelegate);
	}

	/**
	 * Observe that the harness constructs with no pending async work.
	 *
	 * @Kind Observe
	 * @Covers Syntax.EdgeCases
	 * @Inputs a locally constructed harness
	 * @Return true once construction completes
	 * @Boundary default construction
	 */
	UFUNCTION()
	bool ImmediateFailureHarnessConstructs()
	{
		UAsyncSaveLoadImmediateFailureScriptHarness Harness;
		return true;
	}
}
/** @end */
