/**
 * @version v1
 * @summary Local scope lifetime: entering a scope constructs its locals, leaving an inner block destroys the inner locals while the outer state survives, and a container declared inside a loop body is destroyed on each iteration.
 * @topic Language
 */
/**
 * @version root
 * @summary Local scope lifetime: entering a scope constructs its locals, leaving an inner block destroys the inner locals while the outer state survives, and a container declared inside a loop body is destroyed on each iteration.
 * @topic Baseline
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
