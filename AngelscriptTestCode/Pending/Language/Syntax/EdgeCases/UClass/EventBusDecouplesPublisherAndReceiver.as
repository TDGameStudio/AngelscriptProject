/**
 * @version v1
 * @summary An event bus decoupling a publisher actor from a receiver object: the receiver is bound, receives one broadcast, is unbound, and must not receive the second broadcast.
 * @topic Language
 */
/**
 * @version root
 * @summary An event bus decoupling a publisher actor from a receiver object: the receiver is bound, receives one broadcast, is unbound, and must not receive the second broadcast.
 * @topic Baseline
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
