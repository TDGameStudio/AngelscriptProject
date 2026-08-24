// Theme: Feature.Delegates. WorldStory: USTRUCT payload crosses a multicast event.
// C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateStructPayloadPropertyExecutes
// Spawn + BeginPlay oracle: EventWasBound==true, ReceivedValue==19, ReceivedBonus==23, Result==42.
// Extra: default payload 0/0; copy independence of Value/Bonus. Keep Result and Received*.
// FixtureIsolated.

USTRUCT()
struct FCoverageDynamicPayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;
}

event void FCoverageDynamicPayloadEvent(FCoverageDynamicPayload Payload);

UCLASS()
class ACoverageDynamicStructPayloadActor : AActor
{
	UPROPERTY()
	FCoverageDynamicPayloadEvent OnPayload;

	UPROPERTY()
	int ReceivedValue = 0;

	UPROPERTY()
	int ReceivedBonus = 0;

	UPROPERTY()
	int Result = 0;

	UPROPERTY()
	bool EventWasBound = false;

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		OnPayload.AddUFunction(this, n"HandlePayload");
		EventWasBound = OnPayload.IsBound();

		FCoverageDynamicPayload Payload;
		Payload.Value = 19;
		Payload.Bonus = 23;
		OnPayload.Broadcast(Payload);
	}

	UFUNCTION()
	void HandlePayload(FCoverageDynamicPayload Payload)
	{
		ReceivedValue = Payload.Value;
		ReceivedBonus = Payload.Bonus;
		Result = Payload.Value + Payload.Bonus;
	}
}

int Observe_Payload_DefaultZero()
{
	FCoverageDynamicPayload Payload;
	return Payload.Value + Payload.Bonus;
}

bool Observe_EventWasBound_DefaultFalse(ACoverageDynamicStructPayloadActor Actor)
{
	if (Actor is null)
	{
		throw("Test_DynamicDelegateStructPayloadPropertyExecutes setup: required Actor is null");
	}
	return !Actor.EventWasBound;
}

bool Observe_Payload_CopyIndependence()
{
	FCoverageDynamicPayload Original;
	Original.Value = 19;
	Original.Bonus = 23;
	FCoverageDynamicPayload Copy = Original;
	Copy.Value = 0;
	Copy.Bonus = 0;
	return Original.Value == 19 && Original.Bonus == 23 && Copy.Value == 0 && Copy.Bonus == 0;
}
