/**
 * @version v1
 * @summary USTRUCT payload through compute and multicast. After BeginPlay, bPayloadComputeBound true, ComputePayloadValue 19, Bonus 23, Tag Compute, ComputePayloadResult 42; signal Value 29 Bonus 31 Tag Signal Result 60. Default.
 * @topic Feature
 */
/**
 * @version root
 * @summary USTRUCT payload through compute and multicast. After BeginPlay, bPayloadComputeBound true, ComputePayloadValue 19, Bonus 23, Tag Compute, ComputePayloadResult 42; signal Value 29 Bonus 31 Tag Signal Result 60. Default.
 * @topic Baseline
 */
USTRUCT(BlueprintType)
struct FUClassPropertyDelegatePayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;

	UPROPERTY()
	FName Tag;
}

/**
 * A unicast that computes from a struct payload.
 *
 * @Covers Delegates.Execute
 * @Inputs Payload
 * @Return int
 */
delegate int FUClassPropertyPayloadComputeDelegate(FUClassPropertyDelegatePayload Payload);

/**
 * A multicast that signals a struct payload.
 *
 * @Covers Delegates.Broadcast
 * @Inputs Payload
 * @Return void
 */
event void FUClassPropertyPayloadEvent(FUClassPropertyDelegatePayload Payload);

UCLASS()
class ACoverageUClassDelegateStructPayloadActor : AActor
{
	UPROPERTY()
	FUClassPropertyPayloadComputeDelegate OnPayloadCompute;

	UPROPERTY()
	FUClassPropertyPayloadEvent OnPayloadSignal;

	UPROPERTY()
	bool bPayloadComputeBound = false;

	UPROPERTY()
	bool bPayloadSignalBound = false;

	UPROPERTY()
	int ComputePayloadValue = 0;

	UPROPERTY()
	int ComputePayloadBonus = 0;

	UPROPERTY()
	FName ComputePayloadTag;

	UPROPERTY()
	int ComputePayloadResult = 0;

	UPROPERTY()
	int SignalPayloadValue = 0;

	UPROPERTY()
	int SignalPayloadBonus = 0;

	UPROPERTY()
	FName SignalPayloadTag;

	UPROPERTY()
	int SignalPayloadResult = 0;

	/**
	 * Build a payload from value, bonus, and tag.
	 *
	 * @Covers Delegates.Execute
	 * @Inputs Value, Bonus, and Tag
	 * @Return a payload holding those fields
	 * @Param Value the payload value
	 * @Param Bonus the payload bonus
	 * @Param Tag the payload tag
	 */
	FUClassPropertyDelegatePayload MakePayload(int Value, int Bonus, FName Tag)
	{
		FUClassPropertyDelegatePayload Payload;
		Payload.Value = Value;
		Payload.Bonus = Bonus;
		Payload.Tag = Tag;
		return Payload;
	}

	/**
	 * WorldStory: BeginPlay binds and executes/broadcasts struct payloads.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return ComputePayloadResult 42, SignalPayloadResult 60
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnPayloadCompute.BindUFunction(this, n"HandlePayloadCompute");
		bPayloadComputeBound = OnPayloadCompute.IsBound();
		ComputePayloadResult = OnPayloadCompute.Execute(MakePayload(19, 23, n"Compute"));

		OnPayloadSignal.AddUFunction(this, n"HandlePayloadSignal");
		bPayloadSignalBound = OnPayloadSignal.IsBound();
		OnPayloadSignal.Broadcast(MakePayload(29, 31, n"Signal"));
	}

	/**
	 * Store compute payload fields and return Value + Bonus.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Payload Struct received by value
	 * @Inputs Payload
	 * @Return Payload.Value + Payload.Bonus
	 */
	UFUNCTION()
	int HandlePayloadCompute(FUClassPropertyDelegatePayload Payload)
	{
		ComputePayloadValue = Payload.Value;
		ComputePayloadBonus = Payload.Bonus;
		ComputePayloadTag = Payload.Tag;
		return Payload.Value + Payload.Bonus;
	}

	/**
	 * Store signal payload fields and write SignalPayloadResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Broadcast
	 * @Param Payload Struct received by value
	 * @Inputs Payload
	 * @Return void
	 */
	UFUNCTION()
	void HandlePayloadSignal(FUClassPropertyDelegatePayload Payload)
	{
		SignalPayloadValue = Payload.Value;
		SignalPayloadBonus = Payload.Bonus;
		SignalPayloadTag = Payload.Tag;
		SignalPayloadResult = Payload.Value + Payload.Bonus;
	}

	/**
	 * Observe a default payload Value + Bonus.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a default payload
	 * @Return 0
	 * @Boundary default payload
	 */
	UFUNCTION()
	int PayloadDefaultZero()
	{
		FUClassPropertyDelegatePayload Payload;
		return Payload.Value + Payload.Bonus;
	}

	/**
	 * Observe the default ComputePayloadResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default ComputePayloadResult
	 */
	UFUNCTION()
	int ComputePayloadResultDefaultZero()
	{
		return ComputePayloadResult;
	}

	/**
	 * Observe that mutating a payload copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Original 19/23/Compute and a zeroed copy
	 * @Return true when Original stays 19/23/Compute
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool PayloadCopyIndependence()
	{
		FUClassPropertyDelegatePayload Original;
		Original.Value = 19;
		Original.Bonus = 23;
		Original.Tag = n"Compute";
		FUClassPropertyDelegatePayload Copy = Original;
		Copy.Value = 0;
		Copy.Bonus = 0;
		Copy.Tag = n"";
		if (Original.Value != 19)
		{
			return false;
		}
		if (Original.Bonus != 23)
		{
			return false;
		}
		if (Original.Tag != n"Compute")
		{
			return false;
		}
		if (Copy.Value != 0)
		{
			return false;
		}
		return Copy.Bonus == 0;
	}
}
/** @end */
