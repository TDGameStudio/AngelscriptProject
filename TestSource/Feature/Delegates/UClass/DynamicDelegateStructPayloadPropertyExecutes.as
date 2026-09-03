/**
 * A USTRUCT payload crosses a multicast event. After BeginPlay, EventWasBound
 * is true, ReceivedValue is 19, ReceivedBonus is 23, and Result is 42.
 *
 * @Theme Feature.Delegates
 * @Subject Delegates.DynamicDelegateStructPayloadPropertyExecutes
 * @Harness UClass
 * @Tag Feature.Delegates.DynamicDelegateStructPayloadPropertyExecutes
 * @Provenance Theme: Feature.Delegates. WorldStory: USTRUCT payload crosses a multicast event.
 * @Provenance C++: AngelscriptCoverageDynamicDelegateTests.cpp::DynamicDelegateStructPayloadPropertyExecutes
 * @Provenance Spawn + BeginPlay oracle: EventWasBound==true, ReceivedValue==19, ReceivedBonus==23, Result==42.
 * @Provenance Extra: default payload 0/0; copy independence of Value/Bonus. Keep Result and Received*.
 * @Provenance FixtureIsolated.
 */

USTRUCT()
struct FCoverageDynamicPayload
{
	UPROPERTY()
	int Value = 0;

	UPROPERTY()
	int Bonus = 0;
}

/**
 * A multicast that takes a dynamic struct payload.
 *
 * @Covers Delegates.Dynamic
 * @Inputs Payload
 * @Return nothing when broadcast
 */
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

	/**
	 * Binds HandlePayload and broadcasts a 19/23 payload.
	 *
	 * @Kind WorldStory
	 * @Covers Delegates.Dynamic
	 * @Inputs none
	 * @Return nothing; Result ends at 42
	 */
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

	/**
	 * Stores Value, Bonus, and their sum.
	 *
	 * @Covers Delegates.Dynamic
	 * @Param Payload the struct payload
	 * @Inputs Payload.Value and Payload.Bonus
	 * @Return nothing; Result is Value + Bonus
	 */
	UFUNCTION()
	void HandlePayload(FCoverageDynamicPayload Payload)
	{
		ReceivedValue = Payload.Value;
		ReceivedBonus = Payload.Bonus;
		Result = Payload.Value + Payload.Bonus;
	}

	/**
	 * Observe that a default payload sums to 0.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs a default FCoverageDynamicPayload
	 * @Return 0
	 * @Boundary default payload
	 */
	UFUNCTION()
	int PayloadDefaultZero()
	{
		FCoverageDynamicPayload Payload;
		return Payload.Value + Payload.Bonus;
	}

	/**
	 * Observe that EventWasBound starts false.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs this
	 * @Return true when EventWasBound is false
	 * @Boundary default unbound
	 */
	UFUNCTION()
	bool EventWasBoundDefaultFalse()
	{
		return !EventWasBound;
	}

	/**
	 * Observe that copying a payload and clearing the copy leaves the original.
	 *
	 * @Kind Observe
	 * @Covers Delegates.Dynamic
	 * @Inputs Original 19/23; Copy cleared
	 * @Return true when Original stays 19/23 and Copy is 0/0
	 * @Boundary copy independence
	 */
	UFUNCTION()
	bool PayloadCopyIndependence()
	{
		FCoverageDynamicPayload Original;
		Original.Value = 19;
		Original.Bonus = 23;
		FCoverageDynamicPayload Copy = Original;
		Copy.Value = 0;
		Copy.Bonus = 0;
		if (Original.Value != 19)
		{
			return false;
		}
		if (Original.Bonus != 23)
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
