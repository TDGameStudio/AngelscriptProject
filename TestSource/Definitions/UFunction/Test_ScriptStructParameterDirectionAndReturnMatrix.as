// Theme: Definitions.UFunction. WorldStory: AS USTRUCT value/const-ref/out/inout/return.
// C++: AngelscriptCoverageUFunctionTests.cpp::ScriptStructParameterDirectionAndReturnMatrix
// Oracle: AcceptValue(Count 37, "Value")==42; AcceptConstRef(Count 34, "ConstRef")==42;
// FillOut writes 42/"OutPayload"; MutateInout(10,"Input") returns 42 and bInoutSawOriginal true;
// ReturnPayload Count 42 Label ReturnPayload.
// Extra: empty value scores 0; default bInoutSawOriginal false; mutating the input copy
// does not change LastValue (copy independence).
// FixtureIsolated. Runner owns World teardown.

USTRUCT(BlueprintType)
struct FUFunctionDirectionPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageUFunctionStructDirectionActor : AActor
{
	UPROPERTY()
	FUFunctionDirectionPayload LastValue;

	UPROPERTY()
	FUFunctionDirectionPayload LastConstRef;

	UPROPERTY()
	bool bInoutSawOriginal = false;

	UFUNCTION(BlueprintCallable, Category="Coverage|StructDirections")
	int AcceptValue(FUFunctionDirectionPayload Payload)
	{
		LastValue = Payload;
		return Payload.Count + Payload.Label.Len();
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|StructDirections")
	int AcceptConstRef(const FUFunctionDirectionPayload&in Payload)
	{
		LastConstRef = Payload;
		return Payload.Count + Payload.Label.Len();
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|StructDirections")
	void FillOut(FUFunctionDirectionPayload&out Payload)
	{
		Payload.Count = 42;
		Payload.Label = "OutPayload";
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|StructDirections")
	int MutateInout(FUFunctionDirectionPayload&inout Payload)
	{
		bInoutSawOriginal = Payload.Count == 10 && Payload.Label == "Input";
		Payload.Count += 19;
		Payload.Label += "|Mutated";
		return Payload.Count + Payload.Label.Len();
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|StructDirections")
	FUFunctionDirectionPayload ReturnPayload()
	{
		FUFunctionDirectionPayload Payload;
		Payload.Count = 42;
		Payload.Label = "ReturnPayload";
		return Payload;
	}
}

int Observe_StructDir_AcceptValue42(ACoverageUFunctionStructDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ScriptStructParameterDirectionAndReturnMatrix setup: required Actor is null");
	}
	FUFunctionDirectionPayload Payload;
	Payload.Count = 37;
	Payload.Label = "Value";
	return Actor.AcceptValue(Payload);
}

int Observe_StructDir_AcceptConstRef42(ACoverageUFunctionStructDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ScriptStructParameterDirectionAndReturnMatrix setup: required Actor is null");
	}
	FUFunctionDirectionPayload Payload;
	Payload.Count = 34;
	Payload.Label = "ConstRef";
	return Actor.AcceptConstRef(Payload);
}

int Observe_StructDir_EmptyValue(ACoverageUFunctionStructDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ScriptStructParameterDirectionAndReturnMatrix setup: required Actor is null");
	}
	FUFunctionDirectionPayload Payload;
	return Actor.AcceptValue(Payload);
}

bool Observe_StructDir_FillOut(ACoverageUFunctionStructDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ScriptStructParameterDirectionAndReturnMatrix setup: required Actor is null");
	}
	FUFunctionDirectionPayload Payload;
	Actor.FillOut(Payload);
	return Payload.Count == 42 && Payload.Label == "OutPayload";
}

int Observe_StructDir_MutateInout(ACoverageUFunctionStructDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ScriptStructParameterDirectionAndReturnMatrix setup: required Actor is null");
	}
	FUFunctionDirectionPayload Payload;
	Payload.Count = 10;
	Payload.Label = "Input";
	int Result = Actor.MutateInout(Payload);
	if (!Actor.bInoutSawOriginal || Payload.Count != 29 || Payload.Label != "Input|Mutated")
	{
		return -1;
	}
	return Result;
}

bool Observe_StructDir_ReturnPayload(ACoverageUFunctionStructDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ScriptStructParameterDirectionAndReturnMatrix setup: required Actor is null");
	}
	FUFunctionDirectionPayload Payload = Actor.ReturnPayload();
	return Payload.Count == 42 && Payload.Label == "ReturnPayload";
}

bool Observe_StructDir_DefaultInoutFlag(ACoverageUFunctionStructDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ScriptStructParameterDirectionAndReturnMatrix setup: required Actor is null");
	}
	return !Actor.bInoutSawOriginal;
}

bool Observe_StructDir_CopyIndependence(ACoverageUFunctionStructDirectionActor Actor)
{
	if (Actor is null)
	{
		throw("Test_ScriptStructParameterDirectionAndReturnMatrix setup: required Actor is null");
	}
	FUFunctionDirectionPayload First;
	First.Count = 37;
	First.Label = "Value";
	Actor.AcceptValue(First);
	First.Count = 0;
	First.Label = "";
	return Actor.LastValue.Count == 37 && Actor.LastValue.Label == "Value";
}
