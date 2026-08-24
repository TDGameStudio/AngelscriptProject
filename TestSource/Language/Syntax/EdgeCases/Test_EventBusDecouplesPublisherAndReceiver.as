// Theme: Language.Syntax.EdgeCases. WorldStory publisher/receiver Unbind.
// C++: AngelscriptCoverageEventTests.cpp::EventBusDecouplesPublisherAndReceiver
// sha256=e38d77501b547a96d2e0cbc02eb2ac8eab0928eb210162fdcca828400f6479be; lines 1615-1672.
// Oracle: WasBoundBeforeUnbind=true; WasBoundAfterUnbind=false; ReceiverTotal=7; ReceiverLog="A".
// Extra: default ReceiverTotal=0 empty log, WasBoundAfterUnbind starts true until BeginPlay.
// FixtureIsolated. Targeted Unbind does not deliver the second Broadcast(11, "B").

event void FCoverageEventBusMessage(int Value, const FString& Label);

UCLASS()
class UCoverageEventBusReceiver : UObject
{
	UPROPERTY()
	int Total = 0;

	UPROPERTY()
	FString Log;

	UFUNCTION()
	void HandleMessage(int Value, const FString& Label)
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
}

bool Observe_EventBus_DefaultEmpty(ACoverageEventBusActor Actor)
{
	if (Actor is null)
	{
		throw("Test_EventBusDecouplesPublisherAndReceiver setup: required Actor is null");
	}
	return Actor.ReceiverTotal == 0 && Actor.ReceiverLog.Len() == 0 && !Actor.WasBoundBeforeUnbind && Actor.WasBoundAfterUnbind && Actor.Receiver == nullptr;
}
