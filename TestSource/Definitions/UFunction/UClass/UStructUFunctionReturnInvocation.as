/**
 * A USTRUCT UFUNCTION return payload. MakePayload(35, "Payload") writes Count
 * 42, Label "Payload_Returned", and Location (35, 36, 37) into LastReturned.
 * Empty payload defaults are 0 / empty / zero vector. BaseValue 0 / empty
 * Label is the zero boundary.
 *
 * @Theme Definitions.UFunction
 * @Subject UFunction.UStructUFunctionReturnInvocation
 * @Harness UClass
 * @Tag Definitions.UFunction.UStructUFunctionReturnInvocation
 * @Provenance Theme: Definitions.UFunction. WorldStory: USTRUCT UFUNCTION return payload.
 * @Provenance C++: AngelscriptCoverageUStructTests.cpp::UStructUFunctionReturnInvocation
 * @Provenance CompileScriptModule then spawn + FFunctionInvoker MakePayload(35, "Payload").
 * @Provenance Keep LastReturned. Oracle: Count 42, Label "Payload_Returned", Location (35, 36, 37).
 * @Provenance Extra: empty payload defaults; BaseValue 0 / empty Label is the zero boundary.
 * @Provenance FixtureIsolated. Runner owns spawn.
 */

USTRUCT(BlueprintType)
struct FReturnedStructPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;

	UPROPERTY()
	FVector Location;
}

UCLASS()
class ACoverageStructUFunctionReturnActor : AActor
{
	UPROPERTY()
	FReturnedStructPayload LastReturned;

	/**
	 * Build a payload from BaseValue and Label and store it in LastReturned.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Param BaseValue Count offset and Location X
	 * @Param Label Label prefix received as const FString&in
	 * @Inputs BaseValue and Label
	 * @Return a payload with Count BaseValue+7 and Label+"_Returned"
	 */
	UFUNCTION(BlueprintCallable)
	FReturnedStructPayload MakePayload(int BaseValue, const FString&in Label)
	{
		FReturnedStructPayload Payload;
		Payload.Count = BaseValue + 7;
		Payload.Label = Label + "_Returned";
		Payload.Location = FVector(BaseValue, BaseValue + 1, BaseValue + 2);
		LastReturned = Payload;
		return Payload;
	}

	/**
	 * Observe the default FReturnedStructPayload.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs a default-constructed FReturnedStructPayload
	 * @Return true when Count is 0, Label is empty, and Location is zero
	 * @Boundary default payload
	 */
	UFUNCTION()
	bool ReturnedStructPayloadEmptyDefault()
	{
		FReturnedStructPayload Payload;
		if (Payload.Count != 0)
		{
			return false;
		}
		if (Payload.Label != "")
		{
			return false;
		}
		if (Payload.Location.X != 0.0)
		{
			return false;
		}
		if (Payload.Location.Y != 0.0)
		{
			return false;
		}
		return Payload.Location.Z == 0.0;
	}

	/**
	 * Observe MakePayload(35, "Payload").
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs MakePayload(35, "Payload")
	 * @Return true when Count is 42, Label is Payload_Returned, and Location is (35,36,37)
	 */
	UFUNCTION()
	bool MakePayloadThirtyFive()
	{
		FReturnedStructPayload Payload = MakePayload(35, "Payload");
		if (Payload.Count != 42)
		{
			return false;
		}
		if (Payload.Label != "Payload_Returned")
		{
			return false;
		}
		if (Payload.Location.X != 35.0)
		{
			return false;
		}
		if (Payload.Location.Y != 36.0)
		{
			return false;
		}
		if (Payload.Location.Z != 37.0)
		{
			return false;
		}
		if (LastReturned.Count != 42)
		{
			return false;
		}
		return LastReturned.Label == "Payload_Returned";
	}

	/**
	 * Observe MakePayload(0, "") as the zero boundary.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs MakePayload(0, "")
	 * @Return true when Count is 7, Label is _Returned, and Location is (0,1,2)
	 * @Boundary zero base and empty label
	 */
	UFUNCTION()
	bool MakePayloadZeroBoundary()
	{
		FReturnedStructPayload Payload = MakePayload(0, "");
		if (Payload.Count != 7)
		{
			return false;
		}
		if (Payload.Label != "_Returned")
		{
			return false;
		}
		if (Payload.Location.X != 0.0)
		{
			return false;
		}
		if (Payload.Location.Y != 1.0)
		{
			return false;
		}
		return Payload.Location.Z == 2.0;
	}

	/**
	 * Observe that mutating a returned payload copy leaves the other copy intact.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Return
	 * @Inputs MakePayload(35, "Payload") then mutate the first copy
	 * @Return true when the second copy stays 42 / Payload_Returned
	 */
	UFUNCTION()
	bool MakePayloadCopyIndependence()
	{
		FReturnedStructPayload First = MakePayload(35, "Payload");
		FReturnedStructPayload Second = First;
		First.Count = 0;
		First.Label = "";
		if (Second.Count != 42)
		{
			return false;
		}
		return Second.Label == "Payload_Returned";
	}
}
