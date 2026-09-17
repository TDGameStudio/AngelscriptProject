/**
 * @version v1
 * @summary Mixed UObject/FName/FText/FVector/USTRUCT/default int parameters. AcceptMixedParameters(this, InputName, InputText, (3,4,5), Count 11 Label PayloadLabel, 7) returns 21 LastScore 21 LastLabel PayloadLabel:InputText.
 * @topic Definitions
 */
/**
 * @version root
 * @summary Mixed UObject/FName/FText/FVector/USTRUCT/default int parameters. AcceptMixedParameters(this, InputName, InputText, (3,4,5), Count 11 Label PayloadLabel, 7) returns 21 LastScore 21 LastLabel PayloadLabel:InputText.
 * @topic Baseline
 */
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

	/**
	 * Accept mixed object, name, text, vector, payload, and defaulted score.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param ObjectValue Object received by value
	 * @Param NameValue Name received by value
	 * @Param TextValue Text received as const FText&in
	 * @Param VectorValue Vector received by value
	 * @Param Payload Struct received as const FUFunctionPayload&in
	 * @Param Score Integer, default 5
	 * @Inputs ObjectValue, NameValue, TextValue, VectorValue, Payload, Score
	 * @Return LastScore after writing Last* members
	 */
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

	/**
	 * Fill mixed out name, text, vector, and payload.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Param OutName Name received as FName&out
	 * @Param OutText Text received as FText&out
	 * @Param OutVector Vector received as FVector&out
	 * @Param OutPayload Struct received as FUFunctionPayload&out
	 * @Inputs empty out destinations
	 * @Return void
	 */
	UFUNCTION(BlueprintCallable, Category="Coverage|MixedParameters")
	void FillMixedOut(FName&out OutName, FText&out OutText, FVector&out OutVector, FUFunctionPayload&out OutPayload)
	{
		OutName = n"GeneratedName";
		OutText = FText::FromString("GeneratedText");
		OutVector = FVector(9.0, 8.0, 7.0);
		OutPayload.Count = 44;
		OutPayload.Label = "GeneratedPayload";
	}

	/**
	 * Observe AcceptMixedParameters of the nominal mixed payload scoring 21.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs this, InputName, InputText, (3,4,5), Count 11 Label PayloadLabel, 7
	 * @Return 21
	 */
	UFUNCTION()
	int AcceptNominalTwentyOne()
	{
		FUFunctionPayload Payload;
		Payload.Count = 11;
		Payload.Label = "PayloadLabel";
		return AcceptMixedParameters(
			this,
			n"InputName",
			FText::FromString("InputText"),
			FVector(3.0, 4.0, 5.0),
			Payload,
			7);
	}

	/**
	 * Observe Last* members after the nominal AcceptMixedParameters.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs the nominal mixed payload
	 * @Return true when LastScore 21, LastLabel PayloadLabel:InputText, LastName InputName, LastVector (3,4,5), LastObject this, LastPayload.Count 11
	 */
	UFUNCTION()
	bool AcceptState()
	{
		FUFunctionPayload Payload;
		Payload.Count = 11;
		Payload.Label = "PayloadLabel";
		AcceptMixedParameters(
			this,
			n"InputName",
			FText::FromString("InputText"),
			FVector(3.0, 4.0, 5.0),
			Payload,
			7);
		if (LastScore != 21)
		{
			return false;
		}
		if (LastLabel != "PayloadLabel:InputText")
		{
			return false;
		}
		if (LastName != n"InputName")
		{
			return false;
		}
		if (LastVector.X != 3.0)
		{
			return false;
		}
		if (LastVector.Y != 4.0)
		{
			return false;
		}
		if (LastVector.Z != 5.0)
		{
			return false;
		}
		if (LastObject != this)
		{
			return false;
		}
		return LastPayload.Count == 11;
	}

	/**
	 * Observe FillMixedOut destinations.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs empty out destinations
	 * @Return true when GeneratedName / GeneratedText / (9,8,7) / Count 44 Label GeneratedPayload
	 */
	UFUNCTION()
	bool FillOutState()
	{
		FName OutName = NAME_None;
		FText OutText;
		FVector OutVector = FVector::ZeroVector;
		FUFunctionPayload OutPayload;
		FillMixedOut(OutName, OutText, OutVector, OutPayload);
		if (OutName != n"GeneratedName")
		{
			return false;
		}
		if (OutText.ToString() != "GeneratedText")
		{
			return false;
		}
		if (OutVector.X != 9.0)
		{
			return false;
		}
		if (OutVector.Y != 8.0)
		{
			return false;
		}
		if (OutVector.Z != 7.0)
		{
			return false;
		}
		if (OutPayload.Count != 44)
		{
			return false;
		}
		return OutPayload.Label == "GeneratedPayload";
	}

	/**
	 * Observe AcceptMixedParameters with omitted Score and empty payload.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs nullptr, NAME_None, empty text, zero vector, empty payload
	 * @Return default Score 5
	 * @Boundary omitted Score
	 */
	UFUNCTION()
	int DefaultScoreOmitted()
	{
		FUFunctionPayload Payload;
		return AcceptMixedParameters(nullptr, NAME_None, FText::FromString(""), FVector::ZeroVector, Payload);
	}

	/**
	 * Observe the default LastScore.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return 0
	 * @Boundary default LastScore
	 */
	UFUNCTION()
	int DefaultLastScore()
	{
		return LastScore;
	}

	/**
	 * Observe the default LastName and LastObject.
	 *
	 * @Kind Observe
	 * @Covers UFunction.Parameter
	 * @Inputs a freshly constructed actor
	 * @Return true when LastName is NAME_None and LastObject is null
	 * @Boundary default LastName
	 */
	UFUNCTION()
	bool DefaultLastNameNone()
	{
		if (LastName != NAME_None)
		{
			return false;
		}
		return LastObject == nullptr;
	}
}
/** @end */
