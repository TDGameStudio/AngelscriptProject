/**
 * Typed payload (bool/float/string/name/vector/actor/enum) through compute and
 * multicast. After BeginPlay, bComputeBound true, bComputeEnabled true,
 * ComputeWeight 2.5, ComputeLabel ComputeLabel, ComputeTag ComputeTag,
 * ComputeLocation (1,2,3), bComputeActorWasSelf true, ComputeState 1 (Armed),
 * ComputeResult 26; bSignalBound true, bSignalEnabled false, SignalWeight 4.25,
 * SignalLabel SignalLabel, SignalTag SignalTag, SignalLocation (4,5,6),
 * bSignalActorWasSelf true, SignalState 2 (Fired), SignalResult 44. Idle==0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.UClassDelegateTypedPayloadMemberMatrix
 * @Harness UClass
 * @Tag Feature.Delegates.UClassDelegateTypedPayloadMemberMatrix
 * @Provenance Theme: Feature.Delegates. WorldStory: typed payload (bool/float/string/name/vector/actor/enum).
 * @Provenance C++: AngelscriptCoverageUClassPropertyTests.cpp::UClassDelegateTypedPayloadMemberMatrix
 * @Provenance Spawn + BeginPlay oracle: bComputeBound true, bComputeEnabled true, ComputeWeight 2.5,
 * @Provenance ComputeLabel "ComputeLabel", ComputeTag ComputeTag, ComputeLocation (1,2,3),
 * @Provenance bComputeActorWasSelf true, ComputeState 1 (Armed), ComputeResult 26;
 * @Provenance bSignalBound true, bSignalEnabled false, SignalWeight 4.25, SignalLabel "SignalLabel",
 * @Provenance SignalTag SignalTag, SignalLocation (4,5,6), bSignalActorWasSelf true,
 * @Provenance SignalState 2 (Fired), SignalResult 44.
 * @Provenance Extra: Idle==0 default enum; default flags false / 0. Keep Compute* and Signal*.
 * @Provenance FixtureIsolated. PlannedSymbols include int.
 */

UENUM(BlueprintType)
enum EUClassPropertyDelegateTypedState
{
	Idle,
	Armed,
	Fired
}

/**
 * A unicast of the typed payload matrix that returns int.
 *
 * @Covers Delegates.Execute
 * @Inputs bEnabled, Weight, Label, Tag, Location, ActorValue, State
 * @Return int
 */
delegate int FUClassPropertyTypedComputeDelegate(bool bEnabled, float Weight, FString Label, FName Tag, FVector Location, AActor ActorValue, EUClassPropertyDelegateTypedState State);

/**
 * A multicast of the typed payload matrix.
 *
 * @Covers Delegates.Broadcast
 * @Inputs bEnabled, Weight, Label, Tag, Location, ActorValue, State
 * @Return void
 */
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

	/**
	 * WorldStory: BeginPlay binds and executes/broadcasts typed payloads.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return ComputeResult 26, SignalResult 44
	 */
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

	/**
	 * Store typed compute arguments and return Weight*10 + State.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param bEnabled Bool received by value
	 * @Param Weight Float received by value
	 * @Param Label String received by value
	 * @Param Tag Name received by value
	 * @Param Location Vector received by value
	 * @Param ActorValue Actor received by value
	 * @Param State Enum received by value
	 * @Inputs the typed compute arguments
	 * @Return int(Weight * 10) + int(State)
	 */
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

	/**
	 * Store typed signal arguments and write SignalResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param bEnabled Bool received by value
	 * @Param Weight Float received by value
	 * @Param Label String received by value
	 * @Param Tag Name received by value
	 * @Param Location Vector received by value
	 * @Param ActorValue Actor received by value
	 * @Param State Enum received by value
	 * @Inputs the typed signal arguments
	 * @Return void
	 */
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
	 * Observe the Idle enum ordinal.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return 0
	 * @Boundary default Idle
	 */
	UFUNCTION()
	int IdleStateDefaultEnum()
	{
		return int(EUClassPropertyDelegateTypedState::Idle);
	}

	/**
	 * Observe the default bSignalEnabled.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Inputs a freshly constructed actor
	 * @Return true when bSignalEnabled is false
	 * @Boundary default signal enabled
	 */
	UFUNCTION()
	bool SignalEnabledDefaultFalse()
	{
		return !bSignalEnabled;
	}

	/**
	 * Observe Weight 0 and Idle.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Weight 0 and Idle
	 * @Return 0
	 * @Boundary idle weight
	 */
	UFUNCTION()
	int IdleWeightZeroBoundary()
	{
		float Weight = 0.0f;
		EUClassPropertyDelegateTypedState State = EUClassPropertyDelegateTypedState::Idle;
		return int(Weight * 10.0f) + int(State);
	}
}
