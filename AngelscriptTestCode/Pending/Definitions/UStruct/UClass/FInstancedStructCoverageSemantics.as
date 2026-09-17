/**
 * @version v1
 * @summary FInstancedStruct Reset, array storage, and EchoPayload on an actor. C++ compiles the module, spawns, and VerifyByPath bResetInvalid. Keep the UPROPERTY names Payload, Payloads, and bResetInvalid.
 * @topic Definitions
 */
/**
 * @version root
 * @summary FInstancedStruct Reset, array storage, and EchoPayload on an actor. C++ compiles the module, spawns, and VerifyByPath bResetInvalid. Keep the UPROPERTY names Payload, Payloads, and bResetInvalid.
 * @topic Baseline
 */
USTRUCT()
struct FInstancedStructPayload
{
	UPROPERTY()
	int Value = 42;
}

UCLASS()
class AInstancedStructCoverageActor : AActor
{
	UPROPERTY()
	FInstancedStruct Payload;

	UPROPERTY()
	TArray<FInstancedStruct> Payloads;

	UPROPERTY()
	bool bResetInvalid = false;

	/**
	 * Echo an instanced struct through a UFUNCTION return slot.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FInstancedStructCoverageSemantics
	 * @Inputs an FInstancedStruct value
	 * @Return the same payload
	 * @Param Input the payload to echo
	 */
	UFUNCTION()
	FInstancedStruct EchoPayload(FInstancedStruct Input)
	{
		return Input;
	}

	/**
	 * WorldStory: BeginPlay resets Payload, stores it, and records invalidity.
	 *
	 * @Kind WorldStory
	 * @Covers UStruct.FInstancedStructCoverageSemantics
	 * @Inputs none
	 * @Return bResetInvalid true when Payload is invalid and Payloads.Num is 1
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		Payload.Reset();
		Payloads.Add(Payload);
		bResetInvalid = !Payload.IsValid() && Payloads.Num() == 1;
	}

	/**
	 * Observe the local-construct empty vector before BeginPlay.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FInstancedStructCoverageSemantics
	 * @Inputs an actor that has not begun play
	 * @Return true when bResetInvalid is false, Payloads is empty, and Payload is invalid
	 * @Boundary local construct
	 */
	UFUNCTION()
	bool InstancedStructDefaultEmpty()
	{
		if (bResetInvalid != false)
		{
			return false;
		}
		if (Payloads.Num() != 0)
		{
			return false;
		}
		return !Payload.IsValid();
	}

	/**
	 * Observe that echoing an empty instanced struct stays invalid.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FInstancedStructCoverageSemantics
	 * @Inputs EchoPayload of a default FInstancedStruct
	 * @Return true when both the empty input and the echo are invalid
	 * @Boundary empty payload
	 */
	UFUNCTION()
	bool InstancedStructEchoEmptyBoundary()
	{
		FInstancedStruct Empty;
		FInstancedStruct Echoed = EchoPayload(Empty);
		if (Empty.IsValid())
		{
			return false;
		}
		return !Echoed.IsValid();
	}

	/**
	 * Observe Reset plus array storage producing the invalid-shape flag.
	 *
	 * @Kind Observe
	 * @Covers UStruct.FInstancedStructCoverageSemantics
	 * @Inputs Reset Payload and Add it to Payloads
	 * @Return true when bResetInvalid is true
	 */
	UFUNCTION()
	bool InstancedStructResetInvalidShape()
	{
		Payload.Reset();
		Payloads.Add(Payload);
		bResetInvalid = !Payload.IsValid() && Payloads.Num() == 1;
		return bResetInvalid == true;
	}
}
/** @end */
