// Theme: Feature.Delegates. WorldStory: typed payload (bool/float/string/name/vector/actor/enum).
// C++: AngelscriptCoverageUClassPropertyTests.cpp::UClassDelegateTypedPayloadMemberMatrix
// Spawn + BeginPlay oracle: bComputeBound true, bComputeEnabled true, ComputeWeight 2.5,
// ComputeLabel "ComputeLabel", ComputeTag ComputeTag, ComputeLocation (1,2,3),
// bComputeActorWasSelf true, ComputeState 1 (Armed), ComputeResult 26;
// bSignalBound true, bSignalEnabled false, SignalWeight 4.25, SignalLabel "SignalLabel",
// SignalTag SignalTag, SignalLocation (4,5,6), bSignalActorWasSelf true,
// SignalState 2 (Fired), SignalResult 44.
// Extra: Idle==0 default enum; default flags false / 0. Keep Compute* and Signal*.
// FixtureIsolated. PlannedSymbols include int.

UENUM(BlueprintType)
enum EUClassPropertyDelegateTypedState
{
	Idle,
	Armed,
	Fired
}

delegate int FUClassPropertyTypedComputeDelegate(bool bEnabled, float Weight, FString Label, FName Tag, FVector Location, AActor ActorValue, EUClassPropertyDelegateTypedState State);
event void FUClassPropertyTypedSignal(bool bEnabled, float Weight, FString Label, FName Tag, FVector Location, AActor ActorValue, EUClassPropertyDelegateTypedState State);

UCLASS()
class ACoverageUClassDelegateTypedPayloadActor : AActor
{
	UPROPERTY()
	FUClassPropertyTypedComputeDelegate OnTypedCompute;

	UPROPERTY()
	FUClassPropertyTypedSignal OnTypedSignal;

	UPROPERTY()
	bool bComputeBound = false;

	UPROPERTY()
	bool bSignalBound = false;

	UPROPERTY()
	bool bComputeEnabled = false;

	UPROPERTY()
	float ComputeWeight = 0.0;

	UPROPERTY()
	FString ComputeLabel;

	UPROPERTY()
	FName ComputeTag;

	UPROPERTY()
	FVector ComputeLocation;

	UPROPERTY()
	bool bComputeActorWasSelf = false;

	UPROPERTY()
	int ComputeState = 0;

	UPROPERTY()
	int ComputeResult = 0;

	UPROPERTY()
	bool bSignalEnabled = false;

	UPROPERTY()
	float SignalWeight = 0.0;

	UPROPERTY()
	FString SignalLabel;

	UPROPERTY()
	FName SignalTag;

	UPROPERTY()
	FVector SignalLocation;

	UPROPERTY()
	bool bSignalActorWasSelf = false;

	UPROPERTY()
	int SignalState = 0;

	UPROPERTY()
	int SignalResult = 0;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnTypedCompute.BindUFunction(this, n"HandleTypedCompute");
		bComputeBound = OnTypedCompute.IsBound();
		ComputeResult = OnTypedCompute.Execute(
			true,
			2.5f,
			"ComputeLabel",
			n"ComputeTag",
			FVector(1, 2, 3),
			this,
			EUClassPropertyDelegateTypedState::Armed);

		OnTypedSignal.AddUFunction(this, n"HandleTypedSignal");
		bSignalBound = OnTypedSignal.IsBound();
		OnTypedSignal.Broadcast(
			false,
			4.25f,
			"SignalLabel",
			n"SignalTag",
			FVector(4, 5, 6),
			this,
			EUClassPropertyDelegateTypedState::Fired);
	}

	UFUNCTION()
	int HandleTypedCompute(bool bEnabled, float Weight, FString Label, FName Tag, FVector Location, AActor ActorValue, EUClassPropertyDelegateTypedState State)
	{
		bComputeEnabled = bEnabled;
		ComputeWeight = Weight;
		ComputeLabel = Label;
		ComputeTag = Tag;
		ComputeLocation = Location;
		bComputeActorWasSelf = ActorValue == this;
		ComputeState = int(State);
		return int(Weight * 10.0f) + int(State);
	}

	UFUNCTION()
	void HandleTypedSignal(bool bEnabled, float Weight, FString Label, FName Tag, FVector Location, AActor ActorValue, EUClassPropertyDelegateTypedState State)
	{
		bSignalEnabled = bEnabled;
		SignalWeight = Weight;
		SignalLabel = Label;
		SignalTag = Tag;
		SignalLocation = Location;
		bSignalActorWasSelf = ActorValue == this;
		SignalState = int(State);
		SignalResult = int(Weight * 10.0f) + int(State);
	}
}

int Observe_ComputeResult_DefaultZero(ACoverageUClassDelegateTypedPayloadActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateTypedPayloadMemberMatrix setup: required Actor is null");
	}
	return Actor.ComputeResult;
}

int Observe_IdleState_DefaultEnum()
{
	return int(EUClassPropertyDelegateTypedState::Idle);
}

bool Observe_SignalEnabled_DefaultFalse(ACoverageUClassDelegateTypedPayloadActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateTypedPayloadMemberMatrix setup: required Actor is null");
	}
	return !Actor.bSignalEnabled;
}

int Observe_IdleWeight_ZeroBoundary()
{
	float Weight = 0.0f;
	EUClassPropertyDelegateTypedState State = EUClassPropertyDelegateTypedState::Idle;
	return int(Weight * 10.0f) + int(State);
}
