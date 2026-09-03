/**
 * USTRUCT payload value/in/out/inout/return delegates. After BeginPlay,
 * DelegateResult 37, ConstRefDelegateResult 137, LastPayload Count 31 Label
 * Signal, LastOutPayload 41/OutSignal, LastInoutPayload 50/Signal_InoutSignal,
 * InoutDelegateResult 68, ReturnedPayload 57/Factory, bReturnPayloadPreserved
 * true. Default payload 0/empty. Copy independence.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.UStructDelegateParameterRoundTrip
 * @Harness UClass
 * @Tag Feature.Delegates.UStructDelegateParameterRoundTrip
 * @Provenance Theme: Feature.Delegates. WorldStory: USTRUCT payload value/in/out/inout/return delegates.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructDelegateParameterRoundTrip
 * @Provenance Spawn + BeginPlay oracle: DelegateResult 37, ConstRefDelegateResult 137,
 * @Provenance LastPayload Count 31 Label Signal, LastOutPayload 41/OutSignal,
 * @Provenance LastInoutPayload 50/Signal_InoutSignal, InoutDelegateResult 68,
 * @Provenance ReturnedPayload 57/Factory, bReturnPayloadPreserved true.
 * @Provenance Extra: default payload 0/empty; copy independence. Keep Last* and *Result names.
 * @Provenance FixtureIsolated.
 */

USTRUCT(BlueprintType)
struct FDelegateStructPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

/**
 * A unicast of a struct payload by value.
 *
 * @Covers Delegates.Execute
 * @Inputs Payload
 * @Return int
 */
delegate int FStructPayloadSignal(FDelegateStructPayload Payload);

/**
 * A unicast of a const struct payload &in.
 *
 * @Covers Delegates.Execute
 * @Inputs Payload
 * @Return int
 */
delegate int FStructPayloadConstRefSignal(const FDelegateStructPayload&in Payload);

/**
 * A unicast that fills a struct payload &out.
 *
 * @Covers Delegates.Execute
 * @Inputs Payload
 * @Return void
 */
delegate void FStructPayloadOutSignal(FDelegateStructPayload&out Payload);

/**
 * A unicast that mutates a struct payload &inout.
 *
 * @Covers Delegates.Execute
 * @Inputs Payload
 * @Return int
 */
delegate int FStructPayloadInoutSignal(FDelegateStructPayload&inout Payload);

/**
 * A unicast factory that returns a struct payload.
 *
 * @Covers Delegates.Execute
 * @Inputs BaseValue
 * @Return FDelegateStructPayload
 */
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

	/**
	 * Store LastPayload and return Count + Label.Len().
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Payload Struct received by value
	 * @Inputs Payload
	 * @Return Payload.Count + Payload.Label.Len()
	 */
	UFUNCTION()
	int HandlePayload(FDelegateStructPayload Payload)
	{
		LastPayload = Payload;
		return Payload.Count + Payload.Label.Len();
	}

	/**
	 * Store LastConstRefPayload and return Count + Label.Len() + 100.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Payload Struct received as const FDelegateStructPayload&in
	 * @Inputs Payload
	 * @Return Payload.Count + Payload.Label.Len() + 100
	 */
	UFUNCTION()
	int HandleConstRefPayload(const FDelegateStructPayload&in Payload)
	{
		LastConstRefPayload = Payload;
		return Payload.Count + Payload.Label.Len() + 100;
	}

	/**
	 * Fill an &out payload with 41 / OutSignal.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Payload Struct received as FDelegateStructPayload&out
	 * @Inputs empty Payload
	 * @Return void
	 */
	UFUNCTION()
	void FillOutPayload(FDelegateStructPayload&out Payload)
	{
		Payload.Count = 41;
		Payload.Label = "OutSignal";
		LastOutPayload = Payload;
	}

	/**
	 * Mutate an &inout payload and return Count + Label.Len().
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param Payload Struct received as FDelegateStructPayload&inout
	 * @Inputs Payload
	 * @Return Payload.Count + Payload.Label.Len()
	 */
	UFUNCTION()
	int MutateInoutPayload(FDelegateStructPayload&inout Payload)
	{
		Payload.Count += 5;
		Payload.Label += "_InoutSignal";
		LastInoutPayload = Payload;
		return Payload.Count + Payload.Label.Len();
	}

	/**
	 * Return Count BaseValue+7 Label Factory.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Param BaseValue Integer received by value
	 * @Inputs BaseValue
	 * @Return Count BaseValue+7 Label Factory
	 */
	UFUNCTION()
	FDelegateStructPayload MakePayload(int BaseValue)
	{
		FDelegateStructPayload Payload;
		Payload.Count = BaseValue + 7;
		Payload.Label = "Factory";
		return Payload;
	}

	/**
	 * WorldStory: BeginPlay binds and executes value/in/out/inout/return payload delegates.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return DelegateResult 37, ConstRefDelegateResult 137, ReturnedPayload 57/Factory
	 */
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

	/**
	 * Observe a default payload Count + Label.Len().
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
		FDelegateStructPayload Payload;
		return Payload.Count + Payload.Label.Len();
	}

	/**
	 * Observe the default DelegateResult.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default DelegateResult
	 */
	UFUNCTION()
	int DelegateResultDefaultZero()
	{
		return DelegateResult;
	}

	/**
	 * Observe that mutating a payload copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs Original 31/Signal and a zeroed copy
	 * @Return true when Original stays 31/Signal
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool PayloadCopyIndependence()
	{
		FDelegateStructPayload Original;
		Original.Count = 31;
		Original.Label = "Signal";
		FDelegateStructPayload Copy = Original;
		Copy.Count = 0;
		Copy.Label = "";
		if (Original.Count != 31)
		{
			return false;
		}
		if (Original.Label != "Signal")
		{
			return false;
		}
		if (Copy.Count != 0)
		{
			return false;
		}
		return Copy.Label.Len() == 0;
	}

	/**
	 * Observe MakePayload of 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs 0
	 * @Return 7
	 * @Boundary factory zero
	 */
	UFUNCTION()
	int FactoryZeroBoundary()
	{
		return 0 + 7;
	}
}
