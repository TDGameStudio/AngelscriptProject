/**
 * An event bus decoupling a publisher actor from a receiver object: the receiver
 * is bound, receives one broadcast, is unbound, and must not receive the second
 * broadcast.
 *
 * @Theme Language.Syntax
 * @Subject Syntax.EdgeCases.EventBusDecouplesPublisherAndReceiver
 * @Harness UClass
 * @Tag Language.Syntax.EdgeCases.EventBusDecouplesPublisherAndReceiver
 * @Provenance C++: AngelscriptCoverageEventTests.cpp::EventBusDecouplesPublisherAndReceiver
 * @Provenance sha256=e38d77501b547a96d2e0cbc02eb2ac8eab0928eb210162fdcca828400f6479be; lines 1615-1672.
 * @Provenance Oracle: WasBoundBeforeUnbind=true; WasBoundAfterUnbind=false; ReceiverTotal=7; ReceiverLog="A".
 * @Provenance Extra: default ReceiverTotal=0 empty log, WasBoundAfterUnbind starts true until BeginPlay.
 * @Provenance FixtureIsolated. Targeted Unbind does not deliver the second Broadcast(11, "B").
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
