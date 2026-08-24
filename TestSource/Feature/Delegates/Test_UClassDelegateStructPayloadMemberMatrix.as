// Theme: Feature.Delegates. WorldStory: USTRUCT payload through compute and multicast.
// C++: AngelscriptCoverageUClassPropertyTests.cpp::UClassDelegateStructPayloadMemberMatrix
// Spawn + BeginPlay oracle: bPayloadComputeBound true, ComputePayloadValue 19, Bonus 23,
// Tag Compute, ComputePayloadResult 42; signal Value 29 Bonus 31 Tag Signal Result 60.
// Extra: default payload 0/empty name; copy independence. Keep ComputePayload* / SignalPayload*.
// FixtureIsolated.

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

delegate int FUClassPropertyPayloadComputeDelegate(FUClassPropertyDelegatePayload Payload);
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

	FUClassPropertyDelegatePayload MakePayload(int Value, int Bonus, FName Tag)
	{
		FUClassPropertyDelegatePayload Payload;
		Payload.Value = Value;
		Payload.Bonus = Bonus;
		Payload.Tag = Tag;
		return Payload;
	}

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

	UFUNCTION()
	int HandlePayloadCompute(FUClassPropertyDelegatePayload Payload)
	{
		ComputePayloadValue = Payload.Value;
		ComputePayloadBonus = Payload.Bonus;
		ComputePayloadTag = Payload.Tag;
		return Payload.Value + Payload.Bonus;
	}

	UFUNCTION()
	void HandlePayloadSignal(FUClassPropertyDelegatePayload Payload)
	{
		SignalPayloadValue = Payload.Value;
		SignalPayloadBonus = Payload.Bonus;
		SignalPayloadTag = Payload.Tag;
		SignalPayloadResult = Payload.Value + Payload.Bonus;
	}
}

int Observe_Payload_DefaultZero()
{
	FUClassPropertyDelegatePayload Payload;
	return Payload.Value + Payload.Bonus;
}

int Observe_ComputePayloadResult_DefaultZero(ACoverageUClassDelegateStructPayloadActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UClassDelegateStructPayloadMemberMatrix setup: required Actor is null");
	}
	return Actor.ComputePayloadResult;
}

bool Observe_Payload_CopyIndependence()
{
	FUClassPropertyDelegatePayload Original;
	Original.Value = 19;
	Original.Bonus = 23;
	Original.Tag = n"Compute";
	FUClassPropertyDelegatePayload Copy = Original;
	Copy.Value = 0;
	Copy.Bonus = 0;
	Copy.Tag = n"";
	return Original.Value == 19 && Original.Bonus == 23 && Original.Tag == n"Compute"
		&& Copy.Value == 0 && Copy.Bonus == 0;
}
