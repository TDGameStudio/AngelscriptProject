// Theme: Definitions.UFunction. WorldStory: USTRUCT UFUNCTION return payload.
// C++: AngelscriptCoverageUStructTests.cpp::UStructUFunctionReturnInvocation
// CompileScriptModule then spawn + FFunctionInvoker MakePayload(35, "Payload").
// Keep LastReturned. Oracle: Count 42, Label "Payload_Returned", Location (35, 36, 37).
// Extra: empty payload defaults; BaseValue 0 / empty Label is the zero boundary.
// FixtureIsolated. Runner owns spawn.

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

	UFUNCTION(BlueprintCallable)
	FReturnedStructPayload MakePayload(int BaseValue, const FString& Label)
	{
		FReturnedStructPayload Payload;
		Payload.Count = BaseValue + 7;
		Payload.Label = Label + "_Returned";
		Payload.Location = FVector(BaseValue, BaseValue + 1, BaseValue + 2);
		LastReturned = Payload;
		return Payload;
	}
}

bool Observe_ReturnedStructPayload_EmptyDefault()
{
	FReturnedStructPayload Payload;
	return Payload.Count == 0
		&& Payload.Label == ""
		&& Payload.Location.X == 0.0
		&& Payload.Location.Y == 0.0
		&& Payload.Location.Z == 0.0;
}

bool Observe_MakePayload_Nominal(ACoverageStructUFunctionReturnActor Actor)
{
	FReturnedStructPayload Payload = Actor.MakePayload(35, "Payload");
	return Payload.Count == 42
		&& Payload.Label == "Payload_Returned"
		&& Payload.Location.X == 35.0
		&& Payload.Location.Y == 36.0
		&& Payload.Location.Z == 37.0
		&& Actor.LastReturned.Count == 42
		&& Actor.LastReturned.Label == "Payload_Returned";
}

bool Observe_MakePayload_ZeroBoundary(ACoverageStructUFunctionReturnActor Actor)
{
	FReturnedStructPayload Payload = Actor.MakePayload(0, "");
	return Payload.Count == 7
		&& Payload.Label == "_Returned"
		&& Payload.Location.X == 0.0
		&& Payload.Location.Y == 1.0
		&& Payload.Location.Z == 2.0;
}

bool Observe_MakePayload_CopyIndependence(ACoverageStructUFunctionReturnActor Actor)
{
	FReturnedStructPayload First = Actor.MakePayload(35, "Payload");
	FReturnedStructPayload Second = First;
	First.Count = 0;
	First.Label = "";
	return Second.Count == 42 && Second.Label == "Payload_Returned";
}
