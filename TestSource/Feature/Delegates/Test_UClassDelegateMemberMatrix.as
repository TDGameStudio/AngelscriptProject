// Theme: Feature.Delegates. WorldStory: UCLASS single-cast and multicast member delegates.
// C++: AngelscriptCoverageUClassPropertyTests.cpp::UClassDelegateMemberMatrix
// Spawn + BeginPlay oracle: bComputeBound true, ComputeInput 5, ComputeResult 42,
// bPlainSignalBound true, PlainSignalCount 2, bSignalBound true, SignalCountA 3,
// SignalCountB 30, SignalTotal 33, bCallableSignalBound true, CallableSignalCount 400.
// Extra: default flags false / counts 0. Keep ComputeResult, SignalTotal, CallableSignalCount.
// FixtureIsolated.

delegate int FUClassPropertyComputeDelegate(int Value);
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

	UFUNCTION()
	int HandleCompute(int Value)
	{
		ComputeInput = Value;
		return Value + 37;
	}

	UFUNCTION()
	void HandleSignalA(int Value)
	{
		SignalCountA += Value;
	}

	UFUNCTION()
	void HandlePlainSignal(int Value)
	{
		PlainSignalCount += Value;
	}

	UFUNCTION()
	void HandleSignalB(int Value)
	{
		SignalCountB += Value * 10;
	}

	UFUNCTION()
	void HandleCallableSignal(int Value)
	{
		CallableSignalCount += Value * 100;
	}
}

int Observe_ComputeResult_DefaultZero(ACoverageUClassDelegateMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateMemberMatrix setup: required Actor is null");
	}
	return Actor.ComputeResult;
}

bool Observe_BoundFlags_DefaultFalse(ACoverageUClassDelegateMemberActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateMemberMatrix setup: required Actor is null");
	}
	return !Actor.bComputeBound && !Actor.bPlainSignalBound && !Actor.bSignalBound && !Actor.bCallableSignalBound;
}

int Observe_Compute_ZeroBoundary()
{
	return 0 + 37;
}
