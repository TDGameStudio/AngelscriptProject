/**
 * UCLASS single-cast and multicast member delegates. After BeginPlay,
 * bComputeBound true, ComputeInput 5, ComputeResult 42, bPlainSignalBound true,
 * PlainSignalCount 2, bSignalBound true, SignalCountA 3, SignalCountB 30,
 * SignalTotal 33, bCallableSignalBound true, CallableSignalCount 400. Default
 * flags false / counts 0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.UClassDelegateMemberMatrix
 * @Harness UClass
 * @Tag Feature.Delegates.UClassDelegateMemberMatrix
 * @Provenance Theme: Feature.Delegates. WorldStory: UCLASS single-cast and multicast member delegates.
 * @Provenance C++: AngelscriptCoverageUClassPropertyTests.cpp::UClassDelegateMemberMatrix
 * @Provenance Spawn + BeginPlay oracle: bComputeBound true, ComputeInput 5, ComputeResult 42,
 * @Provenance bPlainSignalBound true, PlainSignalCount 2, bSignalBound true, SignalCountA 3,
 * @Provenance SignalCountB 30, SignalTotal 33, bCallableSignalBound true, CallableSignalCount 400.
 * @Provenance Extra: default flags false / counts 0. Keep ComputeResult, SignalTotal, CallableSignalCount.
 * @Provenance FixtureIsolated.
 */

/**
 * A unicast that computes from an int.
 *
 * @Covers Delegates.Execute
 * @Inputs Value
 * @Return int
 */
delegate int FUClassPropertyComputeDelegate(int Value);

/**
 * A multicast that signals an int.
 *
 * @Covers Delegates.Broadcast
 * @Inputs Value
 * @Return void
 */
event void FUClassPropertySignalEvent(int Value);

UCLASS()
class ACoverageUClassDelegateMemberActor : AActor
{
	UPROPERTY()
	FUClassPropertyComputeDelegate OnCompute;

	UPROPERTY()
	FUClassPropertySignalEvent OnPlainSignal;

	UPROPERTY()
	FUClassPropertySignalEvent OnSignal;

	UPROPERTY()
	FUClassPropertySignalEvent OnCallableSignal;

	UPROPERTY()
	bool bComputeBound = false;

	UPROPERTY()
	bool bPlainSignalBound = false;

	UPROPERTY()
	bool bSignalBound = false;

	UPROPERTY()
	bool bCallableSignalBound = false;

	UPROPERTY()
	int ComputeInput = 0;

	UPROPERTY()
	int ComputeResult = 0;

	UPROPERTY()
	int PlainSignalCount = 0;

	UPROPERTY()
	int SignalCountA = 0;

	UPROPERTY()
	int SignalCountB = 0;

	UPROPERTY()
	int SignalTotal = 0;

	UPROPERTY()
	int CallableSignalCount = 0;

	/**
	 * WorldStory: BeginPlay binds compute and signal members and broadcasts.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return ComputeResult 42, SignalTotal 33, CallableSignalCount 400
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnCompute.BindUFunction(this, n"HandleCompute");
		bComputeBound = OnCompute.IsBound();
		ComputeResult = OnCompute.Execute(5);

		OnPlainSignal.AddUFunction(this, n"HandlePlainSignal");
		bPlainSignalBound = OnPlainSignal.IsBound();
		OnPlainSignal.Broadcast(2);

		OnSignal.AddUFunction(this, n"HandleSignalA");
		OnSignal.AddUFunction(this, n"HandleSignalB");
		bSignalBound = OnSignal.IsBound();
		OnSignal.Broadcast(3);
		SignalTotal = SignalCountA + SignalCountB;

		OnCallableSignal.AddUFunction(this, n"HandleCallableSignal");
		bCallableSignalBound = OnCallableSignal.IsBound();
		OnCallableSignal.Broadcast(4);
	}

	/**
	 * Store ComputeInput and return Value + 37.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Value Integer received by value
	 * @Inputs Value
	 * @Return Value + 37
	 */
	UFUNCTION()
	int HandleCompute(int Value)
	{
		ComputeInput = Value;
		return Value + 37;
	}

	/**
	 * Add Value to SignalCountA.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Value Integer received by value
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void HandleSignalA(int Value)
	{
		SignalCountA += Value;
	}

	/**
	 * Add Value to PlainSignalCount.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Value Integer received by value
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void HandlePlainSignal(int Value)
	{
		PlainSignalCount += Value;
	}

	/**
	 * Add Value * 10 to SignalCountB.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Value Integer received by value
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void HandleSignalB(int Value)
	{
		SignalCountB += Value * 10;
	}

	/**
	 * Add Value * 100 to CallableSignalCount.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Value Integer received by value
	 * @Inputs Value
	 * @Return void
	 */
	UFUNCTION()
	void HandleCallableSignal(int Value)
	{
		CallableSignalCount += Value * 100;
	}

	/**
	 * Observe the default ComputeResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default ComputeResult
	 */
	UFUNCTION()
	int ComputeResultDefaultZero()
	{
		return ComputeResult;
	}

	/**
	 * Observe default bound flags.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return true when all four bound flags are false
	 * @Boundary default bound flags
	 */
	UFUNCTION()
	bool BoundFlagsDefaultFalse()
	{
		if (bComputeBound)
		{
			return false;
		}
		if (bPlainSignalBound)
		{
			return false;
		}
		if (bSignalBound)
		{
			return false;
		}
		return !bCallableSignalBound;
	}

	/**
	 * Observe HandleCompute of 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs 0
	 * @Return 37
	 * @Boundary zero compute
	 */
	UFUNCTION()
	int ComputeZeroBoundary()
	{
		return 0 + 37;
	}
}
