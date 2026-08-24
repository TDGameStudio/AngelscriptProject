// Theme: Definitions.UFunction. WorldStory: mixed UObject/FName/FText/FVector/USTRUCT/default int.
// C++: AngelscriptCoverageUFunctionTests.cpp::MixedParameterReflectionAndRuntimeCall
// Oracle: AcceptMixedParameters(this, InputName, InputText, (3,4,5), Count 11 Label PayloadLabel, 7)
// returns 21 LastScore 21 LastLabel PayloadLabel:InputText LastName InputName LastVector (3,4,5).
// FillMixedOut writes GeneratedName / GeneratedText / (9,8,7) / Count 44 Label GeneratedPayload.
// Extra: default Score 5 with empty payload/zero vector/null object; default LastScore 0 LastName None.
// FixtureIsolated. Runner owns World teardown.

USTRUCT(BlueprintType)
struct FUFunctionPayload
{
	UPROPERTY()
	int Count = 0;

	UPROPERTY()
	FString Label;
}

UCLASS()
class ACoverageUFunctionMixedParameterActor : AActor
{
	UPROPERTY()
	int LastScore = 0;

	UPROPERTY()
	FString LastLabel;

	UPROPERTY()
	FName LastName = NAME_None;

	UPROPERTY()
	FText LastText;

	UPROPERTY()
	FVector LastVector = FVector::ZeroVector;

	UPROPERTY()
	UObject LastObject;

	UPROPERTY()
	FUFunctionPayload LastPayload;

	UFUNCTION(BlueprintCallable, Category="Coverage|MixedParameters")
	int AcceptMixedParameters(UObject ObjectValue, FName NameValue, const FText&in TextValue, FVector VectorValue, const FUFunctionPayload&in Payload, int Score = 5)
	{
		LastObject = ObjectValue;
		LastName = NameValue;
		LastText = TextValue;
		LastVector = VectorValue;
		LastPayload = Payload;
		LastScore = Score + Payload.Count + int(VectorValue.X);
		LastLabel = Payload.Label + ":" + TextValue.ToString();
		return LastScore;
	}

	UFUNCTION(BlueprintCallable, Category="Coverage|MixedParameters")
	void FillMixedOut(FName&out OutName, FText&out OutText, FVector&out OutVector, FUFunctionPayload&out OutPayload)
	{
		OutName = n"GeneratedName";
		OutText = FText::FromString("GeneratedText");
		OutVector = FVector(9.0, 8.0, 7.0);
		OutPayload.Count = 44;
		OutPayload.Label = "GeneratedPayload";
	}
}

int Observe_Mixed_AcceptNominal21(ACoverageUFunctionMixedParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedParameterReflectionAndRuntimeCall setup: required Actor is null");
	}
	FUFunctionPayload Payload;
	Payload.Count = 11;
	Payload.Label = "PayloadLabel";
	return Actor.AcceptMixedParameters(
		Actor,
		n"InputName",
		FText::FromString("InputText"),
		FVector(3.0, 4.0, 5.0),
		Payload,
		7);
}

bool Observe_Mixed_AcceptState(ACoverageUFunctionMixedParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedParameterReflectionAndRuntimeCall setup: required Actor is null");
	}
	FUFunctionPayload Payload;
	Payload.Count = 11;
	Payload.Label = "PayloadLabel";
	Actor.AcceptMixedParameters(
		Actor,
		n"InputName",
		FText::FromString("InputText"),
		FVector(3.0, 4.0, 5.0),
		Payload,
		7);
	return Actor.LastScore == 21
		&& Actor.LastLabel == "PayloadLabel:InputText"
		&& Actor.LastName == n"InputName"
		&& Actor.LastVector.X == 3.0
		&& Actor.LastVector.Y == 4.0
		&& Actor.LastVector.Z == 5.0
		&& Actor.LastObject == Actor
		&& Actor.LastPayload.Count == 11;
}

bool Observe_Mixed_FillOut(ACoverageUFunctionMixedParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedParameterReflectionAndRuntimeCall setup: required Actor is null");
	}
	FName OutName = NAME_None;
	FText OutText;
	FVector OutVector = FVector::ZeroVector;
	FUFunctionPayload OutPayload;
	Actor.FillMixedOut(OutName, OutText, OutVector, OutPayload);
	return OutName == n"GeneratedName"
		&& OutText.ToString() == "GeneratedText"
		&& OutVector.X == 9.0
		&& OutVector.Y == 8.0
		&& OutVector.Z == 7.0
		&& OutPayload.Count == 44
		&& OutPayload.Label == "GeneratedPayload";
}

int Observe_Mixed_DefaultScoreOmitted(ACoverageUFunctionMixedParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedParameterReflectionAndRuntimeCall setup: required Actor is null");
	}
	FUFunctionPayload Payload;
	return Actor.AcceptMixedParameters(nullptr, NAME_None, FText::FromString(""), FVector::ZeroVector, Payload);
}

int Observe_Mixed_DefaultLastScore(ACoverageUFunctionMixedParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedParameterReflectionAndRuntimeCall setup: required Actor is null");
	}
	return Actor.LastScore;
}

bool Observe_Mixed_DefaultLastNameNone(ACoverageUFunctionMixedParameterActor Actor)
{
	if (Actor is null)
	{
		throw("Test_MixedParameterReflectionAndRuntimeCall setup: required Actor is null");
	}
	return Actor.LastName == NAME_None && Actor.LastObject == nullptr;
}
