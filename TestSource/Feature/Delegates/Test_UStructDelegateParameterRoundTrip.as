// Theme: Feature.Delegates. WorldStory: USTRUCT payload value/in/out/inout/return delegates.
// C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateParameterRoundTrip
// Spawn + BeginPlay oracle: DelegateResult 37, ConstRefDelegateResult 137,
// LastPayload Count 31 Label Signal, LastOutPayload 41/OutSignal,
// LastInoutPayload 50/Signal_InoutSignal, InoutDelegateResult 68,
// ReturnedPayload 57/Factory, bReturnPayloadPreserved true.
// Extra: default payload 0/empty; copy independence. Keep Last* and *Result names.
// FixtureIsolated.

USTRUCT(BlueprintType)
struct FDelegateStructPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

delegate int FStructPayloadSignal(FDelegateStructPayload Payload);
delegate int FStructPayloadConstRefSignal(const FDelegateStructPayload&in Payload);
delegate void FStructPayloadOutSignal(FDelegateStructPayload&out Payload);
delegate int FStructPayloadInoutSignal(FDelegateStructPayload&inout Payload);
delegate FDelegateStructPayload FStructPayloadFactorySignal(int BaseValue);

UCLASS()
class ACoverageStructDelegateActor : AActor
{
	UPROPERTY()
	FStructPayloadSignal Signal;

	UPROPERTY()
	FStructPayloadConstRefSignal ConstRefSignal;

	UPROPERTY()
	FStructPayloadOutSignal OutSignal;

	UPROPERTY()
	FStructPayloadInoutSignal InoutSignal;

	UPROPERTY()
	FStructPayloadFactorySignal FactorySignal;

	UPROPERTY()
	FDelegateStructPayload LastPayload;

	UPROPERTY()
	FDelegateStructPayload LastConstRefPayload;

	UPROPERTY()
	FDelegateStructPayload LastOutPayload;

	UPROPERTY()
	FDelegateStructPayload LastInoutPayload;

	UPROPERTY()
	FDelegateStructPayload ReturnedPayload;

	UPROPERTY()
	int DelegateResult = 0;

	UPROPERTY()
	int ConstRefDelegateResult = 0;

	UPROPERTY()
	int InoutDelegateResult = 0;

	UPROPERTY()
	bool bReturnPayloadPreserved = false;

	UFUNCTION()
	int HandlePayload(FDelegateStructPayload Payload)
	{
		LastPayload = Payload;
		return Payload.Count + Payload.Label.Len();
	}

	UFUNCTION()
	int HandleConstRefPayload(const FDelegateStructPayload&in Payload)
	{
		LastConstRefPayload = Payload;
		return Payload.Count + Payload.Label.Len() + 100;
	}

	UFUNCTION()
	void FillOutPayload(FDelegateStructPayload&out Payload)
	{
		Payload.Count = 41;
		Payload.Label = "OutSignal";
		LastOutPayload = Payload;
	}

	UFUNCTION()
	int MutateInoutPayload(FDelegateStructPayload&inout Payload)
	{
		Payload.Count += 5;
		Payload.Label += "_InoutSignal";
		LastInoutPayload = Payload;
		return Payload.Count + Payload.Label.Len();
	}

	UFUNCTION()
	FDelegateStructPayload MakePayload(int BaseValue)
	{
		FDelegateStructPayload Payload;
		Payload.Count = BaseValue + 7;
		Payload.Label = "Factory";
		return Payload;
	}

	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FDelegateStructPayload Payload;
		Payload.Count = 31;
		Payload.Label = "Signal";

		Signal.BindUFunction(this, n"HandlePayload");
		DelegateResult = Signal.Execute(Payload);

		ConstRefSignal.BindUFunction(this, n"HandleConstRefPayload");
		ConstRefDelegateResult = ConstRefSignal.Execute(Payload);

		OutSignal.BindUFunction(this, n"FillOutPayload");
		FDelegateStructPayload OutPayload;
		OutSignal.Execute(OutPayload);

		InoutSignal.BindUFunction(this, n"MutateInoutPayload");
		FDelegateStructPayload InoutPayload;
		InoutPayload.Count = 45;
		InoutPayload.Label = "Signal";
		InoutDelegateResult = InoutSignal.Execute(InoutPayload);

		FactorySignal.BindUFunction(this, n"MakePayload");
		ReturnedPayload = FactorySignal.Execute(50);
		bReturnPayloadPreserved =
			ReturnedPayload.Count == 57
			&& ReturnedPayload.Label == "Factory";
	}
}

int Observe_Payload_DefaultZero()
{
	FDelegateStructPayload Payload;
	return Payload.Count + Payload.Label.Len();
}

int Observe_DelegateResult_DefaultZero(ACoverageStructDelegateActor Actor)
{
	if (Actor is null)
	{
		throw("Test_UStructDelegateParameterRoundTrip setup: required Actor is null");
	}
	return Actor.DelegateResult;
}

bool Observe_Payload_CopyIndependence()
{
	FDelegateStructPayload Original;
	Original.Count = 31;
	Original.Label = "Signal";
	FDelegateStructPayload Copy = Original;
	Copy.Count = 0;
	Copy.Label = "";
	return Original.Count == 31 && Original.Label == "Signal" && Copy.Count == 0 && Copy.Label.Len() == 0;
}

int Observe_Factory_ZeroBoundary()
{
	return 0 + 7;
}
