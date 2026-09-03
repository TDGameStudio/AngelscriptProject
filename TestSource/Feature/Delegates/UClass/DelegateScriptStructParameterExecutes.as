/**
 * A script USTRUCT passed through Execute. After BeginPlay, DelegateWasBound is
 * true and Result is 42 (19+23). An empty payload sums to 0.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DelegateScriptStructParameterExecutes
 * @Harness UClass
 * @Tag Feature.Delegates.DelegateScriptStructParameterExecutes
 * @Provenance Theme: Feature.Delegates. WorldStory script USTRUCT passed through Execute.
 * @Provenance C++: AngelscriptCoverageDelegateTests.cpp::DelegateScriptStructParameterExecutes
 * @Provenance Oracle after BeginPlay: DelegateWasBound==true, Result==42 (19+23).
 * @Provenance Extra: empty actor is null; pre-BeginPlay Result==0 / DelegateWasBound==false;
 * @Provenance empty payload sums to 0. FixtureIsolated.
 */

USTRUCT()
struct FCoverageDelegatePayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;
}

/**
 * A unicast that takes a script struct payload.
 *
 * @Covers Delegates.Execute
 * @Inputs Payload
 * @Return an int from the bound handler
 */
delegate int FCoverageDelegatePayloadCallback(FCoverageDelegatePayload Payload);

UCLASS()
class ACoverageDelegateScriptStructActor : AActor
{
	UPROPERTY()
	int Result = 0;

	UPROPERTY()
	bool DelegateWasBound = false;

	/**
	 * Binds HandlePayload and executes a 19/23 payload.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Execute
	 * @Inputs none
	 * @Return nothing; Result ends at 42
	 */
	UFUNCTION(BlueprintOverride)
	void BeginPlay()
	{
		FCoverageDelegatePayload Payload;
		Payload.Value = 19;
		Payload.Bonus = 23;

		FCoverageDelegatePayloadCallback Callback;
		Callback.BindUFunction(this, n"HandlePayload");
		DelegateWasBound = Callback.IsBound();
		Result = Callback.Execute(Payload);
	}

	/**
	 * Returns Value plus Bonus.
	 *
	 * @Covers Delegates.Execute
	 * @Param Payload the struct payload
	 * @Inputs Payload.Value and Payload.Bonus
	 * @Return Value + Bonus
	 */
	UFUNCTION()
	int HandlePayload(FCoverageDelegatePayload Payload)
	{
		return Payload.Value + Payload.Bonus;
	}

	/**
	 * Observe that a default-constructed actor handle is null.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a local ACoverageDelegateScriptStructActor
	 * @Return true when the handle is null
	 * @Boundary empty default
	 */
	UFUNCTION()
	bool EmptyDefaultIsNull()
	{
		ACoverageDelegateScriptStructActor Actor;
		return Actor == nullptr;
	}

	/**
	 * Observe the pre-BeginPlay Result.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs this
	 * @Return 0
	 * @Boundary default Result
	 */
	UFUNCTION()
	int ResultDefault()
	{
		return Result;
	}

	/**
	 * Observe that an empty payload sums to 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Execute
	 * @Inputs a default FCoverageDelegatePayload
	 * @Return 0
	 * @Boundary empty payload
	 */
	UFUNCTION()
	int EmptyPayloadSum()
	{
		FCoverageDelegatePayload Empty;
		return Empty.Value + Empty.Bonus;
	}
}
